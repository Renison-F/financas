# 06 — Segurança (implementação M3; auditoria final em `docs/security/AUDITORIA_FLUTTER.md`)

Referência: OWASP MASVS v2 (STORAGE, CRYPTO, AUTH, RESILIENCE, PRIVACY) e MASTG.

## Dados em repouso

- **Banco cifrado** com SQLCipher 4.x (community), carregado pelo hook nativo do `package:sqlite3`
  (`pubspec.yaml → hooks.user_defines.sqlite3.source: sqlcipher`). O app **recusa abrir** o banco
  se o engine não tiver `PRAGMA cipher_version` (fail-closed, `encryptedExecutor`).
- **Chave do banco**: 256 bits aleatórios (`Random.secure`), gerados no primeiro uso e guardados
  apenas no Keystore (Android) ou Keychain (iOS, `first_unlock_this_device`, sem iCloud). Nunca
  derivada do PIN: trocar o PIN não recifra o banco. `PRAGMA cipher_memory_security = ON`.
  Apagar a chave torna o arquivo irrecuperável ("apagar meus dados").
- **Anexos** ficam dentro do banco (BLOB), portanto cifrados; nunca em diretórios em claro.
- Verificado em teste: cabeçalho do arquivo não é `SQLite format 3`, conteúdo não aparece em claro,
  chave errada falha com erro de HMAC.

## Backups

- Contêiner `serenacash-backup-enc` v1: AES-256-GCM com chave derivada por **Argon2id**
  (64 MiB, 3 iterações, paralelismo 1; mínimo OWASP é 19 MiB/2) de uma senha ≥ 8 caracteres,
  salt de 16 bytes e nonce de 12 bytes aleatórios por arquivo. Cabeçalho (app, formato, versão,
  parâmetros de KDF, salt) é dado adicional autenticado: qualquer alteração invalida o MAC.
- Parâmetros de KDF vindos do arquivo são limitados (≤ 256 MiB, ≤ 10 iterações) para evitar
  negação de serviço por arquivo malicioso.
- Exportação em claro continua disponível (compatibilidade com o app anterior) e será
  acompanhada de aviso explícito na UI.

## PIN e biometria

- PIN de 4 a 8 dígitos guardado apenas como verificador Argon2id (salt aleatório) no Keystore;
  comparação em tempo constante. Nunca em claro, nunca em logs.
- Biometria (`local_auth`) é um gate de interface (M4+); a chave do banco não depende dela.
- `lockOnBackground` nas preferências define bloqueio ao voltar do segundo plano.

## Rede

- Nenhuma chamada de rede no domínio ou na persistência. A única integração remota prevista nesta
  fase é RevenueCat (M8), por SDK oficial, sem segredos no repositório.

## Logs e exposição

- Repositórios e serviços nunca registram valores, chaves ou senhas; erros expõem apenas mensagens
  genéricas para a UI.
- A cobrir em M9: `FLAG_SECURE`/ocultação em recents, verificação de root/jailbreak informativa,
  revisão de permissões (câmera apenas no fluxo de compras), inventário LGPD.

## Checklist MASVS (estado atual)

| Controle | Estado |
|---|---|
| STORAGE-1 dados sensíveis cifrados em repouso | implementado (SQLCipher + Keystore) e testado |
| STORAGE-2 sem vazamento para logs/backup do SO | parcial: logs limpos; `allowBackup=false` e exclusão do Keychain em M9 |
| CRYPTO-1 algoritmos atuais | AES-256-GCM, Argon2id, SHA-256 |
| CRYPTO-2 gestão de chaves | chave aleatória no keystore; nunca hardcoded (testes conferem formato) |
| AUTH-2 autenticação local | PIN com KDF; biometria em M4 |
| RESILIENCE | fora de escopo v1 (app sem anti-tamper); documentado |
| PRIVACY-1 minimização | dados só no aparelho; sem telemetria |
