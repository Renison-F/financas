/// Budgets and the month rhythm (sereno / atenção / agitado). Mirrors `budgets.ts`.
library;

import '../dates/dates.dart';
import '../entities/entities.dart';
import '../ledger/ledger.dart';
import '../money/money.dart';

enum PaceStatus { sereno, atencao, agitado }

class BudgetStatus {
  const BudgetStatus({
    required this.budget,
    this.category,
    required this.month,
    required this.limitCents,
    required this.spentCents,
    required this.plannedCents,
    required this.remainingCents,
    required this.percentUsed,
    required this.expectedPercent,
    required this.pace,
  });
  final Budget budget;
  final Category? category;
  final MonthKey month;
  final Cents limitCents;
  final Cents spentCents;
  final Cents plannedCents;
  final Cents remainingCents;
  final double percentUsed;
  final double expectedPercent;
  final PaceStatus pace;
  Map<String, dynamic> toJson() => {
    'budget': budget.id,
    'category': category?.id,
    'month': month,
    'limitCents': limitCents,
    'spentCents': spentCents,
    'plannedCents': plannedCents,
    'remainingCents': remainingCents,
    'percentUsed': percentUsed,
    'expectedPercent': expectedPercent,
    'pace': pace.name,
  };
}

/// Month-specific budget first, then the template.
Budget? budgetFor(Ledger ledger, Id? categoryId, MonthKey month) {
  final candidates = ledger.budgets
      .where((b) => b.deletedAt == null && b.categoryId == categoryId)
      .toList();
  return candidates.where((b) => b.month == month).firstOrNull ??
      candidates.where((b) => b.month == null).firstOrNull;
}

bool _categoryMatches(Ledger ledger, Transaction t, Id categoryId) {
  if (t.categoryId == categoryId) return true;
  return ledger.categoryById(t.categoryId)?.parentId ==
      categoryId; // subcategory rolls into parent
}

({Cents spentCents, Cents plannedCents}) spentInMonth(
  Ledger ledger,
  MonthKey month, [
  Id? categoryId,
]) {
  var spent = 0, planned = 0;
  for (final t in ledger.transactions) {
    if (!isActive(t) || !isExpenseLike(t) || monthKeyOf(t.date) != month) {
      continue;
    }
    if (categoryId != null && !_categoryMatches(ledger, t, categoryId)) {
      continue;
    }
    if (t.kind == TransactionKind.cardPurchase) {
      spent = addCents(spent, t.amountCents);
    } else if (t.kind == TransactionKind.cardRefund) {
      spent = subCents(spent, t.amountCents);
    } else {
      spent = addCents(spent, effectiveCents(t));
      planned = addCents(planned, t.amountCents - effectiveCents(t));
    }
  }
  return (spentCents: spent, plannedCents: planned);
}

PaceStatus pace(double percentUsed, double expectedPercent) {
  if (percentUsed > 100 || percentUsed > expectedPercent + 10) {
    return PaceStatus.agitado;
  }
  if (percentUsed > expectedPercent) return PaceStatus.atencao;
  return PaceStatus.sereno;
}

double _round1(double v) => (v * 10).roundToDouble() / 10;

double monthElapsedPercent(MonthKey month, ISODate today) {
  final p = parts(today);
  final y = int.parse(month.substring(0, 4));
  final m = int.parse(month.substring(5, 7));
  if (p.year > y || (p.year == y && p.month > m)) return 100;
  if (p.year < y || (p.year == y && p.month < m)) return 0;
  return _round1(p.day / daysInMonth(y, m) * 100);
}

BudgetStatus budgetStatus(
  Ledger ledger,
  Budget budget,
  MonthKey month,
  ISODate today,
) {
  final s = spentInMonth(ledger, month, budget.categoryId);
  final percentUsed = budget.limitCents > 0
      ? _round1(s.spentCents / budget.limitCents * 100)
      : 0.0;
  final expected = monthElapsedPercent(month, today);
  return BudgetStatus(
    budget: budget,
    category: ledger.categoryById(budget.categoryId),
    month: month,
    limitCents: budget.limitCents,
    spentCents: s.spentCents,
    plannedCents: s.plannedCents,
    remainingCents: budget.limitCents - s.spentCents,
    percentUsed: percentUsed,
    expectedPercent: expected,
    pace: pace(percentUsed, expected),
  );
}

/// All budgets that apply to a month (month-specific override templates); global first, then by usage desc.
List<BudgetStatus> budgetsForMonth(
  Ledger ledger,
  MonthKey month,
  ISODate today,
) {
  final indexed = ledger.budgets
      .where((b) => b.deletedAt == null)
      .toList()
      .asMap()
      .entries
      .toList();
  // stable: month-specific first, original order otherwise
  indexed.sort((a, b) {
    final d =
        (a.value.month != null ? -1 : 0) - (b.value.month != null ? -1 : 0);
    return d != 0 ? d : a.key.compareTo(b.key);
  });
  final keys = <String>{};
  final out = <BudgetStatus>[];
  for (final e in indexed) {
    final b = e.value;
    if (b.month != null && b.month != month) continue;
    final key = b.categoryId ?? '__global__';
    if (!keys.add(key)) continue;
    out.add(budgetStatus(ledger, b, month, today));
  }
  final withIndex = out.asMap().entries.toList();
  withIndex.sort((a, b) {
    final d =
        (a.value.budget.categoryId != null ? 1 : 0) -
        (b.value.budget.categoryId != null ? 1 : 0);
    if (d != 0) return d;
    final p = b.value.percentUsed.compareTo(a.value.percentUsed);
    return p != 0 ? p : a.key.compareTo(b.key);
  });
  return withIndex.map((e) => e.value).toList();
}

Cents totalBudgetedCents(List<BudgetStatus> statuses) => sumCents(
  statuses.where((s) => s.budget.categoryId != null).map((s) => s.limitCents),
);
