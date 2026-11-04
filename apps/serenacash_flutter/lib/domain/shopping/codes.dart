/// Barcode and QR helpers. A barcode identifies a product; it never carries a shelf price (except GS1
/// variable-measure codes, whose embedded value may be weight or price and is never assumed). Mirrors `codes.ts`.
library;

class VariableMeasure {
  const VariableMeasure({
    required this.itemCode,
    required this.embedded,
    this.valueCents,
    this.grams,
  });
  final String itemCode;
  final String embedded; // price | weight | unknown
  final int? valueCents;
  final int? grams;
  Map<String, dynamic> toJson() => {
    'itemCode': itemCode,
    'embedded': embedded,
    if (valueCents != null) 'valueCents': valueCents,
    if (grams != null) 'grams': grams,
  };
}

class ParsedBarcode {
  const ParsedBarcode({
    required this.raw,
    required this.kind,
    required this.valid,
    this.gtin,
    this.variableMeasure,
  });
  final String raw;
  final String kind; // ean13 | ean8 | upc_a | upc_e | gs1_variable_measure | internal | unknown
  final bool valid;
  final String? gtin;
  final VariableMeasure? variableMeasure;
  Map<String, dynamic> toJson() => {
    'raw': raw,
    'kind': kind,
    'valid': valid,
    if (gtin != null) 'gtin': gtin,
    if (variableMeasure != null) 'variableMeasure': variableMeasure!.toJson(),
  };
}

bool gtinChecksumValid(String digits) {
  if (!RegExp(r'^\d{8}$|^\d{12,14}$').hasMatch(digits)) return false;
  final body = digits.substring(0, digits.length - 1);
  final check = int.parse(digits[digits.length - 1]);
  var sum = 0;
  for (var i = 0; i < body.length; i++) {
    final d = int.parse(body[body.length - 1 - i]);
    sum += d * (i.isEven ? 3 : 1);
  }
  return (10 - (sum % 10)) % 10 == check;
}

ParsedBarcode parseBarcode(String raw) {
  final s = raw.replaceAll(RegExp(r'\s+'), '');
  if (!RegExp(r'^\d+$').hasMatch(s)) {
    return ParsedBarcode(raw: raw, kind: 'unknown', valid: false);
  }
  if (s.length == 13) {
    final valid = gtinChecksumValid(s);
    if (s.startsWith('2')) {
      final value = int.parse(s.substring(7, 12));
      return ParsedBarcode(
        raw: raw,
        kind: 'gs1_variable_measure',
        valid: valid,
        gtin: s,
        variableMeasure: VariableMeasure(
          itemCode: s.substring(1, 7),
          embedded: 'unknown',
          valueCents: value,
          grams: value,
        ),
      );
    }
    return ParsedBarcode(raw: raw, kind: 'ean13', valid: valid, gtin: s);
  }
  if (s.length == 8) {
    return ParsedBarcode(
      raw: raw,
      kind: 'ean8',
      valid: gtinChecksumValid(s),
      gtin: '00000$s',
    );
  }
  if (s.length == 12) {
    return ParsedBarcode(
      raw: raw,
      kind: 'upc_a',
      valid: gtinChecksumValid(s),
      gtin: '0$s',
    );
  }
  if (s.length == 14) {
    return ParsedBarcode(
      raw: raw,
      kind: 'ean13',
      valid: gtinChecksumValid(s),
      gtin: s.substring(1),
    );
  }
  if (s.length >= 4 && s.length <= 7) {
    return ParsedBarcode(raw: raw, kind: 'internal', valid: true);
  }
  return ParsedBarcode(raw: raw, kind: 'unknown', valid: false);
}

class NFCeQR {
  const NFCeQR({
    required this.accessKey,
    this.uf,
    this.emissionYearMonth,
    this.cnpj,
    required this.url,
  });
  final String accessKey;
  final String? uf;
  final String? emissionYearMonth;
  final String? cnpj;
  final String url;
  Map<String, dynamic> toJson() => {
    'accessKey': accessKey,
    if (uf != null) 'uf': uf,
    if (emissionYearMonth != null) 'emissionYearMonth': emissionYearMonth,
    if (cnpj != null) 'cnpj': cnpj,
    'url': url,
  };
}

/// Brazilian NFC-e QR code: URL with `p=` param "chave|versao|ambiente|[cIdToken]|assinatura".
NFCeQR? parseNFCeQR(String data) {
  final m =
      RegExp(r'[?&]p=([0-9]{44})\|', caseSensitive: false).firstMatch(data) ??
      RegExp(r'chNFe=([0-9]{44})', caseSensitive: false).firstMatch(data);
  if (m == null) return null;
  final key = m.group(1)!;
  return NFCeQR(
    accessKey: key,
    uf: key.substring(0, 2),
    emissionYearMonth: '20${key.substring(2, 4)}-${key.substring(4, 6)}',
    cnpj: key.substring(6, 20),
    url: data,
  );
}
