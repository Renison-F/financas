---
name: Prumo
description: Finanças pessoais e compras no prumo — claro em segundos, completo por dentro.
colors:
  papel: "#F6F3EC"
  linho: "#FFFFFF"
  areia: "#EEEAE0"
  fio: "#DDD8CC"
  fio-forte: "#78857D"
  grafite: "#1B1F24"
  cinza-ardosia: "#5B6670"
  indigo: "#24477A"
  indigo-claro: "#D9E4F4"
  indigo-profundo: "#14294A"
  latao: "#B07A1E"
  verde-sinal: "#176B4E"
  terracota: "#A3362A"
  terracota-claro: "#F7DDD6"
  ambar: "#8A5200"
  ambar-claro: "#F6E3BE"
  noite: "#0F1419"
  noite-superficie: "#181E26"
  noite-superficie-2: "#222A34"
  noite-fio: "#2A323C"
  noite-fio-forte: "#6C7784"
  noite-tinta: "#ECEDE8"
  noite-cinza: "#A6ADB6"
  noite-indigo: "#8FB4F0"
  noite-indigo-container: "#1C3356"
  noite-indigo-sobre-container: "#CFE0FA"
  noite-latao: "#E3B35A"
  noite-verde: "#6FD3A8"
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
    backgroundColor: "{colors.indigo}"
    textColor: "{colors.linho}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "14px 20px"
    height: "52px"
  button-primary-pressed:
    backgroundColor: "{colors.indigo-profundo}"
  button-secondary:
    backgroundColor: "{colors.indigo-claro}"
    textColor: "{colors.indigo-profundo}"
    rounded: "{rounded.md}"
    height: "52px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.indigo}"
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
    backgroundColor: "{colors.indigo-claro}"
    textColor: "{colors.indigo-profundo}"
  tab-bar:
    backgroundColor: "{colors.linho}"
    height: "56px"
---

# Design System: Prumo

## Overview

**Creative North Star: "O fio de prumo"**

O fio de prumo é a ferramenta mais simples e mais honesta do construtor: um cordão e um peso que mostram, sem discussão, se a parede está no prumo. Prumo traz essa honestidade para o dinheiro. A interface é organizada em torno de um único gesto visual, o **marcador de prumo**: uma linha vertical fina terminada por um pequeno peso, que marca "onde você deveria estar hoje" em qualquer barra de orçamento, limite ou meta. Se o preenchimento passa do marcador, você está gastando mais rápido do que o mês permite; se fica atrás, está no prumo. O usuário leigo entende a leitura em um olhar, sem conhecer a palavra "ritmo de gastos".

A personalidade é **firme, calma e artesanal**: superfícies de papel quente, tinta índigo profunda (a cor de uma linha de giz azul sobre a madeira) como única cor de ação, latão (o peso do prumo) reservado ao símbolo e a poucos destaques, terracota para o que precisa de atenção, âmbar para o que vence. Densidade moderada: a tela inicial respira, as listas são compactas e tabulares, a profundidade é revelada por toque. Rejeições confirmadas: gradientes roxos, cartões empilhados dentro de cartões, emojis como ícones, "glassmorphism", sombras duras, mascotes, azul "de banco" claro e genérico.

**Key Characteristics:**
- Um número por tela decide a hierarquia; tudo o mais é apoio.
- Uma cor de ação (índigo); latão só no símbolo e em marcadores; cores semânticas só carregam significado monetário.
- Papel quente claro / noite azul-escura: nunca branco puro nem preto puro como fundo.
- Bricolage Grotesque para números e títulos; fonte do sistema para leitura e controles, respeitando Dynamic Type.
- Ícones desenhados em traço único de 1,75 px, nunca emoji.
- O marcador de prumo como motivo: "onde deveria estar hoje" em barras de orçamento, limite, meta e carrinho.

## Colors

Uma paleta de oficina: papel, índigo de giz, latão do peso e dois tons de alerta terrosos.

