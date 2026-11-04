# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Stack

delegated: React Native com Expo SDK 58 (React Native 0.88, Nova Arquitetura, Expo Router), TypeScript estrito, SQLite local (expo-sqlite) com migrações, pacotes de domínio puros (`packages/core`, `packages/shopping`) testados com Vitest. Escolhido por: uma base de código para Android e iOS com componentes nativos, câmera e leitura de códigos de primeira linha (expo-camera), OCR on-device via ML Kit em development build, compras integradas via RevenueCat/StoreKit 2/Play Billing, builds e publicação via EAS sem Xcode/Android Studio locais. Decisão detalhada em `docs/06-arquitetura-tecnica.md`.

## Users

Usuário principal: uma pessoa adulta no Brasil, com pouco ou nenhum conhecimento financeiro, exigente com a qualidade dos apps que usa, que abre o aplicativo em momentos curtos (fila, ônibus, corredor do supermercado) e quer uma resposta imediata: quanto dinheiro realmente tem, quanto pode gastar sem comprometer as contas, o que vence, para onde o dinheiro foi e o que fazer agora.

Audiência secundária (confirmada no briefing): usuários avançados que querem controles detalhados (cartões com fatura, parcelamentos, empréstimos, orçamentos por categoria, relatórios, importação OFX/CSV). A profundidade existe, mas é revelada progressivamente; nunca na frente do número principal.

Cenários de uso factuais: tela inicial consultada várias vezes por dia; cadastro de despesa em segundos; sessão de compras no supermercado com uma mão, com reflexos na etiqueta e sinal de internet fraco; revisão mensal de contas e cartões.

## Product Purpose

Prumo é um aplicativo de gestão financeira pessoal, mobile-first, offline-first, para Android e iOS, com dois módulos independentes e integráveis: listas de compras e assistente de supermercado (câmera, leitura de etiquetas de preço e códigos de barras, carrinho com total corrente e orçamento). Existe para transformar o gerenciamento do dinheiro em uma experiência clara, confiável e agradável para quem não entende de finanças, sem abrir mão da profundidade para quem entende.

Sucesso: o usuário entende sua situação em poucos segundos ao abrir o app; registra o dia a dia sem fricção; sai do supermercado sem surpresa no caixa; e paga por um plano Premium (mensal, anual ou vitalício) porque o produto se prova útil no plano gratuito.

## Positioning

"Pode gastar" é o número-herói: quanto dá para gastar hoje, calculado só com o que está registrado (saldos − contas até o fim do mês − fatura atual − reservas), sempre com a conta exposta e nunca apresentado como saldo garantido. Nenhum app brasileiro independente entrega esse número explicado, e nenhum app de finanças pessoais analisado conecta esse número ao momento da compra: o assistente de supermercado mostra quanto ainda cabe no orçamento da compra enquanto o carrinho cresce. Tudo funciona sem internet e sem conexão bancária, o que elimina a maior causa de reclamações dos concorrentes (sincronização quebrada e suporte ausente).

## Operating Context

- Registro manual é a fonte primária de dados; importação CSV/OFX com revisão prévia e prevenção de duplicidades; conexão bancária (Open Finance) não faz parte da v1 e não deve ser prometida.
- Moeda padrão BRL, formato pt-BR; arquitetura preparada para outros idiomas e moedas (todos os textos em catálogo de strings, todo valor em inteiros de centavos com moeda explícita).
- Supermercado: etiquetas de gôndola brasileiras (preço, preço por kg/L, promoção "de/por", código interno), código de barras EAN-13/EAN-8/UPC em produtos, QR Code da NFC-e no cupom. Código de barras identifica o produto, não o preço; o preço vem da etiqueta lida, do histórico local ou de confirmação manual.
- Lojas: Google Play (Play Billing 8+) e App Store (StoreKit 2); assinaturas mensal e anual e compra única vitalícia (não consumível); restauração de compras obrigatória; políticas de privacidade e exclusão de conta exigidas.
- Dados financeiros são sensíveis: armazenamento local protegido, biometria opcional, exportação e exclusão de dados pelo usuário, logs sem dados pessoais, nenhum segredo no repositório.

## Capabilities and Constraints

