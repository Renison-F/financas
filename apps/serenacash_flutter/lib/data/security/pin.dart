/// PIN verifier with a memory-hard KDF (Argon2id, OWASP minimum profile) and constant-time compare.
/// The PIN gates the UI; the database key is independent (see 06-SEGURANCA.md).
library;

import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'secret_store.dart';

class PinKdfParams {
  const PinKdfParams({
    this.memoryKiB = 19456,
    this.iterations = 2,
    this.parallelism = 1,
  });
  final int memoryKiB;
  final int iterations;
  final int parallelism;
  Map<String, dynamic> toJson() => {
    'name': 'argon2id',
    'memoryKiB': memoryKiB,
    'iterations': iterations,
    'parallelism': parallelism,
  };
  factory PinKdfParams.fromJson(Map<String, dynamic> j) => PinKdfParams(
    memoryKiB: (j['memoryKiB'] as num).toInt(),
    iterations: (j['iterations'] as num).toInt(),
    parallelism: (j['parallelism'] as num).toInt(),
  );
}

Future<List<int>> deriveArgon2id(
  String secret,
  List<int> salt,
  PinKdfParams p, {
  int length = 32,
}) async {
  final kdf = Argon2id(
    parallelism: p.parallelism,
    memory: p.memoryKiB,
    iterations: p.iterations,
    hashLength: length,
  );
  final key = await kdf.deriveKeyFromPassword(password: secret, nonce: salt);
  return key.extractBytes();
}

bool constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

class PinManager {
  PinManager(this.store, {this.params = const PinKdfParams(), Random? rng})
    : _rng = rng ?? Random.secure();
  final SecretStore store;
  final PinKdfParams params;
  final Random _rng;

  static final _pinRe = RegExp(r'^\d{4,8}$');

  Future<bool> isSet() async =>
      (await store.read(SecretKeys.pinVerifier)) != null;

  Future<void> setPin(String pin) async {
    if (!_pinRe.hasMatch(pin)) {
      throw ArgumentError('PIN deve ter de 4 a 8 dígitos');
    }
    final salt = List<int>.generate(16, (_) => _rng.nextInt(256));
    final hash = await deriveArgon2id(pin, salt, params);
    await store.write(
      SecretKeys.pinVerifier,
      jsonEncode({
        'kdf': params.toJson(),
        'salt': base64Encode(salt),
        'hash': base64Encode(hash),
        'v': 1,
      }),
    );
  }

  Future<bool> verify(String pin) async {
    final raw = await store.read(SecretKeys.pinVerifier);
    if (raw == null) return false;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final p = PinKdfParams.fromJson(j['kdf'] as Map<String, dynamic>);
    final hash = await deriveArgon2id(
      pin,
      base64Decode(j['salt'] as String),
      p,
    );
    return constantTimeEquals(hash, base64Decode(j['hash'] as String));
  }

  Future<void> clear() => store.delete(SecretKeys.pinVerifier);
}
