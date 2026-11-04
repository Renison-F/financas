/// Reports: categories, cash flow, comparisons, year summary, recurring, projection, net worth, search.
/// Mirrors `reports.ts`.
library;

import '../cards/cards.dart';
import '../dates/dates.dart';
import '../entities/entities.dart';
import '../goals/goals.dart';
import '../ledger/ledger.dart';
import '../loans/loans.dart';
import '../money/money.dart';
import '../text/normalize.dart';

double _round1(double v) => (v * 10).roundToDouble() / 10;

class CategoryTotal {
  const CategoryTotal({this.categoryId, required this.name, required this.color, required this.cents, required this.percent, required this.count});
  final Id? categoryId;
  final String name;
  final String color;
  final Cents cents;
  final double percent;
  final int count;
  Map<String, dynamic> toJson() => {'categoryId': categoryId, 'name': name, 'color': color, 'cents': cents, 'percent': percent, 'count': count};
}

/// Expenses by category for a month (settled + card purchases − refunds). Subcategories may roll up to parents.
List<CategoryTotal> expensesByCategory(Ledger ledger, MonthKey month, {bool rollUp = false, bool includePlanned = false}) {
  final map = <Id?, ({int cents, int count})>{};
  final order = <Id?>[];
  for (final t in ledger.transactions) {
    if (!isActive(t) || !isExpenseLike(t) || monthKeyOf(t.date) != month) continue;
    final cents = t.kind == TransactionKind.cardPurchase ? t.amountCents : t.kind == TransactionKind.cardRefund ? -t.amountCents : includePlanned ? t.amountCents : effectiveCents(t);
    if (cents == 0) continue;
    var key = t.categoryId;
    if (rollUp && key != null) {
      final parent = ledger.categoryById(key)?.parentId;
      if (parent != null) key = parent;
    }
    final cur = map[key];
    if (cur == null) order.add(key);
    map[key] = (cents: addCents(cur?.cents ?? 0, cents), count: (cur?.count ?? 0) + 1);
  }
  final total = sumCents(map.values.map((v) => v.cents));
  final list = order.map((k) {
    final v = map[k]!;
    final cat = ledger.categoryById(k);
    return CategoryTotal(categoryId: k, name: cat?.name ?? 'Sem categoria', color: cat?.color ?? '#5B6670', cents: v.cents, percent: total != 0 ? _round1(v.cents / total * 100) : 0, count: v.count);
  }).toList();
  final idx = list.asMap().entries.toList()..sort((a, b) { final d = b.value.cents.compareTo(a.value.cents); return d != 0 ? d : a.key.compareTo(b.key); });
  return idx.map((e) => e.value).toList();
}

class CashflowPoint {
  const CashflowPoint(this.totals, this.balanceEnd);
  final MonthTotals totals;
  final Cents balanceEnd;
  Map<String, dynamic> toJson() => {...totals.toJson(), 'balanceEnd': balanceEnd};
}

List<CashflowPoint> cashflow(Ledger ledger, MonthKey endMonth, int months) => lastMonthKeys(endMonth, months).map((m) => CashflowPoint(monthTotals(ledger, m), consolidatedBalance(ledger, asOf: endOfMonth(m)))).toList();

class Comparison {
  const Comparison({required this.current, required this.previous, required this.incomeDeltaCents, required this.expenseDeltaCents, this.expenseDeltaPercent});
  final MonthTotals current;
  final MonthTotals previous;
  final Cents incomeDeltaCents;
  final Cents expenseDeltaCents;
  final double? expenseDeltaPercent;
  Map<String, dynamic> toJson() => {'current': current.toJson(), 'previous': previous.toJson(), 'incomeDeltaCents': incomeDeltaCents, 'expenseDeltaCents': expenseDeltaCents, 'expenseDeltaPercent': expenseDeltaPercent};
}

Comparison compareMonths(Ledger ledger, MonthKey month, [MonthKey? against]) {
  final current = monthTotals(ledger, month);
  final previous = monthTotals(ledger, against ?? addMonthsToKey(month, -1));
  final expenseDelta = current.expenseSettled - previous.expenseSettled;
  return Comparison(current: current, previous: previous, incomeDeltaCents: current.incomeSettled - previous.incomeSettled, expenseDeltaCents: expenseDelta, expenseDeltaPercent: previous.expenseSettled != 0 ? _round1(expenseDelta / previous.expenseSettled * 100) : null);
}

class YearSummary {
  const YearSummary({required this.year, required this.months, required this.incomeCents, required this.expenseCents, required this.netCents, this.bestMonth, this.worstMonth});
  final int year;
  final List<MonthTotals> months;
  final Cents incomeCents;
  final Cents expenseCents;
  final Cents netCents;
  final MonthKey? bestMonth;
  final MonthKey? worstMonth;
  Map<String, dynamic> toJson() => {'year': year, 'months': months.map((m) => m.toJson()).toList(), 'incomeCents': incomeCents, 'expenseCents': expenseCents, 'netCents': netCents, if (bestMonth != null) 'bestMonth': bestMonth, if (worstMonth != null) 'worstMonth': worstMonth};
}

