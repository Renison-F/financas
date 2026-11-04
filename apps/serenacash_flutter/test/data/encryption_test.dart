import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/security/db_key.dart';
import 'package:serenacash/data/security/secret_store.dart';

void main() {
  late Directory dir;
  setUp(
    () async => dir = await Directory.systemTemp.createTemp('serenacash-enc-'),
  );
  tearDown(() => dir.delete(recursive: true));

  test('database file is encrypted with SQLCipher; wrong key cannot open; raw header is not SQLite', () async {
    final path = '${dir.path}/app.db';
    final keys = DatabaseKeyManager(InMemorySecretStore());
    final key = await keys.getOrCreate();
    expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(
      await keys.getOrCreate(),
      key,
      reason: 'chave estável entre chamadas',
    );

    var db = AppDatabase(encryptedExecutorSync(path, key));
    expect(await db.cipherVersion(), isNotNull);
    await db
        .into(db.kv)
        .insert(
          const KvCompanion(
            key: Value('k'),
            json: Value('"segredo"'),
            updatedAt: Value('2026-11-04T00:00:00Z'),
          ),
        );
    await db.close();

    final header = await File(path).openRead(0, 16).first;
    expect(
      String.fromCharCodes(header).startsWith('SQLite format 3'),
      isFalse,
      reason: 'cabeçalho em claro indicaria banco sem cifra',
    );
    final content = await File(path).readAsBytes();
    expect(
      String.fromCharCodes(content).contains('segredo'),
      isFalse,
      reason: 'dados não podem aparecer em claro no arquivo',
    );

    final wrong = AppDatabase(encryptedExecutorSync(path, 'f' * 64));
    await expectLater(wrong.customSelect('SELECT 1').get(), throwsA(anything));
    await wrong.close();

    db = AppDatabase(encryptedExecutorSync(path, key));
    final row = await (db.select(
      db.kv,
    )..where((t) => t.key.equals('k'))).getSingle();
    expect(row.json, '"segredo"');
    await db.close();
  });

  test('refuses malformed keys', () {
    expect(
      () => encryptedExecutorSync('${dir.path}/x.db', 'short'),
      throwsA(isA<DatabaseKeyError>()),
    );
  });
}
