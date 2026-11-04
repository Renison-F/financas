# 07 — Listas de compras e assistente de supermercado

## Domínio (Dart, `lib/domain/shopping`, equivalente ao TS — ver `02`)

- Unidades (`un, kg, g, L, mL, pct, dz, cx, m`), normalização por casas decimais e conversão para base.
- Carrinho: `lineTotal` (pesados arredondam half-up como balança; promoções leve X pague Y só em contáveis; desconto nunca negativa), `cartTotals` (estado sereno/atenção/agitado contra o orçamento, linhas de baixa confiança), `addLine` (mescla duplicados contáveis ao mesmo preço).
- Códigos: EAN-13/8, UPC-A/E, GS1 de balança (valor embutido nunca assumido), QR da NFC-e (chave de acesso).
- Etiquetas: `parsePriceTag` interpreta linhas de OCR com candidatos, "de/por", preço por kg, parcelas, código interno, confiança e avisos.
- Listas: estimativa soma só itens com preço; agrupamento por categoria; duplicar/desmarcar.
- Sessão: eventos, planejado × realizado, finalização gera observações de preço e **sugere** a despesa (`externalRef = shopping:<id>`).

## UI (lib/features/shopping)

| Tela | Rota | Comportamento |
|---|---|---|
| Aba Compras | `/shopping` | sessão em andamento, listas (estimativa e itens sem preço), compras anteriores |
| Nova lista | `/shopping/list/new` | nome, supermercado, orçamento; limite do plano grátis |
| Lista | `/shopping/list/:id` | itens por categoria, unidades, quantidade, preço estimado (histórico preenche), marcar, editar/remover, duplicar, excluir, iniciar compra |
| Sessão | `/shopping/session` | total-herói, orçamento com marca de progresso (itens da lista comprados ÷ itens), itens da lista com um toque, manual/etiqueta/código, folha de confirmação obrigatória (nome, preço, quantidade, unidade, promoção, subtotal), remover, finalizar, resumo, registrar despesa única |
| Câmera | `/shopping/scan` | `mobile_scanner` (EAN/UPC/Code128/QR) com lanterna e debounce; "Etiqueta" captura foto (`image_picker`) e roda OCR por `OcrService` (ML Kit Latin, só Android/iOS); permissão negada e câmera indisponível tratadas; fallback "informar manualmente" |

Regras preservadas: nada entra no carrinho sem confirmação; código de barras identifica produto, não preço; OCR com confiança < 0,75 marca "confira"; variação ≥ 10 % contra o último preço vira aviso; despesa nunca é registrada duas vezes (idempotência por `externalRef` no repositório).

## Limites e plano

OCR: `freeLimits.ocrScansPerMonth` (30) no plano grátis (contagem por sessão nesta versão; contagem mensal persistida é melhoria registrada), ilimitado no Plus. Histórico de preços por loja e listas compartilhadas são recursos Plus.

## Testes

`test/domain/shopping_test.dart` (68 casos de fixture) e `test/app/shopping_flow_test.dart` (lista → sessão → despesa; leitura simulada de código e etiqueta via `scanResultProvider`). A câmera real não roda em testes; `OcrService` é substituído por `UnavailableOcr`.
