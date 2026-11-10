/// Shelf evidence, the store receipt and the comparison between the two.
///
/// A purchase can be finished with what the shelf labels said. Later the user photographs the
/// receipt; its lines are read, paired with the cart and compared: the price announced on the shelf
/// against the price actually charged. Pairing is a judgement on abbreviated text, so every pair
/// carries how sure it is, and a difference is only stated when the pair is solid. Nothing here
/// rewrites the cart: the charged price is recorded next to the announced one.
library;

import '../money/money.dart';
import '../text/normalize.dart';
import 'cart.dart';
import 'label.dart';

/// A photo kept as evidence of a purchase. The bytes live in the encrypted database; this is what
/// is known about them.
class Evidence {
  const Evidence({
    required this.id,
    required this.sessionId,
    this.lineId,
    required this.role,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    this.width,
    this.height,
    required this.capturedAt,
    this.ocr,
  });
  final String id;
  final String sessionId;

  /// The cart line the photo belongs to; null for a photo of the whole purchase (the receipt).
  final String? lineId;

  /// `label` (shelf price tag) | `product` | `receipt` | `other`.
  final String role;
  final String mimeType;
  final int sizeBytes;

  /// Digest of the bytes as captured: the photo shown later is provably the one taken.
  final String sha256;
  final int? width, height;
  final String capturedAt;

  /// What the engine read on the photo, kept so that the reading can be reviewed later.
  final List<OcrBox>? ocr;

  static const roles = ['label', 'product', 'receipt', 'other'];

  Evidence copyWith({String? lineId}) => Evidence(
    id: id,
    sessionId: sessionId,
    lineId: lineId ?? this.lineId,
    role: role,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
    sha256: sha256,
    width: width,
    height: height,
    capturedAt: capturedAt,
    ocr: ocr,
  );
}

/// One item line of a receipt.
class ReceiptLine {
  const ReceiptLine({
    required this.id,
    required this.position,
    required this.rawText,
    required this.description,
    required this.quantity,
    required this.unit,
    this.unitPriceCents,
    required this.totalCents,
    this.code,
    this.matchedLineId,
    this.matchStatus = ReceiptMatch.unmatched,
    this.matchScore,
  });
  final String id;
  final int position;

  /// The text as read, kept for the user to judge the pairing.
  final String rawText;
  final String description;
  final double quantity;
  final String unit;
  final Cents? unitPriceCents;
  final Cents totalCents;

  /// Product code printed on the line (often the bar code), when one was read.
  final String? code;
  final String? matchedLineId;
  final String matchStatus;
  final double? matchScore;

  /// The price of one unit: the one printed, or the total divided by the quantity.
  Cents get effectiveUnitCents =>
      unitPriceCents ??
      (quantity > 0
          ? divCents(totalCents, quantity, RoundingMode.halfUp)
          : totalCents);

  ReceiptLine copyWith({
    String? matchedLineId,
    String? matchStatus,
    double? matchScore,
    bool clearMatch = false,
  }) => ReceiptLine(
    id: id,
    position: position,
    rawText: rawText,
    description: description,
    quantity: quantity,
    unit: unit,
    unitPriceCents: unitPriceCents,
    totalCents: totalCents,
    code: code,
    matchedLineId: clearMatch ? null : (matchedLineId ?? this.matchedLineId),
    matchStatus: matchStatus ?? this.matchStatus,
    matchScore: clearMatch ? null : (matchScore ?? this.matchScore),
  );
}

/// How a receipt line stands against the cart.
abstract final class ReceiptMatch {
  /// Paired and charged what the shelf announced.
  static const equal = 'equal';

  /// Paired with confidence and charged a different price.
  static const divergent = 'divergent';

  /// Probably the same item and a different price: a person has to look.
  static const suspected = 'suspected';

  /// Paired by the user.
  static const confirmed = 'confirmed';

  /// On the receipt and not paired with anything in the cart.
  static const unmatched = 'unmatched';

