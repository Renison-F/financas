# Guia de publicação (preparação; nenhuma publicação foi feita)

## 1. Identidade nas lojas
- Nome: **SerenaCash** (verificar INPI e disponibilidade do nome nas lojas; `docs/03`).
- Subtítulo (iOS, 30 car.): "Finanças e compras sem ansiedade".
- Descrição curta (Android, 80 car.): "Saiba quanto pode gastar e faça compras sem surpresa no caixa."
- Categoria: Finanças. Classificação: livre.
- Ícone: `apps/mobile/assets/icon.png` (1024). Feature graphic Android 1024×500: gerar a partir de `brand/` (pendente).
- Capturas: 6,7" e 6,1" (iOS), 1080×1920 (Android), **somente de builds reais em simulador/emulador** (ver `docs/09`); fundo Névoa, títulos em Bricolage Grotesque. Sugestão de sequência: Pode gastar · Supermercado (carrinho) · Cartões · Orçamentos com marca de hoje · Tela inicial personalizável · Tema escuro.

## 2. Privacidade e conformidade
- Política de privacidade e termos publicados em URL própria (pendente). Conteúdo base: `apps/mobile/src/app/privacy.tsx` e `docs/06` §6.
- App Store "App Privacy": dados não coletados (nenhum dado sai do aparelho); compras via IAP; câmera com finalidade declarada em `NSCameraUsageDescription`.
- Play "Data safety": sem coleta; permissões CAMERA, USE_BIOMETRIC, VIBRATE, POST_NOTIFICATIONS (Android 13+).
- Exclusão de dados: disponível no app (Privacidade → Apagar tudo); como não há conta remota, não há exclusão de conta no servidor.
- LGPD: dados locais, finalidade explícita, exportação e exclusão pelo titular.

## 3. Compras integradas
- Criar produtos com os IDs de `docs/08` (mensal, anual no mesmo grupo de assinatura; vitalício não consumível).
- Configurar RevenueCat (entitlements `plus`, `lifetime`), chaves públicas em EAS Secrets.
- Testar em sandbox: compra, restauração (3.1.1), cancelamento, carência, reembolso, upgrade mensal→anual.
- Textos obrigatórios já presentes no paywall (renovação automática, cancelamento, restaurar).

## 4. Checklist de release
- [ ] INPI e domínio verificados; identificadores de pacote definitivos
- [ ] Testes verdes, typecheck, contraste (CI)
- [ ] Development build testado em 1 Android + 1 iPhone físicos: câmera, códigos, OCR, biometria, notificações, arrastar e soltar, fonte 200%, VoiceOver/TalkBack
- [ ] Builds de produção assinados (EAS)
- [ ] Capturas e textos das lojas; política de privacidade publicada
- [ ] Produtos e sandbox das lojas aprovados; RevenueCat em produção
- [ ] TestFlight / teste interno com usuários reais por ≥ 1 semana
- [ ] Revisão das lojas enviada (não confundir com aprovação)
