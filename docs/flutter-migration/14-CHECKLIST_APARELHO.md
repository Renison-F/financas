# 14 — Checklist de homologação no aparelho Android

Roteiro para testar o SerenaCash em um celular de verdade. Nada aqui foi executado em aparelho físico: todos os campos de resultado estão em branco de propósito.

Use só dados fictícios. Anote o que aconteceu em "Resultado obtido" e marque a situação: **A** aprovado, **R** reprovado, **B** bloqueado (não deu para testar), **N** não executado. Em caso de reprovação, guarde uma captura ou um vídeo e descreva o passo exato.

**Antes de começar**

| Dado | Valor |
|---|---|
| Aparelho e versão do Android | |
| APK instalado (nome do arquivo) | |
| SHA-256 conferido? | |
| Data do teste | |
| Quem testou | |

Como instalar: copie o APK de homologação para o celular (cabo USB ou download), abra o arquivo e permita "instalar apps desconhecidos" para o aplicativo que abriu o arquivo. Pelo computador, com a depuração USB ligada: `adb install -r <arquivo>.apk`.

Com o bloqueio do app ativado (PIN ou biometria), capturas de tela ficam bloqueadas de propósito. Para registrar evidência dessas telas, fotografe com outro aparelho.

## A. Instalação e inicialização

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| A01 | Instalar o APK de homologação. | Instala sem erro; ícone "SerenaCash" com a marca na gaveta de apps. | | | |
| A02 | Abrir pelo ícone. | Tela de abertura com a marca e, em seguida, "Saiba quanto você pode gastar." (passo 1 de 4). | | | |
| A03 | Fazer o onboarding com uma conta fictícia de R$ 1.234,56, uma conta fixa e um cartão. | Chega à tela inicial; "Pode gastar neste mês" desconta a conta fixa. | | | |
| A04 | No passo 3 do onboarding, usar o botão voltar do aparelho. | Volta para o passo 2, não sai do app. | | | |
| A05 | Fechar o app pela lista de recentes e abrir de novo. | Abre direto na tela inicial, com os mesmos valores. | | | |
| A06 | Reiniciar o aparelho e abrir o app. | Abre com os mesmos dados, sem pedir onboarding. | | | |
| A07 | Instalar por cima uma versão mais nova do APK de homologação (quando houver). | Atualiza sem pedir desinstalação e mantém os dados. | | | |
| A08 | Deixar o app em segundo plano por algumas horas e voltar. | Volta na mesma tela (ou na tela de bloqueio, se ativada), com os dados. | | | |

## B. Segurança

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| B01 | Menu > Configurações > "Proteger com PIN": definir e confirmar um PIN de teste. | Vai para a tela "Bloqueado". | | | |
| B02 | Digitar um PIN errado e depois o certo. | "PIN incorreto." e, com o certo, desbloqueia. | | | |
| B03 | Errar o PIN 5 vezes. | Avisa as tentativas restantes e entra em pausa de 30 s, com contagem regressiva. | | | |
| B04 | Durante a pausa, fechar o app e abrir de novo. | A pausa continua. | | | |
| B05 | Com o app desbloqueado, ir para a tela inicial do Android e voltar. | Pede o PIN de novo. | | | |
| B06 | Com o bloqueio ativo, tentar capturar a tela e olhar a miniatura na lista de recentes. | Captura bloqueada ou preta; miniatura sem conteúdo. | | | |
| B07 | Preencher um lançamento sem salvar, sair para o Android, voltar e desbloquear. | O formulário continua com o que foi digitado. | | | |
| B08 | Configurações: "Trocar PIN" e desativar o PIN. | Os dois pedem o PIN atual; PIN errado não troca nem desativa. | | | |
| B09 | Com digital ou rosto cadastrados no Android, ligar "Pedir biometria ao abrir". | Pede a confirmação na hora; só liga se confirmar. | | | |
| B10 | Fechar e abrir o app com a biometria ligada. | Pede biometria; com ela, desbloqueia. | | | |
| B11 | Cancelar a biometria e tentar de novo; usar a senha do aparelho como alternativa. | Cancelar mantém bloqueado; a alternativa desbloqueia. | | | |
| B12 | Cadastrar outra digital no Android e abrir o app. | Continua pedindo e aceitando a biometria (anote o comportamento). | | | |
| B13 | Na tela de bloqueio, tocar em "Esqueci o PIN" e cancelar. | Explica que não há recuperação; cancelar não apaga nada. | | | |
| B14 | Menu > Exportar e backup: gerar um backup cifrado com uma senha de teste e salvar no aparelho. | Arquivo `.scbk` gerado e compartilhado. | | | |
| B15 | Menu > Importar: restaurar esse backup com a senha errada e depois com a certa. | Senha errada: recusa e nada muda. Senha certa: restaura e mostra o resumo. | | | |
| B16 | Depois de restaurar, conferir saldos, lançamentos e listas de compras. | Iguais aos de antes da exportação. | | | |
| B17 | Menu > Privacidade e dados > "Apagar tudo deste aparelho"; fechar e abrir o app. | Vai para o onboarding e, ao reabrir, continua abrindo normalmente. | | | |

