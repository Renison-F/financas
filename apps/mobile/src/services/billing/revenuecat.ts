import { Platform } from 'react-native';
import type { Entitlement, PlanId } from '@financas/core';
import { PLANS } from '@financas/core';
import type { BillingProvider, StoreOffer } from './types';

/**
 * RevenueCat adapter. The SDK (react-native-purchases) is loaded lazily so the app still runs where it is not
 * linked (Expo Go, web). Keys come from env (EXPO_PUBLIC_RC_IOS_KEY / EXPO_PUBLIC_RC_ANDROID_KEY), never from code.
 * Entitlement identifier in the RevenueCat dashboard must be "plus" (subscriptions) and "lifetime" (non-consumable).
 */
type PurchasesModule = typeof import('react-native-purchases');

export class RevenueCatBilling implements BillingProvider {
  readonly name = 'revenuecat';
  available = false;
  private P: PurchasesModule['default'] | null = null;
  private key = Platform.OS === 'ios' ? process.env.EXPO_PUBLIC_RC_IOS_KEY : process.env.EXPO_PUBLIC_RC_ANDROID_KEY;

  async configure() {
    if (!this.key || Platform.OS === 'web') return;
    try {
      const mod = (await import('react-native-purchases')) as PurchasesModule;
      this.P = mod.default;
      this.P.configure({ apiKey: this.key });
      this.available = true;
    } catch { this.available = false; }
  }
  private planFor(productId: string): PlanId | null {
    for (const p of PLANS) if (p.products.ios === productId || p.products.android === productId || productId.startsWith(p.products.android ?? '§')) return p.id;
    return null;
  }
  async getOffers(): Promise<StoreOffer[]> {
    if (!this.P) return [];
    const offerings = await this.P.getOfferings();
    const pkgs = offerings.current?.availablePackages ?? [];
    return pkgs.map((pkg) => {
      const prod = pkg.product;
      const planId = this.planFor(prod.identifier) ?? (pkg.packageType === 'LIFETIME' ? 'lifetime' : pkg.packageType === 'ANNUAL' ? 'plus_yearly' : 'plus_monthly');
      return { planId, productId: prod.identifier, priceString: prod.priceString, currency: prod.currencyCode, period: prod.subscriptionPeriod ?? undefined, introPriceString: prod.introPrice?.priceString };
    });
  }
  private toEntitlements(info: { entitlements: { active: Record<string, { identifier: string; productIdentifier: string; expirationDate: string | null; latestPurchaseDate: string; willRenew: boolean; billingIssueDetectedAt: string | null; unsubscribeDetectedAt: string | null }> } }): Entitlement[] {
    const now = new Date().toISOString();
    return Object.values(info.entitlements.active).map((e) => {
      const planId = this.planFor(e.productIdentifier) ?? (e.identifier === 'lifetime' ? 'lifetime' : 'plus_monthly');
      const state: Entitlement['state'] = e.billingIssueDetectedAt ? 'billing_issue' : e.unsubscribeDetectedAt ? 'cancelled_active_until_expiry' : 'active';
      return { planId, state, expiresAt: e.expirationDate ?? undefined, verifiedAt: now, source: 'store_verified', transactionRef: e.latestPurchaseDate, willRenew: e.willRenew };
    });
  }
  async purchase(offer: StoreOffer): Promise<Entitlement[]> {
    if (!this.P) throw new Error('Compras indisponíveis.');
    const offerings = await this.P.getOfferings();
    const pkg = offerings.current?.availablePackages.find((p) => p.product.identifier === offer.productId);
    if (!pkg) throw new Error('Oferta não encontrada na loja.');
    const { customerInfo } = await this.P.purchasePackage(pkg);
    return this.toEntitlements(customerInfo as never);
  }
  async restore(): Promise<Entitlement[]> { if (!this.P) return []; return this.toEntitlements((await this.P.restorePurchases()) as never); }
  async getEntitlements(): Promise<Entitlement[]> { if (!this.P) return []; return this.toEntitlements((await this.P.getCustomerInfo()) as never); }
  async manageSubscriptionsUrl() { if (!this.P) return null; const info = await this.P.getCustomerInfo(); return info.managementURL ?? null; }
}
