# 02 — Equivalência do domínio (TypeScript → Dart)

Origem auditada: `ae2c229c4977dcc6f78a19e7e4388cacced9d61b` (`packages/core`, `packages/shopping`).
Destino: `apps/serenacash_flutter/lib/domain/**` (Dart puro, sem Flutter, sem banco, sem UI).

## Método

1. Cada módulo TypeScript ganhou um gerador de fixtures (`packages/core/src/fixtures.gen.test.ts`,
   `packages/shopping/src/fixtures.gen.test.ts`) que executa as funções reais da suíte original e grava
   `docs/flutter-migration/fixtures/<módulo>.json` com `{name, input, expected, note}` por caso.
2. Os testes Dart (`apps/serenacash_flutter/test/domain/*_test.dart`) carregam o mesmo JSON e comparam
   o resultado da implementação Dart com `expected` usando igualdade estrutural (`jsonEquals`),
   sem tolerância numérica: inteiros em centavos e strings precisam ser idênticos.
3. Regras sem fixture (invariantes, erros, `card_refund`) têm testes unitários próprios no mesmo diretório.
4. Gates executados: `dart format --set-exit-if-changed lib test` (0 alterações),
   `flutter analyze` (No issues found), `flutter test` (279 testes verdes).

## Mapa módulo a módulo

| Módulo TS | Arquivo Dart | Fixture | Casos | Resultado |
|---|---|---|---|---|
| `money.ts` | `domain/money/money.dart` | money.json | 46 | idêntico |
| `dates.ts` | `domain/dates/dates.dart` | dates.json | 25 | idêntico |
| `entities.ts` | `domain/entities/entities.dart` | ledger.json (round-trip) | 1 | idêntico (+ campos novos, ver divergências) |
| `ledger.ts` | `domain/ledger/ledger.dart` | ledger.json | 1 (multi-asserção) | idêntico |
| `cards.ts` | `domain/cards/cards.dart` | cards.json | 18 | idêntico |
| `recurrence.ts` | `domain/recurrence/recurrence.dart` | recurrence.json | 8 | idêntico |
| `availability.ts` | `domain/availability/availability.dart` | availability.json | 4 | idêntico |
| `budgets.ts` | `domain/budgets/budgets.dart` | budgets.json | 13 | idêntico |
| `goals.ts` | `domain/goals/goals.dart` | goals.json | 1 | idêntico |
| `loans.ts` | `domain/loans/loans.dart` | loans.json | 13 | idêntico |
| `reports.ts` | `domain/reports/reports.dart` | reports.json | 12 | idêntico |
| `assistant.ts` | `domain/assistant/assistant.dart` | assistant.json | 23 | idêntico |
| `billing.ts` | `domain/billing/billing.dart` | billing.json | 16 | idêntico |
| `dashboard.ts` | `domain/dashboard/widgets.dart` | dashboard.json | 5 | idêntico |
| `sync.ts` | `domain/sync/sync_model.dart` | sync.json | 3 | idêntico |
| `io/csv.ts`, `io/ofx.ts`, `io/duplicates.ts`, `io/legacy.ts`, `io/backup.ts` | `domain/io/*.dart` | io.json | 16 | idêntico |
| `shopping/units.ts` | `domain/shopping/units.dart` | shopping_units.json | 12 | idêntico |
| `shopping/cart.ts` | `domain/shopping/cart.dart` | shopping_cart.json | 15 | idêntico |
| `shopping/codes.ts` | `domain/shopping/codes.dart` | shopping_codes.json | 15 | idêntico |
| `shopping/pricetag.ts` | `domain/shopping/pricetag.dart` | shopping_pricetag.json | 8 | idêntico |
| `shopping/lists.ts` | `domain/shopping/lists.dart` | shopping_lists.json | 5 | idêntico |
| `shopping/products.ts` | `domain/shopping/products.dart` | shopping_products.json | 7 | idêntico |
| `shopping/session.ts` | `domain/shopping/session.dart` | shopping_session.json | 6 | idêntico |

