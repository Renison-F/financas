import { create } from 'zustand';
import type { Account, Category, Tag, CreditCard, Transaction, Budget, Goal, Loan, Ledger, UserPrefs, RecurrenceRule, Entitlement } from '@financas/core';
import { emptyLedger, accountBalance, planInstallments, occurrencesBetween, addMonthsClamped, todayISO, invoiceMonthFor, normalizeLayout, DEFAULT_LAYOUT, type DashboardLayout, resolveAccess, type Access, buildSchedule } from '@financas/core';
import type { ShoppingList, ShoppingSession, Product, PriceObservation } from '@financas/shopping';
import type { DataStore } from '../data/store';
import { DEFAULT_CATEGORIES } from './seed';
import { newId } from './ids';

export type LoadState = 'idle' | 'loading' | 'ready' | 'error';

export interface UndoAction { label: string; run: () => Promise<void>; }

export interface AppState {
  store: DataStore | null;
  loadState: LoadState;
  error?: string | undefined;
  ledger: Ledger;
  layout: DashboardLayout;
  onboarded: boolean;
  shoppingLists: ShoppingList[];
  sessions: ShoppingSession[];
  products: Product[];
  priceObservations: PriceObservation[];
  entitlements: Entitlement[];
  access: Access;
  undo: UndoAction | null;
  today: () => string;

  init: (store: DataStore) => Promise<void>;
  reload: () => Promise<void>;
  setPrefs: (patch: Partial<UserPrefs>) => Promise<void>;
  setLayout: (layout: DashboardLayout) => Promise<void>;
  completeOnboarding: () => Promise<void>;

  saveAccount: (a: Partial<Account> & Pick<Account, 'name'>) => Promise<Account>;
  archiveAccount: (id: string, archived?: boolean) => Promise<void>;
  deleteAccount: (id: string) => Promise<{ ok: boolean; reason?: string }>;
  adjustBalance: (accountId: string, newBalanceCents: number, date: string) => Promise<void>;
  saveCategory: (c: Partial<Category> & Pick<Category, 'name' | 'kind'>) => Promise<Category>;
  saveTag: (t: Partial<Tag> & Pick<Tag, 'name'>) => Promise<Tag>;
  saveCard: (c: Partial<CreditCard> & Pick<CreditCard, 'name' | 'limitCents' | 'closingDay' | 'dueDay'>) => Promise<CreditCard>;
  saveBudget: (b: Partial<Budget> & Pick<Budget, 'limitCents'>) => Promise<Budget>;
  deleteBudget: (id: string) => Promise<void>;
  saveGoal: (g: Partial<Goal> & Pick<Goal, 'name' | 'targetCents'>) => Promise<Goal>;
  saveLoan: (l: Partial<Loan> & Pick<Loan, 'name' | 'principalCents' | 'monthlyRatePercent' | 'termMonths' | 'firstDueDate'>, opts?: { registerDisbursement?: boolean; createInstallments?: boolean }) => Promise<Loan>;

  saveTransaction: (t: TransactionInput) => Promise<Transaction[]>;
  settleTransaction: (id: string, opts?: { paidCents?: number; date?: string }) => Promise<void>;
  deleteTransaction: (id: string, scope?: 'one' | 'series') => Promise<void>;
  payInvoice: (cardId: string, invoiceMonth: string, amountCents: number, accountId: string, date: string) => Promise<void>;
  importTransactions: (list: Transaction[]) => Promise<number>;
  materializeRecurrences: (until?: string) => Promise<number>;

  saveShoppingList: (l: ShoppingList) => Promise<void>;
  deleteShoppingList: (id: string) => Promise<void>;
  saveSession: (s: ShoppingSession) => Promise<void>;
  saveProduct: (p: Product) => Promise<void>;
  addPriceObservations: (obs: PriceObservation[]) => Promise<void>;
  setEntitlements: (e: Entitlement[]) => Promise<void>;
  setUndo: (u: UndoAction | null) => void;
  restoreLedger: (ledger: Ledger) => Promise<void>;
  eraseEverything: () => Promise<void>;
}

export type LoosePartial<T> = { [K in keyof T]?: T[K] | undefined };

export interface TransactionInput extends LoosePartial<Transaction> {
  kind: Transaction['kind'];
  amountCents: number;
  date: string;
  /** split into N card installments (card_purchase only) */
  installments?: number | undefined;
  /** create a recurring series */
  recurrence?: Omit<RecurrenceRule, 'id' | 'startDate'> | undefined;
}

