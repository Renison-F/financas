# 00 — Plano mestre da migração SerenaCash → Flutter/Dart

Decisão aprovada pelo cliente em 2026-11-04. Origem congelada em `ae2c229c4977dcc6f78a19e7e4388cacced9d61b`. Branch de migração: `refactor/flutter-serenacash`. A implementação React Native permanece em `apps/mobile` e `packages/*` como referência até paridade comprovada; nada é apagado antes de validado.

## Fases e estado
| Fase | Conteúdo | Estado |
|---|---|---|
| M0 | commit de referência, baseline de testes, branch, auditoria (`01`) | **concluída** |
| M1 | Flutter SDK 3.47.9 instalado, projeto `apps/serenacash_flutter` criado, pubspec com versões verificadas, análise estrita, fixtures (22 arquivos JSON) | **concluída** (CI na M9) |
| M2 | domínio Dart (money, dates, ledger, cards, recurrence, availability, budgets, goals, loans, reports, assistant, billing, io, shopping) + fixtures de equivalência (`02`) | concluído: 22 fixtures, 272 casos TS reproduzidos, 279 testes Dart verdes, analyze limpo (`02-EQUIVALENCIA_DOMINIO.md`) |
| M3 | Drift/SQLite relacional, migrações, criptografia, backup autenticado | concluído: 23 tabelas, SQLCipher validado, 26 testes de dados (`05`, `06`, auditoria parcial) |
| M4 | design system Flutter, temas, navegação (GoRouter), onboarding | concluído: tema claro/escuro/sistema, DI Riverpod, GoRouter 5 abas, onboarding, bloqueio PIN/biometria, i18n pt-BR/en, lembretes locais |
| M5 | núcleo funcional + dashboard 24 widgets | concluído: contas, categorias/tags, cartões (faturas, parcelas, pagamento), orçamentos, metas, empréstimos, calendário, contas a pagar, relatórios, assistente, importação/exportação (CSV/OFX/backup cifrado/PDF), privacidade, ajuda, paywall |
| M6 | relatórios, calendário, projeções, assistente, import/export, configurações | concluído: anexos no lançamento (bytes no banco cifrado), histórico de alterações + estado de sincronização, planejamento anual |
| M7 | listas, sessão, câmera (mobile_scanner), OCR (ML Kit), histórico de preços | concluído: listas, sessão de compra com confirmação obrigatória, mobile_scanner (EAN/UPC/QR NFC-e), OCR ML Kit via port (fallback manual), histórico de preços, despesa idempotente |
| M8 | RevenueCat Flutter, paywall, direitos | pendente |
| M9 | segurança (MASVS), integração, performance | pendente |
| M10 | builds, assinatura, lojas, release candidate | pendente |

## Diretriz adicional de arquitetura (cliente, 2026-11-04)
Crescimento incremental sem reconstrução: regras financeiras independentes de UI e banco; ports/repositórios que aceitem fontes remotas; IDs estáveis, versionamento e rastreabilidade; conflitos financeiros explícitos e operações idempotentes; separação entre armazenamento local, autenticação, sincronização e assinaturas; contratos e pontos de extensão documentados (`03-ARQUITETURA_FLUTTER.md`, ADR-03 a ADR-08); nenhuma dependência de Firebase no domínio; migrações seguras para futuros usuários/dispositivos; SQLite/Drift como banco local; Firebase/Firestore e PostgreSQL registrados como alternativas a avaliar (ADR-07), sem implementação prematura.

## Regras de execução
Commits pequenos por módulo; nenhum merge na main; nenhum histórico reescrito; nenhum `|| true` em gates obrigatórios; nenhuma funcionalidade declarada pronta sem teste; bloqueios de ambiente documentados com o erro exato.

## Ambiente desta sessão (verificado)
- `storage.googleapis.com` e `pub.dev` acessíveis → Flutter SDK e pacotes instaláveis.
- `dl.google.com` **bloqueado** (403 no proxy) → Android SDK command-line tools não baixáveis; `flutter build apk` deverá ser documentado como bloqueado se nenhuma rota alternativa funcionar.
- Sem macOS/Xcode → build iOS fora do alcance; só preparação.
