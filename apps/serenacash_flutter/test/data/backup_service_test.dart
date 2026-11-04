import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/backup/backup_service.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/database/drift_ledger_repository.dart';
import 'package:serenacash/data/security/backup_crypto.dart';
import 'package:serenacash/data/security/pin.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ports/ports.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  late AppDatabase db;
  late DriftLedgerRepository repo;
  late BackupService svc;
  final clock = FixedClock('2026-11-04T12:00:00.000Z');

  setUp(() {
    db = AppDatabase.inMemory();
    repo = DriftLedgerRepository(db, clock: clock);
    svc = BackupService(
      repo: repo,
      db: db,
      clock: clock,
      ids: SequentialIdGenerator('imp'),
    );
  });
  tearDown(() => db.close());

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

  test('plain export → import restores identical ledger, attachments and recurrence rules', () async {
    await repo.replaceAll(
      fixtureLedger(),
      recurrenceRules: const [
        StoredRecurrence(
          rule: RecurrenceRule(
            id: 'r1',
            frequency: 'monthly',
            startDate: '2026-11-05',
          ),
          templateTransactionId: 't1',
        ),
      ],
    );
    final bytes = utf8.encode('nota');
    await repo.putAttachment(
      't2',
      Attachment(
        id: 'att',
        fileName: 'nota.txt',
        mimeType: 'text/plain',
        sizeBytes: 4,
        sha256: crypto.sha256.convert(bytes).toString(),
      ),
      bytes,
    );
    final before = await repo.loadLedger();
    final text = await svc.exportPlainJson();
    await repo.purgeAll();
    expect((await repo.loadLedger()).transactions, isEmpty);
    final report = await svc.importFromText(text);
    expect(report.ok, isTrue, reason: report.errors.join('\n'));
    expect(report.source, 'serenacash_v1');
    expect(report.counts['transactions'], 11);
    expect(report.counts['attachments'], 1);
    expect(report.counts['recurrenceRules'], 1);
    final after = await repo.loadLedger();
    expect(jsonEquals(after.toJson(), before.toJson()), isTrue);
    expect(await repo.attachmentBytes('att'), bytes);
    expect((await repo.recurrenceRules()).single.templateTransactionId, 't1');
    expect((await svc.reports()).single.id, 'imp1');
  });

  test('encrypted export requires the passphrase and restores', () async {
    await repo.replaceAll(fixtureLedger());
    final env = await svc.exportEncrypted('minha-senha-longa');
    expect(isEncryptedBackup(jsonDecode(env)), isTrue);
    await repo.purgeAll();
    final noPass = await svc.importFromText(env);
    expect(noPass.ok, isFalse);
    final wrong = await svc.importFromText(
      env,
      passphrase: 'outra-senha-longa',
    );
    expect(wrong.ok, isFalse);
    expect(
      (await repo.loadLedger()).transactions,
      isEmpty,
      reason: 'nada é aplicado em caso de erro',
    );
    final ok = await svc.importFromText(env, passphrase: 'minha-senha-longa');
    expect(ok.ok, isTrue, reason: ok.errors.join());
    expect(ok.source, 'serenacash_enc_v1');
    expect((await repo.loadLedger()).transactions.length, 11);
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('legacy pouso-financas-v2 backup imports with its report', () async {
    final legacy =
        loadFixtures('io')
                .firstWhere((c) => c.name == 'importLegacy')
                .inputMap['backup']
            as Map<String, dynamic>;
    final r = await svc.importFromText(jsonEncode(legacy));
    expect(r.ok, isTrue, reason: r.errors.join());
    expect(r.source, 'legacy_pouso_v2');
    expect(r.counts['transactions'], greaterThan(0));
    final l = await repo.loadLedger();
    expect(l.transactions.length, r.counts['transactions']);
  });

  test('invalid references are reported and nothing is written', () async {
    await repo.replaceAll(fixtureLedger());
    final doc = jsonDecode(await svc.exportPlainJson()) as Map<String, dynamic>;
    (doc['ledger'] as Map<String, dynamic>)['accounts'] = <dynamic>[];
    final r = await svc.importFromText(jsonEncode(doc));
    expect(r.ok, isFalse);
    expect(r.errors.first, contains('conta'));
    expect(
      (await repo.loadLedger()).accounts.length,
      2,
      reason: 'dados atuais preservados',
    );
    final junk = await svc.importFromText('{"app":"outro"}');
    expect(junk.ok, isFalse);
    final notJson = await svc.importFromText('xx');
    expect(notJson.ok, isFalse);
  });

  test('KDF default profile for backups is at least the OWASP minimum', () {
    expect(defaultBackupKdf.memoryKiB, greaterThanOrEqualTo(19456));
    expect(defaultBackupKdf.iterations, greaterThanOrEqualTo(2));
    expect(const PinKdfParams().memoryKiB, greaterThanOrEqualTo(19456));
  });
}
