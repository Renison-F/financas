/// Paywall: plan comparison, store offers (when the provider is available), purchase, restore, lifetime policy.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../data/billing/store_billing.dart';
import '../../domain/billing/billing.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.feature});
  final String? feature;
  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<StoreOffer> _offers = const [];
  String? _busy;
  String _msg = '';
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final billing = ref.read(storeBillingProvider);
    final available = await billing.available();
    if (!mounted) return;
    setState(() => _available = available);
    if (!available) return;
    try {
      final offers = await billing.offers();
      final ents = await billing.entitlements();
      if (!mounted) return;
      setState(() => _offers = offers);
      if (ents.isNotEmpty) {
        final cur = ref.read(appControllerProvider).requireValue.entitlements;
        await ref
            .read(appControllerProvider.notifier)
            .setEntitlements(mergeEntitlements(cur, ents));
      }
    } catch (_) {
      // offline: keep the cached entitlement (grace handled by resolveAccess)
    }
  }

  Future<void> _buy(StoreOffer o) async {
    final l = context.l10n;
    setState(() {
      _busy = o.productId;
      _msg = '';
    });
    try {
      final e = await ref.read(storeBillingProvider).purchase(o);
      final cur = ref.read(appControllerProvider).requireValue.entitlements;
      await ref
          .read(appControllerProvider.notifier)
          .setEntitlements(mergeEntitlements(cur, e));
      setState(() => _msg = l.thanksActive);
    } catch (err) {
      setState(
        () => _msg = err is BillingError ? err.message : l.purchaseFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _restore() async {
    final l = context.l10n;
    setState(() {
      _busy = 'restore';
      _msg = '';
    });
    try {
      final e = await ref.read(storeBillingProvider).restore();
      final cur = ref.read(appControllerProvider).requireValue.entitlements;
      await ref
          .read(appControllerProvider.notifier)
          .setEntitlements(mergeEntitlements(cur, e));
      setState(
        () => _msg = e.isNotEmpty ? l.purchasesRestored : l.noPurchasesFound,
      );
    } catch (err) {
      setState(
        () => _msg = err is BillingError ? err.message : l.restoreFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final access = s.access;
    final paid = plans.where((p) => p.id != PlanId.free).toList();
    StoreOffer? offerFor(PlanId id) =>
        _offers.where((o) => o.planId == id).firstOrNull;
    Widget row(String k, String free, String plus) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(k, style: Type.bodySmall.copyWith(color: c.text)),
          ),
          Expanded(
            child: Text(
              free,
              style: Type.bodySmall.copyWith(color: c.textMuted),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(plus, style: Type.bodySmall.copyWith(color: c.primary)),
          ),
        ],
      ),
    );
    return StackScreen(
      title: l.plusTitle,
      children: [
        if (widget.feature != null)
          SCard(
            inset: true,
            child: Text(
              l.featurePartOfPlus(
                featureLabelsPt[widget.feature] ?? widget.feature!,
              ),
              style: Type.bodySmall.copyWith(color: c.text),
            ),
          ),
        if (access.tier != 'free')
          SCard(
            color: c.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  access.reason,
                  style: Type.title.copyWith(color: c.onPrimaryContainer),
                ),
                Text(
                  l.thanksSupport(
                    plans.firstWhere((p) => p.id == access.planId).name,
                  ),
                  style: Type.bodySmall.copyWith(color: c.onPrimaryContainer),
                ),
              ],
            ),
          ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.whatChanges, style: Type.title.copyWith(color: c.text)),
              const SizedBox(height: 8),
              row(
                l.limitsRow,
                '${freeLimits['accounts']} / ${freeLimits['cards']} / ${freeLimits['budgets']} / ${freeLimits['goals']}',
                l.unlimited,
              ),
              row(
                l.ocrRow,
                l.perMonthN(freeLimits['ocrScansPerMonth']!),
                l.unlimitedF,
              ),
              row(l.reportsPdfRow, '—', l.yes),
              row(l.ofxAttachRow, '—', l.yes),
              row(l.priceHistoryRow, '—', l.yes),
              row(l.syncRow, '—', l.syncWhen),
              Text(
                l.essentialFree,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        for (final p in paid)
          Builder(
            builder: (_) {
              final o = offerFor(p.id);
              final rec = p.id == PlanId.plusYearly;
              final fg = rec ? c.onPrimaryContainer : c.text;
              final mutedFg = rec ? c.onPrimaryContainer : c.textMuted;
              return SCard(
                color: rec ? c.primaryContainer : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.name, style: Type.title.copyWith(color: fg)),
                        if (rec)
                          Text(
                            l.recommended,
                            style: Type.label.copyWith(color: fg),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.id == PlanId.lifetime
                          ? l.lifetimeDesc
                          : p.period == 'year'
                          ? l.yearlyDesc
                          : l.monthlyDesc,
                      style: Type.bodySmall.copyWith(color: mutedFg),
                    ),
                    const SizedBox(height: 8),
                    RhythmBar(
                      percent: p.id == PlanId.lifetime
                          ? 100
                          : rec
                          ? 70
                          : 40,
                      expectedPercent: rec ? 70 : null,
                      label: l.planCoverage,
                    ),
                    const SizedBox(height: 10),
                    if (o != null)
                      SButton(
                        label:
                            '${o.priceString}${p.period == 'year'
                                ? l.perYear
                                : p.period == 'month'
                                ? l.perMonthShort
                                : ''}',
                        variant: rec
                            ? SButtonVariant.primary
                            : SButtonVariant.secondary,
                        fullWidth: true,
                        loading: _busy == o.productId,
                        onPressed: () => _buy(o),
                      )
                    else
                      Text(
                        _available ? l.loadingPrice : l.priceInStore,
                        style: Type.caption.copyWith(color: mutedFg),
                      ),
                  ],
                ),
              );
            },
          ),
        SButton(
          label: l.restorePurchases,
          variant: SButtonVariant.ghost,
          fullWidth: true,
          loading: _busy == 'restore',
          onPressed: _available ? _restore : null,
        ),
        if (_msg.isNotEmpty)
          Text(
            _msg,
            style: Type.bodySmall.copyWith(
              color: _msg == l.thanksActive || _msg == l.purchasesRestored
                  ? c.positive
                  : c.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        Text(
          l.subscriptionTerms,
          style: Type.caption.copyWith(color: c.textMuted),
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SIcon(SIconName.lock, size: 14, color: c.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l.storeProcesses,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ),
          ],
        ),
        Text(
          l.plusFeaturesList(
            plusFeatures.map((f) => featureLabelsPt[f] ?? f).join(' · '),
          ),
          style: Type.caption.copyWith(color: c.textMuted),
        ),
        SButton(
          label: l.stayFree,
          variant: SButtonVariant.ghost,
          fullWidth: true,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
