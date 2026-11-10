# CHECKPOINT — migração Flutter

> **Leia primeiro a seção abaixo.** A segunda rodada foi entregue em 10/11/2026: as 32 ocorrências do teste físico foram tratadas e há uma build nova (0.2.0+3) esperando o reteste no celular do usuário. Nada desta rodada está aprovado em aparelho físico.

## BUILD 0.2.0+3 ENTREGUE — AGUARDANDO RETESTE FÍSICO DO USUÁRIO

Registrado em 10/11/2026. O usuário concluiu a homologação física da build 0.1.0+2 e trouxe 32 ocorrências (pacote `docs/SerenaCash_Fable_5_2_Pacote_Com_Referencias/`, fora do controle de versão). O registro, a causa, a correção e o estado de cada uma estão em `15-RETORNO_HOMOLOGACAO_FISICA.md`; o roteiro de reteste é a seção J de `14-CHECKLIST_APARELHO.md` (44 testes, todos "PENDENTE NO DISPOSITIVO DO USUÁRIO").

### Build para reteste

| | |
|---|---|
| Arquivo | `E:\SerenaCash\homologacao-0.2.0\serenacash-0.2.0+3-homologacao-f1b3b47.apk` |
| Versão / build | 0.2.0 / 3 (`pubspec.yaml`: `0.2.0+3`); o menu do app mostra "versão 0.2.0 (build 3)" |
| Commit do código | `f1b3b47ff558eb490488258fe9fb553c18b706ae` (`f1b3b47`), branch `refactor/flutter-serenacash` |
| Application ID | `br.com.serenacash.mobile` |
| Variante | release (R8, não depurável), assinada com a chave de debug deste PC |
| Tamanho | 132.755.640 bytes |
| SHA-256 do APK | `d0de4b2c34976863d6c42ab84048225d3d7ec7f82d744d0d6dd80243b84a18c8` |
| SHA-256 do certificado | `e7c911bbedaec660d221b1e37d98cafe1e3d83116d8fd5d90aa0c1fd6eee16e5` (o mesmo da 0.1.0+2) |

Na mesma pasta: o APK debug do mesmo commit (`serenacash-0.2.0+3-debug-f1b3b47.apk`, SHA-256 `5cca23ea6f06d9bc7c9d5ef6eb1d1120f99e7d78b5653613a58015fa944bdf65`), `LEIA-ME.md` e `CHECKLIST-APARELHO.md`. Não há link de download: os arquivos existem só neste computador.

