import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/database/drift_change_log.dart';
import 'package:serenacash/data/database/drift_ledger_repository.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ledger/ledger.dart' as ledger_rules;
import 'package:serenacash/domain/ports/ports.dart';

import '../fixtures/fixture_loader.dart';

/// The TS fixture references goal `g` without declaring it (the pure domain never checked references).
/// The relational schema enforces the foreign key, so the test declares the goal.
Ledger fixtureLedger() {
  final l = Ledger.fromJson(
    loadFixtures('ledger').first.inputMap['ledger'] as Map<String, dynamic>,
  );
  if (l.goals.any((g) => g.id == 'g')) return l;
  return Ledger(
    accounts: l.accounts,
    categories: l.categories,
    tags: l.tags,
    cards: l.cards,
    transactions: l.transactions,
    budgets: l.budgets,
    goals: [
      ...l.goals,
      const Goal(
        id: 'g',
        name: 'Reserva',
        kind: 'emergency',
        targetCents: 1000000,
        reserved: true,
        color: '#0B5563',
        archived: false,
        createdAt: '2026-11-04T12:00:00.000Z',
        updatedAt: '2026-11-04T12:00:00.000Z',
      ),
    ],
    loans: l.loans,
    prefs: l.prefs,
  );
}

/// Order-insensitive comparison: the store returns transactions sorted by date, the fixture by insertion;
/// `updatedAt` is stamped by the repository and the prefs gain the two new security flags.
Map<String, dynamic> stripStamps(Map<String, dynamic> j) {
  final out = <String, dynamic>{};
  j.forEach((k, v) {
    if (k == 'updatedAt' || k == 'lockOnBackground' || k == 'pinEnabled') {
      return;
    }
    if (k == 'transactions' && v is List) {
      final sorted = [...v.cast<Map<String, dynamic>>()]
        ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
      out[k] = sorted.map(stripStamps).toList();
      return;
    }
    if (v is Map<String, dynamic>) {
      out[k] = stripStamps(v);
    } else if (v is List) {
      out[k] = v
          .map((e) => e is Map<String, dynamic> ? stripStamps(e) : e)
          .toList();
    } else {
      out[k] = v;
    }
  });
  return out;
}

