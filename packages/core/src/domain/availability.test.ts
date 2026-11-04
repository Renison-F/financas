import { describe, it, expect } from 'vitest';
import { availability, simulatePurchase } from './availability';
import { account, card, goal, ledger, tx } from './test-helpers';

describe('availability ("pode gastar")', () => {
  const a = account({ id: 'a', openingBalanceCents: 200000 });
  const s = account({ id: 's', openingBalanceCents: 100000, includeInAvailability: false });
  const c = card({ id: 'c', closingDay: 20, dueDay: 27 });
  const g = goal({ id: 'g', reserved: true });
  const g2 = goal({ id: 'g2', reserved: true, accountId: 'a' });
  const L = ledger({
    accounts: [a, s], cards: [c], goals: [g, g2],
    transactions: [
      tx({ kind: 'expense', amountCents: 30000, date: '2026-11-10', accountId: 'a', status: 'planned' }),        // bill this month
      tx({ kind: 'expense', amountCents: 5000, date: '2026-10-30', accountId: 'a', status: 'planned' }),         // overdue
      tx({ kind: 'expense', amountCents: 99999, date: '2026-12-05', accountId: 'a', status: 'planned' }),        // next month: outside horizon
      tx({ kind: 'income', amountCents: 400000, date: '2026-11-25', accountId: 'a', status: 'planned' }),        // planned salary
      tx({ kind: 'card_purchase', amountCents: 25000, date: '2026-11-02', cardId: 'c' }),                        // current invoice
      tx({ kind: 'goal_deposit', amountCents: 50000, date: '2026-09-01', accountId: 'a', goalId: 'g' }),        // goal without account: money left account a
      tx({ kind: 'goal_deposit', amountCents: 20000, date: '2026-09-02', accountId: 'a', toAccountId: 'a', goalId: 'g2' }), // reserve kept inside account a
    ],
  });
  it('is prudent by default: no planned income, excludes non-considered accounts', () => {
    const av = availability(L, { today: '2026-11-04' });
    expect(av.mode).toBe('prudente');
    expect(av.horizonEnd).toBe('2026-11-30');
    const byKey = Object.fromEntries(av.lines.map((l) => [l.key, l.sign * l.cents]));
    expect(byKey.balances).toBe(150000); // 200000 − 50000 deposited into the goal
    expect(byKey.overdue).toBe(-5000);
    expect(byKey.bills).toBe(-30000);
    expect(byKey.cards).toBe(-25000);
    expect(byKey.reserved).toBe(-20000); // only the reserve that still sits inside account a
    expect(av.availableCents).toBe(150000 - 5000 - 30000 - 25000 - 20000);
  });
  it('adds planned income only in optimistic mode and applies the cushion', () => {
    const av = availability(L, { today: '2026-11-04', includePlannedIncome: true, safetyCushionCents: 10000 });
    expect(av.mode).toBe('otimista');
    expect(av.availableCents).toBe(150000 - 5000 - 30000 - 25000 - 20000 - 10000 + 400000);
  });
  it('supports a 30-day horizon', () => {
    const av = availability(L, { today: '2026-11-10', horizonEnd: '2026-12-10' });
    const bills = av.lines.find((l) => l.key === 'bills')!;
    expect(bills.cents).toBe(30000 + 99999);
  });
  it('simulates a purchase', () => {
    const av = availability(L, { today: '2026-11-04' });
    expect(simulatePurchase(av, 10000).fits).toBe(true);
    expect(simulatePurchase(av, 10_000_000).fits).toBe(false);
  });
  it('reports status and hasAccounts', () => {
    expect(availability(ledger(), { today: '2026-11-04' })).toMatchObject({ hasAccounts: false, availableCents: 0 });
    expect(availability(L, { today: '2026-11-04' }).status).toBe('positive');
  });
});
