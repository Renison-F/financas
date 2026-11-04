# Fase 2 — Identidade visual

Documento-fonte normativo: `DESIGN.md` (tokens em YAML + regras). Este documento explica as decisões e lista os ativos. Ativos em `brand/`; PNGs gerados por `brand/render-assets.mjs` para `apps/mobile/assets/`.

## 1. Conceito criativo: "O encaixe"

A marca é a sensação de uma peça entrando no lugar certo. O símbolo é uma **moldura** com uma abertura no canto superior direito (a peça acabou de entrar) e uma **peça** assentada com folga dentro dela. O mesmo gesto estrutura a interface:

| Onde | Moldura | Peça |
|---|---|---|
| Cartão "cabe gastar" | fundo Verde-claro | o valor em Money Hero |
| Orçamento por categoria | trilho Areia | preenchimento Verde-mata (Terracota se transbordar) |
| Carrinho do supermercado | teto da compra | total corrente |
| Limite do cartão | limite | fatura + compromissos |
| Meta/reserva | objetivo | valor guardado |

Justificativa funcional: um único motivo visual ensina ao usuário leigo, sem texto, a ideia de "valor dentro de limite", que é o conceito central do produto. Justificativa de marca: o motivo é desenhável em 16 px (ícone de aba), 48 px (favicon) e 1024 px (ícone da loja) sem perder leitura.

## 2. Logotipo

- **Símbolo** (`brand/symbol.svg`): traço 5/64 da grade, cantos arredondados, peça com raio 7/28. Cor única (`currentColor`): Verde-mata sobre claro, Noite-verde sobre escuro, Linho sobre Verde-mata.
- **Wordmark** (`brand/wordmark.svg`, `brand/wordmark.png`): "cabe" em caixa baixa, Bricolage Grotesque 700, tracking -1,5/58, Grafite. Caixa baixa porque o nome é um verbo do cotidiano, não uma sigla.
- **Versões**: horizontal (símbolo + wordmark), símbolo isolado (ícone, avatar), wordmark isolado (rodapé, documentos). Versão monocromática: tudo em Grafite ou Linho.
- **Área de proteção**: metade da altura do símbolo em todos os lados. **Tamanho mínimo**: símbolo 16 px; wordmark 60 px de largura.
- **Proibido**: rotacionar, aplicar gradiente, sombra, contorno adicional, usar o símbolo com a abertura fechada, alterar a folga entre moldura e peça.

## 3. Ícone do aplicativo

- iOS (`assets/icon.png`, 1024×1024): fundo Verde-mata #0F5C45, símbolo em Linho #F6F3EC ocupando 62% da largura. Sem transparência, sem cantos (o sistema aplica).
- Android adaptativo: `android-icon-foreground.png` (símbolo dentro da zona segura de 66%), `android-icon-background.png` (Verde-mata sólido), `android-icon-monochrome.png` (ícone temático Android 13+).
- Splash: `splash-icon.png` sobre fundo Papel (claro) e Noite (escuro), configurado em `app.json` via `expo-splash-screen`.

## 4. Paleta e tokens semânticos

Tokens normativos em `DESIGN.md` e em código em `apps/mobile/src/design/tokens.ts`. Mapeamento semântico (claro → escuro):

| Token semântico | Claro | Escuro | Uso |
|---|---|---|---|
| `bg` | Papel #F6F3EC | Noite #0E1311 | fundo de tela |
| `surface` | Linho #FFFFFF | #171D1A | cartões, folhas, tab bar |
| `surfaceInset` | Areia #EEEAE0 | #202825 | insets, chips, trilhos |
| `text` | Grafite #1B211E | #ECEDE8 | texto principal |
| `textMuted` | Cinza-verde #5B6962 | #A3ADA7 | secundário (5,2:1 / 8,1:1) |
| `border` / `borderStrong` | #DDD8CC / #78857D | #2C3531 / #5E6B65 | divisores / contorno de campos |
| `primary` / `onPrimary` | #0F5C45 / #FFFFFF | #6FD3A8 / #0E1311 | ação |
| `primaryContainer` / `onPrimaryContainer` | #D7EFE3 / #0A3B2D | #134A38 / #C8F0DE | destaque suave |
| `positive` | #176B4E | #6FD3A8 | entradas, saldo positivo |
| `negative` / `negativeContainer` | #A3362A / #F7DDD6 | #F0907F / #4A1F18 | saídas atrasadas, "não cabe" |
| `warning` / `warningContainer` | #8A5200 / #F6E3BE | #F2B86B / #4A3410 | vence em breve, baixa confiança |

