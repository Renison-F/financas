# Auditoria de segurança — SerenaCash Flutter

Última atualização: 05/11/2026, sobre a branch `refactor/flutter-serenacash`. Referências: OWASP MASVS 2.x e MASTG.

Este documento registra o que foi verificado, como e com que resultado. **Não é uma declaração de conformidade com o MASVS.** Os controles marcados como verificados foram exercitados por teste automatizado, por inspeção do APK ou no emulador; o que depende de aparelho físico, de serviços de loja ou de ferramentas que não existem neste ambiente está listado como não executado.

Ambientes usados: testes Dart (banco SQLCipher real em arquivo, na máquina de desenvolvimento), emulador `serenacash_api35` (Android 15, x86_64) e análise estática do APK de homologação. Os testes destrutivos no emulador foram feitos em uma instalação isolada (`br.com.serenacash.mobile.seg`), sem tocar nos dados do app normal.

## 1. Achados desta rodada

| # | Gravidade | Achado | Situação | Evidência |
|---|---|---|---|---|
| S1 | P0 | "Apagar tudo" destruía a chave do banco e deixava o arquivo cifrado. Na abertura seguinte o app gerava outra chave, não conseguia abrir o arquivo e ficava preso na tela de erro. | Corrigido: arquivo, WAL, chave e PIN são apagados juntos (`LocalVault.erase`). | `test/data/vault_recovery_test.dart`; emulador: apagar, fechar e reabrir leva ao onboarding. |
| S2 | P1 | Com o banco presente e a chave ausente ou danificada, o gerenciador de chave criava uma chave nova em silêncio (e sobrescrevia uma entrada danificada). | Corrigido: falha fechada (`VaultError`), nada é gerado nem sobrescrito. | Mesmo teste; emulador: chave removida → tela de recuperação, entrada da chave continua ausente. |
| S3 | P1 | Quando o banco não abria, a tela de inicialização era um beco sem saída. | Corrigido: a tela diz o motivo e oferece "Tentar de novo" e "Apagar dados e recomeçar" (com confirmação). | Emulador: chave ausente e arquivo corrompido (`screens/etapa4/s02`, `s03`). |
| S4 | P1 | O bloqueio por biometria podia ser ligado em um aparelho sem biometria nem bloqueio de tela; a abertura seguinte parava em uma tela impossível de passar. | Corrigido: só liga depois que o aparelho confirma a identidade; a tela de bloqueio sempre tem a saída declarada. | Emulador sem biometria: o interruptor permanece desligado (`s04`). Com biometria cadastrada: checklist físico. |
| S5 | P2 | PIN sem limite de tentativas. | Corrigido: 5 tentativas livres, depois pausas de 30 s, 1 min, 5 min, 15 min e 1 h, guardadas no Keystore. | `test/data/pin_throttle_test.dart` (7 testes), `test/app/pin_lock_test.dart`; emulador: pausa continua depois de fechar o app. |
| S6 | P2 | Trocar ou desativar o PIN não pedia o PIN atual. | Corrigido. | `pin_lock_test.dart`. |
| S7 | P2 | Não havia política para PIN esquecido. | Corrigido: "Esqueci o PIN" explica que não há recuperação e oferece apagar os dados (dupla confirmação); backup pode ser restaurado depois. | `pin_lock_test.dart`. |
| S8 | P2 | Exportações (CSV, backup), anexos abertos e arquivos importados ficavam em claro no cache do app. | Corrigido: a cópia própria é apagada ao fechar a folha de compartilhamento; as cópias dos plugins (compartilhar, seletor de arquivos, câmera) são apagadas na abertura do app e 3 minutos depois de cada uso. | Emulador, build de homologação: com a folha aberta há duas cópias (a do app e a do plugin); ao fechar a folha resta só a do plugin; depois de reabrir o app o cache não tem nenhuma. O prazo de 3 minutos com o app aberto não foi cronometrado. |
| S9 | P2 | Com bloqueio ativado, o conteúdo aparecia em capturas de tela e na miniatura da lista de apps recentes. | Corrigido: `FLAG_SECURE` enquanto houver PIN ou biometria ativos. | Emulador: `dumpsys window` mostra `SECURE` e a captura sai preta (`s05`). |
| S10 | P2 | Ao bloquear, a árvore do app era desmontada e o que estava sendo digitado se perdia. | Corrigido: o app fica montado sob o bloqueio, fora da tela, do toque, do foco e da acessibilidade. | `pin_lock_test.dart`. |
| S11 | P1 (financeiro) | "Pagar" de novo, com valor parcial, um lançamento já quitado o reabria e devolvia a diferença ao saldo. | Corrigido no controlador. | `test/app/financial_invariants_test.dart` (invariante 7). |
| S12 | P2 (financeiro) | Uma data inexistente (30/02) era aceita pelo controlador. A tela já impedia; importações não. | Corrigido. | Mesmo arquivo. |

