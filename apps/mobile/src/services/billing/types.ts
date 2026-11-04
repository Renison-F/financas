import type { Entitlement, PlanId } from '@financas/core';

export interface StoreOffer { planId: PlanId; productId: string; priceString: string; priceMicros?: number | undefined; currency?: string | undefined; period?: string | undefined; introPriceString?: string | undefined; }

/**
 * Single interface for the store billing provider. Implementations: RevenueCat (device, dev build) and
 * Unavailable (Expo Go / web), which shows the paywall without purchase buttons. The app never trusts a
 * local flag: entitlements come from the provider (verified server-side) and are cached with a timestamp.
 */
export interface BillingProvider {
  readonly name: string;
  readonly available: boolean;
  configure(): Promise<void>;
  getOffers(): Promise<StoreOffer[]>;
  purchase(offer: StoreOffer): Promise<Entitlement[]>;
  restore(): Promise<Entitlement[]>;
  getEntitlements(): Promise<Entitlement[]>;
  manageSubscriptionsUrl?(): Promise<string | null>;
}
