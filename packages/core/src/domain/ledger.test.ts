import { describe, it, expect } from 'vitest';
import { accountBalance, consolidatedBalance, monthTotals, overdue, upcoming, effectiveCents, pendingCents } from './ledger';
import { account, card, ledger, tx } from './test-helpers';

describe('account balances', () => {
  const a = account({ id: 'a', openingBalanceCents: 100000 });
  const b = account({ id: 'b', openingBalanceCents: 0 });
  const c = card({ id: 'c' });
  const L = ledger({
    accounts: [a, b], cards: [c],
    transactions: [
      tx({ kind: 'income', amountCents: 300000, date: '2026-11-05', accountId: 'a' }),
      tx({ kind: 'expense', amountCents: 5000, date: '2026-11-06', accountId: 'a' }),
      tx({ kind: 'expense', amountCents: 9999, date: '2026-11-07', accountId: 'a', status: 'planned' }),
      tx({ kind: 'transfer', amountCents: 50000, date: '2026-11-08', accountId: 'a', toAccountId: 'b' }),
      tx({ kind: 'card_purchase', amountCents: 20000, date: '2026-11-09', cardId: 'c' }),
      tx({ kind: 'card_payment', amountCents: 20000, date: '2026-11-27', accountId: 'a', cardId: 'c' }),
      tx({ kind: 'expense', amountCents: 10000, date: '2026-11-10', accountId: 'b', status: 'partially_paid', paidCents: 4000 }),
      tx({ kind: 'expense', amountCents: 777, date: '2026-11-11', accountId: 'a', status: 'cancelled' }),
      tx({ kind: 'balance_adjustment', amountCents: 100, date: '2026-11-12', toAccountId: 'b' }),
    ],
  });
  it('applies only settled money, with transfers neutral in the consolidated total', () => {
    expect(accountBalance(L, 'a')).toBe(100000 + 300000 - 5000 - 50000 - 20000);
    expect(accountBalance(L, 'b')).toBe(50000 - 4000 + 100);
    expect(consolidatedBalance(L)).toBe(accountBalance(L, 'a') + accountBalance(L, 'b'));
  });
  it('respects the as-of date', () => {
    expect(accountBalance(L, 'a', '2026-11-05')).toBe(400000);
    expect(accountBalance(L, 'a', '2026-11-04')).toBe(100000);
  });
  it('ignores archived accounts in the consolidated balance unless asked', () => {
    const L2 = ledger({ accounts: [account({ id: 'z', openingBalanceCents: 100, archived: true })] });
    expect(consolidatedBalance(L2)).toBe(0);
    expect(consolidatedBalance(L2, { includeArchived: true })).toBe(100);
  });
  it('does not count a card purchase twice when the invoice is paid', () => {
    const m = monthTotals(L, '2026-11');
    // expenses: 5000 settled + 4000 partial + 20000 card purchase; the 20000 card_payment is not an expense
    expect(m.expenseSettled).toBe(5000 + 4000 + 20000);
    expect(m.expensePlanned).toBe(9999 + 6000);
    expect(m.incomeSettled).toBe(300000);
    expect(m.cardPurchases).toBe(20000);
    expect(m.net).toBe(300000 - 29000);
  });
  it('exposes effective and pending parts of partial payments', () => {
    const t = tx({ kind: 'expense', amountCents: 10000, date: '2026-11-10', status: 'partially_paid', paidCents: 4000 });
    expect(effectiveCents(t)).toBe(4000);
    expect(pendingCents(t)).toBe(6000);
  });
});

describe('overdue and upcoming', () => {
  const L = ledger({
    transactions: [
      tx({ id: 'late', kind: 'expense', amountCents: 100, date: '2026-10-28', dueDate: '2026-10-30', status: 'planned' }),
      tx({ id: 'soon', kind: 'expense', amountCents: 100, date: '2026-11-10', status: 'planned' }),
      tx({ id: 'far', kind: 'expense', amountCents: 100, date: '2026-12-10', status: 'planned' }),
      tx({ id: 'paid', kind: 'expense', amountCents: 100, date: '2026-10-01', status: 'settled' }),
    ],
  });
  it('separates overdue from upcoming within a window', () => {
    expect(overdue(L, '2026-11-04').map((t) => t.id)).toEqual(['late']);
    expect(upcoming(L, '2026-11-04', '2026-11-30').map((t) => t.id)).toEqual(['soon']);
  });
});
