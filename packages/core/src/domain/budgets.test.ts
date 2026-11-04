import { describe, it, expect } from 'vitest';
import { budgetsForMonth, budgetFor, monthElapsedPercent, pace, spentInMonth } from './budgets';
import { budget, category, ledger, tx, card } from './test-helpers';
import { goalProgress } from './goals';
import { goal } from './test-helpers';

describe('budgets', () => {
  const food = category({ id: 'food', name: 'Alimentação' });
  const market = category({ id: 'market', name: 'Supermercado', parentId: 'food' });
  const c = card({ id: 'c' });
  const L = ledger({
    categories: [food, market], cards: [c],
    budgets: [budget({ id: 'b1', categoryId: 'food', limitCents: 100000 }), budget({ id: 'b2', categoryId: 'food', limitCents: 120000, month: '2026-12' }), budget({ id: 'g', limitCents: 300000 })],
    transactions: [
      tx({ kind: 'expense', amountCents: 20000, date: '2026-11-02', categoryId: 'food' }),
      tx({ kind: 'card_purchase', amountCents: 30000, date: '2026-11-03', categoryId: 'market', cardId: 'c' }),
      tx({ kind: 'expense', amountCents: 10000, date: '2026-11-20', categoryId: 'food', status: 'planned' }),
      tx({ kind: 'expense', amountCents: 5000, date: '2026-11-20', categoryId: 'food', status: 'partially_paid', paidCents: 2000 }),
    ],
  });
  it('rolls subcategories into the parent budget and counts card purchases', () => {
    expect(spentInMonth(L, '2026-11', 'food')).toEqual({ spentCents: 52000, plannedCents: 13000 });
  });
  it('uses the month-specific budget over the template', () => {
    expect(budgetFor(L, 'food', '2026-11')?.id).toBe('b1');
    expect(budgetFor(L, 'food', '2026-12')?.id).toBe('b2');
    expect(budgetFor(L, undefined, '2026-11')?.id).toBe('g');
  });
  it('computes status with the rhythm state', () => {
    const [global, food] = budgetsForMonth(L, '2026-11', '2026-11-15');
    expect(global!.budget.id).toBe('g');
    expect(food!.percentUsed).toBe(52);
    expect(food!.expectedPercent).toBe(50);
    expect(food!.pace).toBe('atencao');
    expect(food!.remainingCents).toBe(48000);
  });
  it('pace thresholds', () => {
    expect(pace(30, 50)).toBe('sereno');
    expect(pace(55, 50)).toBe('atencao');
    expect(pace(61, 50)).toBe('agitado');
    expect(pace(101, 100)).toBe('agitado');
    expect(monthElapsedPercent('2026-11', '2026-12-01')).toBe(100);
    expect(monthElapsedPercent('2026-11', '2026-10-01')).toBe(0);
  });
});

describe('goals', () => {
  it('tracks progress and suggests a monthly deposit', () => {
    const g = goal({ id: 'g', targetCents: 120000, targetDate: '2027-05-04', createdAt: '2026-11-04T00:00:00.000Z' });
    const L = ledger({ goals: [g], transactions: [tx({ kind: 'goal_deposit', amountCents: 20000, date: '2026-11-04', goalId: 'g' }), tx({ kind: 'goal_withdrawal', amountCents: 5000, date: '2026-11-05', goalId: 'g' })] });
    const p = goalProgress(L, g, '2026-11-05');
    expect(p.savedCents).toBe(15000);
    expect(p.remainingCents).toBe(105000);
    expect(p.percent).toBe(12.5);
    expect(p.monthsLeft).toBe(6);
    expect(p.suggestedMonthlyCents).toBe(17500);
    expect(p.expectedPercent).toBeGreaterThanOrEqual(0);
  });
});
