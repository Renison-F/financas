# Retorno da homologação física

Registro das 32 ocorrências e diretrizes que o usuário trouxe do teste no celular dele, entregues em 09/11/2026 no pacote `SerenaCash_Prompt_Mestre_Fable_5_2.md` com fotografias e capturas. Os IDs 001 a 032 são os do pacote e não mudam.

O estado do projeto está em `CHECKPOINT.md`. O roteiro de reteste no aparelho está em `14-CHECKLIST_APARELHO.md`.

## Build testada pelo usuário

| | |
|---|---|
| APK | `serenacash-0.1.0+2-homologacao-bae5d9f.apk` |
| Versão / build | 0.1.0 / 2 |
| Commit | `bae5d9f` |
| SHA-256 | `63c3ac06120f9cda29e43a0117e84acbe99cccfa2bcf1836b425cfb705726912` |
| Aparelho | Android com navegação de três botões (pelas fotos; modelo e versão não informados) |
| Período do teste | 05 a 09/11/2026, inclusive uma compra em supermercado |

## Linha de base da retomada (09/11/2026)

- Git: `refactor/flutter-serenacash` em `54c6c99`, igual ao remoto; `origin/main` em `e080f12`.
- `flutter test`: 399 aprovados, 0 falhas.
- CI: última execução 42035033218 (`bae5d9f`), aprovada.
- Repositório `Renison-F/financas`: público.
- Emulador `serenacash_api35` (o dos dados de homologação): não foi ligado nem alterado nesta rodada. As validações usaram um aparelho virtual separado, `serenacash_teste`, criado para isso.

## Estados usados

| Estado | Significado |
|---|---|
| `corrigido` | Código pronto e coberto por teste automatizado que passa. |
| `aprovado automatizado` | Corrigido e também conferido no aparelho virtual de testes. |
| `parcial` | Parte do pedido entregue; o que falta está dito no relatório do item. |
| `aguarda teste físico` | Depende de hardware ou serviço que o aparelho virtual não tem. Acompanha um dos estados acima. |
| `bloqueado` | Não pôde ser feito neste ambiente. |

Nenhum item está "aprovado no aparelho": isso só o reteste do usuário diz.

**Rodada de complemento (10/11/2026, build 0.2.0+4).** A primeira entrega desta rodada (build 0.2.0+3) deixou cinco ocorrências parciais (009, 017, 027, 028, 032) e lacunas em 018, 020 e 029–031. O usuário mandou completar tudo antes de retestar. Não há mais ocorrência com estado `parcial`. O que não pode ser decidido aqui, por depender do aparelho ou de terceiros, está em "O que continua fora do alcance deste ambiente", no fim.

## Matriz 001–032

