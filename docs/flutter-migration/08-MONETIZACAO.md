# 08 — Monetização em Flutter

## Modelo (inalterado)

Grátis para sempre (contas, lançamentos, 1 cartão, orçamentos, metas, listas, carrinho) · **Plus mensal** · **Plus anual** (recomendado) · **Vitalício** (pagamento único; inclui tudo que roda no aparelho; exclui serviços com custo recorrente como sincronização). Catálogo e limites em `lib/domain/billing/billing.dart` (`plans`, `freeLimits`, `featureLabelsPt`), idênticos ao TS (fixtures `billing.json`).

## Direitos

- Fonte de verdade: o provedor da loja (RevenueCat). O app nunca confia em flag local.
- Cache: lista de `Entitlement` com `verifiedAt` e `source`, guardada em `kv` (`entitlement_cache`); `resolveAccess` aplica carência (`cacheGraceMs`, 7 dias) e estados (`billing_issue`, `cancelled_active_until_expiry`, `in_grace_period`…).
- `EntitlementsProvider` (port) e `StoreBilling` (port da loja) separam regras de negócio do SDK.

## RevenueCat (`lib/data/billing/revenuecat_billing.dart`)

- `purchases_flutter` 11.0.0; chaves via `--dart-define=RC_IOS_KEY=… --dart-define=RC_ANDROID_KEY=…` (nunca no código ou no repositório). Sem chave ou fora de Android/iOS → `UnavailableStoreBilling` (paywall sem botões de compra, texto explicativo).
- Mapeamento `EntitlementInfo → Entitlement` é função pura testada (`test/data/revenuecat_mapping_test.dart`): produto → plano (iOS/Android, inclusive `serenacash_plus:yearly` do Google), estado por `billingIssueDetectedAt`/`unsubscribeDetectedAt`, vitalício sem `sync`.
- Compra: `Purchases.purchase(PurchaseParams.package(...))`; cancelamento vira mensagem amigável; restauração por `restorePurchases`.
- Identificadores no painel RevenueCat: entitlements `plus` e `lifetime`; produtos `br.com.serenacash.plus.monthly`, `br.com.serenacash.plus.yearly`, `br.com.serenacash.lifetime` (iOS) e `serenacash_plus` (base plans `monthly`/`yearly`) + `serenacash_lifetime` (Android).

## Paywall (`lib/features/billing/paywall_screen.dart`)

Comparativo grátis × Plus, cartões por plano com barra de abrangência, preço da loja quando disponível, restaurar compras, termos de renovação, nota de privacidade, "continuar no gratuito". Gates: contas/cartões/orçamentos/metas/listas além do limite, OCR acima do limite, relatórios avançados, PDF, OFX, anexos.

## Pendências de loja (não executáveis neste ambiente)

Criar produtos nas lojas, configurar RevenueCat, testar sandbox (StoreKit Testing / Play Billing test tracks). Nenhuma operação comercial foi executada.
