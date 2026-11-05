# Retorno da homologação física

Registro dos problemas, capturas e sugestões que o usuário trouxer do teste no celular dele. Aberto em 05/11/2026, ainda sem itens: a homologação está em andamento.

O estado do projeto e as regras de retomada estão em `CHECKPOINT.md`, seção "HOMOLOGAÇÃO FÍSICA EM ANDAMENTO". O roteiro que o usuário está seguindo é o `14-CHECKLIST_APARELHO.md` (cópia para preencher em `E:\SerenaCash\homologacao\CHECKLIST-APARELHO.md`).

## Build testada

| | |
|---|---|
| APK | `serenacash-0.1.0+2-homologacao-bae5d9f.apk` |
| Versão / build | 0.1.0 / 2 |
| Commit | `bae5d9f` |
| SHA-256 | `63c3ac06120f9cda29e43a0117e84acbe99cccfa2bcf1836b425cfb705726912` |
| APK instalado confirmado pelo usuário | a confirmar |
| Aparelho | a preencher |
| Versão do Android | a preencher |
| Período do teste | início em 05/11/2026 |

## Como registrar cada item

Um item por problema ou sugestão, na ordem em que chegar. Registrar primeiro, investigar depois.

| Campo | O que escrever |
|---|---|
| ID | `F-01`, `F-02`, ... |
| Relato | As palavras do usuário, sem reinterpretar |
| Evidência | Captura, vídeo ou passo a passo; teste do checklist relacionado (ex.: `B07`) |
| Tipo | Defeito, sugestão ou dúvida |
| Área | Segurança, integridade financeira, estabilidade ou experiência de uso |
| Gravidade | P0 a P3 (critérios abaixo) |
| Reproduzido | Sim (onde e como), não, ou só no aparelho |
| Causa | Causa técnica, com arquivo e linha; "não identificada" enquanto não houver |
| Correção | Commit e teste que cobre |
| Reteste | No emulador (build, data) e no aparelho (pelo usuário) |
| Estado | Aberto, em análise, aguardando aprovação, corrigido, retestado, recusado |

Gravidade:

- **P0:** perda ou vazamento de dados, valor financeiro errado gravado, app que não abre.
- **P1:** função principal quebrada sem contorno, falha de segurança que exige condição específica.
- **P2:** função com contorno, erro de exibição que confunde, texto errado em fluxo importante.
- **P3:** acabamento, sugestão de melhoria.

Ordem de trabalho: segurança, integridade financeira, estabilidade, experiência de uso; dentro de cada área, da gravidade maior para a menor.

## O que só o aparelho mostra

Itens que o emulador não cobriu e onde os achados são mais prováveis:

- Câmera, leitura de códigos de barras e de etiquetas de preço (OCR).
- Biometria com digital ou rosto cadastrado.
- Notificações na hora certa, com o app fechado e com economia de bateria do fabricante.
- TalkBack e tamanhos de fonte do sistema.
- Fluidez de rolagem e tempo de abertura em hardware real.
- Compartilhar e importar arquivos com os apps do aparelho.

Quando um defeito só aparecer no aparelho, pedir ao usuário: modelo, versão do Android, o passo exato e, se possível, um `adb logcat` do momento. O app não registra valores, descrições nem PIN no log.

## Itens

Nenhum item registrado até agora.

| ID | Relato | Tipo | Área | Gravidade | Estado |
|---|---|---|---|---|---|
| | | | | | |

## Sugestões fora de defeito

Nenhuma registrada até agora.
