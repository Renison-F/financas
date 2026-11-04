import { describe, it, expect } from 'vitest';
import { resolveAccess, hasFeature, withinLimit, mergeEntitlements, type Entitlement } from './entitlements';
import { PLANS, FREE_LIMITS } from './catalog';

const now = new Date('2026-11-04T12:00:00Z');
const iso = (d: string) => new Date(d).toISOString();
const ent = (p: Partial<Entitlement>): Entitlement => ({ planId: 'plus_monthly', state: 'active', verifiedAt: iso('2026-11-04T11:00:00Z'), source: 'store_verified', ...p });

describe('entitlements', () => {
  it('free by default, with limits', () => {
    const a = resolveAccess([], now);
    expect(a.tier).toBe('free');
    expect(withinLimit(a, 'cards', 0)).toEqual({ ok: true, limit: FREE_LIMITS.cards, remaining: 1 });
    expect(withinLimit(a, 'cards', 1).ok).toBe(false);
    expect(hasFeature(a, 'pdf_export')).toBe(false);
  });
  it('active subscription unlocks plus features without limits', () => {
    const a = resolveAccess([ent({ expiresAt: iso('2026-12-04T00:00:00Z') })], now);
    expect(a.tier).toBe('plus');
    expect(hasFeature(a, 'sync')).toBe(true);
    expect(withinLimit(a, 'cards', 99).ok).toBe(true);
  });
  it('expired, refunded and paused do not unlock', () => {
    expect(resolveAccess([ent({ expiresAt: iso('2026-11-01T00:00:00Z') })], now).tier).toBe('free');
    expect(resolveAccess([ent({ state: 'refunded' })], now).tier).toBe('free');
    expect(resolveAccess([ent({ state: 'paused' })], now).tier).toBe('free');
    expect(resolveAccess([ent({ state: 'expired' })], now).tier).toBe('free');
  });
  it('grace period and billing issue keep access even past expiry', () => {
    expect(resolveAccess([ent({ state: 'in_grace_period', expiresAt: iso('2026-11-01T00:00:00Z') })], now).reason).toContain('problema de cobrança');
    expect(resolveAccess([ent({ state: 'billing_issue', expiresAt: iso('2026-11-01T00:00:00Z') })], now).tier).toBe('plus');
  });
  it('cancelled subscriptions stay active until expiry', () => {
    expect(resolveAccess([ent({ state: 'cancelled_active_until_expiry', expiresAt: iso('2026-11-20T00:00:00Z') })], now).tier).toBe('plus');
    expect(resolveAccess([ent({ state: 'cancelled_active_until_expiry', expiresAt: iso('2026-11-02T00:00:00Z') })], now).tier).toBe('free');
  });
  it('cached proofs are honored for 7 days offline, then downgraded', () => {
    expect(resolveAccess([ent({ source: 'cached', verifiedAt: iso('2026-11-01T00:00:00Z'), expiresAt: iso('2027-01-01T00:00:00Z') })], now).tier).toBe('plus');
    expect(resolveAccess([ent({ source: 'cached', verifiedAt: iso('2026-10-01T00:00:00Z'), expiresAt: iso('2027-01-01T00:00:00Z') })], now).tier).toBe('free');
  });
  it('lifetime wins and excludes sync', () => {
    const a = resolveAccess([ent({ planId: 'lifetime', state: 'active' }), ent({ expiresAt: iso('2026-12-04T00:00:00Z') })], now);
    expect(a.tier).toBe('lifetime');
    expect(hasFeature(a, 'sync')).toBe(false);
    expect(hasFeature(a, 'unlimited_ocr')).toBe(true);
  });
  it('merges by freshest verification per plan', () => {
    const m = mergeEntitlements([ent({ verifiedAt: iso('2026-11-01T00:00:00Z'), state: 'expired' })], [ent({ verifiedAt: iso('2026-11-04T00:00:00Z'), state: 'active' })]);
    expect(m).toHaveLength(1);
    expect(m[0]!.state).toBe('active');
  });
  it('catalog: store product ids are distinct between lifetime and subscriptions (RevenueCat gotcha)', () => {
    const ids = PLANS.flatMap((p) => [p.products.ios, p.products.android]).filter(Boolean);
    const lifetime = PLANS.find((p) => p.id === 'lifetime')!;
    for (const p of PLANS) if (p.id !== 'lifetime') { expect(p.products.ios).not.toBe(lifetime.products.ios); expect(p.products.android).not.toBe(lifetime.products.android); }
    expect(ids.length).toBeGreaterThan(0);
  });
});
