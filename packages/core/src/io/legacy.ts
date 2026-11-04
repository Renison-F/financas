import { cents } from '../money/money';
import { isISODate } from '../dates/dates';
import type { Ledger, Transaction, Account, Category, CreditCard, Budget, Goal, Loan, Tag } from '../domain/types';
import { emptyLedger } from '../domain/types';
import { invoiceMonthFor } from '../domain/cards';

/** Shape of the legacy single-file app backup (localStorage key `pouso-financas-v2`). */
export interface LegacyBackup {
  version?: number;
  prefs?: Record<string, unknown>;
  accounts?: { id: string; name: string; type?: string; balance?: number; color?: string }[];
  categories?: { id: string; name: string; type: 'income' | 'expense'; icon?: string; color?: string }[];
  cards?: { id: string; name: string; limit?: number; closing?: number; due?: number; color?: string }[];
  transactions?: Record<string, unknown>[];
  budgets?: { id: string; categoryId: string; limit: number }[];
  goals?: { id: string; name: string; target: number; deadline?: string; color?: string }[];
  loans?: { id: string; name?: string; principal: number; rate: number; months: number; start?: string; firstDue?: string }[];
  tags?: { id: string; name: string; color?: string }[];
}

export interface LegacyImportResult { ledger: Ledger; warnings: string[]; counts: Record<string, number>; }

const ACCOUNT_TYPES: Record<string, Account['type']> = { cash: 'cash', bank: 'checking', checking: 'checking', savings: 'savings', wallet: 'digital_wallet', digital: 'digital_wallet', investment: 'investment' };

export function isLegacyBackup(x: unknown): x is LegacyBackup {
  return !!x && typeof x === 'object' && Array.isArray((x as LegacyBackup).transactions) && Array.isArray((x as LegacyBackup).accounts) && !('schemaVersion' in (x as object));
}

/** Converts the legacy backup into the new ledger model. Floats are converted to cents once, here. */
export function importLegacyBackup(raw: LegacyBackup, now = new Date().toISOString()): LegacyImportResult {
  const warnings: string[] = [];
  const ts = { createdAt: now, updatedAt: now };
  const ledger = emptyLedger();
  const safeCents = (n: unknown, what: string): number => { const v = Number(n); if (!Number.isFinite(v)) { warnings.push(`Valor inválido em ${what}; usado 0.`); return 0; } return cents(v); };

  for (const [i, a] of (raw.accounts ?? []).entries()) ledger.accounts.push({ id: a.id, name: String(a.name ?? 'Conta').slice(0, 70), type: ACCOUNT_TYPES[a.type ?? ''] ?? 'other', currency: 'BRL', openingBalanceCents: safeCents(a.balance ?? 0, `conta ${a.name}`), openingDate: '1970-01-01', color: a.color ?? '#0B5563', archived: false, includeInAvailability: true, sortOrder: i, ...ts });
  for (const [i, c] of (raw.categories ?? []).entries()) ledger.categories.push({ id: c.id, name: c.name, kind: c.type === 'income' ? 'income' : 'expense', icon: 'tag', color: c.color ?? '#5B6670', archived: false, sortOrder: i, ...ts } as Category);
  for (const t of raw.tags ?? []) ledger.tags.push({ id: t.id, name: t.name, color: t.color ?? '#5B6670', ...ts } as Tag);
  for (const c of raw.cards ?? []) ledger.cards.push({ id: c.id, name: c.name, limitCents: safeCents(c.limit ?? 0, `cartão ${c.name}`), closingDay: Math.min(31, Math.max(1, Number(c.closing) || 20)), dueDay: Math.min(31, Math.max(1, Number(c.due) || 10)), color: c.color ?? '#0B5563', archived: false, currency: 'BRL', ...ts } as CreditCard);
  for (const b of raw.budgets ?? []) ledger.budgets.push({ id: b.id, categoryId: b.categoryId, limitCents: safeCents(b.limit, 'orçamento'), rollover: false, ...ts } as Budget);
  for (const g of raw.goals ?? []) ledger.goals.push({ id: g.id, name: g.name, kind: 'savings', targetCents: safeCents(g.target, `meta ${g.name}`), targetDate: g.deadline && isISODate(g.deadline) ? g.deadline : undefined, reserved: true, color: g.color ?? '#0B5563', archived: false, ...ts } as Goal);
  for (const l of raw.loans ?? []) ledger.loans.push({ id: l.id, name: l.name ?? 'Empréstimo', principalCents: safeCents(l.principal, 'empréstimo'), monthlyRatePercent: Number(l.rate) || 0, termMonths: Math.max(1, Number(l.months) || 1), system: 'price', firstDueDate: l.firstDue && isISODate(l.firstDue) ? l.firstDue : l.start && isISODate(l.start) ? l.start : '1970-01-01', monthlyFeeCents: 0, upfrontFeesCents: 0, archived: false, ...ts } as Loan);

  const kindMap: Record<string, Transaction['kind']> = { income: 'income', expense: 'expense', transfer: 'transfer', card_expense: 'card_purchase', card_payment: 'card_payment', goal_deposit: 'goal_deposit', goal_withdraw: 'goal_withdrawal', loan_payment: 'loan_payment', loan_in: 'loan_disbursement' };
  for (const t of raw.transactions ?? []) {
    const kind = kindMap[String(t.type)];
    const date = String(t.date ?? '');
    if (!kind || !isISODate(date)) { warnings.push(`Lançamento ignorado (tipo ou data inválidos): ${String(t.description ?? t.id)}`); continue; }
    const card = t.cardId ? ledger.cards.find((c) => c.id === t.cardId) : undefined;
    const paid = t.paid !== false;
    const tx: Transaction = {
      id: String(t.id), kind, amountCents: safeCents(t.amount, `lançamento ${String(t.description ?? '')}`), currency: 'BRL', date,
      description: String(t.description ?? '').slice(0, 140),
      categoryId: t.categoryId ? String(t.categoryId) : undefined,
      accountId: t.accountId ? String(t.accountId) : undefined,
      toAccountId: t.toAccountId ? String(t.toAccountId) : undefined,
      cardId: t.cardId ? String(t.cardId) : undefined,
      goalId: t.goalId ? String(t.goalId) : undefined,
      loanId: t.loanId ? String(t.loanId) : undefined,
      status: kind === 'card_purchase' ? 'settled' : paid ? 'settled' : 'planned',
      seriesId: t.seriesId ? String(t.seriesId) : undefined,
      invoiceMonth: kind === 'card_payment' && typeof t.invoiceKey === 'string' ? t.invoiceKey : kind === 'card_purchase' && card ? invoiceMonthFor(card, date) : undefined,
      tags: Array.isArray(t.tags) ? t.tags.map(String) : [],
      notes: t.memo ? String(t.memo).slice(0, 500) : undefined,
      attachments: [],
      externalRef: `legacy:${String(t.id)}`,
      ...ts,
    };
    ledger.transactions.push(tx);
  }
  const prefs = raw.prefs ?? {};
  if (typeof prefs.safetyCushion === 'number') ledger.prefs.safetyCushionCents = cents(prefs.safetyCushion);
  if (prefs.theme === 'dark' || prefs.theme === 'light') ledger.prefs.theme = prefs.theme;
  const counts = { accounts: ledger.accounts.length, categories: ledger.categories.length, cards: ledger.cards.length, transactions: ledger.transactions.length, budgets: ledger.budgets.length, goals: ledger.goals.length, loans: ledger.loans.length, tags: ledger.tags.length };
  return { ledger, warnings, counts };
}
