import { describe, it, expect } from 'vitest';
import { detectIntent, answer, recommendations } from './assistant';
import { account, budget, card, category, ledger, tx, goal } from './test-helpers';

const food = category({ id: 'food', name: 'Alimentação' });
const L = ledger({
  accounts: [account({ id: 'a', openingBalanceCents: 300000 })], categories: [food], cards: [card({ id: 'c', limitCents: 100000 })],
  budgets: [budget({ categoryId: 'food', limitCents: 50000 })], goals: [goal({ id: 'g', name: 'Viagem', targetCents: 100000 })],
  transactions: [
    tx({ kind: 'income', amountCents: 500000, date: '2026-11-01', accountId: 'a' }),
    tx({ kind: 'expense', amountCents: 45000, date: '2026-11-03', accountId: 'a', categoryId: 'food', description: 'Mercado' }),
    tx({ kind: 'expense', amountCents: 80000, date: '2026-11-06', accountId: 'a', description: 'Aluguel', status: 'planned' }),
    tx({ kind: 'expense', amountCents: 5000, date: '2026-10-20', accountId: 'a', description: 'Luz', status: 'planned' }),
    tx({ kind: 'card_purchase', amountCents: 90000, date: '2026-11-02', cardId: 'c' }),
    tx({ kind: 'goal_deposit', amountCents: 30000, date: '2026-11-02', accountId: 'a', goalId: 'g' }),
  ],
});

describe('assistant intents', () => {
  it('detects intents and amounts', () => {
    expect(detectIntent('Quanto posso gastar?').intent).toBe('can_spend');
    expect(detectIntent('Quais contas vencem esta semana?').intent).toBe('bills_this_week');
    expect(detectIntent('Onde estou gastando mais?').intent).toBe('where_spending_most');
    expect(detectIntent('Quanto já gastei com alimentação?')).toMatchObject({ intent: 'spent_on_category', category: 'alimentacao' });
    expect(detectIntent('Tenho dinheiro suficiente para comprar um celular de 1.200,50?')).toMatchObject({ intent: 'can_afford', amountCents: 120050 });
    expect(detectIntent('Como organizar minhas contas?').intent).toBe('how_to_organize');
    expect(detectIntent('Quanto falta para minha meta?').intent).toBe('goal_remaining');
    expect(detectIntent('Quanto tenho comprometido em parcelas?').intent).toBe('installments_committed');
    expect(detectIntent('xyz').intent).toBe('unknown');
  });
  it('answers from real data with a basis', () => {
    const a = answer(L, 'Quanto posso gastar?', '2026-11-04');
    // balances 300000+500000-45000-30000 = 725000; overdue 5000; bills 80000; card 90000
    expect(a.cents).toBe(725000 - 5000 - 80000 - 90000);
    expect(a.basis.length).toBeGreaterThan(2);
    expect(answer(L, 'Posso comprar algo de 100,00?', '2026-11-04').title).toBe('Cabe');
    expect(answer(L, 'Posso comprar algo de 999.999,00?', '2026-11-04').title).toBe('Não cabe agora');
    expect(answer(L, 'Quais contas vencem esta semana?', '2026-11-04').text).toContain('1 conta(s)');
    expect(answer(L, 'Quanto gastei com alimentação?', '2026-11-04').cents).toBe(45000);
    expect(answer(L, 'Onde estou gastando mais?', '2026-11-04').cents).toBe(90000);
    expect(answer(L, 'Quanto falta para minha meta?', '2026-11-04').text).toContain('faltam R$');
    expect(answer(L, 'Quanto tenho comprometido em parcelas?', '2026-11-04').cents).toBe(90000);
    expect(answer(L, 'Como está o mês?', '2026-11-04').title).toMatch(/Mês (sereno|atenção|agitado)/);
  });
  it('produces ordered rule-based recommendations', () => {
    const r = recommendations(L, '2026-11-04');
    expect(r[0]!.id).toBe('overdue');
    expect(r.map((x) => x.id)).toContain('card_c');
    expect(r.map((x) => x.id)).toContain('budget_' + L.budgets[0]!.id);
  });
});
