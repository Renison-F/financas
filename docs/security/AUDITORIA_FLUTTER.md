# Auditoria de segurança — SerenaCash Flutter

Última atualização: 10/11/2026 (seção 7, diferencial da build 0.2.0+3; seção 8, diferencial da build 0.2.0+4), sobre a branch `refactor/flutter-serenacash`. As seções 1 a 6 são da auditoria de 05/11/2026 sobre a build 0.1.0+2. Referências: OWASP MASVS 2.x e MASTG.

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

## 7. Diferencial da build 0.2.0+3 (10/11/2026)

Revisão do que mudou entre `bae5d9f` e `f1b3b47`. Não é uma auditoria nova: as seções 2 a 6 não foram repetidas por inteiro. Verificado por teste automatizado, por inspeção do APK final com `aapt2` e `apksigner`, e no aparelho virtual `serenacash_teste`.

### Achados e correções

| # | Gravidade | Achado | Situação | Evidência |
|---|---|---|---|---|
| S13 | P1 | A confirmação pelo aparelho (digital, rosto ou bloqueio de tela) nunca funcionava: a atividade principal era `FlutterActivity` e o plugin `local_auth` exige `FragmentActivity`. O app tratava o erro como "indisponível". Ocorrência 011. | Corrigido: `FlutterFragmentActivity`, tema AppCompat e uma mensagem para cada estado (confirmado, cancelado, sem cadastro, sem hardware, bloqueado por tentativas). | `physical_return_test.dart`; aparelho virtual com digital cadastrada: ligar, bloquear, abrir, cancelar. |
| S14 | P2 | Desligar a confirmação do aparelho não pedia confirmação nenhuma. | Corrigido: pede a confirmação do aparelho antes de desligar. | Mesmo arquivo. |
| S15 | P3 | Ligar o bloqueio durante o uso bloqueava o app na hora e pedia a confirmação duas vezes. | Corrigido: passa a valer na próxima ida ao segundo plano. | `pin_lock_test.dart`. |

### Controles novos verificados

- **Fotos de evidência** (etiqueta, produto, cupom): gravadas como BLOB dentro do banco SQLCipher, com SHA-256, tipo e limite de 8 MB por imagem. O arquivo temporário da captura é apagado depois de lido; depois de 20 capturas seguidas o cache do app estava vazio.
- **Backup:** fotos e linhas de cupom entram no backup cifrado; na restauração o SHA-256 de cada foto é conferido e uma foto adulterada faz o backup inteiro ser recusado, sem alterar o banco (`backup_shopping_test.dart`).
- **Câmera:** aberta só na tela de leitura, uma por vez, liberada ao sair de vista ou ir para o segundo plano. Permissão negada tem explicação e caminho manual. Sem erro no logcat em build de release.
- **Texto lido** (OCR, cupom, voz, código): sempre tratado como dado. Nada é aberto, executado nem gravado sem revisão do usuário. Um QR com endereço não é aberto.
- **Preço:** leitura duvidosa não entra no carrinho sem conferência explícita; preço de atacado só é aplicado com quantidade mínima.
- **Migrações:** três passos, testados a partir de cada versão anterior com dados; nenhuma apaga ou reescreve valor monetário.

### Superfície nova

- **Microfone** (`RECORD_AUDIO`), pedido só ao tocar em "Falar". O app não grava nem guarda áudio. A transcrição é feita pelo serviço de voz do Android, que conforme o aparelho **pode enviar o áudio a um servidor do fornecedor do serviço**. O app avisa isso na tela antes de ouvir. Não foi forçado o reconhecimento só no aparelho, porque nem todo aparelho tem o idioma instalado; é uma decisão a rever.
- **Armazenamento:** o plugin da câmera declara `WRITE_EXTERNAL_STORAGE` até o Android 9 (`maxSdkVersion=28`), e o Android acrescenta `READ_EXTERNAL_STORAGE` por implicação. O app não pede essas permissões em tempo de execução e não grava fora da área privada.
- **Dependências novas:** `camera`, `speech_to_text` e as transitivas. 185 pacotes do pub.dev consultados na OSV em 10/11/2026: 0 vulnerabilidades conhecidas. A consulta não cobre bibliotecas nativas.
- **Rede:** nenhuma chamada nova. O OCR e a leitura de códigos continuam embarcados; não há catálogo externo de produtos nem consulta de nota fiscal.
- **Segredos:** varredura por padrões no diff da rodada, sem achados. As fotos de etiqueta do usuário não foram versionadas; só o texto que o OCR leu delas (`test/fixtures/labels/`), que é texto de etiqueta de supermercado.

