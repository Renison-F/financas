import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/io/backup.dart';
import 'package:serenacash/domain/io/csv.dart';
import 'package:serenacash/domain/io/duplicates.dart';
import 'package:serenacash/domain/io/legacy.dart';
import 'package:serenacash/domain/io/ofx.dart';
import '../fixtures/fixture_loader.dart';

void main() {
  group('io fixtures', () {
    for (final c in loadFixtures('io')) {
      test(c.name, () {
        final i = c.inputMap;
        dynamic actual;
        if (c.name == 'parseCSV pt') {
          final t = parseCSV(i['text'] as String);
          actual = {'delimiter': t.delimiter, 'headers': t.headers, 'rows': t.rows};
        } else if (c.name == 'guessMapping pt') {
          actual = guessColumnMapping((i['headers'] as List<dynamic>).cast<String>()).toJson();
        } else if (c.name.startsWith('candidates ')) {
          final t = parseCSV(i['text'] as String);
          actual = candidatesFromCSV(t, guessColumnMapping(t.headers)).map((x) => x.toJson()).toList();
        } else if (c.name.startsWith('parseDateFlexible')) {
          actual = parseDateFlexible(i['text'] as String);
        } else if (c.name == 'exportCSV') {
          final L = Ledger.fromJson(i['ledger'] as Map<String, dynamic>);
          actual = exportTransactionsCSV(L, L.transactions);
        } else if (c.name == 'parseOFX') {
          actual = parseOFX(i['text'] as String).toJson();
        } else if (c.name == 'candidatesFromOFX') {
          actual = candidatesFromOFX(parseOFX(i['text'] as String)).map((x) => x.toJson()).toList();
        } else if (c.name == 'textSimilarity') {
          actual = textSimilarity(i['a'] as String, i['b'] as String);
        } else if (c.name == 'findDuplicates') {
          final L = Ledger.fromJson(i['ledger'] as Map<String, dynamic>);
          actual = findDuplicates(L, (i['candidates'] as List<dynamic>).map((e) => ImportCandidate.fromJson(e as Map<String, dynamic>)).toList()).map((m) => m.toJson()).toList();
        } else if (c.name == 'importLegacy') {
          final r = importLegacyBackup(i['backup'] as Map<String, dynamic>, now: '2026-11-04T00:00:00.000Z');
          Map<String, dynamic> strip(Map<String, dynamic> m) => {...m}..remove('createdAt')..remove('updatedAt');
          actual = {'counts': r.counts, 'warnings': r.warnings, 'accounts': r.ledger.accounts.map((a) => strip(a.toJson())).toList(), 'cards': r.ledger.cards.map((a) => strip(a.toJson())).toList(), 'transactions': r.ledger.transactions.map((a) => strip(a.toJson())).toList(), 'prefs': r.ledger.prefs.toJson()..remove('lockOnBackground')..remove('pinEnabled')};
        } else {
          fail('unmapped ${c.name}');
        }
        expect(jsonEquals(actual, c.expected), isTrue, reason: 'expected ${c.expected}\n got $actual');
      });
    }
  });
  test('backup round-trip and validation', () {
    const L = Ledger(tags: [Tag(id: 't', name: 'viagem', color: '#000', createdAt: 'x', updatedAt: 'x')]);
    final json = createBackup(L, exportedAt: '2026-11-04T00:00:00.000Z').toJson();
    final v = validateBackup(json);
    expect(v, isA<BackupOk>());
    expect((v as BackupOk).backup.ledger.tags.single.name, 'viagem');
    expect(validateBackup({'app': 'other'}), isA<BackupInvalid>());
    expect(validateBackup({'app': 'serenacash', 'schemaVersion': 99, 'ledger': L.toJson()}), isA<BackupInvalid>());
    expect(validateBackup({'app': 'serenacash', 'schemaVersion': 1, 'ledger': {...L.toJson(), 'transactions': null}}), isA<BackupInvalid>());
    expect(isLegacyBackup({'transactions': [], 'accounts': []}), isTrue);
    expect(isLegacyBackup(json), isFalse);
  });
}
