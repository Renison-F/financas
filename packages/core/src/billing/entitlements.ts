import { PLANS, FREE_LIMITS, type FeatureKey, type PlanId } from './catalog';

/**
 * Entitlement state as reported by the billing provider (RevenueCat / StoreKit / Play Billing),
 * normalized. The app never computes "premium" from a local flag alone: `source` and `verifiedAt`
 * tell where the proof came from; `expiresAt` drives expiration; grace/billing-issue states keep
 * access while the store retries payment, as both stores require.
 */
export type EntitlementSource = 'store_verified' | 'cached' | 'none';
export type SubscriptionState = 'active' | 'in_grace_period' | 'billing_issue' | 'cancelled_active_until_expiry' | 'expired' | 'refunded' | 'paused';

export interface Entitlement {
  planId: PlanId;
  state: SubscriptionState;
  /** ISO datetime; undefined for lifetime */
  expiresAt?: string | undefined;
  /** when the store/provider last confirmed this */
  verifiedAt: string;
  source: EntitlementSource;
  /** original purchase id for support; never a receipt body */
  transactionRef?: string | undefined;
  willRenew?: boolean | undefined;
}

export interface Access {
  tier: 'free' | 'plus' | 'lifetime';
  planId: PlanId;
  features: ReadonlySet<FeatureKey>;
  limits: typeof FREE_LIMITS | null;
  reason: string;
  /** cached proof older than this many ms is still honored offline (stores allow this); after it, downgrade to free */
  staleAfterMs: number;
}

export const CACHE_GRACE_MS = 7 * 24 * 60 * 60 * 1000; // 7 days offline tolerance

const ACTIVE_STATES: ReadonlySet<SubscriptionState> = new Set(['active', 'in_grace_period', 'billing_issue', 'cancelled_active_until_expiry']);

export function resolveAccess(entitlements: Entitlement[], now: Date): Access {
  const nowMs = now.getTime();
  const free: Access = { tier: 'free', planId: 'free', features: new Set(), limits: FREE_LIMITS, reason: 'Plano gratuito', staleAfterMs: CACHE_GRACE_MS };
  // lifetime first (strongest), then any active subscription
  const candidates = entitlements.filter((e) => {
    if (e.source === 'none') return false;
    if (e.state === 'refunded' || e.state === 'expired' || e.state === 'paused') return false;
    if (e.source === 'cached' && nowMs - Date.parse(e.verifiedAt) > CACHE_GRACE_MS) return false;
    if (e.expiresAt && Date.parse(e.expiresAt) < nowMs && e.state !== 'in_grace_period' && e.state !== 'billing_issue') return false;
    return ACTIVE_STATES.has(e.state);
  });
  const lifetime = candidates.find((e) => e.planId === 'lifetime');
  const chosen = lifetime ?? candidates.find((e) => e.planId === 'plus_yearly') ?? candidates.find((e) => e.planId === 'plus_monthly');
  if (!chosen) return free;
  const plan = PLANS.find((p) => p.id === chosen.planId)!;
  const reason = chosen.planId === 'lifetime' ? 'Licença vitalícia' : chosen.state === 'in_grace_period' || chosen.state === 'billing_issue' ? 'Assinatura com problema de cobrança (acesso mantido temporariamente)' : chosen.state === 'cancelled_active_until_expiry' ? 'Assinatura cancelada, ativa até o fim do período' : 'Assinatura ativa';
  return { tier: plan.tier, planId: plan.id, features: new Set(plan.features), limits: null, reason, staleAfterMs: CACHE_GRACE_MS };
}

export function hasFeature(access: Access, feature: FeatureKey): boolean { return access.features.has(feature); }

export type LimitKey = keyof typeof FREE_LIMITS;

/** Checks a count against the free limit. Premium tiers have no limits. */
export function withinLimit(access: Access, key: LimitKey, currentCount: number): { ok: boolean; limit: number | null; remaining: number | null } {
  if (!access.limits) return { ok: true, limit: null, remaining: null };
  const limit = access.limits[key];
  return { ok: currentCount < limit, limit, remaining: Math.max(0, limit - currentCount) };
}

/** Merge rule when the provider reports several entitlements for the same plan: keep the freshest verification. */
export function mergeEntitlements(existing: Entitlement[], incoming: Entitlement[]): Entitlement[] {
  const map = new Map<PlanId, Entitlement>();
  for (const e of [...existing, ...incoming]) {
    const cur = map.get(e.planId);
    if (!cur || Date.parse(e.verifiedAt) >= Date.parse(cur.verifiedAt)) map.set(e.planId, e);
  }
  return [...map.values()];
}
