/// Drift database. Schema v3 (steps in [AppDatabase._upgradeStep]). Opened through [openEncryptedDatabase] in production (SQLCipher) and
/// through [AppDatabase.inMemory] in tests.
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Tags,
    CreditCards,
    Transactions,
    TransactionTags,
    Attachments,
    Budgets,
    Goals,
    Loans,
    RecurrenceRules,
    ShoppingLists,
    ShoppingListItems,
    Products,
    ProductInternalCodes,
    PriceObservations,
    ShoppingSessions,
    ShoppingSessionLines,
    ShoppingSessionEvents,
    ShoppingEvidence,
    ShoppingReceiptLines,
    Kv,
    ChangeLogEntries,
    Conflicts,
    ImportReports,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Unencrypted in-memory database for unit tests only.
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  static const currentSchemaVersion = 3;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Each future step is appended here as `if (from < N) { ... }` and covered by
      // test/data/migration_test.dart with a schema dump of version N-1.
      await customStatement('PRAGMA foreign_keys = OFF');
      try {
        for (var v = from + 1; v <= to; v++) {
          await _upgradeStep(m, v);
        }
      } finally {
        await customStatement('PRAGMA foreign_keys = ON');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA secure_delete = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );

  Future<void> _upgradeStep(Migrator m, int version) async {
    switch (version) {
      case 2:
        // Recurring budgets get the months they are in force. What already exists starts in the
        // month it was created (the device's local month, the one the user saw), never earlier.
        await m.addColumn(budgets, budgets.validFrom);
        await m.addColumn(budgets, budgets.validUntil);
        final rows = await customSelect(
          'SELECT id, created_at FROM budgets WHERE month IS NULL',
        ).get();
        for (final r in rows) {
          final created = DateTime.tryParse(r.read<String>('created_at'));
          if (created == null) continue;
          final local = created.toLocal();
          final month =
              '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}';
          await customStatement(
            'UPDATE budgets SET valid_from = ? WHERE id = ?',
            [month, r.read<String>('id')],
          );
        }
      case 3:
        // Shelf evidence and receipt comparison: four optional columns on the cart lines and two
        // new tables. Nothing existing is rewritten.
        await m.addColumn(
          shoppingSessionLines,
          shoppingSessionLines.advertisedPriceCents,
        );
        await m.addColumn(
          shoppingSessionLines,
          shoppingSessionLines.wholesalePriceCents,
        );
        await m.addColumn(
          shoppingSessionLines,
          shoppingSessionLines.wholesaleMinQuantity,
        );
        await m.addColumn(
          shoppingSessionLines,
          shoppingSessionLines.chargedUnitPriceCents,
        );
        await m.createTable(shoppingEvidence);
        await m.createIndex(idxEvidenceSession);
        await m.createTable(shoppingReceiptLines);
        await m.createIndex(idxReceiptLinesSession);
      default:
        throw StateError('Migração desconhecida para a versão $version');
    }
  }

  /// SQLite integrity + foreign-key check. Returns a list of problems (empty = ok).
  Future<List<String>> integrityCheck() async {
    final problems = <String>[];
    final ic = await customSelect('PRAGMA integrity_check').get();
    for (final row in ic) {
      final v = row.data.values.first.toString();
      if (v != 'ok') problems.add('integrity: $v');
    }
    final fk = await customSelect('PRAGMA foreign_key_check').get();
    for (final row in fk) {
      problems.add('foreign_key: ${row.data}');
    }
    return problems;
  }

  /// Reports whether the underlying engine is SQLCipher (encryption available).
  Future<String?> cipherVersion() async {
    final rows = await customSelect('PRAGMA cipher_version').get();
    return rows.isEmpty ? null : rows.first.data.values.first?.toString();
  }
}

/// Thrown when the encrypted database cannot be opened with the provided key.
class DatabaseKeyError extends Error {
  DatabaseKeyError(this.message);
  final String message;
  @override
  String toString() => 'DatabaseKeyError: $message';
}

/// Opens (or creates) an encrypted database at [path] with a 256-bit [hexKey] (64 hex chars).
/// Fails closed: if the bundled engine is not SQLCipher, no database is opened.
QueryExecutor encryptedExecutor(String path, String hexKey) {
  if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hexKey)) {
    throw DatabaseKeyError('chave inválida (esperados 64 caracteres hex)');
  }
  return NativeDatabase.createInBackground(
    File(path),
    setup: (sql.Database db) {
      final cipher = db.select('PRAGMA cipher_version');
      if (cipher.isEmpty) {
        throw DatabaseKeyError(
          'engine sem SQLCipher; recusando abrir banco em claro',
        );
      }
      db.execute("PRAGMA key = \"x'$hexKey'\"");
      db.execute('PRAGMA cipher_memory_security = ON');
      // Fails here with "file is not a database" when the key is wrong.
      db.select('SELECT count(*) FROM sqlite_master');
      db.execute('PRAGMA journal_mode = WAL');
    },
  );
}

/// Synchronous variant for tests and tools (no background isolate).
QueryExecutor encryptedExecutorSync(String path, String hexKey) {
  if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hexKey)) {
    throw DatabaseKeyError('chave inválida (esperados 64 caracteres hex)');
  }
  return NativeDatabase(
    File(path),
    setup: (sql.Database db) {
      final cipher = db.select('PRAGMA cipher_version');
      if (cipher.isEmpty) {
        throw DatabaseKeyError(
          'engine sem SQLCipher; recusando abrir banco em claro',
        );
      }
      db.execute("PRAGMA key = \"x'$hexKey'\"");
      db.execute('PRAGMA cipher_memory_security = ON');
      db.select('SELECT count(*) FROM sqlite_master');
    },
  );
}
