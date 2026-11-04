# 01 — Auditoria da origem (React Native/Expo) para a migração Flutter

Commit de referência auditado: **`ae2c229c4977dcc6f78a19e7e4388cacced9d61b`** (branch `claude/wonderful-knuth-30ejqq`).
Baseline executada em 2026-11-04 nesta sessão (`pnpm -r test`): core **100/100**, shopping **18/18**, mobile (Jest) **11/11**; `pnpm -r typecheck` limpo. Verificação feita no código, não nos relatórios.

## 1. Inventário de telas e rotas (Expo Router, 44 arquivos de rota)
| Área | Rotas | Observação verificada |
|---|---|---|
| Abas | `(tabs)/index` Início · `transactions` · `shopping` · `plan` · `more` | 5 destinos; FAB em Início e Lançamentos |
| Raiz/modais | `_layout` (fontes, DB, tema, gate biométrico, lembretes) · `onboarding` (4 passos) · `transaction` (form) · `customize` (dashboard) · `available` (como calculamos) | |
| Contas | `accounts/index`, `accounts/new` (redirect → edit), `accounts/edit`, `accounts/[id]` | ajuste de saldo, arquivar, excluir com bloqueio |
| Cartões | `cards/index`, `cards/new` (também edita via `?id`), `cards/[id]`, `cards/installments` | navegação por fatura, pagamento total/mínimo/parcial |
| Planejar | `budgets/index`, `budgets/new`, `goals/index`, `goals/new`, `goals/[id]`, `loans/index`, `loans/new`, `loans/[id]` | |
| Outros | `bills`, `calendar`, `categories`, `assistant`, `import`, `export`, `settings`, `privacy`, `help`, `paywall` | |
| Relatórios | `reports/index`, `cashflow`, `categories`, `recurring`, `projection`, `indicators` | indicators com gate Plus |
| Compras | `shopping/list/new`, `shopping/list/[id]`, `shopping/session`, `shopping/scan` | |

## 2. Inventário das regras financeiras (packages/core, 229 símbolos exportados)
| Módulo | Regras | Testes |
|---|---|---|
| `money/money.ts` | centavos inteiros; `cents()`, add/sub/mul/div com modos half-even/half-up/down; `allocate` (soma exata, resto nas primeiras/últimas); `parseMoneyBR` (R$ 1.234,56 / 1,234.56 / ambíguos → null); `formatBRL` (privacidade, −0 normalizado); `percentOf` | 19 |
| `dates/dates.ts` | datas de calendário `YYYY-MM-DD` sem fuso; `addMonthsClamped` com dia-âncora; `addDays` via epoch UTC; chaves de mês; `lastMonthKeys`, `monthKeysBetween`; `todayISO(clock)` | 9 |
| `domain/ledger.ts` | efetivo/pendente (parcial com `paidCents`); efeito por conta por tipo (10 tipos); transferência e depósito/resgate de meta como débito/crédito; saldo por conta até data; consolidado (arquivadas opcionais); totais do mês (compra no cartão = despesa na data; pagamento de fatura ≠ despesa); atrasadas; próximas | 6 |
| `domain/cards.ts` | mês da fatura pelo fechamento; vencimento mesmo mês/seguinte; estados open/closed/overdue/paid/future; `invoice` (compras, pagamentos por `invoiceMonth`, pagos parciais); `cardCommitment` (atual, fechadas, futuras, limite livre); `planInstallments` (allocate + 1 por fatura + offset) | 8 |
| `domain/recurrence.ts` | 8 frequências; `occurrencesBetween`, `nextOccurrence`; count/endDate | 4 |
| `domain/availability.ts` | "pode gastar" com linhas: saldos considerados − atrasadas − previstas até horizonte − faturas (fechadas não pagas + atual) − reservas dentro de contas consideradas − colchão (+ receitas previstas no modo otimista); `status` positive/tight/negative; `simulatePurchase` | 5 |
| `domain/budgets.ts` | orçamento por categoria (subcategoria soma na mãe) e global; mês específico > modelo; ritmo sereno/atenção/agitado com marca de hoje | 4 |
| `domain/goals.ts` | guardado = depósitos − resgates; sugestão mensal; progresso esperado por prazo | 1 |
| `domain/loans.ts` | Price e SAC; juros half-up; última parcela absorve resíduo; tarifas mensais e iniciais; posição (parcelas pagas por imputação, extra, atrasadas); quitação = VP à taxa contratual; pagamento extra (reduzir prazo/parcela) | 7 |
| `domain/reports.ts` | categorias (roll-up), fluxo de caixa com saldo ao fim do mês, comparativo, resumo anual, recorrentes (série ou 3+ meses), projeção de saldo (previstos, parcelas, faturas), patrimônio, busca com filtros | 7 |
| `domain/assistant.ts` | 9 intenções por regex pt-BR com valor; respostas com `basis`; 6 recomendações por regra | 3 |
| `dashboard/widgets.ts` | 24 widgets, 4 modelos, mostrar/ocultar/mover, normalização de layout | 4 |
| `billing/*` | 4 planos, limites do grátis, `resolveAccess` (estados, carência, cache 7 dias, vitalício sem sync), `withinLimit`, merge | 9 |
| `io/*` | CSV (delimitador, mapeamento pt/en, datas, valores), OFX SGML/XML, duplicidades (externalRef/exato/parecido/lote), legado `pouso-financas-v2`, backup `serenacash` v1 | 9 |
| `sync/model.ts` | change record, merge por campo com conflito obrigatório em monetários/status | 3 |