### Primary
- **Índigo** (#24477A): única cor de ação. Botões primários, links, ícone ativo na barra de abas, preenchimento "dentro do limite", foco de teclado. 8,4:1 sobre Papel. No tema escuro vira **Noite-índigo** (#8FB4F0), 8,8:1 sobre Noite.
- **Índigo-claro** (#D9E4F4): container do primário: chips selecionados, botão secundário, fundo do cartão "pode gastar" quando positivo. Texto sobre ele sempre **Índigo-profundo** (#14294A), 11,3:1.

### Secondary
- **Latão** (#B07A1E / escuro #E3B35A): o peso do prumo. Só no símbolo, no marcador de prumo e em ícones de destaque de 24 px; nunca como texto pequeno (3,1:1 sobre índigo é suficiente apenas para elementos gráficos ≥ 3 px).
- **Terracota** (#A3362A): valores negativos, "fora do prumo", vencido, ação destrutiva. Container **Terracota-claro** (#F7DDD6). Escuro: #F0907F / #4A1F18.
- **Âmbar** (#8A5200): vence em breve, atenção, estimativa com baixa confiança no OCR. Container **Âmbar-claro** (#F6E3BE). Escuro: #F2B86B / #4A3410.
- **Verde-sinal** (#176B4E / escuro #6FD3A8): valores positivos (receitas, saldo positivo, "no prumo"). Reservado a números e estados, nunca a controles.

### Neutral
- **Papel** (#F6F3EC) / **Noite** (#0F1419): fundo de tela.
- **Linho** (#FFFFFF) / **Noite-superfície** (#181E26): cartões, folhas, barra de abas.
- **Areia** (#EEEAE0) / **Noite-superfície-2** (#222A34): insets, chips, trilhos de barras.
- **Grafite** (#1B1F24) / **Noite-tinta** (#ECEDE8): texto principal.
- **Cinza-ardósia** (#5B6670) / **Noite-cinza** (#A6ADB6): texto secundário.
- **Fio** (#DDD8CC) / **Noite-fio** (#2A323C): divisores. **Fio-forte** (#78857D) / **Noite-fio-forte** (#6C7784): contorno de campos (≥ 3:1).

### Named Rules
**A Regra da Única Voz.** Índigo é a única cor de controle. Terracota e Âmbar só aparecem quando carregam significado monetário; Latão só no símbolo e no marcador.
**A Regra do Sinal.** Um valor monetário em lista é Grafite por padrão; Verde-sinal apenas para entradas, Terracota apenas para saídas atrasadas ou saldo negativo. A cor marca exceção, não rotina.
**A Regra do Papel.** Nenhum fundo é #FFFFFF ou #000000; cartões são Linho sobre Papel, nunca Papel sobre Papel.

## Typography

**Display Font:** Bricolage Grotesque (pesos 600 e 700; fallback: fonte do sistema)
**Body Font:** fonte do sistema: SF Pro (iOS) / Roboto (Android), via Dynamic Type e escala de fonte
**Numerais:** `fontVariant: ['tabular-nums']` em todo valor monetário em lista ou tabela

**Character:** Bricolage Grotesque tem terminais levemente irregulares e um "g" de dois andares que dão calor e identidade sem perder legibilidade em números grandes; a fonte do sistema no corpo mantém o app nativo e acessível.

### Hierarchy
- **Money Hero** (700, 44 px, 1.0, -0.03em): o número "pode gastar" e o total do carrinho. Um por tela. Reduz para 36 px antes de quebrar linha em escala de fonte 200%.
- **Display** (600, 40 px, 1.05): títulos de onboarding e paywall.
- **Headline** (600, 28 px, 1.15): título de tela de topo.
- **Title** (600, 20 px, 1.25): títulos de seção e de cartão.
- **Body** (400, 17 px, 1.4): texto corrente; 65–75 caracteres por linha.
- **Body Small** (400, 15 px, 1.4): descrições em listas.
- **Label** (500, 13 px, 1.3, +0.01em, caixa normal): rótulos, legendas, chips. Nunca caixa alta com tracking largo.
- **Money Row** (600, 17 px, tabular): valores alinhados à direita em listas.

### Named Rules
**A Regra dos Centavos.** Centavos sempre exibidos; em Money Hero têm 60% do tamanho e peso 500.
**A Regra do Título Sem Rótulo.** Nenhum kicker acima de títulos.

## Layout

Grade de 4 px; coluna única com gutter de 16 px (20 px em telas ≥ 400 pt); largura máxima 600 pt em tablets. Ritmo vertical: 8 px dentro de grupos, 16 px entre elementos relacionados, 24 px entre seções, 32 px acima de títulos de seção. Listas densas (linhas de 56 px). A tela inicial é uma lista de widgets com 12 px entre eles, cada um com altura própria. Barra de abas inferior com 5 destinos (Início, Lançamentos, Compras, Planejar, Mais); botão de ação principal flutuante nas abas Início e Lançamentos. Safe areas e insets do teclado sempre aplicados.

## Elevation & Depth

Profundidade tonal: cartões Linho sobre Papel, insets Areia dentro de Linho. Sombras apenas no que flutua (folhas, FAB, menus), com deslocamento e desfoque suave.

### Shadow Vocabulary
- **Flutuante** (`0 6px 20px rgba(27,31,36,0.14)`): FAB, menus.
- **Folha** (`0 -4px 24px rgba(27,31,36,0.10)`): bottom sheets.

### Named Rules
**A Regra do Plano.** Superfícies em repouso são planas.

## Shapes

Cantos arredondados contínuos: 6 px em chips pequenos e barras, 10 px em campos, 14 px em botões, 20 px em cartões e folhas. O **marcador de prumo** é uma linha vertical de 2 px com um peso de 8×10 px (pentágono apontando para baixo) em Latão, desenhado sobre trilhos de 12 px. Bordas de 1 px apenas em campos e divisores; nunca "border-left" colorida. Ícones: traço 1,75 px, terminais arredondados, grade 24 px.

## Components

### Buttons
- **Shape:** 14 px de raio; altura 52 px (44 px ghost); texto Label 500 em 16 px.
- **Primary:** Índigo com texto Linho; pressionado Índigo-profundo com escala 0,98 em 120 ms.
- **Secondary:** Índigo-claro com texto Índigo-profundo.
- **Ghost:** transparente com texto Índigo ("Ver tudo", "Explicar").
- **Destructive:** Terracota-claro com texto Terracota; confirmação em folha.
- **Disabled:** opacidade 0,4; **Loading:** spinner substitui o texto mantendo a largura.

### Chips
- **Style:** Areia, texto Grafite, raio pill, 36 px.
- **State:** selecionado Índigo-claro/Índigo-profundo com check; filtros são chips, ações nunca.

### Cards / Containers
- **Corner Style:** 20 px. **Background:** Linho / Noite-superfície. **Shadow:** nenhuma. **Border:** nenhuma. **Padding:** 16 px; cabeçalho com Title à esquerda e ação ghost à direita.

### Inputs / Fields
- **Style:** Linho com contorno 1 px Fio-forte, raio 10 px, altura 52 px; rótulo Label acima.
- **Focus:** contorno 2 px Índigo. **Error:** contorno Terracota e mensagem que nomeia problema e correção.
- **Money input:** teclado numérico, máscara pt-BR, centavos sempre visíveis, prefixo "R$" em Cinza-ardósia.

### Navigation
- **Tab bar:** Linho, 56 px + safe area, 5 itens, ícone 24 px e rótulo 11 px; ativo Índigo com ícone preenchido.
- **Headers:** iOS large title colapsável; Android top app bar Material 3. Voltar sempre do sistema.
- **Sheets:** bottom sheet para tarefas curtas; tela cheia para fluxos longos (sessão de compras com câmera).

### Barra de prumo (componente-assinatura)
Trilho Areia de 12 px com raio 6 px; preenchimento Índigo (Terracota ao ultrapassar 100%); **marcador de prumo** em Latão na posição "esperada hoje" (dias decorridos ÷ dias do período, ou proporção da lista já comprada no carrinho). Legenda de três estados: "no prumo" (preenchimento ≤ marcador), "atenção" (até 10% acima), "fora do prumo" (acima disso). Usado em: orçamento por categoria, orçamento do mês, limite do cartão, meta/reserva, orçamento do carrinho.

### Valor monetário (componente)
`<Money>` renderiza centavos inteiros com `tabular-nums`, sinal explícito, cor pela Regra do Sinal, modo privacidade (R$ ••••) e rótulo de acessibilidade por extenso.

## Do's and Don'ts

### Do:
- **Do** colocar um único número-herói por tela, em Money Hero, com uma linha de explicação e um botão ghost "Como calculamos".
- **Do** usar Papel (#F6F3EC) como fundo e Linho (#FFFFFF) só em cartões e folhas.
- **Do** desenhar ícones em traço 1,75 px com cantos arredondados, da biblioteca interna.
- **Do** mostrar estados vazio, carregando e erro em todo widget, com uma ação útil no vazio.
- **Do** respeitar Reduce Motion: transições viram crossfade de 150 ms.
- **Do** usar a barra de prumo para qualquer "valor dentro de limite ao longo do tempo".

### Don't:
- **Don't** usar gradientes, roxo, "glass", sombras duras ou cartões dentro de cartões.
- **Don't** usar emoji como ícone ou decoração.
- **Don't** escrever rótulos em caixa alta com tracking largo nem kickers.
- **Don't** apresentar "pode gastar" sem a decomposição acessível, nem chamá-lo de saldo.
- **Don't** usar terracota para qualquer coisa que não seja valor negativo, atraso ou destruição; nem latão em texto.
- **Don't** omitir centavos ou alinhar valores à esquerda em listas.
