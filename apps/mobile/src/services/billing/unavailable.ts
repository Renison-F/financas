import type { BillingProvider, StoreOffer } from './types';
import type { Entitlement } from '@financas/core';

/** Used on web, in Expo Go and when the provider has no API key: paywall renders without purchase buttons. */
export class UnavailableBilling implements BillingProvider {
  readonly name = 'unavailable';
  readonly available = false;
  async configure() {}
  async getOffers(): Promise<StoreOffer[]> { return []; }
  async purchase(): Promise<Entitlement[]> { throw new Error('Compras não estão disponíveis nesta versão do app.'); }
  async restore(): Promise<Entitlement[]> { return []; }
  async getEntitlements(): Promise<Entitlement[]> { return []; }
}
