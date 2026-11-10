# 09 — Testes

Suíte: `apps/serenacash_flutter/test` + fixtures TS→Dart em `docs/flutter-migration/fixtures`.

## Contagem real (execução de 10/11/2026, build 0.2.0+4)

| Resultado | Qtde |
|---|---|
| Aprovados | 637 |
| Ignorados (`skip`) | 0 |
| Com falha | 0 |
| **Total executado** | **637** |

Por camada: domínio 365, dados 58, app 206, desempenho 8. `dart format --set-exit-if-changed lib test integration_test tool` → 0 alterações em 213 arquivos; `flutter analyze --fatal-infos` → "No issues found!"; `flutter test` → `+637: All tests passed!`. O CI aprovou o commit `ee5c63d` (build 0.2.0+3) nos dois jobs, execução 42752550490. Os testes acrescentados no complemento estão em "Testes do complemento (build 0.2.0+4)", no fim deste arquivo.

## Contagem da build 0.2.0+3 (execução de 10/11/2026, commit `f1b3b47`)

| Resultado | Qtde |
|---|---|
| Aprovados | 566 |
| Ignorados (`skip`) | 0 |
| Com falha | 0 |
| **Total executado** | **566** |

Por camada: domínio 365, dados 54, app 139, desempenho 8. `dart format --set-exit-if-changed lib test integration_test tool` → 0 alterações em 197 arquivos; `flutter analyze --fatal-infos` → "No issues found!"; `flutter test` → `+566: All tests passed!`. Os testes novos desta rodada estão em "Testes da rodada de retorno da homologação física", no fim deste arquivo.

A tabela abaixo é a da execução anterior e fica como histórico.

## Contagem anterior (execução de 05/11/2026)

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

## Testes da rodada de retorno da homologação física (10/11/2026)

De 399 para 566 testes. Cada arquivo abaixo nasceu de ocorrências do registro `15-RETORNO_HOMOLOGACAO_FISICA.md`.

| Arquivo | Ocorrências | O que prova | Testes |
|---|---|---|---|
| `test/app/physical_return_test.dart` | 001–005, 011 | Folhas respeitam a barra do sistema (três botões, gestos, fonte grande, tela de 320 pt); troca de tipo mantém o que foi digitado; "Nova conta" dentro da transferência; calendário; confirmação do aparelho por estado (confirmada, cancelada, sem cadastro, sem hardware, bloqueada) | 15 |
| `test/app/planning_validity_test.dart` | 012 | Orçamento e meta só aparecem a partir de quando existem; alterar o limite não reescreve meses passados; encerrar não apaga o histórico | 10 |
| `test/app/shopping_review_test.dart` | 015–019, 021, 023, 025 | Revisão do item: cursor estável, conferência obrigatória em leitura duvidosa, atacado só com quantidade mínima, evidência gravada, estados da leitura de código | 9 |
| `test/app/loans_flex_test.dart` | 006, 007 | Americano, pagamento único, dívida "quando der" com pagamentos livres, recusa de pagamento acima do saldo, empréstimo concedido como ativo | 16 |
| `test/app/daily_control_test.dart` | 027, 029–031 | Controle diário, limite e meta com vigência, dias futuros só como previsto, cartões novos da tela inicial | 13 |
| `test/app/appearance_test.dart` | 009, 026, 032 | Seis paletas com contraste mínimo conferido por cálculo, densidade, restauração, textos sem os termos antigos | 8 |
| `test/domain/label_analysis_test.dart` | 015, 016 | As oito etiquetas fotografadas pelo usuário, com a saída real do OCR guardada em `test/fixtures/labels/` | 9 |
| `test/domain/receipt_test.dart` | 020 | Leitura do cupom e pareamento com o carrinho: igual, divergente, suspeita, sem par | 13 |
| `test/domain/assistant_intents_test.dart` | 010 | Perguntas do usuário, com erro de digitação, período e pedido de economia | 14 |
| `test/domain/shares_test.dart` | 008, 013 | Percentuais somam exatamente 100,0% (maiores restos) | 5 |
| `test/domain/voice_test.dart` | 022 | Frases ditadas viram nome, quantidade, unidade e preço; valor ambíguo é perguntado | 10 |
| `test/domain/price_timeline_test.dart` | 024 | Evolução do preço, comparando só a mesma unidade | 4 |
| `test/data/migration_test.dart` | — | Esquema 1 → 2 → 3 → 4 com dados, conferido contra os retratos de `drift_schemas/` | 4 |
| `test/data/backup_shopping_test.dart` | 019, 020 | Fotos de evidência e linhas de cupom vão e voltam no backup; foto adulterada é recusada | 6 |