## 2. Controles verificados

### Armazenamento e criptografia (MASVS-STORAGE, MASVS-CRYPTO)
- **Banco cifrado no aparelho.** Arquivos `serenacash.db` e `serenacash.db-wal` extraídos da instalação de teste: cabeçalho não é "SQLite format 3", os 4.096 primeiros bytes usam os 256 valores possíveis, e nenhum dos textos gravados (descrição, nome da conta, valor, nomes de categoria, `CREATE`) aparece em claro em nenhum dos dois arquivos.
- **Motor.** `libsqlcipher.so` está no APK para as três arquiteturas. O app recusa abrir se `PRAGMA cipher_version` vier vazio (sem alternativa em claro).
- **Chave errada e arquivo corrompido.** Não abrem; o arquivo é preservado e nada é recriado em silêncio (teste e emulador).
- **Chave.** 256 bits aleatórios, guardada pelo `flutter_secure_storage`: valor cifrado com AES-GCM, chave AES embrulhada por RSA-OAEP do Android Keystore. Nas preferências do app não há chave em claro. O app abriu com os dados depois de reiniciar o emulador.
- **Backup do sistema.** `allowBackup=false` e regras de extração excluindo todos os domínios.
- **Migrações.** O esquema está na versão 1; o caminho de migração existe, mas ainda não há migração para testar.

### PIN e biometria (MASVS-AUTH)
- Verificador Argon2id (19 MiB, 2 iterações) com sal por PIN e comparação em tempo constante; o PIN não é guardado.
- Limite de tentativas, bloqueio ao voltar do segundo plano, troca e desativação com o PIN atual, saída declarada para PIN esquecido (itens S5 a S7).
- O PIN protege a interface; a chave do banco não deriva dele. Quem tem acesso root ao aparelho desbloqueado não é barrado pelo PIN.
- Biometria usa `local_auth` com alternativa pela credencial do aparelho. Em aparelho com biometria cadastrada: não testado (checklist físico).

### Backups (MASVS-CRYPTO)
- AES-256-GCM com chave Argon2id (64 MiB, 3 iterações); cabeçalho autenticado como AAD; sal de 16 bytes e nonce de 12 bytes novos a cada exportação.
- Senha errada, sem senha, arquivo cortado (meio e fim), conteúdo cifrado alterado ou encurtado, parâmetros de derivação alterados, lixo, vazio e JSON de outra origem: todos recusados sem alterar o banco (`test/data/backup_resilience_test.dart`).
- Restauração em uma transação; uma restauração de 50.000 lançamentos interrompida matando o app deixou o banco no estado anterior, íntegro (emulador).
- Compras continuam no backup (`backup_shopping_test.dart`).

### Vazamento de informação (MASVS-STORAGE, MASVS-PLATFORM)
- **Logcat.** Durante os fluxos no emulador (onboarding, lançamentos, PIN, exportação): nenhuma ocorrência do PIN, de valores ou de descrições; 0 exceções do Flutter.
- **Código.** Sem `print`, `debugPrint` ou log de dados; sem uso da área de transferência.
- **Mensagens de erro.** A tela de falha de abertura mostra só o tipo do erro.
- **Notificações.** Mostram descrição e valor da conta, por decisão de produto e só depois de o usuário ativar os lembretes. Ver riscos residuais.

### Câmera e leitura de códigos (MASVS-PLATFORM)
- Permissão pedida só ao abrir a leitura; recusa tratada com explicação e entrada manual (`s06`).
- O conteúdo lido (código de barras, QR de nota) é interpretado como dado: dígito verificador conferido, nada é aberto nem executado, e todo item passa por confirmação. O app não tem dependência para abrir URLs.
- Reconhecimento de texto e de códigos com bibliotecas embarcadas (`libmlkit_google_ocr_pipeline.so`, `libbarhopper_v3.so`). Com câmera real: checklist físico.

