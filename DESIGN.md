---
name: SerenaCash
description: Finanças pessoais e compras sem ansiedade — claro em segundos, completo por dentro.
colors:
  nevoa: "#F3F6F5"
  branco: "#FFFFFF"
  bruma: "#E6ECEA"
  fio: "#D3DCDA"
  fio-forte: "#74848A"
  grafite: "#162022"
  cinza-mar: "#4F5E61"
  sereno: "#0B5563"
  sereno-claro: "#D4ECEF"
  sereno-profundo: "#083E48"
  aurora: "#C0703E"
  verde-sinal: "#176B4E"
  coral: "#A93A29"
  coral-claro: "#F7DDD6"
  ambar: "#8A5200"
  ambar-claro: "#F6E3BE"
  noite: "#0C1517"
  noite-superficie: "#152022"
  noite-superficie-2: "#1E2B2E"
  noite-fio: "#263437"
  noite-fio-forte: "#71818A"
  noite-tinta: "#E8EEEC"
  noite-cinza: "#A3B1B3"
  noite-sereno: "#6FC8D6"
  noite-sereno-container: "#123F48"
  noite-sereno-sobre-container: "#C8ECF2"
  noite-aurora: "#F0B48A"
  noite-verde: "#6FD3A8"
  noite-coral: "#F0907F"
  noite-coral-container: "#4A1F18"
  noite-ambar: "#F2B86B"
  noite-ambar-container: "#4A3410"
typography:
  display:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif"
    fontSize: "30px"
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.015em"
  title:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "-0.005em"
  money-hero:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif"
    fontSize: "36px"
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: "-0.03em"
  hero-value:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif, tabular-nums"
    fontSize: "30px"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.02em"
  section-value:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif, tabular-nums"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.015em"
  body:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "0em"
  body-small:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "13px"
    fontWeight: 400
    lineHeight: 1.35
    letterSpacing: "0em"
  row-title:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "0em"
  row-meta:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "12px"
    fontWeight: 400
    lineHeight: 1.3
    letterSpacing: "0em"
  label:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "12px"
    fontWeight: 500
    lineHeight: 1.3
    letterSpacing: "0.01em"
  money-row:
    fontFamily: "system-ui (SF Pro / Roboto), tabular-nums"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "0em"
  button:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "0em"
rounded:
  xs: "6px"
  sm: "10px"
  md: "14px"
  lg: "20px"
  pill: "999px"
spacing:
  xxs: "4px"
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  xxl: "48px"
components:
  button-primary:
    backgroundColor: "{colors.sereno}"
    textColor: "{colors.branco}"
    typography: "{typography.button}"
    rounded: "{rounded.sm}"
    padding: "12px 18px"
    height: "48px"
  button-primary-pressed:
    backgroundColor: "{colors.sereno-profundo}"
  button-secondary:
    backgroundColor: "{colors.sereno-claro}"
    textColor: "{colors.sereno-profundo}"
    rounded: "{rounded.sm}"
    height: "48px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.sereno}"
    height: "44px"
  button-destructive:
    backgroundColor: "{colors.coral-claro}"
    textColor: "{colors.coral}"
    rounded: "{rounded.sm}"
    height: "48px"
  card:
    backgroundColor: "{colors.branco}"
    rounded: "{rounded.md}"
    padding: "12px 14px"
  card-inset:
    backgroundColor: "{colors.bruma}"
    rounded: "{rounded.sm}"
    padding: "12px"
  input:
    backgroundColor: "{colors.branco}"
    textColor: "{colors.grafite}"
    rounded: "{rounded.sm}"
    padding: "12px 12px"
    height: "48px"
  chip:
    backgroundColor: "{colors.bruma}"
    textColor: "{colors.grafite}"
    rounded: "{rounded.pill}"
    padding: "8px 12px"
    height: "36px"
  chip-selected:
    backgroundColor: "{colors.sereno-claro}"
    textColor: "{colors.sereno-profundo}"
  tab-bar:
    backgroundColor: "{colors.branco}"
    height: "64px"
---

# Design System: SerenaCash

## Overview

**Creative North Star: "Água parada ao amanhecer"**

