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

/// Result of one PIN attempt at the lock screen.
class PinCheck {
  const PinCheck({required this.ok, this.lockedFor, this.attemptsLeft});
  final bool ok;

  /// Set while attempts are paused; the PIN was not even compared.
  final Duration? lockedFor;

  /// Wrong attempts still allowed before the next pause.
  final int? attemptsLeft;
}

class PinManager {
  PinManager(
    this.store, {
    this.params = const PinKdfParams(),
    Random? rng,
    DateTime Function()? now,
  }) : _rng = rng ?? Random.secure(),
       _now = now ?? DateTime.now;
  final SecretStore store;
  final PinKdfParams params;
  final Random _rng;
  final DateTime Function() _now;
  static final _pinRe = RegExp(r'^\d{4,8}$');

  /// Wrong attempts allowed before the first pause.
  static const freeAttempts = 5;

  /// Pause after the 5th, 6th, 7th… consecutive wrong attempt. A 4-digit PIN has 10.000 combinations;
  /// with these pauses a person guessing by hand gets about 30 tries in the first day.
  static const pauses = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(hours: 1),
  ];

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
    await store.delete(SecretKeys.pinAttempts);
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

  Future<({int failures, int lockedUntilMs})> _attempts() async {
    final raw = await store.read(SecretKeys.pinAttempts);
    if (raw == null) return (failures: 0, lockedUntilMs: 0);
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return (
        failures: (j['failures'] as num).toInt(),
        lockedUntilMs: (j['lockedUntilMs'] as num).toInt(),
      );
    } catch (_) {
      // An unreadable counter must not unlock anything: treat it as the strictest state.
      return (
        failures: freeAttempts + pauses.length,
        lockedUntilMs: _now().add(pauses.last).millisecondsSinceEpoch,
      );
    }
  }

  /// How long attempts are still paused, or null when the PIN can be tried now.
  Future<Duration?> lockedFor() async {
    final a = await _attempts();
    final left = a.lockedUntilMs - _now().millisecondsSinceEpoch;
    return left > 0 ? Duration(milliseconds: left) : null;
  }

  /// One attempt at the lock screen. The counter lives in the keystore, so closing the app or
  /// restarting the phone does not give the attempts back.
  Future<PinCheck> check(String pin) async {
    final locked = await lockedFor();
    if (locked != null) return PinCheck(ok: false, lockedFor: locked);
    if (await verify(pin)) {
      await store.delete(SecretKeys.pinAttempts);
      return const PinCheck(ok: true);
    }
    final failures = (await _attempts()).failures + 1;
    Duration? pause;
    if (failures >= freeAttempts) {
      final i = failures - freeAttempts;
      pause = pauses[i < pauses.length ? i : pauses.length - 1];
    }
    await store.write(
      SecretKeys.pinAttempts,
      jsonEncode({
        'failures': failures,
        'lockedUntilMs': pause == null
            ? 0
            : _now().add(pause).millisecondsSinceEpoch,
      }),
    );
    return PinCheck(
      ok: false,
      lockedFor: pause,
      attemptsLeft: pause == null ? freeAttempts - failures : 0,
    );
  }

  Future<void> clear() async {
    await store.delete(SecretKeys.pinVerifier);
    await store.delete(SecretKeys.pinAttempts);
  }
}
