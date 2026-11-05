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

## Validação da identidade, das categorias e da navegação (05/11/2026)

No mesmo emulador, com dados fictícios e o APK debug da branch:

| Fluxo | Resultado |
|---|---|
| Onboarding até a tela inicial | Passou. Achado corrigido: fechar o app no meio da configuração e recomeçar criava a conta de novo (o saldo dobrava), e o voltar saía do app. |
| Botão "+" → folha "Adicionar" → Despesa | Passou; a folha cobre a barra inferior. |
| Seletor de categoria com busca; "Criar “Feiras”" a partir do nome buscado | Passou; o nome chega preenchido, e ao salvar a categoria volta selecionada com valor e descrição preservados. |
| Cor e ícone por busca ("feira" → mercado) | Passou. Achado corrigido: com um único ícone no resultado o botão não existia para o leitor de tela. |
| Subcategoria criada durante o lançamento | Passou; volta selecionada e a linha mostra "Feiras › Hortifruti". |
| Menu lateral: grupos, seção atual, voltar fecha o menu, voltar da tela retorna à aba | Passou. |
| Editar categoria e arquivar subcategoria | Passou; a arquivada vai para "Arquivadas" e o lançamento antigo continua com ela. |
| Conta a receber: criar pela folha, ver em "A receber", marcar como recebida | Passou; o saldo foi de 5.294,10 para 13.494,10. |
| Tema escuro e fonte do sistema a 130% | Passou, sem corte nem sobreposição. |
| Logcat | 0 erros do Flutter e 0 quedas. |

Não refeito nesta rodada: notificação real e toque nela (validado em 05/11 antes desta mudança; a rota do lançamento não mudou e os testes de `reminders_host_test.dart` continuam passando).

## Homologação avançada e endurecimento (05/11/2026, segunda rodada)

Ponto de partida conferido: branch local igual à remota em `dd7a081`, CI aprovado (execução 42018380546), emulador com o APK entregue e sem outra sessão em uso. O app e os dados que já estavam no emulador não foram apagados: os testes que apagam ou corrompem dados rodaram em uma instalação isolada (`SERENA_APP_ID_SUFFIX=.seg`, pacote `br.com.serenacash.mobile.seg`), removida ao final. O teste de integração rodou do mesmo jeito (`.itest`).

### Matriz de homologação

Legenda: **V** aprovado antes e ainda válido (código do fluxo não mudou); **N** aprovado de novo nesta rodada; **C** falhou, foi corrigido e retestado; **F** depende de aparelho físico; **E** depende de serviço externo; **P** pendente. Ambiente: **T** teste automatizado, **Em** emulador.

