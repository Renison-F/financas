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
| money, dates | equivalente (fixtures + regras extras) |
| entidades, ledger, cards, recurrence, availability, budgets, goals, loans | equivalente |
| reports, assistant, billing, dashboard, io, sync | equivalente |
| shopping (units, cart, codes, pricetag, lists, products, session) | equivalente |

M2 concluído: 22 fixtures / 272 casos TS reproduzidos, 279 testes Dart verdes, `flutter analyze` sem
issues, `dart format` sem alterações. Detalhes e divergências em `02-EQUIVALENCIA_DOMINIO.md`.

## Próximos passos
1. M3: esquema Drift relacional (constraints/índices), repositórios implementando as portas do domínio,
   migrações, SQLCipher via `sqlite3` 3.x, backup cifrado autenticado, importadores versionados.
2. M4–M6: design system, navegação, dashboard, módulos, relatórios, ferramentas.
3. M7–M10: compras com câmera/OCR, RevenueCat, segurança/performance, release.
