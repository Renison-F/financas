/// Importer for the legacy single-file app backup (internal compatibility id `pouso-financas-v2`; the old name
/// never appears in the UI). Floats are converted to cents exactly once, here. Mirrors `io/legacy.ts`.
library;

import '../cards/cards.dart';
import '../dates/dates.dart';
import '../entities/entities.dart';
import '../money/money.dart';

class LegacyImportResult {
  const LegacyImportResult(this.ledger, this.warnings, this.counts);
  final Ledger ledger;
  final List<String> warnings;
  final Map<String, int> counts;
}

bool isLegacyBackup(Object? x) => x is Map<String, dynamic> && x['transactions'] is List && x['accounts'] is List && !x.containsKey('schemaVersion');

const _accountTypes = {'cash': 'cash', 'bank': 'checking', 'checking': 'checking', 'savings': 'savings', 'wallet': 'digital_wallet', 'digital': 'digital_wallet', 'investment': 'investment'};
const _kindMap = {'income': 'income', 'expense': 'expense', 'transfer': 'transfer', 'card_expense': 'card_purchase', 'card_payment': 'card_payment', 'goal_deposit': 'goal_deposit', 'goal_withdraw': 'goal_withdrawal', 'loan_payment': 'loan_payment', 'loan_in': 'loan_disbursement'};

