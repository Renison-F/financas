# Relatório final — migração SerenaCash para Flutter/Dart

Branch: `refactor/flutter-serenacash` (a partir de `ae2c229c4977dcc6f78a19e7e4388cacced9d61b`). Sem merge na `main`, sem reescrita de histórico. O app React Native/Expo (`apps/mobile`, `packages/*`) permanece intacto como referência.

## O que foi entregue

| Fase | Entrega | Evidência |
|---|---|---|
| M0 Auditoria | inventário de rotas, regras, entidades, banco, integrações, riscos | `01-AUDITORIA_ORIGEM.md` |
| M1 Base | Flutter 3.47.9, projeto `apps/serenacash_flutter` (`br.com.serenacash.mobile`), ADRs | `03-ARQUITETURA_FLUTTER.md` (ADR-01…10) |
| M2 Domínio | 23 módulos Dart puros; 22 fixtures / 272 casos TS reproduzidos sem divergência; estorno de cartão adicionado | `02-EQUIVALENCIA_DOMINIO.md`, `test/domain` |
| M3 Dados | Drift relacional (23 tabelas, CHECK/FK/índices), SQLCipher via hook do `sqlite3` (fail-closed), chave no Keystore, PIN Argon2id, backup AES-256-GCM, importação v1/cifrada/legado com relatório, change log, conflitos | `05-MIGRACAO_DADOS.md`, `06-SEGURANCA.md`, `test/data` |
| M4–M6 UI | design system do DESIGN.md (claro/escuro/sistema), 5 abas, 46 rotas, 24 widgets/4 presets, todos os módulos, anexos, histórico, planejamento anual, i18n pt-BR/en | `04-UI_DESIGN_SYSTEM.md`, `screenshots/` |
| M7 Compras | listas, sessão, câmera (`mobile_scanner`), OCR (ML Kit) atrás de port, confirmação obrigatória, despesa idempotente | `07-COMPRAS_OCR.md` |
| M8 Monetização | `purchases_flutter` atrás de `StoreBilling`, cache de direitos com carência, paywall | `08-MONETIZACAO.md` |
| M9 Qualidade | 320 testes (domínio, dados, fluxos de app, performance), análise sem issues, formatação, CI sem `|| true`, auditoria MASVS | `09-TESTES.md`, `10-PERFORMANCE.md`, `docs/security/AUDITORIA_FLUTTER.md` |
| M10 Release | manifestos/plist endurecidos, guia de build e publicação, pendências explícitas | `11-BUILD_CI.md`, `12-PUBLICACAO.md` |

## Pendências do escopo original fechadas nesta migração

Estorno de cartão (`card_refund` + validação), anexos (no banco cifrado), tela de histórico de alterações, planejamento anual, i18n, backups protegidos, PIN + biometria, lembretes locais, política de sincronização (change log, conflitos monetários nunca automáticos, transporte como port).

## Diretriz de arquitetura do cliente

Regras financeiras independentes de UI e banco (`lib/domain`), ports para fontes remotas (`lib/domain/ports`), IDs estáveis/versão/rastreabilidade (`version`, `device_id`, `change_log`), conflitos explícitos e operações idempotentes (`external_ref`), módulos separados (`data/database`, `data/security`, `data/backup`, `data/billing`, `data/notifications`), contratos documentados (ADR-03…08), nenhuma dependência de Firebase nas regras, migrações versionadas (`drift_schemas`), SQLite/Drift local, Firebase/Firestore e PostgreSQL registrados como alternativas a avaliar (ADR-07).

## O que NÃO foi possível neste ambiente (e o que falta)

- `flutter build apk --debug`: **falhou** por ausência do Android SDK (`dl.google.com` bloqueado). O workflow de CI compila o APK em runner com SDK. iOS exige macOS.
- `flutter test integration_test`: requer aparelho/emulador; o teste existe em `integration_test/app_test.dart`.
- Validação em aparelho real (câmera, OCR, biometria, notificações, compras em sandbox) e medições de frames.
- Assinatura de release, produtos nas lojas, configuração RevenueCat, política de privacidade publicada: dependem de ações/credenciais do cliente.

## Como continuar

1. Rodar o CI (ou localmente com SDK): `flutter build apk --debug`, instalar e percorrer `docs/13-guia-teste-dispositivo.md`.
2. Configurar RevenueCat e passar as chaves por `--dart-define` (nunca commitar).
3. Após validação em aparelho, decidir a remoção do código RN (não feita: regra "nada é apagado antes de validar").
