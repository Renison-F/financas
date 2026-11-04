import { addCents, sumCents, type Cents } from '../money/money';
import { addMonthsToKey, compareISO, endOfMonth, lastMonthKeys, monthKeyOf, type ISODate, type MonthKey } from '../dates/dates';
import type { Category, Ledger, Transaction } from './types';
import { consolidatedBalance, isActive, isExpenseLike, isIncomeLike, effectiveCents, monthTotals, pendingCents, isPlanned, type MonthTotals } from './ledger';
import { cardCommitment, invoice, invoiceMonths } from './cards';
import { goalSavedCents } from './goals';
import { loanPosition } from './loans';

export interface CategoryTotal { categoryId: string | undefined; name: string; color: string; cents: Cents; percent: number; count: number; }

/** Expenses by category for a month (settled + card purchases). Subcategories can be rolled up to parents. */
export function expensesByCategory(ledger: Ledger, month: MonthKey, opts: { rollUp?: boolean; includePlanned?: boolean } = {}): CategoryTotal[] {
  const map = new Map<string | undefined, { cents: Cents; count: number }>();
  for (const t of ledger.transactions) {
    if (!isActive(t) || !isExpenseLike(t) || monthKeyOf(t.date) !== month) continue;
    const cents = t.kind === 'card_purchase' ? t.amountCents : opts.includePlanned ? t.amountCents : effectiveCents(t);
    if (cents === 0) continue;
    let key = t.categoryId;
    if (opts.rollUp && key) { const c = ledger.categories.find((x) => x.id === key); if (c?.parentId) key = c.parentId; }
    const cur = map.get(key) ?? { cents: 0, count: 0 };
    map.set(key, { cents: addCents(cur.cents, cents), count: cur.count + 1 });
  }
  const total = sumCents([...map.values()].map((v) => v.cents));
  return [...map.entries()].map(([categoryId, v]) => {
    const cat: Category | undefined = categoryId ? ledger.categories.find((c) => c.id === categoryId) : undefined;
    return { categoryId, name: cat?.name ?? 'Sem categoria', color: cat?.color ?? '#5B6670', cents: v.cents, percent: total ? Math.round((v.cents / total) * 1000) / 10 : 0, count: v.count };
  }).sort((a, b) => b.cents - a.cents);
}

export interface CashflowPoint extends MonthTotals { balanceEnd: Cents; }

/** Monthly cash flow for the last N months ending at `endMonth`, with the consolidated balance at each month end. */
export function cashflow(ledger: Ledger, endMonth: MonthKey, months: number): CashflowPoint[] {
  return lastMonthKeys(endMonth, months).map((m) => ({ ...monthTotals(ledger, m), balanceEnd: consolidatedBalance(ledger, { asOf: endOfMonth(m) }) }));
}

export interface Comparison { current: MonthTotals; previous: MonthTotals; incomeDeltaCents: Cents; expenseDeltaCents: Cents; expenseDeltaPercent: number | null; }

export function compareMonths(ledger: Ledger, month: MonthKey, against: MonthKey = addMonthsToKey(month, -1)): Comparison {
  const current = monthTotals(ledger, month), previous = monthTotals(ledger, against);
  const expenseDeltaCents = current.expenseSettled - previous.expenseSettled;
  return { current, previous, incomeDeltaCents: current.incomeSettled - previous.incomeSettled, expenseDeltaCents, expenseDeltaPercent: previous.expenseSettled ? Math.round((expenseDeltaCents / previous.expenseSettled) * 1000) / 10 : null };
}

export interface YearSummary { year: number; months: MonthTotals[]; incomeCents: Cents; expenseCents: Cents; netCents: Cents; bestMonth?: MonthKey | undefined; worstMonth?: MonthKey | undefined; }

export function yearSummary(ledger: Ledger, year: number): YearSummary {
  const months = Array.from({ length: 12 }, (_, i) => monthTotals(ledger, `${year}-${String(i + 1).padStart(2, '0')}`));
  const incomeCents = sumCents(months.map((m) => m.incomeSettled)), expenseCents = sumCents(months.map((m) => m.expenseSettled));
  const withData = months.filter((m) => m.incomeSettled || m.expenseSettled);
  const best = withData.length ? withData.reduce((a, b) => (b.net > a.net ? b : a)) : undefined;
  const worst = withData.length ? withData.reduce((a, b) => (b.net < a.net ? b : a)) : undefined;
  return { year, months, incomeCents, expenseCents, netCents: incomeCents - expenseCents, bestMonth: best?.month, worstMonth: worst?.month };
}

/** Recurring expenses detected by series or by repeated description+amount across ≥3 months. */
export function recurringExpenses(ledger: Ledger, endMonth: MonthKey, lookback = 6): { key: string; description: string; amountCents: Cents; months: MonthKey[]; seriesId?: string | undefined }[] {
  const window = new Set(lastMonthKeys(endMonth, lookback));
  const groups = new Map<string, { description: string; amountCents: Cents; months: Set<MonthKey>; seriesId?: string | undefined }>();
  for (const t of ledger.transactions) {
    if (!isActive(t) || !isExpenseLike(t) || !window.has(monthKeyOf(t.date))) continue;
    const key = t.seriesId ?? `${t.description.trim().toLowerCase()}|${t.amountCents}`;
    const g = groups.get(key) ?? { description: t.description, amountCents: t.amountCents, months: new Set<MonthKey>(), seriesId: t.seriesId };
    g.months.add(monthKeyOf(t.date));
    groups.set(key, g);
  }
  return [...groups.entries()].filter(([, g]) => g.seriesId || g.months.size >= 3).map(([key, g]) => ({ key, description: g.description, amountCents: g.amountCents, months: [...g.months].sort(), seriesId: g.seriesId })).sort((a, b) => b.amountCents - a.amountCents);
}