| ID | Relato | Prioridade | Estado | Commit |
|---|---|---|---|---|
| 001 | Opção do menu "Adicionar" atrás da barra do Android | P1 | aprovado automatizado · aguarda teste físico | `cd9b7e8` |
| 002 | Despesa já digitada ir para o cartão sem recomeçar | P2 | corrigido | `cd9b7e8` |
| 003 | Criar conta dentro da transferência | P2 | aprovado automatizado | `cd9b7e8` |
| 004 | Calendário no vencimento | P2 | aprovado automatizado | `cd9b7e8` |
| 005 | Calendário no primeiro vencimento do empréstimo | P2 | corrigido | `cd9b7e8` |
| 006 | Outros sistemas de empréstimo | P2 | corrigido | `870747a` |
| 007 | Dívida sem parcelas nem prazo | P1/P2 | corrigido | `870747a` |
| 008 | Gráfico de despesas por categoria na tela inicial | P2 | aprovado automatizado | `050f043` |
| 009 | Interface neutra demais | P2 | aprovado automatizado | `a761971`, `764476e`, `96668f9` |
| 010 | Assistente: ranking de gastos e onde economizar | P1 | corrigido | `edfe1e7` |
| 011 | Biometria não habilita | P1 | aprovado automatizado · aguarda teste físico | `5db0075`, `9b31f7c` |
| 012 | Orçamento e meta de 2026 em 2025 | P1 | aprovado automatizado | `ddafeeb` |
| 013 | Relatório por categoria sem gráfico circular | P2 | corrigido | `050f043` |
| 014 | Leitor de etiquetas abre outra câmera | P1 | aprovado automatizado · aguarda teste físico | `20ac26f`, `c774347` |
| 015 | OCR escolhe slogan como nome | P1 | corrigido · aguarda teste físico | `20ac26f` |
| 016 | OCR escolhe preço errado | P1 | corrigido · aguarda teste físico | `20ac26f` |
| 017 | Apontar nome e preço na imagem | P2 | corrigido · aguarda teste físico | `20ac26f`, `228ef04` |
| 018 | Código lido tratado como falha | P1 | corrigido · aguarda teste físico | `20ac26f`, `84b1321` |
| 019 | Foto da gôndola como comprovação | P2 | corrigido | `20ac26f`, `211c06e` |
| 020 | Conferência com o cupom fiscal | P2 | corrigido · aguarda teste físico | `20ac26f`, `878d992` |
| 021 | Cursor salta ao corrigir o nome | P1 | corrigido · aguarda teste físico | `cd9b7e8` |
| 022 | Itens por voz | P2 | corrigido · aguarda teste físico | `814b5bb` |
| 023 | Foto do produto ligada ao preço | P2 | corrigido | `20ac26f` |
| 024 | Histórico e evolução de preços | P2 | corrigido | `449e3db` |
| 025 | Teclado e barras encobrem campos | P1/P2 | aprovado automatizado · aguarda teste físico | `cd9b7e8` |
| 026 | Tirar "mês sereno", "agitado" e parecidos | regra global | corrigido | `870747a`, `edfe1e7`, `a761971` |
| 027 | Tela inicial analítica e modular | P2 | aprovado automatizado | `0f3e994`, `96668f9` |
| 028 | Refinar a identidade da tela inicial | regra global | aprovado automatizado | `0f3e994`, `a761971`, `96668f9` |
| 029 | Gastos diários e limites | P2 | aprovado automatizado | `0f3e994`, `b1a0a7e` |
| 030 | Receitas diárias e evolução dia a dia | P2 | aprovado automatizado | `0f3e994`, `b1a0a7e` |
| 031 | Metas diárias de gasto e de economia | P2 | aprovado automatizado | `0f3e994`, `b1a0a7e` |
| 032 | Personalização de cor, tema e aparência | P2 | aprovado automatizado | `a761971`, `764476e` |

As evidências do usuário ficam em `docs/SerenaCash_Fable_5_2_Pacote_Com_Referencias/referencias/` na máquina dele. A pasta não foi incluída no controle de versão: o repositório é público e ela traz capturas de um aplicativo de terceiros. As fotos de etiqueta também não foram commitadas; o que entrou no repositório foi a leitura do OCR sobre elas (`test/fixtures/labels/*.json`, só texto e posições).

## Achados que as evidências mostram além dos 32

| ID | O que foi visto | Estado | Commit |
|---|---|---|---|
| 002-B | O aviso "Escolha duas contas diferentes" continuava na tela depois de trocar de "Transferência" para "Despesa" | corrigido | `cd9b7e8` |
| 003-B | Com uma conta só, o campo "Para" ficava vazio sem explicação | corrigido | `cd9b7e8` |
| 005-B | Formulário de empréstimo preenchido ainda mostrava "Preencha nome, valor, taxa…"; e a mensagem ficava no fim de um formulário longo, fora de vista | corrigido | `cd9b7e8`, `870747a` |
| N-01 | Ligar a biometria ou o PIN trancava o app na mesma hora, pedindo a identificação duas vezes seguidas | corrigido | `5db0075` |
| N-02 | Desligar a confirmação do aparelho não pedia confirmação | corrigido | `9b31f7c` |
| N-03 | O diálogo de permissão da câmera reiniciava o leitor e terminava em "Câmera indisponível" (achado no aparelho virtual) | corrigido | `c774347` |
| N-04 | O backup levava as compras e deixava para trás fotos e cupom | corrigido | `211c06e` |
| N-05 | A projeção de um mês que ainda não começou partia do saldo de hoje, ignorando o que está previsto até lá (achado ao criar a navegação por mês) | corrigido | `96668f9` |
| N-06 | O gráfico de evolução cortava o rótulo do mês com texto muito grande | corrigido | `96668f9` |
| N-07 | Foto de cupom escolhida da galeria podia levar posição GPS e outros metadados para o banco e os backups | corrigido | `215bba3` |
| N-08 | Lembretes só cobriam contas a pagar; valores a receber, faturas e metas com data ficavam sem aviso | corrigido | `b1a0a7e` |

