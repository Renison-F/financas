# Fase 1 — Pesquisa de mercado e oportunidades de diferenciação

Data da pesquisa: 04/11/2026. Método: busca web (WebSearch) com verificação em fontes secundárias; a sessão não conseguiu abrir diretamente os sites oficiais de Organizze, Mobills, YNAB, Monarch e das lojas (bloqueio de rede), portanto **todos os preços marcados como "não verificado" precisam de confirmação na fonte primária antes de qualquer uso comercial**.

## 1. Concorrentes analisados

| App | Posicionamento | Modelo de preço (fonte / status) | Pontos fortes | Reclamações recorrentes |
|---|---|---|---|---|
| **Nubank** (organização financeira no app do banco) | Banco; organização é recurso de retenção: Transações / Planejamento (Caixinhas) / Shopping | Gratuito | Dados nativos de conta e cartão, categorização automática, Caixinhas com rendimento, assistente de pagamentos (boletos, Pix agendado) | Instabilidades de login (set/2024, Downdetector); usuários relatam ausência de controle por categoria; sem "quanto posso gastar" |
| **Organizze** | Controle manual simples, "dinheiro em tempo real" | Fontes divergem: R$ 12/mês e R$ 96/ano ou compra única R$ 399,90 (TecMundo, sem data) vs. R$ 16,90/mês e limite de 100 transações/mês no grátis (Richify, 2026) — **não verificado** | Simplicidade, versão web, sem anúncios, trial longo (34 dias) | Personalização limitada, dificuldade para criar categorias (amostra antiga) |
| **Mobills** (Toro) | Maior app BR; forte em conteúdo/educação; Open Finance via Belvo | Site oficial: R$ 99,90/ano; mensal entre R$ 35 e R$ 42,90 (fontes conflitam) — **parcialmente verificado** | Projeção de saldo mensal, integração bancária, blog massivo | Reclame Aqui (jul/2026): sincronização quebrada após Open Finance, chamados sem resposta por 60+ dias; divergência de saldos; sem divisão de despesas |
| **Wallet by BudgetBakers** | Internacional, carteiras compartilhadas | ~US$ 5,49–5,99/mês; vitalício US$ 29,99–49,99 — **não verificado** | 4,6 na Play Store (~387 mil avaliações), vitalício | Sincronização bancária falha e suporte ausente (Trustpilot); sem bancos BR |
| **YNAB** | Método zero-based ("dê função a cada real") | US$ 14,99/mês ou US$ 109/ano, trial 34 dias, sem plano grátis (verificado out/2026) | Comunidade, workshops, método | Preço, curva de aprendizado, sync bancário (34% das avaliações negativas), app móvel incompleto, não funciona offline |
| **Monarch Money** | Casal/família, "um número" (flex budgeting) | Core US$ 99,99/ano ou US$ 14,99/mês; Plus US$ 199/ano (abr/2026) | "Left to Budget", colaboração doméstica | Preço, sync em bancos menores, rótulo "left to budget" confunde usuários |
| **Rocket Money** | Cancelamento de assinaturas, negociação de contas | Grátis + Premium "pague o que quiser" US$ 6–14/mês; negociação cobra 35–60% da economia | Detecção de assinaturas, poupança automática | Cancelamento difícil, cobranças-surpresa pós-trial (TrustScore 3/5) |
| **Copilot Money** | Apple-only, design premium | ~US$ 13/mês ou ~US$ 95/ano | Design, categorização por IA | Sem Android; splits e reembolsos mal categorizados |
| **Minhas Economias** | Gratuito com anúncios | "Meu Clube" R$ 99,90; R$ 14,90/mês — **não verificado** | 4,31 na Play (51 mil) | Excesso de anúncios |
| **Guiabolso** (histórico) | Pioneiro de agregação bancária | — | 6 mi de usuários | Encerrado em nov/2022 após venda ao PicPay: agregação sem modelo de receita vira recurso de banco |
| **Spendee / Buddy** | Internacionais | Spendee Premium ~US$ 2,99/mês, vitalício US$ 119,99 — **não verificado** | Vitalício | Sync "quase nunca funciona" (Capterra, 2024) |
| **Bots de WhatsApp** (Porquim IA, ZapGastos, Richify, Zap Real) | Registro por áudio/foto | Grátis a R$ 147/ano | Captura sem fricção | Risco regulatório: Meta proíbe chatbots de IA de uso geral no WhatsApp a partir de 15/01/2026 |