export interface ProjectionPoint { date: ISODate; label: string; cents: Cents; balanceAfterCents: Cents; kind: 'income' | 'expense' | 'card' | 'loan'; }

/** Projected balance until `until`, applying planned incomes/expenses, loan installments and invoice due dates in order. */
export function projectBalance(ledger: Ledger, today: ISODate, until: ISODate): { startCents: Cents; endCents: Cents; minCents: Cents; minDate: ISODate; points: ProjectionPoint[] } {
  const startCents = consolidatedBalance(ledger);
  const events: Omit<ProjectionPoint, 'balanceAfterCents'>[] = [];
  for (const t of ledger.transactions) {
    if (!isPlanned(t)) continue;
    const d = t.dueDate ?? t.date;
    if (compareISO(d, until) > 0) continue;
    if (isIncomeLike(t)) events.push({ date: d, label: t.description || 'Receita prevista', cents: pendingCents(t), kind: 'income' });
    else if (t.kind === 'expense' || t.kind === 'loan_payment') events.push({ date: d, label: t.description || 'Despesa prevista', cents: -pendingCents(t), kind: t.kind === 'loan_payment' ? 'loan' : 'expense' });
  }
  for (const card of ledger.cards.filter((c) => !c.archived && !c.deletedAt)) {
    for (const m of invoiceMonths(ledger, card)) {
      const inv = invoice(ledger, card, m, today);
      if (inv.remainingCents > 0 && compareISO(inv.dueDate, until) <= 0) events.push({ date: compareISO(inv.dueDate, today) < 0 ? today : inv.dueDate, label: `Fatura ${card.name}`, cents: -inv.remainingCents, kind: 'card' });
    }
  }
  events.sort((a, b) => compareISO(a.date, b.date));
  let bal = startCents, minCents = startCents, minDate = today;
  const points: ProjectionPoint[] = events.map((e) => { bal = addCents(bal, e.cents); if (bal < minCents) { minCents = bal; minDate = e.date; } return { ...e, balanceAfterCents: bal }; });
  return { startCents, endCents: bal, minCents, minDate, points };
}

export interface NetWorthPoint { month: MonthKey; assetsCents: Cents; debtsCents: Cents; netCents: Cents; }

/** Net worth evolution: accounts + goal money kept outside accounts − card outstanding − loan outstanding. */
export function netWorth(ledger: Ledger, endMonth: MonthKey, months: number, today: ISODate): NetWorthPoint[] {
  return lastMonthKeys(endMonth, months).map((m) => {
    const asOf = compareISO(endOfMonth(m), today) < 0 ? endOfMonth(m) : today;
    const assets = consolidatedBalance(ledger, { asOf }) + sumCents(ledger.goals.filter((g) => !g.accountId && !g.archived).map((g) => goalSavedCents(ledger, g.id)));
    const cardDebt = sumCents(ledger.cards.filter((c) => !c.archived).map((c) => cardCommitment(ledger, c, asOf).outstandingCents));
    const loanDebt = sumCents(ledger.loans.filter((l) => !l.archived).map((l) => loanPosition(ledger, l, asOf).outstandingCents));
    return { month: m, assetsCents: assets, debtsCents: cardDebt + loanDebt, netCents: assets - cardDebt - loanDebt };
  });
}

export function searchTransactions(ledger: Ledger, query: string, filters: { kinds?: Transaction['kind'][]; categoryIds?: string[]; accountIds?: string[]; cardIds?: string[]; tagIds?: string[]; from?: ISODate; to?: ISODate; status?: Transaction['status'][]; minCents?: Cents; maxCents?: Cents } = {}): Transaction[] {
  const q = query.trim().toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
  const norm = (s: string) => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
  return ledger.transactions.filter((t) => {
    if (!isActive(t) && !(filters.status?.includes('cancelled'))) return false;
    if (q && !norm(t.description).includes(q) && !norm(t.notes ?? '').includes(q) && !norm(t.merchant ?? '').includes(q)) return false;
    if (filters.kinds && !filters.kinds.includes(t.kind)) return false;
    if (filters.categoryIds && !filters.categoryIds.includes(t.categoryId ?? '')) return false;
    if (filters.accountIds && !filters.accountIds.includes(t.accountId ?? '') && !filters.accountIds.includes(t.toAccountId ?? '')) return false;
    if (filters.cardIds && !filters.cardIds.includes(t.cardId ?? '')) return false;
    if (filters.tagIds && !t.tags.some((id) => filters.tagIds!.includes(id))) return false;
    if (filters.from && compareISO(t.date, filters.from) < 0) return false;
    if (filters.to && compareISO(t.date, filters.to) > 0) return false;
    if (filters.status && !filters.status.includes(t.status)) return false;
    if (filters.minCents !== undefined && t.amountCents < filters.minCents) return false;
    if (filters.maxCents !== undefined && t.amountCents > filters.maxCents) return false;
    return true;
  }).sort((a, b) => compareISO(b.date, a.date));
}
