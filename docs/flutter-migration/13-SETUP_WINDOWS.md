# 13 — Preparar um PC Windows para desenvolver o SerenaCash Flutter

Script: `apps/serenacash_flutter/tool/windows/setup-serenacash.ps1` (idempotente; pede aprovação em cada etapa; `-DryRun` só mostra o plano; nada é apagado; só altera variáveis do **usuário**, o Flutter em `C:\dev\flutter` e o clone em `C:\dev\financas`).

## Pré-requisitos no PC
- Windows 10 (1903+) ou 11, 64 bits, ≥ 15 GB livres, virtualização ativada no BIOS (para o emulador).
- Em `E:\`: `flutter_windows_<versão>-stable.zip` (3.47.x ou mais novo) e `android-studio-<versão>-windows.exe`.
- Git (o script oferece instalar com `winget` se faltar).

## Como rodar (PowerShell, não precisa de administrador)
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/Renison-F/financas/refactor/flutter-serenacash/apps/serenacash_flutter/tool/windows/setup-serenacash.ps1 -OutFile E:\setup-serenacash.ps1
```

```powershell
E:\setup-serenacash.ps1 -DryRun
```

```powershell
E:\setup-serenacash.ps1
```

O script para de propósito uma vez, após instalar o Android Studio, pedindo que você abra o Android Studio, conclua o assistente inicial (que instala o SDK) e, no SDK Manager → SDK Tools, marque **Android SDK Command-line Tools (latest)** e **Android Emulator**. Depois rode o script de novo: ele continua de onde parou. As licenças do SDK são aceitas por você, interativamente (`flutter doctor --android-licenses`).

## O que ele faz, por etapa
1. Inspeciona Windows, disco, Git/Flutter/Java/adb existentes, Android Studio e SDK; lista o que há em `E:\`.
2. Git (instala via winget só se faltar).
3. Extrai o Flutter para `C:\dev\flutter` (ou reutiliza um Flutter já no PATH) e adiciona `C:\dev\flutter\bin` ao PATH do usuário (Dart vem junto).
4. Instala o Android Studio (`/S`) só se não existir; define `JAVA_HOME` para o JBR do Studio.
5. Define `ANDROID_HOME`/`ANDROID_SDK_ROOT`; instala pelo `sdkmanager` o que faltar: platform-tools, `platforms;android-35`, build-tools 35, emulator, imagem `android-35 google_apis x86_64` e `ndk;28.2.13676358` (versão que o Flutter 3.47 exige; `-NdkVersion` muda); adiciona `platform-tools` ao PATH. Um `ANDROID_HOME` já configurado é respeitado mesmo que a pasta ainda não exista.
6. Plugins Flutter e Dart via `studio64.exe installPlugins Dart io.flutter` (Studio fechado) ou manualmente pelo Marketplace.
7. `flutter config --android-sdk/--android-studio-dir` e aceite interativo das licenças.
8. `flutter doctor -v` salvo em `E:\SerenaCash\flutter-doctor.txt`.
9. Clona `Renison-F/financas` na branch `refactor/flutter-serenacash` (ou `fetch` + `pull --ff-only` se já existir). Nunca toca na `main`.
10. `flutter pub get`, `dart run build_runner build`, `flutter gen-l10n`.
11. `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos`, `flutter test` (log em `E:\SerenaCash\flutter-test.txt`).
12. `flutter build apk --debug` → copia para `E:\SerenaCash\serenacash-debug-<commit>.apk` com SHA-256.
13. Cria o AVD `serenacash_api35` (Pixel 7), inicia, espera o boot, instala e abre o app. `-SkipEmulator` pula.
14. Gera `E:\SerenaCash\relatorio-setup.md` com o resultado de cada etapa.

## Abrir no Android Studio
File → Open → `C:\dev\financas\apps\serenacash_flutter`. Selecione o emulador e use Run (▶) ou `flutter run` no terminal para hot reload. Os testes rodam com `flutter test`; o teste em aparelho com `flutter test integration_test`.

## Dados de teste
Use apenas dados fictícios. O onboarding cria uma conta a partir de qualquer valor; o import aceita o backup de exemplo em `docs/flutter-migration/fixtures/io.json` (caso `importLegacy`) se precisar de massa de dados.

## Problemas comuns
- `NDK at ... did not have a source.properties` ou NDK ausente: o Flutter Gradle Plugin exige o NDK 28.2.13676358. O script o instala pelo `sdkmanager`; manualmente, marque "NDK (Side by side)" 28.2.13676358 em SDK Manager > SDK Tools (mostrar detalhes do pacote).
- `coreLibraryDesugaring` / `flutter_local_notifications requires desugaring`: já tratado em `android/app/build.gradle.kts` (desugar_jdk_libs 2.1.4). Se aparecer, o clone está antes do commit `82000bc`; faça `git pull --ff-only`.
- `unable to find directory entry in pubspec.yaml` para `assets/brand` ou `assets/fixtures`: idem, clone antes do commit `79bf3fa`.
- `No Android SDK found`: termine o assistente do Android Studio e rode o script de novo.
- Emulador não inicia: ative Hyper-V/Windows Hypervisor Platform (Recursos do Windows) ou a virtualização no BIOS.
- Primeiro build demora: o Gradle baixa dependências e o `package:sqlite3` baixa o binário SQLCipher do GitHub Releases; precisa de internet.
- Antivírus lento: exclua `C:\dev\flutter` e `C:\dev\financas` da verificação em tempo real (opcional).
