import { useMemo } from 'react';
import { availability, monthTotals, upcoming, overdue, budgetsForMonth, expensesByCategory, cashflow, goalProgress, cardCommitment, invoice, currentInvoiceMonth, recurringExpenses, loanPosition, recommendations, consolidatedBalance, accountBalance, activeAccounts, monthKeyOf, addDays, endOfMonth, lastMonthKeys, netWorth, type Ledger, type DashboardLayout } from '@financas/core';
import { useAppStore } from '../../state/appStore';

/** One memoized computation of everything the widgets show, from the pure domain. */
export function useDashboardData() {
  const ledger = useAppStore((s) => s.ledger);
  const layout = useAppStore((s) => s.layout);
  const today = useAppStore((s) => s.today)();
  const shoppingLists = useAppStore((s) => s.shoppingLists);
  const sessions = useAppStore((s) => s.sessions);
  return useMemo(() => compute(ledger, layout, today, shoppingLists.length, sessions.filter((s) => s.status === 'finished').length), [ledger, layout, today, shoppingLists.length, sessions]);
}

function compute(ledger: Ledger, layout: DashboardLayout, today: string, listCount: number, finishedSessions: number) {
  const month = layout.period === 'selected_month' && layout.selectedMonth ? layout.selectedMonth : monthKeyOf(today);
  const horizonEnd = layout.period === 'last_30_days' ? addDays(today, 30) : endOfMonth(month);
  const accountIds = layout.accountIds;
  const av = availability(ledger, { today, accountIds, horizonEnd });
  const totals = monthTotals(ledger, month);
  const accounts = activeAccounts(ledger).filter((a) => !accountIds || accountIds.includes(a.id));
  const cards = ledger.cards.filter((c) => !c.archived && !c.deletedAt).map((c) => { const m = currentInvoiceMonth(c, today); return { card: c, invoice: invoice(ledger, c, m, today), commitment: cardCommitment(ledger, c, today) }; });
  const installmentsFuture = cards.reduce((a, c) => a + c.commitment.futureCents, 0);
  const budgets = budgetsForMonth(ledger, month, today);
  return {
    month, today, horizonEnd, availability: av, totals,
    consolidated: consolidatedBalance(ledger, { accountIds }),
    accounts: accounts.map((a) => ({ account: a, balance: accountBalance(ledger, a.id) })),
    bills: upcoming(ledger, today, horizonEnd), overdue: overdue(ledger, today), next7: upcoming(ledger, today, addDays(today, 7)),
    cards, installmentsFuture, budgets, globalBudget: budgets.find((b) => !b.budget.categoryId),
    categories: expensesByCategory(ledger, month, { rollUp: true }).slice(0, 6),
    cashflow: cashflow(ledger, month, 6),
    goals: ledger.goals.filter((g) => !g.archived && !g.deletedAt).map((g) => goalProgress(ledger, g, today)),
    recurring: recurringExpenses(ledger, month),
    loans: ledger.loans.filter((l) => !l.archived && !l.deletedAt).map((l) => loanPosition(ledger, l, today)),
    recent: [...ledger.transactions].filter((t) => !t.deletedAt && t.status !== 'cancelled').sort((a, b) => (b.date + b.createdAt).localeCompare(a.date + a.createdAt)).slice(0, 5),
    recommendations: recommendations(ledger, today).slice(0, 3),
    netWorth: netWorth(ledger, month, 1, today)[0],
    months: lastMonthKeys(month, 6),
    listCount, finishedSessions,
    hasTransactions: ledger.transactions.length > 0,
  };
}
export type DashboardData = ReturnType<typeof compute>;
