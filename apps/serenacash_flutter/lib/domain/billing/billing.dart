/// Commercial catalog and entitlements. Mirrors `billing/catalog.ts` and `billing/entitlements.ts`.
/// Prices never live here: they come from the stores through the billing provider.
library;

enum PlanId { free, plusMonthly, plusYearly, lifetime }

const planWire = {
  PlanId.free: 'free',
  PlanId.plusMonthly: 'plus_monthly',
  PlanId.plusYearly: 'plus_yearly',
  PlanId.lifetime: 'lifetime',
};
PlanId planFromWire(String s) =>
    planWire.entries.firstWhere((e) => e.value == s).key;

const plusFeatures = [
  'unlimited_accounts',
  'unlimited_cards',
  'unlimited_budgets',
  'unlimited_goals',
  'advanced_reports',
  'pdf_export',
  'ofx_import',
  'attachments',
  'unlimited_ocr',
  'price_history',
  'shared_lists',
  'custom_dashboard_presets',
  'sync',
];

class PlanDefinition {
  const PlanDefinition({
    required this.id,
    required this.name,
    required this.tier,
    this.iosProduct,
    this.androidProduct,
    this.period,
    required this.features,
    this.exclusions = const [],
  });
  final PlanId id;
  final String name;
  final String tier; // free | plus | lifetime
  final String? iosProduct;
  final String? androidProduct;
  final String? period; // month | year
  final List<String> features;
  final List<String> exclusions;
}

final plans = <PlanDefinition>[
  const PlanDefinition(
    id: PlanId.free,
    name: 'SerenaCash',
    tier: 'free',
    features: [],
  ),
  const PlanDefinition(
    id: PlanId.plusMonthly,
    name: 'SerenaCash Plus',
    tier: 'plus',
    period: 'month',
    iosProduct: 'br.com.serenacash.plus.monthly',
    androidProduct: 'serenacash_plus',
    features: plusFeatures,
  ),
  const PlanDefinition(
    id: PlanId.plusYearly,
    name: 'SerenaCash Plus (anual)',
    tier: 'plus',
    period: 'year',
    iosProduct: 'br.com.serenacash.plus.yearly',
    androidProduct: 'serenacash_plus',
    features: plusFeatures,
  ),
  // Lifetime covers everything that runs on the device; hosted services with recurring cost (sync) are excluded.
  PlanDefinition(
    id: PlanId.lifetime,
    name: 'SerenaCash Sempre',
    tier: 'lifetime',
    iosProduct: 'br.com.serenacash.lifetime',
    androidProduct: 'serenacash_lifetime',
    features: plusFeatures.where((f) => f != 'sync').toList(),
    exclusions: const ['sync'],
  ),
];

PlanDefinition planById(PlanId id) => plans.firstWhere((p) => p.id == id);

const freeLimits = {
  'accounts': 3,
  'cards': 1,
  'budgets': 3,
  'goals': 2,
  'ocrScansPerMonth': 30,
  'attachmentsPerTransaction': 0,
  'shoppingLists': 5,
};

const featureLabelsPt = {
  'unlimited_accounts': 'Contas ilimitadas',
  'unlimited_cards': 'Cartões ilimitados',
  'unlimited_budgets': 'Orçamentos ilimitados',
  'unlimited_goals': 'Metas ilimitadas',
  'advanced_reports': 'Relatórios avançados e indicadores',
  'pdf_export': 'Exportação em PDF',
  'ofx_import': 'Importação OFX',
  'attachments': 'Anexos e comprovantes',
  'unlimited_ocr': 'Leitura de etiquetas ilimitada',
  'price_history': 'Histórico de preços por loja',
  'shared_lists': 'Listas compartilhadas',
  'custom_dashboard_presets': 'Modelos de tela inicial personalizados',
  'sync': 'Sincronização entre dispositivos',
};

enum EntitlementSource { storeVerified, cached, none }

enum SubscriptionState {
  active,
  inGracePeriod,
  billingIssue,
  cancelledActiveUntilExpiry,
  expired,
  refunded,
  paused,
}

const _stateWire = {
  SubscriptionState.active: 'active',
  SubscriptionState.inGracePeriod: 'in_grace_period',
  SubscriptionState.billingIssue: 'billing_issue',
  SubscriptionState.cancelledActiveUntilExpiry: 'cancelled_active_until_expiry',
  SubscriptionState.expired: 'expired',
  SubscriptionState.refunded: 'refunded',
  SubscriptionState.paused: 'paused',
};
SubscriptionState stateFromWire(String s) =>
    _stateWire.entries.firstWhere((e) => e.value == s).key;
const _sourceWire = {
  EntitlementSource.storeVerified: 'store_verified',
  EntitlementSource.cached: 'cached',
  EntitlementSource.none: 'none',
};
EntitlementSource sourceFromWire(String s) =>
    _sourceWire.entries.firstWhere((e) => e.value == s).key;

