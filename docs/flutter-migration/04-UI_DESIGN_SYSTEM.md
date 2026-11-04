# 04 — UI e design system em Flutter

Fonte normativa: `DESIGN.md` (SerenaCash, "Água parada ao amanhecer"). Implementação: `apps/serenacash_flutter/lib/app/theme/` e `lib/ui/`.

## Tokens → Flutter

| DESIGN.md | Flutter |
|---|---|
| Cores (névoa, branco, bruma, fio, grafite, cinza-mar, sereno, aurora, coral, âmbar, verde-sinal e variantes "noite") | `SerenaColors` (`ThemeExtension`) com `light` e `dark`; acesso por `context.colors` |
| Temas claro, escuro e automático | `MaterialApp.router(theme, darkTheme, themeMode)` a partir de `prefs.theme` (`system`/`light`/`dark`) |
| Tipografia: Bricolage Grotesque para display/títulos/valores; fonte do sistema para corpo | Fonte variável embarcada em `assets/fonts/BricolageGrotesque-Variable.ttf` (OFL incluída); `Type.moneyHero/display/headline/title` usam a família; `body/bodySmall/label/caption` herdam a fonte da plataforma (SF Pro / Roboto) |
| Numerais tabulares | `FontFeature.tabularFigures()` em `Money` e em toda coluna de valores |
| Raios 6/10/14/20/pill, espaçamentos 4…48, toque 44/52 | `Radii`, `Spacing`, `Touch` |
| Movimento 120/220/320 ms, sem piscar | `Motion`; transições `PredictiveBack` (Android) e `Cupertino` (iOS); nenhuma animação de atenção |

## Componentes (lib/ui/components)

- `Money`: centavos inteiros, sinal explícito, Regra do Sinal, modo privacidade (`R$ ••••`), rótulo falado por extenso; hero com centavos a 60 %.
- `RhythmBar`: trilho 12 px + preenchimento + **marca de hoje** (onda 12×6 em aurora sobre linha de 2 px), estados sereno/atenção/agitado, texto "% acima do limite".
- `SCard`/`CardHeader`: branco sobre névoa, raio 20, sem sombra, cabeçalho título + ação ghost.
- `SButton` (primário/secundário/ghost/destrutivo, 52/44 px, loading mantém largura), `SChip`/`ChipSelect`/`Segmented`, `ListRow` (56 px), `EmptyState` com ação, `STextField`, `MoneyField` (máscara pt-BR, prefixo R$, centavos sempre visíveis), `DateField` (hoje/ontem/amanhã + dd/mm/aaaa), `ToggleRow`, `Collapsible`, `confirmSheet` (folha para ações destrutivas), `SScreen`/`StackScreen`/`SheetHeader`, `AddFab`.
- Ícones: `SIcon` desenha o conjunto próprio (traço 1,75 px, grade 24) a partir dos paths SVG da marca; nunca emoji.

## Navegação

GoRouter com `StatefulShellRoute.indexedStack`: Início, Lançamentos, Compras, Planejar, Mais; rotas empilhadas no navegador raiz; modais (`fullscreenDialog`) para lançamento, personalização, "pode gastar", sessão de compra e câmera. Redirecionamento para onboarding na primeira execução. Gate de PIN/biometria envolve toda a árvore (`LockGate`).

## Acessibilidade

- Toda ação tem rótulo (`tooltip`/`Semantics`); valores têm leitura por extenso; barra de ritmo expõe valor e rótulo.
- Alvos ≥ 44 px; contraste conforme tabela do DESIGN.md (checagem no pipeline RN mantida em `docs/qa`).
- Dynamic Type: estilos sem tamanhos fixos em px além da escala; `MediaQuery` respeitado por `Text`.
- `Reduce motion`: transições são curtas; nenhuma animação decorativa.

## Impeccable (princípios aplicados)

- Um número-herói por tela (pode gastar, total do carrinho, saldo devedor), com explicação e "Como calculamos".
- Estados vazio/carregando/erro em todo widget do painel (`WidgetBoundary` + `EmptyState` com ação).
- Rótulos em caixa normal, sem kickers; cor só com significado monetário.
- Capturas reais do app Flutter (claro e escuro) em `docs/flutter-migration/screenshots/`, geradas pelo próprio motor de renderização a partir da árvore de widgets real (`flutter test --update-goldens`).

## Paridade com o RN

Todas as telas do inventário de rotas (`01-AUDITORIA_ORIGEM.md` §1) existem em Flutter com o mesmo comportamento; o conteúdo textual foi movido para ARB (pt-BR e en) — 940 chaves.
