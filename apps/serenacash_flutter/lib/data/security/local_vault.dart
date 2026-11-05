/// The encrypted database file and its key, treated as one thing: created together on a fresh install,
/// erased together, and never "repaired" by generating a new key for a file that already exists.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import 'db_key.dart';
import 'secret_store.dart';

enum VaultErrorKind {
  /// The database file is on the device but its key is not in the keystore.
  keyMissing,

  /// The keystore entry is there but is not a key.
  keyInvalid,
}

/// The database cannot be opened and nothing was changed. The only ways forward are to try again
/// (a transient keystore failure) or to erase the local data and start over.
class VaultError implements Exception {
  const VaultError(this.kind);
  final VaultErrorKind kind;
  @override
  String toString() => 'VaultError(${kind.name})';
}

class LocalVault {
  LocalVault({required this.store, required this.directory});
  final SecretStore store;
  final Directory directory;

  static const databaseName = 'serenacash.db';
  static final _keyRe = RegExp(r'^[0-9a-f]{64}$');

  File get databaseFile => File(p.join(directory.path, databaseName));

  /// SQLite keeps data in these companions too; all of them are encrypted with the same key.
  List<File> get _allFiles => [
    for (final suffix in const ['', '-wal', '-shm', '-journal'])
      File('${databaseFile.path}$suffix'),
  ];

  Future<bool> databaseExists() => databaseFile.exists();

  /// The key for [databaseFile]. A new key is generated only when there is no database yet; with a
  /// database present, a missing or damaged key is an error and the keystore is left untouched.
  Future<String> resolveKey() async {
    final existing = await store.read(SecretKeys.databaseKey);
    if (existing != null && _keyRe.hasMatch(existing)) return existing;
    if (await databaseExists()) {
      throw VaultError(
        existing == null
            ? VaultErrorKind.keyMissing
            : VaultErrorKind.keyInvalid,
      );
    }
    final key = randomHex(32);
    await store.write(SecretKeys.databaseKey, key);
    return key;
  }

  /// Removes the database files and then the key. The caller closes the database first.
  Future<void> erase() async {
    for (final f in _allFiles) {
      if (await f.exists()) await f.delete();
    }
    await store.delete(SecretKeys.databaseKey);
  }
}
