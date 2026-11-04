import { MemoryDatabase } from './memoryDatabase';
import { DataStore } from './store';
import { migrate, MIGRATIONS } from './migrations';

const now = '2026-11-04T12:00:00.000Z';
const clock = { nowISO: () => now };

describe('DataStore on MemoryDatabase', () => {
  it('migrates to the latest version idempotently', async () => {
    const db = new MemoryDatabase();
    expect(await migrate(db)).toEqual({ from: 0, to: MIGRATIONS[MIGRATIONS.length - 1]!.version });
    expect(await migrate(db)).toEqual({ from: 2, to: 2 });
  });
  it('persists entities, soft-deletes, logs changes and loads a ledger', async () => {
    const store = await DataStore.open(new MemoryDatabase(), clock, 'dev1');
    await store.accounts.upsert({ id: 'a', name: 'Conta', type: 'checking', currency: 'BRL', openingBalanceCents: 1000, openingDate: '2026-01-01', color: '#000', archived: false, includeInAvailability: true, sortOrder: 0, createdAt: now, updatedAt: now });
    await store.transactions.upsert({ id: 't', kind: 'expense', amountCents: 500, currency: 'BRL', date: '2026-11-04', description: 'Café', accountId: 'a', status: 'settled', tags: [], attachments: [], createdAt: now, updatedAt: now });
    let ledger = await store.loadLedger();
    expect(ledger.accounts).toHaveLength(1); expect(ledger.transactions).toHaveLength(1); expect(ledger.prefs.currency).toBe('BRL');
    expect(await store.transactions.softDelete('t')).toBe(true);
    ledger = await store.loadLedger();
    expect(ledger.transactions).toHaveLength(0);
    expect(await store.transactions.all(true)).toHaveLength(1);
    const pending = await store.changeLog.pending();
    expect(pending.map((c) => c.op)).toEqual(['upsert', 'upsert', 'delete']);
    await store.changeLog.markSynced(pending.map((c) => c.id));
    expect(await store.changeLog.pending()).toHaveLength(0);
  });
  it('rolls back a failed transaction', async () => {
    const store = await DataStore.open(new MemoryDatabase(), clock);
    await expect(store.db.withTransactionAsync(async () => {
      await store.kv.set('x', 1);
      throw new Error('boom');
    })).rejects.toThrow('boom');
    expect(await store.kv.get('x')).toBeNull();
  });
  it('replaceAll and eraseAll', async () => {
    const store = await DataStore.open(new MemoryDatabase(), clock);
    await store.kv.set('prefs', { currency: 'BRL', theme: 'dark' });
    await store.replaceAll({ ...(await store.loadLedger()), tags: [{ id: 'g', name: 'viagem', color: '#000', createdAt: now, updatedAt: now }] });
    expect((await store.loadLedger()).tags).toHaveLength(1);
    expect((await store.loadLedger()).prefs.theme).toBe('dark');
    await store.eraseAll();
    expect((await store.loadLedger()).tags).toHaveLength(0);
    expect(await store.kv.get('prefs')).toBeNull();
  });
});
