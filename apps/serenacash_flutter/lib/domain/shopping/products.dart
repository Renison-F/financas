/// Local product catalog and price history built from the user's own scans. Mirrors `products.ts`.
library;

import '../money/money.dart';
import '../text/normalize.dart';
import 'units.dart';

class InternalCode {
  const InternalCode(this.store, this.code);
  final String store;
  final String code;
  factory InternalCode.fromJson(Map<String, dynamic> j) =>
      InternalCode(j['store'] as String, j['code'] as String);
  Map<String, dynamic> toJson() => {'store': store, 'code': code};
}

class ProductPresentation {
  const ProductPresentation(this.quantity, this.unit);
  final double quantity;
  final String unit;
  factory ProductPresentation.fromJson(Map<String, dynamic> j) =>
      ProductPresentation(
        (j['quantity'] as num).toDouble(),
        j['unit'] as String,
      );
  Map<String, dynamic> toJson() => {'quantity': quantity, 'unit': unit};
}

class Product {
  const Product({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    required this.internalCodes,
    required this.defaultUnit,
    this.presentation,
    this.category,
    required this.favorite,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String name;
  final String? brand;
  final String? barcode;
  final List<InternalCode> internalCodes;
  final String defaultUnit;
  final ProductPresentation? presentation;
  final String? category;
  final bool favorite;
  final String createdAt;
  final String updatedAt;
  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] as String,
    name: j['name'] as String,
    brand: j['brand'] as String?,
    barcode: j['barcode'] as String?,
    internalCodes: (j['internalCodes'] as List<dynamic>? ?? const [])
        .map((e) => InternalCode.fromJson(e as Map<String, dynamic>))
        .toList(),
    defaultUnit: j['defaultUnit'] as String,
    presentation: j['presentation'] == null
        ? null
        : ProductPresentation.fromJson(
            j['presentation'] as Map<String, dynamic>,
          ),
    category: j['category'] as String?,
    favorite: j['favorite'] as bool? ?? false,
    createdAt: j['createdAt'] as String,
    updatedAt: j['updatedAt'] as String,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (brand != null) 'brand': brand,
    if (barcode != null) 'barcode': barcode,
    'internalCodes': internalCodes.map((c) => c.toJson()).toList(),
    'defaultUnit': defaultUnit,
    if (presentation != null) 'presentation': presentation!.toJson(),
    if (category != null) 'category': category,
    'favorite': favorite,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class PriceObservation {
  const PriceObservation({
    required this.id,
    required this.productId,
    this.store,
    required this.unit,
    required this.unitPriceCents,
    required this.observedAt,
    required this.source,
    this.sessionId,
    this.promo,
  });
  final String id;
  final String productId;
  final String? store;
  final String unit;
  final Cents unitPriceCents;
  final String observedAt;
  final String source; // label_ocr | manual | receipt | history
  final String? sessionId;
  final bool? promo;
  factory PriceObservation.fromJson(Map<String, dynamic> j) => PriceObservation(
    id: j['id'] as String,
    productId: j['productId'] as String,
    store: j['store'] as String?,
    unit: j['unit'] as String,
    unitPriceCents: (j['unitPriceCents'] as num).toInt(),
    observedAt: j['observedAt'] as String,
    source: j['source'] as String,
    sessionId: j['sessionId'] as String?,
    promo: j['promo'] as bool?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    if (store != null) 'store': store,
    'unit': unit,
    'unitPriceCents': unitPriceCents,
    'observedAt': observedAt,
    'source': source,
    if (sessionId != null) 'sessionId': sessionId,
    if (promo != null) 'promo': promo,
  };
}

String _norm(String s) =>
    stripDiacritics(s.toLowerCase())
        .replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

class ProductMatch {
  const ProductMatch(this.product, this.match, this.score);
  final Product product;
  final String match; // barcode | internal_code | name
  final double score;
  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'match': match,
    'score': score,
  };
}

/// Finds a product by barcode, by store internal code, or by fuzzy name (token overlap ≥ 0.6).
ProductMatch? findProduct(
  List<Product> products, {
  String? barcode,
  String? store,
  String? internalCode,
  String? name,
}) {
  if (barcode != null && barcode.isNotEmpty) {
    final p = products.where((p) => p.barcode == barcode).firstOrNull;
    if (p != null) return ProductMatch(p, 'barcode', 1);
  }
  if (internalCode != null && internalCode.isNotEmpty) {
    final p = products
        .where(
          (p) => p.internalCodes.any(
            (c) =>
                c.code == internalCode &&
                (store == null || store.isEmpty || c.store == store),
          ),
        )
        .firstOrNull;
    if (p != null) return ProductMatch(p, 'internal_code', 0.95);
  }
  if (name != null && name.isNotEmpty) {
    final a = _norm(name).split(' ').where((w) => w.length > 1).toSet();
    ProductMatch? best;
    for (final p in products) {
      final b = _norm('${p.name} ${p.brand ?? ''}')
          .split(' ')
          .where((w) => w.length > 1)
          .toSet();
      final inter = a.where(b.contains).length;
      final score = a.isNotEmpty && b.isNotEmpty
          ? inter / (a.length > b.length ? a.length : b.length)
          : 0.0;
      if (score >= 0.6 && (best == null || score > best.score)) {
        best = ProductMatch(p, 'name', score);
      }
    }
    if (best != null) return best;
  }
  return null;
}

class StorePrice {
  const StorePrice({
    required this.store,
    required this.lastCents,
    required this.lastAt,
    required this.count,
  });
  final String store;
  final Cents lastCents;
  final String lastAt;
  final int count;
  Map<String, dynamic> toJson() => {
    'store': store,
    'lastCents': lastCents,
    'lastAt': lastAt,
    'count': count,
  };
}

class PriceHistory {
  const PriceHistory({
    this.lastCents,
    this.lastStore,
    this.lastAt,
    this.minCents,
    this.maxCents,
    this.avgCents,
    required this.byStore,
    required this.observations,
    this.lastPerBaseUnitCents,
  });
  final Cents? lastCents;
  final String? lastStore;
  final String? lastAt;
  final Cents? minCents;
  final Cents? maxCents;
  final Cents? avgCents;
  final List<StorePrice> byStore;
  final int observations;
  final Cents? lastPerBaseUnitCents;
  Map<String, dynamic> toJson() => {
    if (lastCents != null) 'lastCents': lastCents,
    if (lastStore != null) 'lastStore': lastStore,
    if (lastAt != null) 'lastAt': lastAt,
    if (minCents != null) 'minCents': minCents,
    if (maxCents != null) 'maxCents': maxCents,
    if (avgCents != null) 'avgCents': avgCents,
    'byStore': byStore.map((s) => s.toJson()).toList(),
    'observations': observations,
    if (lastPerBaseUnitCents != null)
      'lastPerBaseUnitCents': lastPerBaseUnitCents,
  };
}

int _jsRound(double v) => (v + 0.5).floorToDouble().toInt();

PriceHistory priceHistory(
  List<PriceObservation> observations,
  String productId, [
  String? unit,
]) {
  final idx =
      observations
          .asMap()
          .entries
          .where(
            (e) =>
                e.value.productId == productId &&
                (unit == null || e.value.unit == unit),
          )
          .toList()
        ..sort((a, b) {
          final d = a.value.observedAt.compareTo(b.value.observedAt);
          return d != 0 ? d : a.key.compareTo(b.key);
        });
  final obs = idx.map((e) => e.value).toList();
  if (obs.isEmpty) return const PriceHistory(byStore: [], observations: 0);
  final last = obs.last;
  final prices = obs.map((o) => o.unitPriceCents).toList();
  final byStore = <String, StorePrice>{};
  for (final o in obs) {
    final k = o.store ?? 'Sem loja';
    byStore[k] = StorePrice(
      store: k,
      lastCents: o.unitPriceCents,
      lastAt: o.observedAt,
      count: (byStore[k]?.count ?? 0) + 1,
    );
  }
  final stores = byStore.values.toList().asMap().entries.toList()
    ..sort((a, b) {
      final d = a.value.lastCents.compareTo(b.value.lastCents);
      return d != 0 ? d : a.key.compareTo(b.key);
    });
  final base = toBaseQuantity(1, last.unit);
  return PriceHistory(
    lastCents: last.unitPriceCents,
    lastStore: last.store,
    lastAt: last.observedAt,
    minCents: prices.reduce((a, b) => a < b ? a : b),
    maxCents: prices.reduce((a, b) => a > b ? a : b),
    avgCents: _jsRound(prices.fold<int>(0, (a, b) => a + b) / prices.length),
    byStore: stores.map((e) => e.value).toList(),
    observations: obs.length,
    lastPerBaseUnitCents: base.quantity > 0
        ? mulCents(last.unitPriceCents, 1 / base.quantity, RoundingMode.halfUp)
        : null,
  );
}

class PriceVariation {
  const PriceVariation(this.percent, this.vsCents);
  final double percent;
  final Cents vsCents;
  Map<String, dynamic> toJson() => {'percent': percent, 'vsCents': vsCents};
}

/// Current vs last observation at any store (percent, positive = more expensive).
PriceVariation? priceVariation(PriceHistory history, Cents currentCents) {
  final last = history.lastCents;
  if (last == null || last == 0) return null;
  return PriceVariation(
    _jsRound((currentCents - last) / last * 1000) / 10,
    last,
  );
}
