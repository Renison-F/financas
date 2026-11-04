# Fase 3 — UX, arquitetura de informação e fluxos

Base: `PRODUCT.md`, `DESIGN.md`, pesquisa (`docs/02`). Persona principal: pessoa leiga em finanças e exigente com apps. Princípio: **o número antes do relatório**; profundidade por progressive disclosure.

## 1. Navegação (barra inferior, 5 destinos)

| Aba | Pergunta que responde | Conteúdo |
|---|---|---|
| **Início** | "Como estou e o que faço agora?" | Dashboard de widgets personalizável; ação principal "+" (novo lançamento) |
| **Lançamentos** | "Para onde foi / de onde veio?" | Lista por período com busca e filtros; previsto × efetivado; "+" |
| **Compras** | "O que preciso comprar e quanto vai dar?" | Listas de compras e botão "Iniciar compra" (assistente de supermercado) |
| **Planejar** | "Cabe no mês?" | Orçamentos, metas/reservas, cartões e faturas, empréstimos, projeções |
| **Mais** | tudo o que é ocasional | Contas, categorias, tags, relatórios e exportação, calendário, importação, assistente, assinatura, configurações, privacidade, ajuda |

Decisões: cinco destinos são o máximo recomendado por iOS HIG e Material 3; "Compras" ganha aba própria porque é diferencial comercial e uso situacional (no mercado, com uma mão). Cartões ficam em "Planejar" porque a pergunta do usuário sobre cartão é "quanto vai vir na fatura?", não "listar compras".

## 2. Tela inicial (widgets)

Lista vertical de widgets, cada um com estados **carregando / vazio (com ação) / erro / com dados**, navegação ao toque e menu de personalização (ícone no cabeçalho):

- Mostrar/ocultar; reordenar por arrastar e soltar (`react-native-reanimated` + `gesture-handler`) e por botões "mover para cima/baixo" (acessível por leitor de tela); modelos ("Essencial", "Só o mais importante", "Completo", "Supermercado"); restaurar padrão; período (mês atual, últimos 30 dias, mês selecionado); contas consideradas; modo privacidade (ocultar valores, persistido); preferências salvas em SQLite (`user_prefs`) e incluídas na sincronização.

Widget **Cabe gastar** (herói): valor + decomposição em folha "Como calculamos": saldos das contas consideradas − contas a pagar até o fim do período − fatura atual dos cartões (fechada ou em aberto até o vencimento no período) − reservas marcadas como intocáveis − colchão definido pelo usuário. Receitas previstas **não** entram por padrão (há um toggle "considerar receitas previstas", que muda o rótulo para "estimativa otimista"). O número nunca é chamado de saldo.

Catálogo completo de widgets (24) em `packages/core/src/dashboard/widgets.ts`: cabe gastar, saldo consolidado, saldos por conta, receitas, despesas, contas a pagar, contas vencidas, próximos vencimentos, cartões e faturas, compras parceladas, orçamento do mês, gastos por categoria, evolução, metas, reservas, economia mensal, assinaturas recorrentes, empréstimos, calendário, últimas movimentações, recomendações, listas de compras, assistente de supermercado (última compra / iniciar), indicadores avançados.

## 3. Fluxos principais

### 3.1 Primeiro acesso e onboarding (≤ 90 s)
1. Boas-vindas com a promessa ("Saiba o que cabe no seu dinheiro") e escolha de tema automática.
2. "Quanto você tem agora?" → cria a primeira conta (tipo + saldo). Pode pular.
3. "Alguma conta fixa que vence este mês?" → cria 0–3 despesas previstas (modelos: aluguel, luz, internet, celular). Pode pular.
4. "Você usa cartão de crédito?" → cria cartão com fechamento/vencimento. Pode pular.
5. Chega ao Início já com "Cabe gastar" explicável. Sem cadastro de e-mail, sem permissões pedidas aqui (câmera e notificações são pedidas em contexto).

### 3.2 Novo lançamento (3 toques)
Folha com segmentos **Despesa / Receita / Transferência / Cartão**; teclado numérico aberto com valor selecionado; descrição; categoria em chips com busca; conta ou cartão; data (hoje por padrão); avançado (recolhido): previsto/efetivado, recorrência (mensal/semanal/anual, até cancelar ou N vezes), parcelamento (N× no cartão), tags, anexo, observação. Salvar dá feedback tátil e toast com "Desfazer" (10 s).

### 3.3 Cartão e fatura
Tela do cartão: fatura atual (aberta/fechada) com total, vencimento, limite disponível (limite − fatura atual − faturas futuras já comprometidas), lista de compras por fatura, parcelas futuras, botão "Pagar fatura" (integral ou parcial, debita conta, nunca cria despesa). Explicação "por que essa compra está nesta fatura" (regra de fechamento).

### 3.4 Supermercado (uma mão, offline)
"Iniciar compra" → escolher lista (opcional) e orçamento (opcional) → tela da sessão com total corrente grande e "ainda cabe R$ X" → botão câmera (tela cheia): modo **Etiqueta** (OCR) e **Código** (barcode/QR) com guia de enquadramento, lanterna, captura manual, feedback de confiança → folha de confirmação (nome, preço, quantidade/peso, unidade) com campos editáveis e destaque do que foi reconhecido com baixa confiança → item no carrinho com subtotal. Finalizar → resumo (planejado × realizado se veio de lista) → "Registrar como despesa?" (opcional, um único lançamento, com categoria Supermercado e loja).

### 3.5 Importação (CSV/OFX)
Selecionar arquivo → pré-visualização em tabela → mapeamento de colunas (CSV) → detecção de duplicidades (mesma data, valor e descrição semelhante ou mesmo FITID no OFX) com marcação → escolher conta → confirmar. Nada é gravado antes da confirmação.

### 3.6 Assinatura
Paywall acessível por "Mais → Cabe Mais" e por bloqueios suaves em recursos Premium (ex.: 2º cartão, OCR ilimitado, relatórios PDF). Comparação de planos em tabela; botões de compra; "Restaurar compras"; links de privacidade e termos; texto claro do que o vitalício cobre.

## 4. Estados e prevenção de erros
- Vazio: sempre com uma ação ("Adicionar primeira conta").
- Erro: nomeia o problema e a recuperação; dados nunca se perdem silenciosamente (rascunho de lançamento preservado ao sair).
- Confirmação para destrutivos em folha com o nome do item; exclusão de conta com movimentos pede reatribuição ou arquivamento.
- Desfazer em toasts para criar/efetivar/excluir.

## 5. Acessibilidade (critérios de aceite)
Toque ≥ 44 pt; `accessibilityLabel` por extenso em valores; foco visível; ordem de leitura lógica; suporte a 200% de fonte sem cortar valores; contraste AA; "reduzir movimento"; feedback tátil opcional; nenhuma informação só por cor (sinal + ícone + texto).