Confirmado para construir (ver `docs/07-matriz-funcionalidades.md` para o estado real de cada item):
- Contas e carteiras; receitas; despesas (fixas, variáveis, recorrentes, parceladas, pagamento parcial, anexos); cartões de crédito com fatura, limite, parcelamento e regra de não dupla contagem; orçamentos; metas e reservas; empréstimos (Tabela Price, amortizações, simulação de quitação); relatórios e projeções; calendário; busca; categorias, subcategorias e tags; exportação CSV/PDF e backup; importação CSV/OFX com revisão.
- Tela inicial personalizável com widgets reais (mostrar/ocultar, reordenar por arrastar e por controles acessíveis, modelos, períodos, contas consideradas, modo privacidade), preferências persistidas.
- Listas de compras (múltiplas, unidades: un, kg, g, L, mL, pacote, dúzia; categorias; histórico; estimativa e planejado × realizado; offline).
- Assistente de supermercado: sessão de compras, carrinho determinístico (unidade, peso, desconto, promoção), orçamento da compra, leitura de códigos de barras e QR, OCR de etiquetas com confiança e confirmação obrigatória, histórico local de produtos e preços, lançamento opcional no módulo financeiro sem duplicidade.
- Assistente financeiro: respostas determinísticas sobre os dados do usuário; recomendações por regras transparentes; IA externa opcional, nunca obrigatória para o essencial.
- Monetização: catálogo de planos, motor de direitos de acesso, paywall, restauração, expiração, cancelamento, reembolso.

Restrições e decisões explícitas:
- Dinheiro nunca em ponto flutuante: inteiros de centavos; arredondamento só em fronteiras explícitas (peso, juros, parcelas) e documentado.
- "Pode gastar" é uma estimativa com decomposição visível; nunca um saldo garantido.
- Nenhuma tela falsa: funcionalidade não implementada não aparece como pronta.
- Nenhum preço fictício como se fosse real; preços no app vêm do usuário, da etiqueta lida ou do histórico do próprio usuário.
- Recursos nativos (câmera, OCR, compras, notificações) só são considerados validados em dispositivo/emulador, não em navegador.

Terminologia do produto: "Pode gastar" (dinheiro disponível), "No prumo / fora do prumo" (ritmo de gastos em relação ao previsto), "Contas" (carteiras/contas bancárias), "Lançamento" (transação), "Fatura", "Parcela", "Reserva" (meta/dinheiro separado), "Lista", "Compra" (sessão no supermercado), "Carrinho".

Indefinido (não inventar): preços finais dos planos (serão definidos nos consoles das lojas); provedor de sincronização entre dispositivos (arquitetura preparada, serviço não escolhido); provedor de IA para o assistente opcional.

## Brand Commitments

Nome comercial: **Prumo** (recomendado na rodada 2 de `docs/03-marca-naming.md` após rejeição de "Cabe" pelo cliente; pendente de busca no INPI). O nome é também vocabulário da interface ("mês no prumo", "fora do prumo"). Símbolo: fio de prumo (cordão + peso de latão). Voz: direta, calorosa, sem jargão, verbos no presente, nunca culpabiliza. Não herdar nome, cores, fontes, emojis ou layout do app legado "Pouso/Finanças POP!" nem da marca rejeitada "Cabe". Identidade visual própria em `DESIGN.md` e `docs/04-identidade-visual.md`; ativos em `brand/`.

## Evidence on Hand

- `index.html` (app legado): referência funcional e de regras financeiras, auditado em `docs/01-auditoria-legado.md`.
- `docs/02-pesquisa-mercado.md`: análise de concorrentes com fontes; preços de concorrentes marcados como não verificados quando aplicável.
- Não existem usuários, depoimentos, métricas, parcerias com supermercados, catálogo de produtos licenciado ou dados de preços reais. Nada disso pode ser fabricado em telas, lojas ou materiais.

## Product Principles

1. **O número antes do relatório.** Toda tela responde primeiro "e daí para mim?"; detalhes vêm por progressive disclosure.
2. **Honestidade contábil.** Cada valor mostrado pode ser explicado com um toque; estimativas se declaram estimativas.
3. **Funciona no corredor do mercado.** Uma mão, offline, luz ruim, pressa: o fluxo principal nunca depende de rede nem de precisão de toque fina.
4. **Linguagem de gente.** Sem jargão contábil; "vence", "falta", "cabe", "sobra".
5. **Simples por fora, completo por dentro.** Recursos avançados existem, testados, e aparecem quando o usuário os procura.

## Accessibility & Inclusion

Alvos: WCAG 2.2 AA para contraste (≥ 4,5:1 texto, ≥ 3:1 texto grande e ícones), áreas de toque ≥ 44×44 pt (iOS) / 48×48 dp (Android), suporte a Dynamic Type/escala de fonte do sistema até 200% sem corte de valores monetários, leitores de tela (VoiceOver/TalkBack) com rótulos em português para todos os controles e valores, redução de movimento respeitada, modo privacidade (ocultar valores) e feedback tátil opcional. Valores monetários lidos por leitor de tela como "mil duzentos e trinta e quatro reais e cinquenta e seis centavos", não como dígitos soltos.
