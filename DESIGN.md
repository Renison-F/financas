---
name: Cabe
description: Finanças pessoais e compras que cabem no bolso — claro em segundos, completo por dentro.
colors:
  papel: "#F6F3EC"
  linho: "#FFFFFF"
  areia: "#EEEAE0"
  fio: "#DDD8CC"
  fio-forte: "#78857D"
  grafite: "#1B211E"
  cinza-verde: "#5B6962"
  verde-mata: "#0F5C45"
  verde-claro: "#D7EFE3"
  verde-profundo: "#0A3B2D"
  verde-sinal: "#176B4E"
  terracota: "#A3362A"
  terracota-claro: "#F7DDD6"
  ambar: "#8A5200"
  ambar-claro: "#F6E3BE"
  noite: "#0E1311"
  noite-superficie: "#171D1A"
  noite-superficie-2: "#202825"
  noite-fio: "#2C3531"
  noite-fio-forte: "#5E6B65"
  noite-tinta: "#ECEDE8"
  noite-cinza: "#A3ADA7"
  noite-verde: "#6FD3A8"
  noite-verde-container: "#134A38"
  noite-verde-sobre-container: "#C8F0DE"
  noite-terracota: "#F0907F"
  noite-terracota-container: "#4A1F18"
  noite-ambar: "#F2B86B"
  noite-ambar-container: "#4A3410"
typography:
  display:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif"
    fontSize: "40px"
    fontWeight: 600
    lineHeight: 1.05
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif"
    fontSize: "28px"
    fontWeight: 600
    lineHeight: 1.15
    letterSpacing: "-0.015em"
  title:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif"
    fontSize: "20px"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.01em"
  money-hero:
    fontFamily: "Bricolage Grotesque, system-ui, sans-serif"
    fontSize: "44px"
    fontWeight: 700
    lineHeight: 1
    letterSpacing: "-0.03em"
  body:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "0em"
  body-small:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "0em"
  label:
    fontFamily: "system-ui (SF Pro / Roboto)"
    fontSize: "13px"
    fontWeight: 500
    lineHeight: 1.3
    letterSpacing: "0.01em"
  money-row:
    fontFamily: "system-ui (SF Pro / Roboto), tabular-nums"
    fontSize: "17px"
    fontWeight: 600
    lineHeight: 1.3
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
    backgroundColor: "{colors.verde-mata}"
    textColor: "{colors.linho}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "14px 20px"
    height: "52px"
  button-primary-pressed:
    backgroundColor: "{colors.verde-profundo}"
  button-secondary:
    backgroundColor: "{colors.verde-claro}"
    textColor: "{colors.verde-profundo}"
    rounded: "{rounded.md}"
    height: "52px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.verde-mata}"
    height: "44px"
  button-destructive:
    backgroundColor: "{colors.terracota-claro}"
    textColor: "{colors.terracota}"
    rounded: "{rounded.md}"
    height: "52px"
  card:
    backgroundColor: "{colors.linho}"
    rounded: "{rounded.lg}"
    padding: "16px"
  card-inset:
    backgroundColor: "{colors.areia}"
    rounded: "{rounded.md}"
    padding: "12px"
  input:
    backgroundColor: "{colors.linho}"
    textColor: "{colors.grafite}"
    rounded: "{rounded.sm}"
    padding: "12px 14px"
    height: "52px"
  chip:
    backgroundColor: "{colors.areia}"
    textColor: "{colors.grafite}"
    rounded: "{rounded.pill}"
    padding: "8px 12px"
    height: "36px"
  chip-selected:
    backgroundColor: "{colors.verde-claro}"
    textColor: "{colors.verde-profundo}"
  tab-bar:
    backgroundColor: "{colors.linho}"
    height: "56px"
---

# Design System: Cabe

## Overview

**Creative North Star: "O encaixe"**

Cabe é a sensação de uma peça entrando no lugar certo: a compra que cabe no orçamento, a conta que cabe no mês, o número que cabe na cabeça. A interface é construída em torno de um único gesto visual, o **encaixe**: uma forma menor assentada com folga dentro de uma forma maior. Esse gesto aparece no símbolo da marca, no cartão do número-herói (o valor "cabe gastar" assentado em sua moldura), nas barras de orçamento (o gasto dentro do limite) e no carrinho do supermercado (o total dentro do teto da compra). Quando algo não cabe, a forma interna "transborda" a moldura e muda de cor; o usuário entende sem ler.

