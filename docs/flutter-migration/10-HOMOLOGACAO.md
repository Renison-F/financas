# 10 — Homologação do app Flutter no emulador

Registro da homologação feita em 04 e 05/11/2026 no emulador `serenacash_api35` (Pixel 7, Android 15, API 35), com dados fictícios. O checklist-base foi a seção 6 de `docs/13-guia-teste-dispositivo.md` (escrito para o app React Native), adaptado ao Flutter.

## Como repetir

Com o emulador aberto, em `apps/serenacash_flutter`:

```bash
flutter run -d emulator-5554
```

```bash
flutter test integration_test -d emulator-5554
```

Observações de ambiente (Windows):

- A partir de um shell em que o Gradle falhe com `Unable to establish loopback connection`, defina só para o processo `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=<pasta gravável>`.
- O `integration_test` é instável nesse emulador (a conexão adb reinicia quando a ferramenta se conecta): repita com limite de tempo. Ele pula o onboarding quando o app já tem dados; apague os dados antes (`adb shell pm clear br.com.serenacash.mobile`).
- O `integration_test` deixa instalada uma build com o ponto de entrada do teste (e sobrescreve `build/app/outputs/flutter-apk/app-debug.apk` com ela). Aberta pelo ícone, essa build fica parada na tela de abertura, sem erro no logcat. Depois do teste, rode `flutter build apk --debug`, reinstale e abra pelo ícone para conferir. Aconteceu em 05/11/2026: o app pareceu travado na abertura e o código não tinha defeito.
- Capturas: `adb exec-out screencap -p > arquivo.png` em um shell POSIX (no PowerShell 5.1 o redirecionamento corrompe o PNG).
- O emulador usado está em fuso GMT; à noite a data do app fica um dia à frente da do PC.

## Resultado

Roteiro percorrido: onboarding, bloqueio por PIN, lançamentos (despesa, receita prevista, parcial, série, exclusão com desfazer, transferência), cartões e fatura, orçamento, meta, relatórios, calendário, projeções, lista e sessão de compras, exportação e restauração de backup, configurações, notificações. O app não caiu nem travou e todos os valores conferiram com a conta manual.

| # | Achado | Situação | Onde foi corrigido |
|---|---|---|---|
| 1 | Build release falhava no R8 (classes opcionais do ML Kit) | Corrigido | `android/app/proguard-rules.pro`, `build.gradle.kts` |
| 2 | Lembretes agendados sem receptor no manifest; toque não abria o lançamento; só agendava ao tocar em "Ativar lembretes" | Corrigido e validado com notificação real | `AndroidManifest.xml`, `bill_reminders.dart`, `app/reminders_host.dart` |
| 3 | Tela vermelha ao definir o PIN em debug (controller descartado cedo) | Corrigido | `settings_screen.dart` |
| 4 | Depois de um PIN errado o correto não entrava (campo sem `Overlay`) | Corrigido | `lock_gate.dart` |
| 5 | Cadeado gigante na tela de bloqueio | Corrigido | `lock_gate.dart` |
| 6 | Aviso de "Desfazer" duplicado | Corrigido | `router.dart` (um `UndoHost` no shell) |
| 7 | "Total do dia" do calendário somava o que só move dinheiro | Corrigido | `ledger.dart` (`resultCents`), `calendar_screen.dart` |
| 8 | Backup sem os dados de Compras (herdado do formato v1 do app RN) | Corrigido com chave de extensão `shopping` | `backup_service.dart` |
| 9 | PIN e senhas de backup em texto claro | Corrigido | `SecretField` em `fields.dart` |
| 10 | "Finalizar compra" sem confirmação | Corrigido | `session_screen.dart` |
| 11 | Textos e acabamento ("Cance…", plurais, resumo em inglês, saudação, melhor mês futuro, ícone padrão do Flutter, cores lidas como código) | Corrigido (iOS: ícone e abertura não alterados) | `screen.dart`, ARB, `format.dart`, `reports.dart`, `android/.../res` |

## Notificações (validado em 05/11/2026)

Com o relógio do emulador adiantado temporariamente e depois restaurado:

- Os lembretes "vence amanhã" e "vence hoje" foram exibidos de fato. Os alarmes são inexatos: o Android pode entregar até 1 hora depois das 09:00.
- Tocar na notificação abriu o lançamento correto com o app aberto, em segundo plano e encerrado (abertura a frio).
- Com duas ou mais notificações o Android as agrupa; tocar no cabeçalho do grupo abre o app pela tela inicial (comportamento do sistema).
- Contas criadas depois de ativar os lembretes são agendadas sozinhas.

## Não coberto

Biometria (emulador sem biometria), leitura real de código de barras e OCR de etiqueta, compras em sandbox e restauração de compras, importação de CSV e OFX, TalkBack ligado, aparelho físico e iOS.
