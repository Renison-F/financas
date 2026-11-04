import type { Account, Category, Tag, CreditCard, Transaction, Budget, Goal, Loan, RecurrenceRule, Ledger, UserPrefs } from '@financas/core';
import { DEFAULT_PREFS } from '@financas/core';
import type { ShoppingList, ShoppingSession, Product, PriceObservation } from '@financas/shopping';
import type { Entitlement } from '@financas/core';
import type { Database, DocumentTable } from './database';
import { migrate } from './migrations';
import { DocumentRepository, KVStore, ChangeLog, type Clock, systemClock } from './repository';

/** All repositories wired to one database; the single entry point for the app's persistence. */
export class DataStore {
  readonly accounts: DocumentRepository<Account>;
  readonly categories: DocumentRepository<Category>;
  readonly tags: DocumentRepository<Tag>;
  readonly cards: DocumentRepository<CreditCard>;
  readonly transactions: DocumentRepository<Transaction>;
  readonly budgets: DocumentRepository<Budget>;
  readonly goals: DocumentRepository<Goal>;
  readonly loans: DocumentRepository<Loan>;
  readonly recurrenceRules: DocumentRepository<RecurrenceRule & { templateTransactionId: string; lastGenerated?: string | undefined }>;
  readonly shoppingLists: DocumentRepository<ShoppingList>;
  readonly shoppingSessions: DocumentRepository<ShoppingSession>;
  readonly products: DocumentRepository<Product>;
  readonly priceObservations: DocumentRepository<PriceObservation>;
  readonly entitlements: DocumentRepository<Entitlement & { id: string }>;
  readonly kv: KVStore;
  readonly changeLog: ChangeLog;

  constructor(readonly db: Database, clock: Clock = systemClock, deviceId = 'local') {
    const r = <T extends { id: string }>(table: DocumentTable, type: string) => new DocumentRepository<T>(db, table, type, clock, deviceId);
    this.accounts = r<Account>('accounts', 'account');
    this.categories = r<Category>('categories', 'category');
    this.tags = r<Tag>('tags', 'tag');
    this.cards = r<CreditCard>('cards', 'card');
    this.transactions = r<Transaction>('transactions', 'transaction');
    this.budgets = r<Budget>('budgets', 'budget');
    this.goals = r<Goal>('goals', 'goal');
    this.loans = r<Loan>('loans', 'loan');
    this.recurrenceRules = r('recurrence_rules', 'recurrence_rule');
    this.shoppingLists = r<ShoppingList>('shopping_lists', 'shopping_list');
    this.shoppingSessions = r<ShoppingSession>('shopping_sessions', 'shopping_session');
    this.products = r<Product>('products', 'product');
    this.priceObservations = r<PriceObservation>('price_observations', 'price_observation');
    this.entitlements = r('entitlements', 'entitlement');
    this.kv = new KVStore(db, clock);
    this.changeLog = new ChangeLog(db);
  }

  static async open(db: Database, clock?: Clock, deviceId?: string): Promise<DataStore> {
    await migrate(db);
    return new DataStore(db, clock, deviceId);
  }

  async loadLedger(): Promise<Ledger> {
    const [accounts, categories, tags, cards, transactions, budgets, goals, loans, prefs] = await Promise.all([
      this.accounts.all(), this.categories.all(), this.tags.all(), this.cards.all(), this.transactions.all(), this.budgets.all(), this.goals.all(), this.loans.all(), this.kv.get<Partial<UserPrefs>>('prefs'),
    ]);
    return { accounts, categories, tags, cards, transactions, budgets, goals, loans, prefs: { ...DEFAULT_PREFS, ...(prefs ?? {}) } };
  }

  async savePrefs(prefs: UserPrefs) { await this.kv.set('prefs', prefs); }

  /** Replaces every table with the given ledger (backup restore). Runs in one transaction. */
  async replaceAll(ledger: Ledger): Promise<void> {
    await this.db.withTransactionAsync(async () => {
      for (const repo of [this.accounts, this.categories, this.tags, this.cards, this.transactions, this.budgets, this.goals, this.loans]) await repo.purgeAll();
      await this.accounts.upsertMany(ledger.accounts); await this.categories.upsertMany(ledger.categories); await this.tags.upsertMany(ledger.tags); await this.cards.upsertMany(ledger.cards);
      await this.transactions.upsertMany(ledger.transactions); await this.budgets.upsertMany(ledger.budgets); await this.goals.upsertMany(ledger.goals); await this.loans.upsertMany(ledger.loans);
      await this.savePrefs(ledger.prefs);
    });
  }

  /** LGPD: erase everything, including shopping data, preferences and the change log. */
  async eraseAll(): Promise<void> {
    await this.db.withTransactionAsync(async () => {
      for (const repo of [this.accounts, this.categories, this.tags, this.cards, this.transactions, this.budgets, this.goals, this.loans, this.recurrenceRules, this.shoppingLists, this.shoppingSessions, this.products, this.priceObservations, this.entitlements]) await repo.purgeAll();
      await this.db.runAsync('DELETE FROM kv'); await this.db.runAsync('DELETE FROM change_log'); await this.db.runAsync('DELETE FROM attachments');
    });
  }
}