YearSummary yearSummary(Ledger ledger, int year) {
  final months = [for (var i = 1; i <= 12; i++) monthTotals(ledger, monthKey(year, i))];
  final income = sumCents(months.map((m) => m.incomeSettled));
  final expense = sumCents(months.map((m) => m.expenseSettled));
  final withData = months.where((m) => m.incomeSettled != 0 || m.expenseSettled != 0).toList();
  MonthTotals? best, worst;
  for (final m in withData) {
    if (best == null || m.net > best.net) best = m;
    if (worst == null || m.net < worst.net) worst = m;
  }
  return YearSummary(year: year, months: months, incomeCents: income, expenseCents: expense, netCents: income - expense, bestMonth: best?.month, worstMonth: worst?.month);
}

class RecurringExpense {
  const RecurringExpense({required this.key, required this.description, required this.amountCents, required this.months, this.seriesId});
  final String key;
  final String description;
  final Cents amountCents;
  final List<MonthKey> months;
  final Id? seriesId;
  Map<String, dynamic> toJson() => {'key': key, 'description': description, 'amountCents': amountCents, 'months': months, if (seriesId != null) 'seriesId': seriesId};
}

/// Recurring expenses: by series, or repeated description+amount across ≥3 of the last `lookback` months.
List<RecurringExpense> recurringExpenses(Ledger ledger, MonthKey endMonth, {int lookback = 6}) {
  final window = lastMonthKeys(endMonth, lookback).toSet();
  final groups = <String, ({String description, int amountCents, Set<MonthKey> months, Id? seriesId})>{};
  final order = <String>[];
  for (final t in ledger.transactions) {
    if (!isActive(t) || !isExpenseLike(t) || !window.contains(monthKeyOf(t.date))) continue;
    final key = t.seriesId ?? '${t.description.trim().toLowerCase()}|${t.amountCents}';
    final g = groups[key];
    if (g == null) {
      order.add(key);
      groups[key] = (description: t.description, amountCents: t.amountCents, months: {monthKeyOf(t.date)}, seriesId: t.seriesId);
    } else {
      g.months.add(monthKeyOf(t.date));
    }
  }
  final list = order.map((k) => groups[k]!).where((g) => g.seriesId != null || g.months.length >= 3).map((g) => RecurringExpense(key: order.firstWhere((k) => groups[k] == g), description: g.description, amountCents: g.amountCents, months: g.months.toList()..sort(), seriesId: g.seriesId)).toList();
  final idx = list.asMap().entries.toList()..sort((a, b) { final d = b.value.amountCents.compareTo(a.value.amountCents); return d != 0 ? d : a.key.compareTo(b.key); });
  return idx.map((e) => e.value).toList();
}

class ProjectionPoint {
  const ProjectionPoint({required this.date, required this.label, required this.cents, required this.balanceAfterCents, required this.kind});
  final ISODate date;
  final String label;
  final Cents cents;
  final Cents balanceAfterCents;
  final String kind; // income | expense | card | loan
  Map<String, dynamic> toJson() => {'date': date, 'label': label, 'cents': cents, 'kind': kind, 'balanceAfterCents': balanceAfterCents};
}

class Projection {
  const Projection({required this.startCents, required this.endCents, required this.minCents, required this.minDate, required this.points});
  final Cents startCents;
  final Cents endCents;
  final Cents minCents;
  final ISODate minDate;
  final List<ProjectionPoint> points;
  Map<String, dynamic> toJson() => {'startCents': startCents, 'endCents': endCents, 'minCents': minCents, 'minDate': minDate, 'points': points.map((p) => p.toJson()).toList()};
}

