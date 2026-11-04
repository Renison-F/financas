/// Append-only log of every local mutation (ADR-04) plus persisted financial conflicts (ADR-05).
library;

import '../sync/sync_model.dart';

abstract interface class ChangeLog {
  Future<void> append(ChangeRecord record);
  Future<List<ChangeRecord>> pending({int limit = 500});
  Future<List<ChangeRecord>> forEntity(String entityType, String entityId);
  Future<void> markSynced(List<String> ids);
  Future<int> count();

  Future<void> saveConflicts(List<Conflict> conflicts);
  Future<List<Conflict>> openConflicts();
  Future<void> resolveConflict(
    String entityType,
    String entityId,
    String field, {
    required String chosenSide,
    required String at,
  });
}