## C. Câmera

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| C01 | Compras > Iniciar compra > "Código": negar a permissão de câmera. | Explica para que serve a câmera e oferece "Informar manualmente". | | | |
| C02 | Tocar em "Permitir câmera" e conceder. | A imagem da câmera aparece. | | | |
| C03 | Apontar para um código a 15–20 cm. | Foca sozinha em até 2 s. | | | |
| C04 | Ligar e desligar a lanterna. | Liga e desliga; o botão muda de estado. | | | |
| C05 | Fechar a câmera e abrir de novo, três vezes seguidas. | Abre sempre; sem tela preta nem travamento. | | | |
| C06 | Com a câmera aberta, atender uma ligação ou trocar de app e voltar. | A câmera volta a funcionar. | | | |
| C07 | Girar o aparelho com a câmera aberta. | A imagem continua correta (anote se a tela gira). | | | |

## D. Códigos de barras

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| D01 | Ler um EAN-13 de um produto de mercado. | Reconhece o código e pede nome e preço (ou traz o produto já conhecido). | | | |
| D02 | Ler um EAN-8. | Reconhece. | | | |
| D03 | Ler um UPC (produto importado). | Reconhece. | | | |
| D04 | Ler o QR Code de uma nota fiscal de consumidor. | Trata como dado da nota; não abre navegador nem link. | | | |
| D05 | Ler um QR Code qualquer (um site, um Wi-Fi). | Não abre nada; avisa que não é um código de produto ou ignora. | | | |
| D06 | Ler um código de um produto nunca cadastrado. | Pede os dados e, depois de confirmar, lembra do produto na próxima leitura. | | | |
| D07 | Ler um código rasurado ou cortado. | Não inventa número; continua esperando ou oferece digitar. | | | |
| D08 | Ler o mesmo código duas vezes seguidas. | Não duplica o item sem confirmação. | | | |

## E. Leitura de etiquetas de preço (OCR)

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| E01 | "Etiqueta": fotografar uma etiqueta com nome e preço. | Sugere nome e preço; pede confirmação antes de adicionar. | | | |
| E02 | Etiqueta de promoção ("de R$ x por R$ y"). | Sugere o preço "por". | | | |
| E03 | Etiqueta com preço por quilo. | Identifica que é por kg e pede o peso. | | | |
| E04 | Etiqueta com mais de um preço (à vista e parcelado). | Não escolhe sozinho um valor errado; sinaliza baixa confiança ou pede escolha. | | | |
| E05 | Etiqueta inclinada (cerca de 30°). | Lê ou avisa que não conseguiu. | | | |
| E06 | Etiqueta com reflexo da luz. | Lê ou avisa que não conseguiu; não trava. | | | |
| E07 | Pouca luz, com e sem lanterna. | Com lanterna melhora; sem ela, avisa. | | | |
| E08 | Corrigir à mão um preço lido errado. | O valor corrigido é o que entra no carrinho. | | | |
| E09 | Cancelar a confirmação. | Nada é adicionado. | | | |
| E10 | Tempo entre fotografar e ver a sugestão. | Anote o tempo (referência: até 3 s). | | | |

