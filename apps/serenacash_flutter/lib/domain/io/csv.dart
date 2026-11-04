/// CSV import/export. Mirrors `io/csv.ts`. Nothing is written by this module; the UI reviews candidates first.
library;

import '../dates/dates.dart';
import '../entities/entities.dart';
import '../money/money.dart';
import '../text/normalize.dart';

List<String> parseCSVLine(String line, String delimiter) {
  final out = <String>[];
  final cur = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (quoted && i + 1 < line.length && line[i + 1] == '"') {
        cur.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (ch == delimiter && !quoted) {
      out.add(cur.toString());
      cur.clear();
    } else {
      cur.write(ch);
    }
  }
  out.add(cur.toString());
  return out;
}

String detectDelimiter(String headerLine) {
  final counts = [';', ',', '\t', '|'].map((d) => (d, d.allMatches(headerLine).length)).toList();
  counts.sort((a, b) => b.$2.compareTo(a.$2));
  return counts.first.$1;
}

class CSVTable {
  const CSVTable(this.headers, this.rows, this.delimiter);
  final List<String> headers;
  final List<List<String>> rows;
  final String delimiter;
}

class ImportError implements Exception {
  ImportError(this.message);
  final String message;
  @override
  String toString() => message;
}

CSVTable parseCSV(String text, {int maxRows = 10000}) {
  final lines = text.replaceFirst('﻿', '').replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) throw ImportError('Arquivo vazio.');
  if (lines.length - 1 > maxRows) throw ImportError('Limite de $maxRows linhas por importação.');
  final delimiter = detectDelimiter(lines.first);
  final headers = parseCSVLine(lines.first, delimiter).map((h) => h.trim()).toList();
  final rows = lines.skip(1).map((l) => parseCSVLine(l, delimiter)).toList();
  return CSVTable(headers, rows, delimiter);
}

String normalizeHeader(String h) => normalizeText(h.trim()).replaceAll(RegExp(r'[^a-z0-9]+'), '_');

class ColumnMapping {
  const ColumnMapping({this.date, this.description, this.amount, this.type, this.category, this.account, this.notes});
  final int? date;
  final int? description;
  final int? amount;
  final int? type;
  final int? category;
  final int? account;
  final int? notes;
  Map<String, dynamic> toJson() => {if (date != null) 'date': date, if (description != null) 'description': description, if (amount != null) 'amount': amount, if (type != null) 'type': type, if (category != null) 'category': category, if (account != null) 'account': account, if (notes != null) 'notes': notes};
  ColumnMapping copyWith({int? date, int? description, int? amount, int? type, int? category, int? account, int? notes}) => ColumnMapping(date: date ?? this.date, description: description ?? this.description, amount: amount ?? this.amount, type: type ?? this.type, category: category ?? this.category, account: account ?? this.account, notes: notes ?? this.notes);
}

ColumnMapping guessColumnMapping(List<String> headers) {
  final n = headers.map(normalizeHeader).toList();
  int? find(List<String> cands) {
    final i = n.indexWhere((h) => cands.any((c) => h == c || h.startsWith(c)));
    return i >= 0 ? i : null;
  }
  return ColumnMapping(date: find(['data', 'date', 'dt', 'data_lancamento', 'data_da_transacao']), description: find(['descricao', 'description', 'historico', 'memo', 'estabelecimento', 'titulo', 'title', 'lancamento']), amount: find(['valor', 'amount', 'value', 'montante', 'quantia']), type: find(['tipo', 'type', 'natureza']), category: find(['categoria', 'category']), account: find(['conta', 'account']), notes: find(['observacoes', 'observacao', 'notes', 'obs']));
}

ISODate? parseDateFlexible(String raw) {
  final s = raw.trim();
  if (isISODate(s)) return s;
  final patterns = <(RegExp, String Function(RegExpMatch))>[
    (RegExp(r'^(\d{2})/(\d{2})/(\d{4})'), (m) => '${m[3]}-${m[2]}-${m[1]}'),
    (RegExp(r'^(\d{4})-(\d{2})-(\d{2})T'), (m) => '${m[1]}-${m[2]}-${m[3]}'),
    (RegExp(r'^(\d{2})-(\d{2})-(\d{4})$'), (m) => '${m[3]}-${m[2]}-${m[1]}'),
    (RegExp(r'^(\d{2})/(\d{2})/(\d{2})$'), (m) => '20${m[3]}-${m[2]}-${m[1]}'),
  ];
  for (final (re, build) in patterns) {
    final m = re.firstMatch(s);
    if (m != null) {
      final d = build(m);
      return isISODate(d) ? d : null;
    }
  }
  return null;
}

