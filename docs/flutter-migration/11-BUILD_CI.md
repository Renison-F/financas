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

