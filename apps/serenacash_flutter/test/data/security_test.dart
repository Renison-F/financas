import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/security/backup_crypto.dart';
import 'package:serenacash/data/security/pin.dart';
import 'package:serenacash/data/security/secret_store.dart';

void main() {
  const fastKdf = PinKdfParams(memoryKiB: 1024, iterations: 1, parallelism: 1);

  group('PIN', () {
    test(
      'set/verify with Argon2id verifier; wrong PIN fails; cleared PIN fails',
      () async {
        final store = InMemorySecretStore();
        final pin = PinManager(store, params: fastKdf, rng: Random(1));
        expect(await pin.isSet(), isFalse);
        await pin.setPin('1234');
        expect(await pin.isSet(), isTrue);
        final raw = await store.read(SecretKeys.pinVerifier);
        expect(
          raw,
          isNot(contains('1234')),
          reason: 'o PIN nunca é armazenado em claro',
        );
        expect(
          ((jsonDecode(raw!) as Map<String, dynamic>)['kdf']
              as Map<String, dynamic>)['name'],
          'argon2id',
        );
        expect(await pin.verify('1234'), isTrue);
        expect(await pin.verify('1235'), isFalse);
        await pin.clear();
        expect(await pin.verify('1234'), isFalse);
      },
    );
    test('rejects weak formats', () async {
      final pin = PinManager(InMemorySecretStore(), params: fastKdf);
      expect(() => pin.setPin('12'), throwsArgumentError);
      expect(() => pin.setPin('abcd'), throwsArgumentError);
    });
    test('constant-time compare', () {
      expect(constantTimeEquals([1, 2, 3], [1, 2, 3]), isTrue);
      expect(constantTimeEquals([1, 2, 3], [1, 2, 4]), isFalse);
      expect(constantTimeEquals([1, 2], [1, 2, 3]), isFalse);
    });
  });

  group('encrypted backup container', () {
    test('round-trip, wrong passphrase, tampered ciphertext and tampered header all fail closed', () async {
      final plain = utf8.encode(
        '{"app":"serenacash","schemaVersion":1,"ledger":{}}',
      );
      final env = await encryptBackup(
        plain,
        'senha-forte-123',
        kdf: fastKdf,
        rng: Random(7),
      );
      final j = jsonDecode(env) as Map<String, dynamic>;
      expect(j['format'], backupEncFormat);
      expect(
        env,
        isNot(contains('serenacash","schemaVersion')),
        reason: 'conteúdo não aparece em claro',
      );
      expect(await decryptBackup(j, 'senha-forte-123'), plain);
      await expectLater(
        decryptBackup(j, 'senha-errada-123'),
        throwsA(isA<BackupCryptoError>()),
      );
      final tampered = {
        ...j,
        'ciphertext': base64Encode(
          base64Decode(j['ciphertext'] as String).map((b) => b ^ 0x01).toList(),
        ),
      };
      await expectLater(
        decryptBackup(tampered, 'senha-forte-123'),
        throwsA(isA<BackupCryptoError>()),
      );
      final headerTampered = {
        ...j,
        'kdf': {...(j['kdf'] as Map<String, dynamic>), 'iterations': 1},
        'salt': base64Encode(List.filled(16, 0)),
      };
      await expectLater(
        decryptBackup(headerTampered, 'senha-forte-123'),
        throwsA(isA<BackupCryptoError>()),
      );
    });
    test('short passphrase refused; absurd KDF params refused', () async {
      await expectLater(
        encryptBackup([1], 'curta', kdf: fastKdf),
        throwsA(isA<BackupCryptoError>()),
      );
      final env = jsonDecode(
        await encryptBackup([1, 2], 'senha-forte-123', kdf: fastKdf),
      ) as Map<String, dynamic>;
      final bomb = {
        ...env,
        'kdf': {
          'name': 'argon2id',
          'memoryKiB': 10 * 1024 * 1024,
          'iterations': 1,
          'parallelism': 1,
        },
      };
      await expectLater(
        decryptBackup(bomb, 'senha-forte-123'),
        throwsA(isA<BackupCryptoError>()),
      );
    });
  });
}
