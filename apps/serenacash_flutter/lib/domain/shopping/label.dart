/// Reading of a shelf label from OCR lines *with their position on the photo*.
///
/// Recognizing characters is not the same as understanding a label. A label carries a description,
/// one price in evidence, sometimes a second price with a condition (wholesale from N units), a
/// price per kilo or per liter in small print, a slogan, a validity date and a bar code. This module
/// tells those apart using where each line sits and how tall it is, and returns every candidate with
/// the reason it was (or was not) chosen, so the screen can show its work and the user can correct
/// it. Nothing here adds an item to a cart: the user always confirms.
///
/// The cases in test/fixtures/labels are real engine output for photos taken in a supermarket.
library;

import '../money/money.dart';
import '../text/normalize.dart';
import 'codes.dart';

/// One recognized line and its box on the photo, in pixels of the photo.
class OcrBox {
  const OcrBox({
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.block = 0,
    this.confidence,
  });
  final String text;
  final double left, top, width, height;

  /// Lines the engine grouped as one paragraph share a block.
  final int block;
  final double? confidence;
  double get right => left + width;
  double get bottom => top + height;
  double get centerX => left + width / 2;
  double get centerY => top + height / 2;

  factory OcrBox.fromJson(Map<String, dynamic> j) => OcrBox(
    text: j['text'] as String,
    left: (j['left'] as num).toDouble(),
    top: (j['top'] as num).toDouble(),
    width: (j['width'] as num).toDouble(),
    height: (j['height'] as num).toDouble(),
    block: (j['block'] as num?)?.toInt() ?? 0,
    confidence: (j['confidence'] as num?)?.toDouble(),
  );
  Map<String, dynamic> toJson() => {
    'text': text,
    'left': left,
    'top': top,
    'width': width,
    'height': height,
    'block': block,
    if (confidence != null) 'confidence': confidence,
  };
}

/// What a price on the label is.
enum LabelPriceRole {
  /// The price of one item for anyone: the one that goes to the cart by default.
  retail,

  /// A lower price that only applies from a minimum quantity.
  wholesale,

  /// Price per kilo, liter or other measure, printed for comparison. Not the price of the item.
  perMeasure,

  /// "Price per unit" of a pack, printed for comparison. Not the price of the item either.
  perUnitOfPack,
}

class LabelPrice {
  const LabelPrice({
    required this.cents,
    required this.role,
    required this.line,
    required this.confidence,
    required this.reason,
    this.unit,
    this.minQuantity,
    this.repaired = false,
  });
  final Cents cents;
  final LabelPriceRole role;

  /// Index of the OCR line the value came from.
  final int line;

  /// 0..1, from the engine's own figure for the line, lowered when the text had to be repaired.
  /// It is not a calibrated probability: below [LabelAnalysis.reviewThreshold] the user is asked to
  /// check, and above it the user still confirms.
  final double confidence;

  /// Why this value has this role, in words the screen can show.
  final String reason;

  /// For [LabelPriceRole.perMeasure]: `kg`, `l`…
  final String? unit;

  /// For [LabelPriceRole.wholesale]: the minimum quantity, when the label states it.
  final int? minQuantity;

  /// The digits were read with stray characters ("4.99-", "9,.49") and were cleaned up.
  final bool repaired;
}

class LabelName {
  const LabelName({
    required this.text,
    required this.lines,
    required this.score,
    required this.reason,
  });
  final String text;
  final List<int> lines;
  final double score;
  final String reason;
}

class LabelAnalysis {
  const LabelAnalysis({
    required this.names,
    required this.prices,
    required this.unit,
    required this.reviewReasons,
    this.price,
    this.barcode,
    this.crossChecked = false,
  });

  /// Below this, the price is shown as "needs review" and has to be confirmed explicitly.
  static const reviewThreshold = 0.7;

  /// Candidates for the product description, best first.
  final List<LabelName> names;

  /// Every price found, the chosen one first.
  final List<LabelPrice> prices;

  /// The price proposed for the cart, when one could be told apart. Null when none or when the only
  /// prices found are conditional or per measure.
  final LabelPrice? price;
  final String unit;
  final String? barcode;

  /// Reasons the reading has to be checked against the photo. Empty when nothing looked off.
  final List<String> reviewReasons;

  /// The chosen price agrees with the price per kilo/liter printed on the label and the weight in
  /// the description.
  final bool crossChecked;

