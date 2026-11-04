import { describe, it, expect } from 'vitest';
import { buildSchedule, priceInstallment, totalInterest, loanPosition, simulateExtraPayment, payoffValue } from './loans';
import { ledger, loan, tx } from './test-helpers';

describe('loan schedules', () => {
  it('computes the Price installment (classic example: 10.000 at 2% for 12 months = 945,60)', () => {
    expect(priceInstallment(1000000, 2, 12)).toBe(94560);
    expect(priceInstallment(1200000, 0, 12)).toBe(100000);
  });
  it('builds a Price schedule whose amortizations sum to the principal', () => {
    const l = loan({ principalCents: 1000000, monthlyRatePercent: 2, termMonths: 12, firstDueDate: '2026-12-10' });
    const s = buildSchedule(l);
    expect(s).toHaveLength(12);
    expect(s.reduce((a, r) => a + r.amortizationCents, 0)).toBe(1000000);
    expect(s[11]!.balanceAfterCents).toBe(0);
    expect(s[0]!.interestCents).toBe(20000);
    expect(s[0]!.dueDate).toBe('2026-12-10');
    expect(s[11]!.dueDate).toBe('2027-11-10');
    expect(totalInterest(s)).toBeGreaterThan(0);
    // all installments equal except possibly the last (rounding)
    const set = new Set(s.slice(0, 11).map((r) => r.installmentCents));
    expect(set.size).toBe(1);
  });
  it('builds a SAC schedule with constant amortization and decreasing installments', () => {
    const s = buildSchedule(loan({ principalCents: 1200000, monthlyRatePercent: 1, termMonths: 12, system: 'sac', firstDueDate: '2026-12-10' }));
    expect(s.every((r) => r.amortizationCents === 100000)).toBe(true);
    expect(s[0]!.installmentCents).toBe(112000);
    expect(s[11]!.installmentCents).toBe(101000);
  });
  it('adds fees and finances upfront fees', () => {
    const s = buildSchedule(loan({ principalCents: 100000, monthlyRatePercent: 0, termMonths: 2, firstDueDate: '2026-12-10', monthlyFeeCents: 500, upfrontFeesCents: 1000 }));
    expect(s.map((r) => r.installmentCents)).toEqual([51000, 51000]);
  });
});

describe('loan position', () => {
  const l = loan({ id: 'l', principalCents: 1000000, monthlyRatePercent: 2, termMonths: 12, firstDueDate: '2026-01-10' });
  it('tracks paid installments, overdue and payoff', () => {
    const L = ledger({ loans: [l], transactions: [
      tx({ kind: 'loan_payment', amountCents: 94560, date: '2026-01-10', loanId: 'l' }),
      tx({ kind: 'loan_payment', amountCents: 94560, date: '2026-02-10', loanId: 'l' }),
      tx({ kind: 'loan_payment', amountCents: 10000, date: '2026-02-11', loanId: 'l' }), // extra
    ] });
    const p = loanPosition(L, l, '2026-04-15');
    expect(p.paidInstallments).toBe(2);
    expect(p.extraAmortizationCents).toBe(10000);
    expect(p.nextDue?.number).toBe(3);
    expect(p.overdueInstallments.map((r) => r.number)).toEqual([3, 4]);
    expect(p.outstandingCents).toBe(p.schedule[1]!.balanceAfterCents - 10000);
    expect(p.payoffTodayCents).toBeLessThan(p.schedule.slice(2).reduce((a, r) => a + r.installmentCents, 0));
    expect(p.payoffTodayCents).toBeGreaterThan(0);
  });
  it('payoff equals the outstanding balance when paid exactly at an installment date (Price property)', () => {
    const s = buildSchedule(l);
    const pv = payoffValue(s.slice(2), 2, '2026-03-10');
    // PV at the date of installment 3 of installments 3..12 ≈ balance after installment 2 + installment 3 interest... tolerance for rounding
    expect(Math.abs(pv - (s[1]!.balanceAfterCents + s[2]!.interestCents))).toBeLessThanOrEqual(50 * 12);
  });
  it('simulates extra payments', () => {
    const r1 = simulateExtraPayment(l, 500000, 100000, 6, 'reduce_installment');
    expect(r1.newInstallmentCents).toBe(priceInstallment(400000, 2, 6));
    const r2 = simulateExtraPayment(l, 500000, 100000, 6, 'reduce_term');
    expect(r2.newTermMonths).toBeLessThan(6);
    expect(simulateExtraPayment(l, 500000, 600000, 6, 'reduce_term').newTermMonths).toBe(0);
  });
});