### Não executado nesta rodada

- MobSF, análise dinâmica, ferramentas dedicadas, root e instrumentação (como na seção 5).
- Reanálise completa de componentes exportados do APK novo: foram conferidos pacote, versão, SDKs, permissões e certificado.
- Biometria com rosto; troca das credenciais biométricas com o bloqueio ligado.
- Qualquer coisa em aparelho físico e em iOS.

### Riscos residuais acrescentados

9. **Áudio da fala pode sair do aparelho** pelo serviço de voz do sistema (ver acima). Mitigação: aviso na tela, uso opcional, digitação sempre disponível.
10. **Fotos de evidência aumentam o banco e o backup.** Há limite por imagem, não por total; uma política de retenção (apagar evidências antigas) ainda não existe.
11. **O cupom fotografado é lido por OCR**, sujeito a erro; por isso ele não altera a despesa e os pares duvidosos ficam como "suspeita".
12. **Repositório público** com o histórico do projeto. Privatizar é ação do dono (passo a passo no `CHECKPOINT.md`).

## 8. Diferencial da build 0.2.0+4 (10/11/2026)

Revisão do que mudou entre `f1b3b47` e a build 0.2.0+4. Mesma ressalva da seção 7: não é uma auditoria nova.

### Achado corrigido

| # | Gravidade | Achado | Situação | Evidência |
|---|---|---|---|---|
| S16 | P2 (privacidade) | Uma foto de cupom escolhida da galeria, ou um anexo de lançamento, podia levar posição GPS, modelo do aparelho e data nos metadados para dentro do banco e dos backups. O seletor de imagens copia o EXIF ao redimensionar. | Corrigido: evidências e anexos em JPEG são gravados sem EXIF, XMP, IPTC e comentários; a imagem não é recodificada e só a orientação é mantida. Fotos já guardadas não são reescritas. | `test/data/image_metadata_test.dart`. |

### Superfície nova: consulta opcional pela internet

É a primeira função do app que envia algo relacionado a uma compra para fora do aparelho. Por isso:

- **Desligada por padrão**, ligada só por escolha do usuário em Configurações, com o texto que diz o que sai.
- **O que sai:** o número do código de barras, em uma requisição HTTPS para `world.openfoodfacts.org`. Nada sobre preço, loja, quantidade, conta ou usuário. O cabeçalho identifica só o aplicativo ("SerenaCash/0.2 (Android)").
- **O que o terceiro fica sabendo:** que alguém, naquele endereço IP, consultou aquele produto naquele momento. É um dado de consumo; a política de privacidade precisa citá-lo antes de uma versão de loja.
- **Entrada:** só dígitos com 8, 12, 13 ou 14 posições chegam à URL; códigos de balança e códigos inválidos não são enviados.
- **Saída:** a resposta é tratada como texto de terceiro: tamanho máximo de 64 KB, tempo limite de 6 s, sem seguir redirecionamento, campos de tipo errado ignorados, textos cortados em 120 caracteres. Vira sugestão de nome em um campo editável; nunca um preço, nunca algo executado ou aberto.
- **Tráfego em claro** continua proibido pelo padrão do Android. Não há fixação de certificado.
- **Sem dependência nova:** usa `dart:io`.

### Outros pontos

- **Releitura de uma área da foto:** o recorte vira um arquivo temporário na área privada do app, apagado logo depois da leitura, inclusive quando a leitura falha.
- **Lembretes:** os avisos de valores a receber, faturas e metas mostram descrição e valor na tela de bloqueio, como os de contas (risco residual 1). Um aviso só abre rotas conhecidas do app (`isReminderRoute`); qualquer outro texto em um aviso é ignorado.
- **Despesa pelo cupom:** muda um valor financeiro, então só acontece por ação do usuário, com os dois valores na tela, e deixa o valor anterior anotado.
- **Preferências novas** são lidas com valores padrão e nunca derrubam o app quando desconhecidas; a paleta personalizada é derivada com contraste garantido mesmo se vier de um backup editado à mão.
- **Dependências:** nenhuma nova nesta build. Consulta à OSV repetida em 10/11/2026 (185 pacotes, 0 vulnerabilidades conhecidas).

### Riscos residuais acrescentados

13. **Consulta ao catálogo revela consumo a um terceiro**, quando ligada. Mitigação: desligada por padrão, texto claro, cadastro local evita repetir a consulta.
14. **Fotos antigas** (guardadas antes desta build) mantêm os metadados que tinham.
