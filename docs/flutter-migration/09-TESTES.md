# 09 — Testes

Suíte: `apps/serenacash_flutter/test` + fixtures TS→Dart em `docs/flutter-migration/fixtures`.

## Contagem real (execução de 05/11/2026, commit desta alteração)

| Resultado | Qtde |
|---|---|
| Aprovados | 349 |
| Ignorados (`skip`) | 0 |
| Com falha | 0 |
| **Total executado** | **349** |

Comando: `flutter test` em `apps/serenacash_flutter` (saída final `+349: All tests passed!`). As referências antigas a 317 e 320 testes ficaram desatualizadas; o número cresceu com os testes de PIN, lembretes, backup de Compras, regressões da homologação e da nova tela inicial.

| Camada | Local | O que cobre | Aprovados | Ignorados | Falhas |
|---|---|---|---|---|---|
| Domínio (equivalência e regras) | `test/domain/*` | 22 fixtures / 272 casos TS reproduzidos sem divergência monetária + invariantes (estorno, erros, arredondamento); `regressions_test.dart`: resultado do dia do calendário, ranking do ano limitado ao mês corrente, saudação por horário, plurais e rótulos do resumo de importação | 288 | 0 | 0 |
| Persistência e segurança | `test/data/*` | esquema/índices/FK/CHECK, round-trip, idempotência, exclusão lógica, anexos com hash, stream, prefs, compras, SQLCipher (chave errada falha, arquivo não é SQLite em claro), PIN Argon2id, backup AES-GCM (adulteração), serviço de backup (v1, cifrado, legado, erros sem efeito), mapeamento RevenueCat; `backup_shopping_test.dart`: Compras no backup (ida e volta, substituição, backup antigo sem Compras, seção malformada aborta) | 33 | 0 | 0 |
| App (widget/fluxo) | `test/app/*` | app real com banco em memória: onboarding → pode gastar → lançamento → lista → tema escuro; 24 widgets; privacidade; contas → cartão → compra parcelada → fatura; orçamento/meta/empréstimo/relatórios; lista → sessão → confirmação de finalização → despesa; leitura simulada de código/etiqueta; histórico e anual; `pin_lock_test.dart` (definir PIN, tela de bloqueio, PIN errado e depois o correto); `reminders_host_test.dart` (toque no lembrete com app aberto e em abertura a frio, lançamento inexistente, reagendamento); `regressions_flow_test.dart` (um único aviso de desfazer, "Cancelar" sem corte, cores com nome, senha oculta); `home_redesign_test.dart` (tela inicial: primeiro acesso sem valor inventado, conta sem movimentações, estado com dados, claro/escuro, valores ocultos, ações rápidas e período, tela estreita com fonte a 200%) | 25 | 0 | 0 |
| Performance | `test/perf/perf_test.dart` | painel com 5.000 lançamentos, busca, banco | 3 | 0 | 0 |

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

Resultado em 05/11/2026: `dart format` → 148 arquivos, 0 alterações; `flutter analyze --fatal-infos` → 0 issues; `flutter test` → 349 aprovados, 0 ignorados, 0 falhas.

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
