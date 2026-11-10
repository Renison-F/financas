import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

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

  test('evidence photos, receipt lines and the new cart fields survive an encrypted round trip', () async {
    await repo.replaceAll(fixtureLedger());
    final base = fixtureSession();
    final session = ShoppingSession(
      id: base.id,
      store: base.store,
      listId: base.listId,
      budgetCents: base.budgetCents,
      lines: [
        const CartLine(
          id: 'l-agua',
          name: 'AGUA S/GAS INDAIA PET 5L',
          unit: 'un',
          quantity: 3,
          unitPriceCents: 999,
          priceSource: 'label_ocr',
          checked: true,
          advertisedPriceCents: 999,
          wholesalePriceCents: 949,
          wholesaleMinQuantity: 3,
          chargedUnitPriceCents: 949,
        ),
      ],
      status: 'finished',
      startedAt: base.startedAt,
      finishedAt: base.startedAt,
      events: const [],
    );
    await shopping.upsertSession(session);
    final photo = Uint8List.fromList(
      List.generate(4096, (i) => (i * 31) % 251),
    );
    final digest = crypto.sha256.convert(photo).toString();
    await shopping.saveEvidence(
      Evidence(
        id: 'e1',
        sessionId: session.id,
        lineId: 'l-agua',
        role: 'label',
        mimeType: 'image/jpeg',
        sizeBytes: photo.length,
        sha256: digest,
        width: 960,
        height: 1280,
        capturedAt: '2026-11-08T21:10:00.000Z',
        ocr: const [
          OcrBox(text: '9,99', left: 600, top: 708, width: 156, height: 84),
        ],
      ),
      photo,
    );
    await shopping.replaceReceiptLines(session.id, const [
      ReceiptLine(
        id: 'r1',
        position: 0,
        rawText: 'AGUA S/GAS INDAIA PET 5L 3 UN x 9,49 28,47',
        description: 'AGUA S/GAS INDAIA PET 5L',
        quantity: 3,
        unit: 'un',
        unitPriceCents: 949,
        totalCents: 2847,
        matchedLineId: 'l-agua',
        matchStatus: ReceiptMatch.equal,
        matchScore: 0.99,
      ),
    ]);

    final encrypted = await svc.exportEncrypted('frase de teste longa 42');
    // the photo is not readable in the file: neither its bytes nor its digest nor the item
    expect(encrypted, isNot(contains(digest)));
    expect(encrypted, isNot(contains('INDAIA')));
    expect(encrypted, isNot(contains(base64Encode(photo).substring(0, 40))));

    await shopping.purgeAll();
    expect(await shopping.evidenceOf(session.id), isEmpty);
    final r = await svc.importFromText(
      encrypted,
      passphrase: 'frase de teste longa 42',
    );
    expect(r.ok, isTrue, reason: r.errors.join(' '));

    final line = (await shopping.session(session.id))!.lines.single;
    expect(line.advertisedPriceCents, 999);
    expect(line.wholesalePriceCents, 949);
    expect(line.wholesaleMinQuantity, 3);
    expect(line.chargedUnitPriceCents, 949);
    final ev = (await shopping.evidenceOf(session.id)).single;
    expect(ev.sha256, digest);
    expect(ev.lineId, 'l-agua');
    expect(ev.ocr!.single.text, '9,99');
    expect(await shopping.evidenceBytes(ev.id), photo);
    final rl = (await shopping.receiptLines(session.id)).single;
    expect(rl.matchedLineId, 'l-agua');
    expect(rl.totalCents, 2847);
    expect(rl.matchStatus, ReceiptMatch.equal);
  });

  test('a photo that does not match its digest stops the restore before anything is written', () async {
    await repo.replaceAll(fixtureLedger());
    final session = fixtureSession();
    await shopping.upsertSession(session);
    final photo = Uint8List.fromList(List.generate(64, (i) => i));
    await shopping.saveEvidence(
      Evidence(
        id: 'e1',
        sessionId: session.id,
        role: 'receipt',
        mimeType: 'image/jpeg',
        sizeBytes: photo.length,
        sha256: crypto.sha256.convert(photo).toString(),
        capturedAt: '2026-11-08T21:10:00.000Z',
      ),
      photo,
    );
    final text = await svc.exportPlainJson();
    final doc = jsonDecode(text) as Map<String, dynamic>;
    final ev =
        ((doc['shopping'] as Map<String, dynamic>)['evidence'] as List).single
            as Map<String, dynamic>;
    ev['dataBase64'] = base64Encode(Uint8List.fromList(List.filled(64, 7)));
    final r = await svc.importFromText(jsonEncode(doc));
    expect(r.ok, isFalse);
    expect(r.errors.join(' '), contains('dados de compras inválidos'));
    // what was on the device is still there
    expect(await shopping.evidenceBytes('e1'), photo);
  });
}
