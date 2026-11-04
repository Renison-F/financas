/// Plain backup document (schema v1, compatible with the React Native app). The *encrypted* container that wraps
/// it on device is defined in data/backup (M3); this module is pure.
library;

import '../entities/entities.dart';

const backupSchemaVersion = 1;

class BackupFile {
  const BackupFile({
    required this.schemaVersion,
    required this.exportedAt,
    required this.ledger,
  });
  final int schemaVersion;
  final String exportedAt;
  final Ledger ledger;
  Map<String, dynamic> toJson() => {
    'app': 'serenacash',
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt,
    'ledger': ledger.toJson(),
  };
}

BackupFile createBackup(Ledger ledger, {String? exportedAt}) => BackupFile(
  schemaVersion: backupSchemaVersion,
  exportedAt: exportedAt ?? DateTime.now().toUtc().toIso8601String(),
  ledger: ledger,
);

sealed class BackupValidation {
  const BackupValidation();
}

class BackupOk extends BackupValidation {
  const BackupOk(this.backup);
  final BackupFile backup;
}

class BackupInvalid extends BackupValidation {
  const BackupInvalid(this.error);
  final String error;
}

BackupValidation validateBackup(Object? x) {
  if (x is! Map<String, dynamic>) {
    return const BackupInvalid('Arquivo não é um backup válido.');
  }
  if (x['app'] != 'serenacash') {
    return const BackupInvalid('Este arquivo não é um backup do SerenaCash.');
  }
  final v = x['schemaVersion'];
  if (v is! num || v > backupSchemaVersion) {
    return const BackupInvalid(
      'Backup de uma versão mais nova do app. Atualize o aplicativo.',
    );
  }
  final l = x['ledger'];
  if (l is! Map<String, dynamic>) {
    return const BackupInvalid('Backup sem dados.');
  }
  for (final k in [
    'accounts',
    'categories',
    'tags',
    'cards',
    'transactions',
    'budgets',
    'goals',
    'loans',
  ]) {
    if (l[k] is! List) return BackupInvalid('Backup corrompido: falta "$k".');
  }
  if (l['prefs'] is! Map) {
    return const BackupInvalid('Backup corrompido: faltam preferências.');
  }
  try {
    return BackupOk(
      BackupFile(
        schemaVersion: v.toInt(),
        exportedAt: x['exportedAt'] as String? ?? '',
        ledger: Ledger.fromJson(l),
      ),
    );
  } catch (e) {
    return BackupInvalid('Backup corrompido: $e');
  }
}