Total: 22 arquivos de fixture, 272 casos gerados a partir do TypeScript, todos reproduzidos em Dart sem
divergência monetária. Testes Dart totais: 279 (fixtures + invariantes).

## Regras financeiras verificadas

- **Centavos inteiros** em todo o domínio; `mulCents` reproduz a semântica de `Math.round` do JS
  (`floor(v + 0.5)`) e o "snap" de ruído de ponto flutuante (`raw * 1e6`) antes do arredondamento.
  Modos: `halfEven` (padrão), `halfUp` (itens pesados, parcelas de empréstimo), `down`.
- **`allocate`** distribui resto em centavos sem perder nem criar dinheiro (soma exata).
- **Datas sem fuso**: strings ISO `YYYY-MM-DD`, aritmética em dias-época UTC; `addMonthsClamped`
  respeita dia-âncora (31 → 28/29/30).
- **Cartão**: mês da fatura por dia de fechamento; parcelas uma por fatura; pagamento de fatura não é
  despesa; estorno (`card_refund`) reduz a fatura e as despesas do mês sem gerar receita.
- **Pode gastar**: decomposição saldo − pendentes − faturas − compromissos − colchão, com horizonte.
- **Ritmo de orçamento**: `sereno`/`atencao`/`agitado` comparando gasto acumulado com a "marca de hoje".
- **Empréstimos**: Price e SAC, valor presente de quitação, pagamento extra; parcelas `halfUp`.
- **Relatórios e buscas**: ordenações estáveis (desempate por índice) para igualar `Array.sort` do V8.
- **Assistente determinístico**: intents por regex com remoção de acentos (mapa idêntico ao TS).
- **Direitos (billing)**: carência, cache de 7 dias, vitalício sem sincronização, limites do plano grátis.
- **Compras**: pesados arredondam `halfUp` como balança; promoções leve X pague Y só em contáveis;
  desconto nunca negativa a linha; estimativa de lista soma só preços conhecidos; sessão nunca cria
  transação (apenas sugere, com `externalRef = shopping:<id>` para idempotência).

## Divergências documentadas (intencionais)

| # | Onde | Divergência | Motivo |
|---|---|---|---|
| D1 | `entities.dart` / `io/legacy.ts` | Dart aceita `TransactionKind.cardRefund` (`card_refund`) e `refundOfId`; `validateCardRefund` em `cards.dart`. TS original não tinha estorno. | Pendência do escopo (estorno de cartão). Fixtures do TS não cobrem; testes unitários Dart cobrem. |
| D2 | `UserPrefs` | Dart adiciona `lockOnBackground` e `pinEnabled` (padrão `false`). O teste `importLegacy` remove essas chaves antes da comparação. | Pendência PIN + biometria. Importação legada mantém padrões seguros. |
| D3 | `packages/core/src/io/legacy.ts` | Cor padrão de conta `#24477A` (marca anterior) corrigida para `#0B5563` (SerenaCash) **no TS** e fixture regenerada. | Bug de origem (cor desatualizada após troca de marca). Não reproduzido deliberadamente; corrigido na origem, não escondido. |
| D4 | `formatBRL` | Usa `NumberFormat('pt_BR')` do `intl` com NBSP entre `R$` e o valor, igual ao `Intl.NumberFormat` do JS. `-0` normalizado para `0`. | Mesma saída; implementação diferente. |
| D5 | `pricetag.dart` | Ordenação de candidatos com desempate por índice. | Reproduz a ordem estável do V8 sem depender de detalhe de implementação. |

Nenhuma divergência monetária foi ignorada. Nenhum bug do TS foi reproduzido conscientemente além dos
listados como corrigidos (D3).

## Como reexecutar

```bash
cd packages/core && npx vitest run src/fixtures.gen
```

```bash
cd packages/shopping && npx vitest run src/fixtures.gen
```

```bash
cd apps/serenacash_flutter && flutter test
```