## Relatório por ocorrência

### 001 — Opção do menu "Adicionar" atrás da barra do Android
- **Causa:** a folha modal do Flutter só reserva o topo e as laterais; a margem de baixo é responsabilidade do conteúdo, e a folha não a aplicava. Com a barra de três botões (48 dp, desenhada sobre o app no Android 15), a sexta opção ficava atrás dela.
- **Correção:** `showSSheet` (`lib/ui/components/sheets.dart`) passou a ser o único caminho para abrir folhas: reserva a barra do sistema e o teclado e deixa o conteúdo rolar. As seis folhas do app usam esse componente.
- **Testes:** `physical_return_test.dart` (3 tamanhos de tela e fonte até 1,6; folha de confirmação). No aparelho virtual com três botões, captura `E:\SerenaCash\screens\etapa5\a01-adicionar-tres-botoes.png`.
- **Estado:** aprovado automatizado · aguarda teste físico.

### 002 — Despesa para o cartão sem recomeçar
- **Causa:** trocar de "Despesa" para "Cartão" apagava a categoria, e não havia escolha de forma de pagamento dentro da despesa. O aviso de transferência (002-B) ficava porque a mensagem só era limpa na tentativa seguinte de salvar.
- **Correção:** campo "Forma de pagamento" (conta ou cartão de crédito) na despesa; a troca preserva valor, descrição, categoria, data e opções. Uma despesa prevista que vai para o cartão não vira conta a pagar. Qualquer edição limpa o aviso anterior.
- **Regra financeira:** a mesma do lançamento "Cartão": não baixa a conta na compra; a fatura paga é que baixa.
- **Testes:** três em `physical_return_test.dart` (inclui saldo da conta inalterado).
- **Estado:** corrigido.

### 003 — Criar conta dentro da transferência
- **Correção:** "Nova conta" em "De" e em "Para" (e "Novo cartão" na compra no cartão). O formulário de conta devolve a conta criada, que volta selecionada no lado certo; cancelar não cria nada e não perde o rascunho. Com uma conta só, o campo "Para" explica que falta a conta de destino.
- **Testes:** `physical_return_test.dart` (cadastrar a conta não gera lançamento; saldos depois da transferência). Visto no aparelho virtual.
- **Estado:** aprovado automatizado.

### 004 e 005 — Calendário
- **Correção:** `DateField` ganhou o botão de calendário, no tema do app e em português, mantendo os atalhos e a digitação. Vale para todos os campos de data: lançamento, conta, cartão, metas, empréstimo. Datas passadas continuam aceitas; data inexistente é recusada.
- **Testes:** `physical_return_test.dart` (cancelar não altera o formulário; 29/02/2028 aceito; 30/02 recusado). Captura `a06-calendario.png`.
- **Estado:** 004 aprovado automatizado; 005 corrigido.

### 006 — Outros sistemas de empréstimo
- **Correção:** além de Price e SAC, sistema americano (juros a cada período, principal na última parcela) e pagamento único (juros compostos no vencimento). A taxa pode ser informada ao mês, ao ano efetiva ou ao ano nominal: o cálculo usa a mensal equivalente e guarda o que foi digitado. O empréstimo pode ser "eu devo" ou "devem a mim"; o concedido movimenta a conta no sentido certo e conta como ativo.
- **Fórmulas:** americano, juro por período = principal × i; pagamento único = principal × (1 + i)ⁿ; ao ano nominal = taxa ÷ 12; ao ano efetiva = (1 + taxa)^(1/12) − 1.
- **Não incluído:** correção monetária, IOF, seguros além da tarifa mensal já existente, amortização híbrida.
- **Testes:** `loans_flex_test.dart`; migração v3 → v4 em `migration_test.dart`.
- **Estado:** corrigido.

### 007 — Dívida sem parcelas nem prazo
- **Correção:** modalidade "Quando der": sem número de parcelas e sem vencimento; nenhuma conta prevista é criada. Pagamentos de qualquer valor em qualquer data, extrato com o que cada um cobriu, botão para quitar pelo saldo exato. Pagamento maior que o saldo é recusado, com o valor que quita.
- **Juros:** opcionais (sem, simples, compostos). Convenção escrita na tela: mês de 30 dias, proporcional aos dias, a partir da data de origem; o pagamento cobre primeiro o juro e depois o principal. Nenhuma multa é aplicada.
- **Aceite do briefing:** R$ 40.000 sem juros, R$ 500 → R$ 39.500; R$ 2.000 → R$ 37.500. Coberto no domínio, no controlador e na tela.
- **Estado:** corrigido.

