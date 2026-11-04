import { addCents, allocate, mulCents, sumCents, type Cents } from '../money/money';
import { addMonthsClamped, compareISO, parts, type ISODate } from '../dates/dates';
import type { Ledger, Loan } from './types';
import { isActive, effectiveCents } from './ledger';

/**
 * Loan math. Assumptions (documented in docs/07-regras-financeiras.md):
 * - `monthlyRatePercent` is a nominal monthly rate applied to the outstanding balance each period.
 * - Price: constant installment PMT = P·i / (1 − (1+i)^−n). SAC: constant amortization P/n + interest on balance.
 * - Rounding: each installment is rounded half-up to cents; the last installment absorbs the residual so that
 *   the sum of amortizations equals the principal exactly.
 * - Fees: `monthlyFeeCents` added to every installment; `upfrontFeesCents` financed (added to principal).
 */

export interface ScheduleRow { number: number; dueDate: ISODate; installmentCents: Cents; interestCents: Cents; amortizationCents: Cents; feeCents: Cents; balanceAfterCents: Cents; }

export function priceInstallment(principalCents: Cents, monthlyRatePercent: number, n: number): Cents {
  if (n < 1) throw new RangeError('Prazo inválido');
  const i = monthlyRatePercent / 100;
  if (i === 0) return Math.round(principalCents / n);
  const factor = i / (1 - Math.pow(1 + i, -n));
  return mulCents(principalCents, factor, 'half-up');
}

export function buildSchedule(loan: Pick<Loan, 'principalCents' | 'monthlyRatePercent' | 'termMonths' | 'system' | 'firstDueDate' | 'monthlyFeeCents' | 'upfrontFeesCents'>): ScheduleRow[] {
  const principal = loan.principalCents + (loan.upfrontFeesCents ?? 0);
  const n = loan.termMonths;
  const i = loan.monthlyRatePercent / 100;
  const rows: ScheduleRow[] = [];
  let balance = principal;
  const anchor = parts(loan.firstDueDate).day;
  const pmt = loan.system === 'price' ? priceInstallment(principal, loan.monthlyRatePercent, n) : 0;
  const sacAmorts = loan.system === 'sac' ? allocate(principal, n, 'first') : [];
  for (let k = 1; k <= n; k++) {
    const interest = mulCents(balance, i, 'half-up');
    let amort: Cents;
    if (loan.system === 'price') amort = k === n ? balance : Math.min(balance, pmt - interest);
    else amort = sacAmorts[k - 1]!;
    if (k === n) amort = balance; // absorb rounding residual
    const installment = addCents(amort, interest) + (loan.monthlyFeeCents ?? 0);
    balance = balance - amort;
    rows.push({ number: k, dueDate: addMonthsClamped(loan.firstDueDate, k - 1, anchor), installmentCents: installment, interestCents: interest, amortizationCents: amort, feeCents: loan.monthlyFeeCents ?? 0, balanceAfterCents: balance });
  }
  return rows;
}

export function totalInterest(schedule: ScheduleRow[]): Cents { return sumCents(schedule.map((r) => r.interestCents)); }
export function totalCost(schedule: ScheduleRow[]): Cents { return sumCents(schedule.map((r) => r.installmentCents)); }

export interface LoanPosition {
  loan: Loan;
  schedule: ScheduleRow[];
  paidInstallments: number;
  paidCents: Cents; // all loan_payment amounts (settled)
  extraAmortizationCents: Cents; // payments beyond scheduled installments
  outstandingCents: Cents; // remaining balance per schedule, minus extra amortizations
  nextDue?: ScheduleRow | undefined;
  overdueInstallments: ScheduleRow[];
  /** settlement value today = present value of remaining installments at the contract rate */
  payoffTodayCents: Cents;
}

/**
 * Payoff simulation: present value of the remaining installments discounted at the contractual monthly rate
 * (what Brazilian law requires for early settlement: proportional reduction of interest, CDC art. 52 §2º).
 * Fees that are not interest (monthlyFeeCents) are not discounted away. Hypothesis documented in docs.
 */
export function payoffValue(remaining: ScheduleRow[], monthlyRatePercent: number, today: ISODate): Cents {
  const i = monthlyRatePercent / 100;
  let total = 0;
  for (const row of remaining) {
    const monthsAhead = Math.max(0, monthsBetween(today, row.dueDate));
    const pv = i === 0 ? row.amortizationCents + row.interestCents : mulCents(row.amortizationCents + row.interestCents, Math.pow(1 + i, -monthsAhead), 'half-up');
    total = addCents(total, pv);
  }
  return total;
}

function monthsBetween(from: ISODate, to: ISODate): number {
  const a = parts(from), b = parts(to);
  const m = (b.year - a.year) * 12 + (b.month - a.month);
  return b.day < a.day ? m - 1 + (m > 0 ? 0 : 0) : m;
}

export function loanPosition(ledger: Ledger, loan: Loan, today: ISODate): LoanPosition {
  const schedule = buildSchedule(loan);
  const payments = ledger.transactions.filter((t) => isActive(t) && t.kind === 'loan_payment' && t.loanId === loan.id);
  const paidCents = sumCents(payments.map(effectiveCents));
  // scheduled installments are considered paid in order until the paid amount is exhausted
  let remainingPaid = paidCents;
  let paidInstallments = 0;
  for (const row of schedule) {
    if (remainingPaid >= row.installmentCents) { remainingPaid -= row.installmentCents; paidInstallments++; } else break;
  }
  const extraAmortizationCents = remainingPaid; // leftover beyond whole installments is treated as extra amortization
  const remaining = schedule.slice(paidInstallments);
  const outstandingCents = Math.max(0, (schedule[paidInstallments - 1]?.balanceAfterCents ?? loan.principalCents + loan.upfrontFeesCents) - extraAmortizationCents);
  const overdueInstallments = remaining.filter((r) => compareISO(r.dueDate, today) < 0);
  return { loan, schedule, paidInstallments, paidCents, extraAmortizationCents, outstandingCents, nextDue: remaining[0], overdueInstallments, payoffTodayCents: Math.max(0, payoffValue(remaining, loan.monthlyRatePercent, today) - extraAmortizationCents) };
}

/** What happens to a loan if the user pays `extraCents` now: shorter term (keep installment) or smaller installment (keep term). */
export function simulateExtraPayment(loan: Loan, outstandingCents: Cents, extraCents: Cents, remainingMonths: number, mode: 'reduce_term' | 'reduce_installment') {
  const newBalance = Math.max(0, outstandingCents - extraCents);
  if (newBalance === 0) return { newBalanceCents: 0, newTermMonths: 0, newInstallmentCents: 0 };
  if (mode === 'reduce_installment') {
    return { newBalanceCents: newBalance, newTermMonths: remainingMonths, newInstallmentCents: priceInstallment(newBalance, loan.monthlyRatePercent, remainingMonths) + loan.monthlyFeeCents };
  }
  const pmt = priceInstallment(outstandingCents, loan.monthlyRatePercent, remainingMonths);
  const i = loan.monthlyRatePercent / 100;
  let months: number;
  if (i === 0) months = Math.ceil(newBalance / pmt);
  else months = Math.ceil(-Math.log(1 - (newBalance * i) / pmt) / Math.log(1 + i));
  return { newBalanceCents: newBalance, newTermMonths: Math.max(1, months), newInstallmentCents: pmt + loan.monthlyFeeCents };
}