## 3. Inventário das entidades (packages/core/src/domain/types.ts)
Account (type, openingBalanceCents, openingDate, includeInAvailability, archived) · Category (kind, parentId, icon, color) · Tag · CreditCard (limit, closingDay, dueDay, defaultPaymentAccountId) · Transaction (10 kinds, status planned/settled/partially_paid/cancelled, paidCents, settledDate, dueDate, installment{number,of,groupId}, seriesId, transferGroupId, invoiceMonth, tags, notes, attachments, merchant, externalRef) · Budget (categoryId?, limit, month?, rollover) · Goal (kind, target, targetDate, accountId, reserved) · Loan (principal, monthlyRatePercent, termMonths, system, firstDueDate, fees) · UserPrefs · RecurrenceRule (+templateTransactionId, lastGenerated no app). Compras: ShoppingList/ListItem (unit, quantity, estimatedUnitPriceCents, estimateSource) · CartLine (promo, discounts, priceSource, confidence) · ShoppingSession (lines, events, transactionId, receiptAccessKey) · Product (barcode, internalCodes) · PriceObservation. Billing: Entitlement.

## 4. Estrutura do banco (apps/mobile/src/data)
- expo-sqlite, WAL. **14 tabelas-documento** (`id, json, updated_at, deleted_at, version, dirty`) + `kv` + `change_log` + `attachments`; migração v2 adiciona colunas geradas `date`/`kind` em `transactions` (tolerante a falha).
- Toda escrita passa por `DocumentRepository` com soft delete e registro em `change_log`.
- Limitação real: JSON por linha → sem integridade referencial, sem índices por conta/categoria; consultas carregam tudo em memória (adequado até dezenas de milhares de lançamentos). **Decisão para o Flutter: esquema relacional tipado (Drift), não documentos.**

## 5. Integrações
| Integração | Pacote RN | Estado real |
|---|---|---|
| Câmera e códigos | expo-camera | implementada; não validada em aparelho |
| OCR | @react-native-ml-kit/text-recognition 2.0 (lazy) | implementada; Nova Arquitetura não verificada; nunca executada |
| Compras | react-native-purchases 10.16 (lazy) + fallback | implementada; nunca executada (sem chaves) |
| Biometria | expo-local-authentication | gate ao abrir e ao voltar do background; não validado |
| Notificações | expo-notifications | lembretes locais (D-1 e D0, 9h); não validados |
| Arquivos/PDF | expo-document-picker, file-system, sharing, print | não validados em aparelho |
| Fontes | @expo-google-fonts/bricolage-grotesque | OK no preview web |

