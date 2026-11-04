# 09 — Testes

Suíte: `apps/serenacash_flutter/test` (317 testes) + fixtures TS→Dart em `docs/flutter-migration/fixtures`.

| Camada | Local | O que cobre | Qtde |
|---|---|---|---|
| Domínio (equivalência) | `test/domain/*_fixtures_test.dart`, `shopping_test.dart`, `io_test.dart`, `planning_test.dart`, `reports_assistant_billing_test.dart`, `ledger_cards_recurrence_test.dart` | 22 fixtures / 272 casos reproduzidos sem divergência monetária + invariantes (estorno, erros, arredondamento) | 279 |
| Persistência e segurança | `test/data/*` | esquema/índices/FK/CHECK, round-trip, idempotência, exclusão lógica, anexos com hash, stream, prefs, compras, SQLCipher (chave errada falha, arquivo não é SQLite em claro), PIN Argon2id, backup AES-GCM (adulteração), serviço de backup (v1, cifrado, legado, erros sem efeito), mapeamento RevenueCat | 29 |
| App (widget/fluxo) | `test/app/*` | app real com banco em memória: onboarding → pode gastar → lançamento → lista → tema escuro; 24 widgets; privacidade; contas → cartão → compra parcelada → fatura; orçamento/meta/empréstimo/relatórios; lista → sessão → despesa; leitura simulada de código/etiqueta; histórico e anual | 9 |
| Performance | `test/perf/perf_test.dart` | painel com 5.000 lançamentos, busca, banco | 3 |

Execução dos gates (todos sem `|| true`):

```bash
cd apps/serenacash_flutter && flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs && flutter gen-l10n
```

```bash
dart format --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test
```

Capturas de tela: `flutter test --update-goldens` grava PNGs em `test/app/goldens/` (copiados para `screenshots/`); numa execução normal as capturas não são comparadas (artefato de documentação, não golden de regressão), evitando falhas por rasterização de fonte entre máquinas.

Testes de integração em aparelho (`integration_test/`): o diretório existe como alvo do gate `flutter test integration_test`; a execução exige dispositivo/emulador, indisponível neste ambiente (ver `11-BUILD_CI.md`). Os cenários de dispositivo (câmera, OCR, biometria, notificações, compras em sandbox) estão no checklist de `docs/13-guia-teste-dispositivo.md`.

Resultado nesta sessão: `flutter test` → 317 verdes; `flutter analyze` → 0 issues; `dart format` → 0 alterações.
