# Regras financeiras e contábeis (implementadas em `packages/core`)

Todas as regras abaixo têm teste automatizado (`pnpm -r test`). Arquivo de referência entre parênteses.

## 1. Dinheiro
- Valores são **inteiros em centavos** (`Cents`). Nenhum cálculo usa ponto flutuante sem arredondamento explícito (`money.ts`).
- Arredondamento padrão **half-even** (bancário) em multiplicações/divisões; **half-up** (balança/caixa) para itens pesados no carrinho e para parcelas de empréstimo.
- Divisão de um valor em N partes (`allocate`): a soma das partes é sempre exatamente o total; o resto (≤ N−1 centavos) vai para as primeiras partes (parcelas de cartão) ou últimas, conforme pedido.
- Parsing de entrada aceita `R$ 1.234,56`, `1234,56`, `24,9`, `1,234.56`; rejeita ambiguidades (`1,2,3`).
- Formatação pt-BR com centavos sempre visíveis; `-0` nunca é exibido.

## 2. Datas
- Datas de competência são **calendário local** (`YYYY-MM-DD`), sem fuso. Soma de meses preserva o dia-âncora (31 → 28/29/30 → 31).
- Mês de competência = mês da data do lançamento (`MonthKey`).

## 3. Lançamentos
| Tipo | Efeito na conta | Conta como | Observação |
|---|---|---|---|
| `income` | + conta | receita na data | previsto não altera saldo |
| `expense` | − conta | despesa na data | pagamento parcial: só a parte paga altera saldo; o restante fica pendente |
| `transfer` | − origem, + destino | neutro | nunca entra em receita/despesa |
| `card_purchase` | nenhum | despesa na data da compra | vai para a fatura pela regra de fechamento |
| `card_payment` | − conta | **não é despesa** | abate a fatura (`invoiceMonth`) |
| `goal_deposit` | − origem (+ conta da meta, se houver) | neutro | dinheiro guardado |
| `goal_withdrawal` | − conta da meta (se houver), + destino | neutro | resgate |
| `loan_disbursement` | + conta | neutro | entrada do empréstimo |
| `loan_payment` | − conta | despesa (parcela) | juros + amortização |
| `balance_adjustment` | ± conta | neutro | conciliação com extrato |
- Status: `planned` (previsto), `settled` (efetivado), `partially_paid` (parcial, com `paidCents`), `cancelled`.
- Soft delete (`deletedAt`) para sincronização; cancelados/excluídos nunca entram em totais.

## 4. Saldos
- Saldo da conta = saldo inicial + efeitos dos lançamentos **efetivados** (ou parte paga) até a data (`ledger.ts`).
- Saldo consolidado = soma das contas ativas (arquivadas só se pedido). Transferências não alteram o consolidado.

## 5. Cartões e faturas (`cards.ts`)
- Fatura identificada pelo **mês em que fecha**. Compra no dia ≤ fechamento → fatura do mês; depois → mês seguinte.
- Vencimento: `dueDay` no mesmo mês se `dueDay > closingDay`, senão no mês seguinte. Dias inválidos são limitados ao tamanho do mês.
- Estados: `open` (ainda acumulando), `closed`, `overdue` (vencida com saldo), `paid`, `future`.
- Parcelamento: N parcelas, uma por fatura consecutiva, soma exata, dia da compra preservado; opção de primeira parcela em fatura posterior.
- Limite disponível = limite − (fatura atual em aberto + fechadas não pagas + futuras já lançadas).
- Pagamento parcial de fatura reduz o restante; o restante permanece no comprometimento.
- Não é permitido alterar o dia de fechamento de um cartão com compras (as faturas mudariam de mês).

## 6. "Pode gastar" (`availability.ts`)
```
pode gastar = Σ saldos das contas consideradas (efetivado)
            − contas previstas atrasadas
            − contas previstas até o horizonte (fim do mês ou 30 dias)
            − faturas de cartão fechadas não pagas + fatura atual em aberto
            − reservas protegidas que ficam DENTRO de contas consideradas
            − colchão de segurança
            (+ receitas previstas até o horizonte, só no modo otimista)
```
Sempre retorna a decomposição (`lines`) para a tela "Como calculamos". Nunca é chamado de saldo.

