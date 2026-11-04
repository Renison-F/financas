/// Row ↔ entity mapping. Keeps the relational schema and the pure domain entities decoupled.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../../domain/ports/ledger_repository.dart';
import '../../domain/shopping/shopping.dart';
import '../../domain/sync/sync_model.dart';
import 'app_database.dart';

class Stamp {
  const Stamp({
    required this.now,
    required this.version,
    required this.deviceId,
  });
  final String now;
  final int version;
  final String deviceId;
}

Value<T?> _v<T>(T? x) => Value(x);

AccountsCompanion accountToRow(Account a, Stamp s) => AccountsCompanion(
  id: Value(a.id),
  name: Value(a.name),
  type: Value(a.type),
  currency: Value(a.currency),
  openingBalanceCents: Value(a.openingBalanceCents),
  openingDate: Value(a.openingDate),
  color: Value(a.color),
  archived: Value(a.archived),
  includeInAvailability: Value(a.includeInAvailability),
  sortOrder: Value(a.sortOrder),
  createdAt: Value(a.createdAt),
  updatedAt: Value(s.now),
  deletedAt: _v(a.deletedAt),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
Account accountFromRow(AccountRow r) => Account(
  id: r.id,
  name: r.name,
  type: r.type,
  currency: r.currency,
  openingBalanceCents: r.openingBalanceCents,
  openingDate: r.openingDate,
  color: r.color,
  archived: r.archived,
  includeInAvailability: r.includeInAvailability,
  sortOrder: r.sortOrder,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
);

CategoriesCompanion categoryToRow(Category c, Stamp s) => CategoriesCompanion(
  id: Value(c.id),
  name: Value(c.name),
  kind: Value(c.kind),
  icon: Value(c.icon),
  color: Value(c.color),
  parentId: _v(c.parentId),
  archived: Value(c.archived),
  sortOrder: Value(c.sortOrder),
  createdAt: Value(c.createdAt),
  updatedAt: Value(s.now),
  deletedAt: _v(c.deletedAt),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
Category categoryFromRow(CategoryRow r) => Category(
  id: r.id,
  name: r.name,
  kind: r.kind,
  icon: r.icon,
  color: r.color,
  parentId: r.parentId,
  archived: r.archived,
  sortOrder: r.sortOrder,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
);

TagsCompanion tagToRow(Tag t, Stamp s) => TagsCompanion(
  id: Value(t.id),
  name: Value(t.name),
  color: Value(t.color),
  createdAt: Value(t.createdAt),
  updatedAt: Value(s.now),
  deletedAt: _v(t.deletedAt),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
Tag tagFromRow(TagRow r) => Tag(
  id: r.id,
  name: r.name,
  color: r.color,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
);

CreditCardsCompanion cardToRow(CreditCard c, Stamp s) => CreditCardsCompanion(
  id: Value(c.id),
  name: Value(c.name),
  brand: _v(c.brand),
  limitCents: Value(c.limitCents),
  closingDay: Value(c.closingDay),
  dueDay: Value(c.dueDay),
  defaultPaymentAccountId: _v(c.defaultPaymentAccountId),
  color: Value(c.color),
  archived: Value(c.archived),
  currency: Value(c.currency),
  createdAt: Value(c.createdAt),
  updatedAt: Value(s.now),
  deletedAt: _v(c.deletedAt),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
CreditCard cardFromRow(CardRow r) => CreditCard(
  id: r.id,
  name: r.name,
  brand: r.brand,
  limitCents: r.limitCents,
  closingDay: r.closingDay,
  dueDay: r.dueDay,
  defaultPaymentAccountId: r.defaultPaymentAccountId,
  color: r.color,
  archived: r.archived,
  currency: r.currency,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
);

TransactionsCompanion transactionToRow(Transaction t, Stamp s) =>
    TransactionsCompanion(
      id: Value(t.id),
      kind: Value(kindToWire(t.kind)),
      amountCents: Value(t.amountCents),
      currency: Value(t.currency),
      date: Value(t.date),
      description: Value(t.description),
      categoryId: _v(t.categoryId),
      accountId: _v(t.accountId),
      toAccountId: _v(t.toAccountId),
      cardId: _v(t.cardId),
      goalId: _v(t.goalId),
      loanId: _v(t.loanId),
      status: Value(statusToWire(t.status)),
      paidCents: _v(t.paidCents),
      settledDate: _v(t.settledDate),
      dueDate: _v(t.dueDate),
      installmentNumber: _v(t.installment?.number),
      installmentOf: _v(t.installment?.of),
      installmentGroupId: _v(t.installment?.groupId),
      seriesId: _v(t.seriesId),
      transferGroupId: _v(t.transferGroupId),
      invoiceMonth: _v(t.invoiceMonth),
      notes: _v(t.notes),
      merchant: _v(t.merchant),
      externalRef: _v(t.externalRef),
      refundOfId: _v(t.refundOfId),
      createdAt: Value(t.createdAt),
      updatedAt: Value(s.now),
      deletedAt: _v(t.deletedAt),
      version: Value(s.version),
      deviceId: Value(s.deviceId),
      dirty: const Value(true),
    );

Transaction transactionFromRow(
  TransactionRow r, {
  List<String> tags = const [],
  List<Attachment> attachments = const [],
}) => Transaction(
  id: r.id,
  kind: kindFromWire(r.kind),
  amountCents: r.amountCents,
  currency: r.currency,
  date: r.date,
  description: r.description,
  categoryId: r.categoryId,
  accountId: r.accountId,
  toAccountId: r.toAccountId,
  cardId: r.cardId,
  goalId: r.goalId,
  loanId: r.loanId,
  status: statusFromWire(r.status),
  paidCents: r.paidCents,
  settledDate: r.settledDate,
  dueDate: r.dueDate,
  installment: r.installmentNumber == null
      ? null
      : Installment(
          number: r.installmentNumber!,
          of: r.installmentOf ?? r.installmentNumber!,
          groupId: r.installmentGroupId ?? r.id,
        ),
  seriesId: r.seriesId,
  transferGroupId: r.transferGroupId,
  invoiceMonth: r.invoiceMonth,
  tags: tags,
  notes: r.notes,
  attachments: attachments,
  merchant: r.merchant,
  externalRef: r.externalRef,
  refundOfId: r.refundOfId,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
);

Attachment attachmentFromRow(AttachmentRow r) => Attachment(
  id: r.id,
  fileName: r.fileName,
  mimeType: r.mimeType,
  sizeBytes: r.sizeBytes,
  sha256: r.sha256,
);

BudgetsCompanion budgetToRow(Budget b, Stamp s) => BudgetsCompanion(
  id: Value(b.id),
  categoryId: _v(b.categoryId),
  limitCents: Value(b.limitCents),
  month: _v(b.month),
  rollover: Value(b.rollover),
  createdAt: Value(b.createdAt),
  updatedAt: Value(s.now),
  deletedAt: _v(b.deletedAt),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
Budget budgetFromRow(BudgetRow r) => Budget(
  id: r.id,
  categoryId: r.categoryId,
  limitCents: r.limitCents,
  month: r.month,
  rollover: r.rollover,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
);

GoalsCompanion goalToRow(Goal g, Stamp s) => GoalsCompanion(
  id: Value(g.id),
  name: Value(g.name),
  kind: Value(g.kind),
  targetCents: Value(g.targetCents),
  targetDate: _v(g.targetDate),
  accountId: _v(g.accountId),
  reserved: Value(g.reserved),
  color: Value(g.color),
  archived: Value(g.archived),
  createdAt: Value(g.createdAt),
  updatedAt: Value(s.now),
  deletedAt: _v(g.deletedAt),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
Goal goalFromRow(GoalRow r) => Goal(
  id: r.id,
  name: r.name,
  kind: r.kind,
  targetCents: r.targetCents,
  targetDate: r.targetDate,
  accountId: r.accountId,
  reserved: r.reserved,
  color: r.color,
  archived: r.archived,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
);

LoansCompanion loanToRow(Loan l, Stamp s) => LoansCompanion(
  id: Value(l.id),
  name: Value(l.name),
  lender: _v(l.lender),
  principalCents: Value(l.principalCents),
  monthlyRatePercent: Value(l.monthlyRatePercent),
  termMonths: Value(l.termMonths),
  system: Value(l.system),
  firstDueDate: Value(l.firstDueDate),
  monthlyFeeCents: Value(l.monthlyFeeCents),
  upfrontFeesCents: Value(l.upfrontFeesCents),
  accountId: _v(l.accountId),
  archived: Value(l.archived),
  createdAt: Value(l.createdAt),
  updatedAt: Value(s.now),
  deletedAt: _v(l.deletedAt),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
Loan loanFromRow(LoanRow r) => Loan(
  id: r.id,
  name: r.name,
  lender: r.lender,
  principalCents: r.principalCents,
  monthlyRatePercent: r.monthlyRatePercent,
  termMonths: r.termMonths,
  system: r.system,
  firstDueDate: r.firstDueDate,
  monthlyFeeCents: r.monthlyFeeCents,
  upfrontFeesCents: r.upfrontFeesCents,
  accountId: r.accountId,
  archived: r.archived,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
);

RecurrenceRulesCompanion recurrenceToRow(
  StoredRecurrence x,
  Stamp s, {
  required String createdAt,
}) => RecurrenceRulesCompanion(
  id: Value(x.rule.id),
  frequency: Value(x.rule.frequency),
  anchorDay: _v(x.rule.anchorDay),
  startDate: Value(x.rule.startDate),
  endDate: _v(x.rule.endDate),
  count: _v(x.rule.count),
  templateTransactionId: Value(x.templateTransactionId),
  lastGenerated: _v(x.lastGenerated),
  createdAt: Value(createdAt),
  updatedAt: Value(s.now),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
StoredRecurrence recurrenceFromRow(RecurrenceRuleRow r) => StoredRecurrence(
  rule: RecurrenceRule(
    id: r.id,
    frequency: r.frequency,
    anchorDay: r.anchorDay,
    startDate: r.startDate,
    endDate: r.endDate,
    count: r.count,
  ),
  templateTransactionId: r.templateTransactionId,
  lastGenerated: r.lastGenerated,
);

// ---------------- shopping ----------------

ShoppingListsCompanion listToRow(ShoppingList l, Stamp s) =>
    ShoppingListsCompanion(
      id: Value(l.id),
      name: Value(l.name),
      store: _v(l.store),
      budgetCents: _v(l.budgetCents),
      archived: Value(l.archived),
      lastCompletedAt: _v(l.lastCompletedAt),
      shareToken: _v(l.shareToken),
      createdAt: Value(l.createdAt),
      updatedAt: Value(s.now),
      version: Value(s.version),
      deviceId: Value(s.deviceId),
      dirty: const Value(true),
    );
ShoppingListItemsCompanion listItemToRow(String listId, ListItem i) =>
    ShoppingListItemsCompanion(
      id: Value(i.id),
      listId: Value(listId),
      name: Value(i.name),
      brand: _v(i.brand),
      category: _v(i.category),
      unit: Value(i.unit),
      quantity: Value(i.quantity),
      estimatedUnitPriceCents: _v(i.estimatedUnitPriceCents),
      estimateSource: _v(i.estimateSource),
      productId: _v(i.productId),
      barcode: _v(i.barcode),
      checked: Value(i.checked),
      note: _v(i.note),
      sortOrder: Value(i.sortOrder),
    );
ListItem listItemFromRow(ShoppingListItemRow r) => ListItem(
  id: r.id,
  name: r.name,
  brand: r.brand,
  category: r.category,
  unit: r.unit,
  quantity: r.quantity,
  estimatedUnitPriceCents: r.estimatedUnitPriceCents,
  estimateSource: r.estimateSource,
  productId: r.productId,
  barcode: r.barcode,
  checked: r.checked,
  note: r.note,
  sortOrder: r.sortOrder,
);
ShoppingList listFromRow(ShoppingListRow r, List<ShoppingListItemRow> items) =>
    ShoppingList(
      id: r.id,
      name: r.name,
      store: r.store,
      budgetCents: r.budgetCents,
      items: (items..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
          .map(listItemFromRow)
          .toList(),
      archived: r.archived,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      lastCompletedAt: r.lastCompletedAt,
      shareToken: r.shareToken,
    );

ProductsCompanion productToRow(Product p, Stamp s) => ProductsCompanion(
  id: Value(p.id),
  name: Value(p.name),
  brand: _v(p.brand),
  barcode: _v(p.barcode),
  defaultUnit: Value(p.defaultUnit),
  presentationQuantity: _v(p.presentation?.quantity),
  presentationUnit: _v(p.presentation?.unit),
  category: _v(p.category),
  favorite: Value(p.favorite),
  createdAt: Value(p.createdAt),
  updatedAt: Value(s.now),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
Product productFromRow(ProductRow r, List<ProductInternalCodeRow> codes) =>
    Product(
      id: r.id,
      name: r.name,
      brand: r.brand,
      barcode: r.barcode,
      internalCodes: codes.map((c) => InternalCode(c.store, c.code)).toList(),
      defaultUnit: r.defaultUnit,
      presentation: r.presentationQuantity == null || r.presentationUnit == null
          ? null
          : ProductPresentation(r.presentationQuantity!, r.presentationUnit!),
      category: r.category,
      favorite: r.favorite,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

PriceObservationsCompanion observationToRow(PriceObservation o, Stamp s) =>
    PriceObservationsCompanion(
      id: Value(o.id),
      productId: Value(o.productId),
      store: _v(o.store),
      unit: Value(o.unit),
      unitPriceCents: Value(o.unitPriceCents),
      observedAt: Value(o.observedAt),
      source: Value(o.source),
      sessionId: _v(o.sessionId),
      promo: _v(o.promo),
      createdAt: Value(s.now),
      updatedAt: Value(s.now),
      version: Value(s.version),
      deviceId: Value(s.deviceId),
      dirty: const Value(true),
    );
PriceObservation observationFromRow(PriceObservationRow r) => PriceObservation(
  id: r.id,
  productId: r.productId,
  store: r.store,
  unit: r.unit,
  unitPriceCents: r.unitPriceCents,
  observedAt: r.observedAt,
  source: r.source,
  sessionId: r.sessionId,
  promo: r.promo,
);

ShoppingSessionsCompanion sessionToRow(
  ShoppingSession x,
  Stamp s, {
  required String createdAt,
}) => ShoppingSessionsCompanion(
  id: Value(x.id),
  store: _v(x.store),
  listId: _v(x.listId),
  budgetCents: _v(x.budgetCents),
  status: Value(x.status),
  startedAt: Value(x.startedAt),
  finishedAt: _v(x.finishedAt),
  transactionId: _v(x.transactionId),
  receiptAccessKey: _v(x.receiptAccessKey),
  createdAt: Value(createdAt),
  updatedAt: Value(s.now),
  version: Value(s.version),
  deviceId: Value(s.deviceId),
  dirty: const Value(true),
);
ShoppingSessionLinesCompanion lineToRow(
  String sessionId,
  int position,
  CartLine l,
) => ShoppingSessionLinesCompanion(
  id: Value(l.id),
  sessionId: Value(sessionId),
  position: Value(position),
  productId: _v(l.productId),
  name: Value(l.name),
  brand: _v(l.brand),
  barcode: _v(l.barcode),
  unit: Value(l.unit),
  quantity: Value(l.quantity),
  unitPriceCents: Value(l.unitPriceCents),
  discountCents: _v(l.discountCents),
  discountPercent: _v(l.discountPercent),
  promoTake: _v(l.promo?.take),
  promoPay: _v(l.promo?.pay),
  priceSource: Value(l.priceSource),
  confidence: _v(l.confidence),
  listItemId: _v(l.listItemId),
  checked: Value(l.checked),
  note: _v(l.note),
);
CartLine lineFromRow(ShoppingSessionLineRow r) => CartLine(
  id: r.id,
  productId: r.productId,
  name: r.name,
  brand: r.brand,
  barcode: r.barcode,
  unit: r.unit,
  quantity: r.quantity,
  unitPriceCents: r.unitPriceCents,
  discountCents: r.discountCents,
  discountPercent: r.discountPercent,
  promo: r.promoTake == null || r.promoPay == null
      ? null
      : Promo(r.promoTake!, r.promoPay!),
  priceSource: r.priceSource,
  confidence: r.confidence,
  listItemId: r.listItemId,
  checked: r.checked,
  note: r.note,
);
ShoppingSessionEventsCompanion eventToRow(String sessionId, SessionEvent e) =>
    ShoppingSessionEventsCompanion(
      sessionId: Value(sessionId),
      at: Value(e.at),
      type: Value(e.type),
      lineId: _v(e.lineId),
      detail: _v(e.detail),
    );
ShoppingSession sessionFromRow(
  ShoppingSessionRow r,
  List<ShoppingSessionLineRow> lines,
  List<ShoppingSessionEventRow> events,
) => ShoppingSession(
  id: r.id,
  store: r.store,
  listId: r.listId,
  budgetCents: r.budgetCents,
  lines: (lines..sort((a, b) => a.position.compareTo(b.position)))
      .map(lineFromRow)
      .toList(),
  status: r.status,
  startedAt: r.startedAt,
  finishedAt: r.finishedAt,
  transactionId: r.transactionId,
  receiptAccessKey: r.receiptAccessKey,
  events: (events..sort((a, b) => a.seq.compareTo(b.seq)))
      .map(
        (e) => SessionEvent(
          at: e.at,
          type: e.type,
          lineId: e.lineId,
          detail: e.detail,
        ),
      )
      .toList(),
);

// ---------------- infrastructure ----------------

ChangeLogEntriesCompanion changeToRow(ChangeRecord c) =>
    ChangeLogEntriesCompanion(
      id: Value(c.id),
      entityType: Value(c.entityType),
      entityId: Value(c.entityId),
      op: Value(c.op),
      payload: _v(c.payload == null ? null : jsonEncode(c.payload)),
      version: Value(c.version),
      deviceId: Value(c.deviceId),
      at: Value(c.at),
      synced: Value(c.synced),
    );
ChangeRecord changeFromRow(ChangeLogRow r) => ChangeRecord(
  id: r.id,
  entityType: r.entityType,
  entityId: r.entityId,
  op: r.op,
  payload: r.payload == null
      ? null
      : jsonDecode(r.payload!) as Map<String, dynamic>,
  version: r.version,
  deviceId: r.deviceId,
  at: r.at,
  synced: r.synced,
);