A build anterior continua intacta em `E:\SerenaCash\homologacao\` e deve ficar assim até a nova ser validada no celular.

### Estado em 10/11/2026

- Git: 17 commits depois de `54c6c99`, de `dadb36d` a `f1b3b47`, mais o commit de documentação que contém este texto. Todos **locais**: `origin/refactor/flutter-serenacash` está em `54c6c99`. Enviar ao GitHub é pedido à parte; o envio dispara o CI. `main` não foi tocada.
- Testes: 566 aprovados, 0 falhas, 0 ignorados (domínio 365, dados 54, app 139, desempenho 8); `dart format` sem alterações; `flutter analyze --fatal-infos` sem avisos. Detalhe em `09-TESTES.md`.
- Banco: esquema na versão 4 (era 1). Migrações testadas a partir de cada retrato, com dados, e ensaiadas no aparelho virtual instalando a 0.2.0+3 por cima da 0.1.0+2: os dados foram preservados. Detalhe em `05-MIGRACAO_DADOS.md`.
- Segurança: diferencial da rodada na seção 7 de `docs/security/AUDITORIA_FLUTTER.md`. 185 pacotes do pub.dev sem vulnerabilidade conhecida na OSV em 10/11/2026.
- Aparelho virtual de validação: `serenacash_teste` (Android 15, três botões, uma digital cadastrada, bloqueio de tela fictício). Tem a build final instalada, com dados fictícios do ensaio de atualização. O emulador de homologação `serenacash_api35` **não foi ligado nem alterado** nesta rodada e segue com a 0.1.0+2 e os dados de antes.
- Fora do repositório, em `E:\SerenaCash\`: `relatorio-etapa5.md` (relatório e parecer), `homologacao-0.2.0\`, `etapa5\` (logs de build) e `screens\etapa5\` (capturas).

### Estado das 32 ocorrências

Nenhuma está "aprovada no aparelho": isso só o reteste do usuário decide.

- **Corrigidas ou implementadas, com teste automatizado e validação no aparelho virtual quando possível:** 001–008, 010–016, 018–026, 029–031.
- **Parciais, com o que falta descrito em `15`:** 009, 028 e 032 (aparência: há paletas, densidade e restauração; não há editor livre de cores, estilos de cartão, tipografia nem redesenho completo da tela inicial), 017 (ajuste da leitura por toque nas linhas lidas; sem recorte livre nem reprocessamento), 027 (cartões novos; sem redimensionar e sem linha do tempo navegável).
- **Só o aparelho físico decide:** câmera, foco e aquecimento em vinte leituras (014), etiquetas reais em loja (015, 016), código de barras real (018), cupom fotografado (020), teclado Samsung (021), voz (022), biometria com a digital do usuário (011), barra de três botões do aparelho dele (001).

### Como retomar

1. Ler esta seção, `15-RETORNO_HOMOLOGACAO_FISICA.md` e a seção J de `14-CHECKLIST_APARELHO.md`.
2. Perguntar ao usuário o resultado do J01 (atualização por cima) antes de qualquer outra coisa: se falhar, é P0.
3. Registrar cada retorno com o ID da ocorrência (sub-IDs permitidos, como 016-B), nas palavras dele, antes de investigar.
4. Reproduzir no aparelho virtual `serenacash_teste` com a build `f1b3b47`, achar a causa, escrever o teste que falha e só então corrigir.
5. Uma correção por commit, na branch `refactor/flutter-serenacash`. Sem merge na `main`, sem force push. Envio ao GitHub é pedido à parte.
6. Build seguinte: subir o número do build (`0.2.0+4`), nomear o arquivo com versão, build e commit, registrar o SHA-256 e conferir que instala por cima da 0.2.0+3.

Regras que continuam valendo: só dados fictícios; não apagar dados do emulador nem do aparelho (`pm clear`, desinstalar, limpar banco) sem autorização específica; não usar a chave definitiva da loja; não registrar credenciais; não declarar resultado sem tê-lo obtido; não publicar nas lojas; não introduzir IA paga, Firebase ou PostgreSQL sem autorização.

### Decisões que dependem do usuário

- **Juros da dívida informal:** adotado mês de 30 dias, proporcional aos dias, juros antes do principal. Confirmar ou trocar.
- **Cupom e despesa:** o cupom não altera a despesa já registrada. Oferecer "atualizar a despesa para o valor do cupom"?
- **Aparência:** até onde ir (editor livre de cores, estilos de cartão, tipografia) depois de ver as seis paletas no aparelho.
- **Pacote de referências:** `docs/SerenaCash_Fable_5_2_Pacote_Com_Referencias/` tem capturas de aplicativos de terceiros e as fotos do usuário. Não foi incluído em commit; o repositório é público. Decidir se fica fora do Git (recomendado) ou vai para um lugar privado.

### Pendências administrativas

- **Privatizar o repositório:** `Renison-F/financas` continua público. Não foi feito por falta de credencial administrativa neste ambiente (não há `gh` instalado nem token; nenhum foi pedido). Passo a passo, para o dono da conta:
  1. Abrir `https://github.com/Renison-F/financas/settings`.
  2. No fim da página, em "Danger Zone", "Change repository visibility" → "Change to private" e confirmar com o nome do repositório.
  3. Antes de confirmar, olhar em Settings → Integrations e em Settings → Pages se há algo que dependa de o repositório ser público; não remover nada às cegas.
  Efeitos: estrelas e observadores são removidos; forks públicos se desligam; os minutos do GitHub Actions passam a contar na cota da conta; a consulta do CI pela API pública deixa de funcionar sem credencial (o resultado passa a ser conferido pelo site).
