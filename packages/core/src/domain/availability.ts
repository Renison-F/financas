import { addCents, sumCents, type Cents } from '../money/money';
import { addDays, compareISO, endOfMonth, monthKeyOf, type ISODate } from '../dates/dates';
import type { Ledger } from './types';
import { activeAccounts, accountBalance, isPlanned, pendingCents, isActive } from './ledger';
import { cardCommitment } from './cards';
import { goalSavedCents } from './goals';

export interface AvailabilityLine { key: string; label: string; cents: Cents; sign: 1 | -1; note?: string | undefined; }

export interface Availability {
  availableCents: Cents;
  horizonEnd: ISODate;
  lines: AvailabilityLine[];
  /** "otimista" when planned income is included */
  mode: 'prudente' | 'otimista';
  hasAccounts: boolean;
  status: 'positive' | 'tight' | 'negative';
}

export interface AvailabilityOptions {
  today: ISODate;
  accountIds?: string[] | undefined;
  horizonEnd?: ISODate | undefined;
  includePlannedIncome?: boolean | undefined;
  safetyCushionCents?: Cents | undefined;
}

/**
 * "Pode gastar": an explainable estimate, never a guaranteed balance.
 *  + balances of the accounts considered (settled money only)
 *  − bills still to pay until the horizon (planned expenses, loan installments, overdue ones)
 *  − unpaid credit card invoices that are due until the horizon (closed/overdue) plus the current open invoice
 *  − reserved goals (money the user asked to keep untouched)
 *  − safety cushion chosen by the user
 *  (+ planned income until the horizon, only in "otimista" mode)
 */
export function availability(ledger: Ledger, opts: AvailabilityOptions): Availability {
  const today = opts.today;
  const horizonEnd = opts.horizonEnd ?? (ledger.prefs.availabilityHorizon === 'days_30' ? addDays(today, 30) : endOfMonth(monthKeyOf(today)));
  const accounts = activeAccounts(ledger).filter((a) => a.includeInAvailability).filter((a) => !opts.accountIds || opts.accountIds.includes(a.id));
  const balances = sumCents(accounts.map((a) => accountBalance(ledger, a.id)));
  const lines: AvailabilityLine[] = [{ key: 'balances', label: 'Dinheiro nas contas', cents: balances, sign: 1 }];

  const billKinds = new Set(['expense', 'loan_payment']);
  const bills = ledger.transactions.filter((t) => isPlanned(t) && billKinds.has(t.kind) && compareISO(t.dueDate ?? t.date, horizonEnd) <= 0 && (!t.accountId || accounts.some((a) => a.id === t.accountId) || !ledger.accounts.some((a) => a.id === t.accountId)));
  const overdueBills = bills.filter((t) => compareISO(t.dueDate ?? t.date, today) < 0);
  const upcomingBills = bills.filter((t) => compareISO(t.dueDate ?? t.date, today) >= 0);
  const overdueCents = sumCents(overdueBills.map(pendingCents));
  const upcomingCents = sumCents(upcomingBills.map(pendingCents));
  if (overdueCents) lines.push({ key: 'overdue', label: 'Contas atrasadas', cents: overdueCents, sign: -1, note: `${overdueBills.length} conta(s)` });
  lines.push({ key: 'bills', label: 'Contas até ' + horizonEnd.slice(8, 10) + '/' + horizonEnd.slice(5, 7), cents: upcomingCents, sign: -1, note: `${upcomingBills.length} conta(s)` });

  let cardsCents = 0;
  let cardNotes = 0;
  for (const card of ledger.cards.filter((c) => !c.archived && !c.deletedAt)) {
    const cm = cardCommitment(ledger, card, today);
    cardsCents = addCents(cardsCents, cm.closedUnpaidCents + cm.currentInvoiceCents);
    if (cm.closedUnpaidCents + cm.currentInvoiceCents > 0) cardNotes++;
  }
  // card payments already registered as planned bills would double count; they are excluded above (kind card_payment not in billKinds)
  lines.push({ key: 'cards', label: 'Faturas de cartão', cents: cardsCents, sign: -1, note: cardNotes ? `${cardNotes} cartão(ões)` : undefined });

  // Reserved goals only reduce availability when their money sits inside an account that is being counted;
  // a goal without an account already left the balances when it was deposited.
  const reserved = sumCents(ledger.goals.filter((g) => g.reserved && !g.archived && !g.deletedAt && g.accountId && accounts.some((a) => a.id === g.accountId)).map((g) => goalSavedCents(ledger, g.id)));
  if (reserved) lines.push({ key: 'reserved', label: 'Reservas guardadas', cents: reserved, sign: -1, note: 'dinheiro separado dentro das contas' });

  const cushion = opts.safetyCushionCents ?? ledger.prefs.safetyCushionCents;
  if (cushion) lines.push({ key: 'cushion', label: 'Colchão de segurança', cents: cushion, sign: -1 });

  const includeIncome = opts.includePlannedIncome ?? ledger.prefs.includePlannedIncomeInAvailability;
  if (includeIncome) {
    const incomes = ledger.transactions.filter((t) => isActive(t) && isPlanned(t) && t.kind === 'income' && compareISO(t.dueDate ?? t.date, horizonEnd) <= 0 && compareISO(t.dueDate ?? t.date, today) >= 0);
    lines.push({ key: 'planned_income', label: 'Receitas previstas', cents: sumCents(incomes.map(pendingCents)), sign: 1, note: 'ainda não recebidas' });
  }

  const availableCents = lines.reduce((acc, l) => acc + l.sign * l.cents, 0);
  const status = availableCents < 0 ? 'negative' : availableCents < Math.max(5000, Math.round(balances * 0.1)) ? 'tight' : 'positive';
  return { availableCents, horizonEnd, lines, mode: includeIncome ? 'otimista' : 'prudente', hasAccounts: accounts.length > 0, status };
}

/** Purchase simulation: how much would remain after spending `amountCents` (cash) or committing it (card). */
export function simulatePurchase(av: Availability, amountCents: Cents): { remainingCents: Cents; fits: boolean } {
  const remainingCents = av.availableCents - amountCents;
  return { remainingCents, fits: remainingCents >= 0 };
}
