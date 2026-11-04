# Plano de testes

## 1. Camadas
| Camada | Ferramenta | Escopo | Comando |
|---|---|---|---|
| Domínio financeiro (`packages/core`) | Vitest | dinheiro, datas, saldos, cartões, recorrência, pode gastar, orçamentos, metas, empréstimos, relatórios, assistente, importação, duplicidades, backup, widgets, direitos, sync | `pnpm --filter @financas/core test` |
| Domínio de compras (`packages/shopping`) | Vitest | unidades, carrinho, códigos, parser de etiquetas, listas, produtos/histórico, sessão | `pnpm --filter @financas/shopping test` |
| App (`apps/mobile`) | Jest + jest-expo | persistência (migrações, repositórios, transações, change_log), fluxos do store (parcelas, recorrência, fatura, parcial, desfazer, prefs/layout) | `pnpm --filter mobile test` |
| Tipos | tsc estrito (`noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`) | todos os pacotes | `pnpm -r typecheck` |
| Visual/fluxo (preview web) | Expo export + Playwright | onboarding, tela inicial, lançamento, personalização, abas, cartões, orçamentos, compras (lista, sessão, carrinho, finalização, despesa), relatórios, assistente, paywall, tema escuro | `docs/qa/` (scripts em scratch) |
| Dispositivo (pendente) | Expo dev build (EAS) + Maestro | câmera, código de barras, OCR, compras integradas, notificações, biometria, arrastar e soltar, Dynamic Type 200%, VoiceOver/TalkBack | ver `docs/11-guia-build.md` |

## 2. Casos cobertos por fluxo do briefing
| Fluxo | Teste |
|---|---|
| Primeiro acesso / onboarding | Playwright (web) · store: seed de categorias |
| Cadastro de conta | store `saveAccount`, limite do grátis |
| Receita / despesa | store, `ledger.test` (efetivação, parcial, cancelado) |
| Transferência | `ledger.test` (neutra no consolidado) |
| Recorrência | `recurrence.test`, store (série, materialização, excluir série + desfazer) |
| Cartão / parcelamento / pagamento de fatura | `cards.test`, store (3x em faturas consecutivas, pagamento, sem dupla contagem) |
| Personalização do dashboard | `widgets.test` (24 widgets, presets, mover, normalização), Playwright |
| Importação / exportação | `io.test` (CSV pt-BR/en, OFX, duplicidades, legado, backup round-trip) |
| Lista de compras | `lists.test` |
| Leitura de preços / correção de OCR | `pricetag.test` (etiqueta típica, de/por, por kg, parcelado, ruído, código) |
| Leitura de códigos | `units.test` (EAN-13/8, UPC-A, balança, NFC-e QR) |
| Totalização do carrinho | `units.test` (exemplo do briefing R$ 93,23, promoções, descontos, peso) |
| Offline / reconexão | persistência local por desenho; sync `model.test` (merge e conflito) |
| Assinaturas / restauração | `billing.test` (ativo, expirado, carência, cancelado, cache 7 dias, vitalício) |
| Recuperação de erros | `store.test` (rollback de transação), widgets com ErrorBoundary |

## 3. Critérios de aceite para publicação
- Zero defeitos críticos conhecidos; todos os testes verdes; typecheck limpo.
- Câmera/OCR/compras validados em pelo menos 1 Android e 1 iPhone físicos.
- Contraste AA (`node docs/qa/contrast-check.mjs`), toque ≥ 44 pt, leitor de tela nos fluxos principais.
- Builds de release assinados; política de privacidade publicada; produtos nas lojas em sandbox aprovados.
