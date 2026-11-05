/// Drift implementation of [LedgerRepository]. Every mutation runs in a transaction, bumps the row
/// version, marks it dirty and appends to the change log (ADR-04).
library;

import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../../domain/ports/change_log.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/ledger_repository.dart';
import '../../domain/ports/preferences_store.dart';
import '../../domain/sync/sync_model.dart';
import 'app_database.dart';
import 'drift_change_log.dart';
import 'mappers.dart';
import 'watch.dart';

class DriftLedgerRepository implements LedgerRepository {
  DriftLedgerRepository(
    this.db, {
    this.clock = const SystemClock(),
    this.deviceId = 'local',
    ChangeLog? changeLog,
  }) : changeLog = changeLog ?? DriftChangeLog(db);
  final AppDatabase db;
  final Clock clock;
  final String deviceId;
  final ChangeLog changeLog;

  // ---------- reads ----------

  @override
  Future<Ledger> loadLedger() => db.transaction(() async {
    final accounts =
        await (db.select(db.accounts)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([
                (t) => OrderingTerm.asc(t.sortOrder),
                (t) => OrderingTerm.asc(t.createdAt),
              ]))
            .get();
    final categories =
        await (db.select(db.categories)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([
                (t) => OrderingTerm.asc(t.sortOrder),
                (t) => OrderingTerm.asc(t.createdAt),
              ]))
            .get();
    final tags =
        await (db.select(db.tags)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final cards =
        await (db.select(db.creditCards)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final txRows =
        await (db.select(db.transactions)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([
                (t) => OrderingTerm.asc(t.date),
                (t) => OrderingTerm.asc(t.createdAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    final budgets =
        await (db.select(db.budgets)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final goals =
        await (db.select(db.goals)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final loans =
        await (db.select(db.loans)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final prefsRow = await (db.select(
      db.kv,
    )..where((t) => t.key.equals(PrefKeys.prefs))).getSingleOrNull();
    final txs = await _hydrate(txRows);
    return Ledger(
      accounts: accounts.map(accountFromRow).toList(),
      categories: categories.map(categoryFromRow).toList(),
      tags: tags.map(tagFromRow).toList(),
      cards: cards.map(cardFromRow).toList(),
      transactions: txs,
      budgets: budgets.map(budgetFromRow).toList(),
      goals: goals.map(goalFromRow).toList(),
      loans: loans.map(loanFromRow).toList(),
      prefs: prefsRow == null
          ? const UserPrefs()
          : UserPrefs.fromJson(
              jsonDecode(prefsRow.json) as Map<String, dynamic>,
            ),
    );
  });

  Future<List<Transaction>> _hydrate(List<TransactionRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();
    final tagRows = <String, List<TransactionTagRow>>{};
    final attRows = <String, List<AttachmentRow>>{};
    // chunk to stay under SQLite's variable limit
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      for (final t
          in await (db.select(db.transactionTags)
                ..where((t) => t.transactionId.isIn(chunk))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get()) {
        (tagRows[t.transactionId] ??= []).add(t);
      }
      final q = db.selectOnly(db.attachments)
        ..addColumns([
          db.attachments.id,
          db.attachments.transactionId,
          db.attachments.fileName,
          db.attachments.mimeType,
          db.attachments.sizeBytes,
          db.attachments.sha256,
          db.attachments.createdAt,
        ])
        ..where(db.attachments.transactionId.isIn(chunk))
        ..orderBy([OrderingTerm.asc(db.attachments.createdAt)]);
      for (final r in await q.get()) {
        final txId = r.read(db.attachments.transactionId)!;
        (attRows[txId] ??= []).add(
          AttachmentRow(
            id: r.read(db.attachments.id)!,
            transactionId: txId,
            fileName: r.read(db.attachments.fileName)!,
            mimeType: r.read(db.attachments.mimeType)!,
            sizeBytes: r.read(db.attachments.sizeBytes)!,
            sha256: r.read(db.attachments.sha256)!,
            data: Uint8List(0),
            createdAt: r.read(db.attachments.createdAt)!,
          ),
        );
      }
    }
    return rows
        .map(
          (r) => transactionFromRow(
            r,
            tags: (tagRows[r.id] ?? const []).map((t) => t.tagId).toList(),
            attachments: (attRows[r.id] ?? const [])
                .map(attachmentFromRow)
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Stream<Ledger> watchLedger() =>
      watchQuery(db, const TableUpdateQuery.any(), loadLedger);

  @override
  Future<Account?> account(String id) async {
    final r = await (db.select(
      db.accounts,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return r == null ? null : accountFromRow(r);
  }

  @override
  Future<Transaction?> transaction(String id) async {
    final r = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return r == null ? null : (await _hydrate([r])).first;
  }

  @override
  Future<List<Transaction>> transactionsBetween(
    String fromISO,
    String toISO, {
    bool includeDeleted = false,
  }) async {
    final q = db.select(db.transactions)
      ..where((t) => t.date.isBetweenValues(fromISO, toISO))
      ..orderBy([
        (t) => OrderingTerm.asc(t.date),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    if (!includeDeleted) q.where((t) => t.deletedAt.isNull());
    return _hydrate(await q.get());
  }

  @override
  Future<List<Transaction>> transactionsForInvoice(
    String cardId,
    String invoiceMonth,
  ) async => _hydrate(
    await (db.select(db.transactions)
          ..where(
            (t) =>
                t.cardId.equals(cardId) &
                t.invoiceMonth.equals(invoiceMonth) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get(),
  );

  @override
  Future<Transaction?> transactionByExternalRef(String externalRef) async {
    final r = await (db.select(
      db.transactions,
    )..where((t) => t.externalRef.equals(externalRef))).getSingleOrNull();
    return r == null ? null : (await _hydrate([r])).first;
  }

  @override
  Future<List<StoredRecurrence>> recurrenceRules() async => (await (db.select(
    db.recurrenceRules,
  )..where((t) => t.deletedAt.isNull())).get()).map(recurrenceFromRow).toList();

  // ---------- writes ----------

  Future<Stamp> _stamp(TableInfo<Table, dynamic> table, String id) async {
    final versionCol = table.columnsByName['version']! as GeneratedColumn<int>;
    final idCol = table.columnsByName['id']! as GeneratedColumn<String>;
    final q = db.selectOnly(table)
      ..addColumns([versionCol])
      ..where(idCol.equals(id));
    final row = await q.getSingleOrNull();
    final current = row?.read(versionCol) ?? 0;
    return Stamp(now: clock.nowISO(), version: current + 1, deviceId: deviceId);
  }

  Future<void> _log(
    String type,
    String id,
    String op,
    Map<String, dynamic>? payload,
    Stamp s,
  ) => changeLog.append(
    ChangeRecord(
      id: '${s.now}-$type-$id-${s.version}',
      entityType: type,
      entityId: id,
      op: op,
      payload: payload,
      version: s.version,
      deviceId: s.deviceId,
      at: s.now,
      synced: false,
    ),
  );

  Future<void> _upsert<R extends Table>(
    TableInfo<R, dynamic> table,
    String type,
    String id,
    Insertable<dynamic> Function(Stamp) row,
    Map<String, dynamic> payload,
  ) => db.transaction(() async {
    final s = await _stamp(table, id);
    await db.into(table).insertOnConflictUpdate(row(s));
    await _log(type, id, 'upsert', payload, s);
  });

  @override
  Future<void> upsertAccount(Account a) => _upsert(
    db.accounts,
    EntityTypes.account,
    a.id,
    (s) => accountToRow(a, s),
    a.toJson(),
  );
  @override
  Future<void> upsertCategory(Category c) => _upsert(
    db.categories,
    EntityTypes.category,
    c.id,
    (s) => categoryToRow(c, s),
    c.toJson(),
  );
  @override
  Future<void> upsertTag(Tag t) => _upsert(
    db.tags,
    EntityTypes.tag,
    t.id,
    (s) => tagToRow(t, s),
    t.toJson(),
  );
  @override
  Future<void> upsertCard(CreditCard c) => _upsert(
    db.creditCards,
    EntityTypes.card,
    c.id,
    (s) => cardToRow(c, s),
    c.toJson(),
  );
  @override
  Future<void> upsertBudget(Budget b) => _upsert(
    db.budgets,
    EntityTypes.budget,
    b.id,
    (s) => budgetToRow(b, s),
    b.toJson(),
  );
  @override
  Future<void> upsertGoal(Goal g) => _upsert(
    db.goals,
    EntityTypes.goal,
    g.id,
    (s) => goalToRow(g, s),
    g.toJson(),
  );
  @override
  Future<void> upsertLoan(Loan l) => _upsert(
    db.loans,
    EntityTypes.loan,
    l.id,
    (s) => loanToRow(l, s),
    l.toJson(),
  );
  @override
  Future<void> upsertRecurrenceRule(StoredRecurrence r) =>
      db.transaction(() async {
        final s = await _stamp(db.recurrenceRules, r.rule.id);
        final existing = await (db.select(
          db.recurrenceRules,
        )..where((t) => t.id.equals(r.rule.id))).getSingleOrNull();
        await db
            .into(db.recurrenceRules)
            .insertOnConflictUpdate(
              recurrenceToRow(r, s, createdAt: existing?.createdAt ?? s.now),
            );
        await _log(
          EntityTypes.recurrenceRule,
          r.rule.id,
          'upsert',
          r.toJson(),
          s,
        );
      });

  Future<WriteOutcome> _writeTransaction(Transaction t) async {
    if (t.externalRef != null) {
      final dup =
          await (db.select(db.transactions)..where(
                (x) =>
                    x.externalRef.equals(t.externalRef!) &
                    x.id.equals(t.id).not(),
              ))
              .getSingleOrNull();
      if (dup != null) return WriteOutcome.alreadyApplied;
    }
    final s = await _stamp(db.transactions, t.id);
    final existed = s.version > 1;
    await db
        .into(db.transactions)
        .insertOnConflictUpdate(transactionToRow(t, s));
    await (db.delete(
      db.transactionTags,
    )..where((x) => x.transactionId.equals(t.id))).go();
    for (var i = 0; i < t.tags.length; i++) {
      await db
          .into(db.transactionTags)
          .insert(
            TransactionTagsCompanion(
              transactionId: Value(t.id),
              tagId: Value(t.tags[i]),
              position: Value(i),
            ),
          );
    }
    await _log(EntityTypes.transaction, t.id, 'upsert', t.toJson(), s);
    return existed ? WriteOutcome.updated : WriteOutcome.inserted;
  }

  @override
  Future<WriteOutcome> upsertTransaction(Transaction t) =>
      db.transaction(() => _writeTransaction(t));

  @override
  Future<List<WriteOutcome>> upsertTransactions(List<Transaction> ts) =>
      db.transaction(() async {
        final out = <WriteOutcome>[];
        for (final t in ts) {
          out.add(await _writeTransaction(t));
        }
        return out;
      });

  TableInfo<Table, dynamic> _tableFor(String entityType) =>
      switch (entityType) {
        EntityTypes.account => db.accounts,
        EntityTypes.category => db.categories,
        EntityTypes.tag => db.tags,
        EntityTypes.card => db.creditCards,
        EntityTypes.transaction => db.transactions,
        EntityTypes.budget => db.budgets,
        EntityTypes.goal => db.goals,
        EntityTypes.loan => db.loans,
        EntityTypes.recurrenceRule => db.recurrenceRules,
        _ => throw ArgumentError(
          'Tipo de entidade sem exclusão lógica: $entityType',
        ),
      };

  Future<bool> _setDeleted(
    String entityType,
    String id,
    String? deletedAt,
    String op,
  ) => db.transaction(() async {
    final table = _tableFor(entityType);
    final s = await _stamp(table, id);
    if (s.version == 1) return false;
    final idCol = table.columnsByName['id']! as GeneratedColumn<String>;
    final n = await db.customUpdate(
      'UPDATE ${table.actualTableName} SET deleted_at = ?, updated_at = ?, version = ?, device_id = ?, dirty = 1 WHERE ${idCol.name} = ?',
      variables: [
        Variable(deletedAt),
        Variable(s.now),
        Variable(s.version),
        Variable(s.deviceId),
        Variable(id),
      ],
      updates: {table},
    );
    if (n == 0) return false;
    await _log(entityType, id, op, null, s);
    return true;
  });

  @override
  Future<bool> softDelete(String entityType, String id) async =>
      _setDeleted(entityType, id, clock.nowISO(), 'delete');

  @override
  Future<int> reassignCategoryOnDeleted(Set<String> fromIds, String? toId) {
    if (fromIds.isEmpty) return Future.value(0);
    final marks = List.filled(fromIds.length, '?').join(', ');
    return db.customUpdate(
      'UPDATE transactions SET category_id = ?, updated_at = ?, dirty = 1 '
      'WHERE deleted_at IS NOT NULL AND category_id IN ($marks)',
      variables: [
        Variable(toId),
        Variable(clock.nowISO()),
        for (final id in fromIds) Variable(id),
      ],
      updates: {db.transactions},
    );
  }

  @override
  Future<bool> restore(String entityType, String id) async =>
      _setDeleted(entityType, id, null, 'restore');

  @override
  Future<void> savePrefs(UserPrefs prefs) => db.transaction(() async {
    final now = clock.nowISO();
    await db
        .into(db.kv)
        .insertOnConflictUpdate(
          KvCompanion(
            key: const Value(PrefKeys.prefs),
            json: Value(jsonEncode(prefs.toJson())),
            updatedAt: Value(now),
          ),
        );
    await _log(
      EntityTypes.prefs,
      PrefKeys.prefs,
      'upsert',
      prefs.toJson(),
      Stamp(now: now, version: 1, deviceId: deviceId),
    );
  });

  // ---------- attachments ----------

  @override
  Future<void> putAttachment(
    String transactionId,
    Attachment meta,
    List<int> bytes,
  ) => db.transaction(() async {
    final digest = crypto.sha256.convert(bytes).toString();
    if (digest != meta.sha256) {
      throw ArgumentError('sha256 do anexo não confere');
    }
    if (bytes.length != meta.sizeBytes) {
      throw ArgumentError('tamanho do anexo não confere');
    }
    await db
        .into(db.attachments)
        .insertOnConflictUpdate(
          AttachmentsCompanion(
            id: Value(meta.id),
            transactionId: Value(transactionId),
            fileName: Value(meta.fileName),
            mimeType: Value(meta.mimeType),
            sizeBytes: Value(meta.sizeBytes),
            sha256: Value(meta.sha256),
            data: Value(Uint8List.fromList(bytes)),
            createdAt: Value(clock.nowISO()),
          ),
        );
    // touch the owning transaction so sync sees the change
    final s = await _stamp(db.transactions, transactionId);
    await (db.update(
      db.transactions,
    )..where((t) => t.id.equals(transactionId))).write(
      TransactionsCompanion(
        updatedAt: Value(s.now),
        version: Value(s.version),
        dirty: const Value(true),
      ),
    );
    await _log(EntityTypes.transaction, transactionId, 'upsert', {
      'attachment': meta.toJson(),
    }, s);
  });

  @override
  Future<List<int>?> attachmentBytes(String attachmentId) async {
    final r = await (db.select(
      db.attachments,
    )..where((t) => t.id.equals(attachmentId))).getSingleOrNull();
    if (r == null) return null;
    if (crypto.sha256.convert(r.data).toString() != r.sha256) {
      throw StateError('anexo corrompido: sha256 divergente');
    }
    return r.data;
  }

  @override
  Future<void> removeAttachment(String attachmentId) =>
      (db.delete(db.attachments)..where((t) => t.id.equals(attachmentId))).go();

  // ---------- bulk ----------

  @override
  Future<void> replaceAll(
    Ledger ledger, {
    List<StoredRecurrence> recurrenceRules = const [],
  }) => db.transaction(() async {
    await _purgeLedgerTables();
    final now = clock.nowISO();
    Stamp s() => Stamp(now: now, version: 1, deviceId: deviceId);
    await db.batch((b) {
      b.insertAll(
        db.accounts,
        ledger.accounts.map((a) => accountToRow(a, s())),
      );
      b.insertAll(
        db.categories,
        ledger.categories.map((c) => categoryToRow(c, s())),
      );
      b.insertAll(db.tags, ledger.tags.map((t) => tagToRow(t, s())));
      b.insertAll(db.creditCards, ledger.cards.map((c) => cardToRow(c, s())));
      b.insertAll(db.goals, ledger.goals.map((g) => goalToRow(g, s())));
      b.insertAll(db.loans, ledger.loans.map((l) => loanToRow(l, s())));
      b.insertAll(db.budgets, ledger.budgets.map((x) => budgetToRow(x, s())));
    });
    // transactions may reference each other (refundOfId) → insert in a stable order with FK deferred by sorting parents first
    final txs = [...ledger.transactions]
      ..sort(
        (a, b) =>
            (a.refundOfId == null ? 0 : 1) - (b.refundOfId == null ? 0 : 1),
      );
    await db.batch((b) {
      b.insertAll(db.transactions, txs.map((t) => transactionToRow(t, s())));
      for (final t in txs) {
        for (var i = 0; i < t.tags.length; i++) {
          b.insert(
            db.transactionTags,
            TransactionTagsCompanion(
              transactionId: Value(t.id),
              tagId: Value(t.tags[i]),
              position: Value(i),
            ),
          );
        }
      }
      b.insertAll(
        db.recurrenceRules,
        recurrenceRules.map((r) => recurrenceToRow(r, s(), createdAt: now)),
      );
    });
    await db
        .into(db.kv)
        .insertOnConflictUpdate(
          KvCompanion(
            key: const Value(PrefKeys.prefs),
            json: Value(jsonEncode(ledger.prefs.toJson())),
            updatedAt: Value(now),
          ),
        );
    await _log('ledger', 'all', 'upsert', {
      'restored': true,
      'transactions': ledger.transactions.length,
    }, Stamp(now: now, version: 1, deviceId: deviceId));
  });

  Future<void> _purgeLedgerTables() async {
    for (final t in <TableInfo<Table, dynamic>>[
      db.attachments,
      db.transactionTags,
      db.recurrenceRules,
      db.transactions,
      db.budgets,
      db.loans,
      db.goals,
      db.creditCards,
      db.tags,
      db.categories,
      db.accounts,
    ]) {
      await db.delete<Table, dynamic>(t).go();
    }
  }

  @override
  Future<void> purgeAll() => db.transaction(() async {
    await _purgeLedgerTables();
    await db.delete(db.kv).go();
    await db.delete(db.changeLogEntries).go();
    await db.delete(db.conflicts).go();
    await db.delete(db.importReports).go();
  });
}
