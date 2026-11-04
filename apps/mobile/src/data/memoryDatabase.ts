import type { Database, Row } from './database';

/**
 * In-memory Database used by unit tests and the web preview. It understands exactly the SQL shapes the
 * repositories use (document tables, kv, change_log, PRAGMA user_version). It is not a SQL engine.
 */
export class MemoryDatabase implements Database {
  tables = new Map<string, Map<string, Row>>();
  userVersion = 0;
  private table(name: string) { let t = this.tables.get(name); if (!t) { t = new Map(); this.tables.set(name, t); } return t; }

  async execAsync(sql: string): Promise<void> {
    for (const stmt of sql.split(';').map((s) => s.trim()).filter(Boolean)) {
      const m = stmt.match(/^PRAGMA user_version = (\d+)/i);
      if (m) { this.userVersion = Number(m[1]); continue; }
      const ct = stmt.match(/CREATE TABLE IF NOT EXISTS (\w+)/i);
      if (ct) { this.table(ct[1]!); continue; }
      // indexes, alter table: no-op
    }
  }
  async runAsync(sql: string, params: unknown[] = []): Promise<{ changes: number }> {
    const s = sql.trim();
    let m = s.match(/^INSERT OR REPLACE INTO (\w+) \(([^)]+)\) VALUES/i);
    if (m) {
      const cols = m[2]!.split(',').map((c) => c.trim());
      const row: Row = {}; cols.forEach((c, i) => { row[c] = params[i]; });
      this.table(m[1]!).set(String(row.id ?? row.key), row);
      return { changes: 1 };
    }
    m = s.match(/^UPDATE (\w+) SET (.+) WHERE id = \?$/i);
    if (m) {
      const t = this.table(m[1]!); const row = t.get(String(params[params.length - 1]));
      if (!row) return { changes: 0 };
      const sets = m[2]!.split(',').map((x) => x.trim().split('=')[0]!.trim());
      sets.forEach((col, i) => { row[col] = params[i]; });
      return { changes: 1 };
    }
    m = s.match(/^UPDATE change_log SET synced = 1 WHERE id IN \((.+)\)$/i);
    if (m) { let n = 0; for (const id of params) { const r = this.table('change_log').get(String(id)); if (r) { r.synced = 1; n++; } } return { changes: n }; }
    m = s.match(/^DELETE FROM (\w+) WHERE (id|key) = \?$/i);
    if (m) { return { changes: this.table(m[1]!).delete(String(params[0])) ? 1 : 0 }; }
    m = s.match(/^DELETE FROM (\w+)$/i);
    if (m) { const n = this.table(m[1]!).size; this.table(m[1]!).clear(); return { changes: n }; }
    throw new Error(`MemoryDatabase: SQL não suportado: ${s}`);
  }
  async getAllAsync<T extends object = Row>(sql: string, params: unknown[] = []): Promise<T[]> {
    const s = sql.trim();
    let m = s.match(/^SELECT \* FROM (\w+) WHERE deleted_at IS NULL$/i);
    if (m) return [...this.table(m[1]!).values()].filter((r) => r.deleted_at == null) as T[];
    m = s.match(/^SELECT \* FROM (\w+)$/i);
    if (m) return [...this.table(m[1]!).values()] as T[];
    m = s.match(/^SELECT \* FROM change_log WHERE synced = 0 ORDER BY at(?: LIMIT \?)?$/i);
    if (m) { const rows = [...this.table('change_log').values()].filter((r) => !r.synced).sort((a, b) => String(a.at).localeCompare(String(b.at))); return (params[0] ? rows.slice(0, Number(params[0])) : rows) as T[]; }
    throw new Error(`MemoryDatabase: consulta não suportada: ${s}`);
  }
  async getFirstAsync<T extends object = Row>(sql: string, params: unknown[] = []): Promise<T | null> {
    const s = sql.trim();
    if (/^PRAGMA user_version$/i.test(s)) return { user_version: this.userVersion } as unknown as T;
    let m = s.match(/^SELECT \* FROM (\w+) WHERE (id|key) = \?$/i);
    if (m) return (this.table(m[1]!).get(String(params[0])) as T | undefined) ?? null;
    m = s.match(/^SELECT COUNT\(\*\) AS n FROM (\w+)$/i);
    if (m) return { n: this.table(m[1]!).size } as unknown as T;
    throw new Error(`MemoryDatabase: consulta não suportada: ${s}`);
  }
  private depth = 0; private snapshot: string | null = null;
  async withTransactionAsync<T>(fn: () => Promise<T>): Promise<T> {
    if (this.depth === 0) this.snapshot = JSON.stringify([...this.tables.entries()].map(([k, v]) => [k, [...v.entries()]]));
    this.depth++;
    try { return await fn(); }
    catch (e) { if (this.depth === 1 && this.snapshot) this.tables = new Map((JSON.parse(this.snapshot) as [string, [string, Row][]][]).map(([k, v]) => [k, new Map(v)])); throw e; }
    finally { this.depth--; if (this.depth === 0) this.snapshot = null; }
  }
  async closeAsync(): Promise<void> { /* nothing */ }
}
