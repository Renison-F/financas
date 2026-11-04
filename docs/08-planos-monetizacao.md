# Planos e monetização

## 1. Estrutura (implementada em `packages/core/src/billing/catalog.ts`)

| Plano | ID | Loja (iOS / Android) | Período | Inclui |
|---|---|---|---|---|
| SerenaCash (grátis) | `free` | — | — | contas (3), 1 cartão, orçamentos (3), metas (2), listas (5), OCR 30/mês, lançamentos ilimitados, relatórios básicos, CSV, backup |
| SerenaCash Plus | `plus_monthly` | `br.com.serenacash.plus.monthly` / `serenacash_plus` (base plan mensal) | mês | tudo ilimitado, relatórios avançados, PDF, OFX, anexos, histórico de preços, listas compartilhadas, modelos de tela, sync (quando existir) |
| SerenaCash Plus anual | `plus_yearly` | `br.com.serenacash.plus.yearly` / `serenacash_plus` (base plan anual) | ano | idem |
| SerenaCash Sempre | `lifetime` | `br.com.serenacash.lifetime` / `serenacash_lifetime` | único (não consumível) | tudo do Plus **exceto** serviços com custo recorrente (sync) |

Preços **não** estão no código: são definidos no App Store Connect e no Play Console e chegam ao app pelas ofertas do RevenueCat. Referências de mercado em `docs/02-pesquisa-mercado.md` (R$ 99,90–119,90/ano; vitalício ~R$ 399,90, não verificados).

## 2. Regras de plataforma (pesquisa de 04/11/2026, fontes em `docs/02` e nos relatórios de pesquisa)
- **Google Play**: Play Billing Library ≥ 8 para novos envios (v7 expirou em 2026); assinaturas com base plans/ofertas; carência e account hold habilitados; reconhecimento (acknowledge) em até 3 dias; verificação server-side via Play Developer API; RTDN via Pub/Sub. Não há proibição de vender não consumível "vitalício" junto com assinaturas; usar IDs distintos.
- **App Store**: StoreKit 2; guideline 3.1.1 exige mecanismo de **restaurar compras** (botão, não automático no launch); 3.1.2(a) permite assinatura "ao lado de ofertas à la carte" (vitalício OK); grupos de assinatura (um grupo, mensal e anual com níveis); Server Notifications V2; Family Sharing opcional e irreversível. Brasil: desde jun/2026 comissões de 21%/10% + 5% com IAP, link-out permitido; desenvolvedores fora do Brasil têm CIDE 10%.
- **RevenueCat**: grátis até ~US$ 2,5 mil de receita mensal, depois 1%; `react-native-purchases` 10.16 (Expo), development build obrigatório; Expo Go só em modo de prévia.

## 3. Fluxo de direitos
1. App abre → `getBilling()` escolhe RevenueCat (chaves em `EXPO_PUBLIC_RC_*`) ou "indisponível".
2. `getEntitlements()` → normaliza para `Entitlement[]` → `resolveAccess()` → `Access` (tier, features, limites).
3. Cache local (`entitlements` no SQLite) honrado por 7 dias offline; depois cai para grátis até nova verificação.
4. Compra/restauração → merge por verificação mais recente → persistência.
5. Carência/problema de cobrança mantêm acesso; reembolso/expiração removem. Reembolso chega pelo provedor (RTDN/ASSN) → próximo `getEntitlements`.

## 4. Paywall (`apps/mobile/src/app/paywall.tsx`)
Comparação de planos, cartão por plano com preço da loja, botão de compra, restaurar compras, gerenciar assinatura, textos obrigatórios (renovação automática, cancelamento na loja), política do vitalício explícita. Bloqueios suaves nos limites do grátis levam ao paywall com o recurso indicado.

## 5. Administração comercial
Ofertas, preços, promoções e testes A/B são geridos no RevenueCat (Offerings) e nos consoles das lojas; o app apenas interpreta. Um painel próprio (relatórios de receita, auditoria) exige backend e está fora da v1. Nenhuma alteração administrativa permite falsificar compras: os direitos vêm sempre assinados pelo provedor.

## 6. Pendências para vender
- Criar produtos nos consoles com exatamente os IDs acima; configurar grupo de assinatura (iOS) e base plans (Android).
- Criar projeto no RevenueCat, entitlements `plus` e `lifetime`, offerings; definir `EXPO_PUBLIC_RC_IOS_KEY` e `EXPO_PUBLIC_RC_ANDROID_KEY` via EAS Secrets.
- Testar em sandbox (TestFlight / internal testing) os fluxos: compra, restauração, cancelamento, carência, reembolso.
- Publicar política de privacidade e termos; preencher questionários de privacidade das lojas.
