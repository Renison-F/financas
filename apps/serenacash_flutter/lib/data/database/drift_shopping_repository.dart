import 'package:drift/drift.dart';

import '../../domain/ports/change_log.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/ledger_repository.dart' show EntityTypes;
import '../../domain/ports/shopping_repository.dart';
import '../../domain/shopping/shopping.dart';
import '../../domain/sync/sync_model.dart';
import 'app_database.dart';
import 'drift_change_log.dart';
import 'mappers.dart';
import 'watch.dart';

class DriftShoppingRepository implements ShoppingRepository {
  DriftShoppingRepository(
    this.db, {
    this.clock = const SystemClock(),
    this.deviceId = 'local',
    ChangeLog? changeLog,
  }) : changeLog = changeLog ?? DriftChangeLog(db);
  final AppDatabase db;
  final Clock clock;
  final String deviceId;
  final ChangeLog changeLog;

  Future<Stamp> _stamp(TableInfo<Table, dynamic> table, String id) async {
    final versionCol = table.columnsByName['version']! as GeneratedColumn<int>;
    final idCol = table.columnsByName['id']! as GeneratedColumn<String>;
    final row =
        await (db.selectOnly(table)
              ..addColumns([versionCol])
              ..where(idCol.equals(id)))
            .getSingleOrNull();
    return Stamp(
      now: clock.nowISO(),
      version: (row?.read(versionCol) ?? 0) + 1,
      deviceId: deviceId,
    );
  }

  Future<void> _log(
    String type,
    String id,
    String op,
    Map<String, dynamic>? payload,
    Stamp s,
  ) => changeLog.append(
    ChangeRecord(
      id: '${s.now}-$type-$id-${s.version}',
      entityType: type,
      entityId: id,
      op: op,
      payload: payload,
      version: s.version,
      deviceId: s.deviceId,
      at: s.now,
      synced: false,
    ),
  );