SerenaCash é a sensação de olhar para um lago sem vento: tudo visível, nada se mexendo sem motivo. A interface traduz isso em **calma visual e verdade imediata**: um único número grande por tela, superfícies claras como névoa, uma cor profunda de água (o "sereno") para toda ação, e um toque de luz de amanhecer (o "aurora") reservado ao símbolo e a um único marcador por tela. O motivo gráfico da marca é a **linha d'água**: uma onda suave e baixa que aparece no símbolo (a moeda-lua refletida na água) e, na interface, como a **marca de hoje** nas barras de ritmo, uma pequena linha com uma ondulação que mostra onde o gasto deveria estar neste ponto do mês. Quando o preenchimento ultrapassa a marca, a água "agita" (muda para coral) e o estado do mês muda de "sereno" para "atenção" ou "agitado".

A personalidade é **serena, concreta e brasileira**: nada de alarmes vermelhos piscando, nada de confete; o app informa e sugere, com espaço em branco generoso na tela inicial e listas compactas e tabulares onde a densidade ajuda. A profundidade (relatórios, faturas, empréstimos) é revelada por toque. Rejeições confirmadas: gradientes roxos, cartões empilhados dentro de cartões, emojis como ícones, "glassmorphism", sombras duras, mascotes, azul "de banco" genérico, linguagem de alarme.

**Key Characteristics:**
- Um número por tela decide a hierarquia; tudo o mais é apoio.
- Uma cor de ação (sereno); aurora só no símbolo e no marcador; cores semânticas só com significado monetário.
- Névoa clara / noite verde-azulada: nunca branco puro nem preto puro como fundo; **temas claro, escuro e automático (segue o sistema)**.
- Bricolage Grotesque para números e títulos; fonte do sistema para leitura e controles, respeitando Dynamic Type.
- Ícones em traço único de 1,75 px, nunca emoji.
- A linha d'água como motivo: "marca de hoje" nas barras de ritmo e a onda do símbolo.

## Colors

Uma paleta de água e névoa ao amanhecer: fundo frio e claro, tinta grafite esverdeada, um azul-petróleo profundo de ação e um laranja suave de luz baixa.

