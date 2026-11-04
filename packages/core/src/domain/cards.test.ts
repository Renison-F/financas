import { describe, it, expect } from 'vitest';
import { invoiceMonthFor, invoiceDueDate, invoice, cardCommitment, planInstallments, invoiceClosingDate } from './cards';
import { card, ledger, tx, account } from './test-helpers';

describe('invoice assignment', () => {
  const c = card({ id: 'c', closingDay: 20, dueDay: 27 });
  it('assigns purchases by closing day', () => {
    expect(invoiceMonthFor(c, '2026-11-20')).toBe('2026-11');
    expect(invoiceMonthFor(c, '2026-11-21')).toBe('2026-12');
    expect(invoiceMonthFor(c, '2026-12-31')).toBe('2027-01');
  });
  it('computes due date in the same month when due > closing, next month otherwise', () => {
    expect(invoiceDueDate(c, '2026-11')).toBe('2026-11-27');
    expect(invoiceDueDate(card({ closingDay: 28, dueDay: 5 }), '2026-11')).toBe('2026-12-05');
    expect(invoiceClosingDate(card({ closingDay: 31 }), '2026-02')).toBe('2026-02-28');
  });
});

describe('invoice totals and states', () => {
  const c = card({ id: 'c', closingDay: 20, dueDay: 27, limitCents: 100000 });
  const a = account({ id: 'a' });
  const L = ledger({
    accounts: [a], cards: [c],
    transactions: [
      tx({ kind: 'card_purchase', amountCents: 10000, date: '2026-10-15', cardId: 'c' }), // oct invoice
      tx({ kind: 'card_purchase', amountCents: 5000, date: '2026-10-25', cardId: 'c' }),  // nov invoice
      tx({ kind: 'card_purchase', amountCents: 7000, date: '2026-11-03', cardId: 'c' }),  // nov invoice
      tx({ kind: 'card_purchase', amountCents: 3000, date: '2026-11-03', cardId: 'c', invoiceMonth: '2027-01' }), // explicit future
      tx({ kind: 'card_payment', amountCents: 10000, date: '2026-10-27', cardId: 'c', accountId: 'a', invoiceMonth: '2026-10' }),
    ],
  });
  it('builds the October invoice as paid', () => {
    const inv = invoice(L, c, '2026-10', '2026-11-04');
    expect(inv.totalCents).toBe(10000);
    expect(inv.paidCents).toBe(10000);
    expect(inv.state).toBe('paid');
  });
  it('builds the November invoice as open with remaining', () => {
    const inv = invoice(L, c, '2026-11', '2026-11-04');
    expect(inv.totalCents).toBe(12000);
    expect(inv.remainingCents).toBe(12000);
    expect(inv.state).toBe('open');
    expect(inv.dueDate).toBe('2026-11-27');
  });
  it('marks a closed unpaid invoice as overdue after the due date', () => {
    expect(invoice(L, c, '2026-11', '2026-11-28').state).toBe('overdue');
    expect(invoice(L, c, '2026-11', '2026-11-22').state).toBe('closed');
    expect(invoice(L, c, '2027-01', '2026-11-04').state).toBe('future');
  });
  it('computes commitment and available limit without double counting payments', () => {
    const cm = cardCommitment(L, c, '2026-11-04');
    expect(cm.currentInvoiceCents).toBe(12000);
    expect(cm.closedUnpaidCents).toBe(0);
    expect(cm.futureCents).toBe(3000);
    expect(cm.outstandingCents).toBe(15000);
    expect(cm.availableLimitCents).toBe(85000);
  });
  it('handles partial invoice payment', () => {
    const L2 = ledger({ ...L, transactions: [...L.transactions, tx({ kind: 'card_payment', amountCents: 2000, date: '2026-11-27', cardId: 'c', accountId: 'a', invoiceMonth: '2026-11' })] });
    const inv = invoice(L2, c, '2026-11', '2026-11-28');
    expect(inv.paidCents).toBe(2000);
    expect(inv.remainingCents).toBe(10000);
    expect(inv.state).toBe('overdue');
  });
});

describe('installments', () => {
  const c = card({ closingDay: 20, dueDay: 27 });
  it('splits exactly, one per invoice, keeping the purchase day', () => {
    const plan = planInstallments({ totalCents: 100000, count: 3, purchaseDate: '2026-11-25', card: c });
    expect(plan.map((p) => p.amountCents)).toEqual([33334, 33333, 33333]);
    expect(plan.map((p) => p.invoiceMonth)).toEqual(['2026-12', '2027-01', '2027-02']);
    expect(plan.map((p) => p.date)).toEqual(['2026-11-25', '2026-12-25', '2027-01-25']);
    expect(plan[0]).toMatchObject({ number: 1, of: 3 });
  });
  it('clamps day 31 across months and supports a first-invoice offset', () => {
    const plan = planInstallments({ totalCents: 9000, count: 3, purchaseDate: '2026-01-31', card: c, firstInvoiceOffsetMonths: 1 });
    expect(plan.map((p) => p.date)).toEqual(['2026-01-31', '2026-02-28', '2026-03-31']);
    expect(plan.map((p) => p.invoiceMonth)).toEqual(['2026-03', '2026-04', '2026-05']);
  });
  it('rejects invalid counts', () => {
    expect(() => planInstallments({ totalCents: 100, count: 0, purchaseDate: '2026-01-01', card: c })).toThrow();
  });
});
