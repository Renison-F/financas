# Development build e testes em aparelho físico

Data: 2026-11-04. **Status real:** nenhum build foi gerado nesta sessão. O EAS Build foi configurado e validado até onde o ambiente permite; a geração está bloqueada por credencial e por rede (detalhes e erros exatos na seção 3).

## 1. O que foi feito e validado nesta sessão

| Item | Resultado |
|---|---|
| `eas.json` (perfis development/preview/production, submit) | revisado; `appVersionSource: remote`, `autoIncrement` em produção |
| `app.json` | nome **SerenaCash**, slug `serenacash`, scheme `serenacash`, bundle/package `br.com.serenacash.mobile`, `newArchEnabled`, `runtimeVersion: appVersion`, permissões e textos de câmera/Face ID; removido `edgeToEdgeEnabled` (obsoleto no SDK 58) |
| `npx expo config --type public` | lê o app.json sem erro |
| `npx expo-doctor` | **18/20 checks aprovados**; os 2 que falharam exigem acesso a `exp.host`/React Native Directory (bloqueado pela rede desta sessão), não são problemas do projeto |
| `npx expo prebuild --no-install --clean --platform all` (offline) | **sucesso**: gerou `android/` e `ios/` com `applicationId 'br.com.serenacash.mobile'`, `PRODUCT_BUNDLE_IDENTIFIER = "br.com.serenacash.mobile"`, `NSCameraUsageDescription`, permissões CAMERA e USE_BIOMETRIC. Prova de que os config plugins (camera, sqlite, secure-store, local-authentication, notifications, splash, fonts) funcionam. Os diretórios nativos são gerados sob demanda (CNG) e não são versionados |
| Workflow `.github/workflows/eas-build.yml` | criado: dispara builds no EAS a partir do GitHub com o segredo `EXPO_TOKEN` |

## 2. Builds

| Plataforma | Status | Link | ID |
|---|---|---|---|
| Android (development, .apk) | **não gerado** (bloqueado) | — | — |
| iOS (development) | **não gerado** (bloqueado) | — | — |

## 3. Bloqueios, erros exatos e próximos comandos

### 3.1 Conta Expo (credencial)
Erro exato de `eas build --profile development --platform android --non-interactive --no-wait`:
```
An Expo user account is required to proceed.
Either log in with eas login or set the EXPO_TOKEN environment variable if you're using EAS CLI on CI (Learn more: https://docs.expo.dev/accounts/programmatic-access/)
    Error: build command failed.
```
`eas whoami` → `Not logged in`. Não existe `EXPO_TOKEN` no ambiente.

**Causa:** o EAS exige uma conta Expo; não há token configurado e o login interativo não é possível nesta sessão.

**Próximo passo (você):** crie um token em https://expo.dev/settings/access-tokens e guarde-o como segredo do ambiente de nuvem (variável `EXPO_TOKEN`) ou como segredo do repositório no GitHub (para o workflow). Não cole o token no chat.

### 3.2 Rede da sessão
`api.expo.dev` e `expo.dev` respondem `CONNECT tunnel failed, response 403` pelo proxy desta sessão; `expo-doctor` relata `getaddrinfo ENOTFOUND exp.host`. Mesmo com token, o `eas build` falharia aqui.

**Próximo passo (você):** nas configurações do ambiente de nuvem (menu do ambiente na barra de título → Edit → Network access), liberar os domínios `api.expo.dev`, `expo.dev`, `exp.host`, `storage.googleapis.com` (upload do projeto) e `reactnative.directory`, ou usar um nível de acesso mais amplo. Depois, em nova sessão, os comandos da seção 4 funcionam.

### 3.3 iOS (Apple Developer)
Build iOS para aparelho físico exige conta Apple Developer paga, dispositivo registrado (`eas device:create`) e credenciais de assinatura geradas pelo EAS. Sem isso, o build iOS falha na etapa de credenciais mesmo com token Expo. Alternativa sem conta paga: build de **simulador** (`"ios": { "simulator": true }` no perfil) para Mac com Xcode.

### 3.4 Identificadores
`br.com.serenacash.mobile` é proposta; só pode ser considerado definitivo após registrar o domínio e criar o App ID no Apple Developer / o app no Play Console. Mudar depois exige novo build.

## 4. Como gerar os builds (passo a passo)

### Opção A — pela sua máquina
```bash
git clone <repo> && cd financas && pnpm install
npm install -g eas-cli
eas login
cd apps/mobile
eas init                                   # cria o projectId e grava em app.json (extra.eas.projectId)
eas build --profile development --platform android      # gera .apk; ao final mostra link e QR code
eas build --profile development --platform ios          # pede Apple ID; registre o iPhone quando solicitado
```
Para registrar iPhones antes do build iOS: `eas device:create` (gera um link/QR para abrir no aparelho).

