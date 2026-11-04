# Fase 2 — Identidade visual (marca SerenaCash)

Documento-fonte normativo: `DESIGN.md` (tokens em YAML + regras). Este documento explica as decisões e lista os ativos. Ativos em `brand/`; PNGs gerados por `brand/render-assets.mjs` para `apps/mobile/assets/`. As identidades anteriores ("Cabe"/verde e "Prumo"/índigo) foram descartadas pelo cliente; o nome **SerenaCash** foi definido por ele em 04/11/2026, com o pedido de visual "combinando com a marca" e temas claro, escuro e automático.

## 1. Conceito criativo: "Água parada ao amanhecer"

Serenidade é água sem vento: tudo visível, nada se mexendo sem motivo. O símbolo é uma **moeda-lua refletida em uma linha d'água calma**: um anel (a moeda, o "cash") sobre uma onda baixa (a serenidade). O mesmo gesto estrutura a interface como **marca de hoje**: uma pequena linha com ondulação que mostra, em qualquer barra de limite, onde o gasto deveria estar neste ponto do mês.

| Onde | Trilho | Preenchimento | Marca de hoje |
|---|---|---|---|
| Orçamento por categoria | limite do mês | gasto até agora | proporção do mês decorrido |
| Orçamento do mês | total previsto | total gasto | dias decorridos ÷ dias do mês |
| Limite do cartão | limite | fatura atual + futuras | — |
| Meta/reserva | objetivo | guardado | proporção do prazo decorrido |
| Carrinho do supermercado | orçamento da compra | total corrente | itens comprados ÷ itens da lista |

Estados do mês, sempre com ícone + texto: **sereno** (dentro do ritmo), **atenção** (até 10% acima), **agitado** (acima disso).

Justificativa funcional: o leigo aprende "ritmo de gastos" sem a palavra; a leitura é "estou antes ou depois da marca?". Justificativa de marca: a onda baixa é o oposto do gráfico nervoso de fintech; comunica calma e é desenhável de 16 px a 1024 px.

## 2. Logotipo

- **Símbolo** (`brand/symbol.svg`): anel (moeda) sobre uma onda de um ciclo. Uma cor (`currentColor`) em usos pequenos; duas cores (anel Névoa/Sereno + onda Aurora) no ícone e no wordmark.
- **Wordmark** (`brand/wordmark.svg`, `brand/wordmark.png`): "Serena" em Grafite e "Cash" em Sereno, Bricolage Grotesque 700, tracking -1,5/58, sem espaço. A troca de cor marca as duas palavras sem precisar de espaço ou hífen.
- **Versões**: horizontal (símbolo + wordmark), símbolo isolado (ícone, avatar), wordmark isolado (rodapé, documentos). Monocromática: tudo em Grafite ou Névoa.
- **Área de proteção**: metade da altura do símbolo em todos os lados. **Tamanho mínimo**: símbolo 16 px; wordmark 90 px de largura.
- **Proibido**: inclinar, aplicar gradiente ou sombra, separar "Serena" de "Cash" em linhas diferentes, trocar a aurora da onda por outra cor.

## 3. Ícone do aplicativo

- iOS (`assets/icon.png`, 1024×1024): fundo Sereno #0B5563; anel em Névoa #F3F6F5; onda em Aurora clara #F0B48A. Sem transparência, sem cantos.
- Android adaptativo: `android-icon-foreground.png` (símbolo dentro da zona segura de 66%), `android-icon-background.png` (Sereno sólido), `android-icon-monochrome.png` (ícone temático Android 13+).
- Splash: `splash-icon.png` (anel Sereno + onda Aurora) sobre Névoa (claro) e Noite (escuro), configurado em `app.json`.

## 4. Paleta e tokens semânticos

Tokens normativos em `DESIGN.md` e em código em `apps/mobile/src/design/tokens.ts`. Mapeamento semântico (claro → escuro):

