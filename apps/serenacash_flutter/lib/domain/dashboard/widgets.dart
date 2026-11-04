/// Dashboard widget catalog (24 widgets, 4 presets) and layout operations. Mirrors `dashboard/widgets.ts`.
library;

class WidgetDefinition {
  const WidgetDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.requires,
    required this.route,
    required this.size,
    this.premiumFeature,
  });
  final String id;
  final String title;
  final String description;
  final List<String> requires;
  final String route;
  final String size; // hero | tall | regular | compact
  final String? premiumFeature;
}

const widgets = <WidgetDefinition>[
  WidgetDefinition(
    id: 'available',
    title: 'Pode gastar',
    description: 'Quanto dá para gastar sem comprometer suas contas, com a conta explicada.',
    requires: ['accounts'],
    route: '/available',
    size: 'hero',
  ),
  WidgetDefinition(
    id: 'consolidated_balance',
    title: 'Saldo total',
    description: 'Soma das contas consideradas.',
    requires: ['accounts'],
    route: '/accounts',
    size: 'compact',
  ),
  WidgetDefinition(
    id: 'account_balances',
    title: 'Saldos por conta',
    description: 'Cada conta com seu saldo.',
    requires: ['accounts'],
    route: '/accounts',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'income',
    title: 'Receitas',
    description: 'Recebido e previsto no período.',
    requires: ['transactions'],
    route: '/transactions?kind=income',
    size: 'compact',
  ),
  WidgetDefinition(
    id: 'expenses',
    title: 'Despesas',
    description: 'Gasto e previsto no período.',
    requires: ['transactions'],
    route: '/transactions?kind=expense',
    size: 'compact',
  ),
  WidgetDefinition(
    id: 'bills_to_pay',
    title: 'Contas a pagar',
    description: 'O que ainda vence neste período.',
    requires: ['transactions'],
    route: '/bills',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'overdue_bills',
    title: 'Contas atrasadas',
    description: 'O que já passou do vencimento.',
    requires: ['transactions'],
    route: '/bills?filter=overdue',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'upcoming_due',
    title: 'Próximos vencimentos',
    description: 'Os próximos 7 dias.',
    requires: ['transactions'],
    route: '/calendar',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'cards_invoices',
    title: 'Cartões e faturas',
    description: 'Fatura atual, vencimento e limite disponível.',
    requires: ['cards'],
    route: '/cards',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'installments',
    title: 'Compras parceladas',
    description: 'Quanto está comprometido nos próximos meses.',
    requires: ['cards'],
    route: '/cards/installments',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'monthly_budget',
    title: 'Orçamento do mês',
    description: 'Gasto contra o limite, com a marca de hoje.',
    requires: ['budgets'],
    route: '/budgets',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'spending_by_category',
    title: 'Gastos por categoria',
    description: 'Para onde o dinheiro está indo.',
    requires: ['transactions'],
    route: '/reports/categories',
    size: 'tall',
  ),
  WidgetDefinition(
    id: 'evolution',
    title: 'Evolução',
    description: 'Receitas, despesas e saldo nos últimos meses.',
    requires: ['transactions'],
    route: '/reports/cashflow',
    size: 'tall',
  ),
  WidgetDefinition(
    id: 'goals',
    title: 'Metas',
    description: 'Progresso de cada objetivo.',
    requires: ['goals'],
    route: '/goals',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'reserves',
    title: 'Reservas',
    description: 'Dinheiro separado e protegido.',
    requires: ['goals'],
    route: '/goals?kind=reserve',
    size: 'compact',
  ),
  WidgetDefinition(
    id: 'monthly_savings',
    title: 'Economia do mês',
    description: 'Quanto sobrou das receitas.',
    requires: ['transactions'],
    route: '/reports/cashflow',
    size: 'compact',
  ),
  WidgetDefinition(
    id: 'subscriptions',
    title: 'Assinaturas e recorrentes',
    description: 'Gastos que se repetem todo mês.',
    requires: ['transactions'],
    route: '/reports/recurring',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'loans',
    title: 'Empréstimos',
    description: 'Saldo devedor e próxima parcela.',
    requires: ['loans'],
    route: '/loans',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'calendar',
    title: 'Calendário',
    description: 'Vencimentos e recebimentos no mês.',
    requires: ['transactions'],
    route: '/calendar',
    size: 'tall',
  ),
  WidgetDefinition(
    id: 'recent_transactions',
    title: 'Últimos lançamentos',
    description: 'As movimentações mais recentes.',
    requires: ['transactions'],
    route: '/transactions',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'recommendations',
    title: 'Sugestões',
    description: 'Orientações baseadas em regras transparentes.',
    requires: ['transactions'],
    route: '/assistant',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'shopping_lists',
    title: 'Listas de compras',
    description: 'Suas listas e o custo estimado.',
    requires: ['shopping'],
    route: '/shopping',
    size: 'regular',
  ),
  WidgetDefinition(
    id: 'shopping_assistant',
    title: 'Assistente de supermercado',
    description: 'Inicie uma compra com câmera e carrinho.',
    requires: ['shopping'],
    route: '/shopping/session',
    size: 'compact',
  ),
  WidgetDefinition(
    id: 'advanced_indicators',
    title: 'Indicadores avançados',
    description: 'Taxa de poupança, comprometimento de renda, patrimônio.',
    requires: ['transactions'],
    route: '/reports/indicators',
    size: 'tall',
    premiumFeature: 'advanced_reports',
  ),
];