## F. Compras

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| F01 | Criar uma lista com 5 itens, um deles por peso. | Lista salva com estimativa só dos itens com preço conhecido. | | | |
| F02 | Alterar quantidades e marcar itens. | Totais e progresso acompanham. | | | |
| F03 | Iniciar a compra a partir da lista, com orçamento de R$ 100. | Sessão mostra o total e a barra do orçamento. | | | |
| F04 | Adicionar itens por código, por etiqueta e manualmente. | Todos entram no carrinho com o preço confirmado. | | | |
| F05 | Item por peso: 0,735 kg a R$ 8,99/kg. | Total da linha R$ 6,61. | | | |
| F06 | Aplicar desconto e promoção "leve 3 pague 2". | Total do carrinho reflete os descontos. | | | |
| F07 | Passar do orçamento. | A barra e o texto avisam que passou. | | | |
| F08 | Tocar em "Finalizar compra" e cancelar. | Pede confirmação; cancelar mantém a sessão. | | | |
| F09 | Finalizar e aceitar a despesa sugerida. | Uma despesa com o total aparece em Lançamentos. | | | |
| F10 | Tentar confirmar a mesma compra de novo (voltar, repetir). | Não cria uma segunda despesa. | | | |
| F11 | Abrir um produto comprado antes. | Mostra o histórico de preços. | | | |
| F12 | Fazer uma compra inteira em modo avião. | Tudo funciona sem internet. | | | |

## G. Finanças

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| G01 | Criar uma segunda conta e transferir R$ 100 entre elas. | Saldos mudam em sentidos opostos; total consolidado igual; não conta como receita nem despesa. | | | |
| G02 | Botão "+" > Despesa: R$ 45,90, criando uma categoria nova pela busca e uma subcategoria. | O que foi digitado é mantido; a despesa mostra "Categoria › Subcategoria". | | | |
| G03 | Botão "+" > Receita de R$ 500. | Saldo sobe R$ 500. | | | |
| G04 | Botão "+" > Conta a pagar para daqui a 3 dias. | Aparece em "Contas a pagar"; saldo não muda; "Pode gastar" desconta. | | | |
| G05 | Pagar metade dessa conta e depois o restante. | Pendente cai pela metade e zera; saldo cai só o que foi pago. | | | |
| G06 | Botão "+" > Conta a receber; depois "Receber". | Só entra no saldo ao receber. | | | |
| G07 | Compra no cartão de R$ 300 em 3 vezes. | Três parcelas de R$ 100 em três faturas; saldo da conta não muda. | | | |
| G08 | Pagar a fatura atual. | Saldo cai o valor pago; os gastos do mês não aumentam de novo. | | | |
| G09 | Estornar parte de uma compra do cartão. | A fatura cai o valor estornado. | | | |
| G10 | Criar uma despesa mensal recorrente e excluir "este e os próximos"; desfazer. | A série some e volta inteira com "Desfazer". | | | |
| G11 | Orçamento de R$ 800 para uma categoria com subcategoria; lançar gastos nas duas. | O orçamento soma a categoria e a subcategoria uma vez só. | | | |
| G12 | Criar uma meta e fazer um depósito. | Progresso da meta sobe; "Pode gastar" desconta a reserva. | | | |
| G13 | Relatórios: fluxo de caixa, gastos por categoria, projeção. | Valores batem com os lançamentos feitos. | | | |
| G14 | Lançamentos: buscar por texto, filtrar por tipo e por categoria. | A lista traz só o que corresponde; a categoria principal traz as subcategorias. | | | |
| G15 | Arquivar uma categoria usada e excluir outra movendo os lançamentos. | A arquivada continua nos lançamentos antigos; a excluída transfere os lançamentos para o destino. | | | |
| G16 | Calendário: abrir um dia com lançamentos. | "Resultado do dia" bate com receitas menos despesas. | | | |
| G17 | Tela inicial > Personalizar: trocar ordem, esconder seções, mudar o período. | A tela inicial obedece e a escolha continua depois de fechar o app. | | | |
| G18 | Ocultar valores (ícone do olho). | Todos os valores viram "R$ ••••" em todas as telas. | | | |

