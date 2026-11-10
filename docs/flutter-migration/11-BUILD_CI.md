# 11 — Build e CI

## Local

```bash
cd apps/serenacash_flutter && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter gen-l10n
```

```bash
flutter build apk --debug
```

```bash
flutter build apk --release --dart-define=RC_ANDROID_KEY=$RC_ANDROID_KEY
```

```bash
flutter build ipa --release --dart-define=RC_IOS_KEY=$RC_IOS_KEY
```

Chaves RevenueCat entram por `--dart-define` (ou secrets do CI); nunca no repositório.

## Resultado neste ambiente

- `flutter build apk --debug` → falha: `No Android SDK found. Try setting the ANDROID_HOME environment variable.` (`dl.google.com` bloqueado pelo proxy; `flutter doctor` confirma "Unable to locate Android SDK"). Não há macOS para `flutter build ipa`.
- Tudo o que não depende de SDK nativo foi executado e passou: `pub get`, geração de código, `format`, `analyze`, `test` (317), `test/perf`.

## CI (`.github/workflows/flutter.yml`)

Job `gates`: Flutter 3.47.9 → `pub get` → `build_runner` → `gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze --fatal-infos` → `flutter test --coverage` (artefato lcov). Job `android`: Java 17 + Android SDK do runner → `flutter build apk --debug` (artefato `app-debug.apk`). Nenhum passo usa `|| true` ou `continue-on-error`. O workflow RN (`ci.yml`) continua ativo para o código de referência.

## Hooks nativos

O `package:sqlite3` baixa o binário SQLCipher na primeira compilação (`hooks.user_defines.sqlite3.source: sqlcipher`); em CI sem acesso ao GitHub Releases, configure `url_pattern` para um espelho interno (ver `03-ARQUITETURA_FLUTTER.md`, ADR-10).

## Android

`applicationId br.com.serenacash.mobile`, `allowBackup=false` com `data_extraction_rules` excluindo tudo, permissões: câmera (opcional), notificações, internet, billing. Assinatura de release: pendente (keystore do cliente; `build.gradle.kts` ainda assina com debug e está marcado com TODO).

## iOS

Bundle `br.com.serenacash.mobile`, `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `ITSAppUsesNonExemptEncryption=false` (criptografia de dados locais padrão). Capacidades a ativar no Xcode: In-App Purchase, Push (não usado), Keychain Sharing (não necessário).

## Variantes de APK (05/11/2026)

| Variante | Comando | Para que serve |
|---|---|---|
| Debug | `flutter build apk --debug` | Desenvolvimento. Depurável, mais lento, maior. |
| Homologação interna | `flutter build apk --release` | Testes em aparelho. Comportamento de release (R8, sem depuração), assinado com a chave de debug da máquina que compilou. Não vale para loja. |
| Comercial (futuro) | `flutter build appbundle --release` com `signingConfig` próprio | Publicação. Exige a chave definitiva, fora do repositório, e as chaves do RevenueCat por `--dart-define`. |

Um APK assinado por uma máquina não atualiza por cima de um APK assinado por outra (o do CI, por exemplo): o Android pede para desinstalar antes, e isso apaga os dados. Para manter os dados entre versões de teste, instale sempre APKs compilados na mesma máquina, ou exporte um backup antes de trocar.

Instalação isolada para testes que apagam dados: `SERENA_APP_ID_SUFFIX=.seg flutter build apk --debug` gera o pacote `br.com.serenacash.mobile.seg` ("SerenaCash teste"), que convive com o app normal.

Depois de `flutter test integration_test`, o arquivo `app-debug.apk` do diretório de build é o do teste. Gere o build de novo antes de distribuir e confira que `kernel_blob.bin` não contém `integration_test/app_test.dart`.

## Build 0.2.0+3 (10/11/2026)

| | Homologação | Debug |
|---|---|---|
| Arquivo | `E:\SerenaCash\homologacao-0.2.0\serenacash-0.2.0+3-homologacao-f1b3b47.apk` | `…\serenacash-0.2.0+3-debug-f1b3b47.apk` |
| Comando | `flutter build apk --release` | `flutter build apk --debug` |
| Tamanho | 132.755.640 bytes | 254.588.599 bytes |
| SHA-256 | `d0de4b2c34976863d6c42ab84048225d3d7ec7f82d744d0d6dd80243b84a18c8` | `5cca23ea6f06d9bc7c9d5ef6eb1d1120f99e7d78b5653613a58015fa944bdf65` |

Commit do código `f1b3b47`, `versionName 0.2.0`, `versionCode 3`, Application ID `br.com.serenacash.mobile`, `minSdk 24`, `targetSdk 36`, certificado "Android Debug" desta máquina (`e7c911bb…16e5`), o mesmo da build 0.1.0+2. O número do build aparece no rodapé do menu ("versão 0.2.0 (build 3)").

Permissões novas em relação à 0.1.0+2: `RECORD_AUDIO` (ditar item) e `WRITE_EXTERNAL_STORAGE` com `maxSdkVersion=28`, declarada pelo plugin da câmera (o Android acrescenta `READ_EXTERNAL_STORAGE` por implicação). O app não pede acesso a armazenamento em tempo de execução.

Dependências novas: `camera` e `speech_to_text`. O arquivo de debug foi conferido: não é a build do `integration_test`.

O CI não rodou sobre estes commits: eles estão só neste computador até o envio ser autorizado.

### Instalar por cima da versão anterior

A build 0.2.0+3 atualiza a 0.1.0+2 sem desinstalar, desde que as duas tenham sido compiladas neste PC (mesmo certificado). Roteiro e resultado do ensaio em `15-RETORNO_HOMOLOGACAO_FISICA.md`, "Atualização sobre a versão anterior". Exporte um backup cifrado antes; não existe caminho de volta para a 0.1.0.

## Build 0.2.0+4 (10/11/2026)

Completa as ocorrências que a 0.2.0+3 deixou parciais. `versionName 0.2.0`, `versionCode 4`, mesmo Application ID, mesmos SDKs, mesmo certificado de debug deste PC: instala por cima da 0.1.0+2 e da 0.2.0+3. Não há migração de banco entre a 0.2.0+3 e a 0.2.0+4.

Sem permissão nova e sem dependência nova. A consulta opcional ao catálogo usa a permissão de internet que já existia.

Arquivos, tamanhos e SHA-256: no `CHECKPOINT.md` e no `LEIA-ME.md` da pasta `E:\SerenaCash\homologacao-0.2.0+4\`.