### Assinaturas (MASVS-RESILIENCE, parcial)
- Sem chave do RevenueCat no build, a loja fica inativa e o plano é o gratuito. Este APK não contém chave nenhuma.
- Os direitos vêm do RevenueCat; o app guarda um cache dentro do banco cifrado com tolerância de 7 dias sem conexão. Estados expirado, reembolsado e pausado tiram o acesso. Não há atalho de depuração que conceda plano pago.
- Compra, restauração, cancelamento e reembolso reais: não testados (dependem de produtos e conta de teste nas lojas).

### Rede (MASVS-NETWORK)
- A permissão de internet existe só para a loja. Nenhum dado financeiro sai do aparelho; não há URL de serviço próprio no código. Tráfego em claro não é permitido (padrão do Android para `targetSdk` 36, sem exceção no manifesto).

## 3. Análise estática do APK de homologação

Feita com `aapt2`, `apksigner` e inspeção do pacote.

- `debuggable`: ausente. `testOnly`: ausente. `allowBackup=false`. `usesCleartextTraffic`: ausente.
- Componentes exportados: a atividade principal (lançador); `com.amazon.device.iap.ResponseReceiver`, do SDK de compras, protegido por permissão da Amazon; `androidx.profileinstaller.ProfileInstallReceiver`, protegido por `android.permission.DUMP`. Receptores de notificação e provedores de arquivo não são exportados.
- Permissões: câmera, notificações, iniciar após o boot, internet, cobrança da loja, vibração, biometria, estado da rede. Sem localização, contatos, armazenamento externo ou SMS.
- Assinatura: esquema v2, certificado "Android Debug" desta máquina. Serve para homologação; não é a chave da loja.
- Segredos: nenhuma chave de API, chave privada ou senha no código compilado nem nos recursos; nenhuma URL `http://`.
- Bibliotecas nativas (arm64): `libapp.so`, `libflutter.so`, `libsqlcipher.so`, `libmlkit_google_ocr_pipeline.so`, `libbarhopper_v3.so`, `libdartjni.so`, `libimage_processing_util_jni.so`, `libsurface_util_jni.so`.

## 4. Dependências e repositório

- 177 pacotes do pub.dev consultados na base OSV (ecossistema Pub): 0 vulnerabilidades conhecidas em 05/11/2026. A consulta não cobre as bibliotecas nativas embarcadas (SQLCipher, OpenSSL, ML Kit).
- Atualizações menores disponíveis: `go_router`, `purchases_flutter`, `sqlite3`.
- Varredura de segredos por padrões nos arquivos versionados e em todo o histórico git: nada encontrado. Não há keystore, `key.properties` ou `.env` versionados, e o `.gitignore` os cobre.

## 5. Não executado

| Item | Motivo |
|---|---|
| Análise dinâmica com MobSF | Exige Docker ou servidor próprio, que não existem neste ambiente. |
| Ferramentas dedicadas (gitleaks, osv-scanner, semgrep, jadx, apktool) | Não instaladas; substituídas por varredura por padrões, consulta à API da OSV e ferramentas do SDK. |
| Biometria com digital ou rosto cadastrados; troca das credenciais biométricas | Emulador sem biometria. |
| Câmera, OCR e leitura de códigos reais | Sem câmera física. |
| Compras, restauração e reembolso na loja | Sem produtos nem conta de teste configurados. |
| Instrumentação, root e adulteração do app (MASVS-RESILIENCE) | Fora do escopo desta etapa. |
| iOS | Sem macOS. |
| Revisão de licenças das bibliotecas nativas | Pendente. |
| Armazenamento cheio | Não simulado. |

## 6. Riscos residuais

1. **Notificações mostram descrição e valor** na tela de bloqueio do aparelho. Uma opção "esconder valores nas notificações" resolveria.
2. **Textos dos lembretes agendados** ficam em claro nas preferências do plugin de notificações, dentro da área privada do app.
3. **A pausa do PIN usa o relógio do aparelho**: adiantar o relógio encurta a pausa.
4. **O PIN não cifra os dados.** Protege contra quem pega o aparelho desbloqueado; não contra root.
5. **Cache de direitos de assinatura** vale por até 7 dias sem conexão.
6. **Cópia do plugin de compartilhamento** pode ficar no cache por até 3 minutos (ou até a próxima abertura), para dar tempo ao app de destino de ler o arquivo.
7. **Sem proteção contra root, instrumentação e reempacotamento.**
8. **A chave de assinatura é a de debug.** Trocar pela chave definitiva exige reinstalar (os dados do aparelho não migram entre chaves; o backup resolve).
