import * as SQLite from 'expo-sqlite';
import type { Database, Row } from './database';

/** expo-sqlite adapter with WAL and foreign keys. */
export class SQLiteDatabase implements Database {
  private constructor(private db: SQLite.SQLiteDatabase) {}
  static async open(name = 'serenacash.db'): Promise<SQLiteDatabase> {
    const db = await SQLite.openDatabaseAsync(name);
    await db.execAsync('PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON; PRAGMA busy_timeout = 3000;');
    return new SQLiteDatabase(db);
  }
  execAsync(sql: string) { return this.db.execAsync(sql); }
  async runAsync(sql: string, params: unknown[] = []) { const r = await this.db.runAsync(sql, params as SQLite.SQLiteBindParams); return { changes: r.changes }; }
  getAllAsync<T extends object = Row>(sql: string, params: unknown[] = []) { return this.db.getAllAsync<T>(sql, params as SQLite.SQLiteBindParams); }
  getFirstAsync<T extends object = Row>(sql: string, params: unknown[] = []) { return this.db.getFirstAsync<T>(sql, params as SQLite.SQLiteBindParams); }
  private depth = 0;
  async withTransactionAsync<T>(fn: () => Promise<T>): Promise<T> {
    if (this.depth > 0) { return fn(); }
    this.depth++;
    try { let out!: T; await this.db.withExclusiveTransactionAsync(async () => { out = await fn(); }); return out; }
    finally { this.depth--; }
  }
  closeAsync() { return this.db.closeAsync(); }
}
