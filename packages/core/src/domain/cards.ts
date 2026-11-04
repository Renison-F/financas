import { addCents, allocate, sumCents, type Cents } from '../money/money';
import { addMonthsClamped, addMonthsToKey, compareISO, monthKeyOf, monthKeyToDate, parts, type ISODate, type MonthKey } from '../dates/dates';
import type { CreditCard, Ledger, Transaction } from './types';
import { isActive, isSettled, effectiveCents } from './ledger';

/**
 * Invoice month for a purchase: purchases on or before the closing day belong to the invoice
 * that closes that month; purchases after the closing day go to the next month's invoice.
 * The invoice "month" is the month in which it CLOSES. Its due date is `dueDay` in the same
 * month when dueDay > closingDay, otherwise in the following month.
 */
export function invoiceMonthFor(card: Pick<CreditCard, 'closingDay'>, purchaseDate: ISODate): MonthKey {
  const p = parts(purchaseDate);
  const key = monthKeyOf(purchaseDate);
  return p.day <= card.closingDay ? key : addMonthsToKey(key, 1);
}

export function invoiceClosingDate(card: Pick<CreditCard, 'closingDay'>, invoiceMonth: MonthKey): ISODate {
  return monthKeyToDate(invoiceMonth, card.closingDay);
}

export function invoiceDueDate(card: Pick<CreditCard, 'closingDay' | 'dueDay'>, invoiceMonth: MonthKey): ISODate {
  const key = card.dueDay > card.closingDay ? invoiceMonth : addMonthsToKey(invoiceMonth, 1);
  return monthKeyToDate(key, card.dueDay);
}

export function purchaseInvoiceMonth(card: Pick<CreditCard, 'closingDay'>, t: Transaction): MonthKey {
  return t.invoiceMonth ?? invoiceMonthFor(card, t.date);
}

export type InvoiceState = 'open' | 'closed' | 'paid' | 'overdue' | 'future';

export interface Invoice {
  cardId: string;
  month: MonthKey;
  closingDate: ISODate;
  dueDate: ISODate;
  purchases: Transaction[];
  payments: Transaction[];
  totalCents: Cents;
  paidCents: Cents;
  remainingCents: Cents;
  state: InvoiceState;
}

export function cardPurchases(ledger: Ledger, cardId: string): Transaction[] {
  return ledger.transactions.filter((t) => isActive(t) && t.kind === 'card_purchase' && t.cardId === cardId);
}
export function cardPayments(ledger: Ledger, cardId: string): Transaction[] {
  return ledger.transactions.filter((t) => isActive(t) && t.kind === 'card_payment' && t.cardId === cardId);
}

export function invoice(ledger: Ledger, card: CreditCard, month: MonthKey, today: ISODate): Invoice {
  const purchases = cardPurchases(ledger, card.id).filter((t) => purchaseInvoiceMonth(card, t) === month);
  const payments = cardPayments(ledger, card.id).filter((t) => t.invoiceMonth === month && isSettled(t) || (t.invoiceMonth === month && t.status === 'partially_paid'));
  const totalCents = sumCents(purchases.map((t) => t.amountCents));
  const paidCents = sumCents(payments.map((t) => effectiveCents(t)));
  const remainingCents = Math.max(0, totalCents - paidCents);
  const closingDate = invoiceClosingDate(card, month);
  const dueDate = invoiceDueDate(card, month);
  let state: InvoiceState;
  if (totalCents > 0 && remainingCents === 0) state = 'paid';
  else if (compareISO(today, closingDate) <= 0) state = compareISO(month, monthKeyOf(today)) > 0 ? 'future' : 'open';
  else if (compareISO(today, dueDate) > 0 && remainingCents > 0) state = 'overdue';
  else state = 'closed';
  return { cardId: card.id, month, closingDate, dueDate, purchases, payments, totalCents, paidCents, remainingCents, state };
}

/** The invoice currently accumulating purchases (closes on or after today). */
export function currentInvoiceMonth(card: Pick<CreditCard, 'closingDay'>, today: ISODate): MonthKey {
  return invoiceMonthFor(card, today);
}

/** All invoice months that have any purchase or payment, sorted ascending. */
export function invoiceMonths(ledger: Ledger, card: CreditCard): MonthKey[] {
  const set = new Set<MonthKey>();
  for (const t of cardPurchases(ledger, card.id)) set.add(purchaseInvoiceMonth(card, t));
  for (const t of cardPayments(ledger, card.id)) if (t.invoiceMonth) set.add(t.invoiceMonth);
  return [...set].sort();
}

export interface CardCommitment {
  /** unpaid amount of the current (open) invoice */
  currentInvoiceCents: Cents;
  /** unpaid amount of closed invoices (including overdue) */
  closedUnpaidCents: Cents;
  /** purchases already assigned to future invoices (installments) */
  futureCents: Cents;
  /** total outstanding = current + closed + future */
  outstandingCents: Cents;
  availableLimitCents: Cents;
}

export function cardCommitment(ledger: Ledger, card: CreditCard, today: ISODate): CardCommitment {
  const current = currentInvoiceMonth(card, today);
  let currentInvoiceCents = 0, closedUnpaidCents = 0, futureCents = 0;
  for (const m of invoiceMonths(ledger, card)) {
    const inv = invoice(ledger, card, m, today);
    if (m === current) currentInvoiceCents = addCents(currentInvoiceCents, inv.remainingCents);
    else if (m < current) closedUnpaidCents = addCents(closedUnpaidCents, inv.remainingCents);
    else futureCents = addCents(futureCents, inv.remainingCents);
  }
  const outstandingCents = currentInvoiceCents + closedUnpaidCents + futureCents;
  return { currentInvoiceCents, closedUnpaidCents, futureCents, outstandingCents, availableLimitCents: card.limitCents - outstandingCents };
}

export interface InstallmentPlanInput {
  totalCents: Cents;
  count: number; // 1..n
  purchaseDate: ISODate;
  card: Pick<CreditCard, 'closingDay'>;
  /** optional: first installment goes to a later invoice (e.g. "compre agora, pague em 2 meses") */
  firstInvoiceOffsetMonths?: number;
}

export interface PlannedInstallment { number: number; of: number; amountCents: Cents; date: ISODate; invoiceMonth: MonthKey; }

/**
 * Splits a card purchase into N installments, one per consecutive invoice.
 * The sum of installments equals the total exactly (remainder cents on the first ones).
 * Each installment keeps the purchase day as its competence date in the respective month.
 */
export function planInstallments(input: InstallmentPlanInput): PlannedInstallment[] {
  if (!Number.isInteger(input.count) || input.count < 1 || input.count > 120) throw new RangeError('Número de parcelas inválido (1 a 120).');
  const amounts = allocate(input.totalCents, input.count, 'first');
  const firstMonth = addMonthsToKey(invoiceMonthFor(input.card, input.purchaseDate), input.firstInvoiceOffsetMonths ?? 0);
  const anchorDay = parts(input.purchaseDate).day;
  return amounts.map((amountCents, i) => ({
    number: i + 1,
    of: input.count,
    amountCents,
    date: i === 0 ? input.purchaseDate : addMonthsClamped(input.purchaseDate, i, anchorDay),
    invoiceMonth: addMonthsToKey(firstMonth, i),
  }));
}