A personalidade é **calma, concreta e brasileira**: superfícies de papel quente em vez de branco clínico, um verde de mata fechada como única cor de ação, terracota para o que precisa de atenção, âmbar para o que vence. Densidade é moderada: a tela inicial respira, as listas são compactas e alinhadas em colunas tabulares, e a profundidade (relatórios, faturas, empréstimos) é revelada por toque, não despejada. Rejeições confirmadas: gradientes roxos, cartões empilhados dentro de cartões, emojis como ícones, "glassmorphism", sombras duras, mascotes.

**Key Characteristics:**
- Um número por tela decide a hierarquia; tudo o mais é apoio.
- Uma cor de ação (verde-mata); cores semânticas só carregam significado monetário.
- Papel quente claro / noite verde-escura: nunca branco puro nem preto puro como fundo.
- Tipografia de display com caráter (Bricolage Grotesque) para números e títulos; fonte do sistema para leitura e controles, respeitando Dynamic Type e escala de fonte.
- Ícones desenhados em um único traço de 1,75 px, cantos arredondados, nunca emoji.
- O "encaixe" como motivo: molduras e preenchimentos com folga de 4 px.

## Colors

Uma paleta de terra e mata: fundo de papel quente, tinta grafite esverdeada, um verde profundo de ação e dois tons de alerta terrosos.

