/// Parser for OCR text of Brazilian shelf price tags. Engine-agnostic and pure: receives recognized lines and returns
/// the best interpretation with confidence, alternatives and warnings; the user always confirms. Mirrors `pricetag.ts`.
library;

import '../money/money.dart';
import 'units.dart';

class OCRLine {
  const OCRLine({required this.text, this.confidence, this.height, this.y});
  final String text;
  final double? confidence;
  final double? height;
  final double? y;
  factory OCRLine.fromJson(Map<String, dynamic> j) => OCRLine(
    text: j['text'] as String,
    confidence: (j['confidence'] as num?)?.toDouble(),
    height: (j['height'] as num?)?.toDouble(),
    y: (j['y'] as num?)?.toDouble(),
  );
}

class PriceCandidate {
  const PriceCandidate({
    required this.cents,
    required this.source,
    required this.score,
    required this.kind,
    this.unit,
  });
  final Cents cents;
  final String source;
  final double score;
  final String kind; // price | promo_from | promo_to | per_unit | installment
  final String? unit;
  Map<String, dynamic> toJson() => {
    'cents': cents,
    'source': source,
    'score': score,
    'kind': kind,
    if (unit != null) 'unit': unit,
  };
}

class Presentation {
  const Presentation(this.quantity, this.unit);
  final double quantity;
  final String unit;
  Map<String, dynamic> toJson() => {'quantity': quantity, 'unit': unit};
}

class PricePerUnit {
  const PricePerUnit(this.cents, this.unit);
  final Cents cents;
  final String unit;
  Map<String, dynamic> toJson() => {'cents': cents, 'unit': unit};
}

class PriceTagReading {
  const PriceTagReading({
    this.name,
    this.brand,
    this.presentation,
    this.priceCents,
    this.promoFromCents,
    this.pricePerUnit,
    required this.priceUnit,
    this.internalCode,
    this.barcode,
    required this.confidence,
    required this.candidates,
    required this.warnings,
  });
  final String? name;
  final String? brand;
  final Presentation? presentation;
  final Cents? priceCents;
  final Cents? promoFromCents;
  final PricePerUnit? pricePerUnit;
  final String priceUnit;
  final String? internalCode;
  final String? barcode;
  final double confidence;
  final List<PriceCandidate> candidates;
  final List<String> warnings;
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (brand != null) 'brand': brand,
    if (presentation != null) 'presentation': presentation!.toJson(),
    if (priceCents != null) 'priceCents': priceCents,
    if (promoFromCents != null) 'promoFromCents': promoFromCents,
    if (pricePerUnit != null) 'pricePerUnit': pricePerUnit!.toJson(),
    'priceUnit': priceUnit,
    if (internalCode != null) 'internalCode': internalCode,
    if (barcode != null) 'barcode': barcode,
    'confidence': confidence,
    'candidates': candidates.map((c) => c.toJson()).toList(),
    'warnings': warnings,
  };
}

final _moneyRe = RegExp(
  r'(?:R\$\s*)?(\d{1,3}(?:\.\d{3})*|\d+)\s*[,.]\s*(\d{2})(?!\d)',
);
final _perUnitRe = RegExp(
  r'(?:R\$\s*)?(\d{1,3}(?:\.\d{3})*|\d+)[,.](\d{2})(?:\s*(?:\/|por|p\/)\s*|\s+(?:o\s+|a\s+)?)(kg|g|l|lt|ml|un|und|m)\b',
  caseSensitive: false,
);
final _presentationRe = RegExp(
  r'(\d+(?:[,.]\d+)?)\s*(kg|g|gr|l|lt|ml|un|und|unid|pç|pc|m)\b',
  caseSensitive: false,
);
final _promoFromRe = RegExp(
  r'\bde\s*(?:R\$)?\s*(\d{1,3}(?:\.\d{3})*|\d+)[,.](\d{2})',
  caseSensitive: false,
);
final _promoToRe = RegExp(
  r'\bpor\s*(?:R\$)?\s*(\d{1,3}(?:\.\d{3})*|\d+)[,.](\d{2})',
  caseSensitive: false,
);
final _installmentRe = RegExp(
  r'(\d{1,2})\s*x\s*(?:de\s*)?(?:R\$)?\s*(\d{1,3}(?:\.\d{3})*|\d+)[,.](\d{2})',
  caseSensitive: false,
);
final _codeRe = RegExp(
  r'\b(?:cod|cód|codigo|código|sku)[.:\s]*(\d{3,8})\b',
  caseSensitive: false,
);
final _barcodeRe = RegExp(r'\b(\d{13}|\d{8})\b');
final _noiseRe = RegExp(
  r'^(?:oferta|promo[cç][aã]o|desconto|leve|pague|economize|preço|preco|valor|unid|un\.?|clube|app|s[oó] hoje|validade|at[eé]|apenas|a partir de)\b',
  caseSensitive: false,
);
final _alphaRe = RegExp(r'[a-zA-ZÀ-ÿ]{3,}');
final _priceLikeRe = RegExp(r'R\$|\d+[,.]\d{2}');