final widgetIds = widgets.map((w) => w.id).toList();
WidgetDefinition widgetById(String id) => widgets.firstWhere((w) => w.id == id);

class Preset {
  const Preset(this.title, this.description, this.widgets);
  final String title;
  final String description;
  final List<String> widgets;
}

final presets = <String, Preset>{
  'essential': const Preset('Essencial', 'O que importa no dia a dia.', [
    'available',
    'bills_to_pay',
    'cards_invoices',
    'monthly_budget',
    'recent_transactions',
    'spending_by_category',
    'goals',
  ]),
  'focus': const Preset(
    'Só o mais importante',
    'Pode gastar, contas e últimos lançamentos.',
    ['available', 'bills_to_pay', 'recent_transactions'],
  ),
  'complete': Preset('Completo', 'Todos os widgets.', widgetIds),
  'shopping': const Preset('Supermercado', 'Compras em primeiro lugar.', [
    'shopping_assistant',
    'shopping_lists',
    'available',
    'monthly_budget',
    'spending_by_category',
  ]),
};

class DashboardLayout {
  const DashboardLayout({
    required this.order,
    this.period = 'current_month',
    this.selectedMonth,
    this.accountIds,
    this.privacyMode = false,
  });
  final List<String> order;
  final String period; // current_month | last_30_days | selected_month
  final String? selectedMonth;
  final List<String>? accountIds;
  final bool privacyMode;
  Map<String, dynamic> toJson() => {
    'order': order,
    'period': period,
    'selectedMonth': selectedMonth,
    'accountIds': accountIds,
    'privacyMode': privacyMode,
    'version': 1,
  };
  DashboardLayout copyWith({
    List<String>? order,
    String? period,
    String? selectedMonth,
    List<String>? accountIds,
    bool clearAccounts = false,
    bool? privacyMode,
  }) => DashboardLayout(
    order: order ?? this.order,
    period: period ?? this.period,
    selectedMonth: selectedMonth ?? this.selectedMonth,
    accountIds: clearAccounts ? null : (accountIds ?? this.accountIds),
    privacyMode: privacyMode ?? this.privacyMode,
  );
}

final defaultLayout = DashboardLayout(order: presets['essential']!.widgets);

DashboardLayout applyPreset(DashboardLayout l, String preset) =>
    l.copyWith(order: [...presets[preset]!.widgets]);
DashboardLayout showWidget(DashboardLayout l, String id, [int? index]) {
  if (l.order.contains(id)) return l;
  final o = [...l.order];
  o.insert(index ?? o.length, id);
  return l.copyWith(order: o);
}

DashboardLayout hideWidget(DashboardLayout l, String id) =>
    l.copyWith(order: l.order.where((w) => w != id).toList());
DashboardLayout moveWidget(DashboardLayout l, String id, int toIndex) {
  final from = l.order.indexOf(id);
  if (from < 0) return l;
  final o = [...l.order]..removeAt(from);
  o.insert(toIndex.clamp(0, o.length), id);
  return l.copyWith(order: o);
}

DashboardLayout moveWidgetBy(DashboardLayout l, String id, int delta) {
  final from = l.order.indexOf(id);
  return from < 0 ? l : moveWidget(l, id, from + delta);
}

List<String> hiddenWidgets(DashboardLayout l) =>
    widgetIds.where((w) => !l.order.contains(w)).toList();

/// Sanitizes a layout loaded from storage: drops unknown ids, de-duplicates, fills defaults.
DashboardLayout normalizeLayout(Object? raw) {
  final r = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  final rawOrder = r['order'];
  final order = rawOrder is List
      ? rawOrder.whereType<String>().where(widgetIds.contains).toSet().toList()
      : [...defaultLayout.order];
  final p = r['period'];
  final period = (p == 'last_30_days' || p == 'selected_month')
      ? p as String
      : 'current_month';
  final ids = r['accountIds'];
  return DashboardLayout(
    order: order,
    period: period,
    selectedMonth: r['selectedMonth'] is String
        ? r['selectedMonth'] as String
        : null,
    accountIds: ids is List ? ids.whereType<String>().toList() : null,
    privacyMode: r['privacyMode'] == true,
  );
}
