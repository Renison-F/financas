export type WidgetId =
  | 'available' | 'consolidated_balance' | 'account_balances' | 'income' | 'expenses' | 'bills_to_pay' | 'overdue_bills'
  | 'upcoming_due' | 'cards_invoices' | 'installments' | 'monthly_budget' | 'spending_by_category' | 'evolution' | 'goals'
  | 'reserves' | 'monthly_savings' | 'subscriptions' | 'loans' | 'calendar' | 'recent_transactions' | 'recommendations'
  | 'shopping_lists' | 'shopping_assistant' | 'advanced_indicators';

export interface WidgetDefinition {
  id: WidgetId;
  title: string;
  description: string;
  /** which domain modules power it (for documentation and empty states) */
  requires: ('accounts' | 'transactions' | 'cards' | 'budgets' | 'goals' | 'loans' | 'shopping')[];
  /** route the widget opens on tap */
  route: string;
  /** size hint for layout */
  size: 'hero' | 'tall' | 'regular' | 'compact';
  /** premium gating key, if any */
  premiumFeature?: string | undefined;
}

export const WIDGETS: readonly WidgetDefinition[] = [
  { id: 'available', title: 'Pode gastar', description: 'Quanto dá para gastar sem comprometer suas contas, com a conta explicada.', requires: ['accounts'], route: '/available', size: 'hero' },
  { id: 'consolidated_balance', title: 'Saldo total', description: 'Soma das contas consideradas.', requires: ['accounts'], route: '/accounts', size: 'compact' },
  { id: 'account_balances', title: 'Saldos por conta', description: 'Cada conta com seu saldo.', requires: ['accounts'], route: '/accounts', size: 'regular' },
  { id: 'income', title: 'Receitas', description: 'Recebido e previsto no período.', requires: ['transactions'], route: '/transactions?kind=income', size: 'compact' },
  { id: 'expenses', title: 'Despesas', description: 'Gasto e previsto no período.', requires: ['transactions'], route: '/transactions?kind=expense', size: 'compact' },
  { id: 'bills_to_pay', title: 'Contas a pagar', description: 'O que ainda vence neste período.', requires: ['transactions'], route: '/bills', size: 'regular' },
  { id: 'overdue_bills', title: 'Contas atrasadas', description: 'O que já passou do vencimento.', requires: ['transactions'], route: '/bills?filter=overdue', size: 'regular' },
  { id: 'upcoming_due', title: 'Próximos vencimentos', description: 'Os próximos 7 dias.', requires: ['transactions'], route: '/calendar', size: 'regular' },
  { id: 'cards_invoices', title: 'Cartões e faturas', description: 'Fatura atual, vencimento e limite disponível.', requires: ['cards'], route: '/cards', size: 'regular' },
  { id: 'installments', title: 'Compras parceladas', description: 'Quanto está comprometido nos próximos meses.', requires: ['cards'], route: '/cards/installments', size: 'regular' },
  { id: 'monthly_budget', title: 'Orçamento do mês', description: 'Gasto contra o limite, com a marca de hoje.', requires: ['budgets'], route: '/budgets', size: 'regular' },
  { id: 'spending_by_category', title: 'Gastos por categoria', description: 'Para onde o dinheiro está indo.', requires: ['transactions'], route: '/reports/categories', size: 'tall' },
  { id: 'evolution', title: 'Evolução', description: 'Receitas, despesas e saldo nos últimos meses.', requires: ['transactions'], route: '/reports/cashflow', size: 'tall' },
  { id: 'goals', title: 'Metas', description: 'Progresso de cada objetivo.', requires: ['goals'], route: '/goals', size: 'regular' },
  { id: 'reserves', title: 'Reservas', description: 'Dinheiro separado e protegido.', requires: ['goals'], route: '/goals?kind=reserve', size: 'compact' },
  { id: 'monthly_savings', title: 'Economia do mês', description: 'Quanto sobrou das receitas.', requires: ['transactions'], route: '/reports/cashflow', size: 'compact' },
  { id: 'subscriptions', title: 'Assinaturas e recorrentes', description: 'Gastos que se repetem todo mês.', requires: ['transactions'], route: '/reports/recurring', size: 'regular' },
  { id: 'loans', title: 'Empréstimos', description: 'Saldo devedor e próxima parcela.', requires: ['loans'], route: '/loans', size: 'regular' },
  { id: 'calendar', title: 'Calendário', description: 'Vencimentos e recebimentos no mês.', requires: ['transactions'], route: '/calendar', size: 'tall' },
  { id: 'recent_transactions', title: 'Últimos lançamentos', description: 'As movimentações mais recentes.', requires: ['transactions'], route: '/transactions', size: 'regular' },
  { id: 'recommendations', title: 'Sugestões', description: 'Orientações baseadas em regras transparentes.', requires: ['transactions'], route: '/assistant', size: 'regular' },
  { id: 'shopping_lists', title: 'Listas de compras', description: 'Suas listas e o custo estimado.', requires: ['shopping'], route: '/shopping', size: 'regular' },
  { id: 'shopping_assistant', title: 'Assistente de supermercado', description: 'Inicie uma compra com câmera e carrinho.', requires: ['shopping'], route: '/shopping/session', size: 'compact' },
  { id: 'advanced_indicators', title: 'Indicadores avançados', description: 'Taxa de poupança, comprometimento de renda, patrimônio.', requires: ['transactions'], route: '/reports/indicators', size: 'tall', premiumFeature: 'advanced_reports' },
];