### Primary
- **Sereno** (#0B5563): única cor de ação. Botões primários, links, ícone ativo na barra de abas, preenchimento "dentro do ritmo", foco de teclado. 7,7:1 sobre Névoa. No tema escuro vira **Noite-sereno** (#6FC8D6), 9,6:1 sobre Noite.
- **Sereno-claro** (#D4ECEF): container do primário: chips selecionados, botão secundário, fundo dos ícones das ações rápidas e da aba ativa. Texto sobre ele sempre **Sereno-profundo** (#083E48), 9,5:1.

### Secondary
- **Aurora** (#C0703E / escuro #F0B48A): a luz baixa do amanhecer. Só no símbolo, na marca de hoje e em ícones de destaque ≥ 24 px; nunca como texto (3,4:1 sobre Névoa é suficiente apenas para elementos gráficos).
- **Coral** (#A93A29): valores negativos, "agitado", vencido, ação destrutiva. Container **Coral-claro** (#F7DDD6). Escuro: #F0907F / #4A1F18.
- **Âmbar** (#8A5200): vence em breve, "atenção", baixa confiança no OCR. Container **Âmbar-claro** (#F6E3BE). Escuro: #F2B86B / #4A3410.
- **Verde-sinal** (#176B4E / escuro #6FD3A8): valores positivos (receitas, saldo positivo, "sereno"). Reservado a números e estados, nunca a controles.

### Neutral
- **Névoa** (#F3F6F5) / **Noite** (#0C1517): fundo de tela.
- **Branco** (#FFFFFF) / **Noite-superfície** (#152022): cartões, folhas, barra de abas.
- **Bruma** (#E6ECEA) / **Noite-superfície-2** (#1E2B2E): insets, chips, trilhos de barras.
- **Grafite** (#162022) / **Noite-tinta** (#E8EEEC): texto principal.
- **Cinza-mar** (#4F5E61) / **Noite-cinza** (#A3B1B3): texto secundário (6,2:1 / 8,4:1).
- **Fio** (#D3DCDA) / **Noite-fio** (#263437): divisores. **Fio-forte** (#74848A) / **Noite-fio-forte** (#71818A): contorno de campos (≥ 3:1).

### Cores de aplicativo escolhidas pelo usuário
Desde a build 0.2.0+3 o usuário pode trocar o Sereno por outra cor de ação: azul, verde, terracota, grafite ou vinho (`lib/app/theme/palettes.dart`). A troca alcança a cor de ação, os contêineres dela, o acento e o painel-resumo. Coral, Âmbar, Verde-sinal, texto e superfícies são os mesmos em todas. Cada par de cada paleta cumpre o contraste mínimo, em claro e em escuro, conferido por teste. A Regra da Única Voz continua valendo: uma cor de controle por vez.

Desde a build 0.2.0+4 há também o **editor de tema**: o usuário escolhe a cor principal e a cor de destaque. Uma cor que não chega a 4,5:1 sobre Névoa é recusada, com o contraste medido e a oferta do tom legível mais próximo; os demais tons são derivados e sempre legíveis. O usuário também escolhe o estilo dos cartões (plano, contorno, sombra, cor), gráficos detalhados ou compactos, o tamanho do texto e o movimento reduzido. A Regra da Névoa admite, por escolha do usuário, cartões com contorno, sombra suave ou um toque da cor principal; o padrão continua sendo o cartão plano.

### Named Rules
**A Regra da Única Voz.** Sereno é a única cor de controle. Coral e Âmbar só aparecem com significado monetário; Aurora só no símbolo e na marca de hoje.
**A Regra do Sinal.** Um valor em lista é Grafite por padrão; Verde-sinal apenas para entradas, Coral apenas para saídas atrasadas ou saldo negativo. A cor marca exceção, não rotina.
**A Regra da Névoa.** Nenhum fundo é #FFFFFF ou #000000; cartões são Branco sobre Névoa, nunca Névoa sobre Névoa.
**A Regra da Calma.** Nenhum elemento pisca, pulsa ou treme para chamar atenção. Atenção é comunicada por cor semântica + ícone + texto, parados.

## Typography

**Display Font:** Bricolage Grotesque (pesos 600 e 700; fallback: fonte do sistema)
**Body Font:** fonte do sistema: SF Pro (iOS) / Roboto (Android), via Dynamic Type e escala de fonte
**Numerais:** `fontVariant: ['tabular-nums']` em todo valor monetário em lista ou tabela

**Character:** Bricolage Grotesque tem terminais levemente irregulares e um "g" de dois andares que dão calor e identidade sem perder legibilidade em números grandes; a fonte do sistema no corpo mantém o app nativo e acessível.

### Hierarchy
Uma escala compacta para o app inteiro, definida pela tela inicial: títulos na fonte de exibição, linhas e valores na fonte do sistema.
- **Money Hero** (700, 36 px, 1.05): total do carrinho e valores de destaque em telas de detalhe.
- **Hero Value** (700, 30 px, 1.15, tabular): "pode gastar" no painel-resumo; centavos no mesmo tamanho.
- **Display** (700, 30 px, 1.1): onboarding e paywall.
- **Headline** (700, 22 px, 1.2): título de tela de aba; 20 px na saudação da tela inicial; 18 px em telas empilhadas, folhas e diálogos.
- **Title** (700, 16 px, 1.25): seções e cartões.
- **Section Value** (700, 20 px, tabular): total logo abaixo do título de uma seção.
- **Body** (400, 15 px, 1.4): texto corrente e campos; 65–75 caracteres por linha.
- **Body Small** (400, 13 px, 1.35): textos de apoio.
- **Row Title** (600, 14 px) e **Row Meta** (400, 12 px): título e linha de apoio em listas.
- **Label** (500, 12 px, 1.3, caixa normal): rótulos de campo, legendas, cabeçalhos de grupo. Nunca caixa alta com tracking largo.
- **Money Row** (600, 14 px, tabular): valores à direita em listas.
- **Link** (600, 13 px) e **Button** (600, 15 px): "Ver todas" e rótulos de botão.

### Named Rules
**A Regra dos Centavos.** Centavos sempre exibidos; em Money Hero com 60% do tamanho e peso 500.
**A Regra do Sinal Separado.** Em listas de lançamentos o sinal vem separado do valor ("- R$ 186,40", "+ R$ 8.200,00"); receita em Verde, gasto rotineiro na cor do texto.
**A Regra do Título Sem Rótulo.** Nenhum kicker acima de títulos.

## Layout

Grade de 4 px; coluna única com margem lateral de 12 px para cartões e listas (o texto do cabeçalho entra mais 4 px); largura máxima 600 pt em tablets. Ritmo vertical: 12 px entre cartões, 6 px entre o título de uma seção e o conteúdo, 8 px dentro de grupos. Listas densas (48 px por linha, com fio de 1 px Bruma entre linhas de um mesmo cartão). A tela inicial é uma lista de seções com 12 px entre elas. Barra inferior com os quatro destinos frequentes (Início, Lançamentos, Compras, Planejar) e a entrada do menu lateral; botão "+" circular flutuante nas abas Início e Lançamentos. Safe areas e insets do teclado sempre aplicados.

## Elevation & Depth

Profundidade tonal: cartões Branco sobre Névoa, insets Bruma dentro de Branco. Sombras apenas no que flutua (folhas, FAB, menus), com deslocamento e desfoque suave.

### Shadow Vocabulary
- **Flutuante** (`0 6px 20px rgba(22,32,34,0.14)`): FAB, menus.
- **Folha** (`0 -4px 24px rgba(22,32,34,0.10)`): bottom sheets.

### Named Rules
**A Regra do Plano.** Superfícies em repouso são planas.

## Shapes

Cantos arredondados contínuos: 6 px em etiquetas e barras, 8 px no quadro de ícone, 10 px em campos e botões, 14 px em cartões e no painel-resumo, 20 px em folhas, diálogos e no menu lateral. A **marca de hoje** é uma linha vertical de 2 px com uma pequena onda de 10×4 px no topo, em Aurora, desenhada sobre trilhos de 12 px. Bordas de 1 px apenas em campos e divisores; nunca "border-left" colorida. Ícones: traço 1,75 px, terminais arredondados, grade 24 px.

## Components

### Buttons
- **Shape:** 10 px de raio; altura 48 px (44 px ghost e compacto); texto Button 600 em 15 px (13 px no compacto).
- **Primary:** Sereno com texto Branco; pressionado Sereno-profundo com escala 0,98 em 120 ms.
- **Secondary:** Sereno-claro com texto Sereno-profundo.
- **Ghost:** transparente com texto Sereno ("Ver tudo", "Explicar").
- **Destructive:** Coral-claro com texto Coral; confirmação em folha.
- **Disabled:** opacidade 0,4; **Loading:** spinner substitui o texto mantendo a largura.

### Chips
- **Style:** Bruma, texto Grafite em 13 px, raio pill, 36 px. Vários filtros ficam em uma linha que rola para o lado, sem empurrar a lista.
- **State:** selecionado Sereno-claro/Sereno-profundo com check; filtros são chips, ações nunca.

### Cards / Containers
- **Corner Style:** 14 px. **Background:** Branco / Noite-superfície. **Shadow:** nenhuma. **Border:** nenhuma. **Padding:** 14 px nas laterais e 12 px em cima e embaixo; cabeçalho com Title à esquerda e, à direita, uma ação ghost ou um link ("Ver todas"). Quando o cartão leva a uma tela própria, o cartão inteiro é o alvo de toque e o link é só o sinal visível.

### Inputs / Fields
- **Style:** Branco com contorno 1 px Fio-forte, raio 10 px, altura 48 px; rótulo Label acima.
- **Focus:** contorno 2 px Sereno. **Error:** contorno Coral e mensagem que nomeia problema e correção.
- **Money input:** teclado numérico, máscara pt-BR, centavos sempre visíveis, prefixo "R$" em Cinza-mar.

### Navigation
- **Barra inferior:** Branco, 64 px + safe area, 5 itens, ícone 22 px e rótulo 11 px (10 px abaixo de 360 pt); a aba ativa ganha uma pílula Sereno-claro atrás do ícone, com ícone e rótulo em Sereno. O quinto item, "Menu", abre o menu lateral e nunca fica selecionado.
- **Menu lateral:** gaveta à esquerda (até 320 pt, cantos de 20 px à direita, fundo Névoa) com a marca, o plano e os destinos em grupos com rótulo Label: Principal, Movimentações, Planejamento, Cadastros, Análises, Dados e Aplicativo. Linhas de 44 px com ícone de 20 px; a seção atual fica em pílula Sereno-claro. Só entram destinos que existem. Abre pelo item "Menu" e pelo gesto na borda; fecha antes de abrir o destino.
- **Botão "+":** círculo Sereno de 52 px. Abre a folha "Adicionar" com os tipos de inclusão, cada um com nome e explicação (despesa, receita, transferência, compra no cartão, conta a pagar, conta a receber). Navegar e criar nunca se misturam.
- **Headers:** iOS large title colapsável; Android top app bar Material 3. Voltar sempre do sistema.
- **Sheets:** bottom sheet para tarefas curtas; tela cheia para fluxos longos (sessão de compras com câmera).

### Painel-resumo "pode gastar" (tela inicial)
Superfície sólida em **Sereno** (#0B5563; no escuro **Noite-sereno-container** #123F48), raio 14 px, texto Branco e texto de apoio tingido da própria cor (#CDE6EA), nunca cinza. Ordem: rótulo "Pode gastar neste mês" (ou "Pode gastar até dd/mm" quando o horizonte não é o fim do mês), valor em Hero Value, uma linha de explicação ("Após os compromissos previstos", ou o aviso de aperto), um fio e dois valores que explicam o número (**Saldo em contas** e **Compromissos do mês**), tirados das mesmas linhas da tela "Como calculamos". O painel inteiro é tocável e abre essa tela. Quando o valor é negativo o painel vira Coral-claro com texto Coral. Sem conta cadastrada o valor é desconhecido: o painel mostra "Configure seu saldo", uma frase e o botão "Adicionar conta", nunca R$ 0,00. Valores longos e fonte grande reduzem a escala em vez de cortar; em tela estreita ou fonte acima de 140% os dois valores empilham.

### Ações rápidas (tela inicial)
Três atalhos logo abaixo do painel: ícone de 20 px em círculo Sereno-claro de 40 px e rótulo de 12 px em até duas linhas: "Lançamento" (abre a folha "Adicionar"), "Conta a pagar" e "Contas".

### Linha de lista
48 px no mínimo: quadro de ícone de 32 px (raio 8 px, Sereno-claro com ícone Sereno, ou a cor da categoria a 14%), Row Title, Row Meta ou etiqueta embaixo, valor em Money Row à direita. O valor reduz a escala antes de empurrar o título.

### Categoria
Cada categoria tem cor e ícone próprios, escolhidos em uma paleta de 13 cores (sem roxo) e em uma biblioteca de ícones com busca por palavras ("mercado", "saúde"). A marca da categoria é o ícone na cor dela sobre um quadro da mesma cor a 14%; arquivada, fica em Cinza-mar sobre Bruma. Subcategoria aparece recuada sob a principal e, fora da árvore, como "Principal › Subcategoria". O seletor é uma folha com busca, criação pelo nome digitado e "+" para subcategoria.

### Linha vazia
Seção sem dados na tela inicial é uma linha só: ícone em quadro Bruma de 32 px, o que falta ("Nenhuma conta prevista", "Adicione seu primeiro cartão") e uma ação ghost à direita. Evita empilhar cartões altos de instrução no primeiro acesso.

### Vencimento
Em listas de contas a pagar, "Atrasada desde dd/mm" (Coral sobre Coral-claro) e "Vence hoje"/"Vence amanhã" (Âmbar sobre Âmbar-claro) aparecem como etiqueta de raio 6 px; os demais vencimentos são texto Cinza-mar ("Vence em 3 dias", "Vence dd/mm"). Cor e texto sempre juntos.

### Barra de ritmo (componente-assinatura)
Trilho Bruma de 12 px com raio 6 px; preenchimento Sereno (Coral ao ultrapassar 100%); **marca de hoje** em Aurora na posição esperada (dias decorridos ÷ dias do período, ou itens comprados ÷ itens da lista no carrinho). Legenda de três estados, sempre com ícone e texto: **sereno** (preenchimento ≤ marca), **atenção** (até 10% acima), **agitado** (acima disso). Usado em: orçamento por categoria, orçamento do mês, limite do cartão, meta/reserva, orçamento do carrinho.

### Valor monetário (componente)
`<Money>` renderiza centavos inteiros com `tabular-nums`, sinal explícito, cor pela Regra do Sinal, modo privacidade (R$ ••••) e rótulo de acessibilidade por extenso.

## Do's and Don'ts

### Do:
- **Do** colocar um único número-herói por tela, em Money Hero, com uma linha de explicação e o acesso a "Como calculamos". Na tela inicial ele vive no painel-resumo em Sereno.
- **Do** usar Névoa (#F3F6F5) como fundo e Branco (#FFFFFF) só em cartões e folhas; oferecer claro, escuro e automático.
- **Do** desenhar ícones em traço 1,75 px com cantos arredondados, da biblioteca interna.
- **Do** mostrar estados vazio, carregando e erro em todo widget, com uma ação útil no vazio.
- **Do** respeitar Reduce Motion: transições viram crossfade de 150 ms.
- **Do** usar a barra de ritmo para qualquer "valor dentro de limite ao longo do tempo".

### Don't:
- **Don't** usar gradientes, roxo, "glass", sombras duras ou cartões dentro de cartões.
- **Don't** usar emoji como ícone ou decoração.
- **Don't** escrever rótulos em caixa alta com tracking largo nem kickers.
- **Don't** apresentar "pode gastar" sem a decomposição acessível, nem chamá-lo de saldo.
- **Don't** usar coral para qualquer coisa que não seja valor negativo, atraso ou destruição; nem aurora em texto.
- **Don't** omitir centavos, alinhar valores à esquerda em listas, nem animar para "chamar atenção".
