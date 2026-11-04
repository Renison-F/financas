/// RevenueCat adapter behind [StoreBilling]. API keys come from `--dart-define=RC_IOS_KEY=... RC_ANDROID_KEY=...`
/// (never from source). Entitlement identifiers in the RevenueCat dashboard: `plus` (subscriptions) and
/// `lifetime` (non-consumable). Business rules never see the SDK: they consume normalized [Entitlement]s.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/billing/billing.dart';
import 'store_billing.dart';

const rcIosKey = String.fromEnvironment('RC_IOS_KEY');
const rcAndroidKey = String.fromEnvironment('RC_ANDROID_KEY');

/// Pure mapping from RevenueCat entitlements to the domain, kept separate for unit tests.
List<Entitlement> entitlementsFromRevenueCat(
  Iterable<EntitlementInfo> active, {
  required String nowISO,
}) => [
  for (final e in active)
    Entitlement(
      planId:
          planForProduct(e.productIdentifier) ??
          (e.identifier == 'lifetime' ? PlanId.lifetime : PlanId.plusMonthly),
      state: e.billingIssueDetectedAt != null
          ? SubscriptionState.billingIssue
          : e.unsubscribeDetectedAt != null
          ? SubscriptionState.cancelledActiveUntilExpiry
          : SubscriptionState.active,
      expiresAt: e.expirationDate,
      verifiedAt: nowISO,
      source: EntitlementSource.storeVerified,
      transactionRef: e.latestPurchaseDate,
      willRenew: e.willRenew,
    ),
];

PlanId? planForProduct(String productId) {
  for (final p in plans) {
    if (p.iosProduct == productId || p.androidProduct == productId) return p.id;
    if (p.androidProduct != null &&
        productId.startsWith('${p.androidProduct}:')) {
      return p.id;
    }
  }
  return null;
}

PlanId planForPackage(Package pkg) =>
    planForProduct(pkg.storeProduct.identifier) ??
    switch (pkg.packageType) {
      PackageType.lifetime => PlanId.lifetime,
      PackageType.annual => PlanId.plusYearly,
      _ => PlanId.plusMonthly,
    };

class RevenueCatBilling implements StoreBilling {
  RevenueCatBilling({String? iosKey, String? androidKey})
    : _key = Platform.isIOS
          ? (iosKey ?? rcIosKey)
          : (androidKey ?? rcAndroidKey);
  final String _key;
  bool _configured = false;

  Future<bool> _ensure() async {
    if (_configured) return true;
    if (_key.isEmpty || !(Platform.isAndroid || Platform.isIOS)) return false;
    try {
      if (!await Purchases.isConfigured) {
        await Purchases.setLogLevel(
          kReleaseMode ? LogLevel.warn : LogLevel.info,
        );
        await Purchases.configure(PurchasesConfiguration(_key));
      }
      _configured = true;
    } catch (_) {
      _configured = false;
    }
    return _configured;
  }

  @override
  Future<bool> available() => _ensure();

  @override
  Future<List<StoreOffer>> offers() async {
    if (!await _ensure()) return const [];
    final offerings = await Purchases.getOfferings();
    final pkgs = offerings.current?.availablePackages ?? const <Package>[];
    return [
      for (final pkg in pkgs)
        StoreOffer(
          planId: planForPackage(pkg),
          productId: pkg.storeProduct.identifier,
          priceString: pkg.storeProduct.priceString,
          period: pkg.packageType == PackageType.annual
              ? 'year'
              : pkg.packageType == PackageType.monthly
              ? 'month'
              : null,
        ),
    ];
  }

  @override
  Future<List<Entitlement>> entitlements() async {
    if (!await _ensure()) return const [];
    final info = await Purchases.getCustomerInfo();
    return entitlementsFromRevenueCat(
      info.entitlements.active.values,
      nowISO: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<List<Entitlement>> purchase(StoreOffer offer) async {
    if (!await _ensure()) throw BillingError('Compras indisponíveis.');
    final offerings = await Purchases.getOfferings();
    final pkg = offerings.current?.availablePackages
        .where((p) => p.storeProduct.identifier == offer.productId)
        .firstOrNull;
    if (pkg == null) throw BillingError('Oferta não encontrada na loja.');
    try {
      final r = await Purchases.purchase(PurchaseParams.package(pkg));
      return entitlementsFromRevenueCat(
        r.customerInfo.entitlements.active.values,
        nowISO: DateTime.now().toUtc().toIso8601String(),
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        throw BillingError('Compra cancelada.');
      }
      throw BillingError(e.message ?? 'Compra não concluída.');
    }
  }

  @override
  Future<List<Entitlement>> restore() async {
    if (!await _ensure()) return const [];
    final info = await Purchases.restorePurchases();
    return entitlementsFromRevenueCat(
      info.entitlements.active.values,
      nowISO: DateTime.now().toUtc().toIso8601String(),
    );
  }
}
