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

## Rodada 0.2.0+3 (ocorrências 014 a 025)

O que as seções acima descrevem como "captura foto (`image_picker`)" e "contagem por sessão" continua valendo só onde não foi citado aqui.

- **Leitor integrado** (`scan_screen.dart`): etiqueta e foto usam o plugin `camera`, dentro do app; código de barras continua no `mobile_scanner`. Uma câmera por vez, liberada ao sair de vista; foco por toque, zoom por pinça, lanterna e total do carrinho no topo.
- **Entender a etiqueta** (`domain/shopping/label.dart`, `analyzeLabel`): usa posição e altura de cada linha do OCR. Separa preço do item, preço por medida (só comparação), preço de atacado (com quantidade mínima) e preço unitário de embalagem. Abaixo de 0,7 de confiança, ou com mais de um candidato plausível, a revisão é obrigatória.
- **Revisão do item** (`item_review_screen.dart`): foto com as linhas lidas tocáveis (modo Nome ou Preço), candidatos de preço, atacado opcional, foto do produto. Nada entra no carrinho sem confirmação.
- **Código de barras**: três estados distintos: produto do cadastro local, código lido sem cadastro, código fora do padrão. Não há catálogo externo; o cadastro se forma com o uso.
- **Evidências** (`ShoppingEvidence`): a foto fica dentro do banco cifrado, com SHA-256, limite de 8 MB por imagem e o texto lido. Entra no backup cifrado.
- **Cupom fiscal** (`domain/shopping/receipt.dart`, `receipt_screen.dart`): foto ou galeria, OCR, leitura das linhas e pareamento com o carrinho; diferenças e suspeitas em destaque; par trocável à mão. O cupom **não** altera a despesa registrada (decisão em aberto, ver `15`).
- **Voz** (`voice.dart`, `voice_sheet.dart`): transcrição pelo serviço de voz do Android; o app não grava áudio. Valor ambíguo ("29 reais" para 5 kg) é perguntado.
- **Histórico de preços** (`/shopping/prices`): evolução por produto e loja, comparando só a mesma unidade.

Gabarito com a leitura real do OCR nas oito fotos do usuário: nome 8/8, preço do item 7/8; a que falhou (o OCR leu outro valor) cai na revisão obrigatória. Esse número descreve essas oito fotos, não a precisão em geral.

Não validado em loja: câmera real, vinte leituras seguidas no aparelho do usuário, cupom fotografado, voz.

## Complemento da build 0.2.0+4

- **Reler uma área da foto (017):** `data/ocr/region_reader.dart` recorta o trecho marcado da foto original (`cropImage`, ampliação de até 3×), grava um arquivo temporário, roda o OCR e apaga o arquivo. `features/shopping/region_layer.dart` é o retângulo: desenhado por arrasto, movido e ajustado pelos cantos, guardado em frações da foto. O reconhecedor de gesto aceita o toque de imediato, para a lista não rolar.
- **Catálogo aberto, opcional (018):** `data/catalog/product_catalog.dart`. Porta `ProductCatalog`, implementação `OpenFoodFactsCatalog` com `dart:io` (sem dependência nova), HTTPS, tempo limite de 6 s, resposta de no máximo 64 KB, sem seguir redirecionamento. Só dígitos de 8, 12, 13 ou 14 posições são enviados. Três resultados: encontrado, não encontrado, falha. Controlado por `UserPrefs.productLookup`, desligado por padrão. Os dados do Open Food Facts têm licença ODbL; o app mostra a origem em cada sugestão.
- **Cupom e despesa (020):** `AppController.adjustAmountFromReceipt` e `canAdjustFromReceipt`. Só por ação do usuário, com o total conferido; anota o valor anterior.
- **Metadados das fotos:** `data/media/image_metadata.dart` remove EXIF, XMP, IPTC e comentários de JPEG sem recodificar a imagem; mantém só a orientação. Vale para evidências e anexos.