/// Projected balance until `until`: planned incomes/expenses, loan installments and invoice due dates, in date order.
Projection projectBalance(Ledger ledger, ISODate today, ISODate until) {
  final start = consolidatedBalance(ledger);
  final events = <({ISODate date, String label, int cents, String kind})>[];
  for (final t in ledger.transactions) {
    if (!isPlanned(t)) continue;
    final d = t.effectiveDate;
    if (compareISO(d, until) > 0) continue;
    if (isIncomeLike(t)) {
      events.add((date: d, label: t.description.isEmpty ? 'Receita prevista' : t.description, cents: pendingCents(t), kind: 'income'));
    } else if (t.kind == TransactionKind.expense || t.kind == TransactionKind.loanPayment) {
      events.add((date: d, label: t.description.isEmpty ? 'Despesa prevista' : t.description, cents: -pendingCents(t), kind: t.kind == TransactionKind.loanPayment ? 'loan' : 'expense'));
    }
  }
  for (final card in ledger.cards.where((c) => c.isActive)) {
    for (final m in invoiceMonths(ledger, card)) {
      final inv = invoice(ledger, card, m, today);
      if (inv.remainingCents > 0 && compareISO(inv.dueDate, until) <= 0) {
        events.add((date: compareISO(inv.dueDate, today) < 0 ? today : inv.dueDate, label: 'Fatura ${card.name}', cents: -inv.remainingCents, kind: 'card'));
      }
    }
  }
  final idx = events.asMap().entries.toList()..sort((a, b) { final d = compareISO(a.value.date, b.value.date); return d != 0 ? d : a.key.compareTo(b.key); });
  var bal = start, minCents = start;
  var minDate = today;
  final points = <ProjectionPoint>[];
  for (final e in idx.map((x) => x.value)) {
    bal = addCents(bal, e.cents);
    if (bal < minCents) {
      minCents = bal;
      minDate = e.date;
    }
    points.add(ProjectionPoint(date: e.date, label: e.label, cents: e.cents, balanceAfterCents: bal, kind: e.kind));
  }
  return Projection(startCents: start, endCents: bal, minCents: minCents, minDate: minDate, points: points);
}

class NetWorthPoint {
  const NetWorthPoint({required this.month, required this.assetsCents, required this.debtsCents, required this.netCents});
  final MonthKey month;
  final Cents assetsCents;
  final Cents debtsCents;
  final Cents netCents;
  Map<String, dynamic> toJson() => {'month': month, 'assetsCents': assetsCents, 'debtsCents': debtsCents, 'netCents': netCents};
}

List<NetWorthPoint> netWorth(Ledger ledger, MonthKey endMonth, int months, ISODate today) => lastMonthKeys(endMonth, months).map((m) {
      final asOf = compareISO(endOfMonth(m), today) < 0 ? endOfMonth(m) : today;
      final assets = consolidatedBalance(ledger, asOf: asOf) + sumCents(ledger.goals.where((g) => g.accountId == null && !g.archived).map((g) => goalSavedCents(ledger, g.id)));
      final cardDebt = sumCents(ledger.cards.where((c) => !c.archived).map((c) => cardCommitment(ledger, c, asOf).outstandingCents));
      final loanDebt = sumCents(ledger.loans.where((l) => !l.archived).map((l) => loanPosition(ledger, l, asOf).outstandingCents));
      return NetWorthPoint(month: m, assetsCents: assets, debtsCents: cardDebt + loanDebt, netCents: assets - cardDebt - loanDebt);
    }).toList();

class SearchFilters {
  const SearchFilters({this.kinds, this.categoryIds, this.accountIds, this.cardIds, this.tagIds, this.from, this.to, this.status, this.minCents, this.maxCents});
  final List<TransactionKind>? kinds;
  final List<Id>? categoryIds;
  final List<Id>? accountIds;
  final List<Id>? cardIds;
  final List<Id>? tagIds;
  final ISODate? from;
  final ISODate? to;
  final List<TransactionStatus>? status;
  final Cents? minCents;
  final Cents? maxCents;
}

List<Transaction> searchTransactions(Ledger ledger, String query, [SearchFilters f = const SearchFilters()]) {
  final q = normalizeText(query.trim());
  final list = ledger.transactions.where((t) {
    if (!isActive(t) && !(f.status?.contains(TransactionStatus.cancelled) ?? false)) return false;
    if (q.isNotEmpty && !normalizeText(t.description).contains(q) && !normalizeText(t.notes ?? '').contains(q) && !normalizeText(t.merchant ?? '').contains(q)) return false;
    if (f.kinds != null && !f.kinds!.contains(t.kind)) return false;
    if (f.categoryIds != null && !f.categoryIds!.contains(t.categoryId ?? '')) return false;
    if (f.accountIds != null && !f.accountIds!.contains(t.accountId ?? '') && !f.accountIds!.contains(t.toAccountId ?? '')) return false;
    if (f.cardIds != null && !f.cardIds!.contains(t.cardId ?? '')) return false;
    if (f.tagIds != null && !t.tags.any((id) => f.tagIds!.contains(id))) return false;
    if (f.from != null && compareISO(t.date, f.from!) < 0) return false;
    if (f.to != null && compareISO(t.date, f.to!) > 0) return false;
    if (f.status != null && !f.status!.contains(t.status)) return false;
    if (f.minCents != null && t.amountCents < f.minCents!) return false;
    if (f.maxCents != null && t.amountCents > f.maxCents!) return false;
    return true;
  }).toList();
  final idx = list.asMap().entries.toList()..sort((a, b) { final d = compareISO(b.value.date, a.value.date); return d != 0 ? d : a.key.compareTo(b.key); });
  return idx.map((e) => e.value).toList();
}