  static const all = [equal, divergent, suspected, confirmed, unmatched];
}

class ReceiptReading {
  const ReceiptReading({
    required this.lines,
    this.totalCents,
    this.discountCents,
    required this.warnings,
  });
  final List<ReceiptLine> lines;

  /// The total printed on the receipt, when it was read.
  final Cents? totalCents;
  final Cents? discountCents;
  final List<String> warnings;
}

final _money = RegExp(r'(\d{1,5})\s*[,.]\s*(\d{2})(?!\d)');
final _qtyTimes = RegExp(
  r'(\d+(?:[,.]\d{1,3})?)\s*(un|und|unid|kg|g|pc|pct|cx|lt|l|ml|fd|dz)?\s*[x*]\s*(\d{1,5}[,.]\d{2})',
);
final _notItem = RegExp(
  r'\b(total|subtotal|sub-total|troco|dinheiro|cartao|credito|debito|pix|desconto|acrescimo|'
  r'cpf|cnpj|tribut|valor pago|forma de pag|qtd\.? total|itens|consumidor|nfc-?e|sat|chave|'
  r'protocolo|emissao|serie|obrigado|volte sempre|caixa|operador)\b',
);
final _leadingSeq = RegExp(r'^\d{1,3}\s+(?=\S)');
final _code = RegExp(r'\b(\d{7,14})\b');

int? _cents(String a, String b) => int.tryParse(a)! * 100 + int.parse(b);

/// Groups OCR boxes into text rows (a receipt row often comes as two boxes: text and amount).
List<String> receiptRows(List<OcrBox> boxes) {
  final sorted = [...boxes]..sort((a, b) => a.centerY.compareTo(b.centerY));
  final rows = <List<OcrBox>>[];
  for (final b in sorted) {
    final last = rows.isEmpty ? null : rows.last;
    if (last != null) {
      final ref = last.first;
      final tol = (ref.height < b.height ? ref.height : b.height) * 0.6;
      if ((b.centerY - ref.centerY).abs() <= tol) {
        last.add(b);
        continue;
      }
    }
    rows.add([b]);
  }
  return [
    for (final r in rows)
      (r..sort((a, b) => a.left.compareTo(b.left)))
          .map((b) => b.text.trim())
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' '),
  ];
}

