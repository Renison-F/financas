/// The database key and the encrypted file live and die together. These tests use a real SQLCipher file.
library;

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/security/db_key.dart';
import 'package:serenacash/data/security/local_vault.dart';
import 'package:serenacash/data/security/secret_store.dart';

Future<void> _writeSomething(AppDatabase db) => db
    .into(db.kv)
    .insert(
      const KvCompanion(
        key: Value('k'),
        json: Value('"valor"'),
        updatedAt: Value('2026-11-05T00:00:00Z'),
      ),
    );

void main() {
  late Directory dir;
  late InMemorySecretStore store;
  late LocalVault vault;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('serenacash-vault-');
    store = InMemorySecretStore();
    vault = LocalVault(store: store, directory: dir);
  });
  tearDown(() => dir.delete(recursive: true));

  test('first launch creates the key; later launches reuse it', () async {
    expect(await vault.databaseExists(), isFalse);
    final key = await vault.resolveKey();
    expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
    final db = AppDatabase(encryptedExecutorSync(vault.databaseFile.path, key));
    await _writeSomething(db);
    await db.close();
    expect(await vault.databaseExists(), isTrue);
    expect(await vault.resolveKey(), key);
  });

  test('a database without its key is refused, and no new key is written over the situation', () async {
    final key = await vault.resolveKey();
    final db = AppDatabase(encryptedExecutorSync(vault.databaseFile.path, key));
    await _writeSomething(db);
    await db.close();

    // What the old "apagar tudo" did: the key goes away, the encrypted file stays.
    await store.delete(SecretKeys.databaseKey);
    await expectLater(
      vault.resolveKey(),
      throwsA(
        isA<VaultError>().having(
          (e) => e.kind,
          'kind',
          VaultErrorKind.keyMissing,
        ),
      ),
    );
    // Fail closed: nothing was generated behind the user's back.
    expect(await store.read(SecretKeys.databaseKey), isNull);

    // Why it must be refused: any other key cannot open that file.
    final other = AppDatabase(
      encryptedExecutorSync(vault.databaseFile.path, 'ab' * 32),
    );
    await expectLater(other.customSelect('SELECT 1').get(), throwsA(anything));
    await other.close();
  });

  test(
    'a damaged key entry is never overwritten while the database exists',
    () async {
      final key = await vault.resolveKey();
      final db = AppDatabase(
        encryptedExecutorSync(vault.databaseFile.path, key),
      );
      await _writeSomething(db);
      await db.close();

      await store.write(SecretKeys.databaseKey, 'not-a-key');
      await expectLater(
        vault.resolveKey(),
        throwsA(
          isA<VaultError>().having(
            (e) => e.kind,
            'kind',
            VaultErrorKind.keyInvalid,
          ),
        ),
      );
      expect(await store.read(SecretKeys.databaseKey), 'not-a-key');
    },
  );

  test('erasing removes the file, its WAL companions and the key; the next launch starts clean', () async {
    final key = await vault.resolveKey();
    final db = AppDatabase(encryptedExecutorSync(vault.databaseFile.path, key));
    await _writeSomething(db);
    await db.close();
    // Leftovers a crash could leave behind.
    await File('${vault.databaseFile.path}-wal').writeAsBytes([1, 2, 3]);
    await File('${vault.databaseFile.path}-shm').writeAsBytes([1, 2, 3]);

    await vault.erase();
    expect(await vault.databaseExists(), isFalse);
    expect(File('${vault.databaseFile.path}-wal').existsSync(), isFalse);
    expect(File('${vault.databaseFile.path}-shm').existsSync(), isFalse);
    expect(await store.read(SecretKeys.databaseKey), isNull);

    final fresh = await vault.resolveKey();
    expect(fresh, isNot(key));
    final db2 = AppDatabase(
      encryptedExecutorSync(vault.databaseFile.path, fresh),
    );
    expect(await db2.select(db2.kv).get(), isEmpty);
    await db2.close();
  });

  test('a corrupted database file is reported, not replaced', () async {
    final key = await vault.resolveKey();
    final db = AppDatabase(encryptedExecutorSync(vault.databaseFile.path, key));
    await _writeSomething(db);
    await db.close();
    final bytes = await vault.databaseFile.readAsBytes();
    for (var i = 0; i < 2048 && i < bytes.length; i++) {
      bytes[i] = 0x41;
    }
    await vault.databaseFile.writeAsBytes(bytes, flush: true);

    final broken = AppDatabase(
      encryptedExecutorSync(vault.databaseFile.path, await vault.resolveKey()),
    );
    await expectLater(broken.customSelect('SELECT 1').get(), throwsA(anything));
    await broken.close();
    // The damaged file is still there for a support or forensic copy; nothing was silently recreated.
    expect(await vault.databaseExists(), isTrue);
    expect(await store.read(SecretKeys.databaseKey), key);
  });

  test(
    'DatabaseKeyManager keeps its simple contract for a fresh install',
    () async {
      final keys = DatabaseKeyManager(InMemorySecretStore());
      final a = await keys.getOrCreate();
      expect(await keys.getOrCreate(), a);
    },
  );
}
