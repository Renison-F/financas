import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:serenacash/data/billing/revenuecat_billing.dart';
import 'package:serenacash/domain/billing/billing.dart';

EntitlementInfo info({
  String id = 'plus',
  String product = 'br.com.serenacash.plus.yearly',
  String? expires = '2027-01-01T00:00:00Z',
  String? billingIssue,
  String? unsubscribed,
  bool willRenew = true,
}) => EntitlementInfo(
  id,
  true,
  willRenew,
  '2026-11-01T00:00:00Z',
  '2026-11-01T00:00:00Z',
  product,
  false,
  ownershipType: OwnershipType.purchased,
  store: Store.appStore,
  periodType: PeriodType.normal,
  expirationDate: expires,
  unsubscribeDetectedAt: unsubscribed,
  billingIssueDetectedAt: billingIssue,
  verification: VerificationResult.verified,
);

void main() {
  const now = '2026-11-04T12:00:00.000Z';
  test('maps product ids to plans and states; lifetime excludes sync', () {
    final e = entitlementsFromRevenueCat([info()], nowISO: now).single;
    expect(e.planId, PlanId.plusYearly);
    expect(e.state, SubscriptionState.active);
    expect(e.source, EntitlementSource.storeVerified);
    expect(e.verifiedAt, now);
    expect(e.expiresAt, '2027-01-01T00:00:00Z');
    final access = resolveAccess([e], DateTime.parse(now));
    expect(access.tier, 'plus');
    expect(access.features, contains('sync'));

    final life = entitlementsFromRevenueCat([
      info(
        id: 'lifetime',
        product: 'br.com.serenacash.lifetime',
        expires: null,
      ),
    ], nowISO: now).single;
    expect(life.planId, PlanId.lifetime);
    final la = resolveAccess([life], DateTime.parse(now));
    expect(la.tier, 'lifetime');
    expect(la.features, isNot(contains('sync')));
  });

  test('billing issue and cancellation states are preserved; google base plan ids resolve', () {
    expect(
      entitlementsFromRevenueCat([
        info(billingIssue: '2026-11-03T00:00:00Z'),
      ], nowISO: now).single.state,
      SubscriptionState.billingIssue,
    );
    expect(
      entitlementsFromRevenueCat([
        info(unsubscribed: '2026-11-03T00:00:00Z', willRenew: false),
      ], nowISO: now).single.state,
      SubscriptionState.cancelledActiveUntilExpiry,
    );
    expect(planForProduct('serenacash_plus:yearly'), isNotNull);
    expect(planForProduct('unknown'), isNull);
  });

  test('unknown product falls back by entitlement identifier', () {
    expect(
      entitlementsFromRevenueCat([
        info(id: 'lifetime', product: 'x'),
      ], nowISO: now).single.planId,
      PlanId.lifetime,
    );
    expect(
      entitlementsFromRevenueCat([
        info(id: 'plus', product: 'x'),
      ], nowISO: now).single.planId,
      PlanId.plusMonthly,
    );
  });
}