### Opção B — pelo GitHub (sem máquina local)
1. Adicione o segredo `EXPO_TOKEN` em Settings → Secrets and variables → Actions.
2. Rode o workflow **EAS development build** (Actions → Run workflow), escolhendo `android` e `development`.
3. Abra o link do build impresso no log do job ou em https://expo.dev → projeto → Builds.

### Opção C — nesta sessão de nuvem, depois de liberar rede e token
```bash
cd apps/mobile && npx eas-cli@latest init --non-interactive --force
npx eas-cli@latest build --profile development --platform android --non-interactive --no-wait
npx eas-cli@latest build:list --platform android --limit 1     # mostra status, ID e link
```

## 5. Instalar e rodar no aparelho

**Android**
1. No link do build (ou no QR code mostrado pelo `eas build`), toque em *Install* e baixe o `.apk`.
2. Permita "instalar apps de fontes desconhecidas" para o navegador, instale e abra o SerenaCash.
3. No computador, na mesma rede Wi-Fi: `cd apps/mobile && npx expo start --dev-client`. No app, escaneie o QR code do terminal (ou digite a URL `exp+serenacash://...`). O JavaScript é carregado pelo servidor de desenvolvimento; recarregue com dois toques no "r" do terminal.
4. Para testar sem computador: `eas build --profile preview --platform android` gera um .apk autocontido.

**iOS**
1. Registre o iPhone (`eas device:create`), gere o build e, no link do build, instale o perfil/app pelo Safari (distribuição interna ad hoc). Em Ajustes → Geral → VPN e Gerenciamento de Dispositivo, confie no perfil.
2. `npx expo start --dev-client` e escaneie o QR code com a Câmera do iPhone.

**Expo Go (atalho sem build):** `npx expo start` e abrir no Expo Go cobre tudo exceto OCR de etiquetas e compras reais (o app cai para entrada manual e paywall sem botões).

## 6. Checklist de validação em aparelho físico

Marque P (passou), F (falhou, abrir issue com print) ou N/A. Teste em 1 Android (≥ 8.0) e 1 iPhone (≥ iOS 15). Repita o essencial com fonte do sistema em 200% e com VoiceOver/TalkBack ligado.

**Onboarding**
- [ ] Abrir o app pela primeira vez mostra a tela "Seu dinheiro em paz" sem pedir e-mail ou permissões.
- [ ] Passo 1: criar conta com saldo R$ 2.500,00 (teclado numérico, máscara pt-BR).
- [ ] Passo 2: marcar "Aluguel" R$ 1.500,00 → vira conta prevista recorrente.
- [ ] Passo 3: cartão com limite R$ 5.000, fechamento 20, vencimento 27. Botão "Não uso cartão" pula.
- [ ] Tela inicial mostra "Pode gastar até dd/mm: R$ 1.000,00". Fechar e reabrir o app mantém tudo (SQLite).

**Criação de conta**
- [ ] Mais → Contas → Nova: nome, tipo, saldo, "considerar no pode gastar". Aparece no saldo consolidado.
- [ ] Ajustar saldo cria um "Ajuste de saldo" com a diferença. Arquivar remove das listas; excluir conta com lançamentos é bloqueado com mensagem.
- [ ] Plano grátis: 4ª conta leva ao paywall.

**Receita e despesa**
- [ ] "+" → Despesa R$ 45,90 "Padaria", categoria Alimentação → aparece em Lançamentos e reduz o saldo.
- [ ] Receita prevista R$ 5.000 "Salário" para daqui a 10 dias → não altera saldo; "pode gastar" não muda (modo prudente); no modo otimista (Como calculamos → toggle) entra.
- [ ] Despesa prevista com "Marcar como pago" e com pagamento parcial (R$ 4,00 de R$ 10,00) → status "parcial".
- [ ] Repetir mensal: cria os próximos 3 meses como previstos; "Excluir este e os próximos" + "Desfazer" na faixa de 10 s.
- [ ] Transferência entre duas contas não altera o total consolidado.

**Cartão e fatura**
- [ ] Compra no cartão R$ 900 em 3x no dia 25 → parcelas 300/300/300 nas faturas de dez, jan, fev (fechamento 20).
- [ ] Detalhe do cartão: fatura aberta, fecha/vence corretos, limite livre = limite − comprometido.
- [ ] Pagar fatura (total e mínimo 15%) debita a conta e não cria despesa; "Despesas" do mês não dobra.
- [ ] Tentar mudar o dia de fechamento com compras existentes é bloqueado com explicação.

**Dashboard com widgets**
- [ ] Engrenagem → modelos (Essencial, Só o mais importante, Completo, Supermercado) mudam a lista.
- [ ] Ocultar e mostrar widgets; mover com as setas; **segurar e arrastar** o ícone de seis pontos reordena (gesto).
- [ ] Período "Próximos 30 dias" e "Contas consideradas" alteram os números; Salvar persiste após reabrir o app.
- [ ] Ícone do olho oculta valores (R$ ••••) em todas as telas; estado persiste.
- [ ] Cada widget vazio mostra uma ação útil; tocar no widget abre a tela correspondente.

