# Fase 1 — Auditoria do repositório legado (`index.html`)

Data: 2026-11-04 · Commit auditado: `e080f12` (único commit do repositório)

## 1. O que existe

| Item | Situação |
|---|---|
| Arquivos | 1 arquivo: `index.html` (147.791 bytes, 552 linhas, CSS e JS minificados inline) |
| Tecnologia | HTML + CSS + JavaScript puro, sem build, sem dependências, sem testes |
| Persistência | `localStorage`, chave `pouso-financas-v2`, um único JSON com todo o estado |
| Identidade | Nome "Pouso" (título) / "Finanças Pop" (meta description), paleta roxo/rosa, emojis decorativos, fonte Trebuchet MS |
| Idioma | pt-BR fixo, moeda BRL fixa (`Intl.NumberFormat`) |
| Layout | Sidebar desktop + tabbar mobile; responsivo, mas pensado para navegador |

## 2. Modelo de dados (extraído de `defaultData()` e `handleForm()`)

```
data = { version, prefs, accounts[], categories[], cards[], transactions[], budgets[], goals[], loans[], tags[] }
account      { id, name, type(cash|bank|...), balance (saldo inicial), color }
category     { id, name, type(income|expense), icon(emoji), color }
card         { id, name, limit, closing(1..28), due(1..28), color }
transaction  { id, type, amount(float), date(YYYY-MM-DD), accountId, toAccountId, cardId,
               categoryId, description, memo, paid(bool), tags[], seriesId?, invoiceKey?, goalId?, loanId? }
   type ∈ income | expense | transfer | card_expense | card_payment | goal_deposit | goal_withdraw | loan_payment | loan_in
budget       { id, categoryId, limit }
goal         { id, name, target, ... }
loan         { id, principal, rate(% a.m.), months, ... }
prefs        { name, theme, dashboardOrder[], dashboardWidgets{}, safetyCushion, widgets{} }
```

## 3. Funcionalidades existentes (19 rotas)

| Rota | Funcionalidade | Avaliação |
|---|---|---|
| dashboard | 16 widgets configuráveis (mostrar/ocultar, ordem por setas, 4 presets) | Conceito bom; sem arrastar e soltar; preferências só no navegador |
| accounts | Contas com saldo inicial, cor e tipo | Reaproveitar conceito; falta arquivamento, conciliação, ajuste de saldo |
| transactions | Receita, despesa, transferência, compra no cartão; previsto/efetivado; repetir mensal (2–24); tags; busca; filtro por tipo | Base sólida de regras; sem parcelamento real, sem anexos, sem pagamento parcial |
| cards | Cartões com limite, fechamento, vencimento; faturas por `invKey`; pagamento de fatura | Lógica de competência de fatura correta na essência; fechamento imutável após uso |
| mia | "Leitura financeira": insights por regras + radar de 5 indicadores | Indicadores sem metodologia documentada (pontuações arbitrárias) |
| budgets | Orçamento por categoria/mês | Falta orçamento global, anual e alertas |
| goals | Objetivos com depósitos/saques movimentando contas | Reaproveitar modelo (meta = transações, não saldo paralelo) |
| reports / charts | Fluxo mensal, categorias, donut, tendência 6 meses (SVG) | Reaproveitar fórmulas; sem comparativo anual nem PDF |
| calendar | Calendário mensal com lançamentos por dia | Reaproveitar |
| categories / tags | CRUD | Reaproveitar; falta subcategoria |
| loans | Empréstimos com Tabela Price (`installment()`), pagamentos | Fórmula correta; sem amortização extra, sem SAC, sem antecipação |
| openfinance | Tela informativa (não implementado) | Descartar; não prometer |
| tools | Backup JSON, exportação CSV do mês, importação CSV (`data;descricao;valor;tipo`) | Reaproveitar formatos; importação sem prevenção de duplicidades e sem revisão |
| plans | Tela informativa "tudo liberado" | Substituir por monetização real |
| settings / help / about | Preferências, nome, tema | Reaproveitar ideia |

## 4. Regras financeiras encontradas (para preservar ou corrigir)

