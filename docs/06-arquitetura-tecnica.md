# Fase 4 — Arquitetura técnica

## 1. Decisão de stack

| Opção | Prós | Contras | Decisão |
|---|---|---|---|
| **React Native + Expo SDK 58** | Uma base para Android/iOS com componentes nativos; Expo Router; expo-camera (EAN/QR em Expo Go); OCR on-device via ML Kit em dev build; RevenueCat/expo-iap; EAS Build/Submit sem Xcode/Android Studio locais (nosso ambiente não os tem); TypeScript estrito; domínio reaproveitável em testes Node | Módulos nativos exigem development build; OCR depende de plugin de terceiros | **Escolhida** |
| Flutter | Excelente desempenho e OCR (google_mlkit) | Dart separado do ecossistema TS; sem reaproveitar validações/regras já conhecidas; equipe de continuidade mais rara no Brasil | Não |
| Nativo (Swift + Kotlin) | Máximo controle | Duas bases, dobro de custo; inviável para o escopo | Não |
| WebView do HTML atual | Rápido | Proibido pelo briefing; experiência não nativa | Não |

Versões fixadas: Expo 58.0.x, React Native 0.88.1, React 19.3, TypeScript 6.0, Expo Router 58, expo-sqlite 58, expo-camera 58, Reanimated 4.7, Gesture Handler 3.3, Vitest 4 (pacotes de domínio), Jest 30 + jest-expo (app).

## 2. Estrutura do repositório (pnpm workspaces)

```
apps/mobile/            Expo app (UI, navegação, persistência SQLite, câmera, compras)
  src/app/              rotas Expo Router
  src/design/           tokens, tema, componentes base, ícones
  src/data/             SQLite: schema, migrações, repositórios, unit of work
  src/features/         telas e hooks por módulo (dashboard, transactions, cards, shopping, billing…)
  src/services/         câmera, OCR, códigos, notificações, biometria, billing adapter
packages/core/          domínio financeiro puro (sem React, sem IO): money, dates, ledger, cards,
                        recurrence, availability, budgets, goals, loans, reports, assistant, import/export,
                        dashboard, billing (catálogo + direitos), sync (modelo de mudanças)
packages/shopping/      domínio de compras puro: unidades, listas, carrinho, parser de etiquetas, códigos,
                        histórico de preços, sessão
docs/                   documentação permanente; brand/ ativos de marca
```

Regra de dependência: `apps/mobile → packages/*`; `packages/shopping → packages/core` (apenas `money`/`dates`); `packages/core` não depende de nada.

## 3. Domínio financeiro

- **Dinheiro** = inteiro de centavos + código de moeda (`Cents`, BRL por padrão). Arredondamento só em `mulCents/divCents/allocate` com modo explícito (half-even padrão; half-up para pesagem; parcelas via `allocate` com resto nas primeiras parcelas).
- **Datas** = `YYYY-MM-DD` calendário local, sem fuso; competência por `MonthKey`.
- **Lançamento (Transaction)**: `kind ∈ income | expense | transfer | card_purchase | card_payment | goal_deposit | goal_withdrawal | loan_disbursement | loan_payment | balance_adjustment`; `status ∈ planned | settled | partially_paid | cancelled`; `paidCents` para pagamento parcial; `seriesId` para recorrência; `installment {n, of, groupId}` para parcelas; `transferGroupId` para evitar dupla contagem.
- **Regra de não dupla contagem**: `card_purchase` é despesa na competência da compra; `card_payment` apenas move dinheiro da conta para o cartão (reduz dívida). Transferência é neutra no consolidado.
- **Fatura**: competência pela regra de fechamento (compra após o dia de fechamento → fatura seguinte); vencimento no mês da fatura; parcelas distribuídas uma por fatura.
- **Cabe gastar**: ver `docs/05` §2; implementado em `availability.ts` retornando a decomposição, não só o número.
- **Empréstimos**: Price (PMT) e SAC; amortização extraordinária reduz prazo ou parcela (escolha explícita); simulação de quitação por valor presente das parcelas restantes à taxa contratual (hipótese documentada).