Testes existentes ajustados de propósito, sem afrouxar a regra testada: `pin_lock_test.dart` (o bloqueio ligado na sessão vale a partir da próxima ida ao segundo plano), `reports_assistant_billing_test.dart` (duas respostas do assistente divergem da origem; ver D6 e D7 em `02`), `shopping_flow_test.dart`, `modules_flow_test.dart`, `app_flow_test.dart` e `home_redesign_test.dart` (telas que mudaram).

### O que os testes automatizados não cobrem nesta rodada

- Câmera real, foco, aquecimento e leitura de etiquetas e códigos em loja.
- Reconhecimento de voz: o serviço do aparelho é substituído por um dublê nos testes.
- Leitura de um cupom fiscal fotografado: o pareamento é testado com texto, não com a foto de um cupom.
- Biometria com a digital do usuário e o teclado do aparelho dele.
- `integration_test` não foi executado de novo nesta rodada; no aparelho virtual foram feitos o ensaio de atualização e os roteiros manuais descritos em `15`.

Ferramentas de desenvolvimento, fora da suíte: `integration_test/tools/ocr_dump_test.dart` roda o OCR do aparelho sobre fotos locais e `tool/ocr_fixtures.py` transforma a saída nas fixtures de etiqueta. As fotos não entram no repositório.

## Testes do complemento (build 0.2.0+4)

De 566 para 637 testes. Cada arquivo fecha uma parte que a build 0.2.0+3 tinha deixado parcial.

| Arquivo | Ocorrências | O que prova | Testes |
|---|---|---|---|
| `test/app/theme_editor_test.dart` | 032 | Dez cores difíceis (branco, preto, amarelo vivo, cinza médio…) viram paletas em que todo par de texto chega a 4,5:1, em claro e escuro; cor ilegível é recusada e corrigida mantendo o matiz; sinal financeiro não segue a paleta; preferências novas com padrão e ida e volta; teto do tamanho do texto; estilo de cartão, texto e movimento chegam a todas as telas; editor em 320 pt com texto a 1,6 × "maior" | 32 |
| `test/app/home_timeline_test.dart` | 027, 028, 009 | Projeção de mês futuro parte do previsto para a véspera; tamanho reduzido salvo com o layout; setas de mês não alteram o que está salvo; cartão de saldo nomeia passado, presente e futuro; toque em um dia mostra os fatos e abre os lançamentos; todos os 30 cartões em 320 pt com texto grande nos três estilos de cartão | 7 |
| `test/app/region_read_test.dart` | 017 | Recorte real sobre uma imagem (parte certa, ampliada, original intacto); ordem de leitura; valores com qualquer separador; marcar, mover e redimensionar; um valor, vários valores, nenhum; falhas ditas sem preencher nada | 7 |
| `test/app/daily_complete_test.dart` | 029–031 | Partes por categoria somam o todo; fluxo de uma conta; comparações entre períodos iguais com "sem registro"; limite por categoria e por dia da semana; simulação sem gravar; meta ligada a uma reserva; lembretes por tipo, sem duplicar, só com rotas conhecidas; aviso na tela inicial; tela inteira em 320 pt | 12 |
| `test/app/receipt_adjust_test.dart` | 020 | Valor, pago e saldo seguem o cupom; valor anterior anotado; pedido repetido não muda nada; parcelado, pago em parte, receita e valores inválidos são recusados; na tela, nada muda sem confirmação | 4 |
| `test/app/catalog_lookup_test.dart` | 018 | Leitura da resposta do catálogo (encontrado, não encontrado, malformado, campos de tipo errado, texto longo); só dígitos de código de produto são enviados; desligado por padrão não consulta; encontrado sugere, falha e ausência dizem coisas diferentes; código já cadastrado não é consultado de novo | 5 |
| `test/data/image_metadata_test.dart` | — | Posição, textos e dados do aparelho saem do JPEG; os dados da imagem ficam byte a byte iguais; orientação mantida nas duas ordens de bytes; arquivo que não é JPEG bem formado volta como veio | 4 |

Testes existentes ajustados de propósito: `shopping_review_test.dart` rola até os campos, porque a revisão ganhou o controle de marcar área sob a foto. Nenhuma regra testada foi afrouxada.

Validação no aparelho virtual `serenacash_teste` (Android 15, três botões), com o APK de release: atualização da 0.2.0+3 para a 0.2.0+4 por cima, com os dados preservados; tela inicial com setas de mês, toque em um dia do gráfico, lançamentos do dia e as duas visões; visão geral com marcas de cor; editor de tema recusando uma cor clara (contraste 1,1:1) e liberando depois do ajuste (4,7:1); estilo de cartão com sombra; tema próprio aplicado; controle diário com filtros e comparações. Sem erro no logcat. Capturas em `E:\SerenaCash\screens\etapa6\`.

Não exercitado no aparelho virtual nesta rodada: marcar área sobre uma foto real e reler, consulta ao catálogo com rede, cupom fotografado, lembretes chegando na hora. São itens do checklist físico (J45 a J64).