## 7. Orçamentos e ritmo (`budgets.ts`)
- Orçamento por categoria (subcategorias somam na mãe) ou global; o específico do mês prevalece sobre o modelo.
- Gasto = despesas efetivadas + compras no cartão (na competência) + parte paga de parciais.
- Marca de hoje = dias decorridos ÷ dias do mês. Estado: **sereno** (≤ marca), **atenção** (≤ marca + 10 pontos), **agitado** (além disso ou > 100%).

## 8. Metas (`goals.ts`)
- Guardado = depósitos − resgates efetivados. Sugestão mensal = restante ÷ meses até o prazo (half-up). Progresso esperado = tempo decorrido do prazo.

## 9. Empréstimos (`loans.ts`)
- Price: `PMT = P·i / (1 − (1+i)^−n)`; SAC: amortização constante `P/n`. Taxa nominal mensal sobre o saldo devedor; juros arredondados half-up por parcela; a última parcela absorve o resíduo para zerar o saldo.
- Tarifas mensais somam à parcela; tarifas iniciais são financiadas (somam ao principal).
- Parcelas pagas são imputadas em ordem; o excedente é amortização extra.
- Quitação hoje = valor presente das parcelas restantes à taxa contratual (hipótese: redução proporcional de juros, CDC art. 52 §2º), sem tarifas; é uma estimativa para negociação.
- Pagamento extra: reduz prazo (mantém parcela) ou reduz parcela (mantém prazo).

## 10. Recorrência (`recurrence.ts`)
- Frequências: diária, semanal, quinzenal, mensal, bimestral, trimestral, semestral, anual; `count`/`endDate` opcionais; dia-âncora preservado.
- O app materializa 3 meses à frente como previstos e gera novos a cada abertura (`materializeRecurrences`). Excluir "este e os próximos" remove da data em diante, com desfazer.

## 11. Importação (`io/`)
- CSV: detecção de delimitador, mapeamento de colunas (pt/en), datas em vários formatos, valores pt-BR/en; tipo inferido pelo sinal quando não há coluna.
- OFX 1.x/2.x: `STMTTRN` com `FITID` → `externalRef` (`ofx:FITID`).
- Duplicidades: mesmo `externalRef` (certa); mesma data+valor+descrição ≥ 0,6 (provável); valor igual ±2 dias com descrição ≥ 0,8 (possível); duplicatas dentro do próprio lote. Nada é gravado antes da confirmação.
- Backup legado (`pouso-financas-v2`): floats convertidos para centavos uma única vez; tipos mapeados; emojis descartados.

## 12. Compras (`packages/shopping`)
- Linha do carrinho: `preço × quantidade` com half-up por item; promoções "leve N pague M" só para contáveis; desconto absoluto ou percentual, nunca negativo.
- Exemplo do briefing: arroz 2 × 24,90 + leite 6 × 5,49 + banana 1,5 kg × 6,99/kg = **R$ 93,23** (teste).
- Estados do carrinho contra o orçamento: sereno (< 90%), atenção (90–100%), agitado (> 100%).
- Código de barras identifica produto; código de balança (prefixo 2) **não presume** se o valor embutido é peso ou preço.
- Estimativa de lista soma só itens com preço conhecido e informa a cobertura.
- Finalizar sessão gera observações de preço (histórico por loja) e **uma** despesa sugerida (`externalRef shopping:<id>`), nunca duas.

## 13. Direitos de acesso (`billing/`)
- Fonte da verdade: provedor da loja (RevenueCat → StoreKit 2 / Play Billing). Cache local honrado por 7 dias offline.
- Estados que mantêm acesso: ativo, carência, problema de cobrança, cancelado até expirar. Não mantêm: expirado, reembolsado, pausado.
- Vitalício ≥ assinaturas; exclui explicitamente serviços de custo recorrente (`sync`).
