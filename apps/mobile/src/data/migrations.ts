import type { Database } from './database';
import { DOCUMENT_TABLES } from './database';

export interface Migration { version: number; name: string; up: (db: Database) => Promise<void>; }

const docTable = (name: string) => `
CREATE TABLE IF NOT EXISTS ${name} (
  id TEXT PRIMARY KEY NOT NULL,
  json TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT,
  version INTEGER NOT NULL DEFAULT 1,
  dirty INTEGER NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS idx_${name}_updated ON ${name}(updated_at);
CREATE INDEX IF NOT EXISTS idx_${name}_deleted ON ${name}(deleted_at);`;

export const MIGRATIONS: Migration[] = [
  {
    version: 1,
    name: 'initial document tables, kv, change_log',
    up: async (db) => {
      for (const t of DOCUMENT_TABLES) await db.execAsync(docTable(t));
      await db.execAsync(`
CREATE TABLE IF NOT EXISTS kv (key TEXT PRIMARY KEY NOT NULL, json TEXT NOT NULL, updated_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS change_log (
  id TEXT PRIMARY KEY NOT NULL, entity_type TEXT NOT NULL, entity_id TEXT NOT NULL, op TEXT NOT NULL,
  payload TEXT, version INTEGER NOT NULL, device_id TEXT NOT NULL, at TEXT NOT NULL, synced INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_change_log_synced ON change_log(synced, at);
CREATE TABLE IF NOT EXISTS attachments (id TEXT PRIMARY KEY NOT NULL, transaction_id TEXT NOT NULL, file_name TEXT NOT NULL, mime_type TEXT NOT NULL, size_bytes INTEGER NOT NULL, sha256 TEXT NOT NULL, created_at TEXT NOT NULL);
CREATE INDEX IF NOT EXISTS idx_attachments_tx ON attachments(transaction_id);`);
    },
  },
  {
    version: 2,
    name: 'transaction query indexes (date, kind) via generated columns',
    up: async (db) => {
      // SQLite ≥ 3.31 supports generated columns; expo-sqlite bundles a recent SQLite. Fallback-safe: wrapped in try.
      try {
        await db.execAsync(`ALTER TABLE transactions ADD COLUMN date TEXT GENERATED ALWAYS AS (json_extract(json, '$.date')) VIRTUAL;`);
        await db.execAsync(`ALTER TABLE transactions ADD COLUMN kind TEXT GENERATED ALWAYS AS (json_extract(json, '$.kind')) VIRTUAL;`);
        await db.execAsync(`CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date); CREATE INDEX IF NOT EXISTS idx_transactions_kind ON transactions(kind);`);
      } catch {
        /* older engines: queries still work through json_extract without the index */
      }
    },
  },
];

export async function migrate(db: Database, migrations: Migration[] = MIGRATIONS): Promise<{ from: number; to: number }> {
  const row = await db.getFirstAsync<{ user_version: number }>('PRAGMA user_version');
  const from = Number(row?.user_version ?? 0);
  let current = from;
  for (const m of migrations.sort((a, b) => a.version - b.version)) {
    if (m.version <= current) continue;
    await db.withTransactionAsync(async () => {
      await m.up(db);
      await db.execAsync(`PRAGMA user_version = ${m.version}`);
    });
    current = m.version;
  }
  return { from, to: current };
}
