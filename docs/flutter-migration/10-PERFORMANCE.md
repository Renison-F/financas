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

## Volumes progressivos (05/11/2026)

### Na máquina de desenvolvimento (`flutter test test/perf/volume_test.dart`)

VM de testes do Dart, banco em memória. Servem para ver a forma do crescimento, não o tempo de um celular. Tempos em milissegundos.

| Medida | 100 | 1.000 | 5.000 | 10.000 | 50.000 |
|---|---|---|---|---|---|
| Painel (ordem padrão) | 2,1 | 9,0 | 53,2 | 92,6 | 482,7 |
| Painel (24 widgets) | 1,2 | 8,0 | 50,4 | 92,3 | 479,9 |
| Busca por texto com período | 0,9 | 1,3 | 3,4 | 6,9 | 38,9 |
| Totais do mês | 0,0 | 0,0 | 0,2 | 0,4 | 2,7 |
| Gastos por categoria | 0,0 | 0,0 | 0,2 | 0,3 | 1,8 |
| "Pode gastar" | 0,1 | 1,2 | 7,6 | 13,2 | 64,2 |
| Banco: gravar tudo | 159 | 77 | 169 | 301 | 1.354 |
| Banco: carregar tudo | 29 | 22 | 56 | 82 | 417 |
| Banco: intervalo de um mês | 0,8 | 1,2 | 5,2 | 4,9 | 25,0 |

O crescimento é linear em todas as medidas. O painel custa o mesmo com 7 ou com 24 seções porque o cálculo é feito uma vez por mudança, para todas.

### No emulador, build release

Emulador `serenacash_api35` (Android 15, x86_64, no PC de desenvolvimento), build release da instalação isolada, banco cifrado, dados importados de um backup em claro gerado pelo teste acima. Um emulador não representa um celular; os números servem de ordem de grandeza.

| Medida | 1.000 | 10.000 | 50.000 |
|---|---|---|---|
| Importar o backup (uma transação) | 2,7 s | 4,8 s | 35,4 s |
| Abertura a frio até o primeiro quadro (`am start -W`, 3 execuções) | 1,6 a 2,0 s | 1,9 a 2,0 s | 2,0 s |
| Tela inicial com dados visível depois disso (sondagem a cada ~2,5 s) | até 2,7 s | até 3,3 s | até 5,1 s |
| Memória (PSS total) | 105 MB | 124 MB | 154 MB |
| Banco em disco | 1,7 MB | 8,5 MB | 32 MB |
| Salvar um lançamento até a tela estabilizar | não medido | não medido | cerca de 3 s |

Como foi medido: importação e conteúdo visível por sondagem da árvore de acessibilidade (cada leitura leva cerca de 2,5 s, então são limites superiores); abertura pelo `am start -W`; memória por `dumpsys meminfo`; salvar por capturas de tela sucessivas até duas iguais. Quadros por segundo e engasgos na rolagem não foram medidos: o `gfxinfo` do Android não enxerga os quadros do Flutter, e isso fica para `flutter run --profile` com DevTools em um aparelho.

Leitura: até 10.000 lançamentos (anos de uso) o app responde bem. Em 50.000 a abertura e cada gravação ficam perceptíveis, porque qualquer mudança recarrega o livro inteiro. É o limite conhecido da arquitetura atual; o remédio (recarga por tabela e paginação da lista) já estava registrado acima e não é necessário para a homologação.

