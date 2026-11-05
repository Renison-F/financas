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
| A02 | Abrir pelo ícone. | Tela de abertura com a marca e, em seguida, "Seu dinheiro em paz." (passo 1 de 4). | | | |
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

Defeitos encontrados (um por linha: ID do teste, o que aconteceu, gravidade percebida):

1.
2.
3.