/// Reads the item lines of a receipt from text rows, top to bottom.
ReceiptReading parseReceipt(List<String> rows, {String Function()? newId}) {
  var seq = 0;
  String id() => newId?.call() ?? 'r${++seq}';
  final lines = <ReceiptLine>[];
  final warnings = <String>[];
  Cents? total, discount;
  String? pendingDescription;
  String? pendingRaw;

  for (final raw in rows) {
    final n = normalizeText(raw).trim();
    if (n.isEmpty) continue;
    final monies = _money.allMatches(n).toList();
    if (_notItem.hasMatch(n)) {
      if (monies.isNotEmpty) {
        final v = _cents(monies.last[1]!, monies.last[2]!);
        if (RegExp(r'\btotal\b').hasMatch(n) &&
            !n.contains('subtotal') &&
            !n.contains('tribut') &&
            !n.contains('qtd')) {
          total = v;
        } else if (n.contains('desconto')) {
          discount = v;
        }
      }
      pendingDescription = null;
      continue;
    }
    final qx = _qtyTimes.firstMatch(n);
    if (monies.isEmpty) {
      // A row of text alone: the description of an item whose figures come on the next row.
      final letters = n.replaceAll(RegExp(r'[^a-z]'), '').length;
      if (letters >= 3) {
        pendingDescription = _cleanDescription(raw);
        pendingRaw = raw;
      }
      continue;
    }
    final lineTotal = _cents(monies.last[1]!, monies.last[2]!)!;
    var quantity = 1.0;
    var unit = 'un';
    Cents? unitPrice;
    if (qx != null) {
      quantity = double.tryParse(qx[1]!.replaceAll(',', '.')) ?? 1;
      unit = _unit(qx[2]);
      final up = _money.firstMatch(qx[3]!);
      if (up != null) unitPrice = _cents(up[1]!, up[2]!);
    }
    // The description is what is left of the row once the figures are taken out.
    var text = raw;
    if (qx != null) {
      text = text.substring(0, _indexIgnoringCase(text, qx[0]!));
    } else {
      final first = _money.firstMatch(normalizeText(text));
      if (first != null) text = text.substring(0, first.start);
    }
    var description = _cleanDescription(text);
    var rawText = raw;
    if (description.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '').length < 3 &&
        pendingDescription != null) {
      description = pendingDescription;
      rawText = '$pendingRaw / $raw';
    }
    pendingDescription = null;
    if (description.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '').length < 3) {
      continue;
    }
    if (unitPrice != null &&
        (mulCents(unitPrice, quantity, RoundingMode.halfUp) - lineTotal).abs() >
            1) {
      warnings.add(
        'Em "$description", quantidade × preço não fecha com o total da linha; confira.',
      );
    }
    lines.add(
      ReceiptLine(
        id: id(),
        position: lines.length,
        rawText: rawText,
        description: description,
        quantity: quantity,
        unit: unit,
        unitPriceCents: unitPrice,
        totalCents: lineTotal,
        code: _code.firstMatch(raw)?.group(1),
      ),
    );
  }
  if (lines.isEmpty) {
    warnings.add(
      'Nenhum item foi lido no cupom; tente outra foto, mais nítida.',
    );
  } else if (total != null) {
    final sum = sumCents(lines.map((l) => l.totalCents)) - (discount ?? 0);
    if ((sum - total).abs() > 1) {
      warnings.add(
        'A soma dos itens lidos (${formatBRL(sum)}) difere do total do cupom (${formatBRL(total)}): alguma linha pode ter ficado de fora.',
      );
    }
  }
  return ReceiptReading(
    lines: lines,
    totalCents: total,
    discountCents: discount,
    warnings: warnings,
  );
}

int _indexIgnoringCase(String text, String normalizedPart) {
  final i = normalizeText(text).indexOf(normalizedPart);
  return i < 0 ? text.length : i;
}

String _unit(String? u) => switch (u) {
  'kg' => 'kg',
  'g' => 'g',
  'l' || 'lt' => 'l',
  'ml' => 'ml',
  _ => 'un',
};