## 6. Realmente implementadas (código + teste ou verificação visual)
Onboarding · contas (CRUD, ajuste, arquivar) · lançamentos (4 tipos de formulário + tipos internos, previsto, parcial, recorrência, parcelas, tags, desfazer) · cartões/faturas/pagamento/parcelas · orçamentos com ritmo · metas com depósito/resgate · empréstimos (Price/SAC, quitação, extra) · contas a pagar · calendário · relatórios (6) · assistente · importação CSV/OFX/backup com revisão · exportação CSV/PDF/backup · dashboard 24 widgets com personalização (drag + setas) · listas · sessão de compras com carrinho/orçamento/finalização/despesa única · paywall e direitos · configurações · privacidade (apagar tudo) · ajuda.

## 7. Parcialmente implementadas
Anexos (modelo e tabela; sem tela) · estorno de cartão (sem tipo próprio) · planejamento anual (só relatório) · histórico de alterações (change_log sem tela) · i18n (strings pt-BR embutidas) · drag-and-drop (código presente, gesto não validado) · OCR/câmera/compras/biometria/notificações (código presente, sem validação nativa) · tablet (coluna única).

## 8. Não implementadas
Sincronização (só modelo de merge e interface de transporte) · backup criptografado · PIN · criptografia do banco · compartilhamento de listas · IA externa · painel administrativo · capturas/textos de loja.

## 9. Problemas identificados no código original
1. Persistência por documentos JSON sem integridade referencial (ver §4).
2. `goal_deposit` com `toAccountId` igual ao `accountId` (reserva dentro da mesma conta) depende de convenção não validada na UI.
3. `recurrence` gera 3 meses à frente e materializa no boot; não há tela de gestão de séries.
4. `cards.ts`: `invoice()` filtra pagamentos com uma expressão `a && b || c` sem parênteses (funciona, mas frágil).
5. Preview web: após voltar de tela empilhada, container anterior intercepta toques (quirk web; não afeta nativo).
6. `assistant.ts` detecta intenções por regex; frases fora do padrão caem em "unknown".
7. Limites do grátis para listas usam a feature `unlimited_accounts` no paywall (rótulo errado).
8. Backup JSON em texto puro, sem criptografia nem autenticação.

## 10. Riscos da migração
Divergência de arredondamento (JS `Math.round` vs Dart) · datas (JS Date UTC vs Dart DateTime) · regex pt-BR com Unicode · ordem de iteração de Map/Set · `allocate` e `planInstallments` (soma exata) · perda de preferências/layout · formato de backup (manter v1) · OCR e câmera com pacotes Flutter diferentes (parser deve ser reimplementado com os mesmos fixtures) · RevenueCat Flutter com IDs de produto iguais.

## 11. Dependências externas (inalteradas pela migração)
Conta Expo não mais necessária · Apple Developer e Play Console · RevenueCat (chaves públicas) · INPI/domínio · fontes Google (Bricolage Grotesque, OFL).

## 12. Critérios de equivalência funcional
1. Todos os fixtures JSON extraídos do TypeScript (docs/flutter-migration/fixtures) passam no domínio Dart com igualdade exata em centavos e datas, salvo divergências documentadas em `02-EQUIVALENCIA_DOMINIO.md`.
2. Cada rota da §1 tem equivalente Flutter com os mesmos dados, ações e estados vazio/erro.
3. 24 widgets com os mesmos ids, modelos e comportamento de personalização.
4. Backup v1 e legado `pouso-financas-v2` importáveis sem perda; exportação CSV idêntica.
5. Limites do grátis e política do vitalício idênticos.
6. Fluxo de compras: lista → sessão → carrinho → finalizar → despesa única.