### 008 e 013 — Gráfico circular por categoria
- **Correção:** um componente (`DonutChart`) alimentado pela mesma consulta na tela inicial e no relatório. Percentuais somam exatamente 100,0%; categorias pequenas vão para "Outras", que mostra o que tem dentro; mês sem despesa não desenha anel. Cada fatia é também uma linha de texto, e o anel tem descrição para leitor de tela.
- **Testes:** `shares_test.dart`, `physical_return_test.dart` (97,8% e 2,2% para R$ 45 e R$ 1).
- **Estado:** 008 aprovado automatizado; 013 corrigido.

### 009, 028 e 032 — Cor, identidade e personalização
- **Paletas:** seis prontas (petróleo, azul, verde, terracota, grafite, vinho) e uma **feita pelo usuário** no editor de tema: cor principal e cor de destaque, por matiz, saturação, luminosidade ou código `#RRGGBB`, com prévia em claro e escuro, desfazer e voltar ao padrão.
- **Trava de contraste:** uma cor que não dá leitura é recusada, com o contraste medido na tela (mínimo 4,5:1 para texto e 3:1 para ícones e gráficos) e um botão que leva ao tom legível mais próximo, mantendo o matiz. Todos os tons derivados (contêineres, painel-resumo, tema escuro) são levados a 4,5:1 por construção; o teste cobre dez cores difíceis, entre elas branco, preto, amarelo vivo e cinza médio, nos dois temas.
- **Sinal financeiro:** receita, despesa, alerta, texto e superfícies são os mesmos em qualquer paleta, inclusive na personalizada.
- **Estilo dos cartões:** plano, com contorno, com sombra ou com cor. **Gráficos:** detalhados ou compactos. **Densidade:** confortável ou compacta.
- **Tipografia:** tamanho do texto padrão, grande ou maior, somado ao tamanho de fonte do Android e com teto de duas vezes o tamanho de projeto. A família tipográfica é a da marca e não é escolhida pelo usuário.
- **Movimento:** "como no aparelho" ou "reduzido"; reduzido, telas e folhas aparecem sem deslizar. A opção de acessibilidade do aparelho também passa a ser respeitada nas transições, o que antes não acontecia.
- **Alcance:** tudo viaja no tema, então vale em todas as telas, folhas, calendário, leitor e tela de bloqueio. "Restaurar aparência padrão" desfaz tudo e mantém as cores personalizadas disponíveis.
- **Identidade da tela inicial (028/009):** marca de cor por indicador na visão geral, linha do tempo com dois modos, cabeçalho com mês navegável e cartões em dois tamanhos. A estrutura aprovada antes (painel "pode gastar", ações rápidas, cartões) foi mantida de propósito.
- **Testes:** `test/app/theme_editor_test.dart` (32) e `appearance_test.dart`; tela de 320 pt com texto a 1,6 × "maior" sem estouro.
- **Estado:** aprovado automatizado. No aparelho: conferir legibilidade e gosto.

### 010 — Assistente
- **Causa:** qualquer pergunta com a palavra "mês" era lida como pedido de resumo do mês, antes de chegar à regra do ranking; "economizar" não tinha regra, e um erro de digitação derrubava a pergunta.
- **Correção:** ranking por categoria com valor, percentual, número de lançamentos e período; "onde economizar" com o que mais pesa, orçamentos acima do previsto, o que subiu em relação ao mês anterior e gastos recorrentes, sem julgar despesas; tolerância a uma ou duas letras erradas; "mês passado"; exemplos conforme os dados quando a pergunta não é entendida. Continua local e determinístico: nenhuma IA externa.
- **Aceite:** "No que mais gastei?" → Alimentação R$ 45,00 (97,8%) e Compras R$ 1,00 (2,2%), total R$ 46,00.
- **Estado:** corrigido.