/// Entitlement as reported by the billing provider (verified server-side), normalized and cached with a timestamp.
class Entitlement {
  const Entitlement({
    required this.planId,
    required this.state,
    this.expiresAt,
    required this.verifiedAt,
    required this.source,
    this.transactionRef,
    this.willRenew,
  });
  final PlanId planId;
  final SubscriptionState state;
  final String? expiresAt; // ISO datetime
  final String verifiedAt;
  final EntitlementSource source;
  final String? transactionRef;
  final bool? willRenew;
  factory Entitlement.fromJson(Map<String, dynamic> j) => Entitlement(
    planId: planFromWire(j['planId'] as String),
    state: stateFromWire(j['state'] as String),
    expiresAt: j['expiresAt'] as String?,
    verifiedAt: j['verifiedAt'] as String,
    source: sourceFromWire(j['source'] as String),
    transactionRef: j['transactionRef'] as String?,
    willRenew: j['willRenew'] as bool?,
  );
  Map<String, dynamic> toJson() => {
    'planId': planWire[planId],
    'state': _stateWire[state],
    if (expiresAt != null) 'expiresAt': expiresAt,
    'verifiedAt': verifiedAt,
    'source': _sourceWire[source],
    if (transactionRef != null) 'transactionRef': transactionRef,
    if (willRenew != null) 'willRenew': willRenew,
  };
}

class Access {
  const Access({
    required this.tier,
    required this.planId,
    required this.features,
    required this.limits,
    required this.reason,
  });
  final String tier;
  final PlanId planId;
  final Set<String> features;
  final Map<String, int>? limits; // null = unlimited
  final String reason;
  bool has(String feature) => features.contains(feature);
  Map<String, dynamic> toJson() => {
    'tier': tier,
    'planId': planWire[planId],
    'features': features.toList()..sort(),
    'limits': limits,
    'reason': reason,
    'staleAfterMs': cacheGraceMs,
  };
}

const cacheGraceMs = 7 * 24 * 60 * 60 * 1000; // 7 days offline tolerance

const _activeStates = {
  SubscriptionState.active,
  SubscriptionState.inGracePeriod,
  SubscriptionState.billingIssue,
  SubscriptionState.cancelledActiveUntilExpiry,
};

Access resolveAccess(List<Entitlement> entitlements, DateTime now) {
  final nowMs = now.millisecondsSinceEpoch;
  const free = Access(
    tier: 'free',
    planId: PlanId.free,
    features: {},
    limits: freeLimits,
    reason: 'Plano gratuito',
  );
  final candidates = entitlements.where((e) {
    if (e.source == EntitlementSource.none) return false;
    if (e.state == SubscriptionState.refunded ||
        e.state == SubscriptionState.expired ||
        e.state == SubscriptionState.paused) {
      return false;
    }
    if (e.source == EntitlementSource.cached &&
        nowMs - DateTime.parse(e.verifiedAt).millisecondsSinceEpoch >
            cacheGraceMs) {
      return false;
    }
    if (e.expiresAt != null &&
        DateTime.parse(e.expiresAt!).millisecondsSinceEpoch < nowMs &&
        e.state != SubscriptionState.inGracePeriod &&
        e.state != SubscriptionState.billingIssue) {
      return false;
    }
    return _activeStates.contains(e.state);
  }).toList();
  final chosen =
      candidates.where((e) => e.planId == PlanId.lifetime).firstOrNull ??
      candidates.where((e) => e.planId == PlanId.plusYearly).firstOrNull ??
      candidates.where((e) => e.planId == PlanId.plusMonthly).firstOrNull;
  if (chosen == null) return free;
  final plan = planById(chosen.planId);
  final reason = chosen.planId == PlanId.lifetime
      ? 'Licença vitalícia'
      : (chosen.state == SubscriptionState.inGracePeriod ||
            chosen.state == SubscriptionState.billingIssue)
      ? 'Assinatura com problema de cobrança (acesso mantido temporariamente)'
      : chosen.state == SubscriptionState.cancelledActiveUntilExpiry
      ? 'Assinatura cancelada, ativa até o fim do período'
      : 'Assinatura ativa';
  return Access(
    tier: plan.tier,
    planId: plan.id,
    features: plan.features.toSet(),
    limits: null,
    reason: reason,
  );
}

({bool ok, int? limit, int? remaining}) withinLimit(
  Access access,
  String key,
  int currentCount,
) {
  if (access.limits == null) return (ok: true, limit: null, remaining: null);
  final limit = access.limits![key]!;
  return (
    ok: currentCount < limit,
    limit: limit,
    remaining: (limit - currentCount).clamp(0, 1 << 30),
  );
}

/// Keep the freshest verification per plan.
List<Entitlement> mergeEntitlements(
  List<Entitlement> existing,
  List<Entitlement> incoming,
) {
  final map = <PlanId, Entitlement>{};
  for (final e in [...existing, ...incoming]) {
    final cur = map[e.planId];
    if (cur == null ||
        DateTime.parse(e.verifiedAt)
                .compareTo(DateTime.parse(cur.verifiedAt)) >=
            0) {
      map[e.planId] = e;
    }
  }
  return map.values.toList();
}