LegacyImportResult importLegacyBackup(Map<String, dynamic> raw, {String? now}) {
  final ts = now ?? DateTime.now().toUtc().toIso8601String();
  final warnings = <String>[];
  int safeCents(Object? n, String what) {
    final v = n is num ? n.toDouble() : double.tryParse(n?.toString() ?? '');
    if (v == null || !v.isFinite) {
      warnings.push('Valor inválido em $what; usado 0.');
      return 0;
    }
    return cents(v);
  }
  String? s(Object? v) => v == null ? null : v.toString();
  int clampDay(Object? v, int def) => (int.tryParse(s(v) ?? '') ?? def).clamp(1, 31);
  List<Map<String, dynamic>> list(String k) => (raw[k] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().toList();

  final accounts = <Account>[];
  for (final (i, a) in list('accounts').indexed) {
    final name = (s(a['name']) ?? 'Conta');
    accounts.add(Account(id: s(a['id'])!, name: name.length > 70 ? name.substring(0, 70) : name, type: _accountTypes[s(a['type']) ?? ''] ?? 'other', currency: 'BRL', openingBalanceCents: safeCents(a['balance'] ?? 0, 'conta $name'), openingDate: '1970-01-01', color: s(a['color']) ?? '#0B5563', archived: false, includeInAvailability: true, sortOrder: i, createdAt: ts, updatedAt: ts));
  }
  final categories = [for (final (i, c) in list('categories').indexed) Category(id: s(c['id'])!, name: s(c['name']) ?? '', kind: c['type'] == 'income' ? 'income' : 'expense', icon: 'tag', color: s(c['color']) ?? '#4F5E61', archived: false, sortOrder: i, createdAt: ts, updatedAt: ts)];
  final tags = [for (final t in list('tags')) Tag(id: s(t['id'])!, name: s(t['name']) ?? '', color: s(t['color']) ?? '#4F5E61', createdAt: ts, updatedAt: ts)];
  final cards = [for (final c in list('cards')) CreditCard(id: s(c['id'])!, name: s(c['name']) ?? '', limitCents: safeCents(c['limit'] ?? 0, 'cartão ${s(c['name'])}'), closingDay: clampDay(c['closing'], 20), dueDay: clampDay(c['due'], 10), color: s(c['color']) ?? '#0B5563', archived: false, currency: 'BRL', createdAt: ts, updatedAt: ts)];
  final budgets = [for (final b in list('budgets')) Budget(id: s(b['id'])!, categoryId: s(b['categoryId']), limitCents: safeCents(b['limit'], 'orçamento'), rollover: false, createdAt: ts, updatedAt: ts)];
  final goals = [for (final g in list('goals')) Goal(id: s(g['id'])!, name: s(g['name']) ?? '', kind: 'savings', targetCents: safeCents(g['target'], 'meta ${s(g['name'])}'), targetDate: isISODate(g['deadline']) ? s(g['deadline']) : null, reserved: true, color: s(g['color']) ?? '#0B5563', archived: false, createdAt: ts, updatedAt: ts)];
  final loans = [for (final l in list('loans')) Loan(id: s(l['id'])!, name: s(l['name']) ?? 'Empréstimo', principalCents: safeCents(l['principal'], 'empréstimo'), monthlyRatePercent: (l['rate'] is num) ? (l['rate'] as num).toDouble() : 0, termMonths: (int.tryParse(s(l['months']) ?? '') ?? 1).clamp(1, 1 << 30), system: 'price', firstDueDate: isISODate(l['firstDue']) ? s(l['firstDue'])! : isISODate(l['start']) ? s(l['start'])! : '1970-01-01', monthlyFeeCents: 0, upfrontFeesCents: 0, archived: false, createdAt: ts, updatedAt: ts)];

  final transactions = <Transaction>[];
  for (final t in list('transactions')) {
    final kindWire = _kindMap[s(t['type']) ?? ''];
    final date = s(t['date']) ?? '';
    if (kindWire == null || !isISODate(date)) {
      warnings.add('Lançamento ignorado (tipo ou data inválidos): ${s(t['description']) ?? s(t['id'])}');
      continue;
    }
    final kind = kindFromWire(kindWire);
    final card = t['cardId'] == null ? null : cards.where((c) => c.id == s(t['cardId'])).firstOrNull;
    final paid = t['paid'] != false;
    final desc = s(t['description']) ?? '';
    final memo = s(t['memo']);
    transactions.add(Transaction(
      id: s(t['id'])!, kind: kind, amountCents: safeCents(t['amount'], 'lançamento $desc'), currency: 'BRL', date: date, description: desc.length > 140 ? desc.substring(0, 140) : desc,
      categoryId: s(t['categoryId']), accountId: s(t['accountId']), toAccountId: s(t['toAccountId']), cardId: s(t['cardId']), goalId: s(t['goalId']), loanId: s(t['loanId']),
      status: kind == TransactionKind.cardPurchase ? TransactionStatus.settled : paid ? TransactionStatus.settled : TransactionStatus.planned,
      seriesId: s(t['seriesId']), invoiceMonth: kind == TransactionKind.cardPayment && t['invoiceKey'] is String ? t['invoiceKey'] as String : kind == TransactionKind.cardPurchase && card != null ? invoiceMonthFor(card.closingDay, date) : null,
      tags: (t['tags'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(), notes: memo == null ? null : (memo.length > 500 ? memo.substring(0, 500) : memo), externalRef: 'legacy:${s(t['id'])}', createdAt: ts, updatedAt: ts,
    ));
  }
  final prefsRaw = raw['prefs'] is Map<String, dynamic> ? raw['prefs'] as Map<String, dynamic> : const <String, dynamic>{};
  var prefs = const UserPrefs();
  if (prefsRaw['safetyCushion'] is num) prefs = prefs.copyWith(safetyCushionCents: cents((prefsRaw['safetyCushion'] as num).toDouble()));
  if (prefsRaw['theme'] == 'dark' || prefsRaw['theme'] == 'light') prefs = prefs.copyWith(theme: prefsRaw['theme'] as String);
  final ledger = Ledger(accounts: accounts, categories: categories, tags: tags, cards: cards, transactions: transactions, budgets: budgets, goals: goals, loans: loans, prefs: prefs);
  return LegacyImportResult(ledger, warnings, {'accounts': accounts.length, 'categories': categories.length, 'cards': cards.length, 'transactions': transactions.length, 'budgets': budgets.length, 'goals': goals.length, 'loans': loans.length, 'tags': tags.length});
}

extension on List<String> {
  void push(String s) => add(s);
}
