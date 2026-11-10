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
- `SButton` (primário/secundário/ghost/destrutivo, 52/44 px, loading mantém largura), `SChip`/`ChipSelect`/`Segmented`, `ListRow` (56 px; o valor à direita encolhe em vez de estourar), `EmptyState` com ação, `EmptyRow` (estado vazio de uma linha), `STextField`, `SecretField` (PIN e senhas ocultos, com botão para mostrar), `MoneyField` (máscara pt-BR, prefixo R$, centavos sempre visíveis), `DateField` (hoje/ontem/amanhã + dd/mm/aaaa), `ToggleRow`, `Collapsible`, `confirmSheet` (folha para ações destrutivas), `SScreen`/`StackScreen`/`SheetHeader`, `AddFab`.
- Ícones: `SIcon` desenha o conjunto próprio (traço 1,75 px, grade 24) a partir dos paths SVG da marca; nunca emoji.

## Tela inicial (redesenho de 05/11/2026)

Composição em `lib/features/home/`:

| Bloco | Onde | Dados |
|---|---|---|
| Cabeçalho compacto: saudação por horário e período como controle discreto (abre "Personalizar tela inicial", onde ficam período e contas consideradas); ações de ocultar valores e alternar tema claro/escuro | `HomeHeader` em `home_parts.dart`, `home_screen.dart` | `greetingFor`, `layout.period`, `prefs.privacyMode`, `prefs.theme` |
| Painel-resumo "pode gastar" com os dois valores que o explicam | `SummaryPanel` | `Availability` (`availableCents`, `lines`, `status`, `mode`); "Dinheiro nas contas" é a linha `balances`, "Compromissos" é a soma das linhas de sinal negativo. Nenhum cálculo novo |
| Primeiro acesso (sem conta) | `SummaryPanel` | `availability.hasAccounts == false` mostra "Configure seu saldo" e "Adicionar conta"; não exibe valor |
| Ações rápidas | `QuickActions` | rotas existentes: `/transaction?kind=expense&planned=1`, `/transaction?kind=transfer` ou `kind=income`, `/accounts` |
| Contas a pagar: total pendente, atrasadas primeiro, vencimento em palavras | caso `bills_to_pay` em `widgets.dart`, `DueBadge`, `dueLabel` | `data.overdue`, `data.bills`, `pendingCents` |
| Cartões e faturas: cartão, fatura, vencimento, fechamento e limite livre; até 2 cartões e "Mais N cartões" | `_CardInvoice` | `data.cards` (`Invoice`, `CardCommitment`) |
| Últimos lançamentos: o que já aconteceu (previstos futuros ficam em "Contas a pagar") | caso `recent_transactions` | `data.recent` |
| Seções vazias em uma linha | `EmptyRow` | — |
| Carregando | `HomeSkeleton` (blocos estáticos) | `dashboardDataProvider == null` |

A personalização continua valendo: ordem, visibilidade, modelos, período e contas consideradas vêm de `DashboardLayout`. As ações rápidas aparecem logo abaixo do painel "pode gastar" (ou no topo, se ele estiver oculto) e o atalho "Personalizar tela inicial" fica no fim da lista. Tokens novos em `SerenaColors`: `hero`, `onHero`, `onHeroMuted`, `heroDivider`; `Touch.target` (48 dp). Barra inferior: pílula `primaryContainer` na aba ativa (`navigationBarTheme`).

Capturas (`screenshots/`): `home_first_access_light`, `home_no_movements_light`, `home_data_light`, `home_data_dark`, `home_data_hidden_light`, `home_data_narrow_large_text(_top)`. Os dados de demonstração existem só em `test/app/home_redesign_test.dart`, em banco em memória.

## Navegação

GoRouter com `StatefulShellRoute.indexedStack`: Início, Lançamentos, Compras, Planejar, Mais; rotas empilhadas no navegador raiz; modais (`fullscreenDialog`) para lançamento, personalização, "pode gastar", sessão de compra e câmera. Redirecionamento para onboarding na primeira execução. Gate de PIN/biometria envolve toda a árvore (`LockGate`).

## Acessibilidade

- Toda ação tem rótulo (`tooltip`/`Semantics`); valores têm leitura por extenso; barra de ritmo expõe valor e rótulo.
- Alvos ≥ 44 px (48 dp nos botões de ícone, ações rápidas e cores de conta); contraste conforme tabela do DESIGN.md (checagem no pipeline RN mantida em `docs/qa`).
- Dynamic Type: estilos sem tamanhos fixos em px além da escala; `MediaQuery` respeitado por `Text`.
- `Reduce motion`: transições são curtas; nenhuma animação decorativa.

