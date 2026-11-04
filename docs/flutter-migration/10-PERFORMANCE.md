# 10 — Performance

Medições reais nesta sessão (`flutter test test/perf`, VM de testes em Linux, modo debug; em aparelho release os tempos de CPU costumam ser 3–10× menores):

| Cenário | Medida |
|---|---|
| Cálculo completo do painel (24 widgets) com 5.000 lançamentos | 83,9 ms por cálculo |
| Busca textual com filtro de período em 5.000 lançamentos | 33,9 ms (111 resultados) |
| Banco cifrado: `replaceAll` de 5.000 lançamentos (uma transação) | 562 ms |
| Banco cifrado: `loadLedger` (5.000 lançamentos + etiquetas + anexos) | 237 ms |
| Banco cifrado: consulta por intervalo de mês (índice `idx_tx_date`) | 9 ms (196 linhas) |

Decisões de arquitetura que sustentam esses números:
- Domínio puro sobre um snapshot imutável (`Ledger`), recalculado uma vez por mudança (`dashboardDataProvider`), não por widget.
- Listas com `CustomScrollView`/`SliverList` e `ListView` preguiçosos; cartões sem sombra (Regra do Plano) reduzem custo de pintura.
- Fonte variável única embarcada (sem download em tempo de execução).
- Consultas de intervalo e de fatura usam índices (`date`, `(kind,date)`, `(card_id, invoice_month)`).

Oportunidades registradas (não necessárias para v1): invalidação seletiva do snapshot por tabela (hoje qualquer mutação recarrega o `Ledger`); paginação da lista de lançamentos acima de ~20 mil registros; `Isolate` para importações muito grandes.

Medições em aparelho (frames, jank, tempo de abertura) ficam pendentes de hardware: `flutter run --profile` com DevTools; critério de aceite proposto: abertura ≤ 1,5 s a frio, 0 frames > 32 ms ao rolar o painel completo.