| Área | Item | Situação | Ambiente e evidência |
|---|---|---|---|
| Núcleo | Contas, saldos, ajuste de saldo | V + N | T: `modules_flow_test`, invariantes 2 e 10; Em: saldo conferido após atualização e reinício |
| Núcleo | Transferências | N | T: invariante 2 (40 transferências aleatórias, sem receita nem despesa) |
| Núcleo | Receitas e despesas | N | T: invariantes 1, 8 e entradas inválidas; Em: etapa 3 |
| Núcleo | Recorrências | N | T: invariante 11 (excluir série e desfazer); Em: primeira homologação |
| Núcleo | Pagamentos parciais | C | T: invariante 7. Defeito S11 corrigido |
| Núcleo | Contas previstas e vencidas | V + N | T: `home_redesign_test`, invariante 13; Em: tela inicial |
| Núcleo | Contas a receber | N | T: invariante 6; Em: etapa 3 |
| Núcleo | Cartões, faturas, pagamento | N | T: invariantes 3 e 14 (fechamento 1 a 31, vencimento 1 a 31, dois anos com fevereiro bissexto) |
| Núcleo | Parcelamentos | N | T: invariante 4 (25 compras, 2 a 24 parcelas) |
| Núcleo | Estornos | N | T: invariante 5 |
| Núcleo | Orçamentos | N | T: `categories_flow_test` (categoria e subcategoria contadas uma vez) |
| Núcleo | Metas e reservas | V | T: `modules_flow_test`, `home_redesign_test` |
| Núcleo | Empréstimos | V | T: `modules_flow_test`; fixtures do domínio |
| Núcleo | Planejamento anual | V | T: `shopping_flow_test` (tela) e fixtures |
| Núcleo | Calendário | V | T: `regressions_test` (resultado do dia) |
| Núcleo | Relatórios e projeções | V + N | T: `modules_flow_test`, `tour_test`, `categories_flow_test` |
| Núcleo | "Pode gastar" | N | T: invariante 13 (soma das linhas, 50 passos aleatórios) |
| Categorias | Criar, editar, arquivar, reativar, excluir com reclassificação, hierarquia, ícones, cores, busca, criação durante o lançamento | V | T: `categories_flow_test` (6 testes); Em: etapa 3. Persistência após reiniciar o app: Em |
| Painel | 24 widgets, personalização, modelos, períodos, privacidade, vazio e com dados, claro e escuro | V | T: `app_flow_test`, `home_redesign_test`, `tour_test` |
| Compras | Listas, quantidades, peso, descontos, promoções, carrinho, orçamento, finalização, despesa sugerida, sem duplicar | V + N | T: `shopping_flow_test`, fixtures de carrinho, invariantes 12 e 15 |
| Compras | Câmera, códigos de barras e etiquetas | F | Checklist físico C, D, E. Permissão negada: Em |
| Navegação | Menu lateral, barra inferior, botão "+", folhas, voltar | V + N | T: testes de fluxo; Em: etapa 3 e esta rodada |
| Formulários | Toque duplo em salvar | C | T: `regressions_flow_test` |
| Formulários | Dados digitados ao bloquear e desbloquear | C | T: `pin_lock_test` (S10) |
| Formulários | Tela estreita, texto ampliado, tema escuro | V | T: `tour_test` (320 pt a 150%), `home_redesign_test` (200%) |
| Segurança | Banco cifrado, chave, recuperação, PIN, backup, vazamentos | C / N | `docs/security/AUDITORIA_FLUTTER.md` |
| Segurança | Biometria com digital cadastrada | F | Checklist físico B09 a B12 |
| Resiliência | Fechamento inesperado, gravação interrompida, backup e importação inválidos, câmera negada, sem internet | N | T e Em (ver abaixo) |
| Resiliência | Armazenamento cheio | P | Não simulado |
| Externos | Notificação real e toque nela | V | Em: 05/11, antes desta rodada; rota inalterada, `reminders_host_test` |
| Externos | Compras e restauração na loja | E | Sem produtos nem chave do RevenueCat |
| Plataforma | iOS | P | Sem macOS |

### Defeitos desta rodada

| # | Gravidade | Defeito | Situação |
|---|---|---|---|
| S1 | P0 | "Apagar tudo" deixava o app sem conseguir abrir na vez seguinte | Corrigido e retestado (T e Em) |
| S2 | P1 | Chave ausente ou danificada gerava chave nova em silêncio | Corrigido e retestado (T e Em) |
| S3 | P1 | Falha ao abrir o banco era um beco sem saída | Corrigido e retestado (Em) |
| S4 | P1 | Bloqueio por biometria podia ser ligado sem o aparelho conseguir desbloquear | Corrigido; retestado em aparelho sem biometria (Em) |
| S11 | P1 | Pagar de novo, em parte, um lançamento quitado devolvia dinheiro ao saldo | Corrigido e retestado (T) |
| S5 a S10, S12 | P2 | Limite de PIN, PIN atual para trocar, PIN esquecido, arquivos no cache, captura de tela, formulário perdido ao bloquear, data inexistente | Corrigidos e retestados |
| D1 | P2 | Folha de "Esqueci o PIN" quebrava ao abrir (introduzido e pego nesta rodada, antes de chegar ao aparelho) | Corrigido (T) |

Nenhum P0 ou P1 conhecido permanece aberto.

### Resiliência

| Cenário | Resultado | Ambiente |
|---|---|---|
| App morto 3 s depois de iniciar a restauração de 50.000 lançamentos | Reabriu com os dados anteriores (10.000), sem erro | Em |
| Lote com uma linha inválida no meio | Nada gravado; integridade conferida | T (invariante 9) |
| Backup com senha errada, cortado, alterado, vazio, lixo | Recusado; banco inalterado | T |
| Arquivo do banco corrompido; chave ausente | Tela de recuperação; nada recriado em silêncio | T e Em |
| Onboarding interrompido e recomeçado | Não duplica conta, cartão nem contas fixas | T; Em (etapa 3) |
| Permissão de câmera negada | Explicação e entrada manual | Em |
| Reinício do emulador | App abre com os dados | Em |
| Atualização do APK debug (versão 1) para o de homologação (versão 2) | Instala por cima e mantém os dados | Em |
| Sem internet | O app não usa rede fora da tela de planos | Inspeção de código e do APK |

## Não coberto

Biometria (emulador sem biometria), leitura real de código de barras e OCR de etiqueta, compras em sandbox e restauração de compras, importação de CSV e OFX, TalkBack ligado, aparelho físico e iOS.