## Impeccable (princípios aplicados)

- Um número-herói por tela (pode gastar, total do carrinho, saldo devedor), com explicação e "Como calculamos".
- Estados vazio/carregando/erro em todo widget do painel (`WidgetBoundary` + `EmptyState` com ação).
- Rótulos em caixa normal, sem kickers; cor só com significado monetário.
- Capturas reais do app Flutter (claro e escuro) em `docs/flutter-migration/screenshots/`, geradas pelo próprio motor de renderização a partir da árvore de widgets real (`flutter test --update-goldens`).

## Paridade com o RN

Todas as telas do inventário de rotas (`01-AUDITORIA_ORIGEM.md` §1) existem em Flutter com o mesmo comportamento; o conteúdo textual foi movido para ARB (pt-BR e en) — 940 chaves.

## Identidade em todo o app (05/11/2026)

A tela inicial passou a definir a linguagem de todas as telas. O que mudou no código:

- `lib/app/theme/tokens.dart`: uma escala compacta única em `Type` (headline 22, title 16, body 15, linha 14/12, valores 14 com algarismos tabulares, botão 15) e `Layout` (margem 12, preenchimento do cartão, quadro de ícone de 32).
- `lib/app/theme/theme.dart`: botões com raio 10 e 48 px, cartões com raio 14, diálogo, folha, aviso, menu lateral e botão "+" circular.
- `lib/ui/components/`: `SCard` (raio e preenchimento novos, parâmetro `radius`), `CardHeader` (link à direita), `ListRow` (linha densa, a mesma da tela inicial), `IconTile`, `RowDivider`/`dividedRows`, `SButton`, `SChip`, `Segmented`, `SScreen` (margem e título), `EmptyState`/`EmptyRow`, `Money` (papéis `heroFlat`, `section`, `dense`, sinal separado).
- `lib/ui/icons.dart` e `lib/ui/category_icons.dart`: 40 ícones novos no mesmo traço e a biblioteca de ícones de categoria com palavras de busca; paleta de 13 cores sem roxo.
- `lib/features/home/home_parts.dart`: só o que é próprio da tela inicial (cabeçalho, painel-resumo, ações rápidas, desenho do cartão, etiqueta de vencimento).
- `lib/app/app_drawer.dart` e `lib/features/shared/add_sheet.dart`: menu lateral e folha "Adicionar".

Acessibilidade: botões que podem aparecer sozinhos (ícone, cor, chip, linha tocável) declaram `container: true`; sem isso o Flutter funde a anotação com o nó vizinho e o botão deixa de ser anunciado.

Capturas em `screenshots/` (`tour_*`, `categories_*`, `category_*`, `menu_light`, `transactions_light`, `home_*`).

## Rodada 0.2.0+3 (10/11/2026)

- **Folhas** (`lib/ui/components/sheets.dart`): toda folha modal passa por `showSSheet`, que reserva o maior entre o teclado e a barra do sistema. O Flutter só trata o topo e as laterais de uma folha; por isso a última opção ficava atrás dos três botões (ocorrência 001).
- **Paletas** (`lib/app/theme/palettes.dart`): seis cores de aplicativo (`teal`, a padrão, `blue`, `green`, `terracotta`, `graphite`, `wine`), em claro e escuro. A paleta troca a cor de ação, seus contêineres, o acento e o painel-resumo. Receita, despesa, alerta, texto e superfícies não mudam. O contraste de cada par é conferido por cálculo em `appearance_test.dart`.
- **Densidade**: confortável (padrão) e compacta (`context.compact`).
- **Gráfico circular** (`lib/ui/components/donut.dart`): anel com legenda ao lado; percentuais com uma casa que somam 100,0% (`domain/reports/shares.dart`). Sempre acompanhado da lista com valor e percentual; a cor nunca é o único sinal.
- **Campo de data**: digitação mais botão de calendário (`showDatePicker` com o tema do app).
- **Linguagem**: "sereno", "atenção" e "agitado" saíram da interface; os textos dizem o fato ("Gasto dentro do previsto", "Resultado do mês"). O nome do produto continua SerenaCash.
- **Tela inicial**: seis cartões novos (`extraWidgets`): saldo do período, visão geral do mês, controle diário, discriminação, recorrência e saúde financeira.
- ARB: 1.430 chaves em pt-BR e en.

Parcial, registrado em `15`: não há editor livre de cores, estilos de cartão, preferências de tipografia nem opção própria de movimento reduzido (o app segue a do sistema); os cartões da tela inicial não mudam de tamanho.