### 011 — Biometria
- **Causa:** `MainActivity` estendia `FlutterActivity`. O plugin `local_auth` só abre o prompt a partir de uma `FragmentActivity` e devolvia erro antes de mostrar qualquer coisa. Falhava em qualquer aparelho, com ou sem digital.
- **Correção:** `FlutterFragmentActivity`; temas nativos com base AppCompat; mensagens por motivo (cancelado, nada cadastrado, sem sensor, bloqueio temporário, indisponível), com atalho para as configurações de segurança do Android. Ligar o bloqueio não tranca mais o app na hora (N-01) e desligar pede confirmação (N-02).
- **Validação no aparelho virtual, com digital cadastrada:** o prompt do Android abre; a digital certa ativa; ao voltar do segundo plano o app pede a confirmação; cancelar não gera erro; a digital errada é recusada; a certa desbloqueia.
- **Estado:** aprovado automatizado · aguarda teste físico.

### 012 — Planejamento retroativo
- **Causa:** o orçamento recorrente não tinha início: valia para qualquer mês, inclusive anteriores à sua criação. A tela anual listava todas as metas ativas, em qualquer ano.
- **Correção:** orçamento recorrente com `validFrom` e `validUntil`. Mudar o limite abre um período novo; excluir encerra o período em vez de apagar a história. Metas aparecem a partir do ano em que existem; ano passado mostra o que foi guardado, sem sugestão; o valor mensal usa o prazo real. Ano sem registros diz que não há registros.
- **Migração v1 → v2:** orçamentos existentes começam no mês em que foram criados.
- **Validação da atualização:** ver "Atualização sobre a versão anterior", abaixo.
- **Estado:** aprovado automatizado.

### 014 — Leitor integrado
- **Causa:** a leitura de etiqueta chamava a câmera do sistema (`image_picker`), outra tela e outro aplicativo.
- **Correção:** câmera dentro do app (plugin `camera`), com foco por toque, zoom por pinça, lanterna, total do carrinho à vista, uma câmera por vez e liberação ao sair de vista. "Adicionar e ler a próxima" volta ao leitor em um toque.
- **Validação no aparelho virtual:** permissão negada e concedida; prévia; captura; 20 capturas seguidas sem erro no logcat, memória de 532 MB para 556 MB (build debug) e nenhuma foto esquecida no cache.
- **Estado:** aprovado automatizado · aguarda teste físico (câmera real, aquecimento, foco).

### 015 e 016 — Entender a etiqueta
- **Causa:** o nome era a linha de texto mais comprida (por isso o slogan) e o preço era o primeiro valor reconhecido, sem distinguir preço por quilo, atacado ou letras pequenas.
- **Correção:** `analyzeLabel` (`lib/domain/shopping/label.dart`) usa a posição e a altura de cada linha lida. Preço em destaque é o do item; "preço por quilo, litro ou unidade" é impressão de comparação e não pode ser escolhido por engano; "atacado" só vale a partir da quantidade mínima; a descrição é o texto logo acima do preço. Leitura duvidosa exige conferência explícita antes de entrar no carrinho.
- **Gabarito, com a leitura real do OCR nas fotos do usuário:**

| Caso | Etiqueta | Nome | Preço de varejo |
|---|---|---|---|
| OCR-01 | Pá de lixo, R$ 16,99 | certo | certo |
| OCR-02 | Papel higiênico, R$ 13,99 | certo | certo |
| OCR-03 | Água, R$ 9,99 varejo e R$ 9,49 atacado | certo | certo; atacado guardado com "a partir de 3" |
| OCR-04 | Vela, R$ 11,99 | certo | **o motor leu "1,99"**; o app não acerta, mas exige conferência |
| OCR-05 | Cookies, R$ 4,99 | certo | certo; pede conferência porque veio com caracteres soltos |
| OCR-06 | Pão, R$ 9,99 | certo | certo |
| OCR-07 | Abacaxi, R$ 8,99 | certo | certo |
| extra | Toalha de papel, R$ 8,99 | certo | certo |

  Resultado: nome 8 de 8; preço de varejo 7 de 8; na que falhou, o valor não é oferecido como confiável. São oito fotos de uma loja: não é uma medida de precisão.
- **Limite conhecido:** quando o motor erra um dígito na própria leitura (OCR-04), o app não tem como saber o valor certo; o que ele garante é pedir a conferência com a foto ao lado.
- **Estado:** corrigido · aguarda teste físico.