const nowISO = () => new Date().toISOString();
/** Removes keys whose value is undefined so they do not override defaults when spread. */
const compact = <T extends object>(o: T): Partial<T> => Object.fromEntries(Object.entries(o).filter(([, v]) => v !== undefined)) as Partial<T>;
const stamp = <T extends object>(x: T): T & { createdAt: string; updatedAt: string } => ({ createdAt: nowISO(), updatedAt: nowISO(), ...x });

export const useAppStore = create<AppState>((set, get) => ({
  store: null, loadState: 'idle', ledger: emptyLedger(), layout: DEFAULT_LAYOUT, onboarded: false,
  shoppingLists: [], sessions: [], products: [], priceObservations: [], entitlements: [], access: resolveAccess([], new Date()), undo: null,
  today: () => todayISO(),

  async init(store) {
    set({ store, loadState: 'loading' });
    try {
      if ((await store.categories.count()) === 0) await store.categories.upsertMany(DEFAULT_CATEGORIES.map((c) => stamp({ ...c, id: newId() })));
      await get().reload();
      await get().materializeRecurrences();
      set({ loadState: 'ready' });
    } catch (e) { set({ loadState: 'error', error: e instanceof Error ? e.message : String(e) }); }
  },
  async reload() {
    const store = get().store!;
    const [ledger, layoutRaw, onboarded, shoppingLists, sessions, products, priceObservations, entitlements] = await Promise.all([
      store.loadLedger(), store.kv.get('dashboard_layout'), store.kv.get<boolean>('onboarded'), store.shoppingLists.all(), store.shoppingSessions.all(), store.products.all(), store.priceObservations.all(), store.entitlements.all(),
    ]);
    set({ ledger, layout: normalizeLayout(layoutRaw), onboarded: !!onboarded, shoppingLists, sessions, products, priceObservations, entitlements, access: resolveAccess(entitlements, new Date()) });
  },
  async setPrefs(patch) { const prefs = { ...get().ledger.prefs, ...patch }; await get().store!.savePrefs(prefs); set({ ledger: { ...get().ledger, prefs } }); },
  async setLayout(layout) { await get().store!.kv.set('dashboard_layout', layout); set({ layout }); },
  async completeOnboarding() { await get().store!.kv.set('onboarded', true); set({ onboarded: true }); },

  async saveAccount(a) {
    const existing = a.id ? get().ledger.accounts.find((x) => x.id === a.id) : undefined;
    const acc: Account = stamp({ id: newId(), type: 'checking', currency: get().ledger.prefs.currency, openingBalanceCents: 0, openingDate: get().today(), color: '#0B5563', archived: false, includeInAvailability: true, sortOrder: get().ledger.accounts.length, ...existing, ...a });
    await get().store!.accounts.upsert(acc); await get().reload(); return acc;
  },
  async archiveAccount(id, archived = true) { const a = get().ledger.accounts.find((x) => x.id === id); if (a) { await get().store!.accounts.upsert({ ...a, archived }); await get().reload(); } },
  async deleteAccount(id) {
    const used = get().ledger.transactions.some((t) => t.accountId === id || t.toAccountId === id);
    if (used) return { ok: false, reason: 'Esta conta tem lançamentos. Arquive-a ou mova os lançamentos antes de excluir.' };
    await get().store!.accounts.softDelete(id); await get().reload(); return { ok: true };
  },
  async adjustBalance(accountId, newBalanceCents, date) {
    const current = accountBalance(get().ledger, accountId);
    const diff = newBalanceCents - current;
    if (diff === 0) return;
    await get().saveTransaction({ kind: 'balance_adjustment', amountCents: Math.abs(diff), date, description: 'Ajuste de saldo', status: 'settled', ...(diff > 0 ? { toAccountId: accountId } : { accountId }) });
  },
  async saveCategory(c) { const cat: Category = stamp({ id: newId(), icon: 'tag', color: '#4F5E61', archived: false, sortOrder: get().ledger.categories.length, ...get().ledger.categories.find((x) => x.id === c.id), ...c }); await get().store!.categories.upsert(cat); await get().reload(); return cat; },
  async saveTag(t) { const tag: Tag = stamp({ id: newId(), color: '#4F5E61', ...get().ledger.tags.find((x) => x.id === t.id), ...t }); await get().store!.tags.upsert(tag); await get().reload(); return tag; },
  async saveCard(c) { const card: CreditCard = stamp({ id: newId(), color: '#0B5563', archived: false, currency: get().ledger.prefs.currency, ...get().ledger.cards.find((x) => x.id === c.id), ...c }); await get().store!.cards.upsert(card); await get().reload(); return card; },
  async saveBudget(b) { const budget: Budget = stamp({ id: newId(), rollover: false, ...get().ledger.budgets.find((x) => x.id === b.id), ...b }); await get().store!.budgets.upsert(budget); await get().reload(); return budget; },
  async deleteBudget(id) { await get().store!.budgets.softDelete(id); await get().reload(); },
  async saveGoal(g) { const goal: Goal = stamp({ id: newId(), kind: 'savings', reserved: true, color: '#0B5563', archived: false, ...get().ledger.goals.find((x) => x.id === g.id), ...g }); await get().store!.goals.upsert(goal); await get().reload(); return goal; },
  async saveLoan(l, opts = {}) {
    const loan: Loan = stamp({ id: newId(), system: 'price', monthlyFeeCents: 0, upfrontFeesCents: 0, archived: false, ...get().ledger.loans.find((x) => x.id === l.id), ...l });
    const store = get().store!;
    await store.db.withTransactionAsync(async () => {
      await store.loans.upsert(loan);
      if (opts.registerDisbursement && loan.accountId) await store.transactions.upsert(stamp({ id: newId(), kind: 'loan_disbursement', amountCents: loan.principalCents, currency: get().ledger.prefs.currency, date: get().today(), description: `Entrada: ${loan.name}`, accountId: loan.accountId, loanId: loan.id, status: 'settled', tags: [], attachments: [] }));
      if (opts.createInstallments) {
        const groupId = newId();
        for (const row of buildSchedule(loan)) await store.transactions.upsert(stamp({ id: newId(), kind: 'loan_payment', amountCents: row.installmentCents, currency: 'BRL', date: row.dueDate, dueDate: row.dueDate, description: `${loan.name} ${row.number}/${loan.termMonths}`, accountId: loan.accountId, loanId: loan.id, status: 'planned', installment: { number: row.number, of: loan.termMonths, groupId }, tags: [], attachments: [] }));
      }
    });
    await get().reload(); return loan;
  },

  async saveTransaction(input) {
    const store = get().store!;
    const { installments, recurrence, ...rest } = input;
    const clean = compact(rest) as Partial<Transaction> & Pick<Transaction, 'kind' | 'amountCents' | 'date'>;
    const base: Transaction = stamp({ id: newId(), currency: get().ledger.prefs.currency, description: '', status: 'settled', tags: [], attachments: [], ...get().ledger.transactions.find((x) => x.id === clean.id), ...clean });
    if (!Number.isSafeInteger(base.amountCents) || base.amountCents <= 0) throw new Error('Informe um valor maior que zero.');
    if (base.kind === 'transfer' && (!base.accountId || !base.toAccountId || base.accountId === base.toAccountId)) throw new Error('Escolha duas contas diferentes.');
    if (base.kind === 'card_purchase' && !base.cardId) throw new Error('Escolha o cartão.');
    if (['income', 'expense', 'card_payment', 'goal_deposit', 'loan_payment'].includes(base.kind) && !base.accountId && base.kind !== 'card_payment') throw new Error('Escolha a conta.');
    const created: Transaction[] = [];
    await store.db.withTransactionAsync(async () => {
      if (base.kind === 'card_purchase' && installments && installments > 1 && !rest.id) {
        const card = get().ledger.cards.find((c) => c.id === base.cardId)!;
        const groupId = newId();
        for (const p of planInstallments({ totalCents: base.amountCents, count: installments, purchaseDate: base.date, card })) {
          const t: Transaction = { ...base, id: newId(), amountCents: p.amountCents, date: p.date, invoiceMonth: p.invoiceMonth, installment: { number: p.number, of: p.of, groupId }, description: `${base.description} (${p.number}/${p.of})` };
          await store.transactions.upsert(t); created.push(t);
        }
      } else if (recurrence && !rest.id) {
        const seriesId = newId();
        const rule: RecurrenceRule = { id: seriesId, startDate: base.date, ...recurrence };
        await store.recurrenceRules.upsert({ ...rule, templateTransactionId: base.id, lastGenerated: undefined });
        const until = addMonthsClamped(get().today(), 3);
        const dates = occurrencesBetween(rule, base.date, until);
        for (const [i, d] of dates.entries()) {
          const t: Transaction = { ...base, id: i === 0 ? base.id : newId(), date: d, dueDate: base.dueDate ? addMonthsClamped(base.dueDate, 0) : d, seriesId, status: i === 0 ? base.status : 'planned' };
          if (t.kind === 'card_purchase' && t.cardId) t.invoiceMonth = invoiceMonthFor(get().ledger.cards.find((c) => c.id === t.cardId)!, d);
          await store.transactions.upsert(t); created.push(t);
        }
        await store.recurrenceRules.upsert({ ...rule, templateTransactionId: base.id, lastGenerated: dates[dates.length - 1] });
      } else {
        if (base.kind === 'card_purchase' && base.cardId && !base.invoiceMonth) base.invoiceMonth = invoiceMonthFor(get().ledger.cards.find((c) => c.id === base.cardId)!, base.date);
        await store.transactions.upsert(base); created.push(base);
      }
    });
    await get().reload();
    return created;
  },
  async settleTransaction(id, opts = {}) {
    const t = get().ledger.transactions.find((x) => x.id === id); if (!t) return;
    const paid = opts.paidCents ?? t.amountCents;
    const total = (t.status === 'partially_paid' ? t.paidCents ?? 0 : 0) + paid;
    const next: Transaction = total >= t.amountCents ? { ...t, status: 'settled', paidCents: t.amountCents, settledDate: opts.date ?? get().today() } : { ...t, status: 'partially_paid', paidCents: total };
    await get().store!.transactions.upsert(next); await get().reload();
  },
  async deleteTransaction(id, scope = 'one') {
    const t = get().ledger.transactions.find((x) => x.id === id); if (!t) return;
    const store = get().store!;
    const targets = scope === 'series' && t.seriesId ? get().ledger.transactions.filter((x) => x.seriesId === t.seriesId && x.date >= t.date) : t.installment ? get().ledger.transactions.filter((x) => x.installment?.groupId === t.installment!.groupId) : [t];
    await store.db.withTransactionAsync(async () => { for (const x of targets) await store.transactions.softDelete(x.id); });
    set({ undo: { label: targets.length > 1 ? `${targets.length} lançamentos excluídos` : 'Lançamento excluído', run: async () => { await store.transactions.upsertMany(targets); await get().reload(); set({ undo: null }); } } });
    await get().reload();
  },
  async payInvoice(cardId, invoiceMonth, amountCents, accountId, date) {
    await get().saveTransaction({ kind: 'card_payment', amountCents, date, accountId, cardId, invoiceMonth, description: `Pagamento fatura ${invoiceMonth.slice(5, 7)}/${invoiceMonth.slice(0, 4)}`, status: 'settled' });
  },
  async importTransactions(list) { await get().store!.transactions.upsertMany(list); await get().reload(); return list.length; },
  async materializeRecurrences(until) {
    const store = get().store!;
    const horizon = until ?? addMonthsClamped(get().today(), 3);
    const rules = await store.recurrenceRules.all();
    let n = 0;
    for (const rule of rules) {
      const template = get().ledger.transactions.find((t) => t.id === rule.templateTransactionId) ?? get().ledger.transactions.find((t) => t.seriesId === rule.id);
      if (!template) continue;
      const from = rule.lastGenerated ? addMonthsClamped(rule.lastGenerated, 0) : rule.startDate;
      const dates = occurrencesBetween(rule, from, horizon).filter((d) => !rule.lastGenerated || d > rule.lastGenerated);
      if (!dates.length) continue;
      for (const d of dates) {
        if (get().ledger.transactions.some((t) => t.seriesId === rule.id && t.date === d)) continue;
        const t: Transaction = { ...template, id: newId(), date: d, dueDate: d, status: 'planned', paidCents: undefined, settledDate: undefined, seriesId: rule.id, createdAt: nowISO(), updatedAt: nowISO() };
        if (t.kind === 'card_purchase' && t.cardId) t.invoiceMonth = invoiceMonthFor(get().ledger.cards.find((c) => c.id === t.cardId)!, d);
        await store.transactions.upsert(t); n++;
      }
      await store.recurrenceRules.upsert({ ...rule, lastGenerated: dates[dates.length - 1] });
    }
    if (n) await get().reload();
    return n;
  },

  async saveShoppingList(l) { await get().store!.shoppingLists.upsert(l); await get().reload(); },
  async deleteShoppingList(id) { await get().store!.shoppingLists.softDelete(id); await get().reload(); },
  async saveSession(s) { await get().store!.shoppingSessions.upsert(s); await get().reload(); },
  async saveProduct(p) { await get().store!.products.upsert(p); await get().reload(); },
  async addPriceObservations(obs) { if (obs.length) { await get().store!.priceObservations.upsertMany(obs); await get().reload(); } },
  async setEntitlements(e) { const store = get().store!; await store.entitlements.purgeAll(); await store.entitlements.upsertMany(e.map((x) => ({ ...x, id: x.planId }))); set({ entitlements: e, access: resolveAccess(e, new Date()) }); },
  setUndo(u) { set({ undo: u }); },
  async restoreLedger(ledger) { await get().store!.replaceAll(ledger); await get().reload(); },
  async eraseEverything() { await get().store!.eraseAll(); set({ onboarded: false }); await get().init(get().store!); },
}));

export const selectLedger = (s: AppState) => s.ledger;
