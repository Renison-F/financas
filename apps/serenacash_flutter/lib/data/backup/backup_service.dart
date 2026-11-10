/// Export/import of backups with a written report. Formats accepted on import:
///   * `serenacash` schema v1 (plain JSON) — produced by the RN app and by this app;
///   * `serenacash-backup-enc` v1 — the authenticated encrypted container (AES-256-GCM + Argon2id);
///   * legacy `pouso-financas-v2` (the original single-file web app), identified only by its internal id.
/// Restoring is atomic: the current data is replaced only after the whole file is validated and written.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../../domain/io/backup.dart';
import '../../domain/io/legacy.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/ledger_repository.dart';
import '../../domain/ports/shopping_repository.dart';
import '../../domain/shopping/shopping.dart';
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
    this.shopping,
    this.clock = const SystemClock(),
    this.ids = const UuidV4IdGenerator(),
  });
  final LedgerRepository repo;

  /// Shopping lists, purchases, products and price history. Optional so the ledger-only format of
  /// the original app keeps working; when present it is exported under the `shopping` extension key.
  final ShoppingRepository? shopping;
  final AppDatabase db;
  final Clock clock;
  final IdGenerator ids;

  /// Plain JSON backup (schema v1) plus the extension keys `attachments` (base64), `recurrenceRules`
  /// and `shopping`. A reader that does not know an extension key ignores it.
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
    final shop = shopping;
    if (shop != null) {
      final sessions = await shop.sessions(limit: _allSessions);
      // Evidence photos and receipt lines travel with the purchases they belong to. The photos go
      // as they were captured; with the encrypted backup they are encrypted with everything else.
      final evidence = <Map<String, dynamic>>[];
      final receiptLines = <Map<String, dynamic>>[];
      for (final s in sessions) {
        for (final e in await shop.evidenceOf(s.id)) {
          final bytes = await shop.evidenceBytes(e.id);
          if (bytes == null) continue;
          evidence.add({
            'id': e.id,
            'sessionId': e.sessionId,
            if (e.lineId != null) 'lineId': e.lineId,
            'role': e.role,
            'mimeType': e.mimeType,
            'sha256': e.sha256,
            if (e.width != null) 'width': e.width,
            if (e.height != null) 'height': e.height,
            'capturedAt': e.capturedAt,
            if (e.ocr != null) 'ocr': e.ocr!.map((b) => b.toJson()).toList(),
            'dataBase64': base64Encode(bytes),
          });
        }
        for (final r in await shop.receiptLines(s.id)) {
          receiptLines.add({
            'id': r.id,
            'sessionId': s.id,
            'rawText': r.rawText,
            'description': r.description,
            'quantity': r.quantity,
            'unit': r.unit,
            if (r.unitPriceCents != null) 'unitPriceCents': r.unitPriceCents,
            'totalCents': r.totalCents,
            if (r.code != null) 'code': r.code,
            if (r.matchedLineId != null) 'matchedLineId': r.matchedLineId,
            'matchStatus': r.matchStatus,
            if (r.matchScore != null) 'matchScore': r.matchScore,
          });
        }
      }
      doc['shopping'] = {
        'lists': [
          for (final x in await shop.lists(includeArchived: true)) x.toJson(),
        ],
        'sessions': [for (final x in sessions) x.toJson()],
        'products': [for (final x in await shop.products()) x.toJson()],
        'observations': [for (final x in await shop.observations()) x.toJson()],
        if (evidence.isNotEmpty) 'evidence': evidence,
        if (receiptLines.isNotEmpty) 'receiptLines': receiptLines,
      };
    }
    return jsonEncode(doc);
  }

  static const _allSessions = 1 << 30;

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
    // Shopping data: parsed before anything is written, so a malformed section aborts the restore.
    final shop = shopping;
    final shopDoc = doc['shopping'];
    var lists = const <ShoppingList>[];
    var sessions = const <ShoppingSession>[];
    var products = const <Product>[];
    var observations = const <PriceObservation>[];
    var evidence = const <(Evidence, Uint8List)>[];
    var receiptLines = const <(String, ReceiptLine)>[];
    final hasShopping = shop != null && shopDoc is Map<String, dynamic>;
    if (hasShopping) {
      try {
        List<T> read<T>(String key, T Function(Map<String, dynamic>) f) => [
          for (final e in shopDoc[key] as List<dynamic>? ?? const [])
            f(e as Map<String, dynamic>),
        ];
        lists = read('lists', ShoppingList.fromJson);
        sessions = read('sessions', ShoppingSession.fromJson);
        products = read('products', Product.fromJson);
        observations = read('observations', PriceObservation.fromJson);
        evidence = read('evidence', (j) {
          final bytes = base64Decode(j['dataBase64'] as String);
          // A photo that does not match its own digest was damaged or swapped: the restore stops.
          if (crypto.sha256.convert(bytes).toString() != j['sha256']) {
            throw const FormatException('foto de evidência não confere');
          }
          return (
            Evidence(
              id: j['id'] as String,
              sessionId: j['sessionId'] as String,
              lineId: j['lineId'] as String?,
              role: j['role'] as String,
              mimeType: j['mimeType'] as String,
              sizeBytes: bytes.length,
              sha256: j['sha256'] as String,
              width: (j['width'] as num?)?.toInt(),
              height: (j['height'] as num?)?.toInt(),
              capturedAt: j['capturedAt'] as String,
              ocr: j['ocr'] == null
                  ? null
                  : [
                      for (final b in j['ocr'] as List)
                        OcrBox.fromJson(b as Map<String, dynamic>),
                    ],
            ),
            bytes,
          );
        });
        var position = 0;
        receiptLines = read(
          'receiptLines',
          (j) => (
            j['sessionId'] as String,
            ReceiptLine(
              id: j['id'] as String,
              position: position++,
              rawText: j['rawText'] as String,
              description: j['description'] as String,
              quantity: (j['quantity'] as num).toDouble(),
              unit: j['unit'] as String,
              unitPriceCents: (j['unitPriceCents'] as num?)?.toInt(),
              totalCents: (j['totalCents'] as num).toInt(),
              code: j['code'] as String?,
              matchedLineId: j['matchedLineId'] as String?,
              matchStatus: j['matchStatus'] as String,
              matchScore: (j['matchScore'] as num?)?.toDouble(),
            ),
          ),
        );
      } catch (e) {
        return _save(
          ImportReport(
            id: id,
            source: source,
            at: at,
            counts: _counts(ledger),
            warnings: warnings,
            errors: ['Backup corrompido: dados de compras inválidos ($e).'],
            schemaVersion: ok.schemaVersion,
          ),
        );
      }
    } else if (shop != null) {
      warnings.add(
        'Este backup não traz dados de Compras; as listas e o histórico de preços atuais foram mantidos.',
      );
    }
    if (replace) {
      await db.transaction(() async {
        await repo.replaceAll(ledger, recurrenceRules: rules);
        if (hasShopping) {
          await shop.purgeAll();
          for (final x in products) {
            await shop.upsertProduct(x);
          }
          for (final x in lists) {
            await shop.upsertList(x);
          }
          for (final x in sessions) {
            await shop.upsertSession(x);
          }
          await shop.addObservations(observations);
          for (final (e, bytes) in evidence) {
            await shop.saveEvidence(e, bytes);
          }
          final bySession = <String, List<ReceiptLine>>{};
          for (final (sessionId, line) in receiptLines) {
            bySession.putIfAbsent(sessionId, () => []).add(line);
          }
          for (final entry in bySession.entries) {
            await shop.replaceReceiptLines(entry.key, entry.value);
          }
        }
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
          if (hasShopping) ...{
            'shoppingLists': lists.length,
            'shoppingSessions': sessions.length,
            'products': products.length,
            'priceObservations': observations.length,
          },
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