## H. Interface

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| H01 | Tema claro e tema escuro (ícone na tela inicial). | Todas as telas legíveis nos dois temas. | | | |
| H02 | Fonte do Android no tamanho máximo. | Nada cortado nem sobreposto; rolagem alcança tudo. | | | |
| H03 | Barra inferior: Início, Lançamentos, Compras, Planejar. | Cada aba abre a sua tela; a aba ativa fica destacada. | | | |
| H04 | "Menu": abrir, usar cada destino e voltar. | Todo item abre uma tela que funciona; voltar retorna à aba de origem. | | | |
| H05 | Abrir o menu arrastando da borda esquerda; fechar com o voltar. | Abre e fecha sem sair do app. | | | |
| H06 | Em cada formulário, abrir o teclado no último campo. | O campo fica visível acima do teclado; dá para salvar. | | | |
| H07 | Girar o aparelho na tela inicial e em um formulário. | Sem perda do que foi digitado nem conteúdo cortado (anote se a tela gira). | | | |
| H08 | Se possível, repetir em um aparelho pequeno e em um grande. | Layout se ajusta. | | | |
| H09 | Ligar o TalkBack e percorrer tela inicial, um lançamento e o seletor de categoria. | Tudo é anunciado com nome e função; valores lidos por extenso; botões acionam o que anunciam. | | | |
| H10 | Rolar a lista de lançamentos com muitos itens. | Rolagem fluida, sem engasgos visíveis. | | | |
| H11 | Tocar duas vezes rápido em "Salvar". | Um lançamento só. | | | |

## I. Recursos externos

| ID | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|
| I01 | Configurações > Lembretes: ativar e conceder a permissão de notificações. | "Lembretes ativados." | | | |
| I02 | Criar uma conta a pagar para amanhã e esperar a manhã seguinte. | Notificação "vence amanhã" ou "vence hoje" por volta das 9h (pode atrasar até 1 hora). | | | |
| I03 | Tocar na notificação com o app aberto, em segundo plano e fechado. | Abre o lançamento certo nos três casos. | | | |
| I04 | Negar a permissão de notificações. | O app explica e continua funcionando sem lembretes. | | | |
| I05 | Reiniciar o aparelho com um lembrete agendado. | O lembrete ainda chega. | | | |
| I06 | Usar o app um dia inteiro em modo avião. | Tudo funciona, menos a tela de planos. | | | |
| I07 | Voltar a ter internet. | Nada muda nos dados; nada é enviado. | | | |
| I08 | Tela de planos (Menu > SerenaCash Plus). | Neste APK a loja não está configurada: cada plano mostra "Preço e compra disponíveis na versão publicada nas lojas.", sem botão de compra, e "Restaurar compras" fica desabilitado. | | | |
| I09 | Compra de teste (sandbox) e restauração de assinatura. | **Bloqueado** até existirem produtos na loja e chave do RevenueCat. | | B | Depende de configuração comercial. |

## J. Reteste das ocorrências da homologação física (build 0.2.0+4)

Um teste por ocorrência do registro `15-RETORNO_HOMOLOGACAO_FISICA.md`. A coluna "ID" da ocorrência liga cada teste ao relato original. Todos estão **PENDENTE NO DISPOSITIVO DO USUÁRIO**: nenhum foi executado em aparelho físico.

