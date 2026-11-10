/// Optional look-up of a product by its barcode in an open catalogue on the internet.
///
/// It is off unless the user turns it on in the settings. When on, the only thing sent is the number
/// of the barcode; nothing about the purchase, the price, the store or the user goes with it. What
/// comes back is a suggestion of name and brand that the user confirms or corrects. A price never
/// comes from the catalogue.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How a look-up ended. "Not found" and "could not ask" are different facts and are told apart.
enum CatalogStatus { found, notFound, failed }

class CatalogProduct {
  const CatalogProduct({required this.name, this.brand, this.quantity});
  final String name;
  final String? brand;

  /// The size as printed on the package ("500 g", "1 L"), when the catalogue has it.
  final String? quantity;

  /// The name as it is suggested to the user: what the product is and its size.
  String get suggestedName =>
      quantity == null || name.toLowerCase().contains(quantity!.toLowerCase())
      ? name
      : '$name $quantity';
}

class CatalogLookup {
  const CatalogLookup.found(CatalogProduct this.product)
    : status = CatalogStatus.found;
  const CatalogLookup.notFound()
    : status = CatalogStatus.notFound,
      product = null;
  const CatalogLookup.failed() : status = CatalogStatus.failed, product = null;
  final CatalogStatus status;
  final CatalogProduct? product;
}

abstract interface class ProductCatalog {
  /// Name of the source, shown to the user with every suggestion.
  String get sourceName;
  Future<CatalogLookup> lookup(String gtin);
}

/// Only digits, and only the lengths a product code can have (EAN-8, UPC-A, EAN-13, GTIN-14).
bool isLookupCode(String code) => RegExp(r'^\d{8}$|^\d{12,14}$').hasMatch(code);

String? _text(Object? v) {
  if (v is! String) return null;
  final t = v.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t.isEmpty ? null : (t.length > 120 ? t.substring(0, 120) : t);
}

/// Reads the answer of the Open Food Facts product API (v2). Anything unexpected is "not found":
/// the text of a third party is never trusted to have a shape.
CatalogLookup parseOpenFoodFacts(String body) {
  final Object? json;
  try {
    json = jsonDecode(body);
  } on FormatException {
    return const CatalogLookup.failed();
  }
  if (json is! Map<String, dynamic>) return const CatalogLookup.failed();
  final product = json['product'];
  if (json['status'] != 1 || product is! Map<String, dynamic>) {
    return const CatalogLookup.notFound();
  }
  final name =
      _text(product['product_name_pt']) ??
      _text(product['product_name']) ??
      _text(product['generic_name_pt']) ??
      _text(product['generic_name']);
  if (name == null) return const CatalogLookup.notFound();
  return CatalogLookup.found(
    CatalogProduct(
      name: name,
      // Several brands come separated by commas; the first is the one on the package.
      brand: _text((_text(product['brands']) ?? '').split(',').first),
      // The "e" after a size is the estimated-quantity mark of the package, not part of the size.
      quantity: _text(
        (_text(product['quantity']) ?? '').replaceFirst(
          RegExp(r'\s*[e℮]$'),
          '',
        ),
      ),
    ),
  );
}

/// Open Food Facts (openfoodfacts.org), an open database of packaged products (ODbL licence).
class OpenFoodFactsCatalog implements ProductCatalog {
  OpenFoodFactsCatalog({
    HttpClient? client,
    this.timeout = const Duration(seconds: 6),
  }) : _client = client ?? HttpClient();
  final HttpClient _client;
  final Duration timeout;

  /// The largest answer that is read. The fields asked for fit in a fraction of this.
  static const maxBytes = 64 * 1024;

  @override
  String get sourceName => 'Open Food Facts';

  @override
  Future<CatalogLookup> lookup(String gtin) async {
    // The code goes into a URL: only digits of a product code are ever sent.
    if (!isLookupCode(gtin)) return const CatalogLookup.notFound();
    try {
      final uri = Uri.https(
        'world.openfoodfacts.org',
        '/api/v2/product/$gtin.json',
        {
          'fields': 'product_name,product_name_pt,generic_name,generic_name_pt,brands,quantity',
        },
      );
      final request = await _client.getUrl(uri).timeout(timeout);
      // The catalogue asks every app to say what it is; nothing here identifies the user.
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'SerenaCash/0.2 (Android)',
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.followRedirects = false;
      final response = await request.close().timeout(timeout);
      if (response.statusCode == HttpStatus.notFound) {
        await response.drain<void>();
        return const CatalogLookup.notFound();
      }
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        return const CatalogLookup.failed();
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(timeout)) {
        bytes.addAll(chunk);
        if (bytes.length > maxBytes) return const CatalogLookup.failed();
      }
      return parseOpenFoodFacts(utf8.decode(bytes, allowMalformed: true));
    } on Exception {
      // No connection, a timeout, a certificate problem: the look-up could not be made.
      return const CatalogLookup.failed();
    }
  }
}

final productCatalogProvider = Provider<ProductCatalog>(
  (_) => OpenFoodFactsCatalog(),
);
