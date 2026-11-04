import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/ports/change_log.dart';
import '../../domain/sync/sync_model.dart';
import 'app_database.dart';
import 'mappers.dart';

class DriftChangeLog implements ChangeLog {
  DriftChangeLog(this.db);
  final AppDatabase db;

  @override
  Future<void> append(ChangeRecord record) =>
      db.into(db.changeLogEntries).insertOnConflictUpdate(changeToRow(record));

  @override
  Future<List<ChangeRecord>> pending({int limit = 500}) async {
    final rows =
        await (db.select(db.changeLogEntries)
              ..where((t) => t.synced.equals(false))
              ..orderBy([(t) => OrderingTerm.asc(t.at)])
              ..limit(limit))
            .get();
    return rows.map(changeFromRow).toList();
  }

  @override
  Future<List<ChangeRecord>> forEntity(
    String entityType,
    String entityId,
  ) async {
    final rows =
        await (db.select(db.changeLogEntries)
              ..where(
                (t) =>
                    t.entityType.equals(entityType) &
                    t.entityId.equals(entityId),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.version)]))
            .get();
    return rows.map(changeFromRow).toList();
  }

  @override
  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    await (db.update(db.changeLogEntries)..where((t) => t.id.isIn(ids))).write(
      const ChangeLogEntriesCompanion(synced: Value(true)),
    );
  }

  @override
  Future<int> count() async {
    final n = db.changeLogEntries.id.count();
    final row = await (db.selectOnly(
      db.changeLogEntries,
    )..addColumns([n])).getSingle();
    return row.read(n) ?? 0;
  }

  @override
  Future<void> saveConflicts(List<Conflict> conflicts) => db.batch((b) {
    for (final c in conflicts) {
      for (final f in c.fields) {
        b.insert(
          db.conflicts,
          ConflictsCompanion(
            entityType: Value(c.entityType),
            entityId: Value(c.entityId),
            field: Value(f),
            localJson: Value(jsonEncode(c.local)),
            remoteJson: Value(jsonEncode(c.remote)),
            detectedAt: Value(c.detectedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    }
  });

  @override
  Future<List<Conflict>> openConflicts() async {
    final rows = await (db.select(
      db.conflicts,
    )..where((t) => t.resolvedAt.isNull())).get();
    final grouped = <String, List<ConflictRow>>{};
    for (final r in rows) {
      (grouped['${r.entityType}/${r.entityId}'] ??= []).add(r);
    }
    return grouped.values
        .map(
          (g) => Conflict(
            entityType: g.first.entityType,
            entityId: g.first.entityId,
            local: jsonDecode(g.first.localJson) as Map<String, dynamic>,
            remote: jsonDecode(g.first.remoteJson) as Map<String, dynamic>,
            fields: g.map((r) => r.field).toList(),
            detectedAt: g.first.detectedAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> resolveConflict(
    String entityType,
    String entityId,
    String field, {
    required String chosenSide,
    required String at,
  }) async {
    if (chosenSide != 'local' && chosenSide != 'remote') {
      throw ArgumentError('chosenSide deve ser local ou remote');
    }
    await (db.update(db.conflicts)..where(
          (t) =>
              t.entityType.equals(entityType) &
              t.entityId.equals(entityId) &
              t.field.equals(field),
        ))
        .write(
          ConflictsCompanion(
            resolvedAt: Value(at),
            chosenSide: Value(chosenSide),
          ),
        );
  }
}