class ImportCandidate {
  const ImportCandidate({required this.rowIndex, required this.date, required this.description, required this.amountCents, required this.kind, this.categoryName, this.notes, this.externalRef, required this.problems});
  final int rowIndex;
  final ISODate date;
  final String description;
  final Cents amountCents;
  final String kind; // income | expense
  final String? categoryName;
  final String? notes;
  final String? externalRef;
  final List<String> problems;
  Map<String, dynamic> toJson() => {'rowIndex': rowIndex, 'date': date, 'description': description, 'amountCents': amountCents, 'kind': kind, if (categoryName != null) 'categoryName': categoryName, if (notes != null) 'notes': notes, if (externalRef != null) 'externalRef': externalRef, 'problems': problems};
  factory ImportCandidate.fromJson(Map<String, dynamic> j) => ImportCandidate(rowIndex: (j['rowIndex'] as num).toInt(), date: j['date'] as String, description: j['description'] as String, amountCents: (j['amountCents'] as num).toInt(), kind: j['kind'] as String, categoryName: j['categoryName'] as String?, notes: j['notes'] as String?, externalRef: j['externalRef'] as String?, problems: (j['problems'] as List<dynamic>? ?? const []).cast<String>());
}

const _incomeWords = {'receita', 'income', 'credito', 'crédito', 'entrada', 'c'};
const _expenseWords = {'despesa', 'expense', 'debito', 'débito', 'saida', 'saída', 'd'};

List<ImportCandidate> candidatesFromCSV(CSVTable table, ColumnMapping mapping) {
  final out = <ImportCandidate>[];
  for (var i = 0; i < table.rows.length; i++) {
    final cols = table.rows[i];
    String col(int? idx) => idx == null || idx >= cols.length ? '' : cols[idx];
    final problems = <String>[];
    final date = parseDateFlexible(col(mapping.date));
    if (date == null) problems.add('Data inválida');
    var rawAmount = col(mapping.amount).replaceAll(RegExp(r'[A-Za-z$\s]'), '');
    final paren = RegExp(r'^\((.*)\)$').firstMatch(rawAmount);
    if (paren != null) rawAmount = '-${paren[1]}';
    final parsed = parseMoneyBR(rawAmount);
    if (parsed == null) problems.add('Valor inválido');
    final rawType = col(mapping.type).toLowerCase().trim();
    String kind;
    if (_incomeWords.contains(rawType)) {
      kind = 'income';
    } else if (_expenseWords.contains(rawType)) {
      kind = 'expense';
    } else {
      kind = 'expense';
    }
    if (rawType.isEmpty && (parsed ?? 0) > 0 && mapping.type == null) kind = 'income';
    final desc = col(mapping.description).trim();
    final cat = col(mapping.category).trim();
    final notes = col(mapping.notes).trim();
    out.add(ImportCandidate(rowIndex: i, date: date ?? '0000-00-00', description: desc.length > 140 ? desc.substring(0, 140) : desc, amountCents: (parsed ?? 0).abs(), kind: kind, categoryName: mapping.category != null && cat.isNotEmpty ? cat : null, notes: mapping.notes != null && notes.isNotEmpty ? notes : null, problems: problems));
  }
  return out;
}

String _csvEscape(Object? v) {
  final s = (v ?? '').toString();
  return RegExp(r'[";\n]').hasMatch(s) ? '"${s.replaceAll('"', '""')}"' : s;
}

const _kindPt = {TransactionKind.income: 'receita', TransactionKind.expense: 'despesa', TransactionKind.transfer: 'transferencia', TransactionKind.cardPurchase: 'compra_cartao', TransactionKind.cardPayment: 'pagamento_fatura', TransactionKind.goalDeposit: 'deposito_reserva', TransactionKind.goalWithdrawal: 'resgate_reserva', TransactionKind.loanDisbursement: 'entrada_emprestimo', TransactionKind.loanPayment: 'parcela_emprestimo', TransactionKind.balanceAdjustment: 'ajuste_saldo', TransactionKind.cardRefund: 'estorno_cartao'};
const _statusPt = {TransactionStatus.planned: 'previsto', TransactionStatus.settled: 'efetivado', TransactionStatus.partiallyPaid: 'parcial', TransactionStatus.cancelled: 'cancelado'};

/// pt-BR friendly CSV (semicolon, BOM, comma decimals). Identical to the TypeScript exporter.
String exportTransactionsCSV(Ledger ledger, List<Transaction> transactions) {
  String name(Iterable<({String id, String name})> list, String? id) => list.where((x) => x.id == id).map((x) => x.name).firstOrNull ?? '';
  final accounts = ledger.accounts.map((a) => (id: a.id, name: a.name));
  final categories = ledger.categories.map((a) => (id: a.id, name: a.name));
  final cards = ledger.cards.map((a) => (id: a.id, name: a.name));
  final tags = ledger.tags.map((a) => (id: a.id, name: a.name));
  const header = ['data', 'tipo', 'descricao', 'categoria', 'conta', 'conta_destino', 'cartao', 'valor', 'situacao', 'vencimento', 'parcela', 'tags', 'observacoes'];
  final rows = transactions.map((t) => [t.date, _kindPt[t.kind], t.description, name(categories, t.categoryId), name(accounts, t.accountId), name(accounts, t.toAccountId), name(cards, t.cardId), '${t.amountCents ~/ 100},${(t.amountCents % 100).toString().padLeft(2, '0')}', _statusPt[t.status], t.dueDate ?? '', t.installment != null ? '${t.installment!.number}/${t.installment!.of}' : '', t.tags.map((id) => name(tags, id)).join('|'), t.notes ?? ''].map(_csvEscape).join(';'));
  return '﻿${[header.join(';'), ...rows].join('\r\n')}';
}
