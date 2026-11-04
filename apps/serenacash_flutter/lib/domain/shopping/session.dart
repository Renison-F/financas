/// In-store shopping session: cart lines, events, planned-vs-actual and the finish step that emits price
/// observations and a *suggested* expense (never created automatically). Mirrors `session.ts`.
library;

import '../money/money.dart';
import 'cart.dart';
import 'lists.dart';
import 'products.dart';
import 'units.dart';

class SessionEvent {
  const SessionEvent({
    required this.at,
    required this.type,
    this.lineId,
    this.detail,
  });
  final String at;
  final String
  type; // start | add | update | remove | scan | finish | abandon | register
  final String? lineId;
  final String? detail;
  factory SessionEvent.fromJson(Map<String, dynamic> j) => SessionEvent(
    at: j['at'] as String,
    type: j['type'] as String,
    lineId: j['lineId'] as String?,
    detail: j['detail'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'at': at,
    'type': type,
    if (lineId != null) 'lineId': lineId,
    if (detail != null) 'detail': detail,
  };
}

class ShoppingSession {
  const ShoppingSession({
    required this.id,
    this.store,
    this.listId,
    this.budgetCents,
    required this.lines,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.transactionId,
    this.receiptAccessKey,
    required this.events,
  });
  final String id;
  final String? store;
  final String? listId;
  final Cents? budgetCents;
  final List<CartLine> lines;
  final String status; // active | finished | abandoned
  final String startedAt;
  final String? finishedAt;
  final String? transactionId;
  final String? receiptAccessKey;
  final List<SessionEvent> events;
  factory ShoppingSession.fromJson(Map<String, dynamic> j) => ShoppingSession(
    id: j['id'] as String,
    store: j['store'] as String?,
    listId: j['listId'] as String?,
    budgetCents: (j['budgetCents'] as num?)?.toInt(),
    lines: (j['lines'] as List<dynamic>? ?? const [])
        .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
        .toList(),
    status: j['status'] as String,
    startedAt: j['startedAt'] as String,
    finishedAt: j['finishedAt'] as String?,
    transactionId: j['transactionId'] as String?,
    receiptAccessKey: j['receiptAccessKey'] as String?,
    events: (j['events'] as List<dynamic>? ?? const [])
        .map((e) => SessionEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    if (store != null) 'store': store,
    if (listId != null) 'listId': listId,
    if (budgetCents != null) 'budgetCents': budgetCents,
    'lines': lines.map((l) => l.toJson()).toList(),
    'status': status,
    'startedAt': startedAt,
    if (finishedAt != null) 'finishedAt': finishedAt,
    if (transactionId != null) 'transactionId': transactionId,
    if (receiptAccessKey != null) 'receiptAccessKey': receiptAccessKey,
    'events': events.map((e) => e.toJson()).toList(),
  };
  ShoppingSession copyWith({
    List<CartLine>? lines,
    String? status,
    String? finishedAt,
    String? transactionId,
    String? receiptAccessKey,
    List<SessionEvent>? events,
  }) => ShoppingSession(
    id: id,
    store: store,
    listId: listId,
    budgetCents: budgetCents,
    lines: lines ?? this.lines,
    status: status ?? this.status,
    startedAt: startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    transactionId: transactionId ?? this.transactionId,
    receiptAccessKey: receiptAccessKey ?? this.receiptAccessKey,
    events: events ?? this.events,
  );
}

ShoppingSession startSession(
  String id,
  String now, {
  String? store,
  ShoppingList? list,
  Cents? budgetCents,
}) => ShoppingSession(
  id: id,
  store: store ?? list?.store,
  listId: list?.id,
  budgetCents: budgetCents ?? list?.budgetCents,
  lines: const [],
  status: 'active',
  startedAt: now,
  events: [SessionEvent(at: now, type: 'start')],
);

CartTotals sessionTotals(ShoppingSession s) =>
    cartTotals(s.lines, s.budgetCents);

ShoppingSession addToSession(ShoppingSession s, CartLine line, String now) =>
    s.copyWith(
      lines: [...s.lines, line],
      events: [
        ...s.events,
        SessionEvent(at: now, type: 'add', lineId: line.id, detail: line.name),
      ],
    );

ShoppingSession updateSessionLine(
  ShoppingSession s,
  String lineId,
  CartLine Function(CartLine) patch,
  String now,
) => s.copyWith(
  lines: s.lines.map((l) => l.id == lineId ? patch(l) : l).toList(),
  events: [
    ...s.events,
    SessionEvent(at: now, type: 'update', lineId: lineId),
  ],
);

ShoppingSession removeFromSession(
  ShoppingSession s,
  String lineId,
  String now,
) => s.copyWith(
  lines: s.lines.where((l) => l.id != lineId).toList(),
  events: [
    ...s.events,
    SessionEvent(at: now, type: 'remove', lineId: lineId),
  ],
);

/// Builds a cart line from a list item. No price is invented: unknown estimates return null → the user confirms.
CartLine? lineFromListItem(ListItem item, String lineId) {
  final price = item.estimatedUnitPriceCents;
  if (price == null) return null;
  return CartLine(
    id: lineId,
    name: item.name,
    brand: item.brand,
    unit: item.unit,
    quantity: item.quantity,
    unitPriceCents: price,
    priceSource: 'list_estimate',
    listItemId: item.id,
    productId: item.productId,
    barcode: item.barcode,
    checked: true,
  );
}

class PerItemComparison {
  const PerItemComparison({
    required this.item,
    this.line,
    this.plannedCents,
    this.actualCents,
  });
  final ListItem item;
  final CartLine? line;
  final Cents? plannedCents;
  final Cents? actualCents;
}

class PlannedVsActual {
  const PlannedVsActual({
    required this.plannedKnownCents,
    required this.actualCents,
    required this.differenceCents,
    required this.bought,
    required this.notBought,
    required this.extra,
    required this.perItem,
  });
  final Cents plannedKnownCents;
  final Cents actualCents;
  final Cents differenceCents;
  final int bought;
  final List<ListItem> notBought;
  final List<CartLine> extra;
  final List<PerItemComparison> perItem;
}

int _jsRound(double v) => (v + 0.5).floorToDouble().toInt();

PlannedVsActual plannedVsActual(ShoppingSession s, ShoppingList list) {
  final perItem = list.items.map((item) {
    final line =
        s.lines.where((l) => l.listItemId == item.id).firstOrNull ??
        s.lines
            .where((l) => l.productId != null && l.productId == item.productId)
            .firstOrNull ??
        s.lines
            .where((l) => l.barcode != null && l.barcode == item.barcode)
            .firstOrNull;
    final planned = item.estimatedUnitPriceCents == null
        ? null
        : _jsRound(item.estimatedUnitPriceCents! * item.quantity);
    final actual = line == null ? null : cartTotals([line]).totalCents;
    return PerItemComparison(
      item: item,
      line: line,
      plannedCents: planned,
      actualCents: actual,
    );
  }).toList();
  final matched = perItem.map((p) => p.line?.id).whereType<String>().toSet();
  final plannedKnown = perItem.fold<int>(
    0,
    (a, p) => a + (p.plannedCents ?? 0),
  );
  final actual = cartTotals(s.lines).totalCents;
  return PlannedVsActual(
    plannedKnownCents: plannedKnown,
    actualCents: actual,
    differenceCents: actual - plannedKnown,
    bought: perItem.where((p) => p.line != null).length,
    notBought: perItem.where((p) => p.line == null).map((p) => p.item).toList(),
    extra: s.lines.where((l) => !matched.contains(l.id)).toList(),
    perItem: perItem,
  );
}

class SuggestedTransaction {
  const SuggestedTransaction({
    required this.amountCents,
    required this.description,
    this.merchant,
    required this.externalRef,
  });
  final Cents amountCents;
  final String description;
  final String? merchant;
  final String externalRef;
  Map<String, dynamic> toJson() => {
    'amountCents': amountCents,
    'description': description,
    if (merchant != null) 'merchant': merchant,
    'externalRef': externalRef,
  };
}

class FinishResult {
  const FinishResult({
    required this.session,
    required this.observations,
    this.suggestedTransaction,
  });
  final ShoppingSession session;
  final List<PriceObservation> observations;
  final SuggestedTransaction? suggestedTransaction;
}

/// Finishes the session, emits price observations for history and a suggested (not created) expense.
FinishResult finishSession(
  ShoppingSession s,
  String now,
  String Function() obsId,
) {
  final totals = sessionTotals(s);
  final finished = s.copyWith(
    status: 'finished',
    finishedAt: now,
    lines: s.lines.map((l) => l.copyWith(checked: true)).toList(),
    events: [
      ...s.events,
      SessionEvent(at: now, type: 'finish'),
    ],
  );
  final observations = s.lines
      .where((l) => l.productId != null && l.priceSource != 'list_estimate')
      .map(
        (l) => PriceObservation(
          id: obsId(),
          productId: l.productId!,
          store: s.store,
          unit: l.unit,
          unitPriceCents: l.unitPriceCents,
          observedAt: now,
          source: l.priceSource == 'label_ocr' ? 'label_ocr' : 'manual',
          sessionId: s.id,
          promo:
              l.promo != null ||
              (l.discountCents ?? 0) != 0 ||
              (l.discountPercent ?? 0) != 0,
        ),
      )
      .toList();
  final suggested = totals.totalCents > 0 && s.transactionId == null
      ? SuggestedTransaction(
          amountCents: totals.totalCents,
          description: s.store != null
              ? 'Compras em ${s.store}'
              : 'Compras de supermercado',
          merchant: s.store,
          externalRef: 'shopping:${s.id}',
        )
      : null;
  return FinishResult(
    session: finished,
    observations: observations,
    suggestedTransaction: suggested,
  );
}

ShoppingSession markRegistered(
  ShoppingSession s,
  String transactionId,
  String now,
) => s.copyWith(
  transactionId: transactionId,
  events: [
    ...s.events,
    SessionEvent(at: now, type: 'register', detail: transactionId),
  ],
);

class SessionSummary {
  const SessionSummary({
    required this.totalCents,
    required this.lines,
    required this.items,
    this.store,
    this.finishedAt,
  });
  final Cents totalCents;
  final int lines;
  final double items;
  final String? store;
  final String? finishedAt;
}

SessionSummary sessionSummary(ShoppingSession s) {
  final t = sessionTotals(s);
  return SessionSummary(
    totalCents: t.totalCents,
    lines: t.lineCount,
    items: s.lines.fold<double>(
      0,
      (a, l) => a + (units[l.unit]!.measured ? 1 : l.quantity),
    ),
    store: s.store,
    finishedAt: s.finishedAt,
  );
}
