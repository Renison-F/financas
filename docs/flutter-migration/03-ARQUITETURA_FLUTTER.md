# 03 — Arquitetura Flutter (ADR consolidada)

Status: aceita em 2026-11-04. Inclui a **diretriz adicional de arquitetura** do cliente (crescimento incremental: autenticação, Firebase/backend, sincronização, backup em nuvem, família, Premium) sem implementar serviços de nuvem prematuramente.

## ADR-01 Stack
| Decisão | Escolha (versão verificada no pub.dev em 2026-11-04) | Motivo |
|---|---|---|
| SDK | Flutter 3.47.9 stable / Dart 3.13.7 | canal estável corrente; instalado e validado (`flutter doctor`) |
| Estado | flutter_riverpod 3.4.3 | injeção de dependências + estado reativo testável sem BuildContext |
| Navegação | go_router 18.1.2 | declarativa, deep links, StatefulShellRoute para 5 abas |
| Modelos | freezed 4.0.3 + json_serializable 6.15.2 | imutabilidade, igualdade, JSON para backup/sync |
| Banco | drift 2.35.3 + sqlite3 3.8.0 (native assets, inclui SQLCipher/Multiple Ciphers) | esquema relacional tipado, migrações, transações; `sqlite3_flutter_libs`/`sqlcipher_flutter_libs` estão EOL e foram **rejeitados** |
| Segredos | flutter_secure_storage 11.2.0 (Keystore/Keychain) | chave do banco e verificador de PIN |
| Biometria | local_auth 3.0.2 | gate de UI com fallback de senha do aparelho |
| Câmera/códigos | mobile_scanner 7.5.0 | EAN/UPC/QR com ML Kit no Android e AVFoundation no iOS |
| OCR | google_mlkit_text_recognition 0.17.1 | Latin on-device; parser próprio em Dart |
| Compras | purchases_flutter 11.0.0 | RevenueCat, mesmos IDs de produto |
| Notificações | flutter_local_notifications 22.3.3 | lembretes locais |
| Arquivos | share_plus, file_picker, pdf, printing, path_provider | export/import |
| Decimal | `int` centavos (dinheiro) + `decimal` 3.2.6 para quantidades fracionárias de peso/volume quando exigir precisão além de 3 casas | política explícita |
| Gráficos | fl_chart 1.3.0 | |
| Fontes | google_fonts 9.0.0 (Bricolage Grotesque, OFL), com fallback empacotado em assets | identidade |

## ADR-02 Camadas e dependências
```
features/ (widgets, controllers Riverpod)  →  domain/ (regras puras, entidades, use cases)
                                           →  data/ (Drift, repositórios locais, serviços nativos)
domain/ não importa flutter, drift, firebase ou qualquer SDK.
data/ implementa as interfaces (ports) declaradas em domain/.
```
Regras financeiras rodam em Dart puro (`flutter test` sem widgets) e são verificadas contra os fixtures do TypeScript.

## ADR-03 Ports para crescimento (diretriz do cliente)
Interfaces declaradas em `lib/domain/ports/`, implementadas hoje apenas localmente:
| Port | Implementação v1 | Futuro (não implementado) |
|---|---|---|
| `LedgerRepository` (contas, categorias, tags, cartões, lançamentos, orçamentos, metas, empréstimos) | Drift local | mesma interface sobre cache local + fila de sync |
| `ShoppingRepository` | Drift local | idem |
| `PreferencesStore` | Drift `kv` | idem |
| `ChangeLog` | Drift `change_log` | base da sincronização |
| `AuthProvider` | `AnonymousLocalAuth` (sem conta) | Firebase Auth / outro IdP |
| `SyncTransport` | `NoopSyncTransport` | Firestore ou API própria sobre PostgreSQL |
| `CloudBackupProvider` | não disponível (local apenas) | Storage em nuvem |
| `EntitlementsProvider` | RevenueCat + `UnavailableBilling` | mesma interface |
| `FamilySharePolicy` | `SingleUserPolicy` | espaços compartilhados |

