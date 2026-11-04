import type { Database, DocumentTable, DocumentRow } from './database';

export interface Clock { nowISO(): string; }
export const systemClock: Clock = { nowISO: () => new Date().toISOString() };

export interface Entity { id: string; updatedAt?: string; deletedAt?: string | undefined; }

/**
 * Generic JSON-document repository. All writes are logged in change_log (for future sync) and marked dirty.
 * Soft delete keeps the row with deleted_at so sync can propagate deletions; `purge` hard-deletes.
 */
export class DocumentRepository<T extends Entity> {
  constructor(protected db: Database, protected table: DocumentTable, protected entityType: string, protected clock: Clock = systemClock, protected deviceId = 'local') {}

  async all(includeDeleted = false): Promise<T[]> {
    const rows = includeDeleted ? await this.db.getAllAsync<DocumentRow>(`SELECT * FROM ${this.table}`) : await this.db.getAllAsync<DocumentRow>(`SELECT * FROM ${this.table} WHERE deleted_at IS NULL`);
    return rows.map((r) => JSON.parse(r.json) as T);
  }
  async get(id: string): Promise<T | null> {
    const row = await this.db.getFirstAsync<DocumentRow>(`SELECT * FROM ${this.table} WHERE id = ?`, [id]);
    return row && !row.deleted_at ? (JSON.parse(row.json) as T) : null;
  }
  async upsert(entity: T): Promise<T> {
    const now = this.clock.nowISO();
    const existing = await this.db.getFirstAsync<DocumentRow>(`SELECT * FROM ${this.table} WHERE id = ?`, [entity.id]);
    const version = (existing?.version ?? 0) + 1;
    const saved = { ...entity, updatedAt: now, deletedAt: undefined } as T;
    await this.db.withTransactionAsync(async () => {
      await this.db.runAsync(`INSERT OR REPLACE INTO ${this.table} (id, json, updated_at, deleted_at, version, dirty) VALUES (?, ?, ?, ?, ?, ?)`, [entity.id, JSON.stringify(saved), now, null, version, 1]);
      await this.log(entity.id, 'upsert', saved, version, now);
    });
    return saved;
  }
  async upsertMany(entities: T[]): Promise<void> { await this.db.withTransactionAsync(async () => { for (const e of entities) await this.upsert(e); }); }
  async softDelete(id: string): Promise<boolean> {
    const existing = await this.db.getFirstAsync<DocumentRow>(`SELECT * FROM ${this.table} WHERE id = ?`, [id]);
    if (!existing) return false;
    const now = this.clock.nowISO();
    const version = existing.version + 1;
    const doc = { ...(JSON.parse(existing.json) as T), deletedAt: now, updatedAt: now };
    await this.db.withTransactionAsync(async () => {
      await this.db.runAsync(`UPDATE ${this.table} SET json = ?, updated_at = ?, deleted_at = ?, version = ?, dirty = ? WHERE id = ?`, [JSON.stringify(doc), now, now, version, 1, id]);
      await this.log(id, 'delete', undefined, version, now);
    });
    return true;
  }
  async purgeAll(): Promise<void> { await this.db.runAsync(`DELETE FROM ${this.table}`); }
  async count(): Promise<number> { const r = await this.db.getFirstAsync<{ n: number }>(`SELECT COUNT(*) AS n FROM ${this.table}`); return Number(r?.n ?? 0); }

  private async log(entityId: string, op: 'upsert' | 'delete', payload: unknown, version: number, at: string) {
    const id = `${at}-${this.entityType}-${entityId}-${version}`;
    await this.db.runAsync('INSERT OR REPLACE INTO change_log (id, entity_type, entity_id, op, payload, version, device_id, at, synced) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', [id, this.entityType, entityId, op, payload ? JSON.stringify(payload) : null, version, this.deviceId, at, 0]);
  }
}

/** Key/value store for prefs, dashboard layout, onboarding flags, entitlement cache. */
export class KVStore {
  constructor(private db: Database, private clock: Clock = systemClock) {}
  async get<T>(key: string): Promise<T | null> { const r = await this.db.getFirstAsync<{ json: string }>('SELECT * FROM kv WHERE key = ?', [key]); return r ? (JSON.parse(r.json) as T) : null; }
  async set<T>(key: string, value: T): Promise<void> { await this.db.runAsync('INSERT OR REPLACE INTO kv (key, json, updated_at) VALUES (?, ?, ?)', [key, JSON.stringify(value), this.clock.nowISO()]); }
  async remove(key: string): Promise<void> { await this.db.runAsync('DELETE FROM kv WHERE key = ?', [key]); }
}

export interface ChangeLogRow { id: string; entity_type: string; entity_id: string; op: string; payload: string | null; version: number; device_id: string; at: string; synced: number; }
export class ChangeLog {
  constructor(private db: Database) {}
  pending(limit = 500) { return this.db.getAllAsync<ChangeLogRow>('SELECT * FROM change_log WHERE synced = 0 ORDER BY at LIMIT ?', [limit]); }
  async markSynced(ids: string[]) { if (ids.length) await this.db.runAsync(`UPDATE change_log SET synced = 1 WHERE id IN (${ids.map(() => '?').join(', ')})`, ids); }
}