### 017 — Apontar nome e preço na imagem
- **Entregue:** a revisão mostra a foto com cada linha lida marcada; tocar em uma linha a usa como nome ou como preço. Além disso, "Marcar uma área para reler": o usuário arrasta um retângulo sobre a foto, ajusta pelos cantos ou move, e pede a leitura só daquele trecho.
- **Como funciona:** o trecho é recortado da foto original, ampliado até três vezes (letra pequena lê melhor), lido pelo OCR do aparelho e descartado. A foto guardada como evidência não muda. No modo Nome, o texto lido vira a descrição. No modo Preço, um valor é usado; vários são oferecidos para escolha; nenhum é dito junto com o texto lido. Nada é preenchido quando nada é lido.
- **Gesto:** a marcação começa no primeiro toque, sem rolar a lista nem mover a foto. Para letra pequena, ampliar a foto antes de marcar.
- **Testes:** `test/app/region_read_test.dart` (7): recorte real sobre uma imagem, ordem de leitura, valores, arrasto, mover e redimensionar, falhas.
- **Não validado aqui:** a qualidade da releitura em etiquetas reais, que depende do OCR do aparelho.
- **Estado:** corrigido · aguarda teste físico.

### 018 — Código de barras
- **Correção:** qualquer código decodificado volta para a compra. Mensagens distintas: produto do cadastro; código lido e ainda não cadastrado (o produto fica cadastrado com ele ao confirmar); código que não fecha como EAN/UPC (guardado como lido). QR Code só é usado para a chave do cupom, como texto; nenhum link é aberto.
- **Catálogo externo, opcional:** em Configurações há "Consultar um catálogo aberto de produtos pela internet", **desligado por padrão**. Ligado, um código que não está no cadastro é consultado no Open Food Facts: só o número do código é enviado; volta uma sugestão de nome (marca e tamanho, quando houver) para conferir. Preço nunca vem do catálogo. "Não está no catálogo" e "não foi possível consultar" são mensagens diferentes. Depois de confirmado, o produto fica no cadastro local e não é consultado de novo. Códigos de balança e códigos inválidos nunca são enviados.
- **Verificação:** o formato da resposta foi conferido contra o serviço real em 10/11/2026 (produto existente e código inexistente). O app não foi exercitado com rede no aparelho virtual.
- **Testes:** `test/app/catalog_lookup_test.dart` (5).
- **Estado:** corrigido · aguarda teste físico.

### 019 e 023 — Fotos como evidência
- **Correção:** a foto da etiqueta e a foto do produto ficam no banco cifrado, com SHA-256, data, dimensões e o que foi lido. O preço lido fica ao lado do preço confirmado. Tela "Evidências" por compra, com ampliar e apagar. As fotos entram no backup cifrado e são conferidas na restauração.
- **Estado:** corrigido.

### 020 — Cupom fiscal
- **Correção:** fotografar ou escolher a foto do cupom; as linhas são lidas no aparelho, pareadas com o carrinho e comparadas. Par sólido com preço diferente vira "diferença"; par fraco vira "suspeita" e pede decisão; o usuário pode trocar ou desfazer um par. O preço do carrinho não é reescrito.
- **Caso da vela:** gôndola R$ 11,99, cupom R$ 14,99 → diferença de R$ 3,00, coberto por teste.
- **Cupom e despesa:** a tela mostra a soma dos itens lidos ao lado da despesa registrada. Se diferem, o usuário pode "Atualizar a despesa pelo cupom": vê os dois valores, confere ou corrige o total e confirma. O valor anterior fica anotado na despesa. O cupom nunca altera a despesa sozinho; lançamento parcelado, recorrente ou pago em parte não é tocado.
- **Privacidade:** a foto é guardada sem metadados (posição GPS, aparelho, data); os dados da imagem não são recodificados.
- **Testes:** `receipt_test.dart`, `shopping_review_test.dart`, `test/app/receipt_adjust_test.dart` (4), `test/data/image_metadata_test.dart` (4).
- **Não testado:** leitura de um cupom real fotografado (os testes usam o texto das linhas). Consulta da NFC-e pela chave de acesso não existe: exigiria serviço de terceiros.
- **Estado:** corrigido · aguarda teste físico.

### 021 — Cursor
- **Causa:** o campo de nome recebia um controlador novo a cada reconstrução da tela, com o cursor no fim; como cada tecla reconstrói a tela, o cursor saltava a cada letra.
- **Correção:** a revisão do item virou uma tela própria com um controlador por campo, criado uma vez.
- **Testes:** inserção no meio, apagar no meio, região de composição do teclado e alterações posteriores de preço e quantidade.
- **Estado:** corrigido · aguarda teste físico (teclado Samsung e Gboard).

