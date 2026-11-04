# CHECKPOINT — migração Flutter

- Origem congelada: `ae2c229c4977dcc6f78a19e7e4388cacced9d61b` (React Native/Expo, testes 100+18+11 verdes).
- Branch: `refactor/flutter-serenacash`. Sem merge na main. Histórico preservado.
- Flutter SDK: 3.47.9 em `/opt/flutter` (instalado nesta sessão a partir de storage.googleapis.com). Android SDK: **bloqueado** (dl.google.com 403). iOS: sem macOS.
- Projeto: `apps/serenacash_flutter` (org `br.com.serenacash`, applicationId/bundle `br.com.serenacash.mobile`).
- Fixtures de equivalência: `docs/flutter-migration/fixtures/*.json` (gerados por `packages/*/src/fixtures.gen.test.ts`).
- Diretriz adicional de arquitetura do cliente incorporada em `00-PLANO_MESTRE.md` e `03-ARQUITETURA_FLUTTER.md` (ADR-03..08).

## Progresso M2 (domínio Dart)
| Módulo | Estado |
|---|---|
| money | equivalente (fixtures + regras extras) |
| dates | equivalente |
| entidades, ledger, cards, recurrence, availability, budgets, goals, loans, reports, assistant, billing, dashboard, io, sync, shopping | pendente |

## Próximos passos
1. Entidades (freezed) e ledger/cards/recurrence com fixtures.
2. availability/budgets/goals/loans/reports/assistant/billing/dashboard/io/sync.
3. shopping (units, cart, codes, pricetag, lists, products, session).
4. M3 Drift relacional + criptografia + backup.
