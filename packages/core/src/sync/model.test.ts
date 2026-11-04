import { describe, it, expect } from 'vitest';
import { mergeEntity } from './model';

describe('sync merge', () => {
  const base = { id: 't', amountCents: 1000, description: 'a', status: 'planned', updatedAt: '2026-11-01T00:00:00Z' };
  it('takes the only changed side per field', () => {
    const r = mergeEntity(base, { ...base, description: 'local' }, { ...base, status: 'settled' }, 'transaction', 't', 'now');
    expect(r.merged).toMatchObject({ description: 'local', status: 'settled' });
    expect(r.conflict).toBeUndefined();
  });
  it('flags monetary conflicts instead of resolving silently', () => {
    const r = mergeEntity(base, { ...base, amountCents: 2000, updatedAt: '2026-11-02T00:00:00Z' }, { ...base, amountCents: 3000, updatedAt: '2026-11-03T00:00:00Z' }, 'transaction', 't', 'now');
    expect(r.conflict?.fields).toEqual(['amountCents']);
    expect(r.merged.amountCents).toBe(2000); // keeps local until the user decides
  });
  it('uses last-writer-wins for non-monetary double edits', () => {
    const r = mergeEntity(base, { ...base, description: 'L', updatedAt: '2026-11-02T00:00:00Z' }, { ...base, description: 'R', updatedAt: '2026-11-03T00:00:00Z' }, 'transaction', 't', 'now');
    expect(r.merged.description).toBe('R');
    expect(r.conflict).toBeUndefined();
  });
});
