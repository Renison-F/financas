/// Authenticated, encrypted backup container.
///
/// Envelope (JSON, UTF-8):
/// ```json
/// {"app":"serenacash","format":"serenacash-backup-enc","version":1,
///  "kdf":{"name":"argon2id","memoryKiB":65536,"iterations":3,"parallelism":1},
///  "salt":"<b64 16B>","nonce":"<b64 12B>","ciphertext":"<b64>","mac":"<b64 16B>"}
/// ```
/// Key = Argon2id(passphrase, salt). Cipher = AES-256-GCM; the header fields (app, format, version, kdf,
/// salt) are bound as AAD, so tampering with any of them fails authentication.
library;

import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'pin.dart';

const backupEncFormat = 'serenacash-backup-enc';
const backupEncVersion = 1;

class BackupCryptoError implements Exception {
  BackupCryptoError(this.message);
  final String message;
  @override
  String toString() => 'BackupCryptoError: $message';
}

const defaultBackupKdf = PinKdfParams(
  memoryKiB: 65536,
  iterations: 3,
  parallelism: 1,
);

String _aad(Map<String, dynamic> header) => jsonEncode({
  'app': header['app'],
  'format': header['format'],
  'version': header['version'],
  'kdf': header['kdf'],
  'salt': header['salt'],
});

bool isEncryptedBackup(Object? x) =>
    x is Map<String, dynamic> && x['format'] == backupEncFormat;

Future<String> encryptBackup(
  List<int> plaintext,
  String passphrase, {
  PinKdfParams kdf = defaultBackupKdf,
  Random? rng,
}) async {
  if (passphrase.length < 8) {
    throw BackupCryptoError(
      'A senha do backup deve ter ao menos 8 caracteres.',
    );
  }
  final r = rng ?? Random.secure();
  final salt = List<int>.generate(16, (_) => r.nextInt(256));
  final nonce = List<int>.generate(12, (_) => r.nextInt(256));
  final key = SecretKey(await deriveArgon2id(passphrase, salt, kdf));
  final header = <String, dynamic>{
    'app': 'serenacash',
    'format': backupEncFormat,
    'version': backupEncVersion,
    'kdf': kdf.toJson(),
    'salt': base64Encode(salt),
  };
  final box = await AesGcm.with256bits().encrypt(
    plaintext,
    secretKey: key,
    nonce: nonce,
    aad: utf8.encode(_aad(header)),
  );
  return jsonEncode({
    ...header,
    'nonce': base64Encode(box.nonce),
    'ciphertext': base64Encode(box.cipherText),
    'mac': base64Encode(box.mac.bytes),
  });
}

Future<List<int>> decryptBackup(
  Map<String, dynamic> envelope,
  String passphrase,
) async {
  if (envelope['app'] != 'serenacash' ||
      envelope['format'] != backupEncFormat) {
    throw BackupCryptoError(
      'Este arquivo não é um backup cifrado do SerenaCash.',
    );
  }
  final version = envelope['version'];
  if (version is! num || version > backupEncVersion) {
    throw BackupCryptoError('Backup cifrado de uma versão mais nova do app.');
  }
  final kdf = PinKdfParams.fromJson(envelope['kdf'] as Map<String, dynamic>);
  if (kdf.memoryKiB > 262144 || kdf.iterations > 10) {
    throw BackupCryptoError('Parâmetros de KDF fora do limite permitido.');
  }
  final salt = base64Decode(envelope['salt'] as String);
  final key = SecretKey(await deriveArgon2id(passphrase, salt, kdf));
  final box = SecretBox(
    base64Decode(envelope['ciphertext'] as String),
    nonce: base64Decode(envelope['nonce'] as String),
    mac: Mac(base64Decode(envelope['mac'] as String)),
  );
  try {
    return await AesGcm.with256bits().decrypt(
      box,
      secretKey: key,
      aad: utf8.encode(_aad(envelope)),
    );
  } on SecretBoxAuthenticationError {
    throw BackupCryptoError('Senha incorreta ou arquivo alterado.');
  }
}