| Token semântico | Claro | Escuro | Uso |
|---|---|---|---|
| `bg` | Névoa #F3F6F5 | Noite #0C1517 | fundo de tela |
| `surface` | Branco #FFFFFF | #152022 | cartões, folhas, tab bar |
| `surfaceInset` | Bruma #E6ECEA | #1E2B2E | insets, chips, trilhos |
| `text` | Grafite #162022 | #E8EEEC | texto principal |
| `textMuted` | Cinza-mar #4F5E61 | #A3B1B3 | secundário |
| `border` / `borderStrong` | #D3DCDA / #74848A | #263437 / #71818A | divisores / contorno de campos |
| `primary` / `onPrimary` | Sereno #0B5563 / #FFFFFF | #6FC8D6 / #0C1517 | ação |
| `primaryContainer` / `onPrimaryContainer` | #D4ECEF / #083E48 | #123F48 / #C8ECF2 | destaque suave |
| `accent` (aurora) | #C0703E | #F0B48A | símbolo e marca de hoje (gráfico, nunca texto) |
| `positive` | #176B4E | #6FD3A8 | entradas, "sereno" |
| `negative` / `negativeContainer` | #A93A29 / #F7DDD6 | #F0907F / #4A1F18 | saídas atrasadas, "agitado" |
| `warning` / `warningContainer` | #8A5200 / #F6E3BE | #F2B86B / #4A3410 | vence em breve, "atenção" |

Todos os pares texto/fundo verificados ≥ 4,5:1 e contornos/marcadores ≥ 3:1 (`node docs/qa/contrast-check.mjs`).

Por que azul-petróleo e aurora: o "sereno" é a cor da água profunda e parada, associada a calma e confiança sem o azul-claro genérico de banco; a aurora é a luz baixa do amanhecer, calor em dose mínima. O nome pede calma, não vibração; por isso não há cores saturadas em grandes áreas.

## 5. Tipografia

- **Bricolage Grotesque** (SIL OFL, `@expo-google-fonts/bricolage-grotesque`): display, headline, title, números-herói e wordmark.
- **Fonte do sistema** (SF Pro / Roboto): corpo, rótulos, controles; respeita Dynamic Type/escala de fonte.
- Escala: Money Hero 44/700 · Display 40/600 · Headline 28/600 · Title 20/600 · Body 17/400 · Body Small 15/400 · Label 13/500 · Money Row 17/600 tabular; unidades escaláveis; testado até 200%.

## 6. Grid, espaçamento e forma

Grade de 4 px; escala 4/8/12/16/24/32/48; gutter 16 px (20 px ≥ 400 pt); largura máxima 600 pt. Raios 6/10/14/20 e pill. Profundidade tonal; sombra só no que flutua. Ícones em traço 1,75 px na grade 24 px, biblioteca própria em `apps/mobile/src/design/icons.tsx`, nunca emoji.

## 7. Movimento e microinterações

- Uma animação autoral por tela: a **ondulação** (a onda da marca de hoje faz um ciclo suave de 320 ms, ease-out) ao atualizar "pode gastar" e ao adicionar item ao carrinho. Nada pisca ou pulsa.
- Transições de navegação do sistema. Feedback tátil leve ao confirmar lançamento e ao ler um código. "Reduzir movimento": crossfade 150 ms, sem ondulação.

## 8. Acessibilidade

Contraste AA verificado; áreas de toque 44 pt / 48 dp; rótulos por extenso para valores; foco 2 px Sereno; modo privacidade (R$ ••••); escala de fonte até 200%; estados nunca só por cor (sinal + ícone + texto).

## 9. Temas claro, escuro e automático

`userInterfaceStyle: automatic` segue o sistema por padrão; o usuário pode fixar claro ou escuro em Configurações (`prefs.theme`). O escuro não é inversão: fundo Noite verde-azulada, superfícies em dois níveis tonais, Sereno claro como ação, containers escurecidos. Ícones e splash têm variantes para ambos.

## 10. Identidade das assinaturas

Planos: **SerenaCash** (grátis), **SerenaCash Plus** (mensal/anual), **SerenaCash Sempre** (vitalício). O paywall usa a barra de ritmo: cada plano é um trilho; o recomendado tem a marca de hoje em Aurora. Destaque tonal (Sereno-claro), sem selos vermelhos. Nomes e preços configuráveis no catálogo (`packages/core/src/billing`).

## 11. Recursos para as lojas

Especificação em `docs/12-guia-publicacao.md`: ícone 1024, capturas 6,7" e 6,1" (iOS) e 1080×1920 + feature graphic 1024×500 (Android), fundo Névoa, telas reais, títulos em Bricolage Grotesque. Capturas só a partir de builds reais, nunca de mockups.
