import { Platform } from 'react-native';
import type { BillingProvider } from './types';
import { UnavailableBilling } from './unavailable';
import { RevenueCatBilling } from './revenuecat';

let provider: BillingProvider | null = null;

/** Picks the provider once: RevenueCat when configured on device, otherwise the "unavailable" implementation. */
export async function getBilling(): Promise<BillingProvider> {
  if (provider) return provider;
  const rc = Platform.OS !== 'web' ? new RevenueCatBilling() : null;
  if (rc) { await rc.configure(); if (rc.available) { provider = rc; return rc; } }
  provider = new UnavailableBilling();
  await provider.configure();
  return provider;
}
export type { BillingProvider, StoreOffer } from './types';
