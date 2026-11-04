/// Export/import of backups with a written report. Formats accepted on import:
///   * `serenacash` schema v1 (plain JSON) — produced by the RN app and by this app;
///   * `serenacash-backup-enc` v1 — the authenticated encrypted container (AES-256-GCM + Argon2id);
///   * legacy `pouso-financas-v2` (the original single-file web app), identified only by its internal id.
/// Restoring is atomic: the current data is replaced only after the whole file is validated and written.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../../domain/io/backup.dart';
import '../../domain/io/legacy.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/ledger_repository.dart';
import '../database/app_database.dart';
import '../security/backup_crypto.dart';

class ImportReport {
  ImportReport({
    required this.id,
    required this.source,
    required this.at,
    required this.counts,
    required this.warnings,
    required this.errors,
    this.schemaVersion,
  });
  final String id;
  final String source; // serenacash_v1 | serenacash_enc_v1 | legacy_pouso_v2
  final String at;
  final Map<String, int> counts;
  final List<String> warnings;
  final List<String> errors;
  final int? schemaVersion;
  bool get ok => errors.isEmpty;
  Map<String, dynamic> toJson() => {
    'id': id,
    'source': source,
    'at': at,
    'counts': counts,
    'warnings': warnings,
    'errors': errors,
    if (schemaVersion != null) 'schemaVersion': schemaVersion,
  };
}

class BackupService {
  BackupService({
    required this.repo,
    required this.db,
    this.clock = const SystemClock(),
    this.ids = const UuidV4IdGenerator(),
  });
  final LedgerRepository repo;
  final AppDatabase db;
  final Clock clock;
  final IdGenerator ids;

  /// Plain JSON backup (schema v1) plus attachments (base64) under the `attachments` extension key.
  Future<String> exportPlainJson() async {
    final ledger = await repo.loadLedger();
    final doc = createBackup(ledger, exportedAt: clock.nowISO()).toJson();
    final atts = <Map<String, dynamic>>[];
    for (final t in ledger.transactions) {
      for (final a in t.attachments) {
        final bytes = await repo.attachmentBytes(a.id);
        if (bytes != null) {
          atts.add({
            'transactionId': t.id,
            ...a.toJson(),
            'dataBase64': base64Encode(bytes),
          });
        }
      }
    }
    final rules = await repo.recurrenceRules();
    doc['attachments'] = atts;
    doc['recurrenceRules'] = rules.map((r) => r.toJson()).toList();
    return jsonEncode(doc);
  }

  Future<String> exportEncrypted(String passphrase) async =>
      encryptBackup(utf8.encode(await exportPlainJson()), passphrase);

  /// Validates and restores. Never partially applies: on any error the database is untouched.
  Future<ImportReport> importFromText(
    String text, {
    String? passphrase,
    bool replace = true,
  }) async {
    final at = clock.nowISO();
    final id = ids.newId();
    Object? parsed;
    try {
      parsed = jsonDecode(text);
    } catch (_) {
      return _save(
        ImportReport(
          id: id,
          source: 'unknown',
          at: at,
          counts: const {},
          warnings: const [],
          errors: const ['Arquivo não é JSON válido.'],
        ),
      );
    }
    if (isEncryptedBackup(parsed)) {
      if (passphrase == null) {
        return _save(
          ImportReport(
            id: id,
            source: 'serenacash_enc_v1',
            at: at,
            counts: const {},
            warnings: const [],
            errors: const ['Backup cifrado: informe a senha.'],
          ),
        );
      }
      try {
        final plain = await decryptBackup(
          parsed! as Map<String, dynamic>,
          passphrase,
        );
        parsed = jsonDecode(utf8.decode(plain));
      } on BackupCryptoError catch (e) {
        return _save(
          ImportReport(
            id: id,
            source: 'serenacash_enc_v1',
            at: at,
            counts: const {},
            warnings: const [],
            errors: [e.message],
          ),
        );
      }
      return _restoreSerena(
        parsed,
        id,
        at,
        'serenacash_enc_v1',
        replace: replace,
      );
    }
    if (isLegacyBackup(parsed)) {
      final r = importLegacyBackup(parsed! as Map<String, dynamic>, now: at);
      final errors = <String>[];
      _checkReferences(r.ledger, errors);
      final report = ImportReport(
        id: id,
        source: 'legacy_pouso_v2',
        at: at,
        counts: r.counts,
        warnings: r.warnings,
        errors: errors,
      );
      if (replace && errors.isEmpty) await repo.replaceAll(r.ledger);
      return _save(report);
    }
    return _restoreSerena(parsed, id, at, 'serenacash_v1', replace: replace);
  }

