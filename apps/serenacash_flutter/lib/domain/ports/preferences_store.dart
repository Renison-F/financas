/// Small key/value port for layout, onboarding flags and cached entitlements. Values are JSON-encodable.
library;

abstract interface class PreferencesStore {
  Future<Object?> get(String key);
  Future<void> set(String key, Object? value);
  Future<void> remove(String key);
  Stream<Object?> watch(String key);
}

abstract final class PrefKeys {
  static const prefs = 'prefs';
  static const dashboardLayout = 'dashboard_layout';
  static const onboarded = 'onboarded';
  static const entitlementCache = 'entitlement_cache';
  static const lastBackupAt = 'last_backup_at';
  static const deviceId = 'device_id';
  static const schemaNote = 'schema_note';
}
