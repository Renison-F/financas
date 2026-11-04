# 05 — Migração e persistência de dados

## Decisão: esquema relacional (Drift) em vez de tabelas de documentos JSON

O app React Native guardava cada entidade como `json TEXT` em tabelas de documentos. O Flutter usa
um esquema relacional tipado (`apps/serenacash_flutter/lib/data/database/tables.dart`) gerado pelo
Drift 2.35, com:

| Tabela | Chave | Restrições principais | Índices |
|---|---|---|---|
| `accounts` | `id` | `type IN (cash, checking, savings, digital_wallet, investment, other)`, `name <> ''`, moeda 3 letras | `deleted_at` |
| `categories` | `id` | `kind IN (income, expense)`, `parent_id → categories` | `parent_id` |
| `tags` | `id` | `name <> ''` | — |
| `credit_cards` | `id` | `limit_cents ≥ 0`, `closing_day`/`due_day` entre 1 e 31, `default_payment_account_id → accounts` | — |
| `transactions` | `id` | `kind` e `status` em listas fechadas, `amount_cents ≥ 0`, `paid_cents ≥ 0`, FKs para contas, categoria, cartão, meta, empréstimo e `refund_of_id → transactions` | `date`, `(kind,date)`, `account_id`, `(card_id, invoice_month)`, `category_id`, `series_id`, `due_date`, `deleted_at`, **único parcial** `external_ref` |
| `transaction_tags` | `(transaction_id, tag_id)` | FKs com `ON DELETE CASCADE` | `tag_id` |
| `attachments` | `id` | `transaction_id → transactions CASCADE`, `size_bytes ≤ 10 MiB`, `sha256` de 64 hex, bytes em `BLOB` dentro do banco cifrado | `transaction_id` |
| `budgets`, `goals`, `loans`, `recurrence_rules` | `id` | valores monetários ≥ 0, `system IN (price, sac)`, `frequency` fechada, `template_transaction_id → transactions` | `month` |
| `shopping_lists`, `shopping_list_items`, `products`, `product_internal_codes`, `price_observations`, `shopping_sessions`, `shopping_session_lines`, `shopping_session_events` | `id` / compostas | quantidades e preços ≥ 0, `status` fechado, FKs em cascata | `barcode`, `(product_id, observed_at)`, `status`, `started_at` |
| `kv` | `key` | preferências, layout do painel, flags | — |
| `change_log_entries` | `id` | `op IN (upsert, delete, restore)` | `(synced, at)`, `(entity_type, entity_id)` |
| `conflicts` | `(entity_type, entity_id, field)` | conflitos monetários persistidos (ADR-05) | — |
| `import_reports` | `id` | relatório JSON de cada importação | — |

Colunas de versionamento em toda tabela de negócio (ADR-04): `created_at`, `updated_at`,
`deleted_at` (exclusão lógica), `version`, `device_id`, `dirty`.

`PRAGMA foreign_keys = ON`, `secure_delete = ON` e `busy_timeout` são aplicados em `beforeOpen`.
Toda escrita do repositório roda em `transaction()`: ou tudo é gravado ou nada (teste
`CHECK and FOREIGN KEY constraints reject invalid rows and keep the batch atomic`).

## Migrações

- `schemaVersion = 1`. O dump oficial está em `apps/serenacash_flutter/drift_schemas/drift_schema_v1.json`
  (gerado por `dart run drift_dev schema dump`). Cada versão futura acrescenta um passo em
  `_upgradeStep` e um teste de migração a partir do dump anterior; o `PRAGMA user_version` é
  verificado em teste.
- Dados vindos do RN **não** são lidos do banco anterior (sandbox e esquema diferentes, ADR-08).

## Repositórios (ports do domínio)

`lib/domain/ports/` declara `LedgerRepository`, `ShoppingRepository`, `PreferencesStore`,
`ChangeLog`, `AuthProvider`, `SyncTransport`, `CloudBackupProvider`, `EntitlementsProvider`,
`FamilySharePolicy`, `Clock` e `IdGenerator`. As implementações Drift ficam em `lib/data/database/`.
O domínio nunca importa Drift; a UI nunca importa Drift.

Regras implementadas:
- **Idempotência**: `upsertTransaction` com `externalRef` já existente retorna `alreadyApplied` e
  não grava (índice único parcial + verificação prévia). Compras de supermercado usam
  `shopping:<sessionId>`; importações usam o identificador do arquivo.
- **Change log**: toda mutação (inclusive restauração e anexos) gera `ChangeRecord` com
  `id = <at>-<tipo>-<id>-<versão>` e `synced = false`.
- **Exclusão lógica + restauração**: `softDelete`/`restore` preservam o registro e os anexos.
- **Anexos**: bytes gravados como BLOB no banco cifrado, com `sha256` conferido na gravação e na
  leitura (corrupção é detectada).

## Backups e importação

| Formato | Detecção | Uso |
|---|---|---|
| `serenacash` schema v1 (JSON em claro) | `app == "serenacash"`, `schemaVersion ≤ 1` | compatível com o app RN; ganha as chaves opcionais `attachments` (base64) e `recurrenceRules` |
| `serenacash-backup-enc` v1 | `format == "serenacash-backup-enc"` | contêiner cifrado e autenticado (ver `06-SEGURANCA.md`) |
| legado `pouso-financas-v2` | `isLegacyBackup` (identificador interno) | importador pré-existente do domínio |

`BackupService.importFromText` valida (estrutura + integridade referencial com mensagens legíveis),
grava um `ImportReport` (`import_reports`) com contagens, avisos e erros, e só então substitui os dados
em uma única transação. Em qualquer erro o banco atual permanece intacto (testado).

## Testes (apps/serenacash_flutter/test/data)

| Arquivo | Cobre |
|---|---|
| `ledger_repository_test.dart` | esquema/índices/`user_version`, round-trip exato do ledger de fixture, versão/dirty/log, idempotência, CHECK/FK atômicos, exclusão lógica, etiquetas/anexos com hash, stream, purge, prefs |
| `shopping_repository_test.dart` | listas, sessões com promoção/eventos, produtos, observações, FK |
| `encryption_test.dart` | arquivo cifrado (SQLCipher), chave errada falha, cabeçalho não é SQLite, dados não aparecem em claro |
| `security_test.dart` | PIN com Argon2id, comparação em tempo constante, contêiner de backup (round-trip, senha errada, adulteração do corpo e do cabeçalho, limites de KDF) |
| `backup_service_test.dart` | exportação/importação em claro e cifrada, legado, relatórios, erros sem efeitos colaterais |

Execução: `flutter test test/data` (26 testes). Suíte completa: 305 testes verdes.
