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
- Emulador `serenacash_api35`: desligado, não alterado. As validações desta rodada usam um aparelho virtual separado e instalação isolada.

## Estados usados

`não iniciado`, `em andamento`, `corrigido` (código e teste automatizado prontos), `aprovado automatizado` (corrigido e conferido no emulador), `aguarda teste físico`, `bloqueado`, `reprovado`.

Nenhum item passa a "aprovado no aparelho" sem o reteste do usuário.

## Matriz 001–032

A coluna "Estado" é atualizada a cada lote. O detalhe de cada item (causa, correção, testes, commit) fica na seção "Relatório por ocorrência".

| ID | Relato | Evidência | Prioridade | Onda | Estado |
|---|---|---|---|---|---|
| 001 | Opção "Conta a receber" do menu "Adicionar" fica atrás da barra do Android | `homologacao/001` | P1 | A | não iniciado |
| 002 | Começou "Despesa" e quer lançar no cartão sem recomeçar; aviso de transferência aparece na despesa | `homologacao/002` | P2 | A | não iniciado |
| 003 | Transferência não deixa criar conta na origem ou no destino | `homologacao/003` | P2 | A | não iniciado |
| 004 | Vencimento só por digitação | `homologacao/004` | P2 | A | não iniciado |
| 005 | Primeiro vencimento do empréstimo sem calendário | `homologacao/005` | P2 | A | não iniciado |
| 006 | Empréstimos limitados a Price e SAC | `homologacao/005` | P2 | C | não iniciado |
| 007 | Dívida sem parcelas nem prazo, paga quando possível | relato | P1/P2 | C | não iniciado |
| 008 | Tela inicial precisa de gráfico de despesas por categoria | `homologacao/008`, `dashboard/06` | P2 | D | não iniciado |
| 009 | Interface neutra demais | `homologacao/008` | P2 | D | não iniciado |
| 010 | Assistente responde resumo em vez de ranking; "onde posso economizar" não é entendido | `homologacao/010` | P1 | C | não iniciado |
| 011 | Biometria não habilita no telefone | `homologacao/011` | P1 | A | não iniciado |
| 012 | Orçamento e meta de 2026 aparecem em 2025 | `homologacao/012` | P1 | A | não iniciado |
| 013 | Relatório por categoria sem gráfico circular | `homologacao/013` | P2 | D | não iniciado |
| 014 | Leitor de etiquetas abre outra câmera | `compras/carrinho-ocr-*` | P1 | B | não iniciado |
| 015 | OCR escolhe slogan ou rodapé como nome | `compras/etiqueta-*`, `carrinho-ocr-erro-02`, `carrinho-ocr-abacaxi` | P1 | B | não iniciado |
| 016 | OCR escolhe o preço errado (por quilo, atacado, campo secundário) | `compras/etiqueta-*`, `carrinho-ocr-erro-01`, `-03` | P1 | B | não iniciado |
| 017 | Quer apontar nome e preço na imagem | relato | P2 | B | não iniciado |
| 018 | Código lido, mas produto "novo" ou não identificado | relato | P1 | B | não iniciado |
| 019 | Preço da gôndola sem comprovação no carrinho | relato | P2 | B | não iniciado |
| 020 | Conferir o preço cobrado no cupom fiscal | relato (vela: R$ 11,99 na gôndola, R$ 14,99 no caixa) | P2 | B | não iniciado |
| 021 | Cursor salta para o fim ao corrigir o nome lido | `compras/carrinho-ocr-teclado-*` | P1 | A | não iniciado |
| 022 | Adicionar itens por voz | relato | P2 | B | não iniciado |
| 023 | Foto do produto ligada ao preço | relato | P2 | B | não iniciado |
| 024 | Histórico e evolução de preços entre compras | relato | P2 | B | não iniciado |
| 025 | Teclado e barras do Android encobrem campos e ações | `compras/carrinho-ocr-teclado-*` | P1/P2 | A | não iniciado |
| 026 | Tirar "mês sereno", "agitado" e parecidos | `homologacao/008`, `010` | regra global | D | não iniciado |
| 027 | Tela inicial com visão analítica e módulos completos | `dashboard/01`–`07` | P2 | D | não iniciado |
| 028 | Refinar a identidade da tela inicial | `dashboard/*` | regra global | D | não iniciado |
| 029 | Gastos diários e comparação com limites | relato | P2 | D | não iniciado |
| 030 | Receitas diárias e evolução dia a dia | relato | P2 | D | não iniciado |
| 031 | Metas diárias de gasto e de economia | relato | P2 | D | não iniciado |
| 032 | Personalização de cor, tema e aparência | relato | P2 | D | não iniciado |

As evidências ficam em `docs/SerenaCash_Fable_5_2_Pacote_Com_Referencias/referencias/` na máquina do usuário. A pasta não foi incluída no controle de versão: o repositório é público e ela contém capturas de um aplicativo de terceiros.

## Achados adicionais vistos nas evidências

Itens que as fotos mostram e que o texto do pacote não lista como ocorrência própria.

| ID | O que a evidência mostra | Ligado a | Estado |
|---|---|---|---|
| 002-B | O aviso "Escolha duas contas diferentes" continua na tela depois de trocar de "Transferência" para "Despesa" | 002 | não iniciado |
| 003-B | Com uma conta só, o campo "Para" da transferência fica vazio, sem explicação | 003 | não iniciado |
| 005-B | Formulário de empréstimo preenchido mostra "Preencha nome, valor, taxa (% ao mês) e prazo" | 005 | não iniciado |

## Relatório por ocorrência

Preenchido conforme cada item é tratado.
