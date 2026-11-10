import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'SerenaCash'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get tabHome;

  /// No description provided for @tabTransactions.
  ///
  /// In pt, this message translates to:
  /// **'Lançamentos'**
  String get tabTransactions;

  /// No description provided for @tabShopping.
  ///
  /// In pt, this message translates to:
  /// **'Compras'**
  String get tabShopping;

  /// No description provided for @tabPlan.
  ///
  /// In pt, this message translates to:
  /// **'Planejar'**
  String get tabPlan;

  /// No description provided for @tabMore.
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get tabMore;

  /// No description provided for @greetingMorning.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In pt, this message translates to:
  /// **'Boa tarde'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In pt, this message translates to:
  /// **'Boa noite'**
  String get greetingEvening;

  /// No description provided for @showValues.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar valores'**
  String get showValues;

  /// No description provided for @hideValues.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar valores'**
  String get hideValues;

  /// No description provided for @customizeHome.
  ///
  /// In pt, this message translates to:
  /// **'Personalizar tela inicial'**
  String get customizeHome;

  /// No description provided for @addTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar lançamento'**
  String get addTransaction;

  /// No description provided for @noWidgetsVisible.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum widget visível. Toque na engrenagem para escolher o que ver.'**
  String get noWidgetsVisible;

  /// No description provided for @widgetLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar'**
  String get widgetLoadError;

  /// No description provided for @tapToRetry.
  ///
  /// In pt, this message translates to:
  /// **'Toque para tentar de novo.'**
  String get tapToRetry;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @seeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get seeAll;

  /// No description provided for @see.
  ///
  /// In pt, this message translates to:
  /// **'Ver'**
  String get see;

  /// No description provided for @all.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get all;

  /// No description provided for @new_.
  ///
  /// In pt, this message translates to:
  /// **'Novo'**
  String get new_;

  /// No description provided for @newF.
  ///
  /// In pt, this message translates to:
  /// **'Nova'**
  String get newF;

  /// No description provided for @add.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// No description provided for @register.
  ///
  /// In pt, this message translates to:
  /// **'Registrar'**
  String get register;

  /// No description provided for @details.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get details;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loadingError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir seus dados.'**
  String get loadingError;

  /// No description provided for @unlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueado'**
  String get unlockTitle;

  /// No description provided for @unlockText.
  ///
  /// In pt, this message translates to:
  /// **'Confirme sua identidade para ver seus dados.'**
  String get unlockText;

  /// No description provided for @unlock.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear'**
  String get unlock;

  /// No description provided for @unlockPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear SerenaCash'**
  String get unlockPrompt;

  /// No description provided for @biometricFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível confirmar sua identidade.'**
  String get biometricFailed;

  /// No description provided for @biometricUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Biometria indisponível neste aparelho.'**
  String get biometricUnavailable;

  /// No description provided for @pinLabel.
  ///
  /// In pt, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @pinWrong.
  ///
  /// In pt, this message translates to:
  /// **'PIN incorreto.'**
  String get pinWrong;

  /// No description provided for @usePin.
  ///
  /// In pt, this message translates to:
  /// **'Usar PIN'**
  String get usePin;

  /// No description provided for @useBiometrics.
  ///
  /// In pt, this message translates to:
  /// **'Usar biometria'**
  String get useBiometrics;

  /// No description provided for @canSpendUntil.
  ///
  /// In pt, this message translates to:
  /// **'Pode gastar até {date}'**
  String canSpendUntil(String date);

  /// No description provided for @canSpendTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pode gastar'**
  String get canSpendTitle;

  /// No description provided for @startWithAccount.
  ///
  /// In pt, this message translates to:
  /// **'Comece pela sua conta'**
  String get startWithAccount;

  /// No description provided for @startWithAccountText.
  ///
  /// In pt, this message translates to:
  /// **'Com o saldo de uma conta o app já mostra quanto cabe gastar.'**
  String get startWithAccountText;

  /// No description provided for @addAccount.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar conta'**
  String get addAccount;

  /// No description provided for @availNegative.
  ///
  /// In pt, this message translates to:
  /// **'As contas registradas passam do dinheiro disponível.'**
  String get availNegative;

  /// No description provided for @availTight.
  ///
  /// In pt, this message translates to:
  /// **'Está apertado: o que sobra cobre pouco mais que as contas.'**
  String get availTight;

  /// No description provided for @availOk.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa com o que está registrado, não um saldo garantido.'**
  String get availOk;

  /// No description provided for @modeOptimistic.
  ///
  /// In pt, this message translates to:
  /// **'Modo otimista'**
  String get modeOptimistic;

  /// No description provided for @modePrudent.
  ///
  /// In pt, this message translates to:
  /// **'Modo prudente'**
  String get modePrudent;

  /// No description provided for @howWeCalculate.
  ///
  /// In pt, this message translates to:
  /// **'Como calculamos ›'**
  String get howWeCalculate;

  /// No description provided for @totalBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo total'**
  String get totalBalance;

  /// No description provided for @accounts.
  ///
  /// In pt, this message translates to:
  /// **'Contas'**
  String get accounts;

  /// No description provided for @noAccount.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta'**
  String get noAccount;

  /// No description provided for @balancesByAccount.
  ///
  /// In pt, this message translates to:
  /// **'Saldos por conta'**
  String get balancesByAccount;

  /// No description provided for @income.
  ///
  /// In pt, this message translates to:
  /// **'Receitas'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get expenses;

  /// No description provided for @plannedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Previstas: {value}'**
  String plannedLabel(String value);

  /// No description provided for @plannedAndCard.
  ///
  /// In pt, this message translates to:
  /// **'Previstas: {planned} · no cartão: {card}'**
  String plannedAndCard(String planned, String card);

  /// No description provided for @billsToPay.
  ///
  /// In pt, this message translates to:
  /// **'Contas a pagar'**
  String get billsToPay;

  /// No description provided for @bill.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get bill;

  /// No description provided for @dueOn.
  ///
  /// In pt, this message translates to:
  /// **'vence {date}'**
  String dueOn(String date);

  /// No description provided for @duePast.
  ///
  /// In pt, this message translates to:
  /// **'venceu {date}'**
  String duePast(String date);

  /// No description provided for @nothingToPay.
  ///
  /// In pt, this message translates to:
  /// **'Nada a pagar até o fim do período'**
  String get nothingToPay;

  /// No description provided for @nothingToPayText.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre contas previstas para o \'pode gastar\' ficar honesto.'**
  String get nothingToPayText;

  /// No description provided for @newBillToPay.
  ///
  /// In pt, this message translates to:
  /// **'Nova conta a pagar'**
  String get newBillToPay;

  /// No description provided for @overdueBills.
  ///
  /// In pt, this message translates to:
  /// **'Contas atrasadas'**
  String get overdueBills;

  /// No description provided for @noOverdue.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta atrasada.'**
  String get noOverdue;

  /// No description provided for @next7days.
  ///
  /// In pt, this message translates to:
  /// **'Próximos 7 dias'**
  String get next7days;

  /// No description provided for @calendar.
  ///
  /// In pt, this message translates to:
  /// **'Calendário'**
  String get calendar;

  /// No description provided for @noDueNext7.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vencimento nos próximos 7 dias.'**
  String get noDueNext7;

  /// No description provided for @cardsAndInvoices.
  ///
  /// In pt, this message translates to:
  /// **'Cartões e faturas'**
  String get cardsAndInvoices;

  /// No description provided for @invoiceLine.
  ///
  /// In pt, this message translates to:
  /// **'Fatura {state} · vence {date} · limite livre {free}'**
  String invoiceLine(String state, String date, String free);

  /// No description provided for @invoiceOpen.
  ///
  /// In pt, this message translates to:
  /// **'aberta'**
  String get invoiceOpen;

  /// No description provided for @invoiceClosed.
  ///
  /// In pt, this message translates to:
  /// **'fechada'**
  String get invoiceClosed;

  /// No description provided for @invoicePaid.
  ///
  /// In pt, this message translates to:
  /// **'paga'**
  String get invoicePaid;

  /// No description provided for @invoiceOverdue.
  ///
  /// In pt, this message translates to:
  /// **'atrasada'**
  String get invoiceOverdue;

  /// No description provided for @invoiceFuture.
  ///
  /// In pt, this message translates to:
  /// **'futura'**
  String get invoiceFuture;

  /// No description provided for @limitCommitted.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% do limite comprometido'**
  String limitCommitted(int percent);

  /// No description provided for @noCard.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum cartão'**
  String get noCard;

  /// No description provided for @noCardText.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre fechamento e vencimento para acompanhar a fatura.'**
  String get noCardText;

  /// No description provided for @addCard.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar cartão'**
  String get addCard;

  /// No description provided for @installmentPurchases.
  ///
  /// In pt, this message translates to:
  /// **'Compras parceladas'**
  String get installmentPurchases;

  /// No description provided for @committedFuture.
  ///
  /// In pt, this message translates to:
  /// **'comprometidos em faturas futuras'**
  String get committedFuture;

  /// No description provided for @monthlyBudget.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento do mês'**
  String get monthlyBudget;

  /// No description provided for @budgets.
  ///
  /// In pt, this message translates to:
  /// **'Orçamentos'**
  String get budgets;

  /// No description provided for @ofLimit.
  ///
  /// In pt, this message translates to:
  /// **'de {value}'**
  String ofLimit(String value);

  /// No description provided for @monthPace.
  ///
  /// In pt, this message translates to:
  /// **'Gasto {pace}'**
  String monthPace(String pace);

  /// No description provided for @paceSereno.
  ///
  /// In pt, this message translates to:
  /// **'dentro do previsto'**
  String get paceSereno;

  /// No description provided for @paceAtencao.
  ///
  /// In pt, this message translates to:
  /// **'pouco acima do previsto'**
  String get paceAtencao;

  /// No description provided for @paceAgitado.
  ///
  /// In pt, this message translates to:
  /// **'acima do previsto'**
  String get paceAgitado;

  /// No description provided for @general.
  ///
  /// In pt, this message translates to:
  /// **'Geral'**
  String get general;

  /// No description provided for @noBudgetYet.
  ///
  /// In pt, this message translates to:
  /// **'Sem orçamento ainda'**
  String get noBudgetYet;

  /// No description provided for @noBudgetText.
  ///
  /// In pt, this message translates to:
  /// **'Defina um limite para o mês e acompanhe o ritmo com a marca de hoje.'**
  String get noBudgetText;

  /// No description provided for @createBudget.
  ///
  /// In pt, this message translates to:
  /// **'Criar orçamento'**
  String get createBudget;

  /// No description provided for @spendingByCategory.
  ///
  /// In pt, this message translates to:
  /// **'Gastos por categoria'**
  String get spendingByCategory;

  /// No description provided for @report.
  ///
  /// In pt, this message translates to:
  /// **'Relatório'**
  String get report;

  /// No description provided for @noExpensesMonth.
  ///
  /// In pt, this message translates to:
  /// **'Sem despesas neste mês'**
  String get noExpensesMonth;

  /// No description provided for @registerExpense.
  ///
  /// In pt, this message translates to:
  /// **'Registrar despesa'**
  String get registerExpense;

  /// No description provided for @evolution.
  ///
  /// In pt, this message translates to:
  /// **'Evolução'**
  String get evolution;

  /// No description provided for @cashflow.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo'**
  String get cashflow;

  /// No description provided for @noHistory.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem histórico'**
  String get noHistory;

  /// No description provided for @noHistoryText.
  ///
  /// In pt, this message translates to:
  /// **'Registre receitas e despesas para ver a evolução.'**
  String get noHistoryText;

  /// No description provided for @incomeOf.
  ///
  /// In pt, this message translates to:
  /// **'Receitas {month}: {value}'**
  String incomeOf(String month, String value);

  /// No description provided for @expensesOf.
  ///
  /// In pt, this message translates to:
  /// **'Despesas {month}: {value}'**
  String expensesOf(String month, String value);

  /// No description provided for @goals.
  ///
  /// In pt, this message translates to:
  /// **'Metas'**
  String get goals;

  /// No description provided for @noGoal.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma meta'**
  String get noGoal;

  /// No description provided for @noGoalText.
  ///
  /// In pt, this message translates to:
  /// **'Uma reserva de emergência é um bom começo.'**
  String get noGoalText;

  /// No description provided for @createGoal.
  ///
  /// In pt, this message translates to:
  /// **'Criar meta'**
  String get createGoal;

  /// No description provided for @reserves.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get reserves;

  /// No description provided for @reservesText.
  ///
  /// In pt, this message translates to:
  /// **'separado e fora do \"pode gastar\"'**
  String get reservesText;

  /// No description provided for @monthlySavings.
  ///
  /// In pt, this message translates to:
  /// **'Economia do mês'**
  String get monthlySavings;

  /// No description provided for @registerIncomeForRate.
  ///
  /// In pt, this message translates to:
  /// **'Registre receitas para ver a taxa de economia.'**
  String get registerIncomeForRate;

  /// No description provided for @percentOfIncome.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% das receitas'**
  String percentOfIncome(int percent);

  /// No description provided for @subscriptions.
  ///
  /// In pt, this message translates to:
  /// **'Assinaturas e recorrentes'**
  String get subscriptions;

  /// No description provided for @monthsInARow.
  ///
  /// In pt, this message translates to:
  /// **'{n} meses seguidos'**
  String monthsInARow(int n);

  /// No description provided for @noRecurring.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum gasto recorrente detectado ainda.'**
  String get noRecurring;

  /// No description provided for @loans.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimos'**
  String get loans;

  /// No description provided for @nextInstallment.
  ///
  /// In pt, this message translates to:
  /// **'próxima {date} · {value}'**
  String nextInstallment(String date, String value);

  /// No description provided for @paidOff.
  ///
  /// In pt, this message translates to:
  /// **'quitado'**
  String get paidOff;

  /// No description provided for @noLoan.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum empréstimo'**
  String get noLoan;

  /// No description provided for @registerLoan.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get registerLoan;

  /// No description provided for @open.
  ///
  /// In pt, this message translates to:
  /// **'Abrir'**
  String get open;

  /// No description provided for @calendarSummary.
  ///
  /// In pt, this message translates to:
  /// **'{n} vencimento(s) até {date}'**
  String calendarSummary(int n, String date);

  /// No description provided for @overdueCount.
  ///
  /// In pt, this message translates to:
  /// **' · {n} atrasado(s)'**
  String overdueCount(int n);

  /// No description provided for @recentTransactions.
  ///
  /// In pt, this message translates to:
  /// **'Últimos lançamentos'**
  String get recentTransactions;

  /// No description provided for @allLabel.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get allLabel;

  /// No description provided for @planned.
  ///
  /// In pt, this message translates to:
  /// **'previsto'**
  String get planned;

  /// No description provided for @noTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum lançamento'**
  String get noTransaction;

  /// No description provided for @suggestions.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões'**
  String get suggestions;

  /// No description provided for @assistant.
  ///
  /// In pt, this message translates to:
  /// **'Assistente'**
  String get assistant;

  /// No description provided for @allCalm.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum alerta no momento.'**
  String get allCalm;

  /// No description provided for @shoppingLists.
  ///
  /// In pt, this message translates to:
  /// **'Listas de compras'**
  String get shoppingLists;

  /// No description provided for @listCount.
  ///
  /// In pt, this message translates to:
  /// **'{n} lista(s)'**
  String listCount(int n);

  /// No description provided for @noListYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma lista ainda.'**
  String get noListYet;

  /// No description provided for @createList.
  ///
  /// In pt, this message translates to:
  /// **'Criar lista'**
  String get createList;

  /// No description provided for @shoppingAssistant.
  ///
  /// In pt, this message translates to:
  /// **'Assistente de supermercado'**
  String get shoppingAssistant;

  /// No description provided for @sessionsCount.
  ///
  /// In pt, this message translates to:
  /// **'{n} compra(s) registrada(s)'**
  String sessionsCount(int n);

  /// No description provided for @shoppingAssistantText.
  ///
  /// In pt, this message translates to:
  /// **'Leia etiquetas e códigos e veja o total antes do caixa.'**
  String get shoppingAssistantText;

  /// No description provided for @startShopping.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar compra'**
  String get startShopping;

  /// No description provided for @continueShopping.
  ///
  /// In pt, this message translates to:
  /// **'Continuar compra'**
  String get continueShopping;

  /// No description provided for @advancedIndicators.
  ///
  /// In pt, this message translates to:
  /// **'Indicadores avançados'**
  String get advancedIndicators;

  /// No description provided for @methodology.
  ///
  /// In pt, this message translates to:
  /// **'Metodologia'**
  String get methodology;

  /// No description provided for @savingRate.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de poupança (mês)'**
  String get savingRate;

  /// No description provided for @committedIncome.
  ///
  /// In pt, this message translates to:
  /// **'Renda comprometida (cartões + parcela)'**
  String get committedIncome;

  /// No description provided for @netWorth.
  ///
  /// In pt, this message translates to:
  /// **'Patrimônio líquido'**
  String get netWorth;

  /// No description provided for @indicatorsDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Cálculos sobre os dados registrados; não são diagnóstico financeiro.'**
  String get indicatorsDisclaimer;

  /// No description provided for @kindIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get kindIncome;

  /// No description provided for @kindExpense.
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get kindExpense;

  /// No description provided for @kindTransfer.
  ///
  /// In pt, this message translates to:
  /// **'Transferência'**
  String get kindTransfer;

  /// No description provided for @kindCardPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Compra no cartão'**
  String get kindCardPurchase;

  /// No description provided for @kindCardPayment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento de fatura'**
  String get kindCardPayment;

  /// No description provided for @kindGoalDeposit.
  ///
  /// In pt, this message translates to:
  /// **'Depósito em reserva'**
  String get kindGoalDeposit;

  /// No description provided for @kindGoalWithdrawal.
  ///
  /// In pt, this message translates to:
  /// **'Resgate de reserva'**
  String get kindGoalWithdrawal;

  /// No description provided for @kindLoanDisbursement.
  ///
  /// In pt, this message translates to:
  /// **'Entrada de empréstimo'**
  String get kindLoanDisbursement;

  /// No description provided for @kindLoanPayment.
  ///
  /// In pt, this message translates to:
  /// **'Parcela de empréstimo'**
  String get kindLoanPayment;

  /// No description provided for @kindBalanceAdjustment.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste de saldo'**
  String get kindBalanceAdjustment;

  /// No description provided for @kindCardRefund.
  ///
  /// In pt, this message translates to:
  /// **'Estorno no cartão'**
  String get kindCardRefund;

  /// No description provided for @customizeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tela inicial'**
  String get customizeTitle;

  /// No description provided for @presets.
  ///
  /// In pt, this message translates to:
  /// **'Modelos'**
  String get presets;

  /// No description provided for @restoreDefault.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar padrão'**
  String get restoreDefault;

  /// No description provided for @visibleWidgets.
  ///
  /// In pt, this message translates to:
  /// **'Visíveis (segure e arraste, ou use as setas)'**
  String get visibleWidgets;

  /// No description provided for @hiddenWidgets.
  ///
  /// In pt, this message translates to:
  /// **'Ocultos'**
  String get hiddenWidgets;

  /// No description provided for @moveUp.
  ///
  /// In pt, this message translates to:
  /// **'Mover {name} para cima'**
  String moveUp(String name);

  /// No description provided for @moveDown.
  ///
  /// In pt, this message translates to:
  /// **'Mover {name} para baixo'**
  String moveDown(String name);

  /// No description provided for @hideWidget.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar {name}'**
  String hideWidget(String name);

  /// No description provided for @showWidget.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar {name}'**
  String showWidget(String name);

  /// No description provided for @indicatorsPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Período dos indicadores'**
  String get indicatorsPeriod;

  /// No description provided for @currentMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês atual'**
  String get currentMonth;

  /// No description provided for @next30days.
  ///
  /// In pt, this message translates to:
  /// **'Próximos 30 dias'**
  String get next30days;

  /// No description provided for @accountsConsidered.
  ///
  /// In pt, this message translates to:
  /// **'Contas consideradas'**
  String get accountsConsidered;

  /// No description provided for @availableSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Até {date} · modo {mode}'**
  String availableSubtitle(String date, String mode);

  /// No description provided for @estimateDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'É uma estimativa com o que você registrou. Não é saldo garantido.'**
  String get estimateDisclaimer;

  /// No description provided for @theMath.
  ///
  /// In pt, this message translates to:
  /// **'A conta'**
  String get theMath;

  /// No description provided for @equalsCanSpend.
  ///
  /// In pt, this message translates to:
  /// **'= Pode gastar'**
  String get equalsCanSpend;

  /// No description provided for @adjustments.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get adjustments;

  /// No description provided for @includePlannedIncome.
  ///
  /// In pt, this message translates to:
  /// **'Considerar receitas previstas'**
  String get includePlannedIncome;

  /// No description provided for @includePlannedIncomeHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ligado = modo otimista: conta com dinheiro que ainda não entrou.'**
  String get includePlannedIncomeHelp;

  /// No description provided for @horizon.
  ///
  /// In pt, this message translates to:
  /// **'Horizonte'**
  String get horizon;

  /// No description provided for @untilMonthEnd.
  ///
  /// In pt, this message translates to:
  /// **'Até o fim do mês'**
  String get untilMonthEnd;

  /// No description provided for @safetyCushion.
  ///
  /// In pt, this message translates to:
  /// **'Colchão de segurança'**
  String get safetyCushion;

  /// No description provided for @none.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum'**
  String get none;

  /// No description provided for @cushionHelp.
  ///
  /// In pt, this message translates to:
  /// **'Valor que você prefere nunca tocar; sai do \"pode gastar\".'**
  String get cushionHelp;

  /// No description provided for @rules.
  ///
  /// In pt, this message translates to:
  /// **'Regras'**
  String get rules;

  /// No description provided for @availabilityRules.
  ///
  /// In pt, this message translates to:
  /// **'Entram só contas marcadas para o cálculo e dinheiro já efetivado. Saem: contas previstas até o horizonte (inclusive atrasadas), faturas de cartão já fechadas e a fatura aberta, reservas guardadas dentro das contas e o colchão. Compras no cartão nunca contam duas vezes: a compra é despesa na data; o pagamento da fatura só move dinheiro.'**
  String get availabilityRules;

  /// No description provided for @previousMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês anterior'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In pt, this message translates to:
  /// **'Próximo mês'**
  String get nextMonth;

  /// No description provided for @inflow.
  ///
  /// In pt, this message translates to:
  /// **'Entradas'**
  String get inflow;

  /// No description provided for @outflow.
  ///
  /// In pt, this message translates to:
  /// **'Saídas'**
  String get outflow;

  /// No description provided for @result.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get result;

  /// No description provided for @searchTransactions.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por descrição, loja ou observação'**
  String get searchTransactions;

  /// No description provided for @filterAll.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get filterAll;

  /// No description provided for @filterCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão'**
  String get filterCard;

  /// No description provided for @filterTransfers.
  ///
  /// In pt, this message translates to:
  /// **'Transferências'**
  String get filterTransfers;

  /// No description provided for @filterPlanned.
  ///
  /// In pt, this message translates to:
  /// **'Previstos'**
  String get filterPlanned;

  /// No description provided for @paidPart.
  ///
  /// In pt, this message translates to:
  /// **'pago {value}'**
  String paidPart(String value);

  /// No description provided for @nothingFound.
  ///
  /// In pt, this message translates to:
  /// **'Nada encontrado'**
  String get nothingFound;

  /// No description provided for @tryAnotherWord.
  ///
  /// In pt, this message translates to:
  /// **'Tente outra palavra.'**
  String get tryAnotherWord;

  /// No description provided for @noTransactionMonth.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum lançamento neste mês'**
  String get noTransactionMonth;

  /// No description provided for @registerWithPlus.
  ///
  /// In pt, this message translates to:
  /// **'Registre uma despesa ou receita com o botão +.'**
  String get registerWithPlus;

  /// No description provided for @newTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Novo lançamento'**
  String get newTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Editar lançamento'**
  String get editTransaction;

  /// No description provided for @transaction.
  ///
  /// In pt, this message translates to:
  /// **'Lançamento'**
  String get transaction;

  /// No description provided for @amount.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get amount;

  /// No description provided for @description.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get description;

  /// No description provided for @descHintIncome.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Salário'**
  String get descHintIncome;

  /// No description provided for @descHintTransfer.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Para a poupança'**
  String get descHintTransfer;

  /// No description provided for @descHintExpense.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Mercado'**
  String get descHintExpense;

  /// No description provided for @category.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get category;

  /// No description provided for @card.
  ///
  /// In pt, this message translates to:
  /// **'Cartão'**
  String get card;

  /// No description provided for @registerCard.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar cartão'**
  String get registerCard;

  /// No description provided for @account.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get account;

  /// No description provided for @from.
  ///
  /// In pt, this message translates to:
  /// **'De'**
  String get from;

  /// No description provided for @to.
  ///
  /// In pt, this message translates to:
  /// **'Para'**
  String get to;

  /// No description provided for @registerAccount.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar conta'**
  String get registerAccount;

  /// No description provided for @dueDate.
  ///
  /// In pt, this message translates to:
  /// **'Vencimento'**
  String get dueDate;

  /// No description provided for @date.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get date;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get tomorrow;

  /// No description provided for @invalidDate.
  ///
  /// In pt, this message translates to:
  /// **'Data inválida (dd/mm/aaaa)'**
  String get invalidDate;

  /// No description provided for @notReceivedYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não recebi (previsto)'**
  String get notReceivedYet;

  /// No description provided for @notPaidYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não paguei (previsto)'**
  String get notPaidYet;

  /// No description provided for @plannedHelp.
  ///
  /// In pt, this message translates to:
  /// **'Lançamentos previstos entram em \'contas a pagar\' e no cálculo de \'pode gastar\'.'**
  String get plannedHelp;

  /// No description provided for @installments.
  ///
  /// In pt, this message translates to:
  /// **'Parcelas'**
  String get installments;

  /// No description provided for @cashPayment.
  ///
  /// In pt, this message translates to:
  /// **'À vista'**
  String get cashPayment;

  /// No description provided for @installmentsHelp.
  ///
  /// In pt, this message translates to:
  /// **'{n}x de {value} (centavos ajustados nas primeiras parcelas), uma por fatura.'**
  String installmentsHelp(int n, String value);

  /// No description provided for @moreOptions.
  ///
  /// In pt, this message translates to:
  /// **'Mais opções'**
  String get moreOptions;

  /// No description provided for @repeat.
  ///
  /// In pt, this message translates to:
  /// **'Repetir'**
  String get repeat;

  /// No description provided for @repeatHelp.
  ///
  /// In pt, this message translates to:
  /// **'Cria uma série; os próximos 3 meses ficam como previstos e novos são gerados automaticamente.'**
  String get repeatHelp;

  /// No description provided for @tags.
  ///
  /// In pt, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @merchant.
  ///
  /// In pt, this message translates to:
  /// **'Estabelecimento'**
  String get merchant;

  /// No description provided for @optional.
  ///
  /// In pt, this message translates to:
  /// **'Opcional'**
  String get optional;

  /// No description provided for @notes.
  ///
  /// In pt, this message translates to:
  /// **'Observações'**
  String get notes;

  /// No description provided for @attachmentsPlus.
  ///
  /// In pt, this message translates to:
  /// **'Anexos e comprovantes fazem parte do SerenaCash Plus.'**
  String get attachmentsPlus;

  /// No description provided for @attachmentsAfterSave.
  ///
  /// In pt, this message translates to:
  /// **'Anexos: adicione pelo detalhe do lançamento após salvar.'**
  String get attachmentsAfterSave;

  /// No description provided for @attachments.
  ///
  /// In pt, this message translates to:
  /// **'Anexos'**
  String get attachments;

  /// No description provided for @addAttachment.
  ///
  /// In pt, this message translates to:
  /// **'Anexar comprovante'**
  String get addAttachment;

  /// No description provided for @payment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get payment;

  /// No description provided for @markReceived.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como recebido'**
  String get markReceived;

  /// No description provided for @markPaid.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como pago'**
  String get markPaid;

  /// No description provided for @payPart.
  ///
  /// In pt, this message translates to:
  /// **'Pagar parte (restam {value})'**
  String payPart(String value);

  /// No description provided for @registerPartial.
  ///
  /// In pt, this message translates to:
  /// **'Registrar pagamento parcial'**
  String get registerPartial;

  /// No description provided for @deleteThisAndNext.
  ///
  /// In pt, this message translates to:
  /// **'Excluir este e os próximos'**
  String get deleteThisAndNext;

  /// No description provided for @deleteTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Excluir lançamento'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionQ.
  ///
  /// In pt, this message translates to:
  /// **'Excluir lançamento?'**
  String get deleteTransactionQ;

  /// No description provided for @deleteSeriesText.
  ///
  /// In pt, this message translates to:
  /// **'Os lançamentos desta série a partir desta data serão excluídos. Você pode desfazer em seguida.'**
  String get deleteSeriesText;

  /// No description provided for @deleteOneText.
  ///
  /// In pt, this message translates to:
  /// **'Você pode desfazer em seguida.'**
  String get deleteOneText;

  /// No description provided for @deletedOne.
  ///
  /// In pt, this message translates to:
  /// **'Lançamento excluído'**
  String get deletedOne;

  /// No description provided for @deletedMany.
  ///
  /// In pt, this message translates to:
  /// **'{n} lançamentos excluídos'**
  String deletedMany(int n);

  /// No description provided for @errAmount.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor maior que zero.'**
  String get errAmount;

  /// No description provided for @errCardFirst.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre um cartão antes de registrar uma compra no cartão.'**
  String get errCardFirst;

  /// No description provided for @errAccountFirst.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre uma conta antes de registrar.'**
  String get errAccountFirst;

  /// No description provided for @errTwoAccounts.
  ///
  /// In pt, this message translates to:
  /// **'Escolha duas contas diferentes.'**
  String get errTwoAccounts;

  /// No description provided for @errSave.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar.'**
  String get errSave;

  /// No description provided for @frequencyMonthly.
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get frequencyMonthly;

  /// No description provided for @frequencyWeekly.
  ///
  /// In pt, this message translates to:
  /// **'Semanal'**
  String get frequencyWeekly;

  /// No description provided for @frequencyBiweekly.
  ///
  /// In pt, this message translates to:
  /// **'Quinzenal'**
  String get frequencyBiweekly;

  /// No description provided for @frequencyYearly.
  ///
  /// In pt, this message translates to:
  /// **'Anual'**
  String get frequencyYearly;

  /// No description provided for @planTitle.
  ///
  /// In pt, this message translates to:
  /// **'Planejar'**
  String get planTitle;

  /// No description provided for @planSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Orçamentos, metas, cartões e empréstimos'**
  String get planSubtitle;

  /// No description provided for @noBudget.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum orçamento'**
  String get noBudget;

  /// No description provided for @noBudgetPlanText.
  ///
  /// In pt, this message translates to:
  /// **'Defina limites por categoria ou para o mês inteiro.'**
  String get noBudgetPlanText;

  /// No description provided for @goalsAndReserves.
  ///
  /// In pt, this message translates to:
  /// **'Metas e reservas'**
  String get goalsAndReserves;

  /// No description provided for @goalLine.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% · faltam {remaining}'**
  String goalLine(int percent, String remaining);

  /// No description provided for @perMonth.
  ///
  /// In pt, this message translates to:
  /// **' · {value}/mês'**
  String perMonth(String value);

  /// No description provided for @noGoalPlanText.
  ///
  /// In pt, this message translates to:
  /// **'Comece por uma reserva de emergência.'**
  String get noGoalPlanText;

  /// No description provided for @cards.
  ///
  /// In pt, this message translates to:
  /// **'Cartões'**
  String get cards;

  /// No description provided for @cardLine.
  ///
  /// In pt, this message translates to:
  /// **'fatura {state} · vence {date} · livre {free}'**
  String cardLine(String state, String date, String free);

  /// No description provided for @loansAndDebts.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimos e dívidas'**
  String get loansAndDebts;

  /// No description provided for @loanLine.
  ///
  /// In pt, this message translates to:
  /// **'próxima {date} · {value} · {paid}/{total} pagas'**
  String loanLine(String date, String value, int paid, int total);

  /// No description provided for @noLoanRegistered.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum empréstimo cadastrado.'**
  String get noLoanRegistered;

  /// No description provided for @balanceProjection.
  ///
  /// In pt, this message translates to:
  /// **'Projeção de saldo'**
  String get balanceProjection;

  /// No description provided for @projectionText.
  ///
  /// In pt, this message translates to:
  /// **'Veja como o saldo evolui com as contas e receitas previstas até o fim do mês.'**
  String get projectionText;

  /// No description provided for @moreTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get moreTitle;

  /// No description provided for @freePlan.
  ///
  /// In pt, this message translates to:
  /// **'Plano gratuito'**
  String get freePlan;

  /// No description provided for @groupMoney.
  ///
  /// In pt, this message translates to:
  /// **'Meu dinheiro'**
  String get groupMoney;

  /// No description provided for @accountsWallets.
  ///
  /// In pt, this message translates to:
  /// **'Contas e carteiras'**
  String get accountsWallets;

  /// No description provided for @accountsWalletsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Saldos, ajustes, arquivamento'**
  String get accountsWalletsDesc;

  /// No description provided for @categoriesTags.
  ///
  /// In pt, this message translates to:
  /// **'Categorias e tags'**
  String get categoriesTags;

  /// No description provided for @categoriesTagsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Organize seus lançamentos'**
  String get categoriesTagsDesc;

  /// No description provided for @financialCalendar.
  ///
  /// In pt, this message translates to:
  /// **'Calendário financeiro'**
  String get financialCalendar;

  /// No description provided for @financialCalendarDesc.
  ///
  /// In pt, this message translates to:
  /// **'Vencimentos e recebimentos'**
  String get financialCalendarDesc;

  /// No description provided for @billsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Previstas, atrasadas, parciais'**
  String get billsDesc;

  /// No description provided for @groupAnalysis.
  ///
  /// In pt, this message translates to:
  /// **'Análises'**
  String get groupAnalysis;

  /// No description provided for @reports.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios'**
  String get reports;

  /// No description provided for @reportsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo de caixa, categorias, comparativos, projeções'**
  String get reportsDesc;

  /// No description provided for @financialAssistant.
  ///
  /// In pt, this message translates to:
  /// **'Assistente financeiro'**
  String get financialAssistant;

  /// No description provided for @financialAssistantDesc.
  ///
  /// In pt, this message translates to:
  /// **'Pergunte sobre o seu dinheiro'**
  String get financialAssistantDesc;

  /// No description provided for @groupData.
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get groupData;

  /// No description provided for @importData.
  ///
  /// In pt, this message translates to:
  /// **'Importar CSV ou OFX'**
  String get importData;

  /// No description provided for @importDesc.
  ///
  /// In pt, this message translates to:
  /// **'Com revisão e sem duplicidades'**
  String get importDesc;

  /// No description provided for @exportBackup.
  ///
  /// In pt, this message translates to:
  /// **'Exportar e backup'**
  String get exportBackup;

  /// No description provided for @exportDesc.
  ///
  /// In pt, this message translates to:
  /// **'CSV, PDF e backup completo'**
  String get exportDesc;

  /// No description provided for @groupAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get groupAccount;

  /// No description provided for @plusTitle.
  ///
  /// In pt, this message translates to:
  /// **'SerenaCash Plus'**
  String get plusTitle;

  /// No description provided for @plusDesc.
  ///
  /// In pt, this message translates to:
  /// **'Planos, assinatura e restauração'**
  String get plusDesc;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @settingsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Tema, moeda, privacidade, biometria'**
  String get settingsDesc;

  /// No description provided for @privacyData.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e dados'**
  String get privacyData;

  /// No description provided for @privacyDataDesc.
  ///
  /// In pt, this message translates to:
  /// **'Exportar ou apagar tudo'**
  String get privacyDataDesc;

  /// No description provided for @help.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get help;

  /// No description provided for @helpDesc.
  ///
  /// In pt, this message translates to:
  /// **'Como o app calcula as coisas'**
  String get helpDesc;

  /// No description provided for @footerLocal.
  ///
  /// In pt, this message translates to:
  /// **'SerenaCash · dados guardados neste aparelho · versão {version}'**
  String footerLocal(String version);

  /// No description provided for @shoppingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compras'**
  String get shoppingTitle;

  /// No description provided for @shoppingSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Listas e assistente de supermercado'**
  String get shoppingSubtitle;

  /// No description provided for @shoppingInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Compra em andamento'**
  String get shoppingInProgress;

  /// No description provided for @sessionLine.
  ///
  /// In pt, this message translates to:
  /// **'{n} item(ns) · {total}'**
  String sessionLine(int n, String total);

  /// No description provided for @shoppingIntro.
  ///
  /// In pt, this message translates to:
  /// **'Leia etiquetas de preço e códigos de barras, veja o total e quanto ainda cabe no orçamento antes do caixa.'**
  String get shoppingIntro;

  /// No description provided for @lists.
  ///
  /// In pt, this message translates to:
  /// **'Listas'**
  String get lists;

  /// No description provided for @itemsCount.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 item} other{{n} itens}}'**
  String itemsCount(int n);

  /// No description provided for @estimated.
  ///
  /// In pt, this message translates to:
  /// **'estimado {value}'**
  String estimated(String value);

  /// No description provided for @noPricesYet.
  ///
  /// In pt, this message translates to:
  /// **'sem preços ainda'**
  String get noPricesYet;

  /// No description provided for @withoutPrice.
  ///
  /// In pt, this message translates to:
  /// **' ({n} sem preço)'**
  String withoutPrice(int n);

  /// No description provided for @noList.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma lista'**
  String get noList;

  /// No description provided for @noListText.
  ///
  /// In pt, this message translates to:
  /// **'Crie a lista em casa e use no mercado, mesmo sem internet.'**
  String get noListText;

  /// No description provided for @previousPurchases.
  ///
  /// In pt, this message translates to:
  /// **'Compras anteriores'**
  String get previousPurchases;

  /// No description provided for @supermarket.
  ///
  /// In pt, this message translates to:
  /// **'Supermercado'**
  String get supermarket;

  /// No description provided for @registered.
  ///
  /// In pt, this message translates to:
  /// **'lançado'**
  String get registered;

  /// No description provided for @previousPurchasesText.
  ///
  /// In pt, this message translates to:
  /// **'As compras finalizadas aparecem aqui, com histórico de preços por loja.'**
  String get previousPurchasesText;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @privacyModeHelp.
  ///
  /// In pt, this message translates to:
  /// **'Mostra R\$ •••• em todas as telas até você desligar.'**
  String get privacyModeHelp;

  /// No description provided for @haptics.
  ///
  /// In pt, this message translates to:
  /// **'Vibração ao confirmar'**
  String get haptics;

  /// No description provided for @money.
  ///
  /// In pt, this message translates to:
  /// **'Dinheiro'**
  String get money;

  /// No description provided for @currency.
  ///
  /// In pt, this message translates to:
  /// **'Moeda'**
  String get currency;

  /// No description provided for @currencyHelp.
  ///
  /// In pt, this message translates to:
  /// **'A moeda vale para novos lançamentos. Formato e idioma seguem o aparelho (pt-BR por padrão).'**
  String get currencyHelp;

  /// No description provided for @availabilityHorizon.
  ///
  /// In pt, this message translates to:
  /// **'Horizonte do \"pode gastar\"'**
  String get availabilityHorizon;

  /// No description provided for @monthEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim do mês'**
  String get monthEnd;

  /// No description provided for @days30.
  ///
  /// In pt, this message translates to:
  /// **'30 dias'**
  String get days30;

  /// No description provided for @security.
  ///
  /// In pt, this message translates to:
  /// **'Segurança'**
  String get security;

  /// No description provided for @biometricLock.
  ///
  /// In pt, this message translates to:
  /// **'Pedir confirmação do aparelho ao abrir'**
  String get biometricLock;

  /// No description provided for @biometricAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Impressão digital, rosto ou bloqueio de tela do aparelho.'**
  String get biometricAvailable;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma biometria cadastrada; a confirmação usa o bloqueio de tela do aparelho.'**
  String get biometricNotAvailable;

  /// No description provided for @pinLock.
  ///
  /// In pt, this message translates to:
  /// **'Proteger com PIN'**
  String get pinLock;

  /// No description provided for @pinLockHelp.
  ///
  /// In pt, this message translates to:
  /// **'PIN de 4 a 8 dígitos, guardado de forma protegida; nunca sai do aparelho.'**
  String get pinLockHelp;

  /// No description provided for @setPin.
  ///
  /// In pt, this message translates to:
  /// **'Definir PIN'**
  String get setPin;

  /// No description provided for @changePin.
  ///
  /// In pt, this message translates to:
  /// **'Trocar PIN'**
  String get changePin;

  /// No description provided for @confirmPin.
  ///
  /// In pt, this message translates to:
  /// **'Confirme o PIN'**
  String get confirmPin;

  /// No description provided for @pinMismatch.
  ///
  /// In pt, this message translates to:
  /// **'Os PINs não conferem.'**
  String get pinMismatch;

  /// No description provided for @pinFormat.
  ///
  /// In pt, this message translates to:
  /// **'Use de 4 a 8 dígitos.'**
  String get pinFormat;

  /// No description provided for @lockOnBackground.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear ao voltar do segundo plano'**
  String get lockOnBackground;

  /// No description provided for @dataLocalHelp.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados ficam só neste aparelho. Faça backups no menu, em Exportar e backup.'**
  String get dataLocalHelp;

  /// No description provided for @reminders.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes'**
  String get reminders;

  /// No description provided for @remindersText.
  ///
  /// In pt, this message translates to:
  /// **'Aviso local no dia anterior e no dia do vencimento das contas previstas (próximos 7 dias). Nada sai do aparelho.'**
  String get remindersText;

  /// No description provided for @enableReminders.
  ///
  /// In pt, this message translates to:
  /// **'Ativar lembretes de vencimento'**
  String get enableReminders;

  /// No description provided for @remindersEnabled.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes ativados.'**
  String get remindersEnabled;

  /// No description provided for @remindersDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permissão de notificação negada ou indisponível.'**
  String get remindersDenied;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Do aparelho'**
  String get languageSystem;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Saiba quanto você pode gastar.'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeText.
  ///
  /// In pt, this message translates to:
  /// **'Em menos de dois minutos você vai saber quanto pode gastar sem comprometer suas contas. Sem cadastro, sem senha de banco: tudo fica no seu aparelho.'**
  String get onbWelcomeText;

  /// No description provided for @onbStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get onbStart;

  /// No description provided for @onbAccountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quanto você tem agora?'**
  String get onbAccountTitle;

  /// No description provided for @onbAccountText.
  ///
  /// In pt, this message translates to:
  /// **'Pode ser aproximado. Você ajusta depois.'**
  String get onbAccountText;

  /// No description provided for @accountName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da conta'**
  String get accountName;

  /// No description provided for @mainAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta principal'**
  String get mainAccount;

  /// No description provided for @typeBank.
  ///
  /// In pt, this message translates to:
  /// **'Banco'**
  String get typeBank;

  /// No description provided for @typeDigital.
  ///
  /// In pt, this message translates to:
  /// **'Digital'**
  String get typeDigital;

  /// No description provided for @typeCash.
  ///
  /// In pt, this message translates to:
  /// **'Dinheiro'**
  String get typeCash;

  /// No description provided for @typeSavings.
  ///
  /// In pt, this message translates to:
  /// **'Poupança'**
  String get typeSavings;

  /// No description provided for @balanceToday.
  ///
  /// In pt, this message translates to:
  /// **'Saldo hoje'**
  String get balanceToday;

  /// No description provided for @onbBillsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contas fixas deste mês'**
  String get onbBillsTitle;

  /// No description provided for @onbBillsText.
  ///
  /// In pt, this message translates to:
  /// **'Toque nas que você paga e informe o valor. Elas viram previstas e se repetem todo mês.'**
  String get onbBillsText;

  /// No description provided for @fixedRent.
  ///
  /// In pt, this message translates to:
  /// **'Aluguel'**
  String get fixedRent;

  /// No description provided for @fixedPower.
  ///
  /// In pt, this message translates to:
  /// **'Luz'**
  String get fixedPower;

  /// No description provided for @fixedInternet.
  ///
  /// In pt, this message translates to:
  /// **'Internet'**
  String get fixedInternet;

  /// No description provided for @fixedPhone.
  ///
  /// In pt, this message translates to:
  /// **'Celular'**
  String get fixedPhone;

  /// No description provided for @fixedWater.
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get fixedWater;

  /// No description provided for @onbCardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você usa cartão de crédito?'**
  String get onbCardTitle;

  /// No description provided for @onbCardText.
  ///
  /// In pt, this message translates to:
  /// **'Com fechamento e vencimento o app mostra a fatura certa e nunca conta a compra duas vezes.'**
  String get onbCardText;

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @limit.
  ///
  /// In pt, this message translates to:
  /// **'Limite'**
  String get limit;

  /// No description provided for @closingDay.
  ///
  /// In pt, this message translates to:
  /// **'Dia do fechamento'**
  String get closingDay;

  /// No description provided for @dueDay.
  ///
  /// In pt, this message translates to:
  /// **'Dia do vencimento'**
  String get dueDay;

  /// No description provided for @continue_.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continue_;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get finish;

  /// No description provided for @undoToastHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque para desfazer'**
  String get undoToastHint;

  /// No description provided for @accountsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contas e carteiras'**
  String get accountsTitle;

  /// No description provided for @consolidatedBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo consolidado'**
  String get consolidatedBalance;

  /// No description provided for @transfersDontChange.
  ///
  /// In pt, this message translates to:
  /// **'Transferências entre contas não alteram o total.'**
  String get transfersDontChange;

  /// No description provided for @active.
  ///
  /// In pt, this message translates to:
  /// **'Ativas'**
  String get active;

  /// No description provided for @archivedF.
  ///
  /// In pt, this message translates to:
  /// **'Arquivadas'**
  String get archivedF;

  /// No description provided for @typeCashL.
  ///
  /// In pt, this message translates to:
  /// **'Dinheiro'**
  String get typeCashL;

  /// No description provided for @typeCheckingL.
  ///
  /// In pt, this message translates to:
  /// **'Conta bancária'**
  String get typeCheckingL;

  /// No description provided for @typeSavingsL.
  ///
  /// In pt, this message translates to:
  /// **'Poupança'**
  String get typeSavingsL;

  /// No description provided for @typeDigitalL.
  ///
  /// In pt, this message translates to:
  /// **'Carteira digital'**
  String get typeDigitalL;

  /// No description provided for @typeInvestmentL.
  ///
  /// In pt, this message translates to:
  /// **'Investimento'**
  String get typeInvestmentL;

  /// No description provided for @typeOtherL.
  ///
  /// In pt, this message translates to:
  /// **'Outra'**
  String get typeOtherL;

  /// No description provided for @outOfAvailability.
  ///
  /// In pt, this message translates to:
  /// **' · fora do pode gastar'**
  String get outOfAvailability;

  /// No description provided for @accountNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Conta não encontrada'**
  String get accountNotFound;

  /// No description provided for @currentBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo atual'**
  String get currentBalance;

  /// No description provided for @openingBalanceLine.
  ///
  /// In pt, this message translates to:
  /// **'Saldo inicial {value} em {date}'**
  String openingBalanceLine(String value, String date);

  /// No description provided for @archivedSuffix.
  ///
  /// In pt, this message translates to:
  /// **' · arquivada'**
  String get archivedSuffix;

  /// No description provided for @history.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get history;

  /// No description provided for @noMovements.
  ///
  /// In pt, this message translates to:
  /// **'Sem movimentações'**
  String get noMovements;

  /// No description provided for @reactivateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Reativar conta'**
  String get reactivateAccount;

  /// No description provided for @archiveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar conta'**
  String get archiveAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get deleteAccount;

  /// No description provided for @archiveAccountQ.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar conta?'**
  String get archiveAccountQ;

  /// No description provided for @archiveAccountText.
  ///
  /// In pt, this message translates to:
  /// **'Ela some das listas e do \'pode gastar\', mas o histórico continua. Você pode reativar depois.'**
  String get archiveAccountText;

  /// No description provided for @archive.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar'**
  String get archive;

  /// No description provided for @deleteAccountQ.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta?'**
  String get deleteAccountQ;

  /// No description provided for @deleteAccountText.
  ///
  /// In pt, this message translates to:
  /// **'Só é possível excluir contas sem lançamentos. Se houver movimentações, arquive.'**
  String get deleteAccountText;

  /// No description provided for @accountHasTransactions.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta tem lançamentos. Arquive-a ou mova os lançamentos antes de excluir.'**
  String get accountHasTransactions;

  /// No description provided for @editAccount.
  ///
  /// In pt, this message translates to:
  /// **'Editar conta'**
  String get editAccount;

  /// No description provided for @newAccount.
  ///
  /// In pt, this message translates to:
  /// **'Nova conta'**
  String get newAccount;

  /// No description provided for @accountNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Nubank, Carteira'**
  String get accountNameHint;

  /// No description provided for @type.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @openingBalanceOnDate.
  ///
  /// In pt, this message translates to:
  /// **'Saldo inicial (na data abaixo)'**
  String get openingBalanceOnDate;

  /// No description provided for @openingHelpEdit.
  ///
  /// In pt, this message translates to:
  /// **'Para corrigir o saldo de hoje, use o ajuste abaixo.'**
  String get openingHelpEdit;

  /// No description provided for @openingHelpNew.
  ///
  /// In pt, this message translates to:
  /// **'O saldo de hoje vira o saldo inicial da conta.'**
  String get openingHelpNew;

  /// No description provided for @openingDate.
  ///
  /// In pt, this message translates to:
  /// **'Data do saldo inicial'**
  String get openingDate;

  /// No description provided for @includeInAvailability.
  ///
  /// In pt, this message translates to:
  /// **'Considerar no \"pode gastar\"'**
  String get includeInAvailability;

  /// No description provided for @includeHelp.
  ///
  /// In pt, this message translates to:
  /// **'Desligue para reservas, investimentos ou contas que você não usa no dia a dia.'**
  String get includeHelp;

  /// No description provided for @color.
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get color;

  /// No description provided for @adjustBalance.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar saldo'**
  String get adjustBalance;

  /// No description provided for @adjustHelp.
  ///
  /// In pt, this message translates to:
  /// **'Saldo calculado hoje: {value}. Informe o saldo real e o app cria um ajuste com a diferença (conciliação).'**
  String adjustHelp(String value);

  /// No description provided for @realBalanceToday.
  ///
  /// In pt, this message translates to:
  /// **'Saldo real hoje'**
  String get realBalanceToday;

  /// No description provided for @registerAdjustment.
  ///
  /// In pt, this message translates to:
  /// **'Registrar ajuste'**
  String get registerAdjustment;

  /// No description provided for @balanceAdjustment.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste de saldo'**
  String get balanceAdjustment;

  /// No description provided for @nameAccountErr.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome à conta.'**
  String get nameAccountErr;

  /// No description provided for @freeLimitAccounts.
  ///
  /// In pt, this message translates to:
  /// **'Plano gratuito: até {n} contas. Contas ilimitadas no SerenaCash Plus.'**
  String freeLimitAccounts(int n);

  /// No description provided for @newCategory.
  ///
  /// In pt, this message translates to:
  /// **'Nova categoria'**
  String get newCategory;

  /// No description provided for @categoryNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Delivery'**
  String get categoryNameHint;

  /// No description provided for @subcategoryOf.
  ///
  /// In pt, this message translates to:
  /// **'Subcategoria de (opcional)'**
  String get subcategoryOf;

  /// No description provided for @expenseCategories.
  ///
  /// In pt, this message translates to:
  /// **'Categorias de despesa'**
  String get expenseCategories;

  /// No description provided for @incomeCategories.
  ///
  /// In pt, this message translates to:
  /// **'Categorias de receita'**
  String get incomeCategories;

  /// No description provided for @reactivate.
  ///
  /// In pt, this message translates to:
  /// **'Reativar'**
  String get reactivate;

  /// No description provided for @archivedLower.
  ///
  /// In pt, this message translates to:
  /// **'arquivada'**
  String get archivedLower;

  /// No description provided for @tagsHelp.
  ///
  /// In pt, this message translates to:
  /// **'Tags marcam lançamentos de forma transversal (ex.: viagem, reembolsável).'**
  String get tagsHelp;

  /// No description provided for @newTag.
  ///
  /// In pt, this message translates to:
  /// **'Nova tag'**
  String get newTag;

  /// No description provided for @tagHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: viagem'**
  String get tagHint;

  /// No description provided for @creditCards.
  ///
  /// In pt, this message translates to:
  /// **'Cartões de crédito'**
  String get creditCards;

  /// No description provided for @closesDueDays.
  ///
  /// In pt, this message translates to:
  /// **'fecha dia {closing} · vence dia {due}'**
  String closesDueDays(int closing, int due);

  /// No description provided for @cardSummary.
  ///
  /// In pt, this message translates to:
  /// **'Fatura {month} ({state}) · limite livre {free} de {limit}'**
  String cardSummary(String month, String state, String free, String limit);

  /// No description provided for @noCardListText.
  ///
  /// In pt, this message translates to:
  /// **'Com fechamento e vencimento o app mostra a fatura certa.'**
  String get noCardListText;

  /// No description provided for @cardNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Cartão não encontrado'**
  String get cardNotFound;

  /// No description provided for @previousInvoice.
  ///
  /// In pt, this message translates to:
  /// **'Fatura anterior'**
  String get previousInvoice;

  /// No description provided for @nextInvoice.
  ///
  /// In pt, this message translates to:
  /// **'Próxima fatura'**
  String get nextInvoice;

  /// No description provided for @invoiceOf.
  ///
  /// In pt, this message translates to:
  /// **'Fatura {label}'**
  String invoiceOf(String label);

  /// No description provided for @invoiceState.
  ///
  /// In pt, this message translates to:
  /// **'Fatura {state}'**
  String invoiceState(String state);

  /// No description provided for @closesOn.
  ///
  /// In pt, this message translates to:
  /// **'fecha {date}'**
  String closesOn(String date);

  /// No description provided for @totalPaid.
  ///
  /// In pt, this message translates to:
  /// **'Total {total} · pago {paid}'**
  String totalPaid(String total, String paid);

  /// No description provided for @limitCommittedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Limite comprometido'**
  String get limitCommittedLabel;

  /// No description provided for @limitBreakdown.
  ///
  /// In pt, this message translates to:
  /// **'Limite livre {free} de {limit} (fatura atual {current} + fechadas {closed} + futuras {future})'**
  String limitBreakdown(
    String free,
    String limit,
    String current,
    String closed,
    String future,
  );

  /// No description provided for @purchasesThisInvoice.
  ///
  /// In pt, this message translates to:
  /// **'Compras desta fatura'**
  String get purchasesThisInvoice;

  /// No description provided for @newPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Nova compra'**
  String get newPurchase;

  /// No description provided for @purchase.
  ///
  /// In pt, this message translates to:
  /// **'Compra'**
  String get purchase;

  /// No description provided for @installmentOf.
  ///
  /// In pt, this message translates to:
  /// **' · parcela {n}/{of}'**
  String installmentOf(int n, int of);

  /// No description provided for @noPurchasesInvoice.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma compra nesta fatura.'**
  String get noPurchasesInvoice;

  /// No description provided for @payments.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos'**
  String get payments;

  /// No description provided for @payInvoice.
  ///
  /// In pt, this message translates to:
  /// **'Pagar fatura'**
  String get payInvoice;

  /// No description provided for @payInvoiceHelp.
  ///
  /// In pt, this message translates to:
  /// **'O pagamento sai da conta e abate a fatura. Não vira despesa de novo: as compras já contaram quando aconteceram.'**
  String get payInvoiceHelp;

  /// No description provided for @totalOf.
  ///
  /// In pt, this message translates to:
  /// **'Total {value}'**
  String totalOf(String value);

  /// No description provided for @minimum15.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo (15%)'**
  String get minimum15;

  /// No description provided for @paymentDate.
  ///
  /// In pt, this message translates to:
  /// **'Data do pagamento'**
  String get paymentDate;

  /// No description provided for @registerPayment.
  ///
  /// In pt, this message translates to:
  /// **'Registrar pagamento'**
  String get registerPayment;

  /// No description provided for @invoiceHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de faturas'**
  String get invoiceHistory;

  /// No description provided for @noInvoicesYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem faturas.'**
  String get noInvoicesYet;

  /// No description provided for @invoiceRule.
  ///
  /// In pt, this message translates to:
  /// **'Regra: compras até o dia {day} entram na fatura do mês; depois disso, na seguinte. Parcelas caem uma por fatura.'**
  String invoiceRule(int day);

  /// No description provided for @invoicePaymentDesc.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento fatura {label}'**
  String invoicePaymentDesc(String label);

  /// No description provided for @editCard.
  ///
  /// In pt, this message translates to:
  /// **'Editar cartão'**
  String get editCard;

  /// No description provided for @newCard.
  ///
  /// In pt, this message translates to:
  /// **'Novo cartão'**
  String get newCard;

  /// No description provided for @cardNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Cartão roxo'**
  String get cardNameHint;

  /// No description provided for @closingHelp.
  ///
  /// In pt, this message translates to:
  /// **'Compras depois desse dia vão para a próxima fatura.'**
  String get closingHelp;

  /// No description provided for @paymentAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta usada para pagar a fatura'**
  String get paymentAccount;

  /// No description provided for @nameCardErr.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome ao cartão.'**
  String get nameCardErr;

  /// No description provided for @daysRangeErr.
  ///
  /// In pt, this message translates to:
  /// **'Dias de fechamento e vencimento devem estar entre 1 e 31.'**
  String get daysRangeErr;

  /// No description provided for @closingChangeErr.
  ///
  /// In pt, this message translates to:
  /// **'Não dá para mudar o fechamento de um cartão com compras: as faturas mudariam de mês. Crie outro cartão.'**
  String get closingChangeErr;

  /// No description provided for @freeLimitCards.
  ///
  /// In pt, this message translates to:
  /// **'Plano gratuito: {n} cartão. Cartões ilimitados no SerenaCash Plus.'**
  String freeLimitCards(int n);

  /// No description provided for @committedPerInvoice.
  ///
  /// In pt, this message translates to:
  /// **'Comprometido por fatura'**
  String get committedPerInvoice;

  /// No description provided for @installmentsCount.
  ///
  /// In pt, this message translates to:
  /// **'{n} parcela(s)'**
  String installmentsCount(int n);

  /// No description provided for @noFutureInstallments.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma parcela futura'**
  String get noFutureInstallments;

  /// No description provided for @perPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Por compra'**
  String get perPurchase;

  /// No description provided for @installmentPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Compra parcelada'**
  String get installmentPurchase;

  /// No description provided for @pastInvoicesRemaining.
  ///
  /// In pt, this message translates to:
  /// **'{paid}/{of} faturas passadas · restam {value}'**
  String pastInvoicesRemaining(int paid, int of, String value);

  /// No description provided for @noInstallmentPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma compra parcelada.'**
  String get noInstallmentPurchase;

  /// No description provided for @plannedSuffix.
  ///
  /// In pt, this message translates to:
  /// **' · {value} previstos'**
  String plannedSuffix(String value);

  /// No description provided for @paceUsed.
  ///
  /// In pt, this message translates to:
  /// **'{pace} · {used}% usado, {expected}% do mês'**
  String paceUsed(String pace, int used, int expected);

  /// No description provided for @noBudgetListText.
  ///
  /// In pt, this message translates to:
  /// **'Defina um limite para uma categoria ou para o mês inteiro. A marca de hoje mostra se o gasto acompanha o previsto para o dia.'**
  String get noBudgetListText;

  /// No description provided for @budgetRules.
  ///
  /// In pt, this message translates to:
  /// **'Dentro do previsto: gasto até a marca de hoje. Pouco acima: até 10 pontos além da marca. Acima do previsto: além disso ou acima do limite. Subcategorias somam no orçamento da categoria-mãe.'**
  String get budgetRules;

  /// No description provided for @editBudget.
  ///
  /// In pt, this message translates to:
  /// **'Editar orçamento'**
  String get editBudget;

  /// No description provided for @newBudget.
  ///
  /// In pt, this message translates to:
  /// **'Novo orçamento'**
  String get newBudget;

  /// No description provided for @forLabel.
  ///
  /// In pt, this message translates to:
  /// **'Para'**
  String get forLabel;

  /// No description provided for @wholeMonth.
  ///
  /// In pt, this message translates to:
  /// **'O mês inteiro'**
  String get wholeMonth;

  /// No description provided for @monthlyLimit.
  ///
  /// In pt, this message translates to:
  /// **'Limite mensal'**
  String get monthlyLimit;

  /// No description provided for @onlyThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Só para este mês'**
  String get onlyThisMonth;

  /// No description provided for @onlyThisMonthHelp.
  ///
  /// In pt, this message translates to:
  /// **'Desligado = vale todo mês até você mudar.'**
  String get onlyThisMonthHelp;

  /// No description provided for @limitErr.
  ///
  /// In pt, this message translates to:
  /// **'Informe o limite.'**
  String get limitErr;

  /// No description provided for @freeLimitBudgets.
  ///
  /// In pt, this message translates to:
  /// **'Plano gratuito: até {n} orçamentos. Ilimitados no SerenaCash Plus.'**
  String freeLimitBudgets(int n);

  /// No description provided for @deleteBudget.
  ///
  /// In pt, this message translates to:
  /// **'Excluir orçamento'**
  String get deleteBudget;

  /// No description provided for @deleteBudgetQ.
  ///
  /// In pt, this message translates to:
  /// **'Excluir orçamento?'**
  String get deleteBudgetQ;

  /// No description provided for @deleteBudgetText.
  ///
  /// In pt, this message translates to:
  /// **'Os lançamentos não são afetados.'**
  String get deleteBudgetText;

  /// No description provided for @goalKindSavings.
  ///
  /// In pt, this message translates to:
  /// **'Economia'**
  String get goalKindSavings;

  /// No description provided for @goalKindEmergency.
  ///
  /// In pt, this message translates to:
  /// **'Reserva de emergência'**
  String get goalKindEmergency;

  /// No description provided for @goalKindPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Compra'**
  String get goalKindPurchase;

  /// No description provided for @goalKindDebt.
  ///
  /// In pt, this message translates to:
  /// **'Quitar dívida'**
  String get goalKindDebt;

  /// No description provided for @goalKindOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get goalKindOther;

  /// No description provided for @protectedSuffix.
  ///
  /// In pt, this message translates to:
  /// **' · protegida'**
  String get protectedSuffix;

  /// No description provided for @untilDate.
  ///
  /// In pt, this message translates to:
  /// **' · até {date}'**
  String untilDate(String date);

  /// No description provided for @goalSummary.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% de {target} · faltam {remaining}'**
  String goalSummary(int percent, String target, String remaining);

  /// No description provided for @saveMonthly.
  ///
  /// In pt, this message translates to:
  /// **' · guarde {value}/mês ({months} meses)'**
  String saveMonthly(String value, int months);

  /// No description provided for @suggestionMonthly.
  ///
  /// In pt, this message translates to:
  /// **' · sugestão {value}/mês'**
  String suggestionMonthly(String value);

  /// No description provided for @deposit.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In pt, this message translates to:
  /// **'Resgatar'**
  String get withdraw;

  /// No description provided for @noGoalListText.
  ///
  /// In pt, this message translates to:
  /// **'Uma reserva de emergência com 3 meses de despesas é um ótimo primeiro objetivo.'**
  String get noGoalListText;

  /// No description provided for @goalNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Meta não encontrada'**
  String get goalNotFound;

  /// No description provided for @saved.
  ///
  /// In pt, this message translates to:
  /// **'Guardado'**
  String get saved;

  /// No description provided for @leavesAccount.
  ///
  /// In pt, this message translates to:
  /// **'Sai da conta'**
  String get leavesAccount;

  /// No description provided for @goesToAccount.
  ///
  /// In pt, this message translates to:
  /// **'Vai para a conta'**
  String get goesToAccount;

  /// No description provided for @movements.
  ///
  /// In pt, this message translates to:
  /// **'Movimentações'**
  String get movements;

  /// No description provided for @noMovementsYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma movimentação ainda.'**
  String get noMovementsYet;

  /// No description provided for @depositDesc.
  ///
  /// In pt, this message translates to:
  /// **'Guardado: {name}'**
  String depositDesc(String name);

  /// No description provided for @withdrawDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resgate: {name}'**
  String withdrawDesc(String name);

  /// No description provided for @editGoal.
  ///
  /// In pt, this message translates to:
  /// **'Editar meta'**
  String get editGoal;

  /// No description provided for @newGoal.
  ///
  /// In pt, this message translates to:
  /// **'Nova meta'**
  String get newGoal;

  /// No description provided for @goalNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Reserva de emergência'**
  String get goalNameHint;

  /// No description provided for @goalAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor da meta'**
  String get goalAmount;

  /// No description provided for @hasDeadline.
  ///
  /// In pt, this message translates to:
  /// **'Tem prazo'**
  String get hasDeadline;

  /// No description provided for @untilWhen.
  ///
  /// In pt, this message translates to:
  /// **'Até quando'**
  String get untilWhen;

  /// No description provided for @whereMoney.
  ///
  /// In pt, this message translates to:
  /// **'Onde o dinheiro fica'**
  String get whereMoney;

  /// No description provided for @outsideApp.
  ///
  /// In pt, this message translates to:
  /// **'Fora das contas do app'**
  String get outsideApp;

  /// No description provided for @whereMoneyHelp.
  ///
  /// In pt, this message translates to:
  /// **'Se ficar dentro de uma conta considerada no \"pode gastar\", o valor guardado é descontado de lá.'**
  String get whereMoneyHelp;

  /// No description provided for @protectFromAvail.
  ///
  /// In pt, this message translates to:
  /// **'Proteger do \"pode gastar\"'**
  String get protectFromAvail;

  /// No description provided for @protectHelp.
  ///
  /// In pt, this message translates to:
  /// **'O valor guardado nunca aparece como disponível.'**
  String get protectHelp;

  /// No description provided for @archiveGoal.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar meta'**
  String get archiveGoal;

  /// No description provided for @nameGoalErr.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome à meta.'**
  String get nameGoalErr;

  /// No description provided for @goalAmountErr.
  ///
  /// In pt, this message translates to:
  /// **'Informe o valor da meta.'**
  String get goalAmountErr;

  /// No description provided for @freeLimitGoals.
  ///
  /// In pt, this message translates to:
  /// **'Plano gratuito: até {n} metas. Ilimitadas no SerenaCash Plus.'**
  String freeLimitGoals(int n);

  /// No description provided for @loanLineList.
  ///
  /// In pt, this message translates to:
  /// **'{system} · {rate}% a.m. · {paid}/{total} pagas'**
  String loanLineList(String system, String rate, int paid, int total);

  /// No description provided for @overdueInstallments.
  ///
  /// In pt, this message translates to:
  /// **' · {n} atrasada(s)'**
  String overdueInstallments(int n);

  /// No description provided for @installmentsPaid.
  ///
  /// In pt, this message translates to:
  /// **'Parcelas pagas'**
  String get installmentsPaid;

  /// No description provided for @nextAndPayoff.
  ///
  /// In pt, this message translates to:
  /// **'Próxima: {value} em {date} · quitar hoje ≈ {payoff}'**
  String nextAndPayoff(String value, String date, String payoff);

  /// No description provided for @paidOffCap.
  ///
  /// In pt, this message translates to:
  /// **'Quitado'**
  String get paidOffCap;

  /// No description provided for @noLoanListText.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre financiamentos, crediário ou dívidas para ver saldo devedor, juros e simulação de quitação.'**
  String get noLoanListText;

  /// No description provided for @loanNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimo não encontrado'**
  String get loanNotFound;

  /// No description provided for @outstanding.
  ///
  /// In pt, this message translates to:
  /// **'Saldo devedor'**
  String get outstanding;

  /// No description provided for @paidSummary.
  ///
  /// In pt, this message translates to:
  /// **'{paid} de {total} parcelas pagas · {value} pagos'**
  String paidSummary(int paid, int total, String value);

  /// No description provided for @extraPaid.
  ///
  /// In pt, this message translates to:
  /// **' ({value} além das parcelas)'**
  String extraPaid(String value);

  /// No description provided for @payoffToday.
  ///
  /// In pt, this message translates to:
  /// **'Quitar hoje ≈ {value} (valor presente das parcelas restantes à taxa do contrato, sem tarifas)'**
  String payoffToday(String value);

  /// No description provided for @overdueInstallmentsMsg.
  ///
  /// In pt, this message translates to:
  /// **'{n} parcela(s) atrasada(s).'**
  String overdueInstallmentsMsg(int n);

  /// No description provided for @simulateExtra.
  ///
  /// In pt, this message translates to:
  /// **'Simular pagamento extra'**
  String get simulateExtra;

  /// No description provided for @extraAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor extra'**
  String get extraAmount;

  /// No description provided for @reduceTerm.
  ///
  /// In pt, this message translates to:
  /// **'Reduzir prazo'**
  String get reduceTerm;

  /// No description provided for @reduceInstallment.
  ///
  /// In pt, this message translates to:
  /// **'Reduzir parcela'**
  String get reduceInstallment;

  /// No description provided for @paysOffLoan.
  ///
  /// In pt, this message translates to:
  /// **'Quita o empréstimo.'**
  String get paysOffLoan;

  /// No description provided for @newTerm.
  ///
  /// In pt, this message translates to:
  /// **'Novo prazo: {n} parcelas de {value} (antes {before}).'**
  String newTerm(int n, String value, int before);

  /// No description provided for @newInstallment.
  ///
  /// In pt, this message translates to:
  /// **'Nova parcela: {value} por {n} meses.'**
  String newInstallment(String value, int n);

  /// No description provided for @registerExtra.
  ///
  /// In pt, this message translates to:
  /// **'Registrar pagamento extra'**
  String get registerExtra;

  /// No description provided for @amortization.
  ///
  /// In pt, this message translates to:
  /// **'Amortização: {name}'**
  String amortization(String name);

  /// No description provided for @table.
  ///
  /// In pt, this message translates to:
  /// **'Tabela'**
  String get table;

  /// No description provided for @editLoan.
  ///
  /// In pt, this message translates to:
  /// **'Editar empréstimo'**
  String get editLoan;

  /// No description provided for @newLoan.
  ///
  /// In pt, this message translates to:
  /// **'Novo empréstimo'**
  String get newLoan;

  /// No description provided for @loanNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Financiamento do carro'**
  String get loanNameHint;

  /// No description provided for @borrowed.
  ///
  /// In pt, this message translates to:
  /// **'Valor emprestado'**
  String get borrowed;

  /// No description provided for @monthlyRate.
  ///
  /// In pt, this message translates to:
  /// **'Juros (% ao mês)'**
  String get monthlyRate;

  /// No description provided for @system.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get system;

  /// No description provided for @priceSystem.
  ///
  /// In pt, this message translates to:
  /// **'Price (parcela fixa)'**
  String get priceSystem;

  /// No description provided for @sacSystem.
  ///
  /// In pt, this message translates to:
  /// **'SAC (decrescente)'**
  String get sacSystem;

  /// No description provided for @firstDue.
  ///
  /// In pt, this message translates to:
  /// **'Primeiro vencimento'**
  String get firstDue;

  /// No description provided for @monthlyFee.
  ///
  /// In pt, this message translates to:
  /// **'Tarifa/seguro mensal (opcional)'**
  String get monthlyFee;

  /// No description provided for @registerDisbursement.
  ///
  /// In pt, this message translates to:
  /// **'Registrar a entrada do dinheiro na conta'**
  String get registerDisbursement;

  /// No description provided for @registerDisbursementHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ligue se o valor caiu na conta hoje.'**
  String get registerDisbursementHelp;

  /// No description provided for @createInstallments.
  ///
  /// In pt, this message translates to:
  /// **'Criar as parcelas como contas previstas'**
  String get createInstallments;

  /// No description provided for @createInstallmentsHelp.
  ///
  /// In pt, this message translates to:
  /// **'Entram em \'contas a pagar\' e no \'pode gastar\' mês a mês.'**
  String get createInstallmentsHelp;

  /// No description provided for @preview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia'**
  String get preview;

  /// No description provided for @previewLine.
  ///
  /// In pt, this message translates to:
  /// **'{n} parcelas · primeira {first}'**
  String previewLine(int n, String first);

  /// No description provided for @lastInstallment.
  ///
  /// In pt, this message translates to:
  /// **' · última {value}'**
  String lastInstallment(String value);

  /// No description provided for @totalInterestCost.
  ///
  /// In pt, this message translates to:
  /// **'Juros totais {interest} · custo total {cost}'**
  String totalInterestCost(String interest, String cost);

  /// No description provided for @loanAssumptions.
  ///
  /// In pt, this message translates to:
  /// **'Hipóteses: taxa nominal mensal sobre o saldo devedor; arredondamento por parcela; IOF e seguros só se informados.'**
  String get loanAssumptions;

  /// No description provided for @loanFormErr.
  ///
  /// In pt, this message translates to:
  /// **'Preencha nome, valor, taxa (% ao mês) e prazo.'**
  String get loanFormErr;

  /// No description provided for @disbursementLabel.
  ///
  /// In pt, this message translates to:
  /// **'Entrada'**
  String get disbursementLabel;

  /// No description provided for @dayItems.
  ///
  /// In pt, this message translates to:
  /// **'{day}: {n} lançamento(s)'**
  String dayItems(String day, int n);

  /// No description provided for @nothingThisDay.
  ///
  /// In pt, this message translates to:
  /// **'Nada neste dia.'**
  String get nothingThisDay;

  /// No description provided for @dayTotal.
  ///
  /// In pt, this message translates to:
  /// **'Resultado do dia: {value}'**
  String dayTotal(String value);

  /// No description provided for @thisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get thisMonth;

  /// No description provided for @days90.
  ///
  /// In pt, this message translates to:
  /// **'90 dias'**
  String get days90;

  /// No description provided for @overdueTotal.
  ///
  /// In pt, this message translates to:
  /// **'Atrasadas · {value}'**
  String overdueTotal(String value);

  /// No description provided for @pay.
  ///
  /// In pt, this message translates to:
  /// **'Pagar'**
  String get pay;

  /// No description provided for @dueUntil.
  ///
  /// In pt, this message translates to:
  /// **'A vencer até {date} · {value}'**
  String dueUntil(String date, String value);

  /// No description provided for @alreadyPaid.
  ///
  /// In pt, this message translates to:
  /// **' · já pago {value}'**
  String alreadyPaid(String value);

  /// No description provided for @nothingDuePeriod.
  ///
  /// In pt, this message translates to:
  /// **'Nada a vencer no período'**
  String get nothingDuePeriod;

  /// No description provided for @billsHelp.
  ///
  /// In pt, this message translates to:
  /// **'\"Pagar\" marca como pago hoje na conta do lançamento. Para pagar parte, abra o lançamento.'**
  String get billsHelp;

  /// No description provided for @cashflowReport.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo de caixa'**
  String get cashflowReport;

  /// No description provided for @cashflowDesc.
  ///
  /// In pt, this message translates to:
  /// **'Receitas, despesas e saldo mês a mês; comparativo mensal e anual'**
  String get cashflowDesc;

  /// No description provided for @categoriesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Para onde o dinheiro foi, com filtros'**
  String get categoriesDesc;

  /// No description provided for @recurringReport.
  ///
  /// In pt, this message translates to:
  /// **'Gastos recorrentes'**
  String get recurringReport;

  /// No description provided for @recurringDesc.
  ///
  /// In pt, this message translates to:
  /// **'Assinaturas e contas que se repetem'**
  String get recurringDesc;

  /// No description provided for @projectionDesc.
  ///
  /// In pt, this message translates to:
  /// **'Como o saldo evolui com o que está previsto'**
  String get projectionDesc;

  /// No description provided for @indicatorsReport.
  ///
  /// In pt, this message translates to:
  /// **'Indicadores e patrimônio'**
  String get indicatorsReport;

  /// No description provided for @indicatorsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de poupança, comprometimento, patrimônio'**
  String get indicatorsDesc;

  /// No description provided for @exportHint.
  ///
  /// In pt, this message translates to:
  /// **'Exportação em CSV e PDF no menu, em Exportar e backup.'**
  String get exportHint;

  /// No description provided for @months6.
  ///
  /// In pt, this message translates to:
  /// **'6 meses'**
  String get months6;

  /// No description provided for @months12.
  ///
  /// In pt, this message translates to:
  /// **'12 meses'**
  String get months12;

  /// No description provided for @incomeVsExpenses.
  ///
  /// In pt, this message translates to:
  /// **'Receitas × despesas'**
  String get incomeVsExpenses;

  /// No description provided for @monthByMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês a mês'**
  String get monthByMonth;

  /// No description provided for @balanceShort.
  ///
  /// In pt, this message translates to:
  /// **'saldo {value}'**
  String balanceShort(String value);

  /// No description provided for @compareWithPrevious.
  ///
  /// In pt, this message translates to:
  /// **'Comparativo com o mês anterior'**
  String get compareWithPrevious;

  /// No description provided for @yearLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ano {year}'**
  String yearLabel(int year);

  /// No description provided for @bestWorst.
  ///
  /// In pt, this message translates to:
  /// **'Melhor mês: {best} · pior: {worst}'**
  String bestWorst(String best, String worst);

  /// No description provided for @groupSubcategories.
  ///
  /// In pt, this message translates to:
  /// **'Agrupar subcategorias'**
  String get groupSubcategories;

  /// No description provided for @includePlanned.
  ///
  /// In pt, this message translates to:
  /// **'Incluir previstos'**
  String get includePlanned;

  /// No description provided for @totalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Total {value}'**
  String totalLabel(String value);

  /// No description provided for @transactionsCount.
  ///
  /// In pt, this message translates to:
  /// **'{n} lançamento(s)'**
  String transactionsCount(int n);

  /// No description provided for @seeMonthTransactions.
  ///
  /// In pt, this message translates to:
  /// **'Ver lançamentos do mês'**
  String get seeMonthTransactions;

  /// No description provided for @plusFeature.
  ///
  /// In pt, this message translates to:
  /// **'Recurso do SerenaCash Plus'**
  String get plusFeature;

  /// No description provided for @indicatorsPlusText.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de poupança, comprometimento de renda e evolução do patrimônio nos últimos 12 meses.'**
  String get indicatorsPlusText;

  /// No description provided for @knowPlus.
  ///
  /// In pt, this message translates to:
  /// **'Conhecer o Plus'**
  String get knowPlus;

  /// No description provided for @thisMonthTitle.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get thisMonthTitle;

  /// No description provided for @savingRateHow.
  ///
  /// In pt, this message translates to:
  /// **'(receitas − despesas) ÷ receitas efetivadas do mês'**
  String get savingRateHow;

  /// No description provided for @commitmentHow.
  ///
  /// In pt, this message translates to:
  /// **'(saldo devedor dos cartões + próxima parcela de empréstimos) ÷ receitas do mês'**
  String get commitmentHow;

  /// No description provided for @netWorthHow.
  ///
  /// In pt, this message translates to:
  /// **'contas + reservas fora das contas − faturas em aberto − saldo devedor de empréstimos'**
  String get netWorthHow;

  /// No description provided for @netWorth12.
  ///
  /// In pt, this message translates to:
  /// **'Patrimônio nos últimos 12 meses'**
  String get netWorth12;

  /// No description provided for @assetsDebts.
  ///
  /// In pt, this message translates to:
  /// **'ativos {assets} · dívidas {debts}'**
  String assetsDebts(String assets, String debts);

  /// No description provided for @indicatorsMethod.
  ///
  /// In pt, this message translates to:
  /// **'Metodologia transparente, calculada só com o que você registrou. Não é avaliação de crédito nem diagnóstico financeiro.'**
  String get indicatorsMethod;

  /// No description provided for @days60.
  ///
  /// In pt, this message translates to:
  /// **'60 dias'**
  String get days60;

  /// No description provided for @onDate.
  ///
  /// In pt, this message translates to:
  /// **'Em {date}'**
  String onDate(String date);

  /// No description provided for @negativeWarning.
  ///
  /// In pt, this message translates to:
  /// **'Atenção: o saldo fica negativo ({value}) em {date}.'**
  String negativeWarning(String value, String date);

  /// No description provided for @minBalance.
  ///
  /// In pt, this message translates to:
  /// **'Menor saldo no período: {value} em {date}.'**
  String minBalance(String value, String date);

  /// No description provided for @balanceAfter.
  ///
  /// In pt, this message translates to:
  /// **'{date} · saldo após {value}'**
  String balanceAfter(String date, String value);

  /// No description provided for @nothingPlanned.
  ///
  /// In pt, this message translates to:
  /// **'Nada previsto no período. Cadastre contas e receitas previstas para projetar.'**
  String get nothingPlanned;

  /// No description provided for @projectionRules.
  ///
  /// In pt, this message translates to:
  /// **'Considera lançamentos previstos, parcelas de empréstimo e faturas de cartão até o vencimento. Faturas atrasadas entram hoje.'**
  String get projectionRules;

  /// No description provided for @perMonthLabel.
  ///
  /// In pt, this message translates to:
  /// **'Por mês'**
  String get perMonthLabel;

  /// No description provided for @recurringHelp.
  ///
  /// In pt, this message translates to:
  /// **'Séries cadastradas e gastos repetidos (mesma descrição e valor em 3+ meses dos últimos 6).'**
  String get recurringHelp;

  /// No description provided for @recurringLine.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 mês} other{{n} meses}} · {kind}'**
  String recurringLine(int n, String kind);

  /// No description provided for @series.
  ///
  /// In pt, this message translates to:
  /// **'série'**
  String get series;

  /// No description provided for @detected.
  ///
  /// In pt, this message translates to:
  /// **'detectado'**
  String get detected;

  /// No description provided for @recurring.
  ///
  /// In pt, this message translates to:
  /// **'Recorrente'**
  String get recurring;

  /// No description provided for @nothingRecurring.
  ///
  /// In pt, this message translates to:
  /// **'Nada recorrente detectado'**
  String get nothingRecurring;

  /// No description provided for @nothingRecurringText.
  ///
  /// In pt, this message translates to:
  /// **'Com 3 meses de histórico o app encontra assinaturas e contas repetidas.'**
  String get nothingRecurringText;

  /// No description provided for @recurringTip.
  ///
  /// In pt, this message translates to:
  /// **'Dica: revise assinaturas que você não usa; cada {month}/mês são {year}/ano.'**
  String recurringTip(String month, String year);

  /// No description provided for @assistantIntro.
  ///
  /// In pt, this message translates to:
  /// **'Respostas calculadas com os seus dados, no aparelho. Nenhuma pergunta sai do celular.'**
  String get assistantIntro;

  /// No description provided for @askHint.
  ///
  /// In pt, this message translates to:
  /// **'Pergunte: posso comprar algo de 300,00?'**
  String get askHint;

  /// No description provided for @ask.
  ///
  /// In pt, this message translates to:
  /// **'Perguntar'**
  String get ask;

  /// No description provided for @question.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta'**
  String get question;

  /// No description provided for @calculationBasis.
  ///
  /// In pt, this message translates to:
  /// **'Base do cálculo'**
  String get calculationBasis;

  /// No description provided for @suggestionsForYou.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões para você'**
  String get suggestionsForYou;

  /// No description provided for @allCalmNoSuggestion.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma sugestão agora.'**
  String get allCalmNoSuggestion;

  /// No description provided for @assistantRules.
  ///
  /// In pt, this message translates to:
  /// **'Regras transparentes: contas atrasadas, orçamentos acima do ritmo, cartão acima de 80% do limite, mês negativo, sobra ≥ 20% sem reserva, 3+ gastos recorrentes.'**
  String get assistantRules;

  /// No description provided for @q1.
  ///
  /// In pt, this message translates to:
  /// **'Quanto posso gastar?'**
  String get q1;

  /// No description provided for @q2.
  ///
  /// In pt, this message translates to:
  /// **'Quais contas vencem esta semana?'**
  String get q2;

  /// No description provided for @q3.
  ///
  /// In pt, this message translates to:
  /// **'Onde estou gastando mais?'**
  String get q3;

  /// No description provided for @q4.
  ///
  /// In pt, this message translates to:
  /// **'Quanto gastei com supermercado?'**
  String get q4;

  /// No description provided for @q5.
  ///
  /// In pt, this message translates to:
  /// **'Quanto falta para minha meta?'**
  String get q5;

  /// No description provided for @q6.
  ///
  /// In pt, this message translates to:
  /// **'Quanto tenho comprometido em parcelas?'**
  String get q6;

  /// No description provided for @q7.
  ///
  /// In pt, this message translates to:
  /// **'Como está o mês?'**
  String get q7;

  /// No description provided for @q8.
  ///
  /// In pt, this message translates to:
  /// **'Como organizar minhas contas?'**
  String get q8;

  /// No description provided for @importTitle.
  ///
  /// In pt, this message translates to:
  /// **'Importar'**
  String get importTitle;

  /// No description provided for @importIntroTitle.
  ///
  /// In pt, this message translates to:
  /// **'CSV, OFX ou backup'**
  String get importIntroTitle;

  /// No description provided for @importIntro.
  ///
  /// In pt, this message translates to:
  /// **'CSV do seu banco ou de outro app (data, descrição, valor, tipo); OFX de extrato bancário (Plus); ou um backup do SerenaCash / do app anterior. Você revisa tudo antes de confirmar e o app aponta possíveis duplicidades.'**
  String get importIntro;

  /// No description provided for @chooseFile.
  ///
  /// In pt, this message translates to:
  /// **'Escolher arquivo'**
  String get chooseFile;

  /// No description provided for @fileReadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler o arquivo.'**
  String get fileReadError;

  /// No description provided for @columnsOf.
  ///
  /// In pt, this message translates to:
  /// **'Colunas de {file}'**
  String columnsOf(String file);

  /// No description provided for @rowsCheck.
  ///
  /// In pt, this message translates to:
  /// **'{n} linhas. Confira as colunas:'**
  String rowsCheck(int n);

  /// No description provided for @columnN.
  ///
  /// In pt, this message translates to:
  /// **'Coluna {n}'**
  String columnN(int n);

  /// No description provided for @typeColumn.
  ///
  /// In pt, this message translates to:
  /// **'Tipo (receita/despesa)'**
  String get typeColumn;

  /// No description provided for @noTypeHelp.
  ///
  /// In pt, this message translates to:
  /// **'Sem coluna de tipo, valores negativos viram despesas e positivos, receitas.'**
  String get noTypeHelp;

  /// No description provided for @chooseDateAmount.
  ///
  /// In pt, this message translates to:
  /// **'Escolha as colunas de data e valor.'**
  String get chooseDateAmount;

  /// No description provided for @reviewTransactions.
  ///
  /// In pt, this message translates to:
  /// **'Revisar lançamentos'**
  String get reviewTransactions;

  /// No description provided for @restoreBackup.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar backup'**
  String get restoreBackup;

  /// No description provided for @backupPassphrase.
  ///
  /// In pt, this message translates to:
  /// **'Senha do backup'**
  String get backupPassphrase;

  /// No description provided for @warningsCount.
  ///
  /// In pt, this message translates to:
  /// **'{n} aviso(s): {text}'**
  String warningsCount(int n, String text);

  /// No description provided for @restoreReplaces.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar substitui TODOS os dados atuais deste aparelho.'**
  String get restoreReplaces;

  /// No description provided for @replaceWithBackup.
  ///
  /// In pt, this message translates to:
  /// **'Substituir meus dados por este backup'**
  String get replaceWithBackup;

  /// No description provided for @restoreQ.
  ///
  /// In pt, this message translates to:
  /// **'Substituir todos os dados?'**
  String get restoreQ;

  /// No description provided for @restoreText.
  ///
  /// In pt, this message translates to:
  /// **'Os dados atuais serão apagados e substituídos pelo backup. Exporte antes, se quiser guardar.'**
  String get restoreText;

  /// No description provided for @restore.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar'**
  String get restore;

  /// No description provided for @foundTransactions.
  ///
  /// In pt, this message translates to:
  /// **'{n} lançamentos encontrados'**
  String foundTransactions(int n);

  /// No description provided for @dupesInfo.
  ///
  /// In pt, this message translates to:
  /// **'{d} possível(is) duplicidade(s) e {e} com erro foram desmarcados. Toque para incluir ou excluir.'**
  String dupesInfo(int d, int e);

  /// No description provided for @targetAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta de destino'**
  String get targetAccount;

  /// No description provided for @categoriesByName.
  ///
  /// In pt, this message translates to:
  /// **'Usar categorias pelo nome'**
  String get categoriesByName;

  /// No description provided for @include.
  ///
  /// In pt, this message translates to:
  /// **'Incluir'**
  String get include;

  /// No description provided for @alreadyImported.
  ///
  /// In pt, this message translates to:
  /// **'já importado'**
  String get alreadyImported;

  /// No description provided for @sameAsExisting.
  ///
  /// In pt, this message translates to:
  /// **'igual a um lançamento existente'**
  String get sameAsExisting;

  /// No description provided for @similarToExisting.
  ///
  /// In pt, this message translates to:
  /// **'parecido com um lançamento existente'**
  String get similarToExisting;

  /// No description provided for @importN.
  ///
  /// In pt, this message translates to:
  /// **'Importar {n}'**
  String importN(int n);

  /// No description provided for @chooseTargetAccount.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a conta de destino.'**
  String get chooseTargetAccount;

  /// No description provided for @importResult.
  ///
  /// In pt, this message translates to:
  /// **'{n} lançamento(s) importado(s); {skipped} ignorado(s).'**
  String importResult(int n, int skipped);

  /// No description provided for @importDone.
  ///
  /// In pt, this message translates to:
  /// **'Importação concluída'**
  String get importDone;

  /// No description provided for @restored.
  ///
  /// In pt, this message translates to:
  /// **'Backup restaurado.'**
  String get restored;

  /// No description provided for @backToStart.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get backToStart;

  /// No description provided for @exportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exportar e backup'**
  String get exportTitle;

  /// No description provided for @allScope.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get allScope;

  /// No description provided for @csvSheet.
  ///
  /// In pt, this message translates to:
  /// **'CSV (planilha)'**
  String get csvSheet;

  /// No description provided for @pdfReport.
  ///
  /// In pt, this message translates to:
  /// **'PDF (relatório)'**
  String get pdfReport;

  /// No description provided for @fullBackup.
  ///
  /// In pt, this message translates to:
  /// **'Backup completo'**
  String get fullBackup;

  /// No description provided for @backupHelp.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo com tudo (contas, lançamentos, cartões, orçamentos, metas, empréstimos, preferências, anexos). Guarde em local seguro; restaure em Importar.'**
  String get backupHelp;

  /// No description provided for @encryptedBackup.
  ///
  /// In pt, this message translates to:
  /// **'Backup cifrado (recomendado)'**
  String get encryptedBackup;

  /// No description provided for @plainBackup.
  ///
  /// In pt, this message translates to:
  /// **'Backup em claro (compatível com o app anterior)'**
  String get plainBackup;

  /// No description provided for @plainWarning.
  ///
  /// In pt, this message translates to:
  /// **'Sem senha: qualquer pessoa com o arquivo lê seus dados.'**
  String get plainWarning;

  /// No description provided for @passphraseMin.
  ///
  /// In pt, this message translates to:
  /// **'Senha com ao menos 8 caracteres'**
  String get passphraseMin;

  /// No description provided for @fileGenerated.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo gerado.'**
  String get fileGenerated;

  /// No description provided for @exportFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao exportar.'**
  String get exportFailed;

  /// No description provided for @reportOf.
  ///
  /// In pt, this message translates to:
  /// **'Relatório de {month}'**
  String reportOf(String month);

  /// No description provided for @fullReport.
  ///
  /// In pt, this message translates to:
  /// **'Relatório completo'**
  String get fullReport;

  /// No description provided for @generatedOn.
  ///
  /// In pt, this message translates to:
  /// **'gerado em {date}'**
  String generatedOn(String date);

  /// No description provided for @byCategory.
  ///
  /// In pt, this message translates to:
  /// **'Por categoria'**
  String get byCategory;

  /// No description provided for @pdfFooter.
  ///
  /// In pt, this message translates to:
  /// **'Valores efetivados e previstos conforme registrados pelo usuário. Compras no cartão contam na data da compra; pagamentos de fatura não são despesas.'**
  String get pdfFooter;

  /// No description provided for @privacyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e dados'**
  String get privacyTitle;

  /// No description provided for @whatWeKeep.
  ///
  /// In pt, this message translates to:
  /// **'O que guardamos'**
  String get whatWeKeep;

  /// No description provided for @privacy1.
  ///
  /// In pt, this message translates to:
  /// **'Contas, lançamentos, cartões, orçamentos, metas, empréstimos, listas e compras: tudo fica neste aparelho, em um banco de dados local cifrado.'**
  String get privacy1;

  /// No description provided for @privacy2.
  ///
  /// In pt, this message translates to:
  /// **'Não pedimos e-mail, CPF nem senha de banco. Não há conexão bancária. Nenhum dado financeiro é enviado a servidores.'**
  String get privacy2;

  /// No description provided for @privacy3.
  ///
  /// In pt, this message translates to:
  /// **'Assinaturas são processadas pela Apple ou pelo Google; recebemos apenas a confirmação do direito de acesso, nunca dados de pagamento.'**
  String get privacy3;

  /// No description provided for @privacy4.
  ///
  /// In pt, this message translates to:
  /// **'A câmera é usada só para ler etiquetas e códigos durante a compra; as imagens não são guardadas.'**
  String get privacy4;

  /// No description provided for @yourRights.
  ///
  /// In pt, this message translates to:
  /// **'Seus direitos'**
  String get yourRights;

  /// No description provided for @exportAllData.
  ///
  /// In pt, this message translates to:
  /// **'Exportar todos os meus dados'**
  String get exportAllData;

  /// No description provided for @eraseAll.
  ///
  /// In pt, this message translates to:
  /// **'Apagar tudo deste aparelho'**
  String get eraseAll;

  /// No description provided for @eraseHelp.
  ///
  /// In pt, this message translates to:
  /// **'Apagar remove dados, preferências, chave do banco e cache de assinatura. Compras na loja podem ser restauradas depois.'**
  String get eraseHelp;

  /// No description provided for @privacyPolicyNote.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade completa e termos: serão publicados em serenacash.app/privacidade antes do lançamento nas lojas.'**
  String get privacyPolicyNote;

  /// No description provided for @eraseQ.
  ///
  /// In pt, this message translates to:
  /// **'Apagar tudo?'**
  String get eraseQ;

  /// No description provided for @eraseText.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não pode ser desfeita. Exporte um backup antes, se quiser guardar o histórico.'**
  String get eraseText;

  /// No description provided for @eraseConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Apagar definitivamente'**
  String get eraseConfirm;

  /// No description provided for @helpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get helpTitle;

  /// No description provided for @faq1q.
  ///
  /// In pt, this message translates to:
  /// **'O que é \"pode gastar\"?'**
  String get faq1q;

  /// No description provided for @faq1a.
  ///
  /// In pt, this message translates to:
  /// **'Dinheiro nas contas consideradas, menos contas previstas até o fim do período (inclusive atrasadas), menos faturas de cartão em aberto, menos reservas guardadas dentro das contas e o colchão que você definir. Receitas previstas só entram no modo otimista. É uma estimativa, não um saldo.'**
  String get faq1a;

  /// No description provided for @faq2q.
  ///
  /// In pt, this message translates to:
  /// **'Compra no cartão conta duas vezes?'**
  String get faq2q;

  /// No description provided for @faq2a.
  ///
  /// In pt, this message translates to:
  /// **'Não. A compra é despesa na data em que aconteceu (na categoria dela). Pagar a fatura só tira dinheiro da conta e abate a fatura.'**
  String get faq2a;

  /// No description provided for @faq3q.
  ///
  /// In pt, this message translates to:
  /// **'Como funciona a fatura?'**
  String get faq3q;

  /// No description provided for @faq3a.
  ///
  /// In pt, this message translates to:
  /// **'Compras até o dia de fechamento entram na fatura do mês; depois, na seguinte. Parcelas caem uma por fatura. O vencimento é o dia que você cadastrou.'**
  String get faq3a;

  /// No description provided for @faq4q.
  ///
  /// In pt, this message translates to:
  /// **'O que é a marca de hoje?'**
  String get faq4q;

  /// No description provided for @faq4a.
  ///
  /// In pt, this message translates to:
  /// **'Nas barras de orçamento, a marca mostra onde o gasto estaria hoje se fosse distribuído por igual nos dias do mês. Antes dela: dentro do previsto. Até 10 pontos depois: pouco acima. Além disso ou acima do limite: acima do previsto.'**
  String get faq4a;

  /// No description provided for @faq5q.
  ///
  /// In pt, this message translates to:
  /// **'Previsto × efetivado'**
  String get faq5q;

  /// No description provided for @faq5a.
  ///
  /// In pt, this message translates to:
  /// **'Previsto é o que ainda vai acontecer (conta a pagar, salário a receber). Efetivado já aconteceu e altera o saldo. Pagamento parcial fica como \"parcial\" até completar.'**
  String get faq5a;

  /// No description provided for @faq6q.
  ///
  /// In pt, this message translates to:
  /// **'Reservas e metas'**
  String get faq6q;

  /// No description provided for @faq6a.
  ///
  /// In pt, this message translates to:
  /// **'Guardar dinheiro numa meta tira o valor da conta de origem. Se a meta fica dentro de uma conta considerada, o valor guardado é descontado do \"pode gastar\" (quando protegida).'**
  String get faq6a;

  /// No description provided for @faq7q.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimos'**
  String get faq7q;

  /// No description provided for @faq7a.
  ///
  /// In pt, this message translates to:
  /// **'Tabela Price (parcela fixa) ou SAC (parcela decrescente), com taxa mensal sobre o saldo devedor. \"Quitar hoje\" é o valor presente das parcelas restantes à taxa do contrato, sem tarifas: uma estimativa para negociar.'**
  String get faq7a;

  /// No description provided for @faq8q.
  ///
  /// In pt, this message translates to:
  /// **'Supermercado'**
  String get faq8q;

  /// No description provided for @faq8a.
  ///
  /// In pt, this message translates to:
  /// **'Código de barras identifica o produto, não o preço. O preço vem da etiqueta lida (OCR), do seu histórico ou de você. Nada é adicionado sem confirmação, e o total do carrinho usa arredondamento de balança.'**
  String get faq8a;

  /// No description provided for @faq9q.
  ///
  /// In pt, this message translates to:
  /// **'Meus dados'**
  String get faq9q;

  /// No description provided for @faq9a.
  ///
  /// In pt, this message translates to:
  /// **'Tudo fica no aparelho, cifrado. Exporte backups no menu, em Exportar e backup. Apague tudo em Privacidade.'**
  String get faq9a;

  /// No description provided for @featurePartOfPlus.
  ///
  /// In pt, this message translates to:
  /// **'\"{feature}\" faz parte do Plus.'**
  String featurePartOfPlus(String feature);

  /// No description provided for @thanksSupport.
  ///
  /// In pt, this message translates to:
  /// **'Plano {plan}. Obrigado por apoiar o SerenaCash.'**
  String thanksSupport(String plan);

  /// No description provided for @whatChanges.
  ///
  /// In pt, this message translates to:
  /// **'O que muda'**
  String get whatChanges;

  /// No description provided for @limitsRow.
  ///
  /// In pt, this message translates to:
  /// **'Contas / cartões / orçamentos / metas'**
  String get limitsRow;

  /// No description provided for @unlimited.
  ///
  /// In pt, this message translates to:
  /// **'Ilimitados'**
  String get unlimited;

  /// No description provided for @ocrRow.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de etiquetas (OCR)'**
  String get ocrRow;

  /// No description provided for @perMonthN.
  ///
  /// In pt, this message translates to:
  /// **'{n}/mês'**
  String perMonthN(int n);

  /// No description provided for @unlimitedF.
  ///
  /// In pt, this message translates to:
  /// **'Ilimitada'**
  String get unlimitedF;

  /// No description provided for @reportsPdfRow.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios avançados e PDF'**
  String get reportsPdfRow;

  /// No description provided for @yes.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get yes;

  /// No description provided for @ofxAttachRow.
  ///
  /// In pt, this message translates to:
  /// **'Importação OFX e anexos'**
  String get ofxAttachRow;

  /// No description provided for @priceHistoryRow.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de preços por loja'**
  String get priceHistoryRow;

  /// No description provided for @syncRow.
  ///
  /// In pt, this message translates to:
  /// **'Sincronização entre aparelhos'**
  String get syncRow;

  /// No description provided for @syncWhen.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura (quando disponível)'**
  String get syncWhen;

  /// No description provided for @essentialFree.
  ///
  /// In pt, this message translates to:
  /// **'O essencial (contas, lançamentos, 1 cartão, orçamentos, metas, listas e carrinho) é gratuito para sempre.'**
  String get essentialFree;

  /// No description provided for @recommended.
  ///
  /// In pt, this message translates to:
  /// **'recomendado'**
  String get recommended;

  /// No description provided for @lifetimeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento único. Inclui tudo o que funciona no aparelho, para sempre. Não inclui serviços com custo recorrente (sincronização).'**
  String get lifetimeDesc;

  /// No description provided for @yearlyDesc.
  ///
  /// In pt, this message translates to:
  /// **'Cobrado uma vez por ano. Cancele quando quiser na loja.'**
  String get yearlyDesc;

  /// No description provided for @monthlyDesc.
  ///
  /// In pt, this message translates to:
  /// **'Cobrado mensalmente. Cancele quando quiser na loja.'**
  String get monthlyDesc;

  /// No description provided for @planCoverage.
  ///
  /// In pt, this message translates to:
  /// **'Abrangência do plano'**
  String get planCoverage;

  /// No description provided for @perYear.
  ///
  /// In pt, this message translates to:
  /// **' / ano'**
  String get perYear;

  /// No description provided for @perMonthShort.
  ///
  /// In pt, this message translates to:
  /// **' / mês'**
  String get perMonthShort;

  /// No description provided for @loadingPrice.
  ///
  /// In pt, this message translates to:
  /// **'Carregando preço da loja…'**
  String get loadingPrice;

  /// No description provided for @priceInStore.
  ///
  /// In pt, this message translates to:
  /// **'Preço e compra disponíveis na versão publicada nas lojas.'**
  String get priceInStore;

  /// No description provided for @restorePurchases.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compras'**
  String get restorePurchases;

  /// No description provided for @manageSubscription.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar assinatura na loja'**
  String get manageSubscription;

  /// No description provided for @thanksActive.
  ///
  /// In pt, this message translates to:
  /// **'Obrigado! Seu plano está ativo.'**
  String get thanksActive;

  /// No description provided for @purchaseFailed.
  ///
  /// In pt, this message translates to:
  /// **'Compra não concluída.'**
  String get purchaseFailed;

  /// No description provided for @purchasesRestored.
  ///
  /// In pt, this message translates to:
  /// **'Compras restauradas.'**
  String get purchasesRestored;

  /// No description provided for @noPurchasesFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma compra encontrada nesta conta da loja.'**
  String get noPurchasesFound;

  /// No description provided for @restoreFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível restaurar.'**
  String get restoreFailed;

  /// No description provided for @subscriptionTerms.
  ///
  /// In pt, this message translates to:
  /// **'Assinaturas renovam automaticamente até serem canceladas na App Store ou no Google Play. Reembolsos seguem as políticas das lojas. Termos e privacidade: Mais → Privacidade.'**
  String get subscriptionTerms;

  /// No description provided for @storeProcesses.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento processado pela loja; não vemos seus dados de pagamento.'**
  String get storeProcesses;

  /// No description provided for @plusFeaturesList.
  ///
  /// In pt, this message translates to:
  /// **'Recursos do Plus: {list}'**
  String plusFeaturesList(String list);

  /// No description provided for @stayFree.
  ///
  /// In pt, this message translates to:
  /// **'Continuar no gratuito'**
  String get stayFree;

  /// No description provided for @notFound.
  ///
  /// In pt, this message translates to:
  /// **'Não encontrado'**
  String get notFound;

  /// No description provided for @attachmentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Anexos e comprovantes'**
  String get attachmentsTitle;

  /// No description provided for @addPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get addPhoto;

  /// No description provided for @addFile.
  ///
  /// In pt, this message translates to:
  /// **'Escolher arquivo'**
  String get addFile;

  /// No description provided for @attachmentTooBig.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo acima de 10 MB.'**
  String get attachmentTooBig;

  /// No description provided for @removeAttachment.
  ///
  /// In pt, this message translates to:
  /// **'Remover anexo'**
  String get removeAttachment;

  /// No description provided for @attachmentCount.
  ///
  /// In pt, this message translates to:
  /// **'{n} anexo(s)'**
  String attachmentCount(int n);

  /// No description provided for @openAttachment.
  ///
  /// In pt, this message translates to:
  /// **'Abrir'**
  String get openAttachment;

  /// No description provided for @attachmentsPlusHint.
  ///
  /// In pt, this message translates to:
  /// **'Anexos fazem parte do SerenaCash Plus.'**
  String get attachmentsPlusHint;

  /// No description provided for @changeHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de alterações'**
  String get changeHistory;

  /// No description provided for @changeHistoryDesc.
  ///
  /// In pt, this message translates to:
  /// **'Registro de mudanças e estado de sincronização'**
  String get changeHistoryDesc;

  /// No description provided for @syncStatus.
  ///
  /// In pt, this message translates to:
  /// **'Sincronização'**
  String get syncStatus;

  /// No description provided for @syncLocalOnly.
  ///
  /// In pt, this message translates to:
  /// **'Somente neste aparelho. A sincronização entre aparelhos chega como serviço de assinatura; enquanto isso, todas as mudanças ficam registradas para envio futuro.'**
  String get syncLocalOnly;

  /// No description provided for @pendingChanges.
  ///
  /// In pt, this message translates to:
  /// **'{n} alteração(ões) registrada(s) e pendente(s) de envio'**
  String pendingChanges(int n);

  /// No description provided for @deviceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Aparelho {id}'**
  String deviceLabel(String id);

  /// No description provided for @recentChanges.
  ///
  /// In pt, this message translates to:
  /// **'Alterações recentes'**
  String get recentChanges;

  /// No description provided for @opUpsert.
  ///
  /// In pt, this message translates to:
  /// **'salvo'**
  String get opUpsert;

  /// No description provided for @opDelete.
  ///
  /// In pt, this message translates to:
  /// **'excluído'**
  String get opDelete;

  /// No description provided for @opRestore.
  ///
  /// In pt, this message translates to:
  /// **'restaurado'**
  String get opRestore;

  /// No description provided for @versionN.
  ///
  /// In pt, this message translates to:
  /// **'v{n}'**
  String versionN(int n);

  /// No description provided for @noChangesYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma alteração registrada ainda.'**
  String get noChangesYet;

  /// No description provided for @entityAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get entityAccount;

  /// No description provided for @entityCategory.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get entityCategory;

  /// No description provided for @entityTag.
  ///
  /// In pt, this message translates to:
  /// **'Tag'**
  String get entityTag;

  /// No description provided for @entityCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão'**
  String get entityCard;

  /// No description provided for @entityTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Lançamento'**
  String get entityTransaction;

  /// No description provided for @entityBudget.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento'**
  String get entityBudget;

  /// No description provided for @entityGoal.
  ///
  /// In pt, this message translates to:
  /// **'Meta'**
  String get entityGoal;

  /// No description provided for @entityLoan.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimo'**
  String get entityLoan;

  /// No description provided for @entityRecurrence.
  ///
  /// In pt, this message translates to:
  /// **'Recorrência'**
  String get entityRecurrence;

  /// No description provided for @entityPrefs.
  ///
  /// In pt, this message translates to:
  /// **'Preferências'**
  String get entityPrefs;

  /// No description provided for @entityList.
  ///
  /// In pt, this message translates to:
  /// **'Lista de compras'**
  String get entityList;

  /// No description provided for @entitySession.
  ///
  /// In pt, this message translates to:
  /// **'Compra'**
  String get entitySession;

  /// No description provided for @entityProduct.
  ///
  /// In pt, this message translates to:
  /// **'Produto'**
  String get entityProduct;

  /// No description provided for @entityObservation.
  ///
  /// In pt, this message translates to:
  /// **'Preço observado'**
  String get entityObservation;

  /// No description provided for @entityLedger.
  ///
  /// In pt, this message translates to:
  /// **'Restauração'**
  String get entityLedger;

  /// No description provided for @conflicts.
  ///
  /// In pt, this message translates to:
  /// **'Conflitos'**
  String get conflicts;

  /// No description provided for @noConflicts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum conflito. Campos monetários nunca são resolvidos automaticamente.'**
  String get noConflicts;

  /// No description provided for @annualPlanning.
  ///
  /// In pt, this message translates to:
  /// **'Planejamento anual'**
  String get annualPlanning;

  /// No description provided for @annualDesc.
  ///
  /// In pt, this message translates to:
  /// **'Visão do ano: resultado por mês, orçamento e metas'**
  String get annualDesc;

  /// No description provided for @previousYear.
  ///
  /// In pt, this message translates to:
  /// **'Ano anterior'**
  String get previousYear;

  /// No description provided for @nextYear.
  ///
  /// In pt, this message translates to:
  /// **'Próximo ano'**
  String get nextYear;

  /// No description provided for @yearResult.
  ///
  /// In pt, this message translates to:
  /// **'Resultado do ano'**
  String get yearResult;

  /// No description provided for @monthCol.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get monthCol;

  /// No description provided for @budgetCol.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento'**
  String get budgetCol;

  /// No description provided for @annualGoals.
  ///
  /// In pt, this message translates to:
  /// **'Metas até o fim do ano'**
  String get annualGoals;

  /// No description provided for @goalNeedPerMonth.
  ///
  /// In pt, this message translates to:
  /// **'{name}: faltam {remaining} · {value}/mês'**
  String goalNeedPerMonth(String name, String remaining, String value);

  /// No description provided for @annualBudgetNote.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento do mês = limite geral vigente no mês. Meses futuros mostram o previsto já registrado.'**
  String get annualBudgetNote;

  /// No description provided for @plannedShort.
  ///
  /// In pt, this message translates to:
  /// **'prev.'**
  String get plannedShort;

  /// No description provided for @newList.
  ///
  /// In pt, this message translates to:
  /// **'Nova lista'**
  String get newList;

  /// No description provided for @create.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get create;

  /// No description provided for @listNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Compra do mês'**
  String get listNameHint;

  /// No description provided for @storeOptional.
  ///
  /// In pt, this message translates to:
  /// **'Supermercado (opcional)'**
  String get storeOptional;

  /// No description provided for @storeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Mercado Bom'**
  String get storeHint;

  /// No description provided for @listBudgetLabel.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento para esta compra (opcional)'**
  String get listBudgetLabel;

  /// No description provided for @listBudgetHelp.
  ///
  /// In pt, this message translates to:
  /// **'No mercado, o carrinho mostra quanto ainda cabe.'**
  String get listBudgetHelp;

  /// No description provided for @freeLimitLists.
  ///
  /// In pt, this message translates to:
  /// **'Plano gratuito: até {n} listas.'**
  String freeLimitLists(int n);

  /// No description provided for @defaultListName.
  ///
  /// In pt, this message translates to:
  /// **'Compra do mês'**
  String get defaultListName;

  /// No description provided for @listNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Lista não encontrada'**
  String get listNotFound;

  /// No description provided for @buy.
  ///
  /// In pt, this message translates to:
  /// **'Comprar'**
  String get buy;

  /// No description provided for @estimateWithPrice.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa ({known} de {total} com preço)'**
  String estimateWithPrice(int known, int total);

  /// No description provided for @budget.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento'**
  String get budget;

  /// No description provided for @estimateVsBudget.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa contra o orçamento'**
  String get estimateVsBudget;

  /// No description provided for @checkedCount.
  ///
  /// In pt, this message translates to:
  /// **'{checked}/{total} marcados'**
  String checkedCount(int checked, int total);

  /// No description provided for @unpricedItems.
  ///
  /// In pt, this message translates to:
  /// **' · {n} item(ns) sem preço (não estimados)'**
  String unpricedItems(int n);

  /// No description provided for @addItem.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item'**
  String get addItem;

  /// No description provided for @itemNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Arroz 5kg'**
  String get itemNameHint;

  /// No description provided for @itemName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do item'**
  String get itemName;

  /// No description provided for @qty.
  ///
  /// In pt, this message translates to:
  /// **'Qtd'**
  String get qty;

  /// No description provided for @unit.
  ///
  /// In pt, this message translates to:
  /// **'Unidade'**
  String get unit;

  /// No description provided for @categoryAndPrice.
  ///
  /// In pt, this message translates to:
  /// **'Categoria e preço estimado'**
  String get categoryAndPrice;

  /// No description provided for @estimatedUnitPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço estimado por unidade (opcional)'**
  String get estimatedUnitPrice;

  /// No description provided for @estimatedPriceHelp.
  ///
  /// In pt, this message translates to:
  /// **'Sem preço, o item entra na lista mas não na estimativa. Se já comprou antes, o histórico preenche sozinho.'**
  String get estimatedPriceHelp;

  /// No description provided for @editItem.
  ///
  /// In pt, this message translates to:
  /// **'Editar {name}'**
  String editItem(String name);

  /// No description provided for @historySuffix.
  ///
  /// In pt, this message translates to:
  /// **' (histórico)'**
  String get historySuffix;

  /// No description provided for @noPrice.
  ///
  /// In pt, this message translates to:
  /// **' · sem preço'**
  String get noPrice;

  /// No description provided for @emptyList.
  ///
  /// In pt, this message translates to:
  /// **'Lista vazia'**
  String get emptyList;

  /// No description provided for @emptyListText.
  ///
  /// In pt, this message translates to:
  /// **'Adicione os itens acima. Unidades: un, kg, g, L, mL, pacote, dúzia, caixa.'**
  String get emptyListText;

  /// No description provided for @startWithList.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar compra com esta lista'**
  String get startWithList;

  /// No description provided for @uncheckAll.
  ///
  /// In pt, this message translates to:
  /// **'Desmarcar tudo'**
  String get uncheckAll;

  /// No description provided for @duplicate.
  ///
  /// In pt, this message translates to:
  /// **'Duplicar'**
  String get duplicate;

  /// No description provided for @deleteListQ.
  ///
  /// In pt, this message translates to:
  /// **'Excluir lista?'**
  String get deleteListQ;

  /// No description provided for @deleteListText.
  ///
  /// In pt, this message translates to:
  /// **'Os itens serão removidos. Compras finalizadas não são afetadas.'**
  String get deleteListText;

  /// No description provided for @editItemTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar item'**
  String get editItemTitle;

  /// No description provided for @removeItem.
  ///
  /// In pt, this message translates to:
  /// **'Remover item'**
  String get removeItem;

  /// No description provided for @newPurchase2.
  ///
  /// In pt, this message translates to:
  /// **'Nova compra'**
  String get newPurchase2;

  /// No description provided for @fromList.
  ///
  /// In pt, this message translates to:
  /// **'A partir da lista \"{name}\" ({n} itens).'**
  String fromList(String name, int n);

  /// No description provided for @noListSession.
  ///
  /// In pt, this message translates to:
  /// **'Sem lista: adicione itens pela câmera ou manualmente.'**
  String get noListSession;

  /// No description provided for @sessionBudgetLabel.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento desta compra (opcional)'**
  String get sessionBudgetLabel;

  /// No description provided for @sessionBudgetHelp.
  ///
  /// In pt, this message translates to:
  /// **'O carrinho mostra quanto ainda cabe.'**
  String get sessionBudgetHelp;

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get start;

  /// No description provided for @orChooseList.
  ///
  /// In pt, this message translates to:
  /// **'Ou escolha uma lista'**
  String get orChooseList;

  /// No description provided for @finishedOn.
  ///
  /// In pt, this message translates to:
  /// **'Finalizada em {date}'**
  String finishedOn(String date);

  /// No description provided for @itemsInCart.
  ///
  /// In pt, this message translates to:
  /// **'{n} item(ns) no carrinho'**
  String itemsInCart(int n);

  /// No description provided for @exit.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get exit;

  /// No description provided for @cartTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total do carrinho'**
  String get cartTotal;

  /// No description provided for @stillFits.
  ///
  /// In pt, this message translates to:
  /// **'Ainda cabe {remaining} de {budget}'**
  String stillFits(String remaining, String budget);

  /// No description provided for @overBudgetBy.
  ///
  /// In pt, this message translates to:
  /// **'{over} acima do orçamento de {budget}'**
  String overBudgetBy(String over, String budget);

  /// No description provided for @cartVsBudget.
  ///
  /// In pt, this message translates to:
  /// **'Carrinho contra o orçamento'**
  String get cartVsBudget;

  /// No description provided for @noBudgetSession.
  ///
  /// In pt, this message translates to:
  /// **'Sem orçamento definido para esta compra.'**
  String get noBudgetSession;

  /// No description provided for @lowConfidenceItems.
  ///
  /// In pt, this message translates to:
  /// **'{n} item(ns) com leitura de baixa confiança.'**
  String lowConfidenceItems(int n);

  /// No description provided for @discountLine.
  ///
  /// In pt, this message translates to:
  /// **' · desconto {value}'**
  String discountLine(String value);

  /// No description provided for @checkSuffix.
  ///
  /// In pt, this message translates to:
  /// **' · confira'**
  String get checkSuffix;

  /// No description provided for @removeLine.
  ///
  /// In pt, this message translates to:
  /// **'Remover {name}'**
  String removeLine(String name);

  /// No description provided for @emptyCart.
  ///
  /// In pt, this message translates to:
  /// **'Carrinho vazio'**
  String get emptyCart;

  /// No description provided for @emptyCartText.
  ///
  /// In pt, this message translates to:
  /// **'Leia a etiqueta de preço ou o código de barras, ou adicione manualmente.'**
  String get emptyCartText;

  /// No description provided for @fromListMissing.
  ///
  /// In pt, this message translates to:
  /// **'Da lista ({n} faltando)'**
  String fromListMissing(int n);

  /// No description provided for @summary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo'**
  String get summary;

  /// No description provided for @plannedVsActualLine.
  ///
  /// In pt, this message translates to:
  /// **'Planejado (com preço): {planned} · Realizado: {actual} · Diferença: {diff}'**
  String plannedVsActualLine(String planned, String actual, String diff);

  /// No description provided for @boughtLine.
  ///
  /// In pt, this message translates to:
  /// **'{bought} da lista comprados · {notBought} não comprados · {extra} extras'**
  String boughtLine(int bought, int notBought, int extra);

  /// No description provided for @receiptRead.
  ///
  /// In pt, this message translates to:
  /// **'Cupom fiscal lido: chave …{key} (consulta à SEFAZ não disponível offline).'**
  String receiptRead(String key);

  /// No description provided for @expenseRegistered.
  ///
  /// In pt, this message translates to:
  /// **'Despesa registrada nas finanças.'**
  String get expenseRegistered;

  /// No description provided for @registerAsExpense.
  ///
  /// In pt, this message translates to:
  /// **'Registrar {value} como despesa'**
  String registerAsExpense(String value);

  /// No description provided for @registerOnceHelp.
  ///
  /// In pt, this message translates to:
  /// **'Cria um único lançamento em Supermercado. Nunca é registrado duas vezes.'**
  String get registerOnceHelp;

  /// No description provided for @tagBtn.
  ///
  /// In pt, this message translates to:
  /// **'Etiqueta'**
  String get tagBtn;

  /// No description provided for @codeBtn.
  ///
  /// In pt, this message translates to:
  /// **'Código'**
  String get codeBtn;

  /// No description provided for @manualBtn.
  ///
  /// In pt, this message translates to:
  /// **'Manual'**
  String get manualBtn;

  /// No description provided for @finishPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar compra'**
  String get finishPurchase;

  /// No description provided for @confirmItem.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar item'**
  String get confirmItem;

  /// No description provided for @readingConfidence.
  ///
  /// In pt, this message translates to:
  /// **'Confiança da leitura: {percent}%'**
  String readingConfidence(int percent);

  /// No description provided for @product.
  ///
  /// In pt, this message translates to:
  /// **'Produto'**
  String get product;

  /// No description provided for @productNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome do produto'**
  String get productNameHint;

  /// No description provided for @pricePer.
  ///
  /// In pt, this message translates to:
  /// **'Preço por {unit}'**
  String pricePer(String unit);

  /// No description provided for @unitPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço unitário'**
  String get unitPrice;

  /// No description provided for @previousTagPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço anterior na etiqueta: {value}'**
  String previousTagPrice(String value);

  /// No description provided for @quantityUnit.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade ({unit})'**
  String quantityUnit(String unit);

  /// No description provided for @quantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get quantity;

  /// No description provided for @promotion.
  ///
  /// In pt, this message translates to:
  /// **'Promoção'**
  String get promotion;

  /// No description provided for @take3pay2.
  ///
  /// In pt, this message translates to:
  /// **'Leve 3 pague 2'**
  String get take3pay2;

  /// No description provided for @take2pay1.
  ///
  /// In pt, this message translates to:
  /// **'Leve 2 pague 1'**
  String get take2pay1;

  /// No description provided for @off10.
  ///
  /// In pt, this message translates to:
  /// **'10% off'**
  String get off10;

  /// No description provided for @off20.
  ///
  /// In pt, this message translates to:
  /// **'20% off'**
  String get off20;

  /// No description provided for @subtotal.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal: {value}'**
  String subtotal(String value);

  /// No description provided for @addToCart.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ao carrinho'**
  String get addToCart;

  /// No description provided for @leavePurchaseQ.
  ///
  /// In pt, this message translates to:
  /// **'Sair da compra?'**
  String get leavePurchaseQ;

  /// No description provided for @leavePurchaseText.
  ///
  /// In pt, this message translates to:
  /// **'O carrinho fica salvo e você pode continuar depois pela aba Compras.'**
  String get leavePurchaseText;

  /// No description provided for @leaveKeep.
  ///
  /// In pt, this message translates to:
  /// **'Sair e manter'**
  String get leaveKeep;

  /// No description provided for @newProductWarn.
  ///
  /// In pt, this message translates to:
  /// **'Produto novo: informe o nome e o preço da etiqueta.'**
  String get newProductWarn;

  /// No description provided for @scaleCodeWarn.
  ///
  /// In pt, this message translates to:
  /// **'Código de balança: o valor embutido pode ser peso ou preço; confirme.'**
  String get scaleCodeWarn;

  /// No description provided for @ocrUnavailableWarn.
  ///
  /// In pt, this message translates to:
  /// **'Leitura indisponível: informe manualmente.'**
  String get ocrUnavailableWarn;

  /// No description provided for @variationWarn.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% em relação ao último preço ({value}).'**
  String variationWarn(String percent, String value);

  /// No description provided for @lowConfidenceWarn.
  ///
  /// In pt, this message translates to:
  /// **'Leitura com baixa confiança: confira nome e preço.'**
  String get lowConfidenceWarn;

  /// No description provided for @noPriceInListWarn.
  ///
  /// In pt, this message translates to:
  /// **'Sem preço na lista: informe o preço da etiqueta.'**
  String get noPriceInListWarn;

  /// No description provided for @groceriesCategory.
  ///
  /// In pt, this message translates to:
  /// **'Supermercado'**
  String get groceriesCategory;

  /// No description provided for @camera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get camera;

  /// No description provided for @cameraPermissionText.
  ///
  /// In pt, this message translates to:
  /// **'Para ler etiquetas de preço e códigos de barras, o SerenaCash precisa da câmera. As fotos de etiqueta ficam só neste aparelho, dentro do banco cifrado, e não são enviadas a lugar nenhum. Se a permissão foi negada antes, libere a câmera nas configurações do Android.'**
  String get cameraPermissionText;

  /// No description provided for @allowCamera.
  ///
  /// In pt, this message translates to:
  /// **'Permitir câmera'**
  String get allowCamera;

  /// No description provided for @enterManually.
  ///
  /// In pt, this message translates to:
  /// **'Informar manualmente'**
  String get enterManually;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @cameraUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Câmera indisponível'**
  String get cameraUnavailable;

  /// No description provided for @frameTag.
  ///
  /// In pt, this message translates to:
  /// **'Enquadre a etiqueta inteira, sem reflexo, e toque em Ler'**
  String get frameTag;

  /// No description provided for @pointBarcode.
  ///
  /// In pt, this message translates to:
  /// **'Aponte para o código de barras ou QR do cupom'**
  String get pointBarcode;

  /// No description provided for @closeCamera.
  ///
  /// In pt, this message translates to:
  /// **'Fechar câmera'**
  String get closeCamera;

  /// No description provided for @torchOn.
  ///
  /// In pt, this message translates to:
  /// **'Ligar lanterna'**
  String get torchOn;

  /// No description provided for @torchOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligar lanterna'**
  String get torchOff;

  /// No description provided for @readTag.
  ///
  /// In pt, this message translates to:
  /// **'Ler etiqueta'**
  String get readTag;

  /// No description provided for @readingTag.
  ///
  /// In pt, this message translates to:
  /// **'Lendo a etiqueta…'**
  String get readingTag;

  /// No description provided for @scanningAuto.
  ///
  /// In pt, this message translates to:
  /// **'Lendo automaticamente…'**
  String get scanningAuto;

  /// No description provided for @qrNotReceipt.
  ///
  /// In pt, this message translates to:
  /// **'QR lido, mas não é um cupom fiscal (NFC-e).'**
  String get qrNotReceipt;

  /// No description provided for @invalidCode.
  ///
  /// In pt, this message translates to:
  /// **'Código inválido; tente de novo.'**
  String get invalidCode;

  /// No description provided for @readFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha na leitura. Tente de novo.'**
  String get readFailed;

  /// No description provided for @ocrUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de texto indisponível neste aparelho/versão. Informe o preço manualmente.'**
  String get ocrUnavailable;

  /// No description provided for @photoFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível capturar a foto.'**
  String get photoFailed;

  /// No description provided for @dayTotalHint.
  ///
  /// In pt, this message translates to:
  /// **'Receitas menos despesas. Transferências, pagamentos de fatura e reservas só movem dinheiro e não entram.'**
  String get dayTotalHint;

  /// No description provided for @colorTeal.
  ///
  /// In pt, this message translates to:
  /// **'Azul-petróleo'**
  String get colorTeal;

  /// No description provided for @colorGreen.
  ///
  /// In pt, this message translates to:
  /// **'Verde'**
  String get colorGreen;

  /// No description provided for @colorCopper.
  ///
  /// In pt, this message translates to:
  /// **'Cobre'**
  String get colorCopper;

  /// No description provided for @colorAmber.
  ///
  /// In pt, this message translates to:
  /// **'Âmbar'**
  String get colorAmber;

  /// No description provided for @colorRed.
  ///
  /// In pt, this message translates to:
  /// **'Vermelho'**
  String get colorRed;

  /// No description provided for @colorGray.
  ///
  /// In pt, this message translates to:
  /// **'Cinza'**
  String get colorGray;

  /// No description provided for @colorOther.
  ///
  /// In pt, this message translates to:
  /// **'Cor {hex}'**
  String colorOther(String hex);

  /// No description provided for @countAccounts.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 conta} other{{n} contas}}'**
  String countAccounts(int n);

  /// No description provided for @countCategories.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 categoria} other{{n} categorias}}'**
  String countCategories(int n);

  /// No description provided for @countTags.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 tag} other{{n} tags}}'**
  String countTags(int n);

  /// No description provided for @countCards.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 cartão} other{{n} cartões}}'**
  String countCards(int n);

  /// No description provided for @countTransactions.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 lançamento} other{{n} lançamentos}}'**
  String countTransactions(int n);

  /// No description provided for @countBudgets.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 orçamento} other{{n} orçamentos}}'**
  String countBudgets(int n);

  /// No description provided for @countGoals.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 meta} other{{n} metas}}'**
  String countGoals(int n);

  /// No description provided for @countLoans.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 empréstimo} other{{n} empréstimos}}'**
  String countLoans(int n);

  /// No description provided for @countAttachments.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 anexo} other{{n} anexos}}'**
  String countAttachments(int n);

  /// No description provided for @countRecurrenceRules.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 série} other{{n} séries}}'**
  String countRecurrenceRules(int n);

  /// No description provided for @countShoppingLists.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 lista de compras} other{{n} listas de compras}}'**
  String countShoppingLists(int n);

  /// No description provided for @countShoppingSessions.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 compra} other{{n} compras}}'**
  String countShoppingSessions(int n);

  /// No description provided for @countProducts.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 produto} other{{n} produtos}}'**
  String countProducts(int n);

  /// No description provided for @countPriceObservations.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 preço registrado} other{{n} preços registrados}}'**
  String countPriceObservations(int n);

  /// No description provided for @countOther.
  ///
  /// In pt, this message translates to:
  /// **'{n} {name}'**
  String countOther(int n, String name);

  /// No description provided for @finishPurchaseQ.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar a compra?'**
  String get finishPurchaseQ;

  /// No description provided for @finishPurchaseText.
  ///
  /// In pt, this message translates to:
  /// **'O carrinho é fechado com {total}. Depois você escolhe se registra como despesa.'**
  String finishPurchaseText(String total);

  /// No description provided for @finishPurchasePending.
  ///
  /// In pt, this message translates to:
  /// **'O item que você estava confirmando ainda não foi adicionado e ficará de fora.'**
  String get finishPurchasePending;

  /// No description provided for @finishConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar'**
  String get finishConfirm;

  /// No description provided for @showSecret.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar'**
  String get showSecret;

  /// No description provided for @hideSecret.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar'**
  String get hideSecret;

  /// No description provided for @homeSetupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configure seu saldo'**
  String get homeSetupTitle;

  /// No description provided for @homeSetupText.
  ///
  /// In pt, this message translates to:
  /// **'Adicione sua primeira conta para saber quanto pode gastar.'**
  String get homeSetupText;

  /// No description provided for @heroBalances.
  ///
  /// In pt, this message translates to:
  /// **'Saldo em contas'**
  String get heroBalances;

  /// No description provided for @heroCommitted.
  ///
  /// In pt, this message translates to:
  /// **'Compromissos'**
  String get heroCommitted;

  /// No description provided for @heroPlannedIncome.
  ///
  /// In pt, this message translates to:
  /// **'Inclui {value} de receitas previstas.'**
  String heroPlannedIncome(String value);

  /// No description provided for @quickBill.
  ///
  /// In pt, this message translates to:
  /// **'Conta a pagar'**
  String get quickBill;

  /// No description provided for @quickTransfer.
  ///
  /// In pt, this message translates to:
  /// **'Transferir'**
  String get quickTransfer;

  /// No description provided for @quickIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get quickIncome;

  /// No description provided for @quickAccounts.
  ///
  /// In pt, this message translates to:
  /// **'Contas'**
  String get quickAccounts;

  /// No description provided for @seeAllFem.
  ///
  /// In pt, this message translates to:
  /// **'Ver todas'**
  String get seeAllFem;

  /// No description provided for @seeAllMasc.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get seeAllMasc;

  /// No description provided for @seeCards.
  ///
  /// In pt, this message translates to:
  /// **'Ver cartões'**
  String get seeCards;

  /// No description provided for @billsPendingUntil.
  ///
  /// In pt, this message translates to:
  /// **'Pendente até {date}'**
  String billsPendingUntil(String date);

  /// No description provided for @billsOverdueCount.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 atrasada} other{{n} atrasadas}}'**
  String billsOverdueCount(int n);

  /// No description provided for @dueToday.
  ///
  /// In pt, this message translates to:
  /// **'Vence hoje'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Vence amanhã'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Vence em 1 dia} other{Vence em {n} dias}}'**
  String dueInDays(int n);

  /// No description provided for @dueOnDate.
  ///
  /// In pt, this message translates to:
  /// **'Vence {date}'**
  String dueOnDate(String date);

  /// No description provided for @overdueSince.
  ///
  /// In pt, this message translates to:
  /// **'Atrasada desde {date}'**
  String overdueSince(String date);

  /// No description provided for @noBillPlanned.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta prevista'**
  String get noBillPlanned;

  /// No description provided for @moreBills.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Mais 1 conta} other{Mais {n} contas}}'**
  String moreBills(int n);

  /// No description provided for @firstCard.
  ///
  /// In pt, this message translates to:
  /// **'Adicione seu primeiro cartão'**
  String get firstCard;

  /// No description provided for @invoiceDueLabel.
  ///
  /// In pt, this message translates to:
  /// **'Vencimento'**
  String get invoiceDueLabel;

  /// No description provided for @invoiceCloses.
  ///
  /// In pt, this message translates to:
  /// **'Fecha em {date}'**
  String invoiceCloses(String date);

  /// No description provided for @freeLimit.
  ///
  /// In pt, this message translates to:
  /// **'Limite livre {value}'**
  String freeLimit(String value);

  /// No description provided for @moreCards.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Mais 1 cartão} other{Mais {n} cartões}}'**
  String moreCards(int n);

  /// No description provided for @noTransactionYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum lançamento ainda'**
  String get noTransactionYet;

  /// No description provided for @useDarkTheme.
  ///
  /// In pt, this message translates to:
  /// **'Usar tema escuro'**
  String get useDarkTheme;

  /// No description provided for @useLightTheme.
  ///
  /// In pt, this message translates to:
  /// **'Usar tema claro'**
  String get useLightTheme;

  /// No description provided for @periodControl.
  ///
  /// In pt, this message translates to:
  /// **'{period}. Mudar período e personalizar'**
  String periodControl(String period);

  /// No description provided for @homeLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando seus dados'**
  String get homeLoading;

  /// No description provided for @noSpendingYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum gasto neste período'**
  String get noSpendingYet;

  /// No description provided for @noGoalYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma meta criada'**
  String get noGoalYet;

  /// No description provided for @greetingWithName.
  ///
  /// In pt, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @canSpendThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Pode gastar neste mês'**
  String get canSpendThisMonth;

  /// No description provided for @heroAfterCommitted.
  ///
  /// In pt, this message translates to:
  /// **'Após os compromissos previstos'**
  String get heroAfterCommitted;

  /// No description provided for @heroCommittedMonth.
  ///
  /// In pt, this message translates to:
  /// **'Compromissos do mês'**
  String get heroCommittedMonth;

  /// No description provided for @quickEntry.
  ///
  /// In pt, this message translates to:
  /// **'Lançamento'**
  String get quickEntry;

  /// No description provided for @invoiceCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Fatura atual'**
  String get invoiceCurrent;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @yourName.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome'**
  String get yourName;

  /// No description provided for @yourNameEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get yourNameEmpty;

  /// No description provided for @yourNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Como quer ser chamado'**
  String get yourNameLabel;

  /// No description provided for @yourNameHelp.
  ///
  /// In pt, this message translates to:
  /// **'Aparece na saudação da tela inicial. Fica só neste aparelho.'**
  String get yourNameHelp;

  /// No description provided for @catTitle.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get catTitle;

  /// No description provided for @catNewSub.
  ///
  /// In pt, this message translates to:
  /// **'Nova subcategoria'**
  String get catNewSub;

  /// No description provided for @catEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar categoria'**
  String get catEdit;

  /// No description provided for @catEditSub.
  ///
  /// In pt, this message translates to:
  /// **'Editar subcategoria'**
  String get catEditSub;

  /// No description provided for @catIcon.
  ///
  /// In pt, this message translates to:
  /// **'Ícone'**
  String get catIcon;

  /// No description provided for @catSearchIcon.
  ///
  /// In pt, this message translates to:
  /// **'Buscar ícone (ex.: mercado, saúde)'**
  String get catSearchIcon;

  /// No description provided for @catNoIcon.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ícone para “{q}”.'**
  String catNoIcon(String q);

  /// No description provided for @catPreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia'**
  String get catPreview;

  /// No description provided for @catPreviewName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da categoria'**
  String get catPreviewName;

  /// No description provided for @catParent.
  ///
  /// In pt, this message translates to:
  /// **'Categoria principal'**
  String get catParent;

  /// No description provided for @catParentNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma: é uma categoria principal'**
  String get catParentNone;

  /// No description provided for @catParentHelp.
  ///
  /// In pt, this message translates to:
  /// **'Uma subcategoria detalha a categoria principal. Os totais da principal já incluem as subcategorias.'**
  String get catParentHelp;

  /// No description provided for @catParentLocked.
  ///
  /// In pt, this message translates to:
  /// **'Esta categoria tem subcategorias, por isso continua como principal.'**
  String get catParentLocked;

  /// No description provided for @catSubCount.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =0{Sem subcategorias} one{1 subcategoria} other{{n} subcategorias}}'**
  String catSubCount(int n);

  /// No description provided for @catAddSubTo.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar subcategoria em {name}'**
  String catAddSubTo(String name);

  /// No description provided for @catAddSub.
  ///
  /// In pt, this message translates to:
  /// **'Subcategoria'**
  String get catAddSub;

  /// No description provided for @catArchivedSection.
  ///
  /// In pt, this message translates to:
  /// **'Arquivadas'**
  String get catArchivedSection;

  /// No description provided for @catArchivedHelp.
  ///
  /// In pt, this message translates to:
  /// **'Categorias arquivadas continuam nos lançamentos antigos e nos relatórios, mas saem das listas de escolha.'**
  String get catArchivedHelp;

  /// No description provided for @catArchive.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar'**
  String get catArchive;

  /// No description provided for @catArchiveText.
  ///
  /// In pt, this message translates to:
  /// **'Sai das listas de escolha. Os lançamentos que já usam esta categoria continuam como estão.'**
  String get catArchiveText;

  /// No description provided for @catReactivate.
  ///
  /// In pt, this message translates to:
  /// **'Reativar'**
  String get catReactivate;

  /// No description provided for @catDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get catDelete;

  /// No description provided for @catDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir “{name}”?'**
  String catDeleteTitle(String name);

  /// No description provided for @catDeleteUnused.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum lançamento usa esta categoria.'**
  String get catDeleteUnused;

  /// No description provided for @catDeleteUsed.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, one{1 lançamento usa esta categoria} other{{n} lançamentos usam esta categoria}}. Escolha o que fazer com eles:'**
  String catDeleteUsed(int n);

  /// No description provided for @catDeleteSubs.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, one{A subcategoria será excluída junto} other{As {n} subcategorias serão excluídas junto}}.'**
  String catDeleteSubs(int n);

  /// No description provided for @catDeleteBudgets.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, one{1 orçamento desta categoria será removido} other{{n} orçamentos desta categoria serão removidos}}.'**
  String catDeleteBudgets(int n);

  /// No description provided for @catMoveTo.
  ///
  /// In pt, this message translates to:
  /// **'Mover para outra categoria'**
  String get catMoveTo;

  /// No description provided for @catMoveToPick.
  ///
  /// In pt, this message translates to:
  /// **'Escolher categoria de destino'**
  String get catMoveToPick;

  /// No description provided for @catLeaveNone.
  ///
  /// In pt, this message translates to:
  /// **'Deixar sem categoria'**
  String get catLeaveNone;

  /// No description provided for @catDeleteConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Excluir categoria'**
  String get catDeleteConfirm;

  /// No description provided for @catDeleted.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =0{Categoria excluída.} one{Categoria excluída. 1 lançamento reclassificado.} other{Categoria excluída. {n} lançamentos reclassificados.}}'**
  String catDeleted(int n);

  /// No description provided for @catErrEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Informe um nome.'**
  String get catErrEmpty;

  /// No description provided for @catErrDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Já existe uma categoria com esse nome neste nível.'**
  String get catErrDuplicate;

  /// No description provided for @catErrParent.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma categoria principal válida do mesmo tipo.'**
  String get catErrParent;

  /// No description provided for @catErrHasSubs.
  ///
  /// In pt, this message translates to:
  /// **'Uma categoria com subcategorias não pode virar subcategoria.'**
  String get catErrHasSubs;

  /// No description provided for @catErrTarget.
  ///
  /// In pt, this message translates to:
  /// **'Escolha outra categoria de destino.'**
  String get catErrTarget;

  /// No description provided for @catSearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar categoria'**
  String get catSearch;

  /// No description provided for @catNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria para “{q}”.'**
  String catNotFound(String q);

  /// No description provided for @catCreateNamed.
  ///
  /// In pt, this message translates to:
  /// **'Criar “{q}”'**
  String catCreateNamed(String q);

  /// No description provided for @catNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem categoria'**
  String get catNone;

  /// No description provided for @catChoose.
  ///
  /// In pt, this message translates to:
  /// **'Escolher categoria'**
  String get catChoose;

  /// No description provided for @catSubcategory.
  ///
  /// In pt, this message translates to:
  /// **'Subcategoria'**
  String get catSubcategory;

  /// No description provided for @catSubNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma'**
  String get catSubNone;

  /// No description provided for @catNewSubShort.
  ///
  /// In pt, this message translates to:
  /// **'Nova'**
  String get catNewSubShort;

  /// No description provided for @catUsage.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =0{Sem lançamentos} one{1 lançamento} other{{n} lançamentos}}'**
  String catUsage(int n);

  /// No description provided for @catEmptyKind.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria aqui ainda.'**
  String get catEmptyKind;

  /// No description provided for @catAllCategories.
  ///
  /// In pt, this message translates to:
  /// **'Todas as categorias'**
  String get catAllCategories;

  /// No description provided for @catFilter.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get catFilter;

  /// No description provided for @colorBlue.
  ///
  /// In pt, this message translates to:
  /// **'Azul'**
  String get colorBlue;

  /// No description provided for @colorSky.
  ///
  /// In pt, this message translates to:
  /// **'Azul-claro'**
  String get colorSky;

  /// No description provided for @colorOlive.
  ///
  /// In pt, this message translates to:
  /// **'Verde-oliva'**
  String get colorOlive;

  /// No description provided for @colorGold.
  ///
  /// In pt, this message translates to:
  /// **'Dourado'**
  String get colorGold;

  /// No description provided for @colorRose.
  ///
  /// In pt, this message translates to:
  /// **'Rosado'**
  String get colorRose;

  /// No description provided for @colorBrown.
  ///
  /// In pt, this message translates to:
  /// **'Marrom'**
  String get colorBrown;

  /// No description provided for @colorLightGray.
  ///
  /// In pt, this message translates to:
  /// **'Cinza-claro'**
  String get colorLightGray;

  /// No description provided for @tagsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @navMenu.
  ///
  /// In pt, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navGroupMain.
  ///
  /// In pt, this message translates to:
  /// **'Principal'**
  String get navGroupMain;

  /// No description provided for @navGroupMoves.
  ///
  /// In pt, this message translates to:
  /// **'Movimentações'**
  String get navGroupMoves;

  /// No description provided for @navGroupPlanning.
  ///
  /// In pt, this message translates to:
  /// **'Planejamento'**
  String get navGroupPlanning;

  /// No description provided for @navGroupRegisters.
  ///
  /// In pt, this message translates to:
  /// **'Cadastros'**
  String get navGroupRegisters;

  /// No description provided for @navGroupSettings.
  ///
  /// In pt, this message translates to:
  /// **'Aplicativo'**
  String get navGroupSettings;

  /// No description provided for @navCards.
  ///
  /// In pt, this message translates to:
  /// **'Cartões de crédito'**
  String get navCards;

  /// No description provided for @navCategories.
  ///
  /// In pt, this message translates to:
  /// **'Categorias e subcategorias'**
  String get navCategories;

  /// No description provided for @addTitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get addTitle;

  /// No description provided for @addExpense.
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get addExpense;

  /// No description provided for @addExpenseDesc.
  ///
  /// In pt, this message translates to:
  /// **'Dinheiro que saiu de uma conta'**
  String get addExpenseDesc;

  /// No description provided for @addIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get addIncome;

  /// No description provided for @addIncomeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Dinheiro que entrou em uma conta'**
  String get addIncomeDesc;

  /// No description provided for @addTransfer.
  ///
  /// In pt, this message translates to:
  /// **'Transferência'**
  String get addTransfer;

  /// No description provided for @addTransferDesc.
  ///
  /// In pt, this message translates to:
  /// **'Entre duas contas suas'**
  String get addTransferDesc;

  /// No description provided for @addCardPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Compra no cartão'**
  String get addCardPurchase;

  /// No description provided for @addCardPurchaseDesc.
  ///
  /// In pt, this message translates to:
  /// **'Entra na fatura do cartão de crédito'**
  String get addCardPurchaseDesc;

  /// No description provided for @addBill.
  ///
  /// In pt, this message translates to:
  /// **'Conta a pagar'**
  String get addBill;

  /// No description provided for @addBillDesc.
  ///
  /// In pt, this message translates to:
  /// **'Despesa com vencimento, ainda não paga'**
  String get addBillDesc;

  /// No description provided for @addReceivable.
  ///
  /// In pt, this message translates to:
  /// **'Conta a receber'**
  String get addReceivable;

  /// No description provided for @addReceivableDesc.
  ///
  /// In pt, this message translates to:
  /// **'Receita prevista, ainda não recebida'**
  String get addReceivableDesc;

  /// No description provided for @repDirectInCategory.
  ///
  /// In pt, this message translates to:
  /// **'Direto na categoria'**
  String get repDirectInCategory;

  /// No description provided for @repSubsIncluded.
  ///
  /// In pt, this message translates to:
  /// **'O total de cada categoria já inclui as subcategorias listadas abaixo dela.'**
  String get repSubsIncluded;

  /// No description provided for @billsBoth.
  ///
  /// In pt, this message translates to:
  /// **'A pagar e a receber'**
  String get billsBoth;

  /// No description provided for @segPayable.
  ///
  /// In pt, this message translates to:
  /// **'A pagar'**
  String get segPayable;

  /// No description provided for @segReceivable.
  ///
  /// In pt, this message translates to:
  /// **'A receber'**
  String get segReceivable;

  /// No description provided for @receive.
  ///
  /// In pt, this message translates to:
  /// **'Receber'**
  String get receive;

  /// No description provided for @receivableUntil.
  ///
  /// In pt, this message translates to:
  /// **'A receber até {date} · {value}'**
  String receivableUntil(String date, String value);

  /// No description provided for @receivableLate.
  ///
  /// In pt, this message translates to:
  /// **'Atrasadas · {value}'**
  String receivableLate(String value);

  /// No description provided for @nothingToReceive.
  ///
  /// In pt, this message translates to:
  /// **'Nada a receber no período'**
  String get nothingToReceive;

  /// No description provided for @newReceivable.
  ///
  /// In pt, this message translates to:
  /// **'Nova conta a receber'**
  String get newReceivable;

  /// No description provided for @receivablesHelp.
  ///
  /// In pt, this message translates to:
  /// **'“Receber” marca como recebido hoje na conta do lançamento. Para receber parte, abra o lançamento.'**
  String get receivablesHelp;

  /// No description provided for @expectedOn.
  ///
  /// In pt, this message translates to:
  /// **'Previsto para {date}'**
  String expectedOn(String date);

  /// No description provided for @expectedSince.
  ///
  /// In pt, this message translates to:
  /// **'Previsto desde {date}'**
  String expectedSince(String date);

  /// No description provided for @plannedHelpIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receitas previstas aparecem em \"A receber\" e só entram no saldo quando você marcar como recebidas.'**
  String get plannedHelpIncome;

  /// No description provided for @bootKeyMissing.
  ///
  /// In pt, this message translates to:
  /// **'A chave que protege seus dados não está mais neste aparelho, então o banco não pode ser aberto. Isso acontece, por exemplo, quando os dados do app são copiados de outro aparelho.'**
  String get bootKeyMissing;

  /// No description provided for @bootKeyInvalid.
  ///
  /// In pt, this message translates to:
  /// **'A chave que protege seus dados está danificada, então o banco não pode ser aberto.'**
  String get bootKeyInvalid;

  /// No description provided for @bootGeneric.
  ///
  /// In pt, this message translates to:
  /// **'O banco de dados protegido não abriu. Pode ser uma falha passageira do aparelho ou um arquivo danificado.'**
  String get bootGeneric;

  /// No description provided for @bootRecoverHelp.
  ///
  /// In pt, this message translates to:
  /// **'Tente de novo primeiro. Se continuar, a saída é apagar os dados deste aparelho e recomeçar; depois você pode restaurar um backup exportado pelo SerenaCash.'**
  String get bootRecoverHelp;

  /// No description provided for @bootRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get bootRetry;

  /// No description provided for @bootReset.
  ///
  /// In pt, this message translates to:
  /// **'Apagar dados e recomeçar'**
  String get bootReset;

  /// No description provided for @bootResetQ.
  ///
  /// In pt, this message translates to:
  /// **'Apagar os dados deste aparelho?'**
  String get bootResetQ;

  /// No description provided for @bootResetText.
  ///
  /// In pt, this message translates to:
  /// **'Tudo o que está guardado no SerenaCash neste aparelho será apagado e não poderá ser recuperado daqui. Um backup exportado antes continua valendo e pode ser restaurado depois.'**
  String get bootResetText;

  /// No description provided for @bootDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhe técnico: {detail}'**
  String bootDetails(String detail);

  /// No description provided for @pinLockedFor.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Tente de novo em {time}.'**
  String pinLockedFor(String time);

  /// No description provided for @pinAttemptsLeft.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, one{PIN incorreto. Resta 1 tentativa antes de uma pausa.} other{PIN incorreto. Restam {n} tentativas antes de uma pausa.}}'**
  String pinAttemptsLeft(int n);

  /// No description provided for @pinForgot.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci o PIN'**
  String get pinForgot;

  /// No description provided for @pinForgotTitle.
  ///
  /// In pt, this message translates to:
  /// **'O PIN não pode ser recuperado'**
  String get pinForgotTitle;

  /// No description provided for @pinForgotText.
  ///
  /// In pt, this message translates to:
  /// **'O SerenaCash não guarda o PIN em nenhum lugar de onde ele possa ser lido, nem envia nada para fora do aparelho. Sem o PIN, a única saída é apagar os dados deste aparelho e recomeçar. Se você exportou um backup, pode restaurá-lo depois.'**
  String get pinForgotText;

  /// No description provided for @pinCurrent.
  ///
  /// In pt, this message translates to:
  /// **'PIN atual'**
  String get pinCurrent;

  /// No description provided for @pinDisableTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirme o PIN para desativar'**
  String get pinDisableTitle;

  /// No description provided for @lockScreenProtected.
  ///
  /// In pt, this message translates to:
  /// **'Com o bloqueio ativado, o app também esconde o conteúdo na lista de apps recentes e impede capturas de tela.'**
  String get lockScreenProtected;

  /// No description provided for @lockRecover.
  ///
  /// In pt, this message translates to:
  /// **'Não consigo desbloquear'**
  String get lockRecover;

  /// No description provided for @lockRecoverText.
  ///
  /// In pt, this message translates to:
  /// **'Se o desbloqueio do aparelho não funciona mais aqui, a única saída é apagar os dados deste aparelho e recomeçar. Se você exportou um backup, pode restaurá-lo depois.'**
  String get lockRecoverText;

  /// No description provided for @biometricConfirmToEnable.
  ///
  /// In pt, this message translates to:
  /// **'Confirme no aparelho para ativar o bloqueio'**
  String get biometricConfirmToEnable;

  /// No description provided for @biometricNotEnabled.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível confirmar no aparelho; o bloqueio não foi ativado. Configure um bloqueio de tela ou biometria no Android e tente de novo.'**
  String get biometricNotEnabled;

  /// No description provided for @openCalendar.
  ///
  /// In pt, this message translates to:
  /// **'Abrir calendário'**
  String get openCalendar;

  /// No description provided for @payWith.
  ///
  /// In pt, this message translates to:
  /// **'Forma de pagamento'**
  String get payWith;

  /// No description provided for @payWithAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta ou carteira'**
  String get payWithAccount;

  /// No description provided for @payWithCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão de crédito'**
  String get payWithCard;

  /// No description provided for @newAccountChip.
  ///
  /// In pt, this message translates to:
  /// **'Nova conta'**
  String get newAccountChip;

  /// No description provided for @newCardChip.
  ///
  /// In pt, this message translates to:
  /// **'Novo cartão'**
  String get newCardChip;

  /// No description provided for @transferNeedsTwo.
  ///
  /// In pt, this message translates to:
  /// **'A transferência precisa de duas contas. Cadastre a conta de destino.'**
  String get transferNeedsTwo;

  /// No description provided for @cardPurchaseHelp.
  ///
  /// In pt, this message translates to:
  /// **'Entra na fatura do cartão. Nenhuma conta é debitada agora; a conta só baixa quando a fatura for paga.'**
  String get cardPurchaseHelp;

  /// No description provided for @installmentsExact.
  ///
  /// In pt, this message translates to:
  /// **'{first} na primeira e {rest} nas demais'**
  String installmentsExact(String first, String rest);

  /// No description provided for @bioCanceled.
  ///
  /// In pt, this message translates to:
  /// **'Confirmação cancelada; o bloqueio não foi ativado.'**
  String get bioCanceled;

  /// No description provided for @bioFailedEnable.
  ///
  /// In pt, this message translates to:
  /// **'O aparelho não confirmou sua identidade; o bloqueio não foi ativado.'**
  String get bioFailedEnable;

  /// No description provided for @bioNotSetUp.
  ///
  /// In pt, this message translates to:
  /// **'Este aparelho não tem bloqueio de tela nem biometria cadastrada. Cadastre nas configurações de segurança do Android e tente de novo.'**
  String get bioNotSetUp;

  /// No description provided for @bioNoHardware.
  ///
  /// In pt, this message translates to:
  /// **'Este aparelho não oferece confirmação por biometria nem por bloqueio de tela. Use o PIN do aplicativo.'**
  String get bioNoHardware;

  /// No description provided for @bioLockedOut.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. O Android suspendeu a biometria por um tempo; aguarde e tente de novo.'**
  String get bioLockedOut;

  /// No description provided for @bioUnavailableNow.
  ///
  /// In pt, this message translates to:
  /// **'O Android não conseguiu abrir a confirmação agora. Tente de novo.'**
  String get bioUnavailableNow;

  /// No description provided for @bioOpenSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir configurações'**
  String get bioOpenSettings;

  /// No description provided for @unlockNotSetUp.
  ///
  /// In pt, this message translates to:
  /// **'O bloqueio de tela deste aparelho foi removido. Cadastre um bloqueio de tela ou uma biometria no Android para desbloquear.'**
  String get unlockNotSetUp;

  /// No description provided for @annualNoData.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum lançamento e nenhum orçamento em {year}.'**
  String annualNoData(String year);

  /// No description provided for @annualNoDataHint.
  ///
  /// In pt, this message translates to:
  /// **'O app só mostra o que foi registrado: um orçamento ou uma meta criados depois não valem para trás.'**
  String get annualNoDataHint;

  /// No description provided for @annualGoalsOfYear.
  ///
  /// In pt, this message translates to:
  /// **'Metas em {year}'**
  String annualGoalsOfYear(String year);

  /// No description provided for @annualNoGoalsInYear.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma meta existia em {year}.'**
  String annualNoGoalsInYear(String year);

  /// No description provided for @annualGoalPast.
  ///
  /// In pt, this message translates to:
  /// **'{name}: {saved} guardados no ano · {total} acumulados até dezembro'**
  String annualGoalPast(String name, String saved, String total);

  /// No description provided for @annualGoalByDate.
  ///
  /// In pt, this message translates to:
  /// **'{name}: faltam {remaining} · {value}/mês até {date}'**
  String annualGoalByDate(
    String name,
    String remaining,
    String value,
    String date,
  );

  /// No description provided for @annualGoalByYearEnd.
  ///
  /// In pt, this message translates to:
  /// **'{name}: faltam {remaining} · {value}/mês para concluir até dezembro (meta sem prazo)'**
  String annualGoalByYearEnd(String name, String remaining, String value);

  /// No description provided for @annualGoalFutureDate.
  ///
  /// In pt, this message translates to:
  /// **'{name}: faltam {remaining} hoje · prazo em {date}'**
  String annualGoalFutureDate(String name, String remaining, String date);

  /// No description provided for @annualGoalFutureOpen.
  ///
  /// In pt, this message translates to:
  /// **'{name}: faltam {remaining} hoje · sem prazo definido'**
  String annualGoalFutureOpen(String name, String remaining);

  /// No description provided for @annualFutureNote.
  ///
  /// In pt, this message translates to:
  /// **'Ano futuro: só aparece o que já está previsto nos lançamentos e o orçamento que estiver em vigor.'**
  String get annualFutureNote;

  /// No description provided for @biometricConfirmToDisable.
  ///
  /// In pt, this message translates to:
  /// **'Confirme no aparelho para desativar o bloqueio'**
  String get biometricConfirmToDisable;

  /// No description provided for @bioDisableDenied.
  ///
  /// In pt, this message translates to:
  /// **'O aparelho não confirmou sua identidade; o bloqueio continua ativado.'**
  String get bioDisableDenied;

  /// No description provided for @takePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get takePhoto;

  /// No description provided for @scanCart.
  ///
  /// In pt, this message translates to:
  /// **'Carrinho {total}'**
  String scanCart(String total);

  /// No description provided for @scanCartBudget.
  ///
  /// In pt, this message translates to:
  /// **'Carrinho {total} · cabe {left}'**
  String scanCartBudget(String total, String left);

  /// No description provided for @reviewTapDefines.
  ///
  /// In pt, this message translates to:
  /// **'O toque na foto define'**
  String get reviewTapDefines;

  /// No description provided for @reviewPhotoHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em um texto marcado na foto para usá-lo. Afaste dois dedos para ampliar.'**
  String get reviewPhotoHint;

  /// No description provided for @reviewPickName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get reviewPickName;

  /// No description provided for @reviewPickPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço'**
  String get reviewPickPrice;

  /// No description provided for @reviewNoPriceInLine.
  ///
  /// In pt, this message translates to:
  /// **'Esse trecho não tem um preço. Toque no valor da etiqueta.'**
  String get reviewNoPriceInLine;

  /// No description provided for @reviewPrices.
  ///
  /// In pt, this message translates to:
  /// **'Preços lidos na etiqueta'**
  String get reviewPrices;

  /// No description provided for @reviewOtherNames.
  ///
  /// In pt, this message translates to:
  /// **'Outros textos lidos'**
  String get reviewOtherNames;

  /// No description provided for @reviewConfirmPrice.
  ///
  /// In pt, this message translates to:
  /// **'Conferi o preço com a foto'**
  String get reviewConfirmPrice;

  /// No description provided for @reviewConfirmPriceHelp.
  ///
  /// In pt, this message translates to:
  /// **'A leitura deste preço ficou duvidosa. Compare com a etiqueta antes de adicionar.'**
  String get reviewConfirmPriceHelp;

  /// No description provided for @reviewNeedsCheck.
  ///
  /// In pt, this message translates to:
  /// **'Revisão necessária: confira o preço na foto, corrija ou marque que conferiu.'**
  String get reviewNeedsCheck;

  /// No description provided for @priceRetail.
  ///
  /// In pt, this message translates to:
  /// **'Varejo {value}'**
  String priceRetail(String value);

  /// No description provided for @priceWholesale.
  ///
  /// In pt, this message translates to:
  /// **'Atacado {value} a partir de {n} un'**
  String priceWholesale(String value, int n);

  /// No description provided for @priceWholesaleNoMin.
  ///
  /// In pt, this message translates to:
  /// **'Atacado {value}'**
  String priceWholesaleNoMin(String value);

  /// No description provided for @pricePerKg.
  ///
  /// In pt, this message translates to:
  /// **'Por quilo: {value} (impresso para comparação; não é o preço do item)'**
  String pricePerKg(String value);

  /// No description provided for @pricePerLiter.
  ///
  /// In pt, this message translates to:
  /// **'Por litro: {value} (impresso para comparação; não é o preço do item)'**
  String pricePerLiter(String value);

  /// No description provided for @pricePerPackUnit.
  ///
  /// In pt, this message translates to:
  /// **'Valor em letras pequenas: {value} (não é o preço do item)'**
  String pricePerPackUnit(String value);

  /// No description provided for @wholesaleHelp.
  ///
  /// In pt, this message translates to:
  /// **'Vale só quando a quantidade no carrinho chegar a {n}. Abaixo disso conta o preço de varejo.'**
  String wholesaleHelp(int n);

  /// No description provided for @wholesaleNoMinHelp.
  ///
  /// In pt, this message translates to:
  /// **'A etiqueta não mostra a partir de quantas unidades vale; por isso não é aplicado.'**
  String get wholesaleNoMinHelp;

  /// No description provided for @addAndScanNext.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar e ler a próxima'**
  String get addAndScanNext;

  /// No description provided for @addProductPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Foto do produto'**
  String get addProductPhoto;

  /// No description provided for @replaceProductPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Trocar foto do produto'**
  String get replaceProductPhoto;

  /// No description provided for @evidenceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Evidências'**
  String get evidenceTitle;

  /// No description provided for @evidenceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Etiqueta da gôndola'**
  String get evidenceLabel;

  /// No description provided for @evidenceProduct.
  ///
  /// In pt, this message translates to:
  /// **'Produto'**
  String get evidenceProduct;

  /// No description provided for @evidenceReceipt.
  ///
  /// In pt, this message translates to:
  /// **'Cupom'**
  String get evidenceReceipt;

  /// No description provided for @evidenceNote.
  ///
  /// In pt, this message translates to:
  /// **'As fotos ficam só neste aparelho, dentro do banco cifrado. São um registro seu do que estava anunciado, não uma prova jurídica.'**
  String get evidenceNote;

  /// No description provided for @evidenceReadVsConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Lido na etiqueta: {read} · confirmado por você: {confirmed}'**
  String evidenceReadVsConfirmed(String read, String confirmed);

  /// No description provided for @evidenceTakenAt.
  ///
  /// In pt, this message translates to:
  /// **'Foto de {date}'**
  String evidenceTakenAt(String date);

  /// No description provided for @evidenceDelete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar esta foto'**
  String get evidenceDelete;

  /// No description provided for @evidenceDeleteQ.
  ///
  /// In pt, this message translates to:
  /// **'Apagar a foto?'**
  String get evidenceDeleteQ;

  /// No description provided for @evidenceDeleteText.
  ///
  /// In pt, this message translates to:
  /// **'A foto sai do aparelho e não pode ser recuperada. O item e o preço continuam no carrinho.'**
  String get evidenceDeleteText;

  /// No description provided for @codeFound.
  ///
  /// In pt, this message translates to:
  /// **'Produto do seu cadastro, encontrado pelo código {code}.'**
  String codeFound(String code);

  /// No description provided for @codeDecodedUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Código {code} lido. Ele ainda não está no seu cadastro: informe nome e preço e o produto fica cadastrado com este código.'**
  String codeDecodedUnknown(String code);

  /// No description provided for @codeNotStandard.
  ///
  /// In pt, this message translates to:
  /// **'O código {code} foi lido, mas não fecha como código de produto padrão (EAN/UPC). Ele fica guardado como está.'**
  String codeNotStandard(String code);

  /// No description provided for @codeLastPrice.
  ///
  /// In pt, this message translates to:
  /// **'Último preço registrado: {value}, em {date}. Confira o preço de hoje na etiqueta.'**
  String codeLastPrice(String value, String date);

  /// No description provided for @photoNoReading.
  ///
  /// In pt, this message translates to:
  /// **'Nada foi lido na foto. Ela fica anexada ao item; informe nome e preço.'**
  String get photoNoReading;

  /// No description provided for @evidenceEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma foto nesta compra'**
  String get evidenceEmpty;

  /// No description provided for @evidenceEmptyText.
  ///
  /// In pt, this message translates to:
  /// **'As fotos de etiqueta, de produto e do cupom aparecem aqui.'**
  String get evidenceEmptyText;

  /// No description provided for @evidenceOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir a foto'**
  String get evidenceOpen;

  /// No description provided for @evidenceCount.
  ///
  /// In pt, this message translates to:
  /// **'Evidências ({n})'**
  String evidenceCount(int n);

  /// No description provided for @receiptTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conferir cupom'**
  String get receiptTitle;

  /// No description provided for @receiptCheck.
  ///
  /// In pt, this message translates to:
  /// **'Conferir com o cupom fiscal'**
  String get receiptCheck;

  /// No description provided for @receiptIntro.
  ///
  /// In pt, this message translates to:
  /// **'Fotografe o cupom ou escolha uma foto. O app lê os itens no aparelho, pareia com o carrinho e mostra o preço anunciado ao lado do preço cobrado. Nada sai do celular.'**
  String get receiptIntro;

  /// No description provided for @receiptPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Fotografar cupom'**
  String get receiptPhoto;

  /// No description provided for @receiptGallery.
  ///
  /// In pt, this message translates to:
  /// **'Escolher foto'**
  String get receiptGallery;

  /// No description provided for @receiptSummary.
  ///
  /// In pt, this message translates to:
  /// **'Anunciado × cobrado'**
  String get receiptSummary;

  /// No description provided for @receiptAnnouncedCharged.
  ///
  /// In pt, this message translates to:
  /// **'Nos itens pareados: {announced} anunciados na gôndola e {charged} cobrados.'**
  String receiptAnnouncedCharged(String announced, String charged);

  /// No description provided for @receiptNoDifference.
  ///
  /// In pt, this message translates to:
  /// **'Sem diferença nos itens pareados'**
  String get receiptNoDifference;

  /// No description provided for @receiptChargedMore.
  ///
  /// In pt, this message translates to:
  /// **'Cobrado {value} a mais'**
  String receiptChargedMore(String value);

  /// No description provided for @receiptChargedLess.
  ///
  /// In pt, this message translates to:
  /// **'Cobrado {value} a menos'**
  String receiptChargedLess(String value);

  /// No description provided for @receiptSummaryNote.
  ///
  /// In pt, this message translates to:
  /// **'A comparação vale para os itens pareados. Descontos de caixa, ofertas com validade e itens por peso podem explicar uma diferença; confira as fotos antes de reclamar.'**
  String get receiptSummaryNote;

  /// No description provided for @receiptSeePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Ver a foto do cupom'**
  String get receiptSeePhoto;

  /// No description provided for @receiptSeeShelfPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Ver a foto da etiqueta'**
  String get receiptSeeShelfPhoto;

  /// No description provided for @receiptEqual.
  ///
  /// In pt, this message translates to:
  /// **'Preço igual ao anunciado'**
  String get receiptEqual;

  /// No description provided for @receiptDiffMore.
  ///
  /// In pt, this message translates to:
  /// **'Diferença: {value} a mais por unidade'**
  String receiptDiffMore(String value);

  /// No description provided for @receiptDiffLess.
  ///
  /// In pt, this message translates to:
  /// **'Diferença: {value} a menos por unidade'**
  String receiptDiffLess(String value);

  /// No description provided for @receiptSuspected.
  ///
  /// In pt, this message translates to:
  /// **'Suspeita de diferença'**
  String get receiptSuspected;

  /// No description provided for @receiptSuspectedHelp.
  ///
  /// In pt, this message translates to:
  /// **'O texto do cupom não basta para ter certeza de que é o mesmo item. Toque para confirmar ou trocar o par.'**
  String get receiptSuspectedHelp;

  /// No description provided for @receiptUnmatched.
  ///
  /// In pt, this message translates to:
  /// **'Sem par no carrinho'**
  String get receiptUnmatched;

  /// No description provided for @receiptShelfVsTill.
  ///
  /// In pt, this message translates to:
  /// **'{name}: gôndola {shelf} · cupom {till}'**
  String receiptShelfVsTill(String name, String shelf, String till);

  /// No description provided for @receiptPairTitle.
  ///
  /// In pt, this message translates to:
  /// **'Com qual item do carrinho esta linha combina?'**
  String get receiptPairTitle;

  /// No description provided for @receiptNoPair.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum (deixar sem par)'**
  String get receiptNoPair;

  /// No description provided for @receiptMissing.
  ///
  /// In pt, this message translates to:
  /// **'No carrinho e não achados no cupom'**
  String get receiptMissing;

  /// No description provided for @receiptMissingHelp.
  ///
  /// In pt, this message translates to:
  /// **'Podem ter ficado fora da foto, ter sido lidos com outro nome ou não ter passado no caixa.'**
  String get receiptMissingHelp;

  /// No description provided for @loanLineFree.
  ///
  /// In pt, this message translates to:
  /// **'{system} · {paid} pagos'**
  String loanLineFree(String system, String paid);

  /// No description provided for @loanPaidShare.
  ///
  /// In pt, this message translates to:
  /// **'Parte do principal já paga'**
  String get loanPaidShare;

  /// No description provided for @loanFreeNote.
  ///
  /// In pt, this message translates to:
  /// **'Sem parcelas nem vencimento: pago quando possível.'**
  String get loanFreeNote;

  /// No description provided for @loanSystemAmericanShort.
  ///
  /// In pt, this message translates to:
  /// **'Americano'**
  String get loanSystemAmericanShort;

  /// No description provided for @loanSystemBulletShort.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento único'**
  String get loanSystemBulletShort;

  /// No description provided for @loanSystemFreeShort.
  ///
  /// In pt, this message translates to:
  /// **'Sem parcelas'**
  String get loanSystemFreeShort;

  /// No description provided for @loanLentTag.
  ///
  /// In pt, this message translates to:
  /// **'Emprestei'**
  String get loanLentTag;

  /// No description provided for @loanDirection.
  ///
  /// In pt, this message translates to:
  /// **'Quem deve'**
  String get loanDirection;

  /// No description provided for @loanBorrowed.
  ///
  /// In pt, this message translates to:
  /// **'Eu devo'**
  String get loanBorrowed;

  /// No description provided for @loanLent.
  ///
  /// In pt, this message translates to:
  /// **'Devem a mim'**
  String get loanLent;

  /// No description provided for @loanMode.
  ///
  /// In pt, this message translates to:
  /// **'Como será pago'**
  String get loanMode;

  /// No description provided for @loanModeScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Com parcelas'**
  String get loanModeScheduled;

  /// No description provided for @loanModeFree.
  ///
  /// In pt, this message translates to:
  /// **'Quando der'**
  String get loanModeFree;

  /// No description provided for @loanModeFreeHelp.
  ///
  /// In pt, this message translates to:
  /// **'Sem número de parcelas e sem prazo. Cada pagamento é registrado quando acontece, com o valor que for.'**
  String get loanModeFreeHelp;

  /// No description provided for @loanCreditor.
  ///
  /// In pt, this message translates to:
  /// **'Credor (para quem devo)'**
  String get loanCreditor;

  /// No description provided for @loanDebtor.
  ///
  /// In pt, this message translates to:
  /// **'Devedor (quem me deve)'**
  String get loanDebtor;

  /// No description provided for @loanLentAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor que emprestei'**
  String get loanLentAmount;

  /// No description provided for @loanSystemAmerican.
  ///
  /// In pt, this message translates to:
  /// **'Americano (juros periódicos)'**
  String get loanSystemAmerican;

  /// No description provided for @loanSystemBullet.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento único no fim'**
  String get loanSystemBullet;

  /// No description provided for @loanSystemPriceHelp.
  ///
  /// In pt, this message translates to:
  /// **'Parcelas iguais; no começo quase tudo é juro.'**
  String get loanSystemPriceHelp;

  /// No description provided for @loanSystemSacHelp.
  ///
  /// In pt, this message translates to:
  /// **'Amortização igual todo mês; a parcela cai com o tempo.'**
  String get loanSystemSacHelp;

  /// No description provided for @loanSystemAmericanHelp.
  ///
  /// In pt, this message translates to:
  /// **'Todo mês paga-se só o juro sobre o valor inteiro; o principal vai junto com a última parcela.'**
  String get loanSystemAmericanHelp;

  /// No description provided for @loanSystemBulletHelp.
  ///
  /// In pt, this message translates to:
  /// **'Nada é pago até o fim do prazo; no vencimento paga-se o principal com os juros acumulados mês a mês.'**
  String get loanSystemBulletHelp;

  /// No description provided for @loanInterest.
  ///
  /// In pt, this message translates to:
  /// **'Juros'**
  String get loanInterest;

  /// No description provided for @loanInterestNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem juros'**
  String get loanInterestNone;

  /// No description provided for @loanInterestSimple.
  ///
  /// In pt, this message translates to:
  /// **'Juros simples'**
  String get loanInterestSimple;

  /// No description provided for @loanInterestCompound.
  ///
  /// In pt, this message translates to:
  /// **'Juros compostos'**
  String get loanInterestCompound;

  /// No description provided for @loanInterestNoneHelp.
  ///
  /// In pt, this message translates to:
  /// **'O saldo só muda quando há pagamento. O tempo não acrescenta nada.'**
  String get loanInterestNoneHelp;

  /// No description provided for @loanInterestSimpleHelp.
  ///
  /// In pt, this message translates to:
  /// **'Juro sobre o principal ainda devido, proporcional aos dias (mês de 30 dias). Cada pagamento cobre primeiro o juro, depois o principal.'**
  String get loanInterestSimpleHelp;

  /// No description provided for @loanInterestCompoundHelp.
  ///
  /// In pt, this message translates to:
  /// **'Juro sobre o saldo inteiro, inclusive juro não pago, proporcional aos dias (mês de 30 dias). Cada pagamento cobre primeiro o juro, depois o principal.'**
  String get loanInterestCompoundHelp;

  /// No description provided for @loanRateYear.
  ///
  /// In pt, this message translates to:
  /// **'Juros (% ao ano)'**
  String get loanRateYear;

  /// No description provided for @loanTermMonths.
  ///
  /// In pt, this message translates to:
  /// **'Prazo (meses)'**
  String get loanTermMonths;

  /// No description provided for @loanRateStated.
  ///
  /// In pt, this message translates to:
  /// **'A taxa do contrato é'**
  String get loanRateStated;

  /// No description provided for @loanRatePerMonth.
  ///
  /// In pt, this message translates to:
  /// **'Ao mês'**
  String get loanRatePerMonth;

  /// No description provided for @loanRatePerYearEffective.
  ///
  /// In pt, this message translates to:
  /// **'Ao ano, efetiva'**
  String get loanRatePerYearEffective;

  /// No description provided for @loanRatePerYearNominal.
  ///
  /// In pt, this message translates to:
  /// **'Ao ano, nominal'**
  String get loanRatePerYearNominal;

  /// No description provided for @loanRateEquivalent.
  ///
  /// In pt, this message translates to:
  /// **'Equivale a {rate}% ao mês, a taxa usada nos cálculos.'**
  String loanRateEquivalent(String rate);

  /// No description provided for @loanOriginDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de origem da dívida'**
  String get loanOriginDate;

  /// No description provided for @loanHandoverLabel.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimo concedido'**
  String get loanHandoverLabel;

  /// No description provided for @loanRegisterHandover.
  ///
  /// In pt, this message translates to:
  /// **'Registrar a saída do dinheiro da conta'**
  String get loanRegisterHandover;

  /// No description provided for @loanRegisterHandoverHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ligue se o valor saiu da conta hoje.'**
  String get loanRegisterHandoverHelp;

  /// No description provided for @loanFormErrBasic.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome e o valor.'**
  String get loanFormErrBasic;

  /// No description provided for @loanFormErrRate.
  ///
  /// In pt, this message translates to:
  /// **'Informe a taxa de juros (use vírgula para decimais).'**
  String get loanFormErrRate;

  /// No description provided for @loanFormErrTerm.
  ///
  /// In pt, this message translates to:
  /// **'Informe o número de parcelas, de 1 a 480.'**
  String get loanFormErrTerm;

  /// No description provided for @loanOwedToYou.
  ///
  /// In pt, this message translates to:
  /// **'A receber'**
  String get loanOwedToYou;

  /// No description provided for @loanFreeSummary.
  ///
  /// In pt, this message translates to:
  /// **'Valor original {principal} em {date} · {paid} já pagos'**
  String loanFreeSummary(String principal, String date, String paid);

  /// No description provided for @loanFreeInterestLine.
  ///
  /// In pt, this message translates to:
  /// **'{mode} de {rate}% ao mês · {accrued} de juros a pagar hoje · {paid} de juros já pagos'**
  String loanFreeInterestLine(
    String mode,
    String rate,
    String accrued,
    String paid,
  );

  /// No description provided for @loanFreeNoInterest.
  ///
  /// In pt, this message translates to:
  /// **'Sem juros: o saldo só muda com pagamentos.'**
  String get loanFreeNoInterest;

  /// No description provided for @loanRegisterPayment.
  ///
  /// In pt, this message translates to:
  /// **'Registrar pagamento'**
  String get loanRegisterPayment;

  /// No description provided for @loanRegisterReceipt.
  ///
  /// In pt, this message translates to:
  /// **'Registrar recebimento'**
  String get loanRegisterReceipt;

  /// No description provided for @loanSettleWith.
  ///
  /// In pt, this message translates to:
  /// **'Quitar: preencher {value}'**
  String loanSettleWith(String value);

  /// No description provided for @loanFreePayNote.
  ///
  /// In pt, this message translates to:
  /// **'O pagamento sai da conta escolhida no cadastro e não conta como despesa do mês: é devolução de dinheiro emprestado.'**
  String get loanFreePayNote;

  /// No description provided for @loanPayTooMuch.
  ///
  /// In pt, this message translates to:
  /// **'O valor é maior que o saldo da dívida nessa data ({owed}). Para quitar, registre {owed}.'**
  String loanPayTooMuch(String owed);

  /// No description provided for @loanPaymentOf.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento: {name}'**
  String loanPaymentOf(String name);

  /// No description provided for @loanReceiptOf.
  ///
  /// In pt, this message translates to:
  /// **'Recebimento: {name}'**
  String loanReceiptOf(String name);

  /// No description provided for @loanStatement.
  ///
  /// In pt, this message translates to:
  /// **'Extrato'**
  String get loanStatement;

  /// No description provided for @loanNoPaymentsYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pagamento registrado ainda.'**
  String get loanNoPaymentsYet;

  /// No description provided for @loanEventSplit.
  ///
  /// In pt, this message translates to:
  /// **'{interest} de juros · {principal} do principal · saldo {balance}'**
  String loanEventSplit(String interest, String principal, String balance);

  /// No description provided for @loanEventBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo depois: {balance}'**
  String loanEventBalance(String balance);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