### 022 — Voz
- **Correção:** "Falar o item": a folha explica antes de abrir o microfone que nenhum áudio é gravado; a transcrição aparece enquanto é ouvida; quando o valor pode ser o total ou o preço de cada unidade, o app pergunta. O resultado passa pela mesma revisão dos outros itens.
- **Não testado:** o reconhecimento de fala em si, que depende do aparelho.
- **Estado:** corrigido · aguarda teste físico.

### 024 — Histórico de preços
- **Correção:** tela "Histórico de preços": por produto, cada compra com loja, preço e diferença para a compra anterior na mesma unidade; menor e maior preço. O texto diz que é a variação observada daquele produto, não inflação.
- **Estado:** corrigido.

### 025 — Teclado e barras
- **Causa:** o painel de confirmação ficava preso ao rodapé com altura fixa de 62% da tela; com o teclado aberto subia para baixo da barra de status, e o botão de adicionar ficava cortado.
- **Correção:** a revisão é uma tela rolável com a ação fixa acima do teclado e da barra do sistema; as ações da compra ficam dentro da área segura.
- **Estado:** aprovado automatizado · aguarda teste físico.

### 026 — Linguagem
- **Correção:** "Mês sereno/agitado" e parecidos saíram do orçamento, do assistente, das boas-vindas, das regras e da ajuda. Um teste varre todos os textos em português e inglês e falha se uma dessas expressões voltar.
- **Estado:** corrigido.

### 027 — Tela inicial analítica
- **Cartões:** saldo do período, visão geral, controle diário, discriminação por estado, despesas por recorrência e saúde financeira por critérios, sem nota, além dos 24 que já existiam (evolução, economia mensal, categorias, vencimentos e outros). Estado vazio em uma linha, nunca zeros.
- **Mês navegável:** setas no cabeçalho mostram o mês anterior e o seguinte. É um olhar, não uma configuração: nada é salvo e o app sempre abre no presente. Fora do mês atual, um aviso diz que "pode gastar" e os saldos das contas são sempre os de hoje.
- **Linha do tempo:** o cartão de saldo tem duas visões (saldo; entradas e saídas). Tocar ou arrastar sobre o gráfico escolhe um dia e mostra saldo, recebido, gasto, a receber e a pagar; "Ver lançamentos do dia" abre os lançamentos daquele dia e permite lançar nele. Passado é linha cheia e barra cheia; previsto é tracejado e barra contornada. Para leitor de tela, o gráfico é um controle que anda dia a dia.
- **Passado, presente e futuro com nomes diferentes:** inicial, saldo hoje, previsto no fim; em mês passado, inicial, saldo final e variação; em mês futuro, tudo dito como previsto.
- **Tamanho dos cartões:** cada cartão pode ficar em "tamanho reduzido" (uma linha, com o número principal quando existe) em "Personalizar tela inicial". A escolha é salva com o layout.
- **Quem já personalizou a tela inicial** mantém a ordem que escolheu; os cartões novos ficam em "Personalizar tela inicial".
- **Testes:** `test/app/home_timeline_test.dart` (7).
- **Estado:** aprovado automatizado.

### 029, 030 e 031 — Controle diário
- **Gastos do dia:** hoje, ontem, mês, as duas médias nomeadas e os mesmos dias do mês anterior, para todos os gastos ou para **uma categoria** (com as subcategorias).
- **Comparações:** últimos 7 dias, 7 dias anteriores e o mesmo dia da semana passada, sempre períodos iguais; onde não há registro, a tela diz "sem registro" em vez de zero. Também a soma do mês se cada dia restante custar a média dos dias até aqui, apresentada como conta sobre o passado, não como previsão.
- **Fluxo de caixa:** por **conta** ou de todas, de **qualquer mês** (setas), em três visões: realizado, previsto, realizado + previsto. Com uma conta escolhida, compras no cartão ficam de fora, e a tela explica por quê.
- **Limites:** geral, **por categoria** e **só em dias da semana escolhidos**, cada um com vigência, histórico e encerramento próprios; sobra de um dia só passa ao seguinte se o usuário ligar. **Simulação:** ao digitar um valor, a tela diz quanto ele soma no mês e em quantos dos dias já passados o gasto teria ficado dentro dele; nada é gravado.
- **Meta de economia:** pode contar só o que for guardado em uma meta escolhida. Gastar menos que o limite continua não sendo economia. Simulação do valor no mês e em 365 dias.
- **Avisos:** quando um limite é ultrapassado, a tela inicial mostra o fato e o valor, sem julgamento; pode ser desligado.
- **Regras:** a soma dos dias fecha com o total do mês; as partes por categoria somam o todo; compra no cartão conta no dia da compra.
- **Aceite do briefing:** limite R$ 100, gasto R$ 35, disponível R$ 65; meta R$ 20, guardado R$ 15, pendente R$ 5.
- **Lembretes (onda D, item 6):** contas a pagar e parcelas, valores a receber, faturas de cartão em aberto e metas com data. Um aviso por compromisso na véspera e outro no dia, sem duplicar; cada tipo pode ser silenciado em Configurações.
- **Testes:** `daily_control_test.dart` (13) e `test/app/daily_complete_test.dart` (12).
- **Estado:** aprovado automatizado. Avisos do sistema (notificações) só no aparelho.

