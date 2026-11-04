/// Store billing port for the paywall. v1 ships [UnavailableStoreBilling]; the RevenueCat implementation
/// (purchases_flutter) lands in M8 behind the same interface, so no business rule depends on the SDK.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/billing/billing.dart';

class StoreOffer {
  const StoreOffer({
    required this.planId,
    required this.productId,
    required this.priceString,
    this.period,
  });
  final PlanId planId;
  final String productId;
  final String priceString;
  final String? period;
}

class BillingError implements Exception {
  BillingError(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class StoreBilling {
  Future<bool> available();
  Future<List<StoreOffer>> offers();
  Future<List<Entitlement>> entitlements();
  Future<List<Entitlement>> purchase(StoreOffer offer);
  Future<List<Entitlement>> restore();
}

class UnavailableStoreBilling implements StoreBilling {
  const UnavailableStoreBilling();
  @override
  Future<bool> available() async => false;
  @override
  Future<List<StoreOffer>> offers() async => const [];
  @override
  Future<List<Entitlement>> entitlements() async => const [];
  @override
  Future<List<Entitlement>> purchase(StoreOffer offer) =>
      throw BillingError('Loja indisponível');
  @override
  Future<List<Entitlement>> restore() async => const [];
}

final storeBillingProvider = Provider<StoreBilling>(
  (_) => const UnavailableStoreBilling(),
);
