/**
 * Minimal database abstraction so the same repositories run on expo-sqlite (device), on an in-memory
 * implementation (tests, web preview) and, later, on any SQL engine. Every entity is stored as a
 * JSON document row with indexed metadata columns; the pure domain never touches SQL.
 */
export type Row = Record<string, unknown>;

export interface Database {
  execAsync(sql: string): Promise<void>;
  runAsync(sql: string, params?: unknown[]): Promise<{ changes: number }>;
  getAllAsync<T extends object = Row>(sql: string, params?: unknown[]): Promise<T[]>;
  getFirstAsync<T extends object = Row>(sql: string, params?: unknown[]): Promise<T | null>;
  /** Runs fn inside a transaction; rolls back on throw. Nested calls run in the outer transaction. */
  withTransactionAsync<T>(fn: () => Promise<T>): Promise<T>;
  closeAsync(): Promise<void>;
}

export const DOCUMENT_TABLES = [
  'accounts', 'categories', 'tags', 'cards', 'transactions', 'budgets', 'goals', 'loans', 'recurrence_rules',
  'shopping_lists', 'shopping_sessions', 'products', 'price_observations', 'entitlements',
] as const;
export type DocumentTable = (typeof DOCUMENT_TABLES)[number];

export interface DocumentRow { id: string; json: string; updated_at: string; deleted_at: string | null; version: number; dirty: number; }