Todos os pares texto/fundo acima foram verificados ≥ 4,5:1 (script em `docs/qa/contrast-check.mjs`).

Por que verde e terra, e não roxo/azul: verde é a cor cultural de "saldo positivo" e de "pode" no Brasil (semáforo, Pix confirmado); a paleta terrosa evita o visual genérico de fintech (roxo Nubank, azul bancário) e sustenta o tom caloroso. O roxo foi explicitamente rejeitado no briefing.

## 5. Tipografia

- **Bricolage Grotesque** (SIL Open Font License, pacote `@expo-google-fonts/bricolage-grotesque`): display, headline, title e números-herói. Escolhida pelo caráter próprio (terminais irregulares, "g" de dois andares) e por ter numerais tabulares.
- **Fonte do sistema** (SF Pro / Roboto): corpo, rótulos, controles. Mantém o app nativo, respeita Dynamic Type/escala de fonte e evita baixar mais famílias.
- Escala: Money Hero 44/700 · Display 40/600 · Headline 28/600 · Title 20/600 · Body 17/400 · Body Small 15/400 · Label 13/500 · Money Row 17/600 tabular. Todos os tamanhos em unidades escaláveis (`sp`/pontos) e testados até 200%.

## 6. Grid, espaçamento e forma

Grade de 4 px; escala 4/8/12/16/24/32/48; gutter 16 px (20 px ≥ 400 pt); largura máxima 600 pt. Raios 6/10/14/20 e pill. Profundidade tonal; sombra só no que flutua. Ícones em traço 1,75 px na grade 24 px, biblioteca própria em `apps/mobile/src/design/icons.tsx` (SVG), nunca emoji.

## 7. Movimento e microinterações

- Uma animação autoral por tela: o **encaixe** (a peça desliza 4 px e assenta com ease-out exponencial, 220 ms) ao atualizar o valor "cabe gastar" e ao adicionar item ao carrinho.
- Transições de navegação são as do sistema. Feedback tátil leve ao confirmar lançamento e ao ler um código. Com "reduzir movimento" ativo: crossfade de 150 ms, sem deslocamento.

## 8. Acessibilidade

Contraste AA verificado; áreas de toque 44 pt / 48 dp; rótulos de leitor de tela por extenso para valores; foco visível 2 px Verde-mata; modo privacidade (R$ ••••); escala de fonte até 200% sem cortar valores (o Money Hero reduz para 36 px antes de quebrar).

## 9. Tema claro e escuro

Ambos de primeira classe; `userInterfaceStyle: automatic`. O escuro não é inversão: fundo Noite esverdeado, superfícies em dois níveis tonais, verde claro como ação, e containers escurecidos para semânticas.

## 10. Identidade das assinaturas

Planos: **Cabe** (grátis), **Cabe Mais** (mensal/anual), **Cabe Sempre** (vitalício). O paywall usa o motivo do encaixe: cada plano é uma moldura; o plano recomendado tem a peça preenchida. Sem selos "melhor valor" em vermelho; o destaque é tonal (Verde-claro). Nomes e preços finais são configuráveis no catálogo (`packages/core/src/billing`).

## 11. Recursos para as lojas

Especificação em `docs/12-guia-publicacao.md`: ícone 1024, capturas 6,7" e 6,1" (iOS) e 1080×1920 + feature graphic 1024×500 (Android), com fundo Papel, telas reais do app e títulos em Bricolage Grotesque. As capturas só serão produzidas a partir de builds reais (emulador/simulador), nunca de mockups.
