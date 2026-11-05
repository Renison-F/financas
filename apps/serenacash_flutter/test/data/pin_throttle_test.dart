/// PIN attempts at the lock screen: a few free tries, then growing pauses that survive a restart.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/security/pin.dart';
import 'package:serenacash/data/security/secret_store.dart';

void main() {
  // A light KDF profile keeps the test fast; the policy under test is the counter, not the hash.
  const fast = PinKdfParams(memoryKiB: 64, iterations: 1);
  late InMemorySecretStore store;
  late DateTime clock;
  PinManager manager() => PinManager(store, params: fast, now: () => clock);

  setUp(() {
    store = InMemorySecretStore();
    clock = DateTime.utc(2026, 11, 5, 12);
  });

  test('wrong attempts count down, the fifth one starts a pause', () async {
    final pin = manager();
    await pin.setPin('4821');
    for (var left = 4; left >= 1; left--) {
      final r = await pin.check('0000');
      expect(r.ok, isFalse);
      expect(r.lockedFor, isNull);
      expect(r.attemptsLeft, left);
    }
    final fifth = await pin.check('0000');
    expect(fifth.ok, isFalse);
    expect(fifth.lockedFor, const Duration(seconds: 30));
    expect(fifth.attemptsLeft, 0);
  });

  test('during a pause even the right PIN is not accepted, and is not compared', () async {
    final pin = manager();
    await pin.setPin('4821');
    for (var i = 0; i < 5; i++) {
      await pin.check('0000');
    }
    final blocked = await pin.check('4821');
    expect(blocked.ok, isFalse);
    expect(blocked.lockedFor, isNotNull);
    // A blocked attempt does not extend the pause nor count as another failure.
    clock = clock.add(const Duration(seconds: 31));
    expect(await pin.lockedFor(), isNull);
    expect((await pin.check('4821')).ok, isTrue);
  });

  test(
    'the pause grows with each further wrong attempt, up to one hour',
    () async {
      final pin = manager();
      await pin.setPin('4821');
      for (var i = 0; i < 4; i++) {
        await pin.check('0000');
      }
      final seen = <Duration>[];
      for (var i = 0; i < 7; i++) {
        final r = await pin.check('0000');
        seen.add(r.lockedFor!);
        clock = clock.add(r.lockedFor! + const Duration(seconds: 1));
      }
      expect(seen, [
        const Duration(seconds: 30),
        const Duration(minutes: 1),
        const Duration(minutes: 5),
        const Duration(minutes: 15),
        const Duration(hours: 1),
        const Duration(hours: 1),
        const Duration(hours: 1),
      ]);
    },
  );

  test('closing the app does not give the attempts back', () async {
    await manager().setPin('4821');
    for (var i = 0; i < 5; i++) {
      await manager().check('0000');
    }
    // A new manager is what a restarted app has; the keystore is the same.
    final restarted = manager();
    expect(await restarted.lockedFor(), isNotNull);
    expect((await restarted.check('4821')).ok, isFalse);
  });

  test(
    'the right PIN clears the counter; so do a new PIN and removing the PIN',
    () async {
      final pin = manager();
      await pin.setPin('4821');
      await pin.check('0000');
      await pin.check('0000');
      expect((await pin.check('4821')).ok, isTrue);
      expect(await store.read(SecretKeys.pinAttempts), isNull);
      expect((await pin.check('0000')).attemptsLeft, 4);

      await pin.setPin('135790');
      expect(await store.read(SecretKeys.pinAttempts), isNull);
      await pin.check('0000');
      await pin.clear();
      expect(await store.read(SecretKeys.pinAttempts), isNull);
      expect(await pin.isSet(), isFalse);
    },
  );

  test('a damaged counter never opens the door', () async {
    final pin = manager();
    await pin.setPin('4821');
    await store.write(SecretKeys.pinAttempts, '{not json');
    final r = await pin.check('4821');
    expect(r.ok, isFalse);
    expect(r.lockedFor, isNotNull);
  });

  test(
    'neither the PIN nor anything derived from it in clear is stored',
    () async {
      final pin = manager();
      await pin.setPin('4821');
      await pin.check('9999');
      for (final key in [SecretKeys.pinVerifier, SecretKeys.pinAttempts]) {
        final raw = await store.read(key);
        expect(raw, isNotNull);
        expect(raw!.contains('4821'), isFalse);
        expect(raw.contains('9999'), isFalse);
      }
    },
  );
}