Fontes principais: Nubank newsroom; Tecnoblog; Itaú RI (Controle de Gastos, mar/2025); TecMundo; Canaltech; Richify; AppGoblin; mobills.com.br/pricing; Reclame Aqui (Mobills); Finder; Trustpilot; FinCompareLab (YNAB, out/2026); Waypoint (Monarch, out/2026); Mobile Time (Guiabolso, out/2022); Data Hackers; TallyCart blog.

## 2. Como os concorrentes comunicam "dinheiro disponível"

| Produto | Rótulo | Fórmula comunicada | Observação |
|---|---|---|---|
| Monarch | "Left to Budget" / flex budgeting | renda planejada − despesas planejadas | Usuários relatam confusão com o rótulo |
| PocketGuard | "In My Pocket" | saldo − contas − metas | Mais próximo do que queremos; quase em tempo real |
| Simplifi | "Available to spend" | atualizado a cada transação | |
| YNAB | "Ready to Assign" | inverso: todo dinheiro deve ganhar função | Exige adesão ao método |
| Mobills | "Projeção de saldo" | saldo + previstos até fim do mês | Contábil, não comportamental |
| Nubank / Itaú | — | só limites por categoria / cartão | Não existe "sobra" |

**Conclusão:** nenhum app brasileiro independente coloca "quanto posso gastar" como número central com explicação da conta. Essa é a lacuna número um.

## 3. Assistente de carrinho com OCR/código de barras

Nenhum app de finanças pessoais analisado oferece carrinho com leitura de etiqueta e total corrente. Existem apps isolados:

- TallyCart (Android): OCR de etiqueta de gôndola + total, offline. O próprio produto documenta que **código de barras identifica o item, não o preço**; o total exige OCR da etiqueta ou entrada manual — mesma premissa do nosso briefing.
- Cartly (iOS), Cart Tracker (web), CadaEuro: código de barras + total.
- Brasil: SuperList@ (R$ 9,90, código de barras + total), SuperLista (total corrente).
- Dados públicos de preço via NFC-e: programa "Menor Preço" (PR, ES, PE) com milhões de produtos atualizados — fonte candidata para comparação histórica **somente onde existir e com termos de uso verificados**.

## 4. Lacunas no mercado brasileiro

1. Sincronização bancária é a maior dor universal e, no Brasil, o suporte demora 60+ dias. Um produto **manual-first, offline-first**, com Open Finance opcional e claramente separado, evita que falhas de sync destruam a confiança.
2. Nenhum app BR mostra "dinheiro disponível" como número-herói explicável.
3. Ninguém conecta finanças pessoais ao momento da compra (supermercado é o maior gasto variável das famílias).
4. Preços em reais opacos e inconsistentes; vitalício praticamente inexistente no Brasil.
5. Divisão de despesas/casal pouco atendida (lacuna admitida pelo próprio Mobills).
6. Apps internacionais não funcionam offline (YNAB) ou não têm Android (Copilot).

## 5. Oportunidades de diferenciação adotadas no produto

| # | Oportunidade | Como o produto responde |
|---|---|---|
| 1 | "Posso gastar hoje" como número-herói explicável | Widget principal com decomposição (saldo − contas até o fim do mês − fatura atual − reservas), em linguagem simples, nunca como saldo garantido |
| 2 | Carrinho com OCR de etiqueta + código de barras + total corrente + alerta de orçamento | Módulo independente de supermercado (Fase 7) |
| 3 | Fechar o loop compra → lançamento | Ao encerrar a sessão de compras, sugerir lançamento único no módulo financeiro (sem duplicidade) |
| 4 | Histórico de preço por produto e loja do próprio usuário | Modelo de dados preparado (`price_observations`), sem prometer comparação em tempo real |
| 5 | Offline total | SQLite local, sincronização opcional |
| 6 | Preço transparente em R$ com vitalício | Catálogo com mensal, anual e vitalício; política clara do que o vitalício cobre |
| 7 | Orçamento de casal | Arquitetura de sincronização com espaços compartilhados (roadmap, não v1) |
| 8 | Status de sincronização visível | Indicador local/sincronizado/conflito em cada registro |
| 9 | Captura por voz/foto dentro do app | Câmera e OCR nativos, sem depender do WhatsApp |
| 10 | Manual-first, Open Finance opcional e pago | Não prometido na v1; arquitetura de importação (CSV/OFX) com revisão |

## 6. Referências de preço para o catálogo (a validar)

Faixa observada no Brasil: R$ 99,90–119,90/ano; R$ 12–42,90/mês; vitalício R$ 399,90 (Organizze, não verificado). Faixa internacional: US$ 95–109/ano. O catálogo do produto será configurável e os preços finais serão definidos nas consoles das lojas, não no código.