- **READMEs:** atualizados nesta rodada (raiz e `apps/serenacash_flutter`).
- **Mostrar build dentro do app:** feito (rodapé do menu). O commit não aparece no app; está no nome do arquivo.
- As demais pendências estão em "Pendências reais", no fim deste arquivo.

### Rodada anterior (05/11/2026), para referência

Build 0.1.0+2, commit `bae5d9f`, `E:\SerenaCash\homologacao\serenacash-0.1.0+2-homologacao-bae5d9f.apk`, SHA-256 `63c3ac06120f9cda29e43a0117e84acbe99cccfa2bcf1836b425cfb705726912`, mesmo certificado. Foi a build que o usuário testou no celular. 399 testes na época. CI aprovado em `bae5d9f` (execução 42035033218).

## Contexto da migração

- Origem congelada: `ae2c229c4977dcc6f78a19e7e4388cacced9d61b` (React Native/Expo, testes 100+18+11 verdes).
- Branch: `refactor/flutter-serenacash`. Sem merge na main. Histórico preservado.
- Ambiente atual: Windows, descrito em `13-SETUP_WINDOWS.md` (Flutter 3.47.9, Android SDK e emulador `serenacash_api35`). A migração começou em um ambiente de nuvem sem Android SDK; os bloqueios citados nas seções M8–M10 abaixo são daquela fase. iOS: sem macOS.
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
- Reteste físico da build 0.2.0+3: seção J de `14-CHECKLIST_APARELHO.md`. Câmera, OCR em loja, código de barras, cupom, voz, biometria e teclado do aparelho do usuário não têm resultado.
- Itens parciais da rodada: 009, 017, 027, 028 e 032 (ver `15`). Limite diário por categoria e por dia da semana existe só no domínio, sem tela.
- Cupom fiscal: lido por foto e OCR. Não há consulta à NFC-e pela chave de acesso nem atualização da despesa pelo cupom.
- Catálogo de produtos: só o cadastro local do usuário; nenhum catálogo externo.
- iOS: sem macOS neste ambiente; nada desta rodada foi compilado ou testado em iOS (as descrições de uso de câmera, microfone e voz foram acrescentadas ao `Info.plist`).
- TalkBack ligado não foi testado; os nós de acessibilidade foram conferidos pela árvore do sistema (uiautomator).
- Final do cartão ("Final 4582" no mockup): o app não guarda esse dado; exigiria um campo novo e uma migração do banco.
- Fora do escopo, por exigirem evolução própria: Open Finance, sincronização em nuvem, perfis, assistente de IA generativa, edição em lote, lançamento em várias categorias, antecipar e reabrir fatura.
- Segurança não executada: MobSF e análise dinâmica, ferramentas dedicadas, root e instrumentação (ver `AUDITORIA_FLUTTER.md`, seções 5 e 7).
- Lojas/RevenueCat, assinatura de release e política de privacidade publicada dependem do cliente. A política precisa citar câmera, microfone e fotos de evidência guardadas no aparelho.
- Lembretes usam alarmes inexatos (podem atrasar até 1 h); alarmes exatos exigem permissão sujeita à política da loja.
- CI não rodou sobre os commits desta rodada (não enviados).

## Próximos passos
1. Usuário: exportar backup, instalar a 0.2.0+3 por cima e executar a seção J do checklist.
2. Tratar o retorno do reteste, uma ocorrência por commit.
3. Decidir os itens de "Decisões que dependem do usuário".
4. Configurar lojas/RevenueCat (ação do cliente) e assinar release.
5. Após paridade validada em aparelho, decidir remoção do código RN.
