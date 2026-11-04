# Fase 2 — Identidade visual (marca Prumo)

Documento-fonte normativo: `DESIGN.md` (tokens em YAML + regras). Este documento explica as decisões e lista os ativos. Ativos em `brand/`; PNGs gerados por `brand/render-assets.mjs` para `apps/mobile/assets/`. A identidade anterior ("Cabe", conceito "o encaixe", verde-mata) foi descartada a pedido do cliente em 04/11/2026 e substituída integralmente.

## 1. Conceito criativo: "O fio de prumo"

O fio de prumo é um cordão com um peso: a ferramenta mais simples que existe para saber se algo está alinhado. A marca transporta essa honestidade para o dinheiro: **estar no prumo** é estar em ordem. O símbolo é o próprio instrumento, e o mesmo gesto estrutura a interface como **marcador de prumo**, uma linha vertical fina com um pequeno peso que marca "onde você deveria estar hoje" em qualquer barra de limite:

| Onde | Trilho | Preenchimento | Marcador de prumo |
|---|---|---|---|
| Orçamento por categoria | limite do mês | gasto até agora | proporção do mês decorrido |
| Orçamento do mês | total previsto | total gasto | dias decorridos ÷ dias do mês |
| Limite do cartão | limite | fatura atual + futuras | — (sem ritmo) |
| Meta/reserva | objetivo | guardado | proporção do prazo decorrido |
| Carrinho do supermercado | orçamento da compra | total corrente | itens comprados ÷ itens da lista |

Justificativa funcional: o leigo aprende "ritmo de gastos" sem a palavra; a leitura é "estou antes ou depois do pesinho?". Justificativa de marca: nenhum app de finanças usa o fio de prumo; ele foge de moedas, cofres, folhas e gráficos de pizza, e é desenhável de 16 px a 1024 px.

## 2. Logotipo

- **Símbolo** (`brand/symbol.svg`): argola (anel) no topo, cordão vertical e peso (ombros retos, ponta arredondada). Em uma cor (`currentColor`) para usos pequenos; em duas cores (cordão Papel/Índigo + peso Latão) para ícone e wordmark.
- **Wordmark** (`brand/wordmark.svg`, `brand/wordmark.png`): "prumo" em caixa baixa, Bricolage Grotesque 700, tracking -1,5/58, Grafite. Caixa baixa porque é uma palavra do cotidiano, não uma sigla.
- **Versões**: horizontal (símbolo + wordmark), símbolo isolado (ícone, avatar), wordmark isolado (rodapé, documentos). Monocromática: tudo em Grafite ou Linho.
- **Área de proteção**: metade da altura do símbolo em todos os lados. **Tamanho mínimo**: símbolo 16 px; wordmark 70 px de largura.
- **Proibido**: inclinar o cordão (o prumo é sempre vertical), gradiente, sombra, contorno extra, trocar o latão por outra cor no peso.

## 3. Ícone do aplicativo

- iOS (`assets/icon.png`, 1024×1024): fundo Índigo #24477A; cordão e argola em Papel #F6F3EC; peso em Latão claro #D9A441. Sem transparência, sem cantos.
- Android adaptativo: `android-icon-foreground.png` (símbolo dentro da zona segura de 66%), `android-icon-background.png` (Índigo sólido), `android-icon-monochrome.png` (ícone temático Android 13+).
- Splash: `splash-icon.png` (símbolo índigo + latão) sobre Papel (claro) e Noite (escuro), configurado em `app.json`.

## 4. Paleta e tokens semânticos

Tokens normativos em `DESIGN.md` e em código em `apps/mobile/src/design/tokens.ts`. Mapeamento semântico (claro → escuro):