  LabelName? get name => names.firstOrNull;
  bool get needsReview => reviewReasons.isNotEmpty;
  LabelPrice? get wholesale =>
      prices.where((p) => p.role == LabelPriceRole.wholesale).firstOrNull;
}

final _moneyToken = RegExp(r'(\d{1,4})\s*[,.]\s*[,.]?\s*(\d{2})(?!\d)');
final _cleanPrice = RegExp(r'^(?:r\$)?\s*\d{1,4},\d{2}$');
final _perLine = RegExp(
  r'pr.{0,4}o\s+por\b|\bpor\s+(kilo|quilo|kg|litro|unidade)\b',
);
final _roleRetail = RegExp(r'^varejo(\s*r\$)?$');
final _roleWholesale = RegExp(r'^atacado(\s*r\$)?$');
final _minQuantity = RegExp(r'a partir de\s*(\d{1,3})');
final _notDescription = RegExp(
  r'^(r\$|un|und|unid|kg|por\s*\w{0,3}|\w{0,2}\s*un|cada)$|'
  r'oferta|valid|promo|prom\w*cao|a partir de|feito com|foto com|cartaz|'
  r'\bloja\b|atacad|varejo|aproveite|pre[cç]o baixo|qualidade|hortifruti|'
  r'\d{2}/\d{2}/\d{2,4}',
);
final _weight = RegExp(r'(\d+(?:[,.]\d+)?)\s*\(?\s*(kg|g|gr|ml|l|lt)\b');
final _digitsRun = RegExp(r'\d{8,14}');

double _lowercaseRatio(String s) {
  var lower = 0, letters = 0;
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    if (ch.toLowerCase() == ch.toUpperCase()) continue;
    letters++;
    if (ch == ch.toLowerCase()) lower++;
  }
  return letters == 0 ? 0 : lower / letters;
}

int _letters(String s) => s.runes.where((r) {
  final ch = String.fromCharCode(r);
  return ch.toLowerCase() != ch.toUpperCase();
}).length;

String? _measureUnit(String normalized) {
  if (RegExp(r'por\s+(kilo|quilo|kg|k|\w?ilo)\b').hasMatch(normalized)) {
    return 'kg';
  }
  if (RegExp(r'por\s+(litro|l)\b').hasMatch(normalized)) return 'l';
  if (RegExp(r'por\s+(unidade|un|\w{0,3}da\s?\w?)\b').hasMatch(normalized)) {
    return 'un';
  }
  return null;
}

