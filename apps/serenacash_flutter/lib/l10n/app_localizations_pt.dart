// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'SerenaCash';

  @override
  String get tabHome => 'Início';

  @override
  String get tabTransactions => 'Lançamentos';

  @override
  String get tabShopping => 'Compras';

  @override
  String get tabPlan => 'Planejar';

  @override
  String get tabMore => 'Mais';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get showValues => 'Mostrar valores';

  @override
  String get hideValues => 'Ocultar valores';

  @override
  String get customizeHome => 'Personalizar tela inicial';

  @override
  String get addTransaction => 'Adicionar lançamento';

  @override
  String get noWidgetsVisible =>
      'Nenhum widget visível. Toque na engrenagem para escolher o que ver.';

  @override
  String get widgetLoadError => 'Não foi possível carregar';

  @override
  String get tapToRetry => 'Toque para tentar de novo.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get close => 'Fechar';

  @override
  String get delete => 'Excluir';

  @override
  String get undo => 'Desfazer';

  @override
  String get edit => 'Editar';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get see => 'Ver';

  @override
  String get all => 'Todas';

  @override
  String get new_ => 'Novo';

  @override
  String get newF => 'Nova';

  @override
  String get add => 'Adicionar';

  @override
  String get register => 'Registrar';

  @override
  String get details => 'Detalhes';

  @override
  String get ok => 'OK';

  @override
  String get loadingError => 'Não foi possível abrir seus dados.';

  @override
  String get unlockTitle => 'Bloqueado';

  @override
  String get unlockText => 'Confirme sua identidade para ver seus dados.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get unlockPrompt => 'Desbloquear SerenaCash';

  @override
  String get biometricFailed => 'Não foi possível confirmar sua identidade.';

  @override
  String get biometricUnavailable => 'Biometria indisponível neste aparelho.';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinWrong => 'PIN incorreto.';

  @override
  String get usePin => 'Usar PIN';

  @override
  String get useBiometrics => 'Usar biometria';

  @override
  String canSpendUntil(String date) {
    return 'Pode gastar até $date';
  }

  @override
  String get canSpendTitle => 'Pode gastar';

  @override
  String get startWithAccount => 'Comece pela sua conta';

  @override
  String get startWithAccountText =>
      'Com o saldo de uma conta o app já mostra quanto cabe gastar.';

  @override
  String get addAccount => 'Adicionar conta';

  @override
  String get availNegative =>
      'As contas registradas passam do dinheiro disponível.';

  @override
  String get availTight =>
      'Está apertado: o que sobra cobre pouco mais que as contas.';

  @override
  String get availOk =>
      'Estimativa com o que está registrado, não um saldo garantido.';

  @override
  String get modeOptimistic => 'Modo otimista';

  @override
  String get modePrudent => 'Modo prudente';

  @override
  String get howWeCalculate => 'Como calculamos ›';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get accounts => 'Contas';

  @override
  String get noAccount => 'Nenhuma conta';

  @override
  String get balancesByAccount => 'Saldos por conta';

  @override
  String get income => 'Receitas';

  @override
  String get expenses => 'Despesas';

  @override
  String plannedLabel(String value) {
    return 'Previstas: $value';
  }

  @override
  String plannedAndCard(String planned, String card) {
    return 'Previstas: $planned · no cartão: $card';
  }

  @override
  String get billsToPay => 'Contas a pagar';

  @override
  String get bill => 'Conta';

  @override
  String dueOn(String date) {
    return 'vence $date';
  }

  @override
  String duePast(String date) {
    return 'venceu $date';
  }

  @override
  String get nothingToPay => 'Nada a pagar até o fim do período';

  @override
  String get nothingToPayText =>
      'Cadastre contas previstas para o \'pode gastar\' ficar honesto.';

  @override
  String get newBillToPay => 'Nova conta a pagar';

  @override
  String get overdueBills => 'Contas atrasadas';

  @override
  String get noOverdue => 'Nenhuma conta atrasada.';

  @override
  String get next7days => 'Próximos 7 dias';

  @override
  String get calendar => 'Calendário';

  @override
  String get noDueNext7 => 'Nenhum vencimento nos próximos 7 dias.';

  @override
  String get cardsAndInvoices => 'Cartões e faturas';

  @override
  String invoiceLine(String state, String date, String free) {
    return 'Fatura $state · vence $date · limite livre $free';
  }

  @override
  String get invoiceOpen => 'aberta';

  @override
  String get invoiceClosed => 'fechada';

  @override
  String get invoicePaid => 'paga';

  @override
  String get invoiceOverdue => 'atrasada';

  @override
  String get invoiceFuture => 'futura';

  @override
  String limitCommitted(int percent) {
    return '$percent% do limite comprometido';
  }

  @override
  String get noCard => 'Nenhum cartão';

  @override
  String get noCardText =>
      'Cadastre fechamento e vencimento para acompanhar a fatura.';

  @override
  String get addCard => 'Adicionar cartão';

  @override
  String get installmentPurchases => 'Compras parceladas';

  @override
  String get committedFuture => 'comprometidos em faturas futuras';

  @override
  String get monthlyBudget => 'Orçamento do mês';

  @override
  String get budgets => 'Orçamentos';

  @override
  String ofLimit(String value) {
    return 'de $value';
  }

  @override
  String monthPace(String pace) {
    return 'Mês $pace';
  }

  @override
  String get paceSereno => 'sereno';

  @override
  String get paceAtencao => 'em atenção';

  @override
  String get paceAgitado => 'agitado';

  @override
  String get general => 'Geral';

  @override
  String get noBudgetYet => 'Sem orçamento ainda';

  @override
  String get noBudgetText =>
      'Defina um limite para o mês e acompanhe o ritmo com a marca de hoje.';

  @override
  String get createBudget => 'Criar orçamento';

  @override
  String get spendingByCategory => 'Gastos por categoria';

  @override
  String get report => 'Relatório';

  @override
  String get noExpensesMonth => 'Sem despesas neste mês';

  @override
  String get registerExpense => 'Registrar despesa';

  @override
  String get evolution => 'Evolução';

  @override
  String get cashflow => 'Fluxo';

  @override
  String get noHistory => 'Ainda sem histórico';

  @override
  String get noHistoryText =>
      'Registre receitas e despesas para ver a evolução.';

  @override
  String incomeOf(String month, String value) {
    return 'Receitas $month: $value';
  }

  @override
  String expensesOf(String month, String value) {
    return 'Despesas $month: $value';
  }

  @override
  String get goals => 'Metas';

  @override
  String get noGoal => 'Nenhuma meta';

  @override
  String get noGoalText => 'Uma reserva de emergência é um bom começo.';

  @override
  String get createGoal => 'Criar meta';

  @override
  String get reserves => 'Reservas';

  @override
  String get reservesText => 'separado e fora do \"pode gastar\"';

  @override
  String get monthlySavings => 'Economia do mês';

  @override
  String get registerIncomeForRate =>
      'Registre receitas para ver a taxa de economia.';

  @override
  String percentOfIncome(int percent) {
    return '$percent% das receitas';
  }

  @override
  String get subscriptions => 'Assinaturas e recorrentes';

  @override
  String monthsInARow(int n) {
    return '$n meses seguidos';
  }

  @override
  String get noRecurring => 'Nenhum gasto recorrente detectado ainda.';

  @override
  String get loans => 'Empréstimos';

  @override
  String nextInstallment(String date, String value) {
    return 'próxima $date · $value';
  }

  @override
  String get paidOff => 'quitado';

  @override
  String get noLoan => 'Nenhum empréstimo';

  @override
  String get registerLoan => 'Cadastrar';

  @override
  String get open => 'Abrir';

  @override
  String calendarSummary(int n, String date) {
    return '$n vencimento(s) até $date';
  }

  @override
  String overdueCount(int n) {
    return ' · $n atrasado(s)';
  }

  @override
  String get recentTransactions => 'Últimos lançamentos';

  @override
  String get allLabel => 'Todos';

  @override
  String get planned => 'previsto';

  @override
  String get noTransaction => 'Nenhum lançamento';

  @override
  String get suggestions => 'Sugestões';

  @override
  String get assistant => 'Assistente';

  @override
  String get allCalm => 'Tudo sereno por aqui.';

  @override
  String get shoppingLists => 'Listas de compras';

  @override
  String listCount(int n) {
    return '$n lista(s)';
  }

  @override
  String get noListYet => 'Nenhuma lista ainda.';

  @override
  String get createList => 'Criar lista';

  @override
  String get shoppingAssistant => 'Assistente de supermercado';

  @override
  String sessionsCount(int n) {
    return '$n compra(s) registrada(s)';
  }

  @override
  String get shoppingAssistantText =>
      'Leia etiquetas e códigos e veja o total antes do caixa.';

  @override
  String get startShopping => 'Iniciar compra';

  @override
  String get continueShopping => 'Continuar compra';

  @override
  String get advancedIndicators => 'Indicadores avançados';

  @override
  String get methodology => 'Metodologia';

  @override
  String get savingRate => 'Taxa de poupança (mês)';

  @override
  String get committedIncome => 'Renda comprometida (cartões + parcela)';

  @override
  String get netWorth => 'Patrimônio líquido';

  @override
  String get indicatorsDisclaimer =>
      'Cálculos sobre os dados registrados; não são diagnóstico financeiro.';

  @override
  String get kindIncome => 'Receita';

  @override
  String get kindExpense => 'Despesa';

  @override
  String get kindTransfer => 'Transferência';

  @override
  String get kindCardPurchase => 'Compra no cartão';

  @override
  String get kindCardPayment => 'Pagamento de fatura';

  @override
  String get kindGoalDeposit => 'Depósito em reserva';

  @override
  String get kindGoalWithdrawal => 'Resgate de reserva';

  @override
  String get kindLoanDisbursement => 'Entrada de empréstimo';

  @override
  String get kindLoanPayment => 'Parcela de empréstimo';

  @override
  String get kindBalanceAdjustment => 'Ajuste de saldo';

  @override
  String get kindCardRefund => 'Estorno no cartão';

  @override
  String get customizeTitle => 'Tela inicial';

  @override
  String get presets => 'Modelos';

  @override
  String get restoreDefault => 'Restaurar padrão';

  @override
  String get visibleWidgets => 'Visíveis (segure e arraste, ou use as setas)';

  @override
  String get hiddenWidgets => 'Ocultos';

  @override
  String moveUp(String name) {
    return 'Mover $name para cima';
  }

  @override
  String moveDown(String name) {
    return 'Mover $name para baixo';
  }

  @override
  String hideWidget(String name) {
    return 'Ocultar $name';
  }

  @override
  String showWidget(String name) {
    return 'Mostrar $name';
  }

  @override
  String get indicatorsPeriod => 'Período dos indicadores';

  @override
  String get currentMonth => 'Mês atual';

  @override
  String get next30days => 'Próximos 30 dias';

  @override
  String get accountsConsidered => 'Contas consideradas';

  @override
  String availableSubtitle(String date, String mode) {
    return 'Até $date · modo $mode';
  }

  @override
  String get estimateDisclaimer =>
      'É uma estimativa com o que você registrou. Não é saldo garantido.';

  @override
  String get theMath => 'A conta';

  @override
  String get equalsCanSpend => '= Pode gastar';

  @override
  String get adjustments => 'Ajustes';

  @override
  String get includePlannedIncome => 'Considerar receitas previstas';

  @override
  String get includePlannedIncomeHelp =>
      'Ligado = modo otimista: conta com dinheiro que ainda não entrou.';

  @override
  String get horizon => 'Horizonte';

  @override
  String get untilMonthEnd => 'Até o fim do mês';

  @override
  String get safetyCushion => 'Colchão de segurança';

  @override
  String get none => 'Nenhum';

  @override
  String get cushionHelp =>
      'Valor que você prefere nunca tocar; sai do \"pode gastar\".';

  @override
  String get rules => 'Regras';

  @override
  String get availabilityRules =>
      'Entram só contas marcadas para o cálculo e dinheiro já efetivado. Saem: contas previstas até o horizonte (inclusive atrasadas), faturas de cartão já fechadas e a fatura aberta, reservas guardadas dentro das contas e o colchão. Compras no cartão nunca contam duas vezes: a compra é despesa na data; o pagamento da fatura só move dinheiro.';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Próximo mês';

  @override
  String get inflow => 'Entradas';

  @override
  String get outflow => 'Saídas';

  @override
  String get result => 'Resultado';

  @override
  String get searchTransactions => 'Buscar por descrição, loja ou observação';

  @override
  String get filterAll => 'Tudo';

  @override
  String get filterCard => 'Cartão';

  @override
  String get filterTransfers => 'Transferências';

  @override
  String get filterPlanned => 'Previstos';

  @override
  String paidPart(String value) {
    return 'pago $value';
  }

  @override
  String get nothingFound => 'Nada encontrado';

  @override
  String get tryAnotherWord => 'Tente outra palavra.';

  @override
  String get noTransactionMonth => 'Nenhum lançamento neste mês';

  @override
  String get registerWithPlus =>
      'Registre uma despesa ou receita com o botão +.';

  @override
  String get newTransaction => 'Novo lançamento';

  @override
  String get editTransaction => 'Editar lançamento';

  @override
  String get transaction => 'Lançamento';

  @override
  String get amount => 'Valor';

  @override
  String get description => 'Descrição';

  @override
  String get descHintIncome => 'Ex.: Salário';

  @override
  String get descHintTransfer => 'Ex.: Para a poupança';

  @override
  String get descHintExpense => 'Ex.: Mercado';

  @override
  String get category => 'Categoria';

  @override
  String get card => 'Cartão';

  @override
  String get registerCard => 'Cadastrar cartão';

  @override
  String get account => 'Conta';

  @override
  String get from => 'De';

  @override
  String get to => 'Para';

  @override
  String get registerAccount => 'Cadastrar conta';

  @override
  String get dueDate => 'Vencimento';

  @override
  String get date => 'Data';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get invalidDate => 'Data inválida (dd/mm/aaaa)';

  @override
  String get notReceivedYet => 'Ainda não recebi (previsto)';

  @override
  String get notPaidYet => 'Ainda não paguei (previsto)';

  @override
  String get plannedHelp =>
      'Lançamentos previstos entram em \'contas a pagar\' e no cálculo de \'pode gastar\'.';

  @override
  String get installments => 'Parcelas';

  @override
  String get cashPayment => 'À vista';

  @override
  String installmentsHelp(int n, String value) {
    return '${n}x de $value (centavos ajustados nas primeiras parcelas), uma por fatura.';
  }

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get repeat => 'Repetir';

  @override
  String get repeatHelp =>
      'Cria uma série; os próximos 3 meses ficam como previstos e novos são gerados automaticamente.';

  @override
  String get tags => 'Tags';

  @override
  String get merchant => 'Estabelecimento';

  @override
  String get optional => 'Opcional';

  @override
  String get notes => 'Observações';

  @override
  String get attachmentsPlus =>
      'Anexos e comprovantes fazem parte do SerenaCash Plus.';

  @override
  String get attachmentsAfterSave =>
      'Anexos: adicione pelo detalhe do lançamento após salvar.';

  @override
  String get attachments => 'Anexos';

  @override
  String get addAttachment => 'Anexar comprovante';

  @override
  String get payment => 'Pagamento';

  @override
  String get markReceived => 'Marcar como recebido';

  @override
  String get markPaid => 'Marcar como pago';

  @override
  String payPart(String value) {
    return 'Pagar parte (restam $value)';
  }

  @override
  String get registerPartial => 'Registrar pagamento parcial';

  @override
  String get deleteThisAndNext => 'Excluir este e os próximos';

  @override
  String get deleteTransaction => 'Excluir lançamento';

  @override
  String get deleteTransactionQ => 'Excluir lançamento?';

  @override
  String get deleteSeriesText =>
      'Os lançamentos desta série a partir desta data serão excluídos. Você pode desfazer em seguida.';

  @override
  String get deleteOneText => 'Você pode desfazer em seguida.';

  @override
  String get deletedOne => 'Lançamento excluído';

  @override
  String deletedMany(int n) {
    return '$n lançamentos excluídos';
  }

  @override
  String get errAmount => 'Informe um valor maior que zero.';

  @override
  String get errCardFirst =>
      'Cadastre um cartão antes de registrar uma compra no cartão.';

  @override
  String get errAccountFirst => 'Cadastre uma conta antes de registrar.';

  @override
  String get errTwoAccounts => 'Escolha duas contas diferentes.';

  @override
  String get errSave => 'Não foi possível salvar.';

  @override
  String get frequencyMonthly => 'Mensal';

  @override
  String get frequencyWeekly => 'Semanal';

  @override
  String get frequencyBiweekly => 'Quinzenal';

  @override
  String get frequencyYearly => 'Anual';

  @override
  String get planTitle => 'Planejar';

  @override
  String get planSubtitle => 'Orçamentos, metas, cartões e empréstimos';

  @override
  String get noBudget => 'Nenhum orçamento';

  @override
  String get noBudgetPlanText =>
      'Defina limites por categoria ou para o mês inteiro.';

  @override
  String get goalsAndReserves => 'Metas e reservas';

  @override
  String goalLine(int percent, String remaining) {
    return '$percent% · faltam $remaining';
  }

  @override
  String perMonth(String value) {
    return ' · $value/mês';
  }

  @override
  String get noGoalPlanText => 'Comece por uma reserva de emergência.';

  @override
  String get cards => 'Cartões';

  @override
  String cardLine(String state, String date, String free) {
    return 'fatura $state · vence $date · livre $free';
  }

  @override
  String get loansAndDebts => 'Empréstimos e dívidas';

  @override
  String loanLine(String date, String value, int paid, int total) {
    return 'próxima $date · $value · $paid/$total pagas';
  }

  @override
  String get noLoanRegistered => 'Nenhum empréstimo cadastrado.';

  @override
  String get balanceProjection => 'Projeção de saldo';

  @override
  String get projectionText =>
      'Veja como o saldo evolui com as contas e receitas previstas até o fim do mês.';

  @override
  String get moreTitle => 'Mais';

  @override
  String get freePlan => 'Plano gratuito';

  @override
  String get groupMoney => 'Meu dinheiro';

  @override
  String get accountsWallets => 'Contas e carteiras';

  @override
  String get accountsWalletsDesc => 'Saldos, ajustes, arquivamento';

  @override
  String get categoriesTags => 'Categorias e tags';

  @override
  String get categoriesTagsDesc => 'Organize seus lançamentos';

  @override
  String get financialCalendar => 'Calendário financeiro';

  @override
  String get financialCalendarDesc => 'Vencimentos e recebimentos';

  @override
  String get billsDesc => 'Previstas, atrasadas, parciais';

  @override
  String get groupAnalysis => 'Análises';

  @override
  String get reports => 'Relatórios';

  @override
  String get reportsDesc =>
      'Fluxo de caixa, categorias, comparativos, projeções';

  @override
  String get financialAssistant => 'Assistente financeiro';

  @override
  String get financialAssistantDesc => 'Pergunte sobre o seu dinheiro';

  @override
  String get groupData => 'Dados';

  @override
  String get importData => 'Importar CSV ou OFX';

  @override
  String get importDesc => 'Com revisão e sem duplicidades';

  @override
  String get exportBackup => 'Exportar e backup';

  @override
  String get exportDesc => 'CSV, PDF e backup completo';

  @override
  String get groupAccount => 'Conta';

  @override
  String get plusTitle => 'SerenaCash Plus';

  @override
  String get plusDesc => 'Planos, assinatura e restauração';

  @override
  String get settings => 'Configurações';

  @override
  String get settingsDesc => 'Tema, moeda, privacidade, biometria';

  @override
  String get privacyData => 'Privacidade e dados';

  @override
  String get privacyDataDesc => 'Exportar ou apagar tudo';

  @override
  String get help => 'Ajuda';

  @override
  String get helpDesc => 'Como o app calcula as coisas';

  @override
  String footerLocal(String version) {
    return 'SerenaCash · dados guardados neste aparelho · versão $version';
  }

  @override
  String get shoppingTitle => 'Compras';

  @override
  String get shoppingSubtitle => 'Listas e assistente de supermercado';

  @override
  String get shoppingInProgress => 'Compra em andamento';

  @override
  String sessionLine(int n, String total) {
    return '$n item(ns) · $total';
  }

  @override
  String get shoppingIntro =>
      'Leia etiquetas de preço e códigos de barras, veja o total e quanto ainda cabe no orçamento antes do caixa.';

  @override
  String get lists => 'Listas';

  @override
  String itemsCount(int n) {
    return '$n itens';
  }

  @override
  String estimated(String value) {
    return 'estimado $value';
  }

  @override
  String get noPricesYet => 'sem preços ainda';

  @override
  String withoutPrice(int n) {
    return ' ($n sem preço)';
  }

  @override
  String get noList => 'Nenhuma lista';

  @override
  String get noListText =>
      'Crie a lista em casa e use no mercado, mesmo sem internet.';

  @override
  String get previousPurchases => 'Compras anteriores';

  @override
  String get supermarket => 'Supermercado';

  @override
  String get registered => 'lançado';

  @override
  String get previousPurchasesText =>
      'As compras finalizadas aparecem aqui, com histórico de preços por loja.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearance => 'Aparência';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Automático';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get privacyModeHelp =>
      'Mostra R\$ •••• em todas as telas até você desligar.';

  @override
  String get haptics => 'Vibração ao confirmar';

  @override
  String get money => 'Dinheiro';

  @override
  String get currency => 'Moeda';

  @override
  String get currencyHelp =>
      'A moeda vale para novos lançamentos. Formato e idioma seguem o aparelho (pt-BR por padrão).';

  @override
  String get availabilityHorizon => 'Horizonte do \"pode gastar\"';

  @override
  String get monthEnd => 'Fim do mês';

  @override
  String get days30 => '30 dias';

  @override
  String get security => 'Segurança';

  @override
  String get biometricLock => 'Pedir biometria ao abrir';

  @override
  String get biometricAvailable => 'Face ID / impressão digital do aparelho.';

  @override
  String get biometricNotAvailable =>
      'Nenhuma biometria configurada neste aparelho.';

  @override
  String get pinLock => 'Proteger com PIN';

  @override
  String get pinLockHelp =>
      'PIN de 4 a 8 dígitos, guardado de forma protegida; nunca sai do aparelho.';

  @override
  String get setPin => 'Definir PIN';

  @override
  String get changePin => 'Trocar PIN';

  @override
  String get confirmPin => 'Confirme o PIN';

  @override
  String get pinMismatch => 'Os PINs não conferem.';

  @override
  String get pinFormat => 'Use de 4 a 8 dígitos.';

  @override
  String get lockOnBackground => 'Bloquear ao voltar do segundo plano';

  @override
  String get dataLocalHelp =>
      'Seus dados ficam só neste aparelho. Faça backups em Mais → Exportar.';

  @override
  String get reminders => 'Lembretes';

  @override
  String get remindersText =>
      'Aviso local no dia anterior e no dia do vencimento das contas previstas (próximos 7 dias). Nada sai do aparelho.';

  @override
  String get enableReminders => 'Ativar lembretes de vencimento';

  @override
  String get remindersEnabled => 'Lembretes ativados.';

  @override
  String get remindersDenied =>
      'Permissão de notificação negada ou indisponível.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Do aparelho';

  @override
  String get onbWelcomeTitle => 'Seu dinheiro em paz.';

  @override
  String get onbWelcomeText =>
      'Em menos de dois minutos você vai saber quanto pode gastar sem comprometer suas contas. Sem cadastro, sem senha de banco: tudo fica no seu aparelho.';

  @override
  String get onbStart => 'Começar';

  @override
  String get onbAccountTitle => 'Quanto você tem agora?';

  @override
  String get onbAccountText => 'Pode ser aproximado. Você ajusta depois.';

  @override
  String get accountName => 'Nome da conta';

  @override
  String get mainAccount => 'Conta principal';

  @override
  String get typeBank => 'Banco';

  @override
  String get typeDigital => 'Digital';

  @override
  String get typeCash => 'Dinheiro';

  @override
  String get typeSavings => 'Poupança';

  @override
  String get balanceToday => 'Saldo hoje';

  @override
  String get onbBillsTitle => 'Contas fixas deste mês';

  @override
  String get onbBillsText =>
      'Toque nas que você paga e informe o valor. Elas viram previstas e se repetem todo mês.';

  @override
  String get fixedRent => 'Aluguel';

  @override
  String get fixedPower => 'Luz';

  @override
  String get fixedInternet => 'Internet';

  @override
  String get fixedPhone => 'Celular';

  @override
  String get fixedWater => 'Água';

  @override
  String get onbCardTitle => 'Você usa cartão de crédito?';

  @override
  String get onbCardText =>
      'Com fechamento e vencimento o app mostra a fatura certa e nunca conta a compra duas vezes.';

  @override
  String get name => 'Nome';

  @override
  String get limit => 'Limite';

  @override
  String get closingDay => 'Dia do fechamento';

  @override
  String get dueDay => 'Dia do vencimento';

  @override
  String get continue_ => 'Continuar';

  @override
  String get skip => 'Pular';

  @override
  String get finish => 'Concluir';

  @override
  String get undoToastHint => 'Toque para desfazer';
}
