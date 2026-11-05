/// Dependency injection (Riverpod). Every feature reaches storage, security and integrations only through
/// these providers and the domain ports (ADR-03/06); tests override them with in-memory implementations.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/backup/backup_service.dart';
import '../data/database/app_database.dart';
import '../data/database/drift_change_log.dart';
import '../data/database/drift_ledger_repository.dart';
import '../data/database/drift_preferences_store.dart';
import '../data/database/drift_shopping_repository.dart';
import '../data/security/local_vault.dart';
import '../data/security/pin.dart';
import '../data/security/secret_store.dart';
import '../domain/ports/ports.dart';

final clockProvider = Provider<Clock>((_) => const SystemClock());
final idGeneratorProvider = Provider<IdGenerator>(
  (_) => const UuidV4IdGenerator(),
);
final secretStoreProvider = Provider<SecretStore>((_) => KeystoreSecretStore());
final pinManagerProvider = Provider<PinManager>(
  (ref) => PinManager(ref.watch(secretStoreProvider)),
);

/// Stable per-install device id (ADR-04), kept in the keystore so a restore from backup does not clone it.
final deviceIdProvider = FutureProvider<String>((ref) async {
  final store = ref.watch(secretStoreProvider);
  final existing = await store.read(SecretKeys.deviceId);
  if (existing != null) return existing;
  final id = ref.read(idGeneratorProvider).newId();
  await store.write(SecretKeys.deviceId, id);
  return id;
});

/// The encrypted database file and its key. Overridden in tests with a temporary directory.
final localVaultProvider = FutureProvider<LocalVault>((ref) async {
  final dir = await getApplicationSupportDirectory();
  await Directory(dir.path).create(recursive: true);
  return LocalVault(store: ref.watch(secretStoreProvider), directory: dir);
});

/// Opens the encrypted database. Overridden in tests with `AppDatabase.inMemory()`.
///
/// Fails closed: a database whose key is missing or damaged is not opened and no key is generated for
/// it ([VaultError]); the boot screen explains it and offers to erase the local data.
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final vault = await ref.watch(localVaultProvider.future);
  final key = await vault.resolveKey();
  final db = AppDatabase(encryptedExecutor(vault.databaseFile.path, key));
  ref.onDispose(db.close);
  return db;
});

/// Erases everything this app keeps on the device: the database files, the database key and the PIN.
/// The database is closed first; afterwards the providers rebuild on an empty database with a new key.
Future<void> eraseLocalData(ProviderContainer container) async {
  try {
    final db = await container.read(databaseProvider.future);
    await db.close();
  } catch (_) {
    // The database may be exactly what failed to open; erasing it is still the point.
  }
  final vault = await container.read(localVaultProvider.future);
  await vault.erase();
  await container.read(pinManagerProvider).clear();
  container.invalidate(databaseProvider);
}

final changeLogProvider = FutureProvider<ChangeLog>(
  (ref) async => DriftChangeLog(await ref.watch(databaseProvider.future)),
);

final ledgerRepositoryProvider = FutureProvider<LedgerRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return DriftLedgerRepository(
    db,
    clock: ref.watch(clockProvider),
    deviceId: await ref.watch(deviceIdProvider.future),
    changeLog: await ref.watch(changeLogProvider.future),
  );
});

final shoppingRepositoryProvider = FutureProvider<ShoppingRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return DriftShoppingRepository(
    db,
    clock: ref.watch(clockProvider),
    deviceId: await ref.watch(deviceIdProvider.future),
    changeLog: await ref.watch(changeLogProvider.future),
  );
});

final preferencesStoreProvider = FutureProvider<PreferencesStore>(
  (ref) async => DriftPreferencesStore(
    await ref.watch(databaseProvider.future),
    clock: ref.watch(clockProvider),
  ),
);

final backupServiceProvider = FutureProvider<BackupService>(
  (ref) async => BackupService(
    repo: await ref.watch(ledgerRepositoryProvider.future),
    shopping: await ref.watch(shoppingRepositoryProvider.future),
    db: await ref.watch(databaseProvider.future),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final authProviderProvider = FutureProvider<AuthProvider>(
  (ref) async => AnonymousLocalAuth(await ref.watch(deviceIdProvider.future)),
);
final entitlementsProviderProvider = Provider<EntitlementsProvider>(
  (_) => const UnavailableBilling(),
);
final cloudBackupProvider = Provider<CloudBackupProvider>(
  (_) => const UnavailableCloudBackup(),
);
final familySharePolicyProvider = Provider<FamilySharePolicy>(
  (_) => const SingleUserPolicy(),
);