String _cleanDescription(String s) => s
    .replaceFirst(_leadingSeq, '')
    .replaceAll(_code, ' ')
    .replaceAll(RegExp(r'[|*]+'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

List<String> _tokens(String s) =>
    normalizeText(s)
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 2 && !RegExp(r'^\d+$').hasMatch(t))
        .toList();

/// How alike two product descriptions are, 0..1. Receipts abbreviate ("PAP HIG FD MAX"), so a word
/// counts when one is the beginning of the other.
double descriptionSimilarity(String a, String b) {
  final ta = _tokens(a), tb = _tokens(b);
  if (ta.isEmpty || tb.isEmpty) return 0;
  var hits = 0;
  final used = <int>{};
  for (final x in ta) {
    for (var j = 0; j < tb.length; j++) {
      if (used.contains(j)) continue;
      final y = tb[j];
      final short = x.length < y.length ? x : y;
      final long = x.length < y.length ? y : x;
      if (x == y || (short.length >= 3 && long.startsWith(short))) {
        hits++;
        used.add(j);
        break;
      }
    }
  }
  final smaller = ta.length < tb.length ? ta.length : tb.length;
  return hits / smaller;
}

class Reconciliation {
  const Reconciliation({
    required this.lines,
    required this.notOnReceipt,
    required this.announcedCents,
    required this.chargedCents,
  });

  /// Every receipt line with what it was paired with.
  final List<ReceiptLine> lines;

  /// Cart lines that no receipt line was paired with.
  final List<CartLine> notOnReceipt;

  /// Among the paired items: what the shelf announced and what was charged, same quantities.
  final Cents announcedCents, chargedCents;
  Cents get differenceCents => chargedCents - announcedCents;
  Iterable<ReceiptLine> get divergent =>
      lines.where((l) => l.matchStatus == ReceiptMatch.divergent);
  Iterable<ReceiptLine> get suspected =>
      lines.where((l) => l.matchStatus == ReceiptMatch.suspected);
}

/// The price the cart holds for one unit of a line at its quantity: the wholesale price when its
/// minimum is reached, otherwise the retail one.
Cents announcedUnitCents(CartLine l) => priceForQuantity(
  retailCents: l.unitPriceCents,
  wholesaleCents: l.wholesalePriceCents,
  wholesaleMinQuantity: l.wholesaleMinQuantity,
  quantity: l.quantity,
);

/// Pairs receipt lines with cart lines. Pairs the user already confirmed are kept as they are.
Reconciliation reconcile(List<CartLine> cart, List<ReceiptLine> receipt) {
  final out = {for (final r in receipt) r.id: r};
  final takenCart = <String>{
    for (final r in receipt)
      if (r.matchStatus == ReceiptMatch.confirmed && r.matchedLineId != null)
        r.matchedLineId!,
  };
  final free = receipt
      .where((r) => r.matchStatus != ReceiptMatch.confirmed)
      .toList();
  final scored = <({ReceiptLine r, CartLine c, double score})>[];
  for (final r in free) {
    for (final c in cart) {
      if (takenCart.contains(c.id)) continue;
      double score;
      if (r.code != null &&
          c.barcode != null &&
          _sameCode(r.code!, c.barcode!)) {
        score = 1;
      } else {
        score = descriptionSimilarity(r.description, c.name) * 0.85;
        if (r.effectiveUnitCents == announcedUnitCents(c)) score += 0.15;
        if ((r.quantity - c.quantity).abs() < 0.001) score += 0.05;
        if (score > 0.99) score = 0.99;
      }
      if (score >= 0.35) scored.add((r: r, c: c, score: score));
    }
  }
  scored.sort((a, b) => b.score.compareTo(a.score));
  final takenReceipt = <String>{};
  for (final s in scored) {
    if (takenReceipt.contains(s.r.id) || takenCart.contains(s.c.id)) continue;
    takenReceipt.add(s.r.id);
    takenCart.add(s.c.id);
    final same = s.r.effectiveUnitCents == announcedUnitCents(s.c);
    out[s.r.id] = s.r.copyWith(
      matchedLineId: s.c.id,
      matchScore: double.parse(s.score.toStringAsFixed(3)),
      matchStatus: same
          ? ReceiptMatch.equal
          : (s.score >= 0.6 ? ReceiptMatch.divergent : ReceiptMatch.suspected),
    );
  }
  for (final r in free) {
    if (!takenReceipt.contains(r.id)) {
      out[r.id] = r.copyWith(
        clearMatch: true,
        matchStatus: ReceiptMatch.unmatched,
      );
    }
  }
  final byId = {for (final c in cart) c.id: c};
  var announced = 0, charged = 0;
  for (final r in out.values) {
    final c = byId[r.matchedLineId];
    if (c == null) continue;
    announced = addCents(
      announced,
      mulCents(announcedUnitCents(c), r.quantity, RoundingMode.halfUp),
    );
    charged = addCents(charged, r.totalCents);
  }
  return Reconciliation(
    lines: receipt.map((r) => out[r.id]!).toList(),
    notOnReceipt: cart.where((c) => !takenCart.contains(c.id)).toList(),
    announcedCents: announced,
    chargedCents: charged,
  );
}

bool _sameCode(String a, String b) {
  String strip(String s) => s.replaceFirst(RegExp(r'^0+'), '');
  return strip(a) == strip(b);
}
