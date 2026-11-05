# 09 — Testes

Suíte: `apps/serenacash_flutter/test` + fixtures TS→Dart em `docs/flutter-migration/fixtures`.

## Contagem real (execução de 05/11/2026, commit desta alteração)

| Resultado | Qtde |
|---|---|
| Aprovados | 399 |
| Ignorados (`skip`) | 0 |
| Com falha | 0 |
| **Total executado** | **399** |

Comando: `flutter test` em `apps/serenacash_flutter` (saída final `+399: All tests passed!`). As referências antigas a 317, 320, 349 e 359 testes ficaram desatualizadas; o número cresceu com os testes de PIN, lembretes, backup de Compras, regressões da homologação, da tela inicial, de categorias e do tour de telas.

| Camada | Local | O que cobre | Aprovados | Ignorados | Falhas |
|---|---|---|---|---|---|
| Domínio (equivalência e regras) | `test/domain/*` | 22 fixtures / 272 casos TS reproduzidos sem divergência monetária + invariantes (estorno, erros, arredondamento); `regressions_test.dart`: resultado do dia do calendário, ranking do ano limitado ao mês corrente, saudação por horário, plurais e rótulos do resumo de importação | 288 | 0 | 0 |
| Persistência e segurança | `test/data/*` | esquema/índices/FK/CHECK, round-trip, idempotência, exclusão lógica, anexos com hash, stream, prefs, compras, SQLCipher (chave errada falha, arquivo não é SQLite em claro), PIN Argon2id, backup AES-GCM (adulteração), serviço de backup (v1, cifrado, legado, erros sem efeito), mapeamento RevenueCat; `backup_shopping_test.dart`: Compras no backup (ida e volta, substituição, backup antigo sem Compras, seção malformada aborta) | 48 | 0 | 0 |
| App (widget/fluxo) | `test/app/*` | app real com banco em memória: onboarding → pode gastar → lançamento → lista → tema escuro; 24 widgets; privacidade; contas → cartão → compra parcelada → fatura; orçamento/meta/empréstimo/relatórios; lista → sessão → confirmação de finalização → despesa; leitura simulada de código/etiqueta; histórico e anual; `pin_lock_test.dart`; `reminders_host_test.dart`; `regressions_flow_test.dart` (desfazer, "Cancelar" sem corte, cores com nome, senha oculta, onboarding: voltar um passo e configuração interrompida sem duplicar conta); `home_redesign_test.dart` (primeiro acesso, conta sem movimentações, com dados, claro/escuro, valores ocultos, ações rápidas e período, tela estreita com fonte a 200%); `categories_flow_test.dart` (regras de hierarquia; excluir movendo também os lançamentos excluídos; criar com ícone e cor, subcategoria, editar, arquivar pelo menu lateral; criar categoria e subcategoria durante o lançamento sem perder o que foi digitado; excluir pedindo o destino; totais sem dupla contagem e filtro por categoria); `tour_test.dart` (20 telas com dados em claro, escuro e em 320 pt com texto a 150%) | 55 | 0 | 0 |
| Performance | `test/perf/perf_test.dart` | painel com 5.000 lançamentos, busca, banco | 8 | 0 | 0 |

## Gates (todos sem `|| true`)

```bash
cd apps/serenacash_flutter && flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs && flutter gen-l10n
```

```bash
dart format --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test
```

Resultado em 05/11/2026: `dart format` → 0 alterações; `flutter analyze --fatal-infos` → 0 issues; `flutter test` → 399 aprovados, 0 ignorados, 0 falhas.

## Capturas de tela

`flutter test --update-goldens` grava PNGs em `test/app/goldens/` (copiados para `screenshots/`); numa execução normal as capturas não são comparadas (artefato de documentação, não golden de regressão), evitando falhas por rasterização de fonte entre máquinas.

## Testes em aparelho

`flutter test integration_test -d emulator-5554` roda `integration_test/app_test.dart` (1 teste: banco cifrado abre, onboarding conclui, início mostra "pode gastar"). Em 05/11/2026 passou no emulador `serenacash_api35` (Android 15). A ferramenta é instável nesse emulador: a conexão adb reinicia quando ela se conecta ao app e a execução pode travar ou falhar com "Failed to start Dart Development Service"; repetir com limite de tempo resolve. Como o teste pula o onboarding quando o app já tem dados, rode-o com os dados do app apagados.

**Depois do teste, reinstale o app.** O comando recompila `build/app/outputs/flutter-apk/app-debug.apk` com o ponto de entrada do teste e deixa essa build instalada no aparelho. Aberta pelo ícone, ela fica parada na tela de abertura (logotipo), sem erro no logcat, porque espera o executor de testes do PC e nunca chama `runApp`. Para voltar a usar o app, gere e instale uma build normal e confira abrindo pelo ícone:

```bash
flutter build apk --debug
```

```bash
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
```

Os cenários de dispositivo (câmera, OCR, biometria, notificações, compras em sandbox) estão no checklist de `docs/13-guia-teste-dispositivo.md`, escrito para o app React Native. A homologação do app Flutter no emulador está em `10-HOMOLOGACAO.md`.

## Testes acrescentados na homologação avançada (05/11/2026)

| Arquivo | O que prova | Testes |
|---|---|---|
| `test/app/financial_invariants_test.dart` | 15 invariantes financeiras e a recusa de entradas inválidas, pelo controlador real em banco em memória, com dados aleatórios semeados: precisão dos centavos, transferências, pagamento de fatura, parcelas, estorno, receita prevista, pagamento parcial, repetição, lote que falha no meio, backup e restauração, excluir e desfazer, peso, "pode gastar", datas de fatura, sessão de compras | 16 |
| `test/data/vault_recovery_test.dart` | Banco e chave juntos, com arquivo SQLCipher real: chave ausente ou danificada é recusada sem gerar outra; apagar remove arquivo, WAL e chave; arquivo corrompido é preservado | 6 |
| `test/data/pin_throttle_test.dart` | Tentativas de PIN: contagem, pausas crescentes, persistência, contador danificado, nada em claro | 7 |
| `test/data/backup_resilience_test.dart` | Dez formas de backup inválido recusadas sem mudar o banco; sal e nonce nunca repetidos | 2 |
| `test/app/pin_lock_test.dart` | Pausa na tela de bloqueio, "Esqueci o PIN", desativar com o PIN atual, formulário preservado ao bloquear | +3 |
| `test/app/regressions_flow_test.dart` | Toque duplo em salvar grava uma vez | +1 |
| `test/perf/volume_test.dart` | Escala de 100 a 50.000 lançamentos | 5 |

Contagem por camada: domínio 288, dados 48, app 55, desempenho 8.

O teste de integração roda em uma instalação isolada para não apagar os dados do app que está no aparelho:

```bash
SERENA_APP_ID_SUFFIX=.itest flutter test integration_test -d emulator-5554
```