  Future<List<ShoppingList>> _lists(
    Expression<bool> Function($ShoppingListsTable) where,
  ) async {
    final rows =
        await (db.select(db.shoppingLists)
              ..where((t) => where(t) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();
    if (rows.isEmpty) return const [];
    final items = await (db.select(
      db.shoppingListItems,
    )..where((t) => t.listId.isIn(rows.map((r) => r.id).toList()))).get();
    return rows
        .map(
          (r) => listFromRow(r, items.where((i) => i.listId == r.id).toList()),
        )
        .toList();
  }

  @override
  Future<List<ShoppingList>> lists({bool includeArchived = false}) => _lists(
    (t) => includeArchived ? const Constant(true) : t.archived.equals(false),
  );

  @override
  Future<ShoppingList?> list(String id) async =>
      (await _lists((t) => t.id.equals(id))).firstOrNull;

  @override
  Stream<List<ShoppingList>> watchLists() => watchQuery(
    db,
    TableUpdateQuery.onAllTables([db.shoppingLists, db.shoppingListItems]),
    lists,
  );

  @override
  Future<void> upsertList(ShoppingList list) => db.transaction(() async {
    final s = await _stamp(db.shoppingLists, list.id);
    await db.into(db.shoppingLists).insertOnConflictUpdate(listToRow(list, s));
    await (db.delete(
      db.shoppingListItems,
    )..where((t) => t.listId.equals(list.id))).go();
    await db.batch(
      (b) => b.insertAll(
        db.shoppingListItems,
        list.items.map((i) => listItemToRow(list.id, i)),
      ),
    );
    await _log(EntityTypes.shoppingList, list.id, 'upsert', list.toJson(), s);
  });

  @override
  Future<bool> deleteList(String id) => db.transaction(() async {
    final s = await _stamp(db.shoppingLists, id);
    if (s.version == 1) return false;
    await (db.update(db.shoppingLists)..where((t) => t.id.equals(id))).write(
      ShoppingListsCompanion(
        deletedAt: Value(s.now),
        updatedAt: Value(s.now),
        version: Value(s.version),
        dirty: const Value(true),
      ),
    );
    await _log(EntityTypes.shoppingList, id, 'delete', null, s);
    return true;
  });

  Future<List<ShoppingSession>> _sessions(
    Expression<bool> Function($ShoppingSessionsTable) where, {
    int? limit,
  }) async {
    final q = db.select(db.shoppingSessions)
      ..where((t) => where(t) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (limit != null) q.limit(limit);
    final rows = await q.get();
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();
    final lines = await (db.select(
      db.shoppingSessionLines,
    )..where((t) => t.sessionId.isIn(ids))).get();
    final events = await (db.select(
      db.shoppingSessionEvents,
    )..where((t) => t.sessionId.isIn(ids))).get();
    return rows
        .map(
          (r) => sessionFromRow(
            r,
            lines.where((l) => l.sessionId == r.id).toList(),
            events.where((e) => e.sessionId == r.id).toList(),
          ),
        )
        .toList();
  }

  @override
  Future<List<ShoppingSession>> sessions({int limit = 50}) =>
      _sessions((t) => const Constant(true), limit: limit);

  @override
  Future<ShoppingSession?> session(String id) async =>
      (await _sessions((t) => t.id.equals(id))).firstOrNull;

  @override
  Future<ShoppingSession?> activeSession() async =>
      (await _sessions((t) => t.status.equals('active'), limit: 1)).firstOrNull;

  @override
  Future<void> upsertSession(ShoppingSession x) => db.transaction(() async {
    final s = await _stamp(db.shoppingSessions, x.id);
    final existing = await (db.select(
      db.shoppingSessions,
    )..where((t) => t.id.equals(x.id))).getSingleOrNull();
    await db
        .into(db.shoppingSessions)
        .insertOnConflictUpdate(
          sessionToRow(x, s, createdAt: existing?.createdAt ?? s.now),
        );
    await (db.delete(
      db.shoppingSessionLines,
    )..where((t) => t.sessionId.equals(x.id))).go();
    await (db.delete(
      db.shoppingSessionEvents,
    )..where((t) => t.sessionId.equals(x.id))).go();
    await db.batch((b) {
      b.insertAll(db.shoppingSessionLines, [
        for (var i = 0; i < x.lines.length; i++) lineToRow(x.id, i, x.lines[i]),
      ]);
      b.insertAll(
        db.shoppingSessionEvents,
        x.events.map((e) => eventToRow(x.id, e)),
      );
    });
    await _log(EntityTypes.shoppingSession, x.id, 'upsert', x.toJson(), s);
  });

  @override
  Future<List<Product>> products() async {
    final rows =
        await (db.select(db.products)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
    final codes = await db.select(db.productInternalCodes).get();
    return rows
        .map(
          (r) => productFromRow(
            r,
            codes.where((c) => c.productId == r.id).toList(),
          ),
        )
        .toList();
  }

  @override
  Future<void> upsertProduct(Product p) => db.transaction(() async {
    final s = await _stamp(db.products, p.id);
    await db.into(db.products).insertOnConflictUpdate(productToRow(p, s));
    await (db.delete(
      db.productInternalCodes,
    )..where((t) => t.productId.equals(p.id))).go();
    await db.batch(
      (b) => b.insertAll(
        db.productInternalCodes,
        p.internalCodes.map(
          (c) => ProductInternalCodesCompanion(
            productId: Value(p.id),
            store: Value(c.store),
            code: Value(c.code),
          ),
        ),
        mode: InsertMode.insertOrIgnore,
      ),
    );
    await _log(EntityTypes.product, p.id, 'upsert', p.toJson(), s);
  });

  @override
  Future<List<PriceObservation>> observations({String? productId}) async {
    final q = db.select(db.priceObservations)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.observedAt)]);
    if (productId != null) q.where((t) => t.productId.equals(productId));
    return (await q.get()).map(observationFromRow).toList();
  }

  @override
  Future<void> addObservations(List<PriceObservation> obs) => db.transaction(
    () async {
      for (final o in obs) {
        final s = await _stamp(db.priceObservations, o.id);
        await db
            .into(db.priceObservations)
            .insertOnConflictUpdate(observationToRow(o, s));
        await _log(EntityTypes.priceObservation, o.id, 'upsert', o.toJson(), s);
      }
    },
  );

  @override
  Future<void> purgeAll() => db.transaction(() async {
    for (final t in <TableInfo<Table, dynamic>>[
      db.shoppingSessionEvents,
      db.shoppingSessionLines,
      db.shoppingSessions,
      db.priceObservations,
      db.productInternalCodes,
      db.products,
      db.shoppingListItems,
      db.shoppingLists,
    ]) {
      await db.delete<Table, dynamic>(t).go();
    }
  });
}