void main() {
  late AppDatabase db;
  late DriftLedgerRepository repo;
  late FixedClock clock;

  setUp(() {
    db = AppDatabase.inMemory();
    clock = FixedClock('2026-11-04T12:00:00.000Z');
    repo = DriftLedgerRepository(db, clock: clock, deviceId: 'test-device');
  });
  tearDown(() => db.close());

  test(
    'schema v1 creates with indexes, foreign keys and integrity ok',
    () async {
      final idx = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
          )
          .get();
      final names = idx.map((r) => r.data['name'] as String).toSet();
      expect(
        names,
        containsAll([
          'idx_tx_date',
          'idx_tx_card_invoice',
          'idx_tx_external_ref',
          'idx_change_log_synced',
        ]),
      );
      final fk = await db.customSelect('PRAGMA foreign_keys').get();
      expect(fk.first.data.values.first, 1);
      final uv = await db.customSelect('PRAGMA user_version').get();
      expect(uv.first.data.values.first, AppDatabase.currentSchemaVersion);
      expect(await db.integrityCheck(), isEmpty);
    },
  );

  test('replaceAll + loadLedger round-trips the fixture ledger exactly (same domain results)', () async {
    final L = fixtureLedger();
    await repo.replaceAll(L);
    final back = await repo.loadLedger();
    expect(
      jsonEquals(stripStamps(back.toJson()), stripStamps(L.toJson())),
      isTrue,
      reason: jsonEncode(back.toJson()),
    );
    expect(
      ledger_rules.consolidatedBalance(back, asOf: '2026-11-30'),
      ledger_rules.consolidatedBalance(L, asOf: '2026-11-30'),
    );
    final totals = ledger_rules.monthTotals(back, '2026-11');
    expect(totals.toJson(), ledger_rules.monthTotals(L, '2026-11').toJson());
  });

  test('upsert bumps version, marks dirty and logs the change', () async {
    final L = fixtureLedger();
    await repo.replaceAll(L);
    final a = L.accounts.first;
    clock.value = '2026-11-05T09:00:00.000Z';
    await repo.upsertAccount(
      Account(
        id: a.id,
        name: 'Renomeada',
        type: a.type,
        currency: a.currency,
        openingBalanceCents: a.openingBalanceCents,
        openingDate: a.openingDate,
        color: a.color,
        archived: false,
        includeInAvailability: true,
        sortOrder: 0,
        createdAt: a.createdAt,
        updatedAt: a.updatedAt,
      ),
    );
    final row = await (db.select(
      db.accounts,
    )..where((t) => t.id.equals(a.id))).getSingle();
    expect(row.version, 2);
    expect(row.dirty, isTrue);
    expect(row.updatedAt, '2026-11-05T09:00:00.000Z');
    expect(row.deviceId, 'test-device');
    final log = await DriftChangeLog(db).forEntity(EntityTypes.account, a.id);
    expect(log.map((c) => c.op), ['upsert']);
    expect(log.last.payload!['name'], 'Renomeada');
    expect(log.last.version, 2);
  });

  test('externalRef makes writes idempotent', () async {
    await repo.replaceAll(fixtureLedger());
    final t = Transaction(
      id: 'shop-1',
      kind: TransactionKind.expense,
      amountCents: 12345,
      currency: 'BRL',
      date: '2026-11-04',
      description: 'Compras',
      accountId: 'a',
      status: TransactionStatus.settled,
      externalRef: 'shopping:S1',
      createdAt: clock.nowISO(),
      updatedAt: clock.nowISO(),
    );
    expect(await repo.upsertTransaction(t), WriteOutcome.inserted);
    expect(await repo.upsertTransaction(t), WriteOutcome.updated);
    final again = Transaction(
      id: 'shop-2',
      kind: TransactionKind.expense,
      amountCents: 12345,
      currency: 'BRL',
      date: '2026-11-04',
      description: 'Compras repetidas',
      accountId: 'a',
      status: TransactionStatus.settled,
      externalRef: 'shopping:S1',
      createdAt: clock.nowISO(),
      updatedAt: clock.nowISO(),
    );
    expect(await repo.upsertTransaction(again), WriteOutcome.alreadyApplied);
    expect((await repo.transactionByExternalRef('shopping:S1'))!.id, 'shop-1');
    expect(
      (await repo.loadLedger()).transactions
          .where((x) => x.externalRef == 'shopping:S1')
          .length,
      1,
    );
  });

  test('CHECK and FOREIGN KEY constraints reject invalid rows and keep the batch atomic', () async {
    await repo.replaceAll(fixtureLedger());
    final before = (await repo.loadLedger()).transactions.length;
    final ok = Transaction(
      id: 'ok1',
      kind: TransactionKind.expense,
      amountCents: 100,
      currency: 'BRL',
      date: '2026-11-04',
      description: 'ok',
      accountId: 'a',
      status: TransactionStatus.settled,
      createdAt: clock.nowISO(),
      updatedAt: clock.nowISO(),
    );
    final badAccount = Transaction(
      id: 'bad1',
      kind: TransactionKind.expense,
      amountCents: 100,
      currency: 'BRL',
      date: '2026-11-04',
      description: 'conta inexistente',
      accountId: 'nope',
      status: TransactionStatus.settled,
      createdAt: clock.nowISO(),
      updatedAt: clock.nowISO(),
    );
    await expectLater(
      repo.upsertTransactions([ok, badAccount]),
      throwsA(anything),
    );
    expect(
      (await repo.loadLedger()).transactions.length,
      before,
      reason: 'a falha da segunda escrita desfaz a primeira',
    );
    final negative = Transaction(
      id: 'bad2',
      kind: TransactionKind.expense,
      amountCents: -1,
      currency: 'BRL',
      date: '2026-11-04',
      description: 'negativo',
      accountId: 'a',
      status: TransactionStatus.settled,
      createdAt: clock.nowISO(),
      updatedAt: clock.nowISO(),
    );
    await expectLater(repo.upsertTransaction(negative), throwsA(anything));
    await expectLater(
      repo.upsertCard(
        CreditCard(
          id: 'cx',
          name: 'x',
          limitCents: 0,
          closingDay: 32,
          dueDay: 1,
          color: '#000',
          archived: false,
          currency: 'BRL',
          createdAt: clock.nowISO(),
          updatedAt: clock.nowISO(),
        ),
      ),
      throwsA(anything),
    );
    expect(await db.integrityCheck(), isEmpty);
  });

  test('soft delete hides, restore brings back, both logged', () async {
    await repo.replaceAll(fixtureLedger());
    expect(await repo.softDelete(EntityTypes.transaction, 't1'), isTrue);
    expect(await repo.transaction('t1'), isNull);
    expect(
      (await repo.loadLedger()).transactions.any((t) => t.id == 't1'),
      isFalse,
    );
    expect(
      (await repo.transactionsBetween(
        '2026-01-01',
        '2026-12-31',
        includeDeleted: true,
      )).any((t) => t.id == 't1'),
      isTrue,
    );
    expect(await repo.restore(EntityTypes.transaction, 't1'), isTrue);
    expect(await repo.transaction('t1'), isNotNull);
    expect(await repo.softDelete(EntityTypes.transaction, 'missing'), isFalse);
    final ops = (await DriftChangeLog(
      db,
    ).forEntity(EntityTypes.transaction, 't1')).map((c) => c.op).toList();
    expect(ops, ['delete', 'restore']);
  });

  test(
    'tags and attachments round-trip; attachment hash is verified',
    () async {
      await repo.replaceAll(fixtureLedger());
      await repo.upsertTag(
        Tag(
          id: 'tg1',
          name: 'viagem',
          color: '#123',
          createdAt: clock.nowISO(),
          updatedAt: clock.nowISO(),
        ),
      );
      final t = (await repo.transaction('t2'))!.copyWith(tags: ['tg1']);
      await repo.upsertTransaction(t);
      final bytes = utf8.encode('recibo-fake');
      final meta = Attachment(
        id: 'att1',
        fileName: 'recibo.txt',
        mimeType: 'text/plain',
        sizeBytes: bytes.length,
        sha256: crypto.sha256.convert(bytes).toString(),
      );
      await repo.putAttachment('t2', meta, bytes);
      final back = (await repo.transaction('t2'))!;
      expect(back.tags, ['tg1']);
      expect(back.attachments.map((a) => a.id), ['att1']);
      expect(await repo.attachmentBytes('att1'), bytes);
      await expectLater(
        repo.putAttachment(
          't2',
          Attachment(
            id: 'att2',
            fileName: 'x',
            mimeType: 'text/plain',
            sizeBytes: 3,
            sha256: 'a' * 64,
          ),
          [1, 2, 3],
        ),
        throwsArgumentError,
      );
      await repo.softDelete(EntityTypes.transaction, 't2');
      expect(
        await repo.attachmentBytes('att1'),
        isNotNull,
        reason: 'exclusão lógica preserva o anexo',
      );
    },
  );

  test('watchLedger emits after each committed change', () async {
    await repo.replaceAll(fixtureLedger());
    final events = <int>[];
    final sub = repo.watchLedger().listen(
      (l) => events.add(l.transactions.length),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await repo.softDelete(EntityTypes.transaction, 't1');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(events.first, 11);
    expect(events.last, 10);
  });

  test('purgeAll leaves no rows anywhere', () async {
    await repo.replaceAll(fixtureLedger());
    await repo.savePrefs(const UserPrefs(theme: 'dark'));
    await repo.purgeAll();
    for (final t in [
      'accounts',
      'transactions',
      'kv',
      'change_log_entries',
      'attachments',
      'transaction_tags',
    ]) {
      final n = await db
          .customSelect('SELECT count(*) AS n FROM $t')
          .getSingle();
      expect(n.data['n'], 0, reason: t);
    }
  });

  test('prefs persist through the kv table', () async {
    await repo.savePrefs(
      const UserPrefs(
        theme: 'dark',
        pinEnabled: true,
        safetyCushionCents: 50000,
      ),
    );
    final l = await repo.loadLedger();
    expect(l.prefs.theme, 'dark');
    expect(l.prefs.pinEnabled, isTrue);
    expect(l.prefs.safetyCushionCents, 50000);
  });
}
