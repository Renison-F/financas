/// Entitlements port: the only source of truth is the provider (RevenueCat); the app keeps a short,
/// signed-by-provider cache for offline use (see billing.dart `cacheGraceMs`).
library;

import '../billing/billing.dart';

abstract interface class EntitlementsProvider {
  Future<Entitlement?> refresh();
  Stream<Entitlement?> watch();
  Future<void> restorePurchases();
}

class UnavailableBilling implements EntitlementsProvider {
  const UnavailableBilling();
  @override
  Future<Entitlement?> refresh() async => null;
  @override
  Stream<Entitlement?> watch() => Stream.value(null);
  @override
  Future<void> restorePurchases() async {}
}
