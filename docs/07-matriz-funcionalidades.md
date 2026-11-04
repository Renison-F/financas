# Matriz de funcionalidades — estado real em 2026-11-04

Legenda: **✅ implementado e testado** (domínio com teste automatizado e/ou tela verificada no preview web) · **🟡 implementado, validação em dispositivo pendente** (depende de recurso nativo que não roda no navegador) · **🔵 arquitetura pronta, serviço externo pendente** · **⬜ não iniciado**.

| Módulo | Funcionalidade | Estado | Onde |
|---|---|---|---|
| Contas | múltiplas contas, tipos, saldo inicial, transferências, histórico, ajuste/conciliação, arquivamento, visão consolidada, sem dupla contagem | ✅ | `accounts/*`, `ledger.ts` |
| Receitas | fixas/variáveis, recorrentes, previstas × recebidas, categorias/subcategorias | ✅ | `transaction.tsx`, `recurrence.ts` |
| Despesas | fixas, variáveis, recorrentes, parceladas (cartão), agendamento (previsto), pagamento parcial, atrasadas, categorias, tags, observações, busca/filtros | ✅ | idem, `transactions.tsx`, `bills.tsx` |
| Despesas | anexos/comprovantes | 🟡 | modelo de dados e tabela `attachments` prontos; tela de anexo não construída (Plus) |
| Cartões | múltiplos, limite, fechamento, vencimento, à vista, parcelado, futuras, limite disponível, pagamento integral/parcial, histórico de faturas, projeção de comprometimento, sem dupla contagem | ✅ | `cards/*`, `cards.ts` |
| Cartões | estorno | 🟡 | registrar como compra negativa não é permitido; usar "ajuste" via pagamento? Pendente: tipo `card_refund` |
| Planejamento | orçamento global e por categoria, limites mensais, ritmo com marca de hoje, metas, reserva de emergência, projeção de saldo, simulação de compra ("cabe?"), alertas por regras | ✅ | `budgets/*`, `goals/*`, `reports/projection`, `assistant` |
| Planejamento | planejamento anual | 🟡 | relatório anual existe; edição de orçamento anual não |
| Empréstimos | cadastro, saldo devedor, juros, parcelas (Price/SAC), amortizações, pagamentos, antecipações, simulação de quitação, histórico | ✅ | `loans/*`, `loans.ts` |
| Relatórios | fluxo de caixa, comparativo mensal e anual, categorias, recorrentes, projeção, patrimônio, indicadores (com metodologia), CSV, PDF | ✅ (PDF 🟡 em dispositivo) | `reports/*`, `export.tsx` |
| Relatórios | relatórios personalizáveis, histórico de alterações | 🟡 | `change_log` grava tudo; tela de histórico não construída |
| Complementares | calendário, busca global, categorias personalizadas, tags, moeda, backup/restauração, importação CSV/OFX com revisão e duplicidades | ✅ | `calendar.tsx`, `import.tsx` |
| Complementares | lembretes e notificações | 🔵 | `expo-notifications` instalado e configurado; agendamento de lembretes de vencimento não implementado |
| Tela inicial | 24 widgets reais, mostrar/ocultar, arrastar e soltar, setas acessíveis, modelos, restaurar, período, contas consideradas, privacidade, persistência | ✅ (drag 🟡 em dispositivo) | `(tabs)/index.tsx`, `customize.tsx` |
| Listas | múltiplas listas, nome, loja, itens, quantidades, unidades (un/kg/g/L/mL/pct/dz/cx/m), categorias, marcar, reutilizar/duplicar, estimativa, totalização, planejado × realizado, offline | ✅ | `shopping/list/*`, `lists.ts` |
| Listas | compartilhamento | 🔵 | campo `shareToken`; exige backend |
| Supermercado | sessão, carrinho (unidade, peso, promoções, descontos), orçamento, "ainda cabe", histórico da sessão, lançamento único opcional | ✅ | `shopping/session.tsx`, `cart.ts`, `session.ts` |
| Supermercado | leitura de códigos EAN/UPC/QR (NFC-e) | 🟡 | `expo-camera`; funciona em Expo Go e dev build; precisa de teste em aparelho |
| Supermercado | OCR de etiquetas (nome, preço, de/por, por kg, código) com confiança e confirmação | 🟡 | parser ✅ testado; motor ML Kit exige development build |
| Supermercado | histórico de preços por produto/loja, variação de preço, produtos conhecidos por código | ✅ | `products.ts` |
| Supermercado | comparação entre estabelecimentos, favoritos, alertas de preço, itens da NFC-e | 🔵 | dados preparados; sem fonte externa |
| Assistente | perguntas determinísticas (8 intenções) com base explicável; recomendações por regras | ✅ | `assistant.ts` |
| Assistente | IA externa opcional | ⬜ | não obrigatória; não implementada |
| Monetização | catálogo, limites do grátis, direitos com carência/cache, paywall, restauração, política do vitalício | ✅ (compra real 🔵) | `billing/*`, `paywall.tsx` |
| Monetização | compras reais nas lojas | 🔵 | RevenueCat integrado via adapter; exige chaves, produtos nos consoles e development build |
| Monetização | administração comercial | 🔵 | ofertas vêm do RevenueCat/consoles; painel próprio exige backend |
| Segurança | dados locais, sem segredos no repo, exportação e exclusão total, logs sem dados pessoais | ✅ | `privacy.tsx`, `DataStore.eraseAll` |
| Segurança | biometria ao abrir | 🟡 | preferência salva; gate de autenticação ao abrir o app não implementado |
| Segurança | criptografia de backup, PIN | ⬜ | planejado (`expo-secure-store` instalado) |
| Sincronização | change_log, versionamento, merge com conflito monetário | ✅ (domínio) | `sync/model.ts` |
| Sincronização | transporte/servidor, status visível | 🔵 | interface `SyncTransport`; sem provedor |
| Onboarding | 4 passos puláveis, sem cadastro | ✅ | `onboarding.tsx` |
| i18n | strings em pt-BR; moeda configurável | 🟡 | sem catálogo de strings ainda |
