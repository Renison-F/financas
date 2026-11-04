/// Database encryption key: 256 random bits generated on first launch, stored only in the keystore.
library;

import 'dart:math';

import 'secret_store.dart';

String randomHex(int bytes, [Random? rng]) {
  final r = rng ?? Random.secure();
  final sb = StringBuffer();
  for (var i = 0; i < bytes; i++) {
    sb.write(r.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}

class DatabaseKeyManager {
  DatabaseKeyManager(this.store);
  final SecretStore store;

  /// Returns the existing key or creates one. The key never leaves the device.
  Future<String> getOrCreate() async {
    final existing = await store.read(SecretKeys.databaseKey);
    if (existing != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(existing)) {
      return existing;
    }
    final key = randomHex(32);
    await store.write(SecretKeys.databaseKey, key);
    return key;
  }

  /// Destroys the key: the database file becomes unreadable (part of "apagar meus dados").
  Future<void> destroy() => store.delete(SecretKeys.databaseKey);
}
