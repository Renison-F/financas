/// One computation of everything the dashboard widgets show, from the pure domain (port of `useDashboardData`).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/assistant/assistant.dart';
import '../../domain/availability/availability.dart';
import '../../domain/budgets/budgets.dart';
import '../../domain/cards/cards.dart';
import '../../domain/dashboard/widgets.dart';
import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/goals/goals.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/loans/loans.dart';
import '../../domain/reports/reports.dart';
import 'app_controller.dart';

class CardView {
  const CardView({
    required this.card,
    required this.invoice,
    required this.commitment,
  });
  final CreditCard card;
  final Invoice invoice;
  final CardCommitment commitment;
}

class DashboardData {
  const DashboardData({
    required this.month,
    required this.today,
    required this.horizonEnd,
    required this.availability,
    required this.totals,
    required this.consolidated,
    required this.accounts,
    required this.bills,
    required this.overdue,
    required this.next7,
    required this.cards,
    required this.installmentsFuture,
    required this.budgets,
    required this.globalBudget,
    required this.categories,
    required this.cashflow,
    required this.goals,
    required this.recurring,
    required this.loans,
    required this.recent,
    required this.recommendations,
    required this.netWorth,
    required this.months,
    required this.listCount,
    required this.finishedSessions,
    required this.hasTransactions,
  });
  final String month, today, horizonEnd;
  final Availability availability;
  final MonthTotals totals;
  final int consolidated;
  final List<({Account account, int balance})> accounts;
  final List<Transaction> bills, overdue, next7, recent;
  final List<CardView> cards;
  final int installmentsFuture;
  final List<BudgetStatus> budgets;
  final BudgetStatus? globalBudget;
  final List<CategoryTotal> categories;
  final List<CashflowPoint> cashflow;
  final List<GoalProgress> goals;
  final List<RecurringExpense> recurring;
  final List<LoanPosition> loans;
  final List<Recommendation> recommendations;
  final NetWorthPoint? netWorth;
  final List<String> months;
  final int listCount, finishedSessions;
  final bool hasTransactions;
}

DashboardData computeDashboard(
  Ledger ledger,
  DashboardLayout layout,
  String today,
  int listCount,
  int finishedSessions,
) {
  final month =
      layout.period == 'selected_month' && layout.selectedMonth != null
      ? layout.selectedMonth!
      : monthKeyOf(today);
  final horizonEnd = layout.period == 'last_30_days'
      ? addDays(today, 30)
      : endOfMonth(month);
  final accountIds = layout.accountIds;
  final av = availability(
    ledger,
    today: today,
    accountIds: accountIds,
    horizonEnd: horizonEnd,
  );
  final totals = monthTotals(ledger, month);
  final accounts = activeAccounts(ledger)
      .where((a) => accountIds == null || accountIds.contains(a.id))
      .toList();
  final cards = ledger.cards.where((c) => c.isActive).map((c) {
    final m = currentInvoiceMonth(c, today);
    return CardView(
      card: c,
      invoice: invoice(ledger, c, m, today),
      commitment: cardCommitment(ledger, c, today),
    );
  }).toList();
  final budgets = budgetsForMonth(ledger, month, today);
  final recent =
      ledger.transactions
          .where(
            (t) =>
                t.deletedAt == null && t.status != TransactionStatus.cancelled,
          )
          .toList()
        ..sort(
          (a, b) => (b.date + b.createdAt).compareTo(a.date + a.createdAt),
        );
  final nw = netWorth(ledger, month, 1, today);
  return DashboardData(
    month: month,
    today: today,
    horizonEnd: horizonEnd,
    availability: av,
    totals: totals,
    consolidated: consolidatedBalance(ledger, accountIds: accountIds),
    accounts: accounts
        .map((a) => (account: a, balance: accountBalance(ledger, a.id)))
        .toList(),
    bills: upcoming(ledger, today, horizonEnd),
    overdue: overdue(ledger, today),
    next7: upcoming(ledger, today, addDays(today, 7)),
    cards: cards,
    installmentsFuture: cards.fold(0, (a, c) => a + c.commitment.futureCents),
    budgets: budgets,
    globalBudget: budgets.where((b) => b.budget.categoryId == null).firstOrNull,
    categories: expensesByCategory(
      ledger,
      month,
      rollUp: true,
    ).take(6).toList(),
    cashflow: cashflow(ledger, month, 6),
    goals: ledger.goals
        .where((g) => !g.archived && g.deletedAt == null)
        .map((g) => goalProgress(ledger, g, today))
        .toList(),
    recurring: recurringExpenses(ledger, month),
    loans: ledger.loans
        .where((l) => !l.archived && l.deletedAt == null)
        .map((l) => loanPosition(ledger, l, today))
        .toList(),
    recent: recent.take(5).toList(),
    recommendations: recommendations(ledger, today).take(3).toList(),
    netWorth: nw.isEmpty ? null : nw.first,
    months: lastMonthKeys(month, 6),
    listCount: listCount,
    finishedSessions: finishedSessions,
    hasTransactions: ledger.transactions.isNotEmpty,
  );
}

final dashboardDataProvider = Provider<DashboardData?>((ref) {
  final s = ref.watch(appControllerProvider).value;
  if (s == null) return null;
  return computeDashboard(
    s.ledger,
    s.layout,
    s.today,
    s.shoppingLists.where((l) => !l.archived).length,
    s.sessions.where((x) => x.status == 'finished').length,
  );
});
