/**
 * Commercial catalog. Prices are NOT defined here: they come from the stores (App Store Connect /
 * Play Console) through the billing provider at runtime. This file defines plan identity, which
 * features each plan unlocks and the free-plan limits, so offers can change without touching rules.
 */
export type PlanId = 'free' | 'plus_monthly' | 'plus_yearly' | 'lifetime';
export type FeatureKey =
  | 'unlimited_accounts' | 'unlimited_cards' | 'unlimited_budgets' | 'unlimited_goals' | 'advanced_reports' | 'pdf_export'
  | 'ofx_import' | 'attachments' | 'unlimited_ocr' | 'price_history' | 'shared_lists' | 'custom_dashboard_presets' | 'sync';

export interface PlanDefinition {
  id: PlanId;
  name: string;
  tier: 'free' | 'plus' | 'lifetime';
  /** store product identifiers, per platform; set in store consoles with EXACTLY these ids */
  products: { ios?: string | undefined; android?: string | undefined };
  period?: 'month' | 'year' | undefined;
  features: FeatureKey[];
  /** what a lifetime purchase explicitly does NOT include forever (recurring-cost services) */
  exclusions?: FeatureKey[] | undefined;
}

export const PLUS_FEATURES: FeatureKey[] = ['unlimited_accounts', 'unlimited_cards', 'unlimited_budgets', 'unlimited_goals', 'advanced_reports', 'pdf_export', 'ofx_import', 'attachments', 'unlimited_ocr', 'price_history', 'shared_lists', 'custom_dashboard_presets', 'sync'];

export const PLANS: readonly PlanDefinition[] = [
  { id: 'free', name: 'SerenaCash', tier: 'free', products: {}, features: [] },
  { id: 'plus_monthly', name: 'SerenaCash Plus', tier: 'plus', period: 'month', products: { ios: 'br.com.serenacash.plus.monthly', android: 'serenacash_plus' }, features: PLUS_FEATURES },
  { id: 'plus_yearly', name: 'SerenaCash Plus (anual)', tier: 'plus', period: 'year', products: { ios: 'br.com.serenacash.plus.yearly', android: 'serenacash_plus' }, features: PLUS_FEATURES },
  // Lifetime is a non-consumable; it covers everything that runs on the device. Sync (a hosted service with recurring cost)
  // is explicitly excluded unless the business model later funds it; see docs/08-planos-monetizacao.md.
  { id: 'lifetime', name: 'SerenaCash Sempre', tier: 'lifetime', products: { ios: 'br.com.serenacash.lifetime', android: 'serenacash_lifetime' }, features: PLUS_FEATURES.filter((f) => f !== 'sync'), exclusions: ['sync'] },
];

/** Free-plan limits (null = unlimited). Transparent to the user in the paywall and in each blocked action. */
export const FREE_LIMITS = {
  accounts: 3,
  cards: 1,
  budgets: 3,
  goals: 2,
  ocrScansPerMonth: 30,
  attachmentsPerTransaction: 0,
  shoppingLists: 5,
} as const;

export const FEATURE_LABELS_PT: Record<FeatureKey, string> = {
  unlimited_accounts: 'Contas ilimitadas', unlimited_cards: 'Cartões ilimitados', unlimited_budgets: 'Orçamentos ilimitados', unlimited_goals: 'Metas ilimitadas',
  advanced_reports: 'Relatórios avançados e indicadores', pdf_export: 'Exportação em PDF', ofx_import: 'Importação OFX', attachments: 'Anexos e comprovantes',
  unlimited_ocr: 'Leitura de etiquetas ilimitada', price_history: 'Histórico de preços por loja', shared_lists: 'Listas compartilhadas', custom_dashboard_presets: 'Modelos de tela inicial personalizados', sync: 'Sincronização entre dispositivos',
};

export const planById = (id: PlanId) => PLANS.find((p) => p.id === id)!;
