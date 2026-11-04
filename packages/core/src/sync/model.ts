/**
 * Offline-first synchronization model (transport not chosen yet). Every entity row carries
 * `version` and `updatedAt`; local writes append a ChangeRecord. A future SyncTransport pushes
 * pending changes and pulls remote ones; conflicts on monetary fields are never auto-resolved.
 */
export type EntityType = 'account' | 'category' | 'tag' | 'card' | 'transaction' | 'budget' | 'goal' | 'loan' | 'prefs' | 'dashboard_layout' | 'shopping_list' | 'shopping_item' | 'shopping_session' | 'product' | 'price_observation';

export interface ChangeRecord {
  id: string;
  entityType: EntityType;
  entityId: string;
  op: 'upsert' | 'delete';
  /** full entity snapshot after the change (upsert) */
  payload?: Record<string, unknown> | undefined;
  version: number;
  deviceId: string;
  at: string; // ISO datetime
  synced: boolean;
}

export type SyncStatus = 'local_only' | 'synced' | 'pending' | 'conflict';

export interface Conflict { entityType: EntityType; entityId: string; local: Record<string, unknown>; remote: Record<string, unknown>; fields: string[]; detectedAt: string; }

export interface SyncTransport {
  push(changes: ChangeRecord[]): Promise<{ accepted: string[]; rejected: { id: string; reason: string }[] }>;
  pull(sinceCursor: string | null): Promise<{ changes: ChangeRecord[]; cursor: string }>;
}

const MONETARY_FIELDS = new Set(['amountCents', 'paidCents', 'openingBalanceCents', 'limitCents', 'targetCents', 'principalCents']);

/**
 * Merge rule: last-writer-wins per field by `updatedAt`, EXCEPT monetary fields and status, which produce
 * a Conflict when both sides changed them differently since the common base.
 */
export function mergeEntity(base: Record<string, unknown> | undefined, local: Record<string, unknown>, remote: Record<string, unknown>, entityType: EntityType, entityId: string, now: string): { merged: Record<string, unknown>; conflict?: Conflict | undefined } {
  const merged: Record<string, unknown> = { ...remote, ...local };
  const conflictFields: string[] = [];
  const keys = new Set([...Object.keys(local), ...Object.keys(remote)]);
  for (const k of keys) {
    const lv = local[k], rv = remote[k], bv = base?.[k];
    const same = JSON.stringify(lv) === JSON.stringify(rv);
    if (same) { merged[k] = lv; continue; }
    const localChanged = JSON.stringify(lv) !== JSON.stringify(bv);
    const remoteChanged = JSON.stringify(rv) !== JSON.stringify(bv);
    if (localChanged && !remoteChanged) merged[k] = lv;
    else if (!localChanged && remoteChanged) merged[k] = rv;
    else if (MONETARY_FIELDS.has(k) || k === 'status') { conflictFields.push(k); merged[k] = lv; }
    else merged[k] = String(local.updatedAt ?? '') >= String(remote.updatedAt ?? '') ? lv : rv;
  }
  return conflictFields.length ? { merged, conflict: { entityType, entityId, local, remote, fields: conflictFields, detectedAt: now } } : { merged };
}
