import { addCents, sumCents, type Cents } from '../money/money';
import { daysInMonth, monthKeyOf, parts, type ISODate, type MonthKey } from '../dates/dates';
import type { Budget, Category, Ledger, Transaction } from './types';
import { isActive, isExpenseLike, effectiveCents } from './ledger';

/** Month rhythm: sereno = within pace, atencao = up to 10 points above, agitado = beyond. */
export type PaceStatus = 'sereno' | 'atencao' | 'agitado';

export interface BudgetStatus {
  budget: Budget;
  category?: Category | undefined;
  month: MonthKey;
  limitCents: Cents;
  spentCents: Cents; // settled + card purchases + paid part of partials
  plannedCents: Cents; // still-planned expenses in the month
  remainingCents: Cents; // limit − spent (can be negative)
  percentUsed: number; // 1 decimal
  /** fraction of the month elapsed, 0..100, the "marca de hoje" position */
  expectedPercent: number;
  pace: PaceStatus;
}

/** Resolves the budget that applies to (categoryId, month): month-specific first, then template. */
export function budgetFor(ledger: Ledger, categoryId: string | undefined, month: MonthKey): Budget | undefined {
  const candidates = ledger.budgets.filter((b) => !b.deletedAt && (b.categoryId ?? undefined) === (categoryId ?? undefined));
  return candidates.find((b) => b.month === month) ?? candidates.find((b) => !b.month);
}

function categoryMatches(ledger: Ledger, t: Transaction, categoryId: string): boolean {
  if (t.categoryId === categoryId) return true;
  const cat = ledger.categories.find((c) => c.id === t.categoryId);
  return cat?.parentId === categoryId; // subcategory rolls up into parent budget
}

export function spentInMonth(ledger: Ledger, month: MonthKey, categoryId?: string): { spentCents: Cents; plannedCents: Cents } {
  let spentCents = 0, plannedCents = 0;
  for (const t of ledger.transactions) {
    if (!isActive(t) || !isExpenseLike(t) || monthKeyOf(t.date) !== month) continue;
    if (categoryId && !categoryMatches(ledger, t, categoryId)) continue;
    if (t.kind === 'card_purchase') spentCents = addCents(spentCents, t.amountCents);
    else {
      spentCents = addCents(spentCents, effectiveCents(t));
      plannedCents = addCents(plannedCents, t.amountCents - effectiveCents(t));
    }
  }
  return { spentCents, plannedCents };
}

export function pace(percentUsed: number, expectedPercent: number): PaceStatus {
  if (percentUsed > 100 || percentUsed > expectedPercent + 10) return 'agitado';
  if (percentUsed > expectedPercent) return 'atencao';
  return 'sereno';
}

export function monthElapsedPercent(month: MonthKey, today: ISODate): number {
  const p = parts(today);
  const y = Number(month.slice(0, 4)), m = Number(month.slice(5, 7));
  if (p.year > y || (p.year === y && p.month > m)) return 100;
  if (p.year < y || (p.year === y && p.month < m)) return 0;
  return Math.round((p.day / daysInMonth(y, m)) * 1000) / 10;
}

export function budgetStatus(ledger: Ledger, budget: Budget, month: MonthKey, today: ISODate): BudgetStatus {
  const { spentCents, plannedCents } = spentInMonth(ledger, month, budget.categoryId);
  const limitCents = budget.limitCents;
  const percentUsed = limitCents > 0 ? Math.round((spentCents / limitCents) * 1000) / 10 : 0;
  const expectedPercent = monthElapsedPercent(month, today);
  return {
    budget, category: budget.categoryId ? ledger.categories.find((c) => c.id === budget.categoryId) : undefined,
    month, limitCents, spentCents, plannedCents, remainingCents: limitCents - spentCents, percentUsed, expectedPercent, pace: pace(percentUsed, expectedPercent),
  };
}

/** All budgets that apply to a month (month-specific override templates). */
export function budgetsForMonth(ledger: Ledger, month: MonthKey, today: ISODate): BudgetStatus[] {
  const keys = new Set<string>();
  const out: BudgetStatus[] = [];
  const sorted = [...ledger.budgets].filter((b) => !b.deletedAt).sort((a, b) => (a.month ? -1 : 0) - (b.month ? -1 : 0));
  for (const b of sorted) {
    if (b.month && b.month !== month) continue;
    const key = b.categoryId ?? '__global__';
    if (keys.has(key)) continue;
    keys.add(key);
    out.push(budgetStatus(ledger, b, month, today));
  }
  return out.sort((a, b) => (a.budget.categoryId ? 1 : 0) - (b.budget.categoryId ? 1 : 0) || b.percentUsed - a.percentUsed);
}

export function totalBudgetedCents(statuses: BudgetStatus[]): Cents { return sumCents(statuses.filter((s) => s.budget.categoryId).map((s) => s.limitCents)); }
