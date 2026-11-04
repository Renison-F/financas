# Resultados de QA — 2026-11-04

## 1. Automatizado (executado nesta sessão)
| Suite | Resultado |
|---|---|
| `@financas/core` (Vitest) | 14 arquivos, **100 testes passando** |
| `@financas/shopping` (Vitest) | 3 arquivos, **18 testes passando** |
| `mobile` (Jest + jest-expo) | 2 suites, **9 testes passando** (persistência e fluxos do store) |
| Typecheck estrito (3 pacotes) | **limpo** |
| Contraste WCAG (`docs/qa/contrast-check.mjs`) | **todos os pares aprovados** (claro e escuro) |
| Export web (`expo export --platform web`) | **compila** (3,3 MB) |

## 2. Fluxos verificados no preview web (Playwright, 390×844, claro e escuro)
Onboarding completo (conta, conta fixa recorrente, cartão) · tela inicial com "pode gastar" correto (R$ 2.500 − R$ 1.500 = R$ 1.000) · explicação do cálculo · novo lançamento (despesa com categoria) · compra no cartão em 3× e detalhe do cartão (fatura 11/2026 R$ 300, futuras R$ 600, limite livre R$ 4.100) · orçamento criado e exibido com marca de hoje · personalização da tela inicial (modelos, ocultar, mover) · abas Lançamentos, Compras, Planejar, Mais · **compras**: criar lista com orçamento, itens (un/kg), iniciar sessão, adicionar manual com quantidade, item da lista com preço, total R$ 41,37 e "ainda cabe R$ 258,63", finalizar com planejado × realizado, registrar despesa única · relatórios (fluxo de caixa), assistente ("quanto posso gastar?"), paywall, importação, configurações, calendário · tema escuro.
Sem erros de página após a correção dos seletores instáveis do zustand (loop de renderização, corrigido).

Capturas de referência (não versionadas) foram geradas no scratch da sessão; capturas oficiais para as lojas devem vir de builds reais.

## 3. Não validado (exige aparelho/emulador ou serviço externo)
| Item | Motivo | Como validar |
|---|---|---|
| Leitura de códigos EAN/QR | câmera | Expo Go ou dev build em aparelho |
| OCR de etiquetas (ML Kit) | módulo nativo, Nova Arquitetura não verificada pela comunidade | dev build; se falhar, trocar motor (docs/11) |
| Compras, restauração, carência, reembolso | RevenueCat + sandbox das lojas | docs/08 §6 |
| Notificações locais, biometria | permissões nativas | dev build |
| Arrastar e soltar (reanimated + gesture-handler) | gestos | aparelho; as setas acessíveis cobrem o caso enquanto isso |
| Dynamic Type 200%, VoiceOver/TalkBack | simulador/emulador | docs/09 §3 |
| SQLite real (migrações v1→v2 com colunas geradas) | expo-sqlite nativo | dev build; a migração v2 é tolerante a falhas |

## 4. Auditoria Impeccable (modo nativo, a partir do código; `.claude/skills/impeccable/reference/audit.native.md`)

| # | Dimensão | Nota | Achado principal |
|---|---|---|---|
| 1 | Acessibilidade | 3 | Labels, roles, estados e valores por extenso presentes; faltam testes reais com leitor de tela e 200% |
| 2 | Desempenho | 3 | Lista de lançamentos usa SectionList virtualizada; tela inicial recalcula indicadores por `useMemo` sobre o ledger inteiro (ok até dezenas de milhares de lançamentos; medir em aparelho) |
| 3 | Aparência e tema | 4 | Tokens semânticos em todo o app; claro/escuro/automático; nenhum hex solto nas telas (apenas em `tokens.ts` e categorias) |
| 4 | Conformidade de plataforma | 3 | Tab bar nativa (5 itens), voltar do sistema, sheets para tarefas curtas; **P2**: cabeçalhos são inline próprios (sem large title iOS / top app bar M3); ícones próprios em vez de SF Symbols/Material (decisão de marca documentada) |
| 5 | Adaptatividade | 2 | Largura máxima 600 pt e teclado tratado; **P1**: tablet renderiza coluna única centralizada (sem rail/duas colunas); orientação travada em retrato por decisão |
| **Total** | | **15/20 — Bom** | |

**Veredito de conformidade:** lê-se como app nativo (sem controles web, sem hover, insets respeitados, gestos do sistema vivos). Violações: cabeçalhos customizados (P2), ausência de layout de tablet (P1).

**Issues registradas:** P0: 0 · P1: 1 (tablet) · P2: 2 (cabeçalhos inline; Segmented customizado em vez de `SegmentedControl` nativo). Resolvido nesta sessão: `Toggle` agora usa o `Switch` da plataforma · P3: 2 (animação da onda ainda não implementada; splash sem variante animada).

**Pontos positivos:** um número-herói por tela; estados vazio/erro/carregando em todos os widgets; "pode gastar" sempre explicável; sem emojis; contraste verificado por script; desfazer em exclusões; nenhuma tela falsa.

**Ações recomendadas (ordem):** `/impeccable adapt` (tablet e paisagem) → `/impeccable polish` (cabeçalhos nativos, Switch/SegmentedControl do sistema) → `/impeccable animate` (ondulação da marca de hoje com Reduce Motion) → `/impeccable harden` (textos longos, moedas diferentes de BRL, fonte 200%).

## 5. Defeitos conhecidos
| Severidade | Defeito | Estado |
|---|---|---|
| Crítica | nenhum conhecido | — |
| Alta | OCR não validado em aparelho | aberto (bloqueio de ambiente) |
| Média | No preview web, após voltar de uma tela empilhada o container anterior pode interceptar toques (quirk do react-native-screens web); não afeta nativo | aberto, só web |
| Média | Tablet sem layout dedicado | aberto |
| Baixa | Estorno de cartão sem tipo próprio (`card_refund`) | aberto |
