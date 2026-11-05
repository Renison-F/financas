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
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n itens',
      one: '1 item',
    );
    return '$_temp0';
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
      'Seus dados ficam só neste aparelho. Faça backups no menu, em Exportar e backup.';

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

  @override
  String get accountsTitle => 'Contas e carteiras';

  @override
  String get consolidatedBalance => 'Saldo consolidado';

  @override
  String get transfersDontChange =>
      'Transferências entre contas não alteram o total.';

  @override
  String get active => 'Ativas';

  @override
  String get archivedF => 'Arquivadas';

  @override
  String get typeCashL => 'Dinheiro';

  @override
  String get typeCheckingL => 'Conta bancária';

  @override
  String get typeSavingsL => 'Poupança';

  @override
  String get typeDigitalL => 'Carteira digital';

  @override
  String get typeInvestmentL => 'Investimento';

  @override
  String get typeOtherL => 'Outra';

  @override
  String get outOfAvailability => ' · fora do pode gastar';

  @override
  String get accountNotFound => 'Conta não encontrada';

  @override
  String get currentBalance => 'Saldo atual';

  @override
  String openingBalanceLine(String value, String date) {
    return 'Saldo inicial $value em $date';
  }

  @override
  String get archivedSuffix => ' · arquivada';

  @override
  String get history => 'Histórico';

  @override
  String get noMovements => 'Sem movimentações';

  @override
  String get reactivateAccount => 'Reativar conta';

  @override
  String get archiveAccount => 'Arquivar conta';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get archiveAccountQ => 'Arquivar conta?';

  @override
  String get archiveAccountText =>
      'Ela some das listas e do \'pode gastar\', mas o histórico continua. Você pode reativar depois.';

  @override
  String get archive => 'Arquivar';

  @override
  String get deleteAccountQ => 'Excluir conta?';

  @override
  String get deleteAccountText =>
      'Só é possível excluir contas sem lançamentos. Se houver movimentações, arquive.';

  @override
  String get accountHasTransactions =>
      'Esta conta tem lançamentos. Arquive-a ou mova os lançamentos antes de excluir.';

  @override
  String get editAccount => 'Editar conta';

  @override
  String get newAccount => 'Nova conta';

  @override
  String get accountNameHint => 'Ex.: Nubank, Carteira';

  @override
  String get type => 'Tipo';

  @override
  String get openingBalanceOnDate => 'Saldo inicial (na data abaixo)';

  @override
  String get openingHelpEdit =>
      'Para corrigir o saldo de hoje, use o ajuste abaixo.';

  @override
  String get openingHelpNew => 'O saldo de hoje vira o saldo inicial da conta.';

  @override
  String get openingDate => 'Data do saldo inicial';

  @override
  String get includeInAvailability => 'Considerar no \"pode gastar\"';

  @override
  String get includeHelp =>
      'Desligue para reservas, investimentos ou contas que você não usa no dia a dia.';

  @override
  String get color => 'Cor';

  @override
  String get adjustBalance => 'Ajustar saldo';

  @override
  String adjustHelp(String value) {
    return 'Saldo calculado hoje: $value. Informe o saldo real e o app cria um ajuste com a diferença (conciliação).';
  }

  @override
  String get realBalanceToday => 'Saldo real hoje';

  @override
  String get registerAdjustment => 'Registrar ajuste';

  @override
  String get balanceAdjustment => 'Ajuste de saldo';

  @override
  String get nameAccountErr => 'Dê um nome à conta.';

  @override
  String freeLimitAccounts(int n) {
    return 'Plano gratuito: até $n contas. Contas ilimitadas no SerenaCash Plus.';
  }

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get categoryNameHint => 'Ex.: Delivery';

  @override
  String get subcategoryOf => 'Subcategoria de (opcional)';

  @override
  String get expenseCategories => 'Categorias de despesa';

  @override
  String get incomeCategories => 'Categorias de receita';

  @override
  String get reactivate => 'Reativar';

  @override
  String get archivedLower => 'arquivada';

  @override
  String get tagsHelp =>
      'Tags marcam lançamentos de forma transversal (ex.: viagem, reembolsável).';

  @override
  String get newTag => 'Nova tag';

  @override
  String get tagHint => 'Ex.: viagem';

  @override
  String get creditCards => 'Cartões de crédito';

  @override
  String closesDueDays(int closing, int due) {
    return 'fecha dia $closing · vence dia $due';
  }

  @override
  String cardSummary(String month, String state, String free, String limit) {
    return 'Fatura $month ($state) · limite livre $free de $limit';
  }

  @override
  String get noCardListText =>
      'Com fechamento e vencimento o app mostra a fatura certa.';

  @override
  String get cardNotFound => 'Cartão não encontrado';

  @override
  String get previousInvoice => 'Fatura anterior';

  @override
  String get nextInvoice => 'Próxima fatura';

  @override
  String invoiceOf(String label) {
    return 'Fatura $label';
  }

  @override
  String invoiceState(String state) {
    return 'Fatura $state';
  }

  @override
  String closesOn(String date) {
    return 'fecha $date';
  }

  @override
  String totalPaid(String total, String paid) {
    return 'Total $total · pago $paid';
  }

  @override
  String get limitCommittedLabel => 'Limite comprometido';

  @override
  String limitBreakdown(
    String free,
    String limit,
    String current,
    String closed,
    String future,
  ) {
    return 'Limite livre $free de $limit (fatura atual $current + fechadas $closed + futuras $future)';
  }

  @override
  String get purchasesThisInvoice => 'Compras desta fatura';

  @override
  String get newPurchase => 'Nova compra';

  @override
  String get purchase => 'Compra';

  @override
  String installmentOf(int n, int of) {
    return ' · parcela $n/$of';
  }

  @override
  String get noPurchasesInvoice => 'Nenhuma compra nesta fatura.';

  @override
  String get payments => 'Pagamentos';

  @override
  String get payInvoice => 'Pagar fatura';

  @override
  String get payInvoiceHelp =>
      'O pagamento sai da conta e abate a fatura. Não vira despesa de novo: as compras já contaram quando aconteceram.';

  @override
  String totalOf(String value) {
    return 'Total $value';
  }

  @override
  String get minimum15 => 'Mínimo (15%)';

  @override
  String get paymentDate => 'Data do pagamento';

  @override
  String get registerPayment => 'Registrar pagamento';

  @override
  String get invoiceHistory => 'Histórico de faturas';

  @override
  String get noInvoicesYet => 'Ainda sem faturas.';

  @override
  String invoiceRule(int day) {
    return 'Regra: compras até o dia $day entram na fatura do mês; depois disso, na seguinte. Parcelas caem uma por fatura.';
  }

  @override
  String invoicePaymentDesc(String label) {
    return 'Pagamento fatura $label';
  }

  @override
  String get editCard => 'Editar cartão';

  @override
  String get newCard => 'Novo cartão';

  @override
  String get cardNameHint => 'Ex.: Cartão roxo';

  @override
  String get closingHelp =>
      'Compras depois desse dia vão para a próxima fatura.';

  @override
  String get paymentAccount => 'Conta usada para pagar a fatura';

  @override
  String get nameCardErr => 'Dê um nome ao cartão.';

  @override
  String get daysRangeErr =>
      'Dias de fechamento e vencimento devem estar entre 1 e 31.';

  @override
  String get closingChangeErr =>
      'Não dá para mudar o fechamento de um cartão com compras: as faturas mudariam de mês. Crie outro cartão.';

  @override
  String freeLimitCards(int n) {
    return 'Plano gratuito: $n cartão. Cartões ilimitados no SerenaCash Plus.';
  }

  @override
  String get committedPerInvoice => 'Comprometido por fatura';

  @override
  String installmentsCount(int n) {
    return '$n parcela(s)';
  }

  @override
  String get noFutureInstallments => 'Nenhuma parcela futura';

  @override
  String get perPurchase => 'Por compra';

  @override
  String get installmentPurchase => 'Compra parcelada';

  @override
  String pastInvoicesRemaining(int paid, int of, String value) {
    return '$paid/$of faturas passadas · restam $value';
  }

  @override
  String get noInstallmentPurchase => 'Nenhuma compra parcelada.';

  @override
  String plannedSuffix(String value) {
    return ' · $value previstos';
  }

  @override
  String paceUsed(String pace, int used, int expected) {
    return '$pace · $used% usado, $expected% do mês';
  }

  @override
  String get noBudgetListText =>
      'Defina um limite para uma categoria ou para o mês inteiro. A marca de hoje mostra se o ritmo está sereno.';

  @override
  String get budgetRules =>
      'Sereno: gasto até a marca de hoje. Atenção: até 10 pontos acima. Agitado: além disso ou acima do limite. Subcategorias somam no orçamento da categoria-mãe.';

  @override
  String get editBudget => 'Editar orçamento';

  @override
  String get newBudget => 'Novo orçamento';

  @override
  String get forLabel => 'Para';

  @override
  String get wholeMonth => 'O mês inteiro';

  @override
  String get monthlyLimit => 'Limite mensal';

  @override
  String get onlyThisMonth => 'Só para este mês';

  @override
  String get onlyThisMonthHelp => 'Desligado = vale todo mês até você mudar.';

  @override
  String get limitErr => 'Informe o limite.';

  @override
  String freeLimitBudgets(int n) {
    return 'Plano gratuito: até $n orçamentos. Ilimitados no SerenaCash Plus.';
  }

  @override
  String get deleteBudget => 'Excluir orçamento';

  @override
  String get deleteBudgetQ => 'Excluir orçamento?';

  @override
  String get deleteBudgetText => 'Os lançamentos não são afetados.';

  @override
  String get goalKindSavings => 'Economia';

  @override
  String get goalKindEmergency => 'Reserva de emergência';

  @override
  String get goalKindPurchase => 'Compra';

  @override
  String get goalKindDebt => 'Quitar dívida';

  @override
  String get goalKindOther => 'Outro';

  @override
  String get protectedSuffix => ' · protegida';

  @override
  String untilDate(String date) {
    return ' · até $date';
  }

  @override
  String goalSummary(int percent, String target, String remaining) {
    return '$percent% de $target · faltam $remaining';
  }

  @override
  String saveMonthly(String value, int months) {
    return ' · guarde $value/mês ($months meses)';
  }

  @override
  String suggestionMonthly(String value) {
    return ' · sugestão $value/mês';
  }

  @override
  String get deposit => 'Guardar';

  @override
  String get withdraw => 'Resgatar';

  @override
  String get noGoalListText =>
      'Uma reserva de emergência com 3 meses de despesas é um ótimo primeiro objetivo.';

  @override
  String get goalNotFound => 'Meta não encontrada';

  @override
  String get saved => 'Guardado';

  @override
  String get leavesAccount => 'Sai da conta';

  @override
  String get goesToAccount => 'Vai para a conta';

  @override
  String get movements => 'Movimentações';

  @override
  String get noMovementsYet => 'Nenhuma movimentação ainda.';

  @override
  String depositDesc(String name) {
    return 'Guardado: $name';
  }

  @override
  String withdrawDesc(String name) {
    return 'Resgate: $name';
  }

  @override
  String get editGoal => 'Editar meta';

  @override
  String get newGoal => 'Nova meta';

  @override
  String get goalNameHint => 'Ex.: Reserva de emergência';

  @override
  String get goalAmount => 'Valor da meta';

  @override
  String get hasDeadline => 'Tem prazo';

  @override
  String get untilWhen => 'Até quando';

  @override
  String get whereMoney => 'Onde o dinheiro fica';

  @override
  String get outsideApp => 'Fora das contas do app';

  @override
  String get whereMoneyHelp =>
      'Se ficar dentro de uma conta considerada no \"pode gastar\", o valor guardado é descontado de lá.';

  @override
  String get protectFromAvail => 'Proteger do \"pode gastar\"';

  @override
  String get protectHelp => 'O valor guardado nunca aparece como disponível.';

  @override
  String get archiveGoal => 'Arquivar meta';

  @override
  String get nameGoalErr => 'Dê um nome à meta.';

  @override
  String get goalAmountErr => 'Informe o valor da meta.';

  @override
  String freeLimitGoals(int n) {
    return 'Plano gratuito: até $n metas. Ilimitadas no SerenaCash Plus.';
  }

  @override
  String loanLineList(String system, String rate, int paid, int total) {
    return '$system · $rate% a.m. · $paid/$total pagas';
  }

  @override
  String overdueInstallments(int n) {
    return ' · $n atrasada(s)';
  }

  @override
  String get installmentsPaid => 'Parcelas pagas';

  @override
  String nextAndPayoff(String value, String date, String payoff) {
    return 'Próxima: $value em $date · quitar hoje ≈ $payoff';
  }

  @override
  String get paidOffCap => 'Quitado';

  @override
  String get noLoanListText =>
      'Cadastre financiamentos, crediário ou dívidas para ver saldo devedor, juros e simulação de quitação.';

  @override
  String get loanNotFound => 'Empréstimo não encontrado';

  @override
  String get outstanding => 'Saldo devedor';

  @override
  String paidSummary(int paid, int total, String value) {
    return '$paid de $total parcelas pagas · $value pagos';
  }

  @override
  String extraPaid(String value) {
    return ' ($value além das parcelas)';
  }

  @override
  String payoffToday(String value) {
    return 'Quitar hoje ≈ $value (valor presente das parcelas restantes à taxa do contrato, sem tarifas)';
  }

  @override
  String overdueInstallmentsMsg(int n) {
    return '$n parcela(s) atrasada(s).';
  }

  @override
  String get simulateExtra => 'Simular pagamento extra';

  @override
  String get extraAmount => 'Valor extra';

  @override
  String get reduceTerm => 'Reduzir prazo';

  @override
  String get reduceInstallment => 'Reduzir parcela';

  @override
  String get paysOffLoan => 'Quita o empréstimo.';

  @override
  String newTerm(int n, String value, int before) {
    return 'Novo prazo: $n parcelas de $value (antes $before).';
  }

  @override
  String newInstallment(String value, int n) {
    return 'Nova parcela: $value por $n meses.';
  }

  @override
  String get registerExtra => 'Registrar pagamento extra';

  @override
  String amortization(String name) {
    return 'Amortização: $name';
  }

  @override
  String get table => 'Tabela';

  @override
  String get editLoan => 'Editar empréstimo';

  @override
  String get newLoan => 'Novo empréstimo';

  @override
  String get loanNameHint => 'Ex.: Financiamento do carro';

  @override
  String get borrowed => 'Valor emprestado';

  @override
  String get monthlyRate => 'Juros (% ao mês)';

  @override
  String get system => 'Sistema';

  @override
  String get priceSystem => 'Price (parcela fixa)';

  @override
  String get sacSystem => 'SAC (decrescente)';

  @override
  String get firstDue => 'Primeiro vencimento';

  @override
  String get monthlyFee => 'Tarifa/seguro mensal (opcional)';

  @override
  String get registerDisbursement => 'Registrar a entrada do dinheiro na conta';

  @override
  String get registerDisbursementHelp => 'Ligue se o valor caiu na conta hoje.';

  @override
  String get createInstallments => 'Criar as parcelas como contas previstas';

  @override
  String get createInstallmentsHelp =>
      'Entram em \'contas a pagar\' e no \'pode gastar\' mês a mês.';

  @override
  String get preview => 'Prévia';

  @override
  String previewLine(int n, String first) {
    return '$n parcelas · primeira $first';
  }

  @override
  String lastInstallment(String value) {
    return ' · última $value';
  }

  @override
  String totalInterestCost(String interest, String cost) {
    return 'Juros totais $interest · custo total $cost';
  }

  @override
  String get loanAssumptions =>
      'Hipóteses: taxa nominal mensal sobre o saldo devedor; arredondamento por parcela; IOF e seguros só se informados.';

  @override
  String get loanFormErr => 'Preencha nome, valor, taxa (% ao mês) e prazo.';

  @override
  String get disbursementLabel => 'Entrada';

  @override
  String dayItems(String day, int n) {
    return '$day: $n lançamento(s)';
  }

  @override
  String get nothingThisDay => 'Nada neste dia.';

  @override
  String dayTotal(String value) {
    return 'Resultado do dia: $value';
  }

  @override
  String get thisMonth => 'Este mês';

  @override
  String get days90 => '90 dias';

  @override
  String overdueTotal(String value) {
    return 'Atrasadas · $value';
  }

  @override
  String get pay => 'Pagar';

  @override
  String dueUntil(String date, String value) {
    return 'A vencer até $date · $value';
  }

  @override
  String alreadyPaid(String value) {
    return ' · já pago $value';
  }

  @override
  String get nothingDuePeriod => 'Nada a vencer no período';

  @override
  String get billsHelp =>
      '\"Pagar\" marca como pago hoje na conta do lançamento. Para pagar parte, abra o lançamento.';

  @override
  String get cashflowReport => 'Fluxo de caixa';

  @override
  String get cashflowDesc =>
      'Receitas, despesas e saldo mês a mês; comparativo mensal e anual';

  @override
  String get categoriesDesc => 'Para onde o dinheiro foi, com filtros';

  @override
  String get recurringReport => 'Gastos recorrentes';

  @override
  String get recurringDesc => 'Assinaturas e contas que se repetem';

  @override
  String get projectionDesc => 'Como o saldo evolui com o que está previsto';

  @override
  String get indicatorsReport => 'Indicadores e patrimônio';

  @override
  String get indicatorsDesc => 'Taxa de poupança, comprometimento, patrimônio';

  @override
  String get exportHint =>
      'Exportação em CSV e PDF no menu, em Exportar e backup.';

  @override
  String get months6 => '6 meses';

  @override
  String get months12 => '12 meses';

  @override
  String get incomeVsExpenses => 'Receitas × despesas';

  @override
  String get monthByMonth => 'Mês a mês';

  @override
  String balanceShort(String value) {
    return 'saldo $value';
  }

  @override
  String get compareWithPrevious => 'Comparativo com o mês anterior';

  @override
  String yearLabel(int year) {
    return 'Ano $year';
  }

  @override
  String bestWorst(String best, String worst) {
    return 'Melhor mês: $best · pior: $worst';
  }

  @override
  String get groupSubcategories => 'Agrupar subcategorias';

  @override
  String get includePlanned => 'Incluir previstos';

  @override
  String totalLabel(String value) {
    return 'Total $value';
  }

  @override
  String transactionsCount(int n) {
    return '$n lançamento(s)';
  }

  @override
  String get seeMonthTransactions => 'Ver lançamentos do mês';

  @override
  String get plusFeature => 'Recurso do SerenaCash Plus';

  @override
  String get indicatorsPlusText =>
      'Taxa de poupança, comprometimento de renda e evolução do patrimônio nos últimos 12 meses.';

  @override
  String get knowPlus => 'Conhecer o Plus';

  @override
  String get thisMonthTitle => 'Este mês';

  @override
  String get savingRateHow =>
      '(receitas − despesas) ÷ receitas efetivadas do mês';

  @override
  String get commitmentHow =>
      '(saldo devedor dos cartões + próxima parcela de empréstimos) ÷ receitas do mês';

  @override
  String get netWorthHow =>
      'contas + reservas fora das contas − faturas em aberto − saldo devedor de empréstimos';

  @override
  String get netWorth12 => 'Patrimônio nos últimos 12 meses';

  @override
  String assetsDebts(String assets, String debts) {
    return 'ativos $assets · dívidas $debts';
  }

  @override
  String get indicatorsMethod =>
      'Metodologia transparente, calculada só com o que você registrou. Não é avaliação de crédito nem diagnóstico financeiro.';

  @override
  String get days60 => '60 dias';

  @override
  String onDate(String date) {
    return 'Em $date';
  }

  @override
  String negativeWarning(String value, String date) {
    return 'Atenção: o saldo fica negativo ($value) em $date.';
  }

  @override
  String minBalance(String value, String date) {
    return 'Menor saldo no período: $value em $date.';
  }

  @override
  String balanceAfter(String date, String value) {
    return '$date · saldo após $value';
  }

  @override
  String get nothingPlanned =>
      'Nada previsto no período. Cadastre contas e receitas previstas para projetar.';

  @override
  String get projectionRules =>
      'Considera lançamentos previstos, parcelas de empréstimo e faturas de cartão até o vencimento. Faturas atrasadas entram hoje.';

  @override
  String get perMonthLabel => 'Por mês';

  @override
  String get recurringHelp =>
      'Séries cadastradas e gastos repetidos (mesma descrição e valor em 3+ meses dos últimos 6).';

  @override
  String recurringLine(int n, String kind) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n meses',
      one: '1 mês',
    );
    return '$_temp0 · $kind';
  }

  @override
  String get series => 'série';

  @override
  String get detected => 'detectado';

  @override
  String get recurring => 'Recorrente';

  @override
  String get nothingRecurring => 'Nada recorrente detectado';

  @override
  String get nothingRecurringText =>
      'Com 3 meses de histórico o app encontra assinaturas e contas repetidas.';

  @override
  String recurringTip(String month, String year) {
    return 'Dica: revise assinaturas que você não usa; cada $month/mês são $year/ano.';
  }

  @override
  String get assistantIntro =>
      'Respostas calculadas com os seus dados, no aparelho. Nenhuma pergunta sai do celular.';

  @override
  String get askHint => 'Pergunte: posso comprar algo de 300,00?';

  @override
  String get ask => 'Perguntar';

  @override
  String get question => 'Pergunta';

  @override
  String get calculationBasis => 'Base do cálculo';

  @override
  String get suggestionsForYou => 'Sugestões para você';

  @override
  String get allCalmNoSuggestion => 'Tudo sereno. Nenhuma sugestão agora.';

  @override
  String get assistantRules =>
      'Regras transparentes: contas atrasadas, orçamentos acima do ritmo, cartão acima de 80% do limite, mês negativo, sobra ≥ 20% sem reserva, 3+ gastos recorrentes.';

  @override
  String get q1 => 'Quanto posso gastar?';

  @override
  String get q2 => 'Quais contas vencem esta semana?';

  @override
  String get q3 => 'Onde estou gastando mais?';

  @override
  String get q4 => 'Quanto gastei com supermercado?';

  @override
  String get q5 => 'Quanto falta para minha meta?';

  @override
  String get q6 => 'Quanto tenho comprometido em parcelas?';

  @override
  String get q7 => 'Como está o mês?';

  @override
  String get q8 => 'Como organizar minhas contas?';

  @override
  String get importTitle => 'Importar';

  @override
  String get importIntroTitle => 'CSV, OFX ou backup';

  @override
  String get importIntro =>
      'CSV do seu banco ou de outro app (data, descrição, valor, tipo); OFX de extrato bancário (Plus); ou um backup do SerenaCash / do app anterior. Você revisa tudo antes de confirmar e o app aponta possíveis duplicidades.';

  @override
  String get chooseFile => 'Escolher arquivo';

  @override
  String get fileReadError => 'Não foi possível ler o arquivo.';

  @override
  String columnsOf(String file) {
    return 'Colunas de $file';
  }

  @override
  String rowsCheck(int n) {
    return '$n linhas. Confira as colunas:';
  }

  @override
  String columnN(int n) {
    return 'Coluna $n';
  }

  @override
  String get typeColumn => 'Tipo (receita/despesa)';

  @override
  String get noTypeHelp =>
      'Sem coluna de tipo, valores negativos viram despesas e positivos, receitas.';

  @override
  String get chooseDateAmount => 'Escolha as colunas de data e valor.';

  @override
  String get reviewTransactions => 'Revisar lançamentos';

  @override
  String get restoreBackup => 'Restaurar backup';

  @override
  String get backupPassphrase => 'Senha do backup';

  @override
  String warningsCount(int n, String text) {
    return '$n aviso(s): $text';
  }

  @override
  String get restoreReplaces =>
      'Restaurar substitui TODOS os dados atuais deste aparelho.';

  @override
  String get replaceWithBackup => 'Substituir meus dados por este backup';

  @override
  String get restoreQ => 'Substituir todos os dados?';

  @override
  String get restoreText =>
      'Os dados atuais serão apagados e substituídos pelo backup. Exporte antes, se quiser guardar.';

  @override
  String get restore => 'Restaurar';

  @override
  String foundTransactions(int n) {
    return '$n lançamentos encontrados';
  }

  @override
  String dupesInfo(int d, int e) {
    return '$d possível(is) duplicidade(s) e $e com erro foram desmarcados. Toque para incluir ou excluir.';
  }

  @override
  String get targetAccount => 'Conta de destino';

  @override
  String get categoriesByName => 'Usar categorias pelo nome';

  @override
  String get include => 'Incluir';

  @override
  String get alreadyImported => 'já importado';

  @override
  String get sameAsExisting => 'igual a um lançamento existente';

  @override
  String get similarToExisting => 'parecido com um lançamento existente';

  @override
  String importN(int n) {
    return 'Importar $n';
  }

  @override
  String get chooseTargetAccount => 'Escolha a conta de destino.';

  @override
  String importResult(int n, int skipped) {
    return '$n lançamento(s) importado(s); $skipped ignorado(s).';
  }

  @override
  String get importDone => 'Importação concluída';

  @override
  String get restored => 'Backup restaurado.';

  @override
  String get backToStart => 'Voltar ao início';

  @override
  String get exportTitle => 'Exportar e backup';

  @override
  String get allScope => 'Tudo';

  @override
  String get csvSheet => 'CSV (planilha)';

  @override
  String get pdfReport => 'PDF (relatório)';

  @override
  String get fullBackup => 'Backup completo';

  @override
  String get backupHelp =>
      'Arquivo com tudo (contas, lançamentos, cartões, orçamentos, metas, empréstimos, preferências, anexos). Guarde em local seguro; restaure em Importar.';

  @override
  String get encryptedBackup => 'Backup cifrado (recomendado)';

  @override
  String get plainBackup => 'Backup em claro (compatível com o app anterior)';

  @override
  String get plainWarning =>
      'Sem senha: qualquer pessoa com o arquivo lê seus dados.';

  @override
  String get passphraseMin => 'Senha com ao menos 8 caracteres';

  @override
  String get fileGenerated => 'Arquivo gerado.';

  @override
  String get exportFailed => 'Falha ao exportar.';

  @override
  String reportOf(String month) {
    return 'Relatório de $month';
  }

  @override
  String get fullReport => 'Relatório completo';

  @override
  String generatedOn(String date) {
    return 'gerado em $date';
  }

  @override
  String get byCategory => 'Por categoria';

  @override
  String get pdfFooter =>
      'Valores efetivados e previstos conforme registrados pelo usuário. Compras no cartão contam na data da compra; pagamentos de fatura não são despesas.';

  @override
  String get privacyTitle => 'Privacidade e dados';

  @override
  String get whatWeKeep => 'O que guardamos';

  @override
  String get privacy1 =>
      'Contas, lançamentos, cartões, orçamentos, metas, empréstimos, listas e compras: tudo fica neste aparelho, em um banco de dados local cifrado.';

  @override
  String get privacy2 =>
      'Não pedimos e-mail, CPF nem senha de banco. Não há conexão bancária. Nenhum dado financeiro é enviado a servidores.';

  @override
  String get privacy3 =>
      'Assinaturas são processadas pela Apple ou pelo Google; recebemos apenas a confirmação do direito de acesso, nunca dados de pagamento.';

  @override
  String get privacy4 =>
      'A câmera é usada só para ler etiquetas e códigos durante a compra; as imagens não são guardadas.';

  @override
  String get yourRights => 'Seus direitos';

  @override
  String get exportAllData => 'Exportar todos os meus dados';

  @override
  String get eraseAll => 'Apagar tudo deste aparelho';

  @override
  String get eraseHelp =>
      'Apagar remove dados, preferências, chave do banco e cache de assinatura. Compras na loja podem ser restauradas depois.';

  @override
  String get privacyPolicyNote =>
      'Política de privacidade completa e termos: serão publicados em serenacash.app/privacidade antes do lançamento nas lojas.';

  @override
  String get eraseQ => 'Apagar tudo?';

  @override
  String get eraseText =>
      'Esta ação não pode ser desfeita. Exporte um backup antes, se quiser guardar o histórico.';

  @override
  String get eraseConfirm => 'Apagar definitivamente';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get faq1q => 'O que é \"pode gastar\"?';

  @override
  String get faq1a =>
      'Dinheiro nas contas consideradas, menos contas previstas até o fim do período (inclusive atrasadas), menos faturas de cartão em aberto, menos reservas guardadas dentro das contas e o colchão que você definir. Receitas previstas só entram no modo otimista. É uma estimativa, não um saldo.';

  @override
  String get faq2q => 'Compra no cartão conta duas vezes?';

  @override
  String get faq2a =>
      'Não. A compra é despesa na data em que aconteceu (na categoria dela). Pagar a fatura só tira dinheiro da conta e abate a fatura.';

  @override
  String get faq3q => 'Como funciona a fatura?';

  @override
  String get faq3a =>
      'Compras até o dia de fechamento entram na fatura do mês; depois, na seguinte. Parcelas caem uma por fatura. O vencimento é o dia que você cadastrou.';

  @override
  String get faq4q => 'O que é a marca de hoje?';

  @override
  String get faq4a =>
      'Nas barras de orçamento, a pequena onda mostra onde o gasto deveria estar hoje (proporcional aos dias do mês). Antes dela: sereno. Até 10 pontos depois: atenção. Além disso ou acima do limite: agitado.';

  @override
  String get faq5q => 'Previsto × efetivado';

  @override
  String get faq5a =>
      'Previsto é o que ainda vai acontecer (conta a pagar, salário a receber). Efetivado já aconteceu e altera o saldo. Pagamento parcial fica como \"parcial\" até completar.';

  @override
  String get faq6q => 'Reservas e metas';

  @override
  String get faq6a =>
      'Guardar dinheiro numa meta tira o valor da conta de origem. Se a meta fica dentro de uma conta considerada, o valor guardado é descontado do \"pode gastar\" (quando protegida).';

  @override
  String get faq7q => 'Empréstimos';

  @override
  String get faq7a =>
      'Tabela Price (parcela fixa) ou SAC (parcela decrescente), com taxa mensal sobre o saldo devedor. \"Quitar hoje\" é o valor presente das parcelas restantes à taxa do contrato, sem tarifas: uma estimativa para negociar.';

  @override
  String get faq8q => 'Supermercado';

  @override
  String get faq8a =>
      'Código de barras identifica o produto, não o preço. O preço vem da etiqueta lida (OCR), do seu histórico ou de você. Nada é adicionado sem confirmação, e o total do carrinho usa arredondamento de balança.';

  @override
  String get faq9q => 'Meus dados';

  @override
  String get faq9a =>
      'Tudo fica no aparelho, cifrado. Exporte backups no menu, em Exportar e backup. Apague tudo em Privacidade.';

  @override
  String featurePartOfPlus(String feature) {
    return '\"$feature\" faz parte do Plus.';
  }

  @override
  String thanksSupport(String plan) {
    return 'Plano $plan. Obrigado por apoiar o SerenaCash.';
  }

  @override
  String get whatChanges => 'O que muda';

  @override
  String get limitsRow => 'Contas / cartões / orçamentos / metas';

  @override
  String get unlimited => 'Ilimitados';

  @override
  String get ocrRow => 'Leitura de etiquetas (OCR)';

  @override
  String perMonthN(int n) {
    return '$n/mês';
  }

  @override
  String get unlimitedF => 'Ilimitada';

  @override
  String get reportsPdfRow => 'Relatórios avançados e PDF';

  @override
  String get yes => 'Sim';

  @override
  String get ofxAttachRow => 'Importação OFX e anexos';

  @override
  String get priceHistoryRow => 'Histórico de preços por loja';

  @override
  String get syncRow => 'Sincronização entre aparelhos';

  @override
  String get syncWhen => 'Assinatura (quando disponível)';

  @override
  String get essentialFree =>
      'O essencial (contas, lançamentos, 1 cartão, orçamentos, metas, listas e carrinho) é gratuito para sempre.';

  @override
  String get recommended => 'recomendado';

  @override
  String get lifetimeDesc =>
      'Pagamento único. Inclui tudo o que funciona no aparelho, para sempre. Não inclui serviços com custo recorrente (sincronização).';

  @override
  String get yearlyDesc =>
      'Cobrado uma vez por ano. Cancele quando quiser na loja.';

  @override
  String get monthlyDesc =>
      'Cobrado mensalmente. Cancele quando quiser na loja.';

  @override
  String get planCoverage => 'Abrangência do plano';

  @override
  String get perYear => ' / ano';

  @override
  String get perMonthShort => ' / mês';

  @override
  String get loadingPrice => 'Carregando preço da loja…';

  @override
  String get priceInStore =>
      'Preço e compra disponíveis na versão publicada nas lojas.';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get manageSubscription => 'Gerenciar assinatura na loja';

  @override
  String get thanksActive => 'Obrigado! Seu plano está ativo.';

  @override
  String get purchaseFailed => 'Compra não concluída.';

  @override
  String get purchasesRestored => 'Compras restauradas.';

  @override
  String get noPurchasesFound =>
      'Nenhuma compra encontrada nesta conta da loja.';

  @override
  String get restoreFailed => 'Não foi possível restaurar.';

  @override
  String get subscriptionTerms =>
      'Assinaturas renovam automaticamente até serem canceladas na App Store ou no Google Play. Reembolsos seguem as políticas das lojas. Termos e privacidade: Mais → Privacidade.';

  @override
  String get storeProcesses =>
      'Pagamento processado pela loja; não vemos seus dados de pagamento.';

  @override
  String plusFeaturesList(String list) {
    return 'Recursos do Plus: $list';
  }

  @override
  String get stayFree => 'Continuar no gratuito';

  @override
  String get notFound => 'Não encontrado';

  @override
  String get attachmentsTitle => 'Anexos e comprovantes';

  @override
  String get addPhoto => 'Tirar foto';

  @override
  String get addFile => 'Escolher arquivo';

  @override
  String get attachmentTooBig => 'Arquivo acima de 10 MB.';

  @override
  String get removeAttachment => 'Remover anexo';

  @override
  String attachmentCount(int n) {
    return '$n anexo(s)';
  }

  @override
  String get openAttachment => 'Abrir';

  @override
  String get attachmentsPlusHint => 'Anexos fazem parte do SerenaCash Plus.';

  @override
  String get changeHistory => 'Histórico de alterações';

  @override
  String get changeHistoryDesc =>
      'Registro de mudanças e estado de sincronização';

  @override
  String get syncStatus => 'Sincronização';

  @override
  String get syncLocalOnly =>
      'Somente neste aparelho. A sincronização entre aparelhos chega como serviço de assinatura; enquanto isso, todas as mudanças ficam registradas para envio futuro.';

  @override
  String pendingChanges(int n) {
    return '$n alteração(ões) registrada(s) e pendente(s) de envio';
  }

  @override
  String deviceLabel(String id) {
    return 'Aparelho $id';
  }

  @override
  String get recentChanges => 'Alterações recentes';

  @override
  String get opUpsert => 'salvo';

  @override
  String get opDelete => 'excluído';

  @override
  String get opRestore => 'restaurado';

  @override
  String versionN(int n) {
    return 'v$n';
  }

  @override
  String get noChangesYet => 'Nenhuma alteração registrada ainda.';

  @override
  String get entityAccount => 'Conta';

  @override
  String get entityCategory => 'Categoria';

  @override
  String get entityTag => 'Tag';

  @override
  String get entityCard => 'Cartão';

  @override
  String get entityTransaction => 'Lançamento';

  @override
  String get entityBudget => 'Orçamento';

  @override
  String get entityGoal => 'Meta';

  @override
  String get entityLoan => 'Empréstimo';

  @override
  String get entityRecurrence => 'Recorrência';

  @override
  String get entityPrefs => 'Preferências';

  @override
  String get entityList => 'Lista de compras';

  @override
  String get entitySession => 'Compra';

  @override
  String get entityProduct => 'Produto';

  @override
  String get entityObservation => 'Preço observado';

  @override
  String get entityLedger => 'Restauração';

  @override
  String get conflicts => 'Conflitos';

  @override
  String get noConflicts =>
      'Nenhum conflito. Campos monetários nunca são resolvidos automaticamente.';

  @override
  String get annualPlanning => 'Planejamento anual';

  @override
  String get annualDesc => 'Visão do ano: resultado por mês, orçamento e metas';

  @override
  String get previousYear => 'Ano anterior';

  @override
  String get nextYear => 'Próximo ano';

  @override
  String get yearResult => 'Resultado do ano';

  @override
  String get monthCol => 'Mês';

  @override
  String get budgetCol => 'Orçamento';

  @override
  String get annualGoals => 'Metas até o fim do ano';

  @override
  String goalNeedPerMonth(String name, String remaining, String value) {
    return '$name: faltam $remaining · $value/mês';
  }

  @override
  String get annualBudgetNote =>
      'Orçamento do mês = limite geral vigente no mês. Meses futuros mostram o previsto já registrado.';

  @override
  String get plannedShort => 'prev.';

  @override
  String get newList => 'Nova lista';

  @override
  String get create => 'Criar';

  @override
  String get listNameHint => 'Ex.: Compra do mês';

  @override
  String get storeOptional => 'Supermercado (opcional)';

  @override
  String get storeHint => 'Ex.: Mercado Bom';

  @override
  String get listBudgetLabel => 'Orçamento para esta compra (opcional)';

  @override
  String get listBudgetHelp =>
      'No mercado, o carrinho mostra quanto ainda cabe.';

  @override
  String freeLimitLists(int n) {
    return 'Plano gratuito: até $n listas.';
  }

  @override
  String get defaultListName => 'Compra do mês';

  @override
  String get listNotFound => 'Lista não encontrada';

  @override
  String get buy => 'Comprar';

  @override
  String estimateWithPrice(int known, int total) {
    return 'Estimativa ($known de $total com preço)';
  }

  @override
  String get budget => 'Orçamento';

  @override
  String get estimateVsBudget => 'Estimativa contra o orçamento';

  @override
  String checkedCount(int checked, int total) {
    return '$checked/$total marcados';
  }

  @override
  String unpricedItems(int n) {
    return ' · $n item(ns) sem preço (não estimados)';
  }

  @override
  String get addItem => 'Adicionar item';

  @override
  String get itemNameHint => 'Ex.: Arroz 5kg';

  @override
  String get itemName => 'Nome do item';

  @override
  String get qty => 'Qtd';

  @override
  String get unit => 'Unidade';

  @override
  String get categoryAndPrice => 'Categoria e preço estimado';

  @override
  String get estimatedUnitPrice => 'Preço estimado por unidade (opcional)';

  @override
  String get estimatedPriceHelp =>
      'Sem preço, o item entra na lista mas não na estimativa. Se já comprou antes, o histórico preenche sozinho.';

  @override
  String editItem(String name) {
    return 'Editar $name';
  }

  @override
  String get historySuffix => ' (histórico)';

  @override
  String get noPrice => ' · sem preço';

  @override
  String get emptyList => 'Lista vazia';

  @override
  String get emptyListText =>
      'Adicione os itens acima. Unidades: un, kg, g, L, mL, pacote, dúzia, caixa.';

  @override
  String get startWithList => 'Iniciar compra com esta lista';

  @override
  String get uncheckAll => 'Desmarcar tudo';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get deleteListQ => 'Excluir lista?';

  @override
  String get deleteListText =>
      'Os itens serão removidos. Compras finalizadas não são afetadas.';

  @override
  String get editItemTitle => 'Editar item';

  @override
  String get removeItem => 'Remover item';

  @override
  String get newPurchase2 => 'Nova compra';

  @override
  String fromList(String name, int n) {
    return 'A partir da lista \"$name\" ($n itens).';
  }

  @override
  String get noListSession =>
      'Sem lista: adicione itens pela câmera ou manualmente.';

  @override
  String get sessionBudgetLabel => 'Orçamento desta compra (opcional)';

  @override
  String get sessionBudgetHelp => 'O carrinho mostra quanto ainda cabe.';

  @override
  String get start => 'Começar';

  @override
  String get orChooseList => 'Ou escolha uma lista';

  @override
  String finishedOn(String date) {
    return 'Finalizada em $date';
  }

  @override
  String itemsInCart(int n) {
    return '$n item(ns) no carrinho';
  }

  @override
  String get exit => 'Sair';

  @override
  String get cartTotal => 'Total do carrinho';

  @override
  String stillFits(String remaining, String budget) {
    return 'Ainda cabe $remaining de $budget';
  }

  @override
  String overBudgetBy(String over, String budget) {
    return '$over acima do orçamento de $budget';
  }

  @override
  String get cartVsBudget => 'Carrinho contra o orçamento';

  @override
  String get noBudgetSession => 'Sem orçamento definido para esta compra.';

  @override
  String lowConfidenceItems(int n) {
    return '$n item(ns) com leitura de baixa confiança.';
  }

  @override
  String discountLine(String value) {
    return ' · desconto $value';
  }

  @override
  String get checkSuffix => ' · confira';

  @override
  String removeLine(String name) {
    return 'Remover $name';
  }

  @override
  String get emptyCart => 'Carrinho vazio';

  @override
  String get emptyCartText =>
      'Leia a etiqueta de preço ou o código de barras, ou adicione manualmente.';

  @override
  String fromListMissing(int n) {
    return 'Da lista ($n faltando)';
  }

  @override
  String get summary => 'Resumo';

  @override
  String plannedVsActualLine(String planned, String actual, String diff) {
    return 'Planejado (com preço): $planned · Realizado: $actual · Diferença: $diff';
  }

  @override
  String boughtLine(int bought, int notBought, int extra) {
    return '$bought da lista comprados · $notBought não comprados · $extra extras';
  }

  @override
  String receiptRead(String key) {
    return 'Cupom fiscal lido: chave …$key (consulta à SEFAZ não disponível offline).';
  }

  @override
  String get expenseRegistered => 'Despesa registrada nas finanças.';

  @override
  String registerAsExpense(String value) {
    return 'Registrar $value como despesa';
  }

  @override
  String get registerOnceHelp =>
      'Cria um único lançamento em Supermercado. Nunca é registrado duas vezes.';

  @override
  String get tagBtn => 'Etiqueta';

  @override
  String get codeBtn => 'Código';

  @override
  String get manualBtn => 'Manual';

  @override
  String get finishPurchase => 'Finalizar compra';

  @override
  String get confirmItem => 'Confirmar item';

  @override
  String readingConfidence(int percent) {
    return 'Confiança da leitura: $percent%';
  }

  @override
  String get product => 'Produto';

  @override
  String get productNameHint => 'Nome do produto';

  @override
  String pricePer(String unit) {
    return 'Preço por $unit';
  }

  @override
  String get unitPrice => 'Preço unitário';

  @override
  String previousTagPrice(String value) {
    return 'Preço anterior na etiqueta: $value';
  }

  @override
  String quantityUnit(String unit) {
    return 'Quantidade ($unit)';
  }

  @override
  String get quantity => 'Quantidade';

  @override
  String get promotion => 'Promoção';

  @override
  String get take3pay2 => 'Leve 3 pague 2';

  @override
  String get take2pay1 => 'Leve 2 pague 1';

  @override
  String get off10 => '10% off';

  @override
  String get off20 => '20% off';

  @override
  String subtotal(String value) {
    return 'Subtotal: $value';
  }

  @override
  String get addToCart => 'Adicionar ao carrinho';

  @override
  String get leavePurchaseQ => 'Sair da compra?';

  @override
  String get leavePurchaseText =>
      'O carrinho fica salvo e você pode continuar depois pela aba Compras.';

  @override
  String get leaveKeep => 'Sair e manter';

  @override
  String get newProductWarn =>
      'Produto novo: informe o nome e o preço da etiqueta.';

  @override
  String get scaleCodeWarn =>
      'Código de balança: o valor embutido pode ser peso ou preço; confirme.';

  @override
  String get ocrUnavailableWarn => 'Leitura indisponível: informe manualmente.';

  @override
  String variationWarn(String percent, String value) {
    return '$percent% em relação ao último preço ($value).';
  }

  @override
  String get lowConfidenceWarn =>
      'Leitura com baixa confiança: confira nome e preço.';

  @override
  String get noPriceInListWarn =>
      'Sem preço na lista: informe o preço da etiqueta.';

  @override
  String get groceriesCategory => 'Supermercado';

  @override
  String get camera => 'Câmera';

  @override
  String get cameraPermissionText =>
      'Para ler etiquetas de preço e códigos de barras, o SerenaCash precisa da câmera. As imagens não são guardadas nem enviadas.';

  @override
  String get allowCamera => 'Permitir câmera';

  @override
  String get enterManually => 'Informar manualmente';

  @override
  String get back => 'Voltar';

  @override
  String get cameraUnavailable => 'Câmera indisponível';

  @override
  String get frameTag =>
      'Enquadre a etiqueta inteira, sem reflexo, e toque em Ler';

  @override
  String get pointBarcode => 'Aponte para o código de barras ou QR do cupom';

  @override
  String get closeCamera => 'Fechar câmera';

  @override
  String get torchOn => 'Ligar lanterna';

  @override
  String get torchOff => 'Desligar lanterna';

  @override
  String get readTag => 'Ler etiqueta';

  @override
  String get readingTag => 'Lendo a etiqueta…';

  @override
  String get scanningAuto => 'Lendo automaticamente…';

  @override
  String get qrNotReceipt => 'QR lido, mas não é um cupom fiscal (NFC-e).';

  @override
  String get invalidCode => 'Código inválido; tente de novo.';

  @override
  String get readFailed => 'Falha na leitura. Tente de novo.';

  @override
  String get ocrUnavailable =>
      'Leitura de texto indisponível neste aparelho/versão. Informe o preço manualmente.';

  @override
  String get photoFailed => 'Não foi possível capturar a foto.';

  @override
  String get dayTotalHint =>
      'Receitas menos despesas. Transferências, pagamentos de fatura e reservas só movem dinheiro e não entram.';

  @override
  String get colorTeal => 'Azul-petróleo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorCopper => 'Cobre';

  @override
  String get colorAmber => 'Âmbar';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorGray => 'Cinza';

  @override
  String colorOther(String hex) {
    return 'Cor $hex';
  }

  @override
  String countAccounts(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n contas',
      one: '1 conta',
    );
    return '$_temp0';
  }

  @override
  String countCategories(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n categorias',
      one: '1 categoria',
    );
    return '$_temp0';
  }

  @override
  String countTags(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tags',
      one: '1 tag',
    );
    return '$_temp0';
  }

  @override
  String countCards(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cartões',
      one: '1 cartão',
    );
    return '$_temp0';
  }

  @override
  String countTransactions(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lançamentos',
      one: '1 lançamento',
    );
    return '$_temp0';
  }

  @override
  String countBudgets(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n orçamentos',
      one: '1 orçamento',
    );
    return '$_temp0';
  }

  @override
  String countGoals(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n metas',
      one: '1 meta',
    );
    return '$_temp0';
  }

  @override
  String countLoans(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n empréstimos',
      one: '1 empréstimo',
    );
    return '$_temp0';
  }

  @override
  String countAttachments(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n anexos',
      one: '1 anexo',
    );
    return '$_temp0';
  }

  @override
  String countRecurrenceRules(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n séries',
      one: '1 série',
    );
    return '$_temp0';
  }

  @override
  String countShoppingLists(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n listas de compras',
      one: '1 lista de compras',
    );
    return '$_temp0';
  }

  @override
  String countShoppingSessions(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n compras',
      one: '1 compra',
    );
    return '$_temp0';
  }

  @override
  String countProducts(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n produtos',
      one: '1 produto',
    );
    return '$_temp0';
  }

  @override
  String countPriceObservations(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n preços registrados',
      one: '1 preço registrado',
    );
    return '$_temp0';
  }

  @override
  String countOther(int n, String name) {
    return '$n $name';
  }

  @override
  String get finishPurchaseQ => 'Finalizar a compra?';

  @override
  String finishPurchaseText(String total) {
    return 'O carrinho é fechado com $total. Depois você escolhe se registra como despesa.';
  }

  @override
  String get finishPurchasePending =>
      'O item que você estava confirmando ainda não foi adicionado e ficará de fora.';

  @override
  String get finishConfirm => 'Finalizar';

  @override
  String get showSecret => 'Mostrar';

  @override
  String get hideSecret => 'Ocultar';

  @override
  String get homeSetupTitle => 'Configure seu saldo';

  @override
  String get homeSetupText =>
      'Adicione sua primeira conta para saber quanto pode gastar.';

  @override
  String get heroBalances => 'Saldo em contas';

  @override
  String get heroCommitted => 'Compromissos';

  @override
  String heroPlannedIncome(String value) {
    return 'Inclui $value de receitas previstas.';
  }

  @override
  String get quickBill => 'Conta a pagar';

  @override
  String get quickTransfer => 'Transferir';

  @override
  String get quickIncome => 'Receita';

  @override
  String get quickAccounts => 'Contas';

  @override
  String get seeAllFem => 'Ver todas';

  @override
  String get seeAllMasc => 'Ver todos';

  @override
  String get seeCards => 'Ver cartões';

  @override
  String billsPendingUntil(String date) {
    return 'Pendente até $date';
  }

  @override
  String billsOverdueCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n atrasadas',
      one: '1 atrasada',
    );
    return '$_temp0';
  }

  @override
  String get dueToday => 'Vence hoje';

  @override
  String get dueTomorrow => 'Vence amanhã';

  @override
  String dueInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Vence em $n dias',
      one: 'Vence em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String dueOnDate(String date) {
    return 'Vence $date';
  }

  @override
  String overdueSince(String date) {
    return 'Atrasada desde $date';
  }

  @override
  String get noBillPlanned => 'Nenhuma conta prevista';

  @override
  String moreBills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Mais $n contas',
      one: 'Mais 1 conta',
    );
    return '$_temp0';
  }

  @override
  String get firstCard => 'Adicione seu primeiro cartão';

  @override
  String get invoiceDueLabel => 'Vencimento';

  @override
  String invoiceCloses(String date) {
    return 'Fecha em $date';
  }

  @override
  String freeLimit(String value) {
    return 'Limite livre $value';
  }

  @override
  String moreCards(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Mais $n cartões',
      one: 'Mais 1 cartão',
    );
    return '$_temp0';
  }

  @override
  String get noTransactionYet => 'Nenhum lançamento ainda';

  @override
  String get useDarkTheme => 'Usar tema escuro';

  @override
  String get useLightTheme => 'Usar tema claro';

  @override
  String periodControl(String period) {
    return '$period. Mudar período e personalizar';
  }

  @override
  String get homeLoading => 'Carregando seus dados';

  @override
  String get noSpendingYet => 'Nenhum gasto neste período';

  @override
  String get noGoalYet => 'Nenhuma meta criada';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get canSpendThisMonth => 'Pode gastar neste mês';

  @override
  String get heroAfterCommitted => 'Após os compromissos previstos';

  @override
  String get heroCommittedMonth => 'Compromissos do mês';

  @override
  String get quickEntry => 'Lançamento';

  @override
  String get invoiceCurrent => 'Fatura atual';

  @override
  String get profile => 'Perfil';

  @override
  String get yourName => 'Seu nome';

  @override
  String get yourNameEmpty => 'Não informado';

  @override
  String get yourNameLabel => 'Como quer ser chamado';

  @override
  String get yourNameHelp =>
      'Aparece na saudação da tela inicial. Fica só neste aparelho.';

  @override
  String get catTitle => 'Categorias';

  @override
  String get catNewSub => 'Nova subcategoria';

  @override
  String get catEdit => 'Editar categoria';

  @override
  String get catEditSub => 'Editar subcategoria';

  @override
  String get catIcon => 'Ícone';

  @override
  String get catSearchIcon => 'Buscar ícone (ex.: mercado, saúde)';

  @override
  String catNoIcon(String q) {
    return 'Nenhum ícone para “$q”.';
  }

  @override
  String get catPreview => 'Prévia';

  @override
  String get catPreviewName => 'Nome da categoria';

  @override
  String get catParent => 'Categoria principal';

  @override
  String get catParentNone => 'Nenhuma: é uma categoria principal';

  @override
  String get catParentHelp =>
      'Uma subcategoria detalha a categoria principal. Os totais da principal já incluem as subcategorias.';

  @override
  String get catParentLocked =>
      'Esta categoria tem subcategorias, por isso continua como principal.';

  @override
  String catSubCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n subcategorias',
      one: '1 subcategoria',
      zero: 'Sem subcategorias',
    );
    return '$_temp0';
  }

  @override
  String catAddSubTo(String name) {
    return 'Adicionar subcategoria em $name';
  }

  @override
  String get catAddSub => 'Subcategoria';

  @override
  String get catArchivedSection => 'Arquivadas';

  @override
  String get catArchivedHelp =>
      'Categorias arquivadas continuam nos lançamentos antigos e nos relatórios, mas saem das listas de escolha.';

  @override
  String get catArchive => 'Arquivar';

  @override
  String get catArchiveText =>
      'Sai das listas de escolha. Os lançamentos que já usam esta categoria continuam como estão.';

  @override
  String get catReactivate => 'Reativar';

  @override
  String get catDelete => 'Excluir';

  @override
  String catDeleteTitle(String name) {
    return 'Excluir “$name”?';
  }

  @override
  String get catDeleteUnused => 'Nenhum lançamento usa esta categoria.';

  @override
  String catDeleteUsed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lançamentos usam esta categoria',
      one: '1 lançamento usa esta categoria',
    );
    return '$_temp0. Escolha o que fazer com eles:';
  }

  @override
  String catDeleteSubs(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'As $n subcategorias serão excluídas junto',
      one: 'A subcategoria será excluída junto',
    );
    return '$_temp0.';
  }

  @override
  String catDeleteBudgets(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n orçamentos desta categoria serão removidos',
      one: '1 orçamento desta categoria será removido',
    );
    return '$_temp0.';
  }

  @override
  String get catMoveTo => 'Mover para outra categoria';

  @override
  String get catMoveToPick => 'Escolher categoria de destino';

  @override
  String get catLeaveNone => 'Deixar sem categoria';

  @override
  String get catDeleteConfirm => 'Excluir categoria';

  @override
  String catDeleted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Categoria excluída. $n lançamentos reclassificados.',
      one: 'Categoria excluída. 1 lançamento reclassificado.',
      zero: 'Categoria excluída.',
    );
    return '$_temp0';
  }

  @override
  String get catErrEmpty => 'Informe um nome.';

  @override
  String get catErrDuplicate =>
      'Já existe uma categoria com esse nome neste nível.';

  @override
  String get catErrParent =>
      'Escolha uma categoria principal válida do mesmo tipo.';

  @override
  String get catErrHasSubs =>
      'Uma categoria com subcategorias não pode virar subcategoria.';

  @override
  String get catErrTarget => 'Escolha outra categoria de destino.';

  @override
  String get catSearch => 'Buscar categoria';

  @override
  String catNotFound(String q) {
    return 'Nenhuma categoria para “$q”.';
  }

  @override
  String catCreateNamed(String q) {
    return 'Criar “$q”';
  }

  @override
  String get catNone => 'Sem categoria';

  @override
  String get catChoose => 'Escolher categoria';

  @override
  String get catSubcategory => 'Subcategoria';

  @override
  String get catSubNone => 'Nenhuma';

  @override
  String get catNewSubShort => 'Nova';

  @override
  String catUsage(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lançamentos',
      one: '1 lançamento',
      zero: 'Sem lançamentos',
    );
    return '$_temp0';
  }

  @override
  String get catEmptyKind => 'Nenhuma categoria aqui ainda.';

  @override
  String get catAllCategories => 'Todas as categorias';

  @override
  String get catFilter => 'Categoria';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorSky => 'Azul-claro';

  @override
  String get colorOlive => 'Verde-oliva';

  @override
  String get colorGold => 'Dourado';

  @override
  String get colorRose => 'Rosado';

  @override
  String get colorBrown => 'Marrom';

  @override
  String get colorLightGray => 'Cinza-claro';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get navMenu => 'Menu';

  @override
  String get navGroupMain => 'Principal';

  @override
  String get navGroupMoves => 'Movimentações';

  @override
  String get navGroupPlanning => 'Planejamento';

  @override
  String get navGroupRegisters => 'Cadastros';

  @override
  String get navGroupSettings => 'Aplicativo';

  @override
  String get navCards => 'Cartões de crédito';

  @override
  String get navCategories => 'Categorias e subcategorias';

  @override
  String get addTitle => 'Adicionar';

  @override
  String get addExpense => 'Despesa';

  @override
  String get addExpenseDesc => 'Dinheiro que saiu de uma conta';

  @override
  String get addIncome => 'Receita';

  @override
  String get addIncomeDesc => 'Dinheiro que entrou em uma conta';

  @override
  String get addTransfer => 'Transferência';

  @override
  String get addTransferDesc => 'Entre duas contas suas';

  @override
  String get addCardPurchase => 'Compra no cartão';

  @override
  String get addCardPurchaseDesc => 'Entra na fatura do cartão de crédito';

  @override
  String get addBill => 'Conta a pagar';

  @override
  String get addBillDesc => 'Despesa com vencimento, ainda não paga';

  @override
  String get addReceivable => 'Conta a receber';

  @override
  String get addReceivableDesc => 'Receita prevista, ainda não recebida';

  @override
  String get repDirectInCategory => 'Direto na categoria';

  @override
  String get repSubsIncluded =>
      'O total de cada categoria já inclui as subcategorias listadas abaixo dela.';

  @override
  String get billsBoth => 'A pagar e a receber';

  @override
  String get segPayable => 'A pagar';

  @override
  String get segReceivable => 'A receber';

  @override
  String get receive => 'Receber';

  @override
  String receivableUntil(String date, String value) {
    return 'A receber até $date · $value';
  }

  @override
  String receivableLate(String value) {
    return 'Atrasadas · $value';
  }

  @override
  String get nothingToReceive => 'Nada a receber no período';

  @override
  String get newReceivable => 'Nova conta a receber';

  @override
  String get receivablesHelp =>
      '“Receber” marca como recebido hoje na conta do lançamento. Para receber parte, abra o lançamento.';

  @override
  String expectedOn(String date) {
    return 'Previsto para $date';
  }

  @override
  String expectedSince(String date) {
    return 'Previsto desde $date';
  }

  @override
  String get plannedHelpIncome =>
      'Receitas previstas aparecem em \"A receber\" e só entram no saldo quando você marcar como recebidas.';

  @override
  String get bootKeyMissing =>
      'A chave que protege seus dados não está mais neste aparelho, então o banco não pode ser aberto. Isso acontece, por exemplo, quando os dados do app são copiados de outro aparelho.';

  @override
  String get bootKeyInvalid =>
      'A chave que protege seus dados está danificada, então o banco não pode ser aberto.';

  @override
  String get bootGeneric =>
      'O banco de dados protegido não abriu. Pode ser uma falha passageira do aparelho ou um arquivo danificado.';

  @override
  String get bootRecoverHelp =>
      'Tente de novo primeiro. Se continuar, a saída é apagar os dados deste aparelho e recomeçar; depois você pode restaurar um backup exportado pelo SerenaCash.';

  @override
  String get bootRetry => 'Tentar de novo';

  @override
  String get bootReset => 'Apagar dados e recomeçar';

  @override
  String get bootResetQ => 'Apagar os dados deste aparelho?';

  @override
  String get bootResetText =>
      'Tudo o que está guardado no SerenaCash neste aparelho será apagado e não poderá ser recuperado daqui. Um backup exportado antes continua valendo e pode ser restaurado depois.';

  @override
  String bootDetails(String detail) {
    return 'Detalhe técnico: $detail';
  }

  @override
  String pinLockedFor(String time) {
    return 'Muitas tentativas. Tente de novo em $time.';
  }

  @override
  String pinAttemptsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'PIN incorreto. Restam $n tentativas antes de uma pausa.',
      one: 'PIN incorreto. Resta 1 tentativa antes de uma pausa.',
    );
    return '$_temp0';
  }

  @override
  String get pinForgot => 'Esqueci o PIN';

  @override
  String get pinForgotTitle => 'O PIN não pode ser recuperado';

  @override
  String get pinForgotText =>
      'O SerenaCash não guarda o PIN em nenhum lugar de onde ele possa ser lido, nem envia nada para fora do aparelho. Sem o PIN, a única saída é apagar os dados deste aparelho e recomeçar. Se você exportou um backup, pode restaurá-lo depois.';

  @override
  String get pinCurrent => 'PIN atual';

  @override
  String get pinDisableTitle => 'Confirme o PIN para desativar';

  @override
  String get lockScreenProtected =>
      'Com o bloqueio ativado, o app também esconde o conteúdo na lista de apps recentes e impede capturas de tela.';

  @override
  String get lockRecover => 'Não consigo desbloquear';

  @override
  String get lockRecoverText =>
      'Se o desbloqueio do aparelho não funciona mais aqui, a única saída é apagar os dados deste aparelho e recomeçar. Se você exportou um backup, pode restaurá-lo depois.';

  @override
  String get biometricConfirmToEnable =>
      'Confirme no aparelho para ativar o bloqueio';

  @override
  String get biometricNotEnabled =>
      'Não foi possível confirmar no aparelho; o bloqueio não foi ativado. Configure um bloqueio de tela ou biometria no Android e tente de novo.';
}
