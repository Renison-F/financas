# SerenaCash

Aplicativo de finanças pessoais e compras de supermercado para Android e iOS, feito para funcionar sem internet, com os dados cifrados no aparelho.

**O produto é o app Flutter** em `apps/serenacash_flutter`. O app Expo/React Native (`apps/mobile`, `packages/`) é a origem da migração: fica congelado como referência de regras e de fixtures, e não recebe mais funcionalidades.

**Estado atual (10/11/2026):** build de homologação 0.2.0+4 entregue para reteste em aparelho físico, depois de uma primeira rodada de testes no celular. Nada está publicado nas lojas. iOS não foi compilado nem testado. O estado real, com o que está pendente, fica em `docs/flutter-migration/CHECKPOINT.md`.

## Estrutura
```
apps/serenacash_flutter/   app Flutter (produto): domínio, banco cifrado, telas, testes
docs/flutter-migration/    plano, arquitetura, dados, testes, homologação e checkpoint do app Flutter
docs/security/             auditoria de segurança do app Flutter
apps/mobile/               app Expo/React Native (legado, congelado)
packages/core, shopping/   domínio em TypeScript (legado; origem das fixtures de equivalência)
docs/01 … 13               documentos da fase React Native (históricos)
brand/                     identidade visual (SVG) e gerador de ícones
index.html                 protótipo antigo (referência funcional)
```

## Comandos (app Flutter)
```bash
cd apps/serenacash_flutter && flutter pub get
```
```bash
dart run build_runner build --delete-conflicting-outputs && flutter gen-l10n
```
```bash
dart format --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test
```
```bash
flutter build apk --release
```
Ambiente Windows, variantes de APK e CI: `docs/flutter-migration/13-SETUP_WINDOWS.md` e `11-BUILD_CI.md`.

## Documentação
`PRODUCT.md` · `DESIGN.md` · `docs/flutter-migration/CHECKPOINT.md` (comece por aqui) · `03` arquitetura · `05` dados e migrações · `06` segurança · `07` compras e OCR · `09` testes · `14` checklist de aparelho · `15` retorno da homologação física · `docs/security/AUDITORIA_FLUTTER.md`

`docs/CHECKPOINT.md` é o checkpoint da fase React Native e está marcado como histórico.
