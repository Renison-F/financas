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

## Progresso M6–M7 — concluído
- Pendências fechadas: anexos (câmera/arquivo, ≤ 10 MB, SHA-256, dentro do banco cifrado, gate Plus), tela de histórico de alterações com contagem pendente de sincronização e conflitos, planejamento anual (resultado mês a mês, orçamento vigente, metas até o fim do ano).
- Compras: nova lista, detalhe (itens por categoria, unidades, estimativa só com preços conhecidos, marcar/duplicar/excluir), sessão (total, orçamento com marca de progresso, itens da lista, manual, etiqueta/código, promoções, finalização com observações de preço, despesa única idempotente), câmera (`mobile_scanner` + `image_picker` + ML Kit atrás de `OcrService`, fallback manual, permissão negada tratada).
- Testes: 3 fluxos novos (lista → sessão → despesa; leitura simulada de código/etiqueta; histórico e anual). 18 capturas em `screenshots/`.

## Progresso M8–M10
- RevenueCat (`purchases_flutter` 11) atrás de `StoreBilling`; mapeamento puro testado; chaves por `--dart-define`.
- Testes de performance (painel 5k lançamentos 84 ms; DB load 237 ms), CI `flutter.yml` (format/analyze --fatal-infos/test/apk), Android `allowBackup=false` + regras de extração, iOS usage descriptions, `integration_test/app_test.dart`.
- Docs 04, 07–12, RELATORIO_FINAL e auditoria consolidada.
- Bloqueios: APK (sem Android SDK: `dl.google.com` 403), iOS (sem macOS), aparelho (câmera/OCR/biometria/compras).

## Próximos passos
1. Executar o CI (APK) e validar em aparelho conforme `docs/13-guia-teste-dispositivo.md`.
2. Configurar lojas/RevenueCat (ação do cliente) e assinar release.
3. Após paridade validada em aparelho, decidir remoção do código RN.