LabelAnalysis analyzeLabel(List<OcrBox> lines) {
  final norm = [for (final l in lines) normalizeText(l.text).trim()];
  final prices = <LabelPrice>[];
  final review = <String>[];

  // 1. Money on each line. A "price per ..." line is comparison print: none of it is the item price.
  final display = <({int line, int cents, bool repaired})>[];
  for (var i = 0; i < lines.length; i++) {
    final perLine = _perLine.hasMatch(norm[i]);
    for (final m in _moneyToken.allMatches(norm[i])) {
      final cents = int.parse(m[1]!) * 100 + int.parse(m[2]!);
      if (cents == 0) continue;
      if (perLine) {
        final unit = _measureUnit(norm[i]);
        prices.add(
          LabelPrice(
            cents: cents,
            role: unit == 'un' || unit == null
                ? LabelPriceRole.perUnitOfPack
                : LabelPriceRole.perMeasure,
            unit: unit,
            line: i,
            confidence: lines[i].confidence ?? 0.5,
            reason: unit == 'kg'
                ? 'Preço por quilo, impresso para comparação.'
                : unit == 'l'
                ? 'Preço por litro, impresso para comparação.'
                : 'Preço por unidade da embalagem, impresso para comparação.',
          ),
        );
      } else {
        display.add((
          line: i,
          cents: cents,
          repaired: !_cleanPrice.hasMatch(norm[i]),
        ));
      }
    }
  }

  // 2. The prices in evidence are the tall ones: the label is printed so that the eye finds them.
  final tallest = display.fold<double>(
    0,
    (m, d) => lines[d.line].height > m ? lines[d.line].height : m,
  );
  final evidence = display
      .where((d) => lines[d.line].height >= tallest * 0.6)
      .toList();

  // 3. "VAREJO" / "ATACADO" printed near a price say which one it is.
  final roleLabels = <({int line, LabelPriceRole role})>[
    for (var i = 0; i < lines.length; i++)
      if (_roleRetail.hasMatch(norm[i]))
        (line: i, role: LabelPriceRole.retail)
      else if (_roleWholesale.hasMatch(norm[i]))
        (line: i, role: LabelPriceRole.wholesale),
  ];
  int? minQuantity;
  for (final n in norm) {
    final m = _minQuantity.firstMatch(n);
    if (m != null) minQuantity = int.tryParse(m[1]!);
  }
  final hasWholesaleLabel = roleLabels.any(
    (r) => r.role == LabelPriceRole.wholesale,
  );
  for (final d in evidence) {
    final box = lines[d.line];
    LabelPriceRole role = LabelPriceRole.retail;
    var reason = 'Preço em destaque na etiqueta.';
    if (roleLabels.isNotEmpty) {
      // Nearest label that starts above the bottom of the price; side by side columns are told
      // apart by horizontal distance.
      ({int line, LabelPriceRole role})? nearest;
      double? best;
      for (final r in roleLabels) {
        final rb = lines[r.line];
        if (rb.top > box.bottom) continue;
        final dist =
            (rb.centerX - box.centerX).abs() + (box.centerY - rb.centerY).abs();
        if (best == null || dist < best) {
          best = dist;
          nearest = r;
        }
      }
      if (nearest != null) {
        role = nearest.role;
        reason = role == LabelPriceRole.retail
            ? 'Preço em destaque, sob a indicação "varejo".'
            : 'Preço sob a indicação "atacado"${minQuantity != null ? ', a partir de $minQuantity unidades' : ''}.';
      }
    }
    final conf = (box.confidence ?? 0.7) * (d.repaired ? 0.85 : 1);
    prices.add(
      LabelPrice(
        cents: d.cents,
        role: role,
        line: d.line,
        confidence: double.parse(conf.toStringAsFixed(3)),
        reason: reason,
        minQuantity: role == LabelPriceRole.wholesale ? minQuantity : null,
        repaired: d.repaired,
      ),
    );
  }
  // Small prices that are neither in evidence nor on a "price per" line: kept as other candidates.
  for (final d in display) {
    if (evidence.contains(d)) continue;
    prices.add(
      LabelPrice(
        cents: d.cents,
        role: LabelPriceRole.perUnitOfPack,
        line: d.line,
        confidence: (lines[d.line].confidence ?? 0.5) * 0.5,
        reason: 'Valor em letras pequenas, fora do destaque.',
        repaired: d.repaired,
      ),
    );
  }

  // 4. The price for the cart: the retail one in evidence. A wholesale price is never taken on its
  // own, because it depends on a quantity the user has not chosen yet.
  final retail = prices.where((p) => p.role == LabelPriceRole.retail).toList()
    ..sort((a, b) => lines[b.line].height.compareTo(lines[a.line].height));
  final chosen = retail.firstOrNull;
  if (chosen == null) {
    review.add(
      prices.any((p) => p.role == LabelPriceRole.wholesale)
          ? 'Só o preço de atacado foi lido; confira o preço de varejo na foto.'
          : 'Nenhum preço em destaque foi lido; informe o preço.',
    );
  } else {
    if (retail.where((p) => p.cents != chosen.cents).isNotEmpty) {
      review.add('Mais de um preço em destaque; confira qual vale para você.');
    }
    if (chosen.repaired) {
      review.add(
        'Os dígitos do preço foram lidos com falhas; confira na foto.',
      );
    } else if (chosen.confidence < LabelAnalysis.reviewThreshold) {
      review.add('Leitura do preço com pouca nitidez; confira na foto.');
    }
    if (hasWholesaleLabel && minQuantity != null) {
      // Not a problem with the reading: the label really has two prices.
    }
  }

  // 5. The description: the text right above the price in evidence. Slogans, the store banner, the
  // validity of the offer and comparison print are not descriptions, however long they are.
  final anchor = chosen != null
      ? lines[chosen.line]
      : (evidence.isNotEmpty ? lines[evidence.first.line] : null);
  final blocks = <int, List<int>>{};
  for (var i = 0; i < lines.length; i++) {
    final n = norm[i];
    if (_letters(n) < 3) continue;
    if (_notDescription.hasMatch(n)) continue;
    if (_perLine.hasMatch(n)) continue;
    if (_moneyToken.hasMatch(n) && _letters(n) < 6) continue;
    if (_digitsRun.hasMatch(n) && _letters(n) < 4) continue;
    blocks.putIfAbsent(lines[i].block, () => []).add(i);
  }
  final names = <LabelName>[];
  for (final idx in blocks.values) {
    idx.sort((a, b) => lines[a].top.compareTo(lines[b].top));
    final text = idx
        .map((i) => lines[i].text.trim())
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    final top = lines[idx.first].top, bottom = lines[idx.last].bottom;
    final conf =
        idx.map((i) => lines[i].confidence ?? 0.7).reduce((a, b) => a + b) /
        idx.length;
    var score = conf;
    var reason = 'Texto da etiqueta.';
    if (anchor != null) {
      final unitH = anchor.height <= 0 ? 1.0 : anchor.height;
      if (bottom <= anchor.top + unitH * 0.25) {
        final gap = (anchor.top - bottom).clamp(0, double.infinity) / unitH;
        score *= 1 / (1 + gap);
        reason = 'Texto logo acima do preço em destaque.';
      } else if (top >= anchor.bottom - unitH * 0.25) {
        score *= 0.25;
        reason = 'Texto abaixo do preço.';
      } else {
        score *= 0.4;
        reason = 'Texto ao lado do preço.';
      }
    }
    // Descriptions on labels are printed in capitals; a sentence in lower case is usually a slogan.
    if (_lowercaseRatio(text) > 0.35) {
      score *= 0.4;
      reason = 'Frase em minúsculas (costuma ser slogan).';
    }
    if (conf < 0.5) score *= 0.5;
    names.add(
      LabelName(
        text: text,
        lines: idx,
        score: double.parse(score.toStringAsFixed(4)),
        reason: reason,
      ),
    );
  }
  names.sort((a, b) => b.score.compareTo(a.score));
  if (names.isEmpty) {
    review.add('A descrição do produto não foi lida; informe o nome.');
  } else if (names.first.score < 0.2) {
    review.add('A descrição pode não ser a do produto; confira o nome.');
  }

  // 6. Bar code printed on the label: only a number whose check digit closes is accepted.
  String? barcode;
  for (final n in norm) {
    for (final m in _digitsRun.allMatches(n)) {
      final parsed = parseBarcode(m[0]!);
      if (parsed.valid && parsed.gtin != null) barcode ??= parsed.gtin;
    }
  }

  // 7. When the label prints the price per kilo or liter and the description states the weight,
  // the two must agree with the chosen price. Agreement raises trust; disagreement only asks for a
  // look, because either number may be the one read wrong.
  var crossChecked = false;
  if (chosen != null && names.isNotEmpty) {
    final w = _weight.firstMatch(normalizeText(names.first.text));
    final per = prices
        .where((p) => p.role == LabelPriceRole.perMeasure)
        .firstOrNull;
    if (w != null && per != null) {
      final q = double.tryParse(w[1]!.replaceAll(',', '.')) ?? 0;
      final u = w[2]!;
      final inBase = switch (u) {
        'g' || 'gr' => per.unit == 'kg' ? q / 1000 : null,
        'kg' => per.unit == 'kg' ? q : null,
        'ml' => per.unit == 'l' ? q / 1000 : null,
        'l' || 'lt' => per.unit == 'l' ? q : null,
        _ => null,
      };
      if (inBase != null && inBase > 0) {
        final expected = per.cents * inBase;
        final diff = (expected - chosen.cents).abs();
        if (diff <= chosen.cents * 0.03 + 1) {
          crossChecked = true;
        } else if (!review.any((r) => r.contains('preço'))) {
          review.add(
            'O preço não confere com o preço por ${per.unit == 'kg' ? 'quilo' : 'litro'} impresso; confira na foto.',
          );
        }
      }
    }
  }

  final ordered = [?chosen, ...prices.where((p) => !identical(p, chosen))];
  return LabelAnalysis(
    names: names,
    prices: ordered,
    price: chosen,
    unit: 'un',
    barcode: barcode,
    reviewReasons: review,
    crossChecked: crossChecked,
  );
}

/// The subtotal of a line that may reach a wholesale price: the lower price only applies once the
/// minimum quantity is in the cart.
Cents priceForQuantity({
  required Cents retailCents,
  Cents? wholesaleCents,
  int? wholesaleMinQuantity,
  required double quantity,
}) {
  if (wholesaleCents != null &&
      wholesaleMinQuantity != null &&
      quantity >= wholesaleMinQuantity) {
    return wholesaleCents;
  }
  return retailCents;
}