Cents? _toCents(String intPart, String frac) => parseMoneyBR('$intPart,$frac');
double _round2(double v) => (v * 100).roundToDouble() / 100;

PriceTagReading parsePriceTag(List<OCRLine> lines) {
  final warnings = <String>[];
  final candidates = <PriceCandidate>[];
  final text = lines.map((l) => l.text).join('\n');
  final maxHeight = [
    1.0,
    ...lines.map((l) => l.height ?? 0),
  ].reduce((a, b) => a > b ? a : b);

  PricePerUnit? pricePerUnit;
  final perUnit = _perUnitRe.firstMatch(text);
  if (perUnit != null) {
    final c = _toCents(perUnit[1]!, perUnit[2]!);
    final u = parseUnit(perUnit[3]!);
    if (c != null && u != null) {
      pricePerUnit = PricePerUnit(c, u);
      candidates.add(
        PriceCandidate(
          cents: c,
          source: perUnit[0]!,
          score: 0.6,
          kind: 'per_unit',
          unit: u,
        ),
      );
    }
  }
  final promoTo = _promoToRe.firstMatch(text);
  final promoFrom = _promoFromRe.firstMatch(text);
  Cents? promoFromCents;
  if (promoFrom != null) {
    final c = _toCents(promoFrom[1]!, promoFrom[2]!);
    if (c != null) {
      promoFromCents = c;
      candidates.add(
        PriceCandidate(
          cents: c,
          source: promoFrom[0]!,
          score: 0.3,
          kind: 'promo_from',
        ),
      );
    }
  }
  if (promoTo != null) {
    final c = _toCents(promoTo[1]!, promoTo[2]!);
    if (c != null) {
      candidates.add(
        PriceCandidate(
          cents: c,
          source: promoTo[0]!,
          score: 0.95,
          kind: 'promo_to',
        ),
      );
    }
  }
  final inst = _installmentRe.firstMatch(text);
  if (inst != null) {
    final c = _toCents(inst[2]!, inst[3]!);
    if (c != null) {
      candidates.add(
        PriceCandidate(
          cents: c,
          source: inst[0]!,
          score: 0.2,
          kind: 'installment',
        ),
      );
    }
  }
  for (final line in lines) {
    for (final m in _moneyRe.allMatches(line.text)) {
      final c = _toCents(m[1]!, m[2]!);
      if (c == null || c == 0) continue;
      if (candidates.any((k) => k.cents == c && k.kind != 'price')) continue;
      final heightScore = line.height != null
          ? (line.height! / maxHeight) * 0.6
          : 0.3;
      final confScore = (line.confidence ?? 0.7) * 0.3;
      final hasSymbol = line.text.contains(r'R$') ? 0.1 : 0.0;
      candidates.add(
        PriceCandidate(
          cents: c,
          source: line.text.trim(),
          score: [
            0.9,
            heightScore + confScore + hasSymbol,
          ].reduce((a, b) => a < b ? a : b),
          kind: 'price',
        ),
      );
    }
  }
  final priceCandidates = candidates
      .where((c) => c.kind == 'price' || c.kind == 'promo_to')
      .toList();
  final pcIdx = priceCandidates.asMap().entries.toList()
    ..sort((a, b) {
      final d = b.value.score.compareTo(a.value.score);
      return d != 0 ? d : a.key.compareTo(b.key);
    });
  final sortedPrices = pcIdx.map((e) => e.value).toList();
  final best = sortedPrices.firstOrNull;
  var priceCents = best?.cents;
  if (pricePerUnit != null &&
      priceCents != null &&
      pricePerUnit.cents == priceCents &&
      sortedPrices.length > 1) {
    priceCents = sortedPrices[1].cents;
  }

  final textNoMoney = text.replaceAll(_moneyRe, ' ');
  final pres = _presentationRe.firstMatch(textNoMoney);
  Presentation? presentation;
  if (pres != null) {
    final u = parseUnit(pres[2]!);
    final q = double.tryParse(pres[1]!.replaceAll(',', '.'));
    if (u != null && q != null && q.isFinite && q > 0) {
      presentation = Presentation(q, u);
    }
  }
  var priceUnit = 'un';
  if (priceCents == null && pricePerUnit != null) {
    priceCents = pricePerUnit.cents;
    priceUnit = pricePerUnit.unit;
  } else if (pricePerUnit != null &&
      priceCents != null &&
      pricePerUnit.cents == priceCents) {
    priceUnit = pricePerUnit.unit;
  } else if (RegExp(r'\bkg\b', caseSensitive: false).hasMatch(text) &&
      presentation == null) {
    priceUnit = 'kg';
  }

  final nameLines = lines
      .map((l) => l.text.trim())
      .where(
        (t) =>
            t.length >= 3 &&
            _alphaRe.hasMatch(t) &&
            !_noiseRe.hasMatch(t) &&
            !_priceLikeRe.hasMatch(t) &&
            !_codeRe.hasMatch(t) &&
            !_barcodeRe.hasMatch(t),
      )
      .toList();
  final nameIdx = nameLines.asMap().entries.toList()
    ..sort((a, b) {
      final d = b.value.length.compareTo(a.value.length);
      return d != 0 ? d : a.key.compareTo(b.key);
    });
  final name = nameIdx.isEmpty
      ? null
      : nameIdx.first.value.replaceAll(RegExp(r'\s+'), ' ');
  final code = _codeRe.firstMatch(text)?.group(1);
  final barcode = _barcodeRe.firstMatch(text)?.group(1);

  var confidence = 0.0;
  if (priceCents != null) {
    confidence += best != null
        ? [0.6, best.score * 0.65].reduce((a, b) => a < b ? a : b)
        : (pricePerUnit != null ? 0.45 : 0);
  }
  if (name != null) confidence += 0.25;
  if (presentation != null || pricePerUnit != null) confidence += 0.1;
  if (sortedPrices.length > 1 &&
      sortedPrices[1].score >= (best?.score ?? 0) - 0.1) {
    confidence -= 0.15;
    warnings.add('Mais de um preço parecido na etiqueta; confirme o valor.');
  }
  if (priceCents == null) {
    warnings.add('Nenhum preço reconhecido; informe manualmente.');
  }
  if (name == null) warnings.add('Nome do produto não reconhecido.');
  if (lines.any((l) => (l.confidence ?? 1) < 0.5)) confidence -= 0.1;
  confidence = _round2(confidence.clamp(0, 1));
  final allIdx = candidates.asMap().entries.toList()
    ..sort((a, b) {
      final d = b.value.score.compareTo(a.value.score);
      return d != 0 ? d : a.key.compareTo(b.key);
    });
  return PriceTagReading(
    name: name,
    presentation: presentation,
    priceCents: priceCents,
    promoFromCents: promoFromCents,
    pricePerUnit: pricePerUnit,
    priceUnit: priceUnit,
    internalCode: code,
    barcode: barcode,
    confidence: confidence,
    candidates: allIdx.map((e) => e.value).toList(),
    warnings: warnings,
  );
}
