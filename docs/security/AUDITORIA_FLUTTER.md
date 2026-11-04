# Auditoria de segurança — SerenaCash Flutter (em andamento)

Última atualização: M3 (persistência). Auditoria final consolidada em M9.

## Escopo auditado até aqui
- `apps/serenacash_flutter/lib/data/database/*` (Drift/SQLCipher)
- `apps/serenacash_flutter/lib/data/security/*` (chave do banco, PIN, backup cifrado)
- `apps/serenacash_flutter/lib/data/backup/*`

## Achados e evidências

| # | Item | Resultado | Evidência |
|---|---|---|---|
| A1 | Banco local cifrado em repouso | OK | `test/data/encryption_test.dart` (cabeçalho não SQLite, dados não em claro, chave errada falha) |
| A2 | Chave do banco fora do código e fora do banco | OK | `DatabaseKeyManager` usa `SecretStore` (Keystore/Keychain); testes usam `InMemorySecretStore` |
| A3 | Fail-closed quando o engine não é SQLCipher | OK | `encryptedExecutor` lança `DatabaseKeyError` se `PRAGMA cipher_version` vazio |
| A4 | Backup cifrado autenticado | OK | `test/data/security_test.dart` (adulteração de corpo e cabeçalho rejeitada) |
| A5 | PIN nunca em claro | OK | verificador Argon2id + salt; teste confere ausência do PIN no armazenamento |
| A6 | Integridade de anexos | OK | SHA-256 conferido na gravação e na leitura |
| A7 | Integridade referencial do banco | OK | FKs + CHECK + `integrityCheck()` em testes |
| A8 | Idempotência de operações de integração | OK | índice único parcial `external_ref` + `WriteOutcome.alreadyApplied` |
| A9 | Segredos no repositório | OK | nenhum; tokens fora do git (ver guia de build) |

## Pendências para M9
- `android:allowBackup="false"` e `fullBackupContent` vazio; `FLAG_SECURE` opcional; exclusão do Keychain ao reinstalar (iOS).
- Revisão de permissões (câmera só no fluxo de compras; sem localização).
- Inventário LGPD (dados tratados, base legal, retenção, exclusão) e tela "Apagar meus dados".
- Análise de dependências (`flutter pub outdated`, licenças SQLCipher/OpenSSL no Android).
