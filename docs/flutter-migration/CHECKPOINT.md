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

## Progresso M3 (persistência) — concluído
- Ports do domínio em `lib/domain/ports/` (ledger, shopping, prefs, change log, auth, sync, backup em nuvem, direitos, família, clock/ids).
- Esquema Drift v1 (23 tabelas, CHECK/FK/índices, dump em `drift_schemas/`), repositórios, change log, conflitos, relatórios de importação.
- SQLCipher 4.19 via hook do `sqlite3` (fail-closed), chave no Keystore, PIN Argon2id, backup AES-256-GCM + Argon2id, importação v1/cifrada/legado.
- Gates: `flutter analyze` sem issues, `dart format` sem alterações, `flutter test` 305 verdes.

## Progresso M4–M5 (UI) — concluído
- Design system Flutter (tokens do DESIGN.md, Bricolage Grotesque embarcada, ícones próprios, Money, barra de ritmo, cartões, botões, chips, campos, folhas de confirmação).
- Shell: Riverpod DI, AppController (porta do appStore RN), GoRouter com 5 abas + 40 rotas, gate PIN/biometria, lembretes locais, i18n pt-BR/en (776 chaves).
- Telas: início (24 widgets, 4 presets, personalização com arrastar/setas), pode gastar, lançamentos (lista, formulário com parcelas/série/baixa/parcial/exclusão com desfazer), planejar, contas, categorias/tags, cartões (fatura, pagamento, histórico, parceladas), orçamentos, metas (guardar/resgatar), empréstimos (Price/SAC, simulação, tabela), calendário, contas a pagar, relatórios (fluxo, categorias, recorrentes, projeção, indicadores), assistente, importação (CSV/OFX/backup com mapeamento, duplicidades, relatório), exportação (CSV, PDF, backup cifrado/claro), privacidade (apagar tudo), ajuda, paywall (port de loja; RevenueCat em M8), configurações, onboarding.
- Testes de fluxo com app real em banco em memória (6 cenários) e 13 capturas em `docs/flutter-migration/screenshots/`.

## Próximos passos
1. M6: anexos no detalhe do lançamento, tela de histórico de alterações (change log), planejamento anual, estado de sincronização.
2. M7: compras (listas, sessão, mobile_scanner, ML Kit OCR, histórico de preços).
3. M8–M10: RevenueCat (purchases_flutter), auditoria de segurança, performance, CI, release.
