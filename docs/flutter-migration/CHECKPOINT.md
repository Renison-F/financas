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

## Homologação no emulador e correções (04–05/11/2026)
- Ambiente Windows preparado (`13-SETUP_WINDOWS.md`); APK debug e release compilam localmente; emulador `serenacash_api35` (Android 15).
- Homologação percorrida no emulador com dados fictícios: `10-HOMOLOGACAO.md`. Os 11 achados foram corrigidos (release/R8, receptores e toque das notificações, PIN, desfazer, calendário, backup com Compras, segredos ocultos, confirmação ao finalizar compra, textos, ícone e abertura com a marca no Android).
- Notificação real exibida e toque validado com o app aberto, em segundo plano e encerrado.
- Lembretes reagendam sozinhos quando o livro muda (paridade com o RN).
- `integration_test` passou no emulador; a ferramenta é instável ali (conexão adb), repetir com limite de tempo.

## Redesenho da tela inicial (05/11/2026)
- Cabeçalho compacto (saudação, período como controle, ocultar valores, alternar tema), painel-resumo "pode gastar" em azul-petróleo com "Dinheiro nas contas" e "Compromissos", ações rápidas, "Contas a pagar" com total e vencimentos em palavras, "Cartões e faturas", "Últimos lançamentos", estados vazios de uma linha e primeiro acesso sem valor inventado. Detalhes em `04-UI_DESIGN_SYSTEM.md` e `DESIGN.md`.
- Personalização da tela inicial (ordem, visibilidade, modelos, período, contas) preservada; nenhuma regra financeira alterada.
- Gates: `dart format` 0 alterações, `flutter analyze --fatal-infos` 0 issues, `flutter test` 349 aprovados, 0 ignorados, 0 falhas (`09-TESTES.md`).

## Identidade em todo o app, categorias e navegação (05/11/2026)
- Tela inicial refeita na identidade do mockup de referência (escala compacta, painel "Pode gastar neste mês" com "Saldo em contas" e "Compromissos do mês", ações Lançamento / Conta a pagar / Contas, linhas densas com ícone da categoria, botão "+" circular). Nome opcional na saudação (Configurações > Perfil).
- A mesma identidade foi levada ao tema e aos componentes compartilhados (tipografia, cartão, linha de lista, botões, campos, chips, diálogos, folhas, avisos), e com isso a todas as telas. `DESIGN.md` e `04-UI_DESIGN_SYSTEM.md` atualizados.
- Categorias e subcategorias: regras no domínio (`lib/domain/categories/`), biblioteca de ícones com busca, paleta sem roxo, criar/editar/arquivar/reativar, excluir com reclassificação, seletor no lançamento com criação na hora, filtro por categoria nos lançamentos, detalhe por subcategoria no relatório. Sem mudança de esquema do banco.
- Navegação: barra inferior com os quatro destinos frequentes e a entrada do menu lateral; a tela "Mais" deixou de existir. O botão "+" abre a folha "Adicionar".
- Contas a receber na tela "A pagar e a receber".
- Achados da validação no emulador corrigidos: onboarding duplicava a conta quando interrompido e o voltar saía do app; botões únicos (ícone, cor, chip, linha) perdiam o nó de acessibilidade.
- Gates: `dart format` 0 alterações, `flutter analyze --fatal-infos` 0 issues, `flutter test` 359 aprovados, 0 ignorados, 0 falhas.
- Nenhuma regra financeira foi alterada. A ordem padrão do domínio para a tela inicial continua igual à fixture; quem nunca personalizou recebe a ordem do mockup (definida na camada de app).

## Homologação avançada e endurecimento de segurança (05/11/2026)
- Defeitos corrigidos: "Apagar tudo" deixava o app sem abrir (P0); chave do banco regenerada em silêncio, falha de abertura sem saída, bloqueio por biometria sem aparelho capaz, pagamento repetido que devolvia dinheiro (P1); limite de tentativas de PIN, PIN atual para trocar, PIN esquecido, arquivos exportados no cache, captura de tela com bloqueio, formulário perdido ao bloquear, data inexistente, toque duplo em salvar (P2).
- Banco e chave passaram a ser tratados juntos (`lib/data/security/local_vault.dart`); a tela de inicialização explica a falha e oferece recuperação.
- Testes: 399 aprovados (domínio 288, dados 48, app 55, desempenho 8), com 15 invariantes financeiras novas.
- Evidência no emulador em instalação isolada: banco e WAL cifrados sem texto em claro, chave embrulhada pelo Keystore, recuperação por chave ausente e por arquivo corrompido, PIN com pausa persistente, captura preta com bloqueio, restauração interrompida sem dano.
- Desempenho medido de 100 a 50.000 lançamentos (`10-PERFORMANCE.md`).
- Documentos: `docs/security/AUDITORIA_FLUTTER.md` (reescrito), matriz em `10-HOMOLOGACAO.md`, `14-CHECKLIST_APARELHO.md` (novo), variantes de APK em `11-BUILD_CI.md`.
- Build 0.1.0+2. APKs de debug e de homologação em `E:\SerenaCash\homologacao\`.

## Pendências reais
- iOS: sem macOS neste ambiente; ícone e abertura com a marca só foram feitos no Android.
- TalkBack ligado não foi testado; os nós de acessibilidade foram conferidos pela árvore do sistema (uiautomator).
- Final do cartão ("Final 4582" no mockup): o app não guarda esse dado; exigiria um campo novo e uma migração do banco.
- Fora do escopo, por exigirem evolução própria: Open Finance, sincronização em nuvem, perfis, assistente de IA, edição em lote, lançamento em várias categorias, antecipar e reabrir fatura.
- Aparelho físico: câmera/OCR, biometria e compras em sandbox continuam sem validação.
- Lojas/RevenueCat, assinatura de release e política de privacidade publicada dependem do cliente.
- Lembretes usam alarmes inexatos (podem atrasar até 1 h); alarmes exatos exigem permissão sujeita à política da loja.

## Próximos passos
1. Validar em aparelho físico os itens de `10-HOMOLOGACAO.md` em "Não coberto".
2. Configurar lojas/RevenueCat (ação do cliente) e assinar release.
3. Após paridade validada em aparelho, decidir remoção do código RN.
