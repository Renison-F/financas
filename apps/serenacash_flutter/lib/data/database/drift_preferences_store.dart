import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/ports/clock.dart';
import '../../domain/ports/preferences_store.dart';
import 'app_database.dart';

class DriftPreferencesStore implements PreferencesStore {
  DriftPreferencesStore(this.db, {this.clock = const SystemClock()});
  final AppDatabase db;
  final Clock clock;

  @override
  Future<Object?> get(String key) async {
    final row = await (db.select(
      db.kv,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row == null ? null : jsonDecode(row.json);
  }

  @override
  Future<void> set(String key, Object? value) => db
      .into(db.kv)
      .insertOnConflictUpdate(
        KvCompanion(
          key: Value(key),
          json: Value(jsonEncode(value)),
          updatedAt: Value(clock.nowISO()),
        ),
      );

  @override
  Future<void> remove(String key) =>
      (db.delete(db.kv)..where((t) => t.key.equals(key))).go();

  @override
  Stream<Object?> watch(String key) =>
      (db.select(db.kv)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((r) => r == null ? null : jsonDecode(r.json));
}
