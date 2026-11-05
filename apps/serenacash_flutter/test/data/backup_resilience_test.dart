/// Backups that are wrong in some way must change nothing: wrong passphrase, cut-off file, edited
/// content, garbage. And two exports of the same data must never share salt or nonce.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/backup/backup_service.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/database/drift_ledger_repository.dart';
import 'package:serenacash/data/database/drift_shopping_repository.dart';
import 'package:serenacash/domain/ledger/ledger.dart';
import 'package:serenacash/domain/ports/ports.dart';

import '../perf/perf_test.dart' show bigLedger;

void main() {
  late AppDatabase db;
  late DriftLedgerRepository repo;
  late BackupService backup;
  const pass = 'frase de teste comprida';

  setUp(() async {
    db = AppDatabase.inMemory();
    final clock = FixedClock('2026-11-05T12:00:00.000Z');
    repo = DriftLedgerRepository(db, clock: clock);
    backup = BackupService(
      repo: repo,
      db: db,
      clock: clock,
      ids: SequentialIdGenerator('b'),
      shopping: DriftShoppingRepository(db, clock: clock),
    );
    await repo.replaceAll(bigLedger(60));
  });
  tearDown(() => db.close());

  Future<String> picture() async {
    final l = await repo.loadLedger();
    return [
      l.transactions.length,
      for (final a in l.accounts) accountBalance(l, a.id),
      (l.transactions.map((t) => t.id).toList()..sort()).join(','),
    ].join('|');
  }

  test('wrong passphrase, cut-off file, edited file and garbage are all refused and change nothing', () async {
    final good = await backup.exportEncrypted(pass);
    // The database moves on after the export, so a wrongly accepted restore would be visible.
    final l = await repo.loadLedger();
    await repo.softDelete(EntityTypes.transaction, l.transactions.first.id);
    final before = await picture();

    final envelope = jsonDecode(good) as Map<String, dynamic>;
    final cipher = envelope['ciphertext'] as String;
    final cases = <String, (String, String?)>{
      'senha errada': (good, 'outra frase qualquer'),
      'sem senha': (good, null),
      'arquivo cortado ao meio': (good.substring(0, good.length ~/ 2), pass),
      'arquivo cortado no fim': (good.substring(0, good.length - 40), pass),
      'conteúdo cifrado trocado': (
        jsonEncode({
          ...envelope,
          'ciphertext':
              cipher.substring(0, 40) +
              (cipher[40] == 'A' ? 'B' : 'A') +
              cipher.substring(41),
        }),
        pass,
      ),
      'conteúdo cifrado encurtado': (
        jsonEncode({
          ...envelope,
          'ciphertext': cipher.substring(0, cipher.length - 16),
        }),
        pass,
      ),
      'parâmetros da derivação alterados': (
        jsonEncode({
          ...envelope,
          'kdf': {...(envelope['kdf'] as Map), 'iterations': 1},
        }),
        pass,
      ),
      'lixo': ('isto não é um backup', pass),
      'vazio': ('', pass),
      'json de outra coisa': ('{"app":"outro","dados":[1,2,3]}', pass),
    };
    for (final e in cases.entries) {
      final report = await backup.importFromText(
        e.value.$1,
        passphrase: e.value.$2,
      );
      expect(report.ok, isFalse, reason: e.key);
      expect(await picture(), before, reason: '${e.key}: o banco mudou');
    }
    expect(await db.integrityCheck(), isEmpty);

    // And the untouched file with the right passphrase still restores.
    final ok = await backup.importFromText(good, passphrase: pass);
    expect(ok.ok, isTrue);
    expect(await picture(), isNot(before));
  });

  test('two exports of the same data never repeat salt or nonce, and carry no plain data', () async {
    final a =
        jsonDecode(await backup.exportEncrypted(pass)) as Map<String, dynamic>;
    final b =
        jsonDecode(await backup.exportEncrypted(pass)) as Map<String, dynamic>;
    expect(a['salt'], isNot(b['salt']));
    expect(a['nonce'], isNot(b['nonce']));
    expect(a['ciphertext'], isNot(b['ciphertext']));
    expect(base64Decode(a['salt'] as String), hasLength(16));
    expect(base64Decode(a['nonce'] as String), hasLength(12));
    final text = jsonEncode(a);
    expect(text.contains('Lançamento'), isFalse);
    expect(text.contains('Conta 0'), isFalse);
    expect(text.contains(pass), isFalse);
  });
}