Regras: nenhuma feature chama SDK remoto diretamente; tudo passa pelos ports via Riverpod providers (`lib/app/di.dart`). Firebase/Firestore e PostgreSQL ficam registrados como **alternativas a avaliar** (ADR-07) antes de qualquer definição.

## ADR-04 Identidade e versionamento dos registros
- `id` UUID v4 estável, gerado no aparelho, nunca reutilizado.
- Toda tabela: `created_at`, `updated_at` (UTC ISO-8601), `deleted_at` (exclusão lógica), `version` (inteiro incremental), `device_id`, `dirty` (pendente de envio).
- `change_log(id, entity_type, entity_id, op, payload, version, device_id, at, synced)` grava toda mutação, inclusive importações e restaurações, com `op_id` idempotente.
- Operações idempotentes: toda escrita originada por integração (importação, compra de supermercado, pagamento de fatura, restauração) carrega `external_ref` único; repetir a operação não duplica.

## ADR-05 Conflitos financeiros
Merge por campo com `updated_at` para campos descritivos; **campos monetários e status nunca são resolvidos automaticamente**: geram `Conflict` persistido e visível na UI (estado "conflito" no registro). Política documentada em `02-EQUIVALENCIA_DOMINIO.md` (fixture `sync`).

## ADR-06 Separação de responsabilidades
Armazenamento local (`data/database`), autenticação (`data/auth`), sincronização (`data/sync`), assinaturas (`data/billing`) e backup (`data/backup`) são módulos independentes com interfaces próprias; nenhum importa outro além dos ports do domínio.

## ADR-07 Backend: alternativas a avaliar (não decidido)
| Opção | Prós | Contras | Pré-requisito para decidir |
|---|---|---|---|
| Firebase (Auth + Firestore + Storage) | rapidez, offline SDK, FCM | modelo de dados por documentos, regras de segurança complexas para finanças, custo por leitura | protótipo do `SyncTransport` com regras de segurança e custo estimado |
| PostgreSQL + API própria (ex.: Supabase/Hasura ou serviço Dart/TS) | relacional, transações, auditoria, custo previsível | mais operação | mesmo protótipo com API autenticada |
Decisão só após: política de privacidade publicada, modelo de família definido e teste de carga do change_log.

## ADR-08 Migração de dados entre tecnologias
Flutter **não** lê o banco do app React Native (sandbox e esquema diferentes). Caminho suportado: exportar backup JSON (`serenacash` v1 ou legado `pouso-financas-v2`) no app anterior e importar no Flutter com relatório de importação; futuramente, restauração a partir de backup em nuvem.

## ADR-09 Segurança (resumo; detalhes em 06-SEGURANCA.md)
Banco local cifrado (SQLCipher via sqlite3 3.x) com chave aleatória no Keystore/Keychain; backups com criptografia autenticada (AES-GCM com chave derivada por Argon2id/PBKDF2 de senha do usuário); PIN armazenado apenas como verificador derivado; biometria como gate de UI; sem dados em logs; FLAG_SECURE/ocultação em recents opcional; direitos comerciais só a partir do provedor com cache assinado localmente e expiração.

## ADR-10 SQLCipher via hooks do `package:sqlite3` (decidido em M3)
`sqlite3_flutter_libs`/`sqlcipher_flutter_libs` estão EOL; a partir do `sqlite3` 3.x o binário nativo é
resolvido por hook de build (`hooks.user_defines.sqlite3.source: sqlcipher` no `pubspec.yaml`), que
baixa a build SQLCipher community para cada plataforma. Validado nesta sessão: `PRAGMA cipher_version`
= `4.19.0 community` nos testes Linux. Consequências: licença SQLCipher community (BSD-style) e
OpenSSL no Android/Linux/Windows; build offline exige espelho via `url_pattern`. Alternativa avaliada
e mantida como fallback documentado: SQLite3MultipleCiphers (`source: sqlite3mc`).
