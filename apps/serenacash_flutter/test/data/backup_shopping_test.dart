import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/backup/backup_service.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/database/drift_ledger_repository.dart';
import 'package:serenacash/data/database/drift_shopping_repository.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/shopping/shopping.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  late AppDatabase db;
  late DriftLedgerRepository repo;
  late DriftShoppingRepository shopping;
  late BackupService svc;
  final clock = FixedClock('2026-11-04T12:00:00.000Z');

  setUp(() {
    db = AppDatabase.inMemory();
    repo = DriftLedgerRepository(db, clock: clock);
    shopping = DriftShoppingRepository(db, clock: clock);
    svc = BackupService(
      repo: repo,
      shopping: shopping,
      db: db,
      clock: clock,
      ids: SequentialIdGenerator('imp'),
    );
  });
  tearDown(() => db.close());

  // Same shape as backup_service_test: the fixture references the goal `g`.
  Ledger fixtureLedger() {
    final l = Ledger.fromJson(
      loadFixtures('ledger').first.inputMap['ledger'] as Map<String, dynamic>,
    );
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

  ShoppingList fixtureList() => ShoppingList.fromJson(
    loadFixtures('shopping_lists')
            .firstWhere((c) => c.name == 'estimate')
            .inputMap['list']
        as Map<String, dynamic>,
  );

  ShoppingSession fixtureSession() => ShoppingSession.fromJson(
    loadFixtures('shopping_session')
            .firstWhere((c) => c.name == 'totals')
            .inputMap['session']
        as Map<String, dynamic>,
  );

  test(
    'backup carries shopping lists and purchases and restore brings them back',
    () async {
      await repo.replaceAll(fixtureLedger());
      final list = fixtureList();
      final session = fixtureSession();
      await shopping.upsertList(list);
      await shopping.upsertSession(session);

      final text = await svc.exportPlainJson();
      final doc = jsonDecode(text) as Map<String, dynamic>;
      expect((doc['shopping'] as Map<String, dynamic>)['lists'], hasLength(1));
      expect(
        (doc['shopping'] as Map<String, dynamic>)['sessions'],
        hasLength(1),
      );

      // A different device: everything gone, then restored from the file.
      await shopping.purgeAll();
      expect(await shopping.lists(includeArchived: true), isEmpty);
      final r = await svc.importFromText(text);
      expect(r.ok, isTrue, reason: r.errors.join(' '));
      expect(r.counts['shoppingLists'], 1);
      expect(r.counts['shoppingSessions'], 1);
      final back = (await shopping.list(list.id))!;
      expect(back.items.length, list.items.length);
      expect(estimateList(back).toJson(), estimateList(list).toJson());
      final sessionBack = (await shopping.session(session.id))!;
      expect(sessionBack.lines.length, session.lines.length);
    },
  );

  test('restore replaces shopping data that is not in the backup with what the backup has', () async {
    await repo.replaceAll(fixtureLedger());
    await shopping.upsertList(fixtureList());
    final text = await svc.exportPlainJson();

    final other = fixtureList().copyWith(
      id: 'outra-lista',
      name: 'Outra',
      items: const [],
    );
    await shopping.upsertList(other);
    expect(await shopping.lists(includeArchived: true), hasLength(2));

    final r = await svc.importFromText(text);
    expect(r.ok, isTrue, reason: r.errors.join(' '));
    final lists = await shopping.lists(includeArchived: true);
    expect(lists.map((x) => x.id), [fixtureList().id]);
  });

  test('a ledger-only backup (original format) keeps the current shopping data and says so', () async {
    await repo.replaceAll(fixtureLedger());
    await shopping.upsertList(fixtureList());
    final doc = jsonDecode(await svc.exportPlainJson()) as Map<String, dynamic>
      ..remove('shopping');

    final r = await svc.importFromText(jsonEncode(doc));
    expect(r.ok, isTrue, reason: r.errors.join(' '));
    expect(r.counts.containsKey('shoppingLists'), isFalse);
    expect(r.warnings.join(' '), contains('Compras'));
    expect(await shopping.lists(includeArchived: true), hasLength(1));
  });

  test('a malformed shopping section aborts the restore untouched', () async {
    await repo.replaceAll(fixtureLedger());
    await shopping.upsertList(fixtureList());
    final before = (await repo.loadLedger()).transactions.length;
    final doc = jsonDecode(await svc.exportPlainJson()) as Map<String, dynamic>;
    (doc['ledger'] as Map<String, dynamic>)['transactions'] = <dynamic>[];
    (doc['shopping'] as Map<String, dynamic>)['lists'] = [
      {'id': 7},
    ];

    final r = await svc.importFromText(jsonEncode(doc));
    expect(r.ok, isFalse);
    expect(r.errors.join(' '), contains('compras'));
    expect((await repo.loadLedger()).transactions.length, before);
    expect(await shopping.lists(includeArchived: true), hasLength(1));
  });
}
