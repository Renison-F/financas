# SerenaCash

Aplicativo de finanças pessoais e compras de supermercado para Android e iOS, mobile-first e offline-first. Nome e identidade definidos em novembro de 2026 (histórico em `docs/03-marca-naming.md`).

**Estado atual:** núcleo financeiro, compras e monetização implementados com testes de domínio e preview web verificado; validação em dispositivos físicos, compras reais nas lojas e OCR em build nativo ainda pendentes. Detalhes em `docs/CHECKPOINT.md` e `docs/07-matriz-funcionalidades.md`.

## Estrutura
```
apps/mobile/        app Expo SDK 58 (React Native 0.88, Expo Router, SQLite)
packages/core/      domínio financeiro puro (centavos inteiros, cartões, orçamentos, empréstimos, relatórios, importação, direitos)
packages/shopping/  domínio de compras (unidades, carrinho, códigos, parser de etiquetas, listas, histórico de preços, sessão)
docs/               produto, pesquisa, marca, UX, arquitetura, regras, planos, testes, guias
brand/              identidade visual (SVG) e gerador de ícones
index.html          app legado (referência funcional; não é mais o produto)
```

## Comandos
```bash
pnpm install
pnpm -r test          # Vitest (core, shopping) + Jest (mobile)
pnpm -r typecheck
cd apps/mobile && npx expo start   # Expo Go: tudo exceto OCR e compras reais
```
Build nativo (câmera + OCR + compras): `docs/11-guia-build.md`. Publicação: `docs/12-guia-publicacao.md`.

## Documentação
`PRODUCT.md` · `DESIGN.md` · `docs/01` auditoria · `docs/02` mercado · `docs/03` naming · `docs/04` identidade · `docs/05` UX · `docs/06` arquitetura · `docs/07` regras e matriz · `docs/08` planos · `docs/09` testes · `docs/10` QA · `docs/11` build · `docs/12` publicação · `docs/CHECKPOINT.md`
