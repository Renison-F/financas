import { addCents, negate, sumCents, type Cents } from '../money/money';
import { compareISO, monthKeyOf, type ISODate, type MonthKey } from '../dates/dates';
import type { Account, Ledger, Transaction, TransactionKind } from './types';

export function isActive(t: Transaction): boolean { return !t.deletedAt && t.status !== 'cancelled'; }
export function isSettled(t: Transaction): boolean { return isActive(t) && t.status === 'settled'; }
export function isPlanned(t: Transaction): boolean { return isActive(t) && (t.status === 'planned' || t.status === 'partially_paid'); }

/** Amount that has effectively moved money (settled or the paid part of a partial). */
export function effectiveCents(t: Transaction): Cents {
  if (!isActive(t)) return 0;
  if (t.status === 'settled') return t.amountCents;
  if (t.status === 'partially_paid') return Math.min(t.paidCents ?? 0, t.amountCents);
  return 0;
}
/** Amount still pending (planned or remaining part of a partial). */
export function pendingCents(t: Transaction): Cents {
  if (!isActive(t)) return 0;
  if (t.status === 'planned') return t.amountCents;
  if (t.status === 'partially_paid') return Math.max(0, t.amountCents - (t.paidCents ?? 0));
  return 0;
}

/** Signed effect of a transaction on a given account (effective money only). */
export function accountEffect(t: Transaction, accountId: string, cents: Cents = effectiveCents(t)): Cents {
  if (cents === 0) return 0;
  switch (t.kind) {
    case 'income':
    case 'loan_disbursement':
      return t.accountId === accountId ? cents : 0;
    case 'expense':
    case 'card_payment':
    case 'loan_payment':
      return t.accountId === accountId ? negate(cents) : 0;
    case 'transfer':
    case 'goal_deposit':     // accountId = source, toAccountId = account where the goal money sits (optional)
    case 'goal_withdrawal':  // accountId = account where the goal money sits (optional), toAccountId = destination
      return (t.accountId === accountId ? negate(cents) : 0) + (t.toAccountId === accountId ? cents : 0);
    case 'balance_adjustment':
      // amountCents is positive; direction encoded by toAccountId (credit) vs accountId (debit)
      if (t.toAccountId === accountId) return cents;
      if (t.accountId === accountId) return negate(cents);
      return 0;
    case 'card_purchase':
      return 0; // does not touch accounts until the invoice is paid
    default:
      return 0;
  }
}

/** Balance of an account as of `asOf` (inclusive), considering settled money only. */
export function accountBalance(ledger: Ledger, accountId: string, asOf?: ISODate): Cents {
  const account = ledger.accounts.find((a) => a.id === accountId);
  if (!account) return 0;
  let balance: Cents = account.openingBalanceCents;
  for (const t of ledger.transactions) {
    if (!isActive(t)) continue;
    const effDate = t.settledDate ?? t.date;
    if (asOf && compareISO(effDate, asOf) > 0) continue;
    balance = addCents(balance, accountEffect(t, accountId));
  }
  return balance;
}

export function activeAccounts(ledger: Ledger): Account[] { return ledger.accounts.filter((a) => !a.archived && !a.deletedAt); }

export function consolidatedBalance(ledger: Ledger, opts: { accountIds?: string[]; asOf?: ISODate; includeArchived?: boolean } = {}): Cents {
  const accounts = (opts.includeArchived ? ledger.accounts.filter((a) => !a.deletedAt) : activeAccounts(ledger))
    .filter((a) => !opts.accountIds || opts.accountIds.includes(a.id));
  return sumCents(accounts.map((a) => accountBalance(ledger, a.id, opts.asOf)));
}

export const EXPENSE_KINDS: ReadonlySet<TransactionKind> = new Set(['expense', 'card_purchase']);
export const INCOME_KINDS: ReadonlySet<TransactionKind> = new Set(['income']);

export function isExpenseLike(t: Transaction): boolean { return EXPENSE_KINDS.has(t.kind); }
export function isIncomeLike(t: Transaction): boolean { return INCOME_KINDS.has(t.kind); }

export function transactionsInMonth(ledger: Ledger, month: MonthKey): Transaction[] {
  return ledger.transactions.filter((t) => isActive(t) && monthKeyOf(t.date) === month);
}

export interface MonthTotals {
  month: MonthKey;
  incomeSettled: Cents; incomePlanned: Cents;
  expenseSettled: Cents; expensePlanned: Cents;
  /** settled income − settled expense (card purchases count as expense on purchase date) */
  net: Cents;
  cardPurchases: Cents;
}

/**
 * Month totals by competence. Card purchases count as expenses in the month of purchase;
 * card payments are NOT expenses (they only move money), so nothing is counted twice.
 */
export function monthTotals(ledger: Ledger, month: MonthKey): MonthTotals {
  let incomeSettled = 0, incomePlanned = 0, expenseSettled = 0, expensePlanned = 0, cardPurchases = 0;
  for (const t of transactionsInMonth(ledger, month)) {
    if (isIncomeLike(t)) { incomeSettled = addCents(incomeSettled, effectiveCents(t)); incomePlanned = addCents(incomePlanned, pendingCents(t)); }
    if (isExpenseLike(t)) {
      const eff = t.kind === 'card_purchase' ? t.amountCents : effectiveCents(t);
      const pend = t.kind === 'card_purchase' ? 0 : pendingCents(t);
      expenseSettled = addCents(expenseSettled, eff); expensePlanned = addCents(expensePlanned, pend);
      if (t.kind === 'card_purchase') cardPurchases = addCents(cardPurchases, t.amountCents);
    }
  }
  return { month, incomeSettled, incomePlanned, expenseSettled, expensePlanned, net: incomeSettled - expenseSettled, cardPurchases };
}

/** Overdue bills: planned expenses/incomes whose due date (or date) is before `today`. */
export function overdue(ledger: Ledger, today: ISODate): Transaction[] {
  return ledger.transactions.filter((t) => isPlanned(t) && (t.kind === 'expense' || t.kind === 'income' || t.kind === 'loan_payment' || t.kind === 'card_payment') && compareISO(t.dueDate ?? t.date, today) < 0);
}

/** Upcoming bills within [today, until], inclusive. */
export function upcoming(ledger: Ledger, today: ISODate, until: ISODate): Transaction[] {
  return ledger.transactions
    .filter((t) => isPlanned(t) && (t.kind === 'expense' || t.kind === 'loan_payment' || t.kind === 'card_payment') && compareISO(t.dueDate ?? t.date, today) >= 0 && compareISO(t.dueDate ?? t.date, until) <= 0)
    .sort((a, b) => compareISO(a.dueDate ?? a.date, b.dueDate ?? b.date));
}
