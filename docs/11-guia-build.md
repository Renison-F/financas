# Guia de compilação

## Requisitos
- Node 22, pnpm 10. `pnpm install` na raiz.
- Conta Expo (EAS) para builds na nuvem; não é necessário Xcode/Android Studio locais.
- Variáveis: copie `apps/mobile/.env.example` para `.env` (chaves públicas do RevenueCat). Em CI/EAS use `eas secret:create`.

## Desenvolvimento rápido (Expo Go)
```bash
cd apps/mobile
npx expo start
```
Funciona: tudo do financeiro, listas, carrinho, leitura de **códigos de barras/QR** (expo-camera). **Não funciona** em Expo Go: OCR de etiquetas (ML Kit, módulo nativo) e compras reais (RevenueCat em modo prévia). O app detecta e cai para entrada manual / paywall sem botões.

## Development build (recomendado para validar câmera + OCR + compras)
```bash
cd apps/mobile
npx eas-cli@latest build --profile development --platform android   # .apk para instalar em aparelho físico
npx eas-cli@latest build --profile development --platform ios       # requer Apple Developer; instala por TestFlight/registro de dispositivo
npx expo start --dev-client
```
Módulos nativos incluídos pelo config plugin / autolinking: expo-camera, expo-sqlite, expo-secure-store, expo-local-authentication, expo-notifications, @react-native-ml-kit/text-recognition, react-native-purchases, react-native-reanimated, react-native-gesture-handler, react-native-svg.

## Preview interno
```bash
npx eas-cli@latest build --profile preview --platform all
```

## Produção
```bash
npx eas-cli@latest build --profile production --platform all
npx eas-cli@latest submit --platform ios|android
```
`eas.json` usa `autoIncrement` e `appVersionSource: remote`. Identificadores: `br.com.serenacash.mobile` (ajustar após registrar o domínio).

## Verificações antes de qualquer build
```bash
pnpm -r typecheck && pnpm -r test && node docs/qa/contrast-check.mjs
cd apps/mobile && npx expo-doctor
```

## Preview web (só para inspeção visual)
```bash
cd apps/mobile && npx expo export --platform web --output-dir /tmp/web && npx http-server /tmp/web -p 8099
```
Na web o banco é em memória (sem SQLite) e não há câmera/OCR/compras; serve para revisar layout e fluxos.

## Problemas conhecidos neste ambiente de desenvolvimento
- `npx expo install` precisa de `EXPO_OFFLINE=1` quando a API do Expo está bloqueada pela rede.
- ML Kit text recognition v2 tem suporte à Nova Arquitetura não verificado pela comunidade (issue aberta); se o build falhar, alternativa: `react-native-vision-camera@5` + `react-native-vision-camera-mlkit@2` (ver pesquisa em `docs/02`). O parser de etiquetas é independente do motor.