  Future<ImportReport> _restoreSerena(
    Object? parsed,
    String id,
    String at,
    String source, {
    required bool replace,
  }) async {
    final v = validateBackup(parsed);
    if (v is BackupInvalid) {
      return _save(
        ImportReport(
          id: id,
          source: source,
          at: at,
          counts: const {},
          warnings: const [],
          errors: [v.error],
        ),
      );
    }
    final ok = (v as BackupOk).backup;
    final ledger = ok.ledger;
    final warnings = <String>[];
    final errors = <String>[];
    _checkReferences(ledger, errors);
    if (errors.isNotEmpty) {
      return _save(
        ImportReport(
          id: id,
          source: source,
          at: at,
          counts: _counts(ledger),
          warnings: warnings,
          errors: errors,
          schemaVersion: ok.schemaVersion,
        ),
      );
    }
    final doc = parsed! as Map<String, dynamic>;
    final rules = (doc['recurrenceRules'] as List<dynamic>? ?? const [])
        .map((e) => StoredRecurrence.fromJson(e as Map<String, dynamic>))
        .toList();
    final atts = (doc['attachments'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    if (replace) {
      await db.transaction(() async {
        await repo.replaceAll(ledger, recurrenceRules: rules);
        for (final a in atts) {
          try {
            await repo.putAttachment(
              a['transactionId'] as String,
              Attachment.fromJson(a),
              base64Decode(a['dataBase64'] as String),
            );
          } catch (e) {
            warnings.add('Anexo ${a['fileName']} ignorado: $e');
          }
        }
      });
    }
    return _save(
      ImportReport(
        id: id,
        source: source,
        at: at,
        counts: {
          ..._counts(ledger),
          'attachments': atts.length,
          'recurrenceRules': rules.length,
        },
        warnings: warnings,
        errors: errors,
        schemaVersion: ok.schemaVersion,
      ),
    );
  }

  Map<String, int> _counts(Ledger l) => {
    'accounts': l.accounts.length,
    'categories': l.categories.length,
    'tags': l.tags.length,
    'cards': l.cards.length,
    'transactions': l.transactions.length,
    'budgets': l.budgets.length,
    'goals': l.goals.length,
    'loans': l.loans.length,
  };

  /// Referential integrity of the document (the database would reject it anyway; this gives readable errors).
  void _checkReferences(Ledger l, List<String> errors) {
    final accounts = l.accounts.map((a) => a.id).toSet();
    final cards = l.cards.map((c) => c.id).toSet();
    final categories = l.categories.map((c) => c.id).toSet();
    final goals = l.goals.map((g) => g.id).toSet();
    final loans = l.loans.map((x) => x.id).toSet();
    final txIds = l.transactions.map((t) => t.id).toSet();
    final tags = l.tags.map((t) => t.id).toSet();
    for (final t in l.transactions) {
      if (t.accountId != null && !accounts.contains(t.accountId)) {
        errors.add('Lançamento ${t.id}: conta ${t.accountId} inexistente');
      }
      if (t.toAccountId != null && !accounts.contains(t.toAccountId)) {
        errors.add(
          'Lançamento ${t.id}: conta destino ${t.toAccountId} inexistente',
        );
      }
      if (t.cardId != null && !cards.contains(t.cardId)) {
        errors.add('Lançamento ${t.id}: cartão ${t.cardId} inexistente');
      }
      if (t.categoryId != null && !categories.contains(t.categoryId)) {
        errors.add('Lançamento ${t.id}: categoria ${t.categoryId} inexistente');
      }
      if (t.goalId != null && !goals.contains(t.goalId)) {
        errors.add('Lançamento ${t.id}: meta ${t.goalId} inexistente');
      }
      if (t.loanId != null && !loans.contains(t.loanId)) {
        errors.add('Lançamento ${t.id}: empréstimo ${t.loanId} inexistente');
      }
      if (t.refundOfId != null && !txIds.contains(t.refundOfId)) {
        errors.add(
          'Lançamento ${t.id}: estorno de ${t.refundOfId} inexistente',
        );
      }
      for (final tag in t.tags) {
        if (!tags.contains(tag)) {
          errors.add('Lançamento ${t.id}: etiqueta $tag inexistente');
        }
      }
      if (t.amountCents < 0) errors.add('Lançamento ${t.id}: valor negativo');
    }
    for (final c in l.cards) {
      if (c.defaultPaymentAccountId != null &&
          !accounts.contains(c.defaultPaymentAccountId)) {
        errors.add('Cartão ${c.id}: conta de pagamento inexistente');
      }
    }
    for (final b in l.budgets) {
      if (b.categoryId != null && !categories.contains(b.categoryId)) {
        errors.add('Orçamento ${b.id}: categoria inexistente');
      }
    }
    for (final c in l.categories) {
      if (c.parentId != null && !categories.contains(c.parentId)) {
        errors.add('Categoria ${c.id}: categoria pai inexistente');
      }
    }
  }

  Future<ImportReport> _save(ImportReport r) async {
    await db
        .into(db.importReports)
        .insertOnConflictUpdate(
          ImportReportsCompanion(
            id: Value(r.id),
            source: Value(r.source),
            at: Value(r.at),
            reportJson: Value(jsonEncode(r.toJson())),
          ),
        );
    return r;
  }

  Future<List<ImportReport>> reports() async {
    final rows = await (db.select(
      db.importReports,
    )..orderBy([(t) => OrderingTerm.desc(t.at)])).get();
    return rows.map((row) {
      final j = jsonDecode(row.reportJson) as Map<String, dynamic>;
      return ImportReport(
        id: j['id'] as String,
        source: j['source'] as String,
        at: j['at'] as String,
        counts: (j['counts'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
        warnings: (j['warnings'] as List<dynamic>).cast<String>(),
        errors: (j['errors'] as List<dynamic>).cast<String>(),
        schemaVersion: (j['schemaVersion'] as num?)?.toInt(),
      );
    }).toList();
  }
}
