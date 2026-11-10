/// Relational schema (Drift). Every business table carries the sync/versioning columns from ADR-04.
/// Money is INTEGER cents; dates are ISO text (`YYYY-MM-DD`); instants are UTC ISO-8601 text.
library;

// Drift expressa CHECK constraints referenciando o próprio getter (padrão documentado da biblioteca).
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

mixin SyncColumns on Table {
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().withDefault(const Constant('local'))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
}

@DataClassName('AccountRow')
@TableIndex(name: 'idx_accounts_deleted', columns: {#deletedAt})
class Accounts extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  TextColumn get type => text().check(
    type.isIn([
      'cash',
      'checking',
      'savings',
      'digital_wallet',
      'investment',
      'other',
    ]),
  )();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  IntColumn get openingBalanceCents => integer()();
  TextColumn get openingDate => text()();
  TextColumn get color => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  BoolColumn get includeInAvailability =>
      boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CategoryRow')
@TableIndex(name: 'idx_categories_parent', columns: {#parentId})
class Categories extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  TextColumn get kind => text().check(kind.isIn(['income', 'expense']))();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  TextColumn get parentId => text().nullable().references(Categories, #id)();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TagRow')
class Tags extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  TextColumn get color => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CardRow')
class CreditCards extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  TextColumn get brand => text().nullable()();
  IntColumn get limitCents =>
      integer().check(limitCents.isBiggerOrEqualValue(0))();
  IntColumn get closingDay =>
      integer().check(closingDay.isBetweenValues(1, 31))();
  IntColumn get dueDay => integer().check(dueDay.isBetweenValues(1, 31))();
  TextColumn get defaultPaymentAccountId =>
      text().nullable().references(Accounts, #id)();
  TextColumn get color => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TransactionRow')
@TableIndex(name: 'idx_tx_date', columns: {#date})
@TableIndex(name: 'idx_tx_kind_date', columns: {#kind, #date})
@TableIndex(name: 'idx_tx_account', columns: {#accountId})
@TableIndex(name: 'idx_tx_card_invoice', columns: {#cardId, #invoiceMonth})
@TableIndex(name: 'idx_tx_category', columns: {#categoryId})
@TableIndex(name: 'idx_tx_series', columns: {#seriesId})
@TableIndex(name: 'idx_tx_deleted', columns: {#deletedAt})
@TableIndex(name: 'idx_tx_due', columns: {#dueDate})
@TableIndex.sql(
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_tx_external_ref ON transactions (external_ref) WHERE external_ref IS NOT NULL',
)
class Transactions extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get kind => text().check(
    kind.isIn([
      'income',
      'expense',
      'transfer',
      'card_purchase',
      'card_payment',
      'goal_deposit',
      'goal_withdrawal',
      'loan_disbursement',
      'loan_payment',
      'balance_adjustment',
      'card_refund',
    ]),
  )();
  IntColumn get amountCents =>
      integer().check(amountCents.isBiggerOrEqualValue(0))();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get date => text().withLength(min: 10, max: 10)();
  TextColumn get description => text()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get accountId => text().nullable().references(Accounts, #id)();
  TextColumn get toAccountId => text().nullable().references(Accounts, #id)();
  TextColumn get cardId => text().nullable().references(CreditCards, #id)();
  TextColumn get goalId => text().nullable().references(Goals, #id)();
  TextColumn get loanId => text().nullable().references(Loans, #id)();
  TextColumn get status => text().check(
    status.isIn(['planned', 'settled', 'partially_paid', 'cancelled']),
  )();
  IntColumn get paidCents => integer().nullable().check(
    paidCents.isNull() | paidCents.isBiggerOrEqualValue(0),
  )();
  TextColumn get settledDate => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  IntColumn get installmentNumber => integer().nullable()();
  IntColumn get installmentOf => integer().nullable()();
  TextColumn get installmentGroupId => text().nullable()();
  TextColumn get seriesId => text().nullable()();
  TextColumn get transferGroupId => text().nullable()();
  TextColumn get invoiceMonth => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get merchant => text().nullable()();
  TextColumn get externalRef => text().nullable()();
  TextColumn get refundOfId =>
      text().nullable().references(Transactions, #id)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TransactionTagRow')
@TableIndex(name: 'idx_tx_tags_tag', columns: {#tagId})
class TransactionTags extends Table {
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {transactionId, tagId};
}

/// Attachment bytes stay inside the encrypted database (never on the plain file system).
@DataClassName('AttachmentRow')
@TableIndex(name: 'idx_attachments_tx', columns: {#transactionId})
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes =>
      integer().check(sizeBytes.isBetweenValues(0, 10 * 1024 * 1024))();
  TextColumn get sha256 => text().withLength(min: 64, max: 64)();
  BlobColumn get data => blob()();
  TextColumn get createdAt => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BudgetRow')
@TableIndex(name: 'idx_budgets_month', columns: {#month})
class Budgets extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  IntColumn get limitCents =>
      integer().check(limitCents.isBiggerOrEqualValue(0))();
  TextColumn get month => text().nullable()();
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();
  // v2: first and (exclusive) last month a recurring budget is in force.
  TextColumn get validFrom => text().nullable()();
  TextColumn get validUntil => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GoalRow')
class Goals extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  TextColumn get kind => text()();
  IntColumn get targetCents =>
      integer().check(targetCents.isBiggerOrEqualValue(0))();
  TextColumn get targetDate => text().nullable()();
  TextColumn get accountId => text().nullable().references(Accounts, #id)();
  BoolColumn get reserved => boolean().withDefault(const Constant(true))();
  TextColumn get color => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LoanRow')
class Loans extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  TextColumn get lender => text().nullable()();
  IntColumn get principalCents =>
      integer().check(principalCents.isBiggerOrEqualValue(0))();
  RealColumn get monthlyRatePercent =>
      real().check(monthlyRatePercent.isBiggerOrEqualValue(0))();
  // v4: 0 for a debt without a schedule.
  IntColumn get termMonths =>
      integer().check(termMonths.isBiggerOrEqualValue(0))();
  TextColumn get system => text().check(
    system.isIn(['price', 'sac', 'american', 'bullet', 'free']),
  )();
  TextColumn get firstDueDate => text()();
  IntColumn get monthlyFeeCents => integer().withDefault(const Constant(0))();
  IntColumn get upfrontFeesCents => integer().withDefault(const Constant(0))();
  TextColumn get accountId => text().nullable().references(Accounts, #id)();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  // v4: who owes whom, interest of a debt without schedule, and how the rate was stated.
  TextColumn get direction => text()
      .withDefault(const Constant('borrowed'))
      .check(direction.isIn(['borrowed', 'lent']))();
  TextColumn get interestMode => text()
      .withDefault(const Constant('none'))
      .check(interestMode.isIn(['none', 'simple', 'compound']))();
  TextColumn get ratePeriod => text()
      .withDefault(const Constant('month'))
      .check(ratePeriod.isIn(['month', 'year']))();
  TextColumn get rateKind => text()
      .withDefault(const Constant('effective'))
      .check(rateKind.isIn(['effective', 'nominal']))();
  RealColumn get rateInputPercent => real().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RecurrenceRuleRow')
class RecurrenceRules extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get frequency => text().check(
    frequency.isIn([
      'daily',
      'weekly',
      'biweekly',
      'monthly',
      'bimonthly',
      'quarterly',
      'semiannual',
      'yearly',
    ]),
  )();
  IntColumn get anchorDay => integer().nullable()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  IntColumn get count => integer().nullable()();

  /// Transaction used as template for each occurrence (same as the RN app's `templateTransactionId`).
  TextColumn get templateTransactionId =>
      text().references(Transactions, #id)();
  TextColumn get lastGenerated => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------- shopping ----------------

@DataClassName('ShoppingListRow')
@TableIndex(name: 'idx_lists_archived', columns: {#archived})
class ShoppingLists extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get store => text().nullable()();
  IntColumn get budgetCents => integer().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get lastCompletedAt => text().nullable()();
  TextColumn get shareToken => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ShoppingListItemRow')
@TableIndex(name: 'idx_list_items_list', columns: {#listId})
class ShoppingListItems extends Table {
  TextColumn get id => text()();
  TextColumn get listId =>
      text().references(ShoppingLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get unit => text()();
  RealColumn get quantity => real().check(quantity.isBiggerOrEqualValue(0))();
  IntColumn get estimatedUnitPriceCents => integer().nullable()();
  TextColumn get estimateSource => text().nullable()();
  TextColumn get productId => text().nullable()();
  TextColumn get barcode => text().nullable()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProductRow')
@TableIndex(name: 'idx_products_barcode', columns: {#barcode})
class Products extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get defaultUnit => text()();
  RealColumn get presentationQuantity => real().nullable()();
  TextColumn get presentationUnit => text().nullable()();
  TextColumn get category => text().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProductInternalCodeRow')
class ProductInternalCodes extends Table {
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get store => text()();
  TextColumn get code => text()();
  @override
  Set<Column<Object>> get primaryKey => {productId, store, code};
}

@DataClassName('PriceObservationRow')
@TableIndex(name: 'idx_obs_product_at', columns: {#productId, #observedAt})
class PriceObservations extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get store => text().nullable()();
  TextColumn get unit => text()();
  IntColumn get unitPriceCents =>
      integer().check(unitPriceCents.isBiggerOrEqualValue(0))();
  TextColumn get observedAt => text()();
  TextColumn get source => text()();
  TextColumn get sessionId => text().nullable()();
  BoolColumn get promo => boolean().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ShoppingSessionRow')
@TableIndex(name: 'idx_sessions_status', columns: {#status})
@TableIndex(name: 'idx_sessions_started', columns: {#startedAt})
class ShoppingSessions extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get store => text().nullable()();
  TextColumn get listId => text().nullable()();
  IntColumn get budgetCents => integer().nullable()();
  TextColumn get status =>
      text().check(status.isIn(['active', 'finished', 'abandoned']))();
  TextColumn get startedAt => text()();
  TextColumn get finishedAt => text().nullable()();
  TextColumn get transactionId => text().nullable()();
  TextColumn get receiptAccessKey => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ShoppingSessionLineRow')
@TableIndex(name: 'idx_session_lines_session', columns: {#sessionId})
class ShoppingSessionLines extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(ShoppingSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get productId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get unit => text()();
  RealColumn get quantity => real().check(quantity.isBiggerOrEqualValue(0))();
  IntColumn get unitPriceCents =>
      integer().check(unitPriceCents.isBiggerOrEqualValue(0))();
  IntColumn get discountCents => integer().nullable()();
  RealColumn get discountPercent => real().nullable()();
  IntColumn get promoTake => integer().nullable()();
  IntColumn get promoPay => integer().nullable()();
  TextColumn get priceSource => text()();
  RealColumn get confidence => real().nullable()();
  TextColumn get listItemId => text().nullable()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  // v3: shelf evidence and receipt comparison.
  IntColumn get advertisedPriceCents => integer().nullable()();
  IntColumn get wholesalePriceCents => integer().nullable()();
  IntColumn get wholesaleMinQuantity => integer().nullable()();
  IntColumn get chargedUnitPriceCents => integer().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Photos kept as evidence of a purchase (shelf label, product, receipt). Like attachments, the
/// bytes stay inside the encrypted database and never on the plain file system.
@DataClassName('ShoppingEvidenceRow')
@TableIndex(name: 'idx_evidence_session', columns: {#sessionId})
class ShoppingEvidence extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(ShoppingSessions, #id, onDelete: KeyAction.cascade)();
  // Not a foreign key: the lines of a session are rewritten as a whole on every save.
  TextColumn get lineId => text().nullable()();
  TextColumn get role =>
      text().check(role.isIn(['label', 'product', 'receipt', 'other']))();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes =>
      integer().check(sizeBytes.isBetweenValues(0, 8 * 1024 * 1024))();
  TextColumn get sha256 => text().withLength(min: 64, max: 64)();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  BlobColumn get data => blob()();
  TextColumn get capturedAt => text()();
  TextColumn get ocrJson => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ShoppingReceiptLineRow')
@TableIndex(name: 'idx_receipt_lines_session', columns: {#sessionId})
class ShoppingReceiptLines extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(ShoppingSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get rawText => text()();
  TextColumn get description => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  IntColumn get unitPriceCents => integer().nullable()();
  IntColumn get totalCents => integer()();
  TextColumn get code => text().nullable()();
  TextColumn get matchedLineId => text().nullable()();
  TextColumn get matchStatus => text().check(
    matchStatus.isIn([
      'equal',
      'divergent',
      'suspected',
      'confirmed',
      'unmatched',
    ]),
  )();
  RealColumn get matchScore => real().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ShoppingSessionEventRow')
@TableIndex(name: 'idx_session_events_session', columns: {#sessionId})
class ShoppingSessionEvents extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get sessionId =>
      text().references(ShoppingSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get at => text()();
  TextColumn get type => text()();
  TextColumn get lineId => text().nullable()();
  TextColumn get detail => text().nullable()();
}

// ---------------- infrastructure ----------------

@DataClassName('KvRow')
class Kv extends Table {
  TextColumn get key => text()();
  TextColumn get json => text()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('ChangeLogRow')
@TableIndex(name: 'idx_change_log_synced', columns: {#synced, #at})
@TableIndex(name: 'idx_change_log_entity', columns: {#entityType, #entityId})
class ChangeLogEntries extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get op => text().check(op.isIn(['upsert', 'delete', 'restore']))();
  TextColumn get payload => text().nullable()();
  IntColumn get version => integer()();
  TextColumn get deviceId => text()();
  TextColumn get at => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ConflictRow')
class Conflicts extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();
  TextColumn get localJson => text()();
  TextColumn get remoteJson => text()();
  TextColumn get detectedAt => text()();
  TextColumn get resolvedAt => text().nullable()();
  TextColumn get chosenSide => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId, field};
}

@DataClassName('ImportReportRow')
class ImportReports extends Table {
  TextColumn get id => text()();
  TextColumn get source => text()();
  TextColumn get at => text()();
  TextColumn get reportJson => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

const allTablesInDependencyOrder = <Type>[
  Accounts,
  Categories,
  Tags,
  CreditCards,
  Goals,
  Loans,
  Transactions,
  TransactionTags,
  Attachments,
  Budgets,
  RecurrenceRules,
  ShoppingLists,
  ShoppingListItems,
  Products,
  ProductInternalCodes,
  PriceObservations,
  ShoppingSessions,
  ShoppingSessionLines,
  ShoppingSessionEvents,
  ShoppingEvidence,
  ShoppingReceiptLines,
  Kv,
  ChangeLogEntries,
  Conflicts,
  ImportReports,
];