| ID | Ocorrência | Procedimento | Resultado esperado | Resultado obtido | Situação | Observações, evidência, defeito |
|---|---|---|---|---|---|---|
| J01 | — | Instalar o APK 0.2.0 (build 4) **por cima** da versão que já está no celular (0.1.0 ou 0.2.0 build 3), sem desinstalar. Antes, exportar um backup cifrado. | Instala sem erro e abre com todos os dados de antes. No fim do menu aparece "versão 0.2.0 (build 4)". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J02 | 001 | Com a navegação de três botões, tocar em "+" na tela inicial. | As seis opções aparecem inteiras, a última ("Conta a receber") acima da barra do Android, e todas respondem ao toque. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J03 | 001 | Repetir J02 com a fonte do Android no maior tamanho. | A lista rola dentro da folha; nenhuma opção fica atrás da barra. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J04 | 002 | Em "Despesa", digitar valor, descrição e categoria; em "Forma de pagamento", tocar em "Cartão de crédito". | Valor, descrição e categoria continuam; aparece a escolha do cartão. Ao salvar, o saldo da conta não muda. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J05 | 002 | Em "Transferência" com uma conta só, tocar em Salvar; depois trocar para "Despesa". | O aviso de duas contas aparece na transferência e some ao trocar para despesa. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J06 | 003 | Em "Transferência", tocar em "Nova conta" no campo "Para", cadastrar e salvar. | Volta para a transferência com o que estava digitado e a conta nova selecionada em "Para". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J07 | 004 | Em "Conta a pagar", tocar no ícone de calendário do vencimento e escolher um dia. | Abre o calendário nas cores do app; a data escolhida aparece no campo; digitar à mão continua funcionando. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J08 | 005 | Em "Novo empréstimo", tocar no calendário do primeiro vencimento. | Mesmo calendário de J07. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J09 | 006 | Cadastrar um empréstimo "Americano" de R$ 10.000,00 a 1% ao mês em 3 parcelas. | Prévia: 3 parcelas, R$ 100,00 nas duas primeiras e R$ 10.100,00 na última. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J10 | 007 | Cadastrar uma dívida "Quando der" de R$ 40.000,00 sem juros; registrar pagamentos de R$ 500,00 e de R$ 2.000,00. | Saldo R$ 39.500,00 e depois R$ 37.500,00; nenhuma conta prevista foi criada; o extrato lista os dois pagamentos. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J11 | 007 | Na mesma dívida, tentar registrar um pagamento maior que o saldo. | O app recusa e informa o valor que quita a dívida. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J12 | 008 | Lançar despesas em duas categorias e olhar a tela inicial. | Cartão "Gastos por categoria" com o anel e, ao lado, cada categoria com o percentual. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J13 | 013 | Abrir Relatórios > Gastos por categoria e tocar em uma fatia ou em uma linha. | Anel com os percentuais somando 100,0%; a fatia tocada fica em destaque e o centro mostra o valor dela. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J14 | 010 | No Assistente, perguntar "No que mais gastei esse mês?". | Ranking de categorias com valor e percentual, não o resumo do mês. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J15 | 010 | Perguntar "no que posso ecomizar" (com o erro de digitação). | Resposta sobre onde o gasto se concentra; não "Não entendi". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J16 | 011 | Em Configurações, ligar "Pedir confirmação do aparelho ao abrir" e confirmar com a digital ou o bloqueio de tela. | O prompt do Android aparece; depois de confirmar, a opção fica ligada e o app continua aberto. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J17 | 011 | Com a opção ligada, mandar o app para o segundo plano e voltar. | Pede a confirmação; com a digital certa, abre; cancelar deixa na tela "Bloqueado", sem mensagem de erro. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J18 | 011 | Desligar a opção. | Pede a confirmação do aparelho antes de desligar. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J19 | 012 | Abrir Planejamento anual e ir para 2025. | Sem orçamento e sem meta em 2025, com o aviso de que não há registros. Em 2026, o orçamento aparece só a partir do mês em que foi criado. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J20 | 014 | Em uma compra, tocar em "Etiqueta". | A câmera abre dentro do app, com o total do carrinho no topo; nenhum outro aplicativo de câmera é aberto. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J21 | 014 | Ler 20 etiquetas seguidas usando "Adicionar e ler a próxima". | Nenhum travamento, câmera presa ou aquecimento anormal; cada leitura volta ao leitor em um toque. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J22 | 014 | Com o leitor aberto, ir para a tela inicial do Android e voltar ao app. | A prévia da câmera volta sozinha. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J23 | 015 | Ler a etiqueta de um cartaz com slogan (como a do abacaxi ou do papel higiênico). | O nome proposto é a descrição do produto, não o slogan nem o rodapé. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J24 | 016 | Ler uma etiqueta com preço por quilo em letras pequenas (como a dos cookies). | O preço proposto é o do item; o preço por quilo aparece só como informação de comparação. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J25 | 016 | Ler uma etiqueta com atacado e varejo (como a da água). | Preço proposto: varejo. O atacado aparece como opção "a partir de N un" e só vale quando a quantidade chega a N. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J26 | 016 | Ler uma etiqueta difícil (reflexo, risco sobre o preço). | Se a leitura sair duvidosa, o botão de adicionar fica desligado até você conferir, corrigir ou marcar "Conferi o preço com a foto". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J27 | 017 | Na revisão, tocar em um texto marcado na foto com "Nome" selecionado; depois em um valor com "Preço" selecionado. | O texto tocado vira o nome; o valor tocado vira o preço. Dá para ampliar a foto com dois dedos. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J28 | 018 | Ler o código de barras de um produto nunca cadastrado; informar nome e preço; ler o mesmo código de novo. | Na primeira vez: "Código … lido", sem falar em falha. Na segunda: o produto do seu cadastro aparece com o nome. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J29 | 019 | Depois de adicionar um item lido pela etiqueta, finalizar a compra e abrir "Evidências". | A foto da etiqueta está lá, com o preço lido e o preço confirmado. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J30 | 023 | Na revisão de um item, tocar em "Foto do produto" e fotografar. | A foto aparece na revisão e depois em "Evidências", como "Produto". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J31 | 020 | Com a compra finalizada, tocar em "Conferir com o cupom fiscal" e fotografar o cupom. | Os itens do cupom aparecem pareados com o carrinho, com preço da gôndola e preço cobrado; diferenças em destaque; par duvidoso como "Suspeita de diferença". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J32 | 020 | Tocar em uma linha do cupom e trocar o item pareado. | O par muda e o resumo é recalculado. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J33 | 021 | Na revisão, tocar no meio do nome e digitar várias letras (teclado do aparelho, com sugestões ligadas). | O cursor fica onde foi colocado; não salta para o fim. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J34 | 025 | Na revisão, com o teclado aberto. | Título e botão "Adicionar ao carrinho" continuam visíveis; nada fica sob a barra de status nem sob o teclado. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J35 | 022 | Em uma compra, "Falar o item" > "Falar" e dizer "cinco quilos de arroz, vinte e nove reais". | A transcrição aparece; o app pergunta se R$ 29,00 é o total ou o preço por quilo; depois abre a revisão. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J36 | 022 | Negar a permissão do microfone. | Mensagem clara de que a voz não está disponível; dá para digitar o item. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J37 | 024 | Depois de duas compras com o mesmo produto, abrir Compras > Histórico de preços. | O produto aparece com as duas compras, a diferença em valor e em percentual. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J38 | 026 | Passear por orçamento, assistente, ajuda e boas-vindas. | Nenhuma ocorrência de "mês sereno", "agitado" ou parecidos. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J39 | 027 | Olhar a tela inicial e abrir "Personalizar tela inicial". | Cartões novos disponíveis (saldo do período, visão geral, controle diário, discriminação, recorrência, saúde financeira); dá para ocultar e reordenar. Se você já tinha personalizado a tela, eles estão na lista para adicionar. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J40 | 029/030 | Menu > Controle diário. | Gasto de hoje e de ontem, as duas médias, o mês dia a dia; dias futuros só com "previsto". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J41 | 031 | Em Controle diário, definir limite de R$ 100,00 e lançar uma despesa de R$ 35,00. | Disponível hoje: R$ 65,00. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J42 | 031 | Definir meta de economia de R$ 20,00 e guardar R$ 15,00 em uma meta. | Guardado hoje R$ 15,00; pendente R$ 5,00. Gastar menos que o limite não aumenta o "guardado". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J43 | 032 | Em Configurações, trocar a cor do aplicativo e a densidade. | O app inteiro muda na hora; receita, despesa e alerta mantêm as cores; "Restaurar aparência padrão" desfaz. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J44 | — | Exportar um backup cifrado depois de uma compra com fotos e restaurar. | As fotos de evidência e a conferência do cupom voltam junto. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J45 | 017 | Na revisão de uma etiqueta, tocar em "Marcar uma área para reler", arrastar o dedo sobre o nome do produto na foto e tocar em "Ler a área marcada". | O retângulo aparece onde o dedo passou, a lista não rola e a foto não se move. O nome lido entra no campo. Dá para ajustar pelos cantos antes de ler. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J46 | 017 | Repetir com "Preço" selecionado, marcando uma área com dois valores (varejo e atacado). | O app mostra os dois valores para escolher; não escolhe sozinho. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J47 | 018 | Em Configurações, ligar "Consultar um catálogo aberto de produtos pela internet". Com internet, ler o código de barras de um produto industrializado nunca cadastrado. | A revisão abre com um nome sugerido e o aviso de que veio do Open Food Facts. Sem preço. Dá para corrigir o nome. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J48 | 018 | Com a opção ligada, em modo avião, ler outro código nunca cadastrado. | Mensagem de que não foi possível consultar; o cadastro manual continua funcionando. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J49 | 018 | Desligar a opção e ler um código nunca cadastrado. | Nenhuma consulta é feita; a revisão pede o nome e lembra que a opção existe. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J50 | 020 | Depois de conferir um cupom cujo total difere da despesa registrada, tocar em "Atualizar a despesa pelo cupom", conferir o valor e confirmar. | A despesa passa a ter o valor confirmado; nas observações dela fica anotado o valor anterior. Sem tocar no botão, nada muda. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J51 | 027 | Na tela inicial, tocar nas setas ao lado do mês. | Os cartões passam a mostrar o mês anterior ou o seguinte, com um aviso e o botão de voltar ao mês atual. Fechar e abrir o app: volta ao mês atual. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J52 | 027 | No cartão "Saldo do período", tocar em um dia do gráfico e em "Ver lançamentos do dia". | Aparecem saldo, recebido e gasto daquele dia; a lista abre os lançamentos dele. Dias futuros dizem "previsto". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J53 | 027 | No mesmo cartão, trocar para "Entradas e saídas". | Barras por dia: cheias para o que aconteceu, contornadas para o que está previsto. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J54 | 027 | Em "Personalizar tela inicial", marcar "Tamanho reduzido" em dois cartões e salvar. | Na tela inicial esses cartões ocupam uma linha, com o número principal. Desmarcar devolve o tamanho normal. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J55 | 029 | Em Controle diário, escolher uma categoria no primeiro cartão. | Os gastos passam a ser só os da categoria; recebido e saldos não mudam. As comparações de 7 dias aparecem, ou "sem registro". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J56 | 030 | No cartão "Fluxo de caixa", escolher uma conta, andar um mês para trás e para frente e trocar entre "Realizado", "Previsto" e "Realizado + previsto". | A lista de dias e os saldos acompanham a conta e o mês escolhidos; mês futuro aparece como previsto. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J57 | 031 | Definir um limite de R$ 30,00 para uma categoria, só em sábado e domingo. Antes de salvar, ler a simulação. | A simulação diz quanto soma no mês e em quantos dias passados o gasto teria ficado dentro. Depois de salvar, o limite aparece em "Limites por categoria", com "Só em: Sáb, Dom". | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J58 | 031 | Com um limite diário de R$ 50,00, lançar uma despesa de R$ 65,00 hoje e voltar à tela inicial. | Um aviso no topo: "Limite diário ultrapassado em R$ 15,00." Desligando o aviso no Controle diário, ele some. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J59 | 031 | Definir uma meta diária de economia ligada a uma meta específica e guardar dinheiro em outra meta. | O valor guardado na outra meta não conta para a meta diária. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J60 | — | Em Configurações > Lembretes, permitir avisos. Cadastrar uma conta a receber para amanhã e uma conta a pagar para amanhã. | No dia seguinte, às 9 h (pode atrasar até uma hora), um aviso de cada. Desligando "Valores a receber", só o da conta a pagar chega. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J61 | 032 | Em Configurações, abrir "Editor de tema", escolher um amarelo bem claro como cor principal. | O app avisa que a cor é clara demais, mostra o contraste e não deixa aplicar. "Ajustar para o tom legível mais próximo" libera o botão. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J62 | 032 | Aplicar uma cor própria e passear pelo app, em claro e em escuro. | Botões, links e painel-resumo usam a cor escolhida; receitas, despesas e alertas mantêm as cores de sempre; tudo legível. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J63 | 032 | Trocar o estilo dos cartões (contorno, sombra, cor), os gráficos (compactos), o tamanho do texto (maior) e o movimento (reduzido). | Cada troca vale na hora, em todas as telas. Com movimento reduzido, telas e folhas aparecem sem deslizar. Nada cortado com o texto maior. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |
| J64 | — | Anexar a um lançamento uma foto da galeria tirada com a localização ligada. Exportar o anexo e ver os detalhes do arquivo em outro app. | O arquivo exportado não traz a localização. | | PENDENTE NO DISPOSITIVO DO USUÁRIO | |

## Resumo

| Seção | Aprovados | Reprovados | Bloqueados | Não executados |
|---|---|---|---|---|
| A. Instalação | | | | |
| B. Segurança | | | | |
| C. Câmera | | | | |
| D. Códigos | | | | |
| E. Etiquetas | | | | |
| F. Compras | | | | |
| G. Finanças | | | | |
| H. Interface | | | | |
| I. Externos | | | | |
| J. Reteste das ocorrências 001–032 | | | | |

Defeitos encontrados (um por linha: ID do teste, o que aconteceu, gravidade percebida):

1.
2.
3.