1. **Efetivação**: `effective(t) = t.paid !== false || t.type === 'card_expense'`. Compras no cartão sempre contam como despesa na data da compra; o pagamento da fatura (`card_payment`) só debita a conta. **Correto**: evita dupla contagem — regra a preservar.
2. **Saldo de conta** = saldo inicial + receitas − despesas ± transferências − pagamentos de fatura − depósitos em metas + resgates de metas − parcelas de empréstimo + entrada de empréstimo. Só lançamentos efetivados.
3. **Fatura**: compra após o dia de fechamento vai para a fatura do mês seguinte; chave da fatura = mês do vencimento. Vencimento limitado ao dia 28.
4. **Dinheiro disponível** = soma dos saldos − despesas pendentes até o fim do mês − dívida total de cartões − colchão de segurança. Ignora receitas previstas (prudente), mas inclui a dívida total de cartões (inclusive faturas futuras), o que pode subestimar o disponível. A nova versão deve separar fatura atual, faturas futuras e compromissos previstos, e explicar cada parcela.
5. **Empréstimo**: Price, taxa mensal `r = rate/1200`, `PMT = P·r / (1 − (1+r)^−n)`.
6. **Recorrência**: copia o lançamento N vezes com `plusMonths` (ajusta dia 31→30/28). Não há série editável nem "até cancelar".

## 5. Problemas técnicos e arquiteturais

| Severidade | Problema |
|---|---|
| Crítica | Dinheiro em `Number` (ponto flutuante) com arredondamento `rnd()` em cada operação; risco de centavos perdidos em somas longas e parcelamentos |
| Crítica | Sem testes automatizados de qualquer tipo |
| Crítica | Persistência em `localStorage` (limite ~5 MB, pode ser apagado pelo navegador, sem transação, sem migração formal) |
| Alta | Arquivo único de 148 KB: UI, regras e persistência misturadas; impossível reaproveitar o domínio em mobile sem reescrever |
| Alta | Renderização por `innerHTML` com templates string: risco de XSS mitigado por `esc()`/`attr()` manuais, mas frágil |
| Alta | Sem módulo de listas de compras, sem assistente de supermercado, sem câmera/OCR, sem monetização, sem sincronização, sem autenticação |
| Média | Datas como string local sem fuso explícito (`T12:00:00` como truque); sem suporte a múltiplas moedas |
| Média | Importação CSV sem revisão prévia e sem detecção de duplicidades; sem OFX |
| Média | Indicadores de "saúde financeira" com pesos arbitrários apresentados como diagnóstico |
| Baixa | Acessibilidade parcial (foco visível, aria-labels) mas emojis como ícones e contraste não auditado |

## 6. Decisão: reaproveitar, reescrever, substituir

**Reaproveitar (como especificação, reescrito em TypeScript tipado e testado):**
- Regra de não dupla contagem cartão × fatura.
- Modelo "meta = transações de depósito/resgate" e "empréstimo = entrada + parcelas".
- Competência da fatura (fechamento/vencimento).
- Conceito de dashboard por widgets com presets.
- Formatos de backup JSON e CSV (compatibilidade de importação do legado será mantida: um importador `legacy-pouso-v2` converte o JSON antigo).
- Categorias iniciais (nomes), ajustadas.

**Reescrever:** todo o domínio financeiro em inteiros (centavos), persistência em SQLite com migrações, UI nativa (React Native), recorrência como série, importação com revisão.

**Substituir/descartar:** marca, cores, tipografia, emojis, telas informativas de Open Finance e Planos, radar de saúde financeira sem metodologia.

## 7. Requisitos ausentes em relação ao briefing

Listas de compras · assistente de supermercado (câmera, OCR, códigos, carrinho) · parcelamento em cartão · pagamento parcial · anexos/comprovantes · subcategorias · orçamento global/anual · reserva de emergência · simulação de quitação · projeção de saldo · OFX · PDF · assistente financeiro em linguagem natural · monetização · sincronização · biometria · notificações · internacionalização · exclusão/exportação de dados (LGPD) · testes.