export const WIDGET_IDS: readonly WidgetId[] = WIDGETS.map((w) => w.id);
export const widgetById = (id: WidgetId): WidgetDefinition => WIDGETS.find((w) => w.id === id)!;

export type DashboardPreset = 'essential' | 'focus' | 'complete' | 'shopping';

export const PRESETS: Record<DashboardPreset, { title: string; description: string; widgets: WidgetId[] }> = {
  essential: { title: 'Essencial', description: 'O que importa no dia a dia.', widgets: ['available', 'bills_to_pay', 'cards_invoices', 'monthly_budget', 'recent_transactions', 'spending_by_category', 'goals'] },
  focus: { title: 'Só o mais importante', description: 'Pode gastar, contas e últimos lançamentos.', widgets: ['available', 'bills_to_pay', 'recent_transactions'] },
  complete: { title: 'Completo', description: 'Todos os widgets.', widgets: [...WIDGET_IDS] },
  shopping: { title: 'Supermercado', description: 'Compras em primeiro lugar.', widgets: ['shopping_assistant', 'shopping_lists', 'available', 'monthly_budget', 'spending_by_category'] },
};

export type DashboardPeriod = 'current_month' | 'last_30_days' | 'selected_month';

export interface DashboardLayout {
  /** visible widgets in display order */
  order: WidgetId[];
  period: DashboardPeriod;
  selectedMonth?: string | undefined;
  /** account ids considered by indicators; undefined = all active accounts flagged includeInAvailability */
  accountIds?: string[] | undefined;
  privacyMode: boolean;
  version: 1;
}

export const DEFAULT_LAYOUT: DashboardLayout = { order: PRESETS.essential.widgets, period: 'current_month', privacyMode: false, version: 1 };

export function applyPreset(layout: DashboardLayout, preset: DashboardPreset): DashboardLayout {
  return { ...layout, order: [...PRESETS[preset].widgets] };
}
export function showWidget(layout: DashboardLayout, id: WidgetId, index?: number): DashboardLayout {
  if (layout.order.includes(id)) return layout;
  const order = [...layout.order];
  order.splice(index ?? order.length, 0, id);
  return { ...layout, order };
}
export function hideWidget(layout: DashboardLayout, id: WidgetId): DashboardLayout {
  return { ...layout, order: layout.order.filter((w) => w !== id) };
}
export function moveWidget(layout: DashboardLayout, id: WidgetId, toIndex: number): DashboardLayout {
  const from = layout.order.indexOf(id);
  if (from < 0) return layout;
  const order = [...layout.order];
  order.splice(from, 1);
  order.splice(Math.max(0, Math.min(toIndex, order.length)), 0, id);
  return { ...layout, order };
}
export function moveWidgetBy(layout: DashboardLayout, id: WidgetId, delta: -1 | 1): DashboardLayout {
  const from = layout.order.indexOf(id);
  if (from < 0) return layout;
  return moveWidget(layout, id, from + delta);
}
export function hiddenWidgets(layout: DashboardLayout): WidgetId[] { return WIDGET_IDS.filter((w) => !layout.order.includes(w)); }

/** Sanitizes a layout loaded from storage: drops unknown ids, de-duplicates, fills defaults. */
export function normalizeLayout(raw: unknown): DashboardLayout {
  const r = (raw && typeof raw === 'object' ? raw : {}) as Partial<DashboardLayout>;
  const order = Array.isArray(r.order) ? [...new Set(r.order.filter((id): id is WidgetId => WIDGET_IDS.includes(id as WidgetId)))] : [...DEFAULT_LAYOUT.order];
  const period: DashboardPeriod = r.period === 'last_30_days' || r.period === 'selected_month' ? r.period : 'current_month';
  return { order, period, selectedMonth: typeof r.selectedMonth === 'string' ? r.selectedMonth : undefined, accountIds: Array.isArray(r.accountIds) ? r.accountIds.filter((x): x is string => typeof x === 'string') : undefined, privacyMode: r.privacyMode === true, version: 1 };
}
