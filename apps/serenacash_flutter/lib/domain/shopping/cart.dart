/// Cart math. Weighed items round half-up like a store scale (R$ 6,99/kg × 1,5 kg = R$ 10,49). Mirrors `cart.ts`.
library;

import '../money/money.dart';
import 'units.dart';

class Promo {
  const Promo(this.take, this.pay);
  final int take;
  final int pay;
  Map<String, dynamic> toJson() => {'take': take, 'pay': pay};
  factory Promo.fromJson(Map<String, dynamic> j) =>
      Promo((j['take'] as num).toInt(), (j['pay'] as num).toInt());
}

class CartLine {
  const CartLine({
    required this.id,
    this.productId,
    required this.name,
    this.brand,
    this.barcode,
    required this.unit,
    required this.quantity,
    required this.unitPriceCents,
    this.discountCents,
    this.discountPercent,
    this.promo,
    required this.priceSource,
    this.confidence,
    this.listItemId,
    required this.checked,
    this.note,
  });
  final String id;
  final String? productId;
  final String name;
  final String? brand;
  final String? barcode;
  final String unit;
  final double quantity;
  final Cents unitPriceCents;
  final Cents? discountCents;
  final double? discountPercent;
  final Promo? promo;
  final String
  priceSource; // label_ocr | manual | history | barcode_catalog | list_estimate
  final double? confidence;
  final String? listItemId;
  final bool checked;
  final String? note;
  factory CartLine.fromJson(Map<String, dynamic> j) => CartLine(
    id: j['id'] as String,
    productId: j['productId'] as String?,
    name: j['name'] as String,
    brand: j['brand'] as String?,
    barcode: j['barcode'] as String?,
    unit: j['unit'] as String,
    quantity: (j['quantity'] as num).toDouble(),
    unitPriceCents: (j['unitPriceCents'] as num).toInt(),
    discountCents: (j['discountCents'] as num?)?.toInt(),
    discountPercent: (j['discountPercent'] as num?)?.toDouble(),
    promo: j['promo'] == null
        ? null
        : Promo.fromJson(j['promo'] as Map<String, dynamic>),
    priceSource: j['priceSource'] as String,
    confidence: (j['confidence'] as num?)?.toDouble(),
    listItemId: j['listItemId'] as String?,
    checked: j['checked'] as bool? ?? false,
    note: j['note'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    if (productId != null) 'productId': productId,
    'name': name,
    if (brand != null) 'brand': brand,
    if (barcode != null) 'barcode': barcode,
    'unit': unit,
    'quantity': quantity,
    'unitPriceCents': unitPriceCents,
    if (discountCents != null) 'discountCents': discountCents,
    if (discountPercent != null) 'discountPercent': discountPercent,
    if (promo != null) 'promo': promo!.toJson(),
    'priceSource': priceSource,
    if (confidence != null) 'confidence': confidence,
    if (listItemId != null) 'listItemId': listItemId,
    'checked': checked,
    if (note != null) 'note': note,
  };
  CartLine copyWith({
    String? name,
    String? unit,
    double? quantity,
    Cents? unitPriceCents,
    Cents? discountCents,
    double? discountPercent,
    Promo? promo,
    String? priceSource,
    double? confidence,
    bool? checked,
    String? productId,
    String? barcode,
    String? brand,
    bool clearPromo = false,
    bool clearDiscount = false,
  }) => CartLine(
    id: id,
    productId: productId ?? this.productId,
    name: name ?? this.name,
    brand: brand ?? this.brand,
    barcode: barcode ?? this.barcode,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    discountCents: clearDiscount ? null : (discountCents ?? this.discountCents),
    discountPercent: clearDiscount
        ? null
        : (discountPercent ?? this.discountPercent),
    promo: clearPromo ? null : (promo ?? this.promo),
    priceSource: priceSource ?? this.priceSource,
    confidence: confidence ?? this.confidence,
    listItemId: listItemId,
    checked: checked ?? this.checked,
    note: note,
  );
}

class LineTotal {
  const LineTotal({
    required this.grossCents,
    required this.discountCents,
    required this.netCents,
    this.pricePerBaseUnitCents,
    required this.baseUnit,
  });
  final Cents grossCents;
  final Cents discountCents;
  final Cents netCents;
  final Cents? pricePerBaseUnitCents;
  final String baseUnit;
  Map<String, dynamic> toJson() => {
    'grossCents': grossCents,
    'discountCents': discountCents,
    'netCents': netCents,
    if (pricePerBaseUnitCents != null)
      'pricePerBaseUnitCents': pricePerBaseUnitCents,
    'baseUnit': baseUnit,
  };
}

LineTotal lineTotal(CartLine line) {
  final qty = normalizeQuantity(line.quantity, line.unit);
  final def = units[line.unit]!;
  var payable = qty;
  final p = line.promo;
  if (p != null && !def.measured && p.take > 0 && p.pay > 0 && p.pay < p.take) {
    final groups = (qty / p.take).floor();
    payable = qty - groups * (p.take - p.pay);
  }
  final gross = mulCents(line.unitPriceCents, qty, RoundingMode.halfUp);
  final afterPromo = mulCents(
    line.unitPriceCents,
    payable,
    RoundingMode.halfUp,
  );
  var discount = gross - afterPromo;
  if (line.discountCents != null && line.discountCents != 0) {
    discount += [
      afterPromo,
      [0, line.discountCents!].reduce((a, b) => a > b ? a : b),
    ].reduce((a, b) => a < b ? a : b);
  } else if (line.discountPercent != null && line.discountPercent != 0) {
    discount += mulCents(
      afterPromo,
      line.discountPercent!.clamp(0, 100) / 100,
      RoundingMode.halfUp,
    );
  }
  final net = (gross - discount).clamp(0, maxSafeCents);
  final base = toBaseQuantity(1, line.unit);
  return LineTotal(
    grossCents: gross,
    discountCents: discount,
    netCents: net,
    pricePerBaseUnitCents: base.quantity > 0
        ? mulCents(line.unitPriceCents, 1 / base.quantity, RoundingMode.halfUp)
        : null,
    baseUnit: base.base,
  );
}

class CartTotals {
  const CartTotals({
    required this.itemCount,
    required this.lineCount,
    required this.grossCents,
    required this.discountCents,
    required this.totalCents,
    this.budgetCents,
    this.remainingCents,
    required this.overBudget,
    required this.state,
    required this.unconfirmedLines,
  });
  final double itemCount;
  final int lineCount;
  final Cents grossCents;
  final Cents discountCents;
  final Cents totalCents;
  final Cents? budgetCents;
  final Cents? remainingCents;
  final bool overBudget;
  final String state; // sereno | atencao | agitado | sem_orcamento
  final int unconfirmedLines;
  Map<String, dynamic> toJson() => {
    'itemCount': itemCount,
    'lineCount': lineCount,
    'grossCents': grossCents,
    'discountCents': discountCents,
    'totalCents': totalCents,
    if (budgetCents != null) 'budgetCents': budgetCents,
    if (remainingCents != null) 'remainingCents': remainingCents,
    'overBudget': overBudget,
    'state': state,
    'unconfirmedLines': unconfirmedLines,
  };
}

CartTotals cartTotals(
  List<CartLine> lines, [
  Cents? budgetCents,
  double confidenceThreshold = 0.75,
]) {
  final totals = lines.map(lineTotal).toList();
  final gross = sumCents(totals.map((t) => t.grossCents));
  final discount = sumCents(totals.map((t) => t.discountCents));
  final total = sumCents(totals.map((t) => t.netCents));
  final itemCount = lines.fold<double>(
    0,
    (a, l) => a + (units[l.unit]!.measured ? 1 : l.quantity),
  );
  final unconfirmed = lines
      .where(
        (l) =>
            l.priceSource == 'label_ocr' &&
            (l.confidence ?? 0) < confidenceThreshold,
      )
      .length;
  if (budgetCents == null) {
    return CartTotals(
      itemCount: itemCount,
      lineCount: lines.length,
      grossCents: gross,
      discountCents: discount,
      totalCents: total,
      overBudget: false,
      state: 'sem_orcamento',
      unconfirmedLines: unconfirmed,
    );
  }
  final remaining = budgetCents - total;
  final ratio = budgetCents > 0 ? total / budgetCents : 1.0;
  final state = ratio > 1
      ? 'agitado'
      : ratio >= 0.9
      ? 'atencao'
      : 'sereno';
  return CartTotals(
    itemCount: itemCount,
    lineCount: lines.length,
    grossCents: gross,
    discountCents: discount,
    totalCents: total,
    budgetCents: budgetCents,
    remainingCents: remaining,
    overBudget: remaining < 0,
    state: state,
    unconfirmedLines: unconfirmed,
  );
}

List<CartLine> updateLine(
  List<CartLine> lines,
  String id,
  CartLine Function(CartLine) patch,
) => lines.map((l) => l.id == id ? patch(l) : l).toList();
List<CartLine> removeLine(List<CartLine> lines, String id) =>
    lines.where((l) => l.id != id).toList();

/// Merges countable duplicates of the same product/barcode at the same price.
List<CartLine> addLine(List<CartLine> lines, CartLine line) {
  final i = lines.indexWhere(
    (l) =>
        !units[l.unit]!.measured &&
        l.unit == line.unit &&
        l.unitPriceCents == line.unitPriceCents &&
        ((l.barcode != null && l.barcode == line.barcode) ||
            (l.productId != null && l.productId == line.productId)) &&
        l.promo == null &&
        line.promo == null &&
        (l.discountCents ?? 0) == 0 &&
        (line.discountCents ?? 0) == 0,
  );
  if (i >= 0) {
    final next = [...lines];
    next[i] = next[i].copyWith(quantity: next[i].quantity + line.quantity);
    return next;
  }
  return [...lines, line];
}