## Atualização sobre a versão anterior

Ensaio feito em 10/11/2026 no aparelho virtual `serenacash_teste` (Android 15, navegação de três botões), separado do emulador de homologação, que não foi tocado.

1. Instalado o APK que está no celular do usuário (`serenacash-0.1.0+2-homologacao-bae5d9f.apk`). Dados fictícios criados: uma conta com R$ 5.480,50, uma despesa de R$ 45,00 e um orçamento recorrente de R$ 850,00.
2. Instalado por cima, sem desinstalar, o APK 0.2.0+3 (`adb install -r`). A instalação foi aceita: mesmo Application ID, mesmo certificado (`e7c911bb…16e5`), código de versão 3 maior que 2.
3. O app abriu em cerca de 1,5 s, passou as três migrações do banco (versão 1 para 4) e mostrou os mesmos dados: saldo R$ 5.435,50, a despesa e o orçamento. Os cartões novos da tela inicial apareceram. No planejamento anual, 2025 ficou vazio ("Nenhum lançamento e nenhum orçamento em 2025.", "Nenhuma meta existia em 2025.").
4. O APK final (`f1b3b47`) foi instalado sobre esse mesmo app e abriu pelo ícone, sem erro no logcat.

Capturas: `E:\SerenaCash\screens\etapa5\` (`c01` a `c03`, `d01`).

O que o ensaio **não** prova: a atualização no celular do usuário, com os dados reais dele. O caminho é o mesmo (mesmo certificado, mesmas migrações, cobertas também por `test/data/migration_test.dart`), mas o resultado só existe depois do teste J01 do checklist. Antes de instalar, exportar um backup cifrado pela versão atual. Não há volta: a versão 0.1.0 não abre um banco já migrado.

## Decisões de produto para confirmar

Todas têm um padrão conservador já implementado; nenhuma impede o uso.

| Assunto | O que foi adotado | O que confirmar |
|---|---|---|
| Juros de dívida informal | Opcionais; mês de 30 dias, proporcional aos dias, juros antes do principal | Se a convenção atende |
| Cupom e despesa registrada | O cupom nunca altera sozinho; o usuário pode atualizar, conferindo o total | — |
| Catálogo externo | Open Food Facts, só com a opção ligada; desligado por padrão | Se a opção deve existir na versão de loja (exige citar na política de privacidade) |
| Voz | Serviço de voz do Android, com aviso de que pode usar a internet | Exigir reconhecimento só no aparelho? |
| Previsto e contas atrasadas | "Previsto" soma o que está registrado de amanhã em diante; uma conta vencida e não paga não entra | Se contas atrasadas devem reduzir o previsto |
| Tipografia | Tamanho escolhido pelo usuário; família fixa da marca | — |
| Privatização do repositório | Não executada (sem credencial); passos no `CHECKPOINT.md` | Executar no GitHub |

## O que continua fora do alcance deste ambiente

Não são itens parciais: são coisas que só o aparelho físico ou terceiros podem decidir.

- Tudo o que depende do celular do usuário: câmera, foco e aquecimento; etiquetas e códigos em loja; cupom fotografado; voz; digital; teclado Samsung; barra de três botões; notificações.
- iOS: nada foi compilado nem testado (sem macOS).
- Segurança: MobSF, análise dinâmica, root e instrumentação.
- Consulta da NFC-e pela chave de acesso e Open Finance: dependem de serviços de terceiros.
- Lojas, assinatura definitiva e política de privacidade publicada: dependem do cliente.