### Primary
- **Verde-mata** (#0F5C45): única cor de ação. Botões primários, links, ícone ativo na barra de abas, barra de progresso "dentro do limite", foco de teclado. Contraste 7,2:1 sobre Papel. No tema escuro vira **Noite-verde** (#6FD3A8), 10,3:1 sobre Noite.
- **Verde-claro** (#D7EFE3): container do primário: chips selecionados, botão secundário, fundo do cartão "cabe gastar" quando positivo. Texto sobre ele sempre **Verde-profundo** (#0A3B2D), 10,4:1.

### Secondary
- **Terracota** (#A3362A): valores negativos, despesas no extrato, "não cabe", vencido, ação destrutiva. Nunca como decoração. Container **Terracota-claro** (#F7DDD6). Escuro: #F0907F / #4A1F18.
- **Âmbar** (#8A5200): vence em breve, atenção, estimativa com baixa confiança no OCR. Container **Âmbar-claro** (#F6E3BE). Escuro: #F2B86B / #4A3410.
- **Verde-sinal** (#176B4E): valores positivos (receitas, saldo positivo) em listas; distinto do Verde-mata por ser ligeiramente mais claro e reservado a números, não a controles. Escuro: compartilha #6FD3A8.

### Neutral
- **Papel** (#F6F3EC): fundo de tela (claro). **Noite** (#0E1311): fundo de tela (escuro).
- **Linho** (#FFFFFF) / **Noite-superfície** (#171D1A): cartões, folhas (sheets), barra de abas.
- **Areia** (#EEEAE0) / **Noite-superfície-2** (#202825): áreas internas (inset), chips, trilhos de barras de progresso.
- **Grafite** (#1B211E) / **Noite-tinta** (#ECEDE8): texto principal.
- **Cinza-verde** (#5B6962) / **Noite-cinza** (#A3ADA7): texto secundário, 5,2:1 e 8,1:1 sobre o fundo.
- **Fio** (#DDD8CC) / **Noite-fio** (#2C3531): divisores. **Fio-forte** (#78857D) / **Noite-fio-forte** (#5E6B65): contorno de campos de entrada (≥ 3:1).

### Named Rules
**A Regra da Única Voz.** Verde-mata é a única cor de controle. Terracota e Âmbar só aparecem quando carregam significado monetário (negativo, vencido, atenção); nunca em ilustração, fundo ou ornamento.
**A Regra do Sinal.** Um valor monetário em lista é Grafite por padrão; Verde-sinal apenas para entradas, Terracota apenas para saídas atrasadas ou saldo negativo. A cor marca exceção, não rotina.
**A Regra do Papel.** Nenhum fundo é #FFFFFF ou #000000; cartões são Linho sobre Papel, nunca Papel sobre Papel.

## Typography

**Display Font:** Bricolage Grotesque (pesos 600 e 700; fallback: fonte do sistema)
**Body Font:** fonte do sistema: SF Pro (iOS) / Roboto (Android), via Dynamic Type e escala de fonte
**Numerais:** `fontVariant: ['tabular-nums']` em todo valor monetário em lista ou tabela

**Character:** Bricolage Grotesque tem terminais levemente irregulares e um "g" de duas andares que dão calor e identidade sem perder legibilidade em números grandes; a fonte do sistema no corpo mantém o app nativo e acessível. O par é "voz própria nos títulos, voz da plataforma no texto".

### Hierarchy
- **Money Hero** (700, 44 px, 1.0, -0.03em): o número "cabe gastar" e o total do carrinho. Um por tela. Escala até 200% sem quebrar: o valor reduz para 36 px antes de quebrar linha.
- **Display** (600, 40 px, 1.05): títulos de onboarding e paywall.
- **Headline** (600, 28 px, 1.15): título de tela de topo (iOS large title / Android headline-medium).
- **Title** (600, 20 px, 1.25): títulos de seção e de cartão.
- **Body** (400, 17 px, 1.4): texto corrente; largura máxima 65–75 caracteres.
- **Body Small** (400, 15 px, 1.4): descrições em listas.
- **Label** (500, 13 px, 1.3, +0.01em, caixa normal): rótulos de campo, legendas de gráfico, texto de chips. Nunca em caixa alta com tracking largo.
- **Money Row** (600, 17 px, tabular): valores alinhados à direita em listas.

### Named Rules
**A Regra dos Centavos.** Centavos são sempre exibidos (R$ 1.234,56), nunca omitidos; em Money Hero os centavos têm 60% do tamanho e peso 500.
**A Regra do Título Sem Rótulo.** Nenhum "eyebrow"/kicker acima de títulos; o título carrega o próprio peso.

## Layout

Grade de 4 px; coluna única com gutter de 16 px nas laterais (20 px em telas ≥ 400 pt); conteúdo com largura máxima de 600 pt centralizado em tablets. Ritmo vertical: 8 px dentro de grupos, 16 px entre elementos relacionados, 24 px entre seções, 32 px acima de títulos de seção. Listas são densas (linhas de 56 px com ícone 36 px, título, descrição e valor à direita). A tela inicial é uma lista de widgets com 12 px entre eles; cada widget tem altura própria, nunca grade de cartões iguais. Barra de abas inferior com 5 destinos (Início, Lançamentos, Compras, Planejar, Mais) e um botão de ação principal flutuante apenas na aba Início e Lançamentos (Android: FAB; iOS: botão na barra de navegação). Safe areas e insets do teclado sempre aplicados; telas com um campo de valor abrem o teclado numérico com o valor já selecionado.

## Elevation & Depth

Profundidade tonal, não por sombra: cartões Linho sobre Papel, insets Areia dentro de Linho. Sombras aparecem apenas em elementos que flutuam de fato (folhas modais, FAB, menus) e sempre com deslocamento e desfoque suave.

### Shadow Vocabulary
- **Flutuante** (`0 6px 20px rgba(27,33,30,0.14)`): FAB, menus de contexto.
- **Folha** (`0 -4px 24px rgba(27,33,30,0.10)`): bottom sheets.

### Named Rules
**A Regra do Plano.** Superfícies em repouso são planas. Nada ganha sombra por "parecer cartão".

## Shapes

Cantos arredondados contínuos: 6 px em chips pequenos e barras, 10 px em campos, 14 px em botões, 20 px em cartões e folhas. O motivo do **encaixe** usa sempre uma folga de 4 px entre moldura e preenchimento (ex.: a barra de orçamento é um trilho Areia de 12 px com preenchimento de 8 px de altura). Bordas de 1 px apenas em campos de entrada e divisores; nunca "border-left" colorida. Ícones: traço 1,75 px, cantos e terminais arredondados, grade 24 px.

## Components

### Buttons
- **Shape:** 14 px de raio; altura 52 px (44 px na variante ghost); texto Label 500 em 16 px.
- **Primary:** Verde-mata com texto Linho; pressionado Verde-profundo com escala 0,98 em 120 ms.
- **Secondary:** Verde-claro com texto Verde-profundo.
- **Ghost:** transparente com texto Verde-mata; usado em "Ver tudo", "Explicar".
- **Destructive:** Terracota-claro com texto Terracota; confirmação em folha, nunca em alerta genérico.
- **Disabled:** opacidade 0,4; **Loading:** spinner substitui o texto mantendo a largura.

### Chips
- **Style:** Areia, texto Grafite, raio pill, 36 px de altura.
- **State:** selecionado Verde-claro/Verde-profundo com ícone de check; filtros são chips, ações nunca.

### Cards / Containers
- **Corner Style:** 20 px.
- **Background:** Linho (claro) / Noite-superfície (escuro).
- **Shadow Strategy:** nenhuma (Regra do Plano).
- **Border:** nenhuma; separação pela diferença tonal com o Papel.
- **Internal Padding:** 16 px; cabeçalho com Title à esquerda e ação ghost à direita.

### Inputs / Fields
- **Style:** Linho com contorno 1 px Fio-forte, raio 10 px, altura 52 px; rótulo Label acima, ajuda Body Small abaixo.
- **Focus:** contorno 2 px Verde-mata, sem brilho.
- **Error:** contorno Terracota e mensagem que nomeia o problema e a correção ("Informe um valor maior que zero").
- **Money input:** teclado numérico, máscara pt-BR em tempo real, centavos sempre visíveis, prefixo "R$" em Cinza-verde.

### Navigation
- **Tab bar:** Linho, 56 px + safe area, 5 itens com ícone 24 px e rótulo 11 px; ativo Verde-mata com ícone preenchido; inativo Cinza-verde.
- **Headers:** iOS large title colapsável; Android top app bar Material 3. Botão voltar sempre do sistema.
- **Sheets:** bottom sheet para tarefas curtas (novo lançamento, confirmar item do carrinho); tela cheia para fluxos longos (sessão de compras com câmera).

### Encaixe (componente-assinatura)
Moldura Areia com raio 14 px e preenchimento interno com folga de 4 px. O preenchimento cresce proporcionalmente ao valor; ao ultrapassar 100% ele é desenhado "transbordando" 4 px além da moldura em Terracota-claro, com o excedente escrito ao lado ("R$ 40 acima"). Usado em: "cabe gastar", orçamento por categoria, orçamento do carrinho, limite do cartão, progresso de meta.

### Valor monetário (componente)
`<Money>` renderiza inteiro em centavos com `tabular-nums`, sinal explícito para negativos, cor pela Regra do Sinal, modo privacidade (R$ ••••) e rótulo de acessibilidade por extenso.

## Do's and Don'ts

### Do:
- **Do** colocar um único número-herói por tela, em Money Hero, com uma linha de explicação e um botão ghost "Como calculamos".
- **Do** usar Papel (#F6F3EC) como fundo e Linho (#FFFFFF) só em cartões e folhas.
- **Do** desenhar ícones em traço 1,75 px com cantos arredondados, sempre da mesma biblioteca interna.
- **Do** mostrar estados vazio, carregando e erro em todo widget, com uma ação útil no vazio.
- **Do** respeitar Reduce Motion: transições viram crossfade de 150 ms.
- **Do** usar o motivo do encaixe para qualquer "valor dentro de limite".

### Don't:
- **Don't** usar gradientes em texto ou fundos, roxo, "glass", sombras duras ou cartões dentro de cartões.
- **Don't** usar emoji como ícone ou como decoração de categoria.
- **Don't** escrever rótulos em caixa alta com tracking largo nem kickers acima de títulos.
- **Don't** apresentar "cabe gastar" sem a decomposição acessível, nem chamá-lo de saldo.
- **Don't** usar vermelho/terracota para qualquer coisa que não seja valor negativo, atraso ou destruição.
- **Don't** omitir centavos ou alinhar valores à esquerda em listas.
