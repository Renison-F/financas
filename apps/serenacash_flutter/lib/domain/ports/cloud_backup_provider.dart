/// Cloud backup port (not available in v1; local encrypted backups only).
library;

class RemoteBackupInfo {
  const RemoteBackupInfo({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
    required this.deviceId,
  });
  final String id;
  final String createdAt;
  final int sizeBytes;
  final String deviceId;
}

abstract interface class CloudBackupProvider {
  bool get available;
  Future<List<RemoteBackupInfo>> list();
  Future<void> upload(String id, List<int> encryptedBytes);
  Future<List<int>> download(String id);
}

class UnavailableCloudBackup implements CloudBackupProvider {
  const UnavailableCloudBackup();
  @override
  bool get available => false;
  @override
  Future<List<RemoteBackupInfo>> list() async => const [];
  @override
  Future<void> upload(String id, List<int> encryptedBytes) =>
      throw UnsupportedError('Backup em nuvem indisponível nesta versão');
  @override
  Future<List<int>> download(String id) =>
      throw UnsupportedError('Backup em nuvem indisponível nesta versão');
}