**Lista de compras**
- [ ] Compras → Criar lista "Compra da semana", loja, orçamento R$ 300.
- [ ] Adicionar "Arroz 5kg" 1 un com preço estimado, "Banana" 1,5 kg sem preço → estimativa soma só o item com preço e informa "1 sem preço".
- [ ] Marcar itens, editar quantidade/unidade, duplicar lista, excluir.
- [ ] Modo avião ligado: criar lista e itens continua funcionando.

**Câmera para EAN/QR**
- [ ] Iniciar compra → "Código": primeira vez pede permissão com o texto do SerenaCash; negar mostra tela com "Abrir configurações" e "Informar manualmente".
- [ ] Ler um EAN-13 de produto real → abre a folha de confirmação com o código; produto novo pede nome e preço (nunca inventa preço).
- [ ] Ler o mesmo código de novo → nome e último preço preenchidos (histórico).
- [ ] Ler código de balança (começa com 2) → aviso de que o valor embutido pode ser peso ou preço.
- [ ] Ler o QR de um cupom NFC-e → sessão registra a chave (mensagem no resumo). QR genérico → "não é um cupom fiscal".
- [ ] Lanterna liga/desliga; fechar a câmera volta para a sessão sem perder o carrinho.

**OCR de etiquetas** (somente development/production build)
- [ ] "Etiqueta" → enquadrar etiqueta de gôndola → "Ler" → folha com nome, preço, unidade e **confiança**; preço "de/por" usa o "por" e mostra o anterior.
- [ ] Etiqueta por kg (ex.: banana R$ 6,99 kg) → unidade kg e quantidade em kg; subtotal com arredondamento de balança.
- [ ] Etiqueta com parcelamento ("10x de…") não usa a parcela como preço.
- [ ] Foto ruim/sem preço → aviso "Nenhum preço reconhecido; informe manualmente"; nada entra no carrinho sem confirmar.
- [ ] Plano grátis: 31ª leitura no mês leva ao paywall.
- [ ] Em Expo Go: mensagem "Leitura de texto indisponível" e entrada manual (comportamento esperado).

**Carrinho e finalização**
- [ ] Total corrente e "ainda cabe R$ X de R$ 300" atualizam a cada item; ao passar de 90% muda para atenção e acima de 100% para agitado.
- [ ] Promoção "leve 3 pague 2" e "10% off" alteram o subtotal corretamente.
- [ ] Finalizar → resumo planejado × realizado → "Registrar como despesa" cria **um** lançamento em Supermercado; voltar à sessão não oferece registrar de novo.

**Paywall**
- [ ] Mais → SerenaCash Plus mostra comparação e os 3 planos com preço da loja (exige produtos criados e chaves RevenueCat); sem configuração mostra "Preço e compra disponíveis na versão publicada".
- [ ] Bloqueios suaves (2º cartão, OFX, PDF, 4ª conta) abrem o paywall indicando o recurso.
- [ ] Comprar em sandbox (TestFlight / teste interno) libera os recursos imediatamente e após reabrir o app.

**Restauração de compra**
- [ ] Apagar tudo (Privacidade) ou reinstalar → paywall → "Restaurar compras" recupera o plano com a mesma conta da loja.
- [ ] Sem compras: mensagem "Nenhuma compra encontrada nesta conta da loja".
- [ ] Cancelar assinatura em sandbox: acesso mantido até a data de expiração; depois cai para grátis.

**Biometria**
- [ ] Configurações → "Pedir biometria ao abrir" → fechar e reabrir pede Face ID/digital; cancelar mostra tela "Bloqueado" com "Desbloquear".
- [ ] Ir para segundo plano e voltar bloqueia de novo. Aparelho sem biometria: toggle explica e usa senha do aparelho.

**Notificações**
- [ ] Configurações → "Ativar lembretes" pede permissão do sistema.
- [ ] Criar conta prevista para amanhã → notificação local às 9:00 do dia anterior (hoje, se ainda não passou) e no dia; tocar abre o lançamento.
- [ ] Negar permissão: app segue sem erro; mensagem explica.

**Modo claro e escuro**
- [ ] Configurações → Automático segue o sistema ao trocar o tema do aparelho; Claro/Escuro fixam.
- [ ] No escuro: fundo #0C1517, cartões #152022, ação ciano, nenhum texto cinza ilegível; splash e ícone adaptativo corretos.
- [ ] Barra de status e navegação do sistema combinam com o tema.

**Acessibilidade e robustez (transversal)**
- [ ] Fonte 200%: valores "pode gastar" e totais não são cortados; botões continuam tocáveis.
- [ ] VoiceOver/TalkBack: valores lidos por extenso ("mil duzentos e trinta e quatro reais e cinquenta e seis centavos"); toggles, abas e barras de progresso anunciam estado.
- [ ] Voltar do sistema (gesto iOS / botão Android) funciona em todas as telas empilhadas.
- [ ] Matar o app no meio de um lançamento e reabrir não corrompe dados (SQLite WAL).
