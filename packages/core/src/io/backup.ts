import type { Ledger } from '../domain/types';

export const BACKUP_SCHEMA_VERSION = 1;

export interface BackupFile { app: 'serenacash'; schemaVersion: number; exportedAt: string; ledger: Ledger; }

export function createBackup(ledger: Ledger, exportedAt = new Date().toISOString()): BackupFile {
  return { app: 'serenacash', schemaVersion: BACKUP_SCHEMA_VERSION, exportedAt, ledger };
}

export function validateBackup(x: unknown): { ok: true; backup: BackupFile } | { ok: false; error: string } {
  if (!x || typeof x !== 'object') return { ok: false, error: 'Arquivo não é um backup válido.' };
  const b = x as Partial<BackupFile>;
  if (b.app !== 'serenacash') return { ok: false, error: 'Este arquivo não é um backup do SerenaCash.' };
  if (typeof b.schemaVersion !== 'number' || b.schemaVersion > BACKUP_SCHEMA_VERSION) return { ok: false, error: 'Backup de uma versão mais nova do app. Atualize o aplicativo.' };
  const l = b.ledger as Partial<Ledger> | undefined;
  if (!l || typeof l !== 'object') return { ok: false, error: 'Backup sem dados.' };
  for (const k of ['accounts', 'categories', 'tags', 'cards', 'transactions', 'budgets', 'goals', 'loans'] as const) {
    if (!Array.isArray(l[k])) return { ok: false, error: `Backup corrompido: falta "${k}".` };
  }
  if (!l.prefs || typeof l.prefs !== 'object') return { ok: false, error: 'Backup corrompido: faltam preferências.' };
  return { ok: true, backup: b as BackupFile };
}
