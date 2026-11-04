/// Port for the financial ledger. The domain (pure functions over [Ledger]) never touches storage;
/// features read a snapshot or watch it, and write through explicit, idempotent operations.
/// A remote-backed implementation can sit behind this same interface (ADR-03).
library;

import '../entities/entities.dart';

/// A recurrence rule bound to the transaction it clones on each occurrence.
class StoredRecurrence {
  const StoredRecurrence({
    required this.rule,
    required this.templateTransactionId,
    this.lastGenerated,
  });
  final RecurrenceRule rule;
  final String templateTransactionId;
  final String? lastGenerated;
  Map<String, dynamic> toJson() => {
    ...rule.toJson(),
    'templateTransactionId': templateTransactionId,
    if (lastGenerated != null) 'lastGenerated': lastGenerated,
  };
  factory StoredRecurrence.fromJson(Map<String, dynamic> j) => StoredRecurrence(
    rule: RecurrenceRule.fromJson(j),
    templateTransactionId: j['templateTransactionId'] as String,
    lastGenerated: j['lastGenerated'] as String?,
  );
}

/// Result of an idempotent write keyed by `externalRef`.
enum WriteOutcome { inserted, updated, alreadyApplied }

abstract interface class LedgerRepository {
  /// Full in-memory snapshot (active records only) for domain calculations.
  Future<Ledger> loadLedger();

  /// Emits a new snapshot after every committed mutation.
  Stream<Ledger> watchLedger();

  Future<Account?> account(String id);
  Future<Transaction?> transaction(String id);
  Future<List<Transaction>> transactionsBetween(
    String fromISO,
    String toISO, {
    bool includeDeleted = false,
  });
  Future<List<Transaction>> transactionsForInvoice(
    String cardId,
    String invoiceMonth,
  );
  Future<Transaction?> transactionByExternalRef(String externalRef);

  Future<void> upsertAccount(Account a);
  Future<void> upsertCategory(Category c);
  Future<void> upsertTag(Tag t);
  Future<void> upsertCard(CreditCard c);
  Future<void> upsertBudget(Budget b);
  Future<void> upsertGoal(Goal g);
  Future<void> upsertLoan(Loan l);
  Future<void> upsertRecurrenceRule(StoredRecurrence r);
  Future<List<StoredRecurrence>> recurrenceRules();

  /// Inserts or updates. When [t.externalRef] is set and a record with the same ref already exists,
  /// the write is a no-op and returns [WriteOutcome.alreadyApplied].
  Future<WriteOutcome> upsertTransaction(Transaction t);

  /// Writes several transactions atomically (installment series, transfers, imports).
  Future<List<WriteOutcome>> upsertTransactions(List<Transaction> ts);

  Future<bool> softDelete(String entityType, String id);

  /// Restores a soft-deleted record if still present.
  Future<bool> restore(String entityType, String id);

  Future<void> savePrefs(UserPrefs prefs);

  /// Attachment bytes live inside the encrypted database; metadata lives on the transaction.
  Future<void> putAttachment(
    String transactionId,
    Attachment meta,
    List<int> bytes,
  );
  Future<List<int>?> attachmentBytes(String attachmentId);
  Future<void> removeAttachment(String attachmentId);

  /// Replaces everything (restore from backup). Runs in one transaction; the old data is only
  /// discarded after the new data is fully written.
  Future<void> replaceAll(
    Ledger ledger, {
    List<StoredRecurrence> recurrenceRules = const [],
  });

  /// Permanently deletes every record (LGPD "apagar meus dados").
  Future<void> purgeAll();
}

/// Entity type names used by the change log, conflicts and sync. Stable wire values.
abstract final class EntityTypes {
  static const account = 'account';
  static const category = 'category';
  static const tag = 'tag';
  static const card = 'card';
  static const transaction = 'transaction';
  static const budget = 'budget';
  static const goal = 'goal';
  static const loan = 'loan';
  static const recurrenceRule = 'recurrence_rule';
  static const prefs = 'prefs';
  static const shoppingList = 'shopping_list';
  static const shoppingSession = 'shopping_session';
  static const product = 'product';
  static const priceObservation = 'price_observation';
  static const all = [
    account,
    category,
    tag,
    card,
    transaction,
    budget,
    goal,
    loan,
    recurrenceRule,
    prefs,
    shoppingList,
    shoppingSession,
    product,
    priceObservation,
  ];
}
