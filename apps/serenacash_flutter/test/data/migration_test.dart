/// Upgrades of the local database, run against real schema snapshots (`drift_schemas/`) with data in
/// place: the phone that has version N keeps everything when it installs version N+1.
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/database/app_database.dart';

import '../generated_migrations/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('every step from v1 reaches the current schema', () async {
    for (var from = 1; from < AppDatabase.currentSchemaVersion; from++) {
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, AppDatabase.currentSchemaVersion);
      expect(await db.integrityCheck(), isEmpty);
      await db.close();
    }
  });

  test('v1 → v2: budgets keep their data and gain the month they started', () async {
    final schema = await verifier.schemaAt(1);
    final raw = schema.rawDatabase;
    const sync =
        "'2026-11-07T15:00:00.000Z', '2026-11-07T15:00:00.000Z', NULL, 1, 'local', 1";
    raw.execute(
      "INSERT INTO categories (id, name, kind, icon, color, parent_id, archived, "
      "sort_order, created_at, updated_at, deleted_at, version, device_id, dirty) "
      "VALUES ('c1', 'Alimentação', 'expense', 'food', '#C0703E', NULL, 0, 0, $sync)",
    );
    raw.execute(
      "INSERT INTO budgets (id, category_id, limit_cents, month, rollover, "
      "created_at, updated_at, deleted_at, version, device_id, dirty) "
      "VALUES ('b-geral', NULL, 85000, NULL, 0, $sync)",
    );
    raw.execute(
      "INSERT INTO budgets (id, category_id, limit_cents, month, rollover, "
      "created_at, updated_at, deleted_at, version, device_id, dirty) "
      "VALUES ('b-cat', 'c1', 40000, NULL, 1, "
      "'2026-03-10T12:00:00.000Z', '2026-03-10T12:00:00.000Z', NULL, 1, 'local', 1)",
    );
    raw.execute(
      "INSERT INTO budgets (id, category_id, limit_cents, month, rollover, "
      "created_at, updated_at, deleted_at, version, device_id, dirty) "
      "VALUES ('b-dez', NULL, 120000, '2026-12', 0, $sync)",
    );

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);

    final rows = {for (final r in await db.select(db.budgets).get()) r.id: r};
    expect(rows.length, 3);
    expect(rows['b-geral']!.limitCents, 85000);
    expect(rows['b-geral']!.validFrom, '2026-11');
    expect(rows['b-geral']!.validUntil, isNull);
    expect(rows['b-cat']!.limitCents, 40000);
    expect(rows['b-cat']!.rollover, isTrue);
    expect(rows['b-cat']!.validFrom, '2026-03');
    // a budget of one month has its own month; it gets no period
    expect(rows['b-dez']!.month, '2026-12');
    expect(rows['b-dez']!.validFrom, isNull);
    expect(await db.integrityCheck(), isEmpty);
    await db.close();
  });

  test(
    'v2 → v3: carts keep their lines; evidence and receipt tables start empty',
    () async {
      final schema = await verifier.schemaAt(2);
      final raw = schema.rawDatabase;
      raw.execute(
        "INSERT INTO shopping_sessions (id, store, list_id, budget_cents, status, "
        "started_at, finished_at, transaction_id, receipt_access_key, "
        "created_at, updated_at, deleted_at, version, device_id, dirty) "
        "VALUES ('s1', 'teste', NULL, 70000, 'finished', '2026-11-08T21:07:00.000Z', "
        "'2026-11-08T21:40:00.000Z', NULL, NULL, "
        "'2026-11-08T21:07:00.000Z', '2026-11-08T21:40:00.000Z', NULL, 1, 'local', 1)",
      );
      raw.execute(
        "INSERT INTO shopping_session_lines (id, session_id, position, product_id, name, "
        "brand, barcode, unit, quantity, unit_price_cents, discount_cents, discount_percent, "
        "promo_take, promo_pay, price_source, confidence, list_item_id, checked, note) "
        "VALUES ('l1', 's1', 0, NULL, 'VELA FIAT LUX', NULL, NULL, 'un', 1, 1199, NULL, NULL, "
        "NULL, NULL, 'label_ocr', 0.54, NULL, 1, NULL)",
      );

      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 3);

      final line = await db.select(db.shoppingSessionLines).getSingle();
      expect(line.name, 'VELA FIAT LUX');
      expect(line.unitPriceCents, 1199);
      expect(line.advertisedPriceCents, isNull);
      expect(line.wholesalePriceCents, isNull);
      expect(line.chargedUnitPriceCents, isNull);
      expect(await db.select(db.shoppingEvidence).get(), isEmpty);
      expect(await db.select(db.shoppingReceiptLines).get(), isEmpty);
      expect(await db.integrityCheck(), isEmpty);
      await db.close();
    },
  );
}
