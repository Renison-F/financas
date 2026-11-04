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
  /// **'Mês {pace}'**
  String monthPace(String pace);

  /// No description provided for @paceSereno.
  ///
  /// In pt, this message translates to:
  /// **'sereno'**
  String get paceSereno;

  /// No description provided for @paceAtencao.
  ///
  /// In pt, this message translates to:
  /// **'em atenção'**
  String get paceAtencao;

  /// No description provided for @paceAgitado.
  ///
  /// In pt, this message translates to:
  /// **'agitado'**
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
  /// **'Tudo sereno por aqui.'**
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
  /// **'{n} itens'**
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
  /// **'Pedir biometria ao abrir'**
  String get biometricLock;

  /// No description provided for @biometricAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Face ID / impressão digital do aparelho.'**
  String get biometricAvailable;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma biometria configurada neste aparelho.'**
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
  /// **'Seus dados ficam só neste aparelho. Faça backups em Mais → Exportar.'**
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
  /// **'Seu dinheiro em paz.'**
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
