# SerenaCash (Flutter)

Finanças pessoais e compras de supermercado, sem depender de internet. Versão `0.2.0+4`, em homologação. Application ID `br.com.serenacash.mobile`.

## O que tem aqui
```
lib/domain/     regras puras: dinheiro em centavos, lançamentos, cartões, orçamentos, metas,
                empréstimos, relatórios, controle diário, compras, etiqueta, cupom, voz
lib/data/       banco Drift + SQLCipher, repositórios, backup cifrado, OCR, segurança
lib/app/        controlador (Riverpod), rotas (GoRouter), tema e paletas
lib/features/   telas por área
lib/ui/         componentes e ícones
lib/l10n/       textos (pt-BR e en)
test/           domínio, dados, app e desempenho
drift_schemas/  retrato de cada versão do banco, usado nos testes de migração
```

## Rodar
```bash
flutter pub get
```
```bash
dart run build_runner build --delete-conflicting-outputs && flutter gen-l10n
```
```bash
flutter run
```

## Antes de entregar
```bash
dart format --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test
```
```bash
flutter build apk --release
```
O APK de release sai assinado com a chave de debug da máquina: serve para homologação, não para loja. Depois de `flutter test integration_test`, gere o build de novo antes de distribuir (o teste desinstala o app e deixa um APK próprio no diretório de build).

## Regras do projeto
- Dinheiro é sempre inteiro em centavos. Nenhuma conta com ponto flutuante.
- Nada entra no carrinho nem no banco sem confirmação do usuário; texto lido por câmera ou voz é só uma proposta.
- Toda mudança de esquema sobe a versão do banco, ganha um retrato em `drift_schemas/` e um teste de migração com dados.
- Só dados fictícios em testes e capturas. Sem chaves, certificados ou fotos pessoais no repositório.

Documentação completa: `../../docs/flutter-migration/` (comece pelo `CHECKPOINT.md`).
