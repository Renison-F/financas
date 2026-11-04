import { MemoryDatabase } from '../data/memoryDatabase';
import { DataStore } from '../data/store';
import { useAppStore } from './appStore';
import { accountBalance, invoice, monthTotals } from '@financas/core';

jest.mock('expo-crypto', () => ({ randomUUID: () => 'uuid-' + Math.random().toString(36).slice(2) }));

const TODAY = '2026-11-04';

describe('app store flows', () => {
  beforeEach(async () => {
    useAppStore.setState({ today: () => TODAY });
    const store = await DataStore.open(new MemoryDatabase(), { nowISO: () => '2026-11-04T12:00:00.000Z' });
    await useAppStore.getState().init(store);
  });

  it('seeds default categories and creates account + expense', async () => {
    const s = useAppStore.getState();
    expect(s.ledger.categories.length).toBeGreaterThan(10);
    const acc = await s.saveAccount({ name: 'Nubank', openingBalanceCents: 100000 });
    await s.saveTransaction({ kind: 'expense', amountCents: 2500, date: TODAY, accountId: acc.id, description: 'Café' });
    expect(accountBalance(useAppStore.getState().ledger, acc.id)).toBe(97500);
    await expect(s.saveTransaction({ kind: 'expense', amountCents: 0, date: TODAY, accountId: acc.id })).rejects.toThrow('maior que zero');
  });

  it('splits a card purchase into installments across invoices and pays an invoice', async () => {
    const s = useAppStore.getState();
    const acc = await s.saveAccount({ name: 'Conta', openingBalanceCents: 500000 });
    const card = await s.saveCard({ name: 'Cartão', limitCents: 300000, closingDay: 20, dueDay: 27 });
    const created = await s.saveTransaction({ kind: 'card_purchase', amountCents: 90000, date: '2026-11-25', cardId: card.id, description: 'TV', installments: 3 });
    expect(created).toHaveLength(3);
    expect(created.map((t) => t.invoiceMonth)).toEqual(['2026-12', '2027-01', '2027-02']);
    expect(created.reduce((a, t) => a + t.amountCents, 0)).toBe(90000);
    const L = useAppStore.getState().ledger;
    const inv = invoice(L, card, '2026-12', '2026-11-26');
    expect(inv.totalCents).toBe(30000);
    await useAppStore.getState().payInvoice(card.id, '2026-12', 30000, acc.id, '2026-12-27');
    const L2 = useAppStore.getState().ledger;
    expect(invoice(L2, card, '2026-12', '2026-12-28').state).toBe('paid');
    expect(accountBalance(L2, acc.id)).toBe(470000);
    // paying the invoice is not an expense: November expenses only include the first installment (competence 25/11)
    expect(monthTotals(L2, '2026-12').expenseSettled).toBe(30000); // 2nd installment dated 25/12
  });

  it('creates a monthly series and materializes 3 months ahead; deleting the series removes future ones with undo', async () => {
    const s = useAppStore.getState();
    const acc = await s.saveAccount({ name: 'Conta' });
    const created = await s.saveTransaction({ kind: 'expense', amountCents: 150000, date: '2026-11-05', accountId: acc.id, description: 'Aluguel', status: 'planned', recurrence: { frequency: 'monthly' } });
    expect(created.length).toBeGreaterThanOrEqual(3);
    expect(created.every((t) => t.seriesId)).toBe(true);
    const first = created[0]!;
    await useAppStore.getState().settleTransaction(first.id);
    expect(useAppStore.getState().ledger.transactions.find((t) => t.id === first.id)?.status).toBe('settled');
    const second = created[1]!;
    await useAppStore.getState().deleteTransaction(second.id, 'series');
    const after = useAppStore.getState().ledger.transactions.filter((t) => t.seriesId === first.seriesId);
    expect(after).toHaveLength(1);
    expect(useAppStore.getState().undo?.label).toContain('excluídos');
    await useAppStore.getState().undo!.run();
    expect(useAppStore.getState().ledger.transactions.filter((t) => t.seriesId === first.seriesId).length).toBe(created.length);
  });

  it('partial settlement and balance adjustment', async () => {
    const s = useAppStore.getState();
    const acc = await s.saveAccount({ name: 'Conta', openingBalanceCents: 10000 });
    const [bill] = await s.saveTransaction({ kind: 'expense', amountCents: 10000, date: TODAY, accountId: acc.id, status: 'planned', description: 'Luz' });
    await useAppStore.getState().settleTransaction(bill!.id, { paidCents: 4000 });
    expect(useAppStore.getState().ledger.transactions[0]).toMatchObject({ status: 'partially_paid', paidCents: 4000 });
    expect(accountBalance(useAppStore.getState().ledger, acc.id)).toBe(6000);
    await useAppStore.getState().adjustBalance(acc.id, 9000, TODAY);
    expect(accountBalance(useAppStore.getState().ledger, acc.id)).toBe(9000);
  });

  it('blocks deleting an account with movements and persists prefs/layout', async () => {
    const s = useAppStore.getState();
    const acc = await s.saveAccount({ name: 'Conta' });
    await s.saveTransaction({ kind: 'income', amountCents: 100, date: TODAY, accountId: acc.id });
    expect((await useAppStore.getState().deleteAccount(acc.id)).ok).toBe(false);
    await useAppStore.getState().setPrefs({ theme: 'dark', privacyMode: true });
    await useAppStore.getState().setLayout({ ...useAppStore.getState().layout, order: ['available'] });
    await useAppStore.getState().reload();
    expect(useAppStore.getState().ledger.prefs.theme).toBe('dark');
    expect(useAppStore.getState().layout.order).toEqual(['available']);
  });
});