## 4. Persistência (SQLite, offline-first)

- `expo-sqlite` com WAL, migrações versionadas (`src/data/migrations/*.ts`), transações para toda escrita multi-tabela (unit of work).
- Todas as tabelas têm `id` (UUID v4), `created_at`, `updated_at`, `deleted_at` (soft delete), `version` (inteiro) e `dirty` (bool) para sincronização futura.
- Anexos em `FileSystem.documentDirectory/attachments/<uuid>` com nome e hash no banco.
- Backup/exportação: JSON versionado (`schemaVersion`) + CSV; importação do backup legado (`pouso-financas-v2`) via conversor.

## 5. Sincronização (opcional, não ativa na v1)

Modelo preparado: log de mudanças (`change_log`) por entidade com `version` e `device_id`; estratégia **last-writer-wins por campo com detecção de conflito** em valores monetários (conflito monetário nunca é resolvido silenciosamente: cria item em "Conflitos" para o usuário decidir). Transporte e servidor não escolhidos; interface `SyncTransport` definida em `packages/core/src/sync`. O usuário vê o estado de cada registro: local / sincronizado / conflito.

## 6. Segurança e privacidade

- Banco local; chave de criptografia de backups em `expo-secure-store` (Keychain/Keystore); biometria opcional para abrir o app (`expo-local-authentication`) com fallback de PIN.
- Nenhum segredo no repositório; variáveis em `.env` (ignorado) e EAS Secrets; `app.config` lê `process.env`.
- Logs sem dados pessoais (valores e descrições nunca em logs); crash reporting opcional e desligado por padrão.
- Exportação e exclusão total de dados pelo usuário em "Privacidade"; política de privacidade e termos publicados antes das lojas.
- Compras: recibos validados pelo provedor (RevenueCat) ou por backend próprio; o app nunca libera Premium a partir de um flag local não assinado (cache de direitos assinado e com expiração).

## 7. Câmera, OCR e códigos

- Códigos de barras/QR: `expo-camera` (EAN-13, EAN-8, UPC-A/E, Code128, QR) — funciona em Expo Go.
- OCR on-device: `react-native-vision-camera@5` + `react-native-vision-camera-mlkit@2` (config plugin, ML Kit Latin) em development build; fallback de foto estática. O parser de etiquetas (`packages/shopping/src/pricetag`) é puro e testado com textos reais de OCR, independente do motor.
- QR da NFC-e: reconhecido e armazenado (chave de acesso); importação de itens depende de consulta à SEFAZ (não disponível offline) — preparado, não prometido.

## 8. Monetização

- `packages/core/src/billing`: catálogo (planos, produtos por plataforma, features), motor de direitos (`entitlements`), regras de expiração, carência, cancelamento, reembolso, vitalício.
- `apps/mobile/src/services/billing`: adapter com interface única; implementação RevenueCat (`react-native-purchases`, dev build) e implementação "indisponível" (Expo Go/web) que mostra o paywall sem botões de compra.
- Administração comercial: as ofertas vêm do provedor (RevenueCat Offerings / consoles das lojas); o app só interpreta. Um painel administrativo próprio exige backend e fica documentado como pendência (`docs/08`).

## 9. Testes e qualidade

- Domínio: Vitest (unitários e propriedades) em `packages/*`.
- App: Jest + Testing Library (componentes e hooks), testes de repositório SQLite via `expo-sqlite` em jest-expo quando possível; E2E (Maestro) planejado para dispositivos/emuladores.
- Lint/typecheck obrigatórios; CI (GitHub Actions) roda testes dos pacotes e typecheck do app.

## 10. Ambientes

`development` (dev build, logs verbosos, sandbox de compras), `preview` (EAS internal distribution), `production` (lojas). Separação por `eas.json` e `app.config.ts` com `APP_ENV`.
