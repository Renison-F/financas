# 12 — Preparação para publicação (nenhuma publicação foi feita)

## Checklist Android (Google Play)

- [ ] Keystore de release do cliente; `signingConfigs.release` em `build.gradle.kts`.
- [ ] `flutter build appbundle --release --dart-define=RC_ANDROID_KEY=…`.
- [ ] Produtos no Play Console: assinatura `serenacash_plus` (base plans `monthly`, `yearly`), item único `serenacash_lifetime`; vincular ao RevenueCat.
- [ ] Política de privacidade publicada (texto base em `docs/12-guia-publicacao.md` do RN; tela Privacidade do app já descreve o tratamento).
- [ ] Formulário de segurança de dados: nenhum dado coletado; dados financeiros ficam no aparelho; câmera usada sem armazenamento.
- [ ] Teste em trilha interna com compras em sandbox (licenças de teste).
- [ ] Capturas de loja a partir de `docs/flutter-migration/screenshots/` em aparelho real.

## Checklist iOS (App Store)

- [ ] Conta de desenvolvedor, certificado e perfil; `flutter build ipa --release --dart-define=RC_IOS_KEY=…`.
- [ ] Produtos no App Store Connect com os IDs de `billing.dart`; StoreKit Testing local e TestFlight.
- [ ] App Privacy: "Data Not Collected"; descrever câmera e Face ID (`NSFaceIDUsageDescription` é adicionada pelo `local_auth` quando biometria é usada — confirmar no Info.plist antes do envio).
- [ ] Revisão de restauração de compras e termos de assinatura visíveis no paywall (já implementados).

## Compatibilidade de dados com o app anterior

O usuário do app React Native exporta o backup (`serenacash` v1) e importa no Flutter (Mais → Importar). O Flutter não lê o banco antigo (ADR-08). O formato legado `pouso-financas-v2` continua aceito.

## Operações comerciais

Nada foi publicado, nenhum produto foi criado nas lojas e nenhuma chave foi usada. Essas ações exigem autorização explícita do cliente.
