import { describe, it, expect } from 'vitest';
import { expensesByCategory, cashflow, compareMonths, yearSummary, recurringExpenses, projectBalance, netWorth, searchTransactions } from './reports';
import { account, card, category, ledger, tx, loan } from './test-helpers';

const food = category({ id: 'food', name: 'Alimentação' });
const market = category({ id: 'market', name: 'Supermercado', parentId: 'food' });
const rent = category({ id: 'rent', name: 'Moradia' });
const a = account({ id: 'a', openingBalanceCents: 100000, openingDate: '2026-01-01' });
const c = card({ id: 'c', closingDay: 20, dueDay: 27 });
const L = ledger({
  accounts: [a], cards: [c], categories: [food, market, rent],
  transactions: [
    tx({ kind: 'income', amountCents: 500000, date: '2026-10-05', accountId: 'a', description: 'Salário' }),
    tx({ kind: 'income', amountCents: 500000, date: '2026-11-05', accountId: 'a', description: 'Salário' }),
    tx({ kind: 'expense', amountCents: 150000, date: '2026-09-10', accountId: 'a', categoryId: 'rent', description: 'Aluguel' }),
    tx({ kind: 'expense', amountCents: 150000, date: '2026-10-10', accountId: 'a', categoryId: 'rent', description: 'Aluguel' }),
    tx({ kind: 'expense', amountCents: 150000, date: '2026-11-10', accountId: 'a', categoryId: 'rent', description: 'Aluguel' }),
    tx({ kind: 'expense', amountCents: 40000, date: '2026-11-11', accountId: 'a', categoryId: 'food', description: 'Padaria' }),
    tx({ kind: 'card_purchase', amountCents: 60000, date: '2026-11-12', cardId: 'c', categoryId: 'market', description: 'Mercado Bom' }),
    tx({ kind: 'expense', amountCents: 20000, date: '2026-11-28', accountId: 'a', categoryId: 'food', description: 'Delivery', status: 'planned' }),
    tx({ kind: 'income', amountCents: 100000, date: '2026-11-30', accountId: 'a', description: 'Freela', status: 'planned' }),
  ],
});

describe('reports', () => {
  it('expenses by category with roll-up and percentages', () => {
    const flat = expensesByCategory(L, '2026-11');
    expect(flat.map((c) => [c.name, c.cents])).toEqual([['Moradia', 150000], ['Supermercado', 60000], ['Alimentação', 40000]]);
    const rolled = expensesByCategory(L, '2026-11', { rollUp: true });
    expect(rolled.map((c) => [c.name, c.cents, c.percent])).toEqual([['Moradia', 150000, 60], ['Alimentação', 100000, 40]]);
  });
  it('cashflow and month comparison', () => {
    const cf = cashflow(L, '2026-11', 3);
    expect(cf.map((p) => p.month)).toEqual(['2026-09', '2026-10', '2026-11']);
    expect(cf[2]!.expenseSettled).toBe(250000);
    expect(cf[1]!.balanceEnd).toBe(100000 - 150000 + 500000 - 150000);
    const cmp = compareMonths(L, '2026-11');
    expect(cmp.expenseDeltaCents).toBe(100000);
    expect(cmp.expenseDeltaPercent).toBe(66.7);
  });
  it('year summary', () => {
    const y = yearSummary(L, 2026);
    expect(y.incomeCents).toBe(1000000);
    expect(y.expenseCents).toBe(550000);
    expect(y.bestMonth).toBe('2026-10');
    expect(y.worstMonth).toBe('2026-09');
  });
  it('detects recurring expenses by repeated description and amount', () => {
    const rec = recurringExpenses(L, '2026-11');
    expect(rec.map((r) => r.description)).toEqual(['Aluguel']);
    expect(rec[0]!.months).toHaveLength(3);
  });
  it('projects the balance with planned items and invoice due dates', () => {
    const p = projectBalance(L, '2026-11-15', '2026-11-30');
    expect(p.startCents).toBe(100000 + 1000000 - 490000);
    const labels = p.points.map((x) => x.label);
    expect(labels).toEqual(['Fatura Cartão', 'Delivery', 'Freela']);
    expect(p.endCents).toBe(p.startCents - 60000 - 20000 + 100000);
    expect(p.minCents).toBe(p.startCents - 80000);
  });
  it('net worth subtracts card and loan debt', () => {
    const L2 = ledger({ ...L, loans: [loan({ id: 'l', principalCents: 100000, monthlyRatePercent: 0, termMonths: 10, firstDueDate: '2026-12-10' })] });
    const nw = netWorth(L2, '2026-11', 1, '2026-11-15');
    expect(nw[0]!.debtsCents).toBe(60000 + 100000);
    expect(nw[0]!.netCents).toBe(nw[0]!.assetsCents - 160000);
  });
  it('searches with accent-insensitive text and filters', () => {
    expect(searchTransactions(L, 'salario').length).toBe(2);
    expect(searchTransactions(L, '', { categoryIds: ['food'], status: ['planned'] }).length).toBe(1);
    expect(searchTransactions(L, '', { cardIds: ['c'] }).length).toBe(1);
    expect(searchTransactions(L, '', { minCents: 200000 }).length).toBe(2);
  });
});