| Token semântico | Claro | Escuro | Uso |
|---|---|---|---|
| `bg` | Papel #F6F3EC | Noite #0F1419 | fundo de tela |
| `surface` | Linho #FFFFFF | #181E26 | cartões, folhas, tab bar |
| `surfaceInset` | Areia #EEEAE0 | #222A34 | insets, chips, trilhos |
| `text` | Grafite #1B1F24 | #ECEDE8 | texto principal |
| `textMuted` | Cinza-ardósia #5B6670 | #A6ADB6 | secundário |
| `border` / `borderStrong` | #DDD8CC / #78857D | #2A323C / #6C7784 | divisores / contorno de campos |
| `primary` / `onPrimary` | Índigo #24477A / #FFFFFF | #8FB4F0 / #0F1419 | ação |
| `primaryContainer` / `onPrimaryContainer` | #D9E4F4 / #14294A | #1C3356 / #CFE0FA | destaque suave |
| `accent` (latão) | #B07A1E | #E3B35A | símbolo e marcador de prumo (gráfico, nunca texto) |
| `positive` | #176B4E | #6FD3A8 | entradas, "no prumo" |
| `negative` / `negativeContainer` | #A3362A / #F7DDD6 | #F0907F / #4A1F18 | saídas atrasadas, "fora do prumo" |
| `warning` / `warningContainer` | #8A5200 / #F6E3BE | #F2B86B / #4A3410 | vence em breve, baixa confiança |

Todos os pares texto/fundo acima foram verificados ≥ 4,5:1 e contornos ≥ 3:1 (`node docs/qa/contrast-check.mjs`).

Por que índigo e latão: o índigo de giz é a cor da linha que o construtor risca para alinhar; é sóbrio e confiável sem cair no azul-claro genérico de banco (a paleta é escura e quente, não "corporativa"). O latão é a cor real de um peso de prumo e dá à marca um ponto de calor e artesanato. Roxo, gradientes e verde-fintech foram descartados.

## 5. Tipografia

- **Bricolage Grotesque** (SIL OFL, `@expo-google-fonts/bricolage-grotesque`): display, headline, title e números-herói. Caráter próprio e numerais tabulares.
- **Fonte do sistema** (SF Pro / Roboto): corpo, rótulos, controles; respeita Dynamic Type/escala de fonte.
- Escala: Money Hero 44/700 · Display 40/600 · Headline 28/600 · Title 20/600 · Body 17/400 · Body Small 15/400 · Label 13/500 · Money Row 17/600 tabular; unidades escaláveis; testado até 200%.

## 6. Grid, espaçamento e forma

Grade de 4 px; escala 4/8/12/16/24/32/48; gutter 16 px (20 px ≥ 400 pt); largura máxima 600 pt. Raios 6/10/14/20 e pill. Profundidade tonal; sombra só no que flutua. Ícones em traço 1,75 px na grade 24 px, biblioteca própria em `apps/mobile/src/design/icons.tsx`, nunca emoji.

## 7. Movimento e microinterações

- Uma animação autoral por tela: o **assentar do prumo** (o peso desce 6 px e assenta com ease-out exponencial, 240 ms, leve oscilação de 1 ciclo) ao atualizar "pode gastar" e ao adicionar item ao carrinho.
- Transições de navegação do sistema. Feedback tátil leve ao confirmar lançamento e ao ler um código. "Reduzir movimento": crossfade 150 ms, sem deslocamento nem oscilação.

## 8. Acessibilidade

Contraste AA verificado; áreas de toque 44 pt / 48 dp; rótulos por extenso para valores; foco 2 px Índigo; modo privacidade (R$ ••••); escala de fonte até 200%; estados nunca só por cor (sinal + ícone + texto: "no prumo" com check, "fora do prumo" com alerta).

## 9. Tema claro e escuro

Ambos de primeira classe; `userInterfaceStyle: automatic`. Escuro: fundo Noite azul-escura, superfícies em dois níveis tonais, índigo claro como ação, containers escurecidos.

## 10. Identidade das assinaturas

Planos: **Prumo** (grátis), **Prumo Mais** (mensal/anual), **Prumo Sempre** (vitalício). O paywall usa a barra de prumo: cada plano é um trilho; o recomendado tem o peso assentado em Latão. Destaque tonal (Índigo-claro), sem selos vermelhos. Nomes e preços configuráveis no catálogo (`packages/core/src/billing`).

## 11. Recursos para as lojas

Especificação em `docs/12-guia-publicacao.md`: ícone 1024, capturas 6,7" e 6,1" (iOS) e 1080×1920 + feature graphic 1024×500 (Android), fundo Papel, telas reais, títulos em Bricolage Grotesque. Capturas só a partir de builds reais (emulador/simulador), nunca de mockups.
