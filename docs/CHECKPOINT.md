# Checkpoint de desenvolvimento — 2026-11-04

> **Arquivo histórico.** Este checkpoint é da versão React Native/Expo. O trabalho atual é o app Flutter na branch `refactor/flutter-serenacash`; o checkpoint em vigor é `docs/flutter-migration/CHECKPOINT.md`.

Branch: `claude/wonderful-knuth-30ejqq`. Leia este arquivo antes de continuar em outra sessão.

## Decisões fechadas
- **Marca: SerenaCash** (nome do cliente após rejeitar "Cabe" e "Prumo"). Identidade "água parada ao amanhecer": sereno (#0B5563), aurora (#C0703E), névoa (#F3F6F5), noite (#0C1517); claro/escuro/automático. Fonte Bricolage Grotesque (títulos/números) + sistema (corpo). Nunca reutilizar Pouso/Cabe/Prumo.
- **Stack:** Expo SDK 58 / RN 0.88 / Expo Router / expo-sqlite / zustand; monorepo pnpm com `packages/core` e `packages/shopping` puros e testados (Vitest); app testada com Jest.
- **Dinheiro:** inteiros em centavos; regras em `docs/07-regras-financeiras.md`.
- **Terminologia:** "Pode gastar", estados "sereno / atenção / agitado", "marca de hoje".
- **Monetização:** free / Plus mensal / Plus anual / Sempre (vitalício sem sync); RevenueCat via adapter; preços nas lojas.
- **Impeccable** instalado em `.claude/skills/impeccable` (cópia do plugin 4.8.0, Apache-2.0; o download oficial estava bloqueado); `PRODUCT.md` e `DESIGN.md` seguem os esquemas do Impeccable; auditoria em `docs/10`.

## Estado por fase
| Fase | Estado |
|---|---|
| 1 Auditoria e mercado | concluída (`docs/01`, `docs/02`) |
| 2 Marca | concluída com nome do cliente (`docs/03`, `docs/04`, `DESIGN.md`, `brand/`) |
| 3 UX | concluída (`docs/05`) |
| 4 Arquitetura | concluída (`docs/06`), scaffold e persistência |
| 5 Núcleo financeiro | concluída (domínio + telas + testes) |
| 6 Módulos avançados | concluída (relatórios, calendário, empréstimos, projeções, import/export) |
| 7 Compras e supermercado | implementada; **validação em aparelho pendente** (câmera/OCR) |
| 8 Monetização | implementada; **integração real com lojas pendente** (chaves, produtos, sandbox) |
| 9 Qualidade | automatizado verde; dispositivo pendente (`docs/10`) |
| 10 Publicação | preparada, não executada (`docs/12`) |
| Build EAS | configurado e validado (prebuild OK, expo-doctor 18/20); **builds não gerados**: sem `EXPO_TOKEN` e rede da sessão bloqueia `api.expo.dev` (`docs/13`) |

## Pendências ordenadas (próxima sessão)
0. Liberar `api.expo.dev`/`expo.dev`/`exp.host` na rede do ambiente e definir `EXPO_TOKEN` (ou rodar o workflow EAS no GitHub) → gerar development builds (`docs/13` §4).
1. Gerar development build (EAS) e validar em Android + iPhone: câmera/códigos, OCR (trocar motor se ML Kit falhar na Nova Arquitetura), biometria, notificações, arrastar e soltar, SQLite real.
2. INPI/domínio/handles para SerenaCash; fixar identificadores de pacote.
3. RevenueCat + produtos nas lojas + sandbox; testar restauração/carência/reembolso.
4. `/impeccable adapt` (tablet/paisagem) e `/impeccable polish` (cabeçalhos nativos, Switch/SegmentedControl do sistema); animação da marca de hoje.
5. Tela de anexos (Plus), tipo `card_refund`, histórico de alterações (change_log), i18n com catálogo de strings, PIN + backup criptografado.
6. Sincronização: escolher provedor e implementar `SyncTransport`; status local/sincronizado/conflito na UI.
7. Capturas e textos das lojas a partir de builds reais; política de privacidade publicada.

## Como rodar
```bash
pnpm install && pnpm -r test && pnpm -r typecheck
cd apps/mobile && npx expo start
```
Comandos de build/publicação: `docs/11`, `docs/12`. Convenção de commits: pequenos, em português, com escopo (`feat(core)`, `feat(mobile)`, `docs`).
