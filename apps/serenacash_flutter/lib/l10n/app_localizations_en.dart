// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SerenaCash';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTransactions => 'Transactions';

  @override
  String get tabShopping => 'Shopping';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabMore => 'More';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get showValues => 'Show amounts';

  @override
  String get hideValues => 'Hide amounts';

  @override
  String get customizeHome => 'Customize home screen';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get noWidgetsVisible =>
      'No widgets visible. Tap the gear to choose what to see.';

  @override
  String get widgetLoadError => 'Could not load';

  @override
  String get tapToRetry => 'Tap to try again.';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get edit => 'Edit';

  @override
  String get seeAll => 'See all';

  @override
  String get see => 'See';

  @override
  String get all => 'All';

  @override
  String get new_ => 'New';

  @override
  String get newF => 'New';

  @override
  String get add => 'Add';

  @override
  String get register => 'Record';

  @override
  String get details => 'Details';

  @override
  String get ok => 'OK';

  @override
  String get loadingError => 'Could not open your data.';

  @override
  String get unlockTitle => 'Locked';

  @override
  String get unlockText => 'Confirm your identity to see your data.';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlockPrompt => 'Unlock SerenaCash';

  @override
  String get biometricFailed => 'Could not confirm your identity.';

  @override
  String get biometricUnavailable => 'Biometrics unavailable on this device.';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinWrong => 'Wrong PIN.';

  @override
  String get usePin => 'Use PIN';

  @override
  String get useBiometrics => 'Use biometrics';

  @override
  String canSpendUntil(String date) {
    return 'Can spend until $date';
  }

  @override
  String get canSpendTitle => 'Can spend';

  @override
  String get startWithAccount => 'Start with your account';

  @override
  String get startWithAccountText =>
      'With one account balance the app already shows how much fits.';

  @override
  String get addAccount => 'Add account';

  @override
  String get availNegative => 'Registered bills exceed the money available.';

  @override
  String get availTight => 'It\'s tight: what\'s left barely covers the bills.';

  @override
  String get availOk =>
      'An estimate from what is recorded, not a guaranteed balance.';

  @override
  String get modeOptimistic => 'Optimistic mode';

  @override
  String get modePrudent => 'Prudent mode';

  @override
  String get howWeCalculate => 'How we calculate ›';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get accounts => 'Accounts';

  @override
  String get noAccount => 'No account';

  @override
  String get balancesByAccount => 'Balances by account';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String plannedLabel(String value) {
    return 'Planned: $value';
  }

  @override
  String plannedAndCard(String planned, String card) {
    return 'Planned: $planned · on card: $card';
  }

  @override
  String get billsToPay => 'Bills to pay';

  @override
  String get bill => 'Bill';

  @override
  String dueOn(String date) {
    return 'due $date';
  }

  @override
  String duePast(String date) {
    return 'was due $date';
  }

  @override
  String get nothingToPay => 'Nothing to pay until the end of the period';

  @override
  String get nothingToPayText =>
      'Register planned bills so \'can spend\' stays honest.';

  @override
  String get newBillToPay => 'New bill to pay';

  @override
  String get overdueBills => 'Overdue bills';

  @override
  String get noOverdue => 'No overdue bills.';

  @override
  String get next7days => 'Next 7 days';

  @override
  String get calendar => 'Calendar';

  @override
  String get noDueNext7 => 'Nothing due in the next 7 days.';

  @override
  String get cardsAndInvoices => 'Cards and statements';

  @override
  String invoiceLine(String state, String date, String free) {
    return 'Statement $state · due $date · free limit $free';
  }

  @override
  String get invoiceOpen => 'open';

  @override
  String get invoiceClosed => 'closed';

  @override
  String get invoicePaid => 'paid';

  @override
  String get invoiceOverdue => 'overdue';

  @override
  String get invoiceFuture => 'future';

  @override
  String limitCommitted(int percent) {
    return '$percent% of limit committed';
  }

  @override
  String get noCard => 'No card';

  @override
  String get noCardText =>
      'Register closing and due days to track the statement.';

  @override
  String get addCard => 'Add card';

  @override
  String get installmentPurchases => 'Installment purchases';

  @override
  String get committedFuture => 'committed in future statements';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get budgets => 'Budgets';

  @override
  String ofLimit(String value) {
    return 'of $value';
  }

  @override
  String monthPace(String pace) {
    return 'Spending $pace';
  }

  @override
  String get paceSereno => 'within plan';

  @override
  String get paceAtencao => 'slightly above plan';

  @override
  String get paceAgitado => 'above plan';

  @override
  String get general => 'General';

  @override
  String get noBudgetYet => 'No budget yet';

  @override
  String get noBudgetText =>
      'Set a monthly limit and follow the pace with today\'s mark.';

  @override
  String get createBudget => 'Create budget';

  @override
  String get spendingByCategory => 'Spending by category';

  @override
  String get report => 'Report';

  @override
  String get noExpensesMonth => 'No expenses this month';

  @override
  String get registerExpense => 'Record expense';

  @override
  String get evolution => 'Evolution';

  @override
  String get cashflow => 'Cash flow';

  @override
  String get noHistory => 'No history yet';

  @override
  String get noHistoryText =>
      'Record income and expenses to see the evolution.';

  @override
  String incomeOf(String month, String value) {
    return 'Income $month: $value';
  }

  @override
  String expensesOf(String month, String value) {
    return 'Expenses $month: $value';
  }

  @override
  String get goals => 'Goals';

  @override
  String get noGoal => 'No goal';

  @override
  String get noGoalText => 'An emergency fund is a good start.';

  @override
  String get createGoal => 'Create goal';

  @override
  String get reserves => 'Reserves';

  @override
  String get reservesText => 'set aside and outside \"can spend\"';

  @override
  String get monthlySavings => 'Savings this month';

  @override
  String get registerIncomeForRate => 'Record income to see the savings rate.';

  @override
  String percentOfIncome(int percent) {
    return '$percent% of income';
  }

  @override
  String get subscriptions => 'Subscriptions and recurring';

  @override
  String monthsInARow(int n) {
    return '$n months in a row';
  }

  @override
  String get noRecurring => 'No recurring expense detected yet.';

  @override
  String get loans => 'Loans';

  @override
  String nextInstallment(String date, String value) {
    return 'next $date · $value';
  }

  @override
  String get paidOff => 'paid off';

  @override
  String get noLoan => 'No loan';

  @override
  String get registerLoan => 'Register';

  @override
  String get open => 'Open';

  @override
  String calendarSummary(int n, String date) {
    return '$n due date(s) until $date';
  }

  @override
  String overdueCount(int n) {
    return ' · $n overdue';
  }

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get allLabel => 'All';

  @override
  String get planned => 'planned';

  @override
  String get noTransaction => 'No transaction';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get assistant => 'Assistant';

  @override
  String get allCalm => 'No alerts right now.';

  @override
  String get shoppingLists => 'Shopping lists';

  @override
  String listCount(int n) {
    return '$n list(s)';
  }

  @override
  String get noListYet => 'No list yet.';

  @override
  String get createList => 'Create list';

  @override
  String get shoppingAssistant => 'Supermarket assistant';

  @override
  String sessionsCount(int n) {
    return '$n purchase(s) recorded';
  }

  @override
  String get shoppingAssistantText =>
      'Read price tags and barcodes and see the total before checkout.';

  @override
  String get startShopping => 'Start shopping';

  @override
  String get continueShopping => 'Continue shopping';

  @override
  String get advancedIndicators => 'Advanced indicators';

  @override
  String get methodology => 'Methodology';

  @override
  String get savingRate => 'Savings rate (month)';

  @override
  String get committedIncome => 'Committed income (cards + installment)';

  @override
  String get netWorth => 'Net worth';

  @override
  String get indicatorsDisclaimer =>
      'Calculations over recorded data; not financial advice.';

  @override
  String get kindIncome => 'Income';

  @override
  String get kindExpense => 'Expense';

  @override
  String get kindTransfer => 'Transfer';

  @override
  String get kindCardPurchase => 'Card purchase';

  @override
  String get kindCardPayment => 'Statement payment';

  @override
  String get kindGoalDeposit => 'Deposit to reserve';

  @override
  String get kindGoalWithdrawal => 'Withdrawal from reserve';

  @override
  String get kindLoanDisbursement => 'Loan disbursement';

  @override
  String get kindLoanPayment => 'Loan installment';

  @override
  String get kindBalanceAdjustment => 'Balance adjustment';

  @override
  String get kindCardRefund => 'Card refund';

  @override
  String get customizeTitle => 'Home screen';

  @override
  String get presets => 'Presets';

  @override
  String get restoreDefault => 'Restore default';

  @override
  String get visibleWidgets => 'Visible (hold and drag, or use the arrows)';

  @override
  String get hiddenWidgets => 'Hidden';

  @override
  String moveUp(String name) {
    return 'Move $name up';
  }

  @override
  String moveDown(String name) {
    return 'Move $name down';
  }

  @override
  String hideWidget(String name) {
    return 'Hide $name';
  }

  @override
  String showWidget(String name) {
    return 'Show $name';
  }

  @override
  String get indicatorsPeriod => 'Indicators period';

  @override
  String get currentMonth => 'Current month';

  @override
  String get next30days => 'Next 30 days';

  @override
  String get accountsConsidered => 'Accounts considered';

  @override
  String availableSubtitle(String date, String mode) {
    return 'Until $date · $mode mode';
  }

  @override
  String get estimateDisclaimer =>
      'An estimate from what you recorded. Not a guaranteed balance.';

  @override
  String get theMath => 'The math';

  @override
  String get equalsCanSpend => '= Can spend';

  @override
  String get adjustments => 'Adjustments';

  @override
  String get includePlannedIncome => 'Count planned income';

  @override
  String get includePlannedIncomeHelp =>
      'On = optimistic mode: counts money that has not arrived yet.';

  @override
  String get horizon => 'Horizon';

  @override
  String get untilMonthEnd => 'Until month end';

  @override
  String get safetyCushion => 'Safety cushion';

  @override
  String get none => 'None';

  @override
  String get cushionHelp =>
      'Money you prefer never to touch; it leaves \"can spend\".';

  @override
  String get rules => 'Rules';

  @override
  String get availabilityRules =>
      'Only accounts marked for the calculation and settled money count. Out: planned bills until the horizon (including overdue), closed card statements and the open statement, reserves kept inside accounts and the cushion. Card purchases never count twice: the purchase is an expense on its date; paying the statement only moves money.';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get inflow => 'In';

  @override
  String get outflow => 'Out';

  @override
  String get result => 'Result';

  @override
  String get searchTransactions => 'Search by description, merchant or note';

  @override
  String get filterAll => 'All';

  @override
  String get filterCard => 'Card';

  @override
  String get filterTransfers => 'Transfers';

  @override
  String get filterPlanned => 'Planned';

  @override
  String paidPart(String value) {
    return 'paid $value';
  }

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get tryAnotherWord => 'Try another word.';

  @override
  String get noTransactionMonth => 'No transaction this month';

  @override
  String get registerWithPlus =>
      'Record an expense or income with the + button.';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get transaction => 'Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get descHintIncome => 'E.g. Salary';

  @override
  String get descHintTransfer => 'E.g. To savings';

  @override
  String get descHintExpense => 'E.g. Groceries';

  @override
  String get category => 'Category';

  @override
  String get card => 'Card';

  @override
  String get registerCard => 'Register card';

  @override
  String get account => 'Account';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get registerAccount => 'Register account';

  @override
  String get dueDate => 'Due date';

  @override
  String get date => 'Date';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get invalidDate => 'Invalid date (dd/mm/yyyy)';

  @override
  String get notReceivedYet => 'Not received yet (planned)';

  @override
  String get notPaidYet => 'Not paid yet (planned)';

  @override
  String get plannedHelp =>
      'Planned transactions go to \'bills to pay\' and into the \'can spend\' calculation.';

  @override
  String get installments => 'Installments';

  @override
  String get cashPayment => 'Single payment';

  @override
  String installmentsHelp(int n, String value) {
    return '${n}x of $value (cents adjusted in the first installments), one per statement.';
  }

  @override
  String get moreOptions => 'More options';

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatHelp =>
      'Creates a series; the next 3 months become planned and new ones are generated automatically.';

  @override
  String get tags => 'Tags';

  @override
  String get merchant => 'Merchant';

  @override
  String get optional => 'Optional';

  @override
  String get notes => 'Notes';

  @override
  String get attachmentsPlus =>
      'Attachments and receipts are part of SerenaCash Plus.';

  @override
  String get attachmentsAfterSave =>
      'Attachments: add from the transaction detail after saving.';

  @override
  String get attachments => 'Attachments';

  @override
  String get addAttachment => 'Attach receipt';

  @override
  String get payment => 'Payment';

  @override
  String get markReceived => 'Mark as received';

  @override
  String get markPaid => 'Mark as paid';

  @override
  String payPart(String value) {
    return 'Pay part (remaining $value)';
  }

  @override
  String get registerPartial => 'Record partial payment';

  @override
  String get deleteThisAndNext => 'Delete this and the next';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String get deleteTransactionQ => 'Delete transaction?';

  @override
  String get deleteSeriesText =>
      'Transactions of this series from this date on will be deleted. You can undo right after.';

  @override
  String get deleteOneText => 'You can undo right after.';

  @override
  String get deletedOne => 'Transaction deleted';

  @override
  String deletedMany(int n) {
    return '$n transactions deleted';
  }

  @override
  String get errAmount => 'Enter an amount greater than zero.';

  @override
  String get errCardFirst =>
      'Register a card before recording a card purchase.';

  @override
  String get errAccountFirst => 'Register an account before recording.';

  @override
  String get errTwoAccounts => 'Choose two different accounts.';

  @override
  String get errSave => 'Could not save.';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyBiweekly => 'Every two weeks';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get planTitle => 'Plan';

  @override
  String get planSubtitle => 'Budgets, goals, cards and loans';

  @override
  String get noBudget => 'No budget';

  @override
  String get noBudgetPlanText =>
      'Set limits per category or for the whole month.';

  @override
  String get goalsAndReserves => 'Goals and reserves';

  @override
  String goalLine(int percent, String remaining) {
    return '$percent% · $remaining to go';
  }

  @override
  String perMonth(String value) {
    return ' · $value/month';
  }

  @override
  String get noGoalPlanText => 'Start with an emergency fund.';

  @override
  String get cards => 'Cards';

  @override
  String cardLine(String state, String date, String free) {
    return 'statement $state · due $date · free $free';
  }

  @override
  String get loansAndDebts => 'Loans and debts';

  @override
  String loanLine(String date, String value, int paid, int total) {
    return 'next $date · $value · $paid/$total paid';
  }

  @override
  String get noLoanRegistered => 'No loan registered.';

  @override
  String get balanceProjection => 'Balance projection';

  @override
  String get projectionText =>
      'See how the balance evolves with planned bills and income until month end.';

  @override
  String get moreTitle => 'More';

  @override
  String get freePlan => 'Free plan';

  @override
  String get groupMoney => 'My money';

  @override
  String get accountsWallets => 'Accounts and wallets';

  @override
  String get accountsWalletsDesc => 'Balances, adjustments, archiving';

  @override
  String get categoriesTags => 'Categories and tags';

  @override
  String get categoriesTagsDesc => 'Organize your transactions';

  @override
  String get financialCalendar => 'Financial calendar';

  @override
  String get financialCalendarDesc => 'Due dates and receipts';

  @override
  String get billsDesc => 'Planned, overdue, partial';

  @override
  String get groupAnalysis => 'Analysis';

  @override
  String get reports => 'Reports';

  @override
  String get reportsDesc => 'Cash flow, categories, comparisons, projections';

  @override
  String get financialAssistant => 'Financial assistant';

  @override
  String get financialAssistantDesc => 'Ask about your money';

  @override
  String get groupData => 'Data';

  @override
  String get importData => 'Import CSV or OFX';

  @override
  String get importDesc => 'With review and no duplicates';

  @override
  String get exportBackup => 'Export and backup';

  @override
  String get exportDesc => 'CSV, PDF and full backup';

  @override
  String get groupAccount => 'Account';

  @override
  String get plusTitle => 'SerenaCash Plus';

  @override
  String get plusDesc => 'Plans, subscription and restore';

  @override
  String get settings => 'Settings';

  @override
  String get settingsDesc => 'Theme, currency, privacy, biometrics';

  @override
  String get privacyData => 'Privacy and data';

  @override
  String get privacyDataDesc => 'Export or erase everything';

  @override
  String get help => 'Help';

  @override
  String get helpDesc => 'How the app calculates things';

  @override
  String footerLocal(String version) {
    return 'SerenaCash · data kept on this device · version $version';
  }

  @override
  String get shoppingTitle => 'Shopping';

  @override
  String get shoppingSubtitle => 'Lists and supermarket assistant';

  @override
  String get shoppingInProgress => 'Shopping in progress';

  @override
  String sessionLine(int n, String total) {
    return '$n item(s) · $total';
  }

  @override
  String get shoppingIntro =>
      'Read price tags and barcodes, see the total and how much still fits the budget before checkout.';

  @override
  String get lists => 'Lists';

  @override
  String itemsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String estimated(String value) {
    return 'estimated $value';
  }

  @override
  String get noPricesYet => 'no prices yet';

  @override
  String withoutPrice(int n) {
    return ' ($n without price)';
  }

  @override
  String get noList => 'No list';

  @override
  String get noListText =>
      'Build the list at home and use it in the store, even offline.';

  @override
  String get previousPurchases => 'Previous purchases';

  @override
  String get supermarket => 'Supermarket';

  @override
  String get registered => 'recorded';

  @override
  String get previousPurchasesText =>
      'Finished purchases show up here, with price history per store.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Automatic';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get privacyModeHelp =>
      'Shows R\$ •••• on every screen until you turn it off.';

  @override
  String get haptics => 'Vibrate on confirm';

  @override
  String get money => 'Money';

  @override
  String get currency => 'Currency';

  @override
  String get currencyHelp =>
      'The currency applies to new transactions. Format and language follow the device (pt-BR by default).';

  @override
  String get availabilityHorizon => '\"Can spend\" horizon';

  @override
  String get monthEnd => 'Month end';

  @override
  String get days30 => '30 days';

  @override
  String get security => 'Security';

  @override
  String get biometricLock => 'Ask for device confirmation on open';

  @override
  String get biometricAvailable =>
      'Fingerprint, face or the device screen lock.';

  @override
  String get biometricNotAvailable =>
      'No biometrics enrolled; the confirmation uses the device screen lock.';

  @override
  String get pinLock => 'Protect with PIN';

  @override
  String get pinLockHelp =>
      '4 to 8 digit PIN, stored protected; it never leaves the device.';

  @override
  String get setPin => 'Set PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinMismatch => 'PINs do not match.';

  @override
  String get pinFormat => 'Use 4 to 8 digits.';

  @override
  String get lockOnBackground => 'Lock when returning from background';

  @override
  String get dataLocalHelp =>
      'Your data stays only on this device. Make backups in the menu, under Export and backup.';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersText =>
      'Local notice the day before and on the due date of planned bills (next 7 days). Nothing leaves the device.';

  @override
  String get enableReminders => 'Enable due-date reminders';

  @override
  String get remindersEnabled => 'Reminders enabled.';

  @override
  String get remindersDenied =>
      'Notification permission denied or unavailable.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Device';

  @override
  String get onbWelcomeTitle => 'Know how much you can spend.';

  @override
  String get onbWelcomeText =>
      'In under two minutes you\'ll know how much you can spend without compromising your bills. No sign-up, no bank password: everything stays on your device.';

  @override
  String get onbStart => 'Start';

  @override
  String get onbAccountTitle => 'How much do you have now?';

  @override
  String get onbAccountText => 'It can be approximate. You adjust later.';

  @override
  String get accountName => 'Account name';

  @override
  String get mainAccount => 'Main account';

  @override
  String get typeBank => 'Bank';

  @override
  String get typeDigital => 'Digital';

  @override
  String get typeCash => 'Cash';

  @override
  String get typeSavings => 'Savings';

  @override
  String get balanceToday => 'Balance today';

  @override
  String get onbBillsTitle => 'Fixed bills this month';

  @override
  String get onbBillsText =>
      'Tap the ones you pay and enter the amount. They become planned and repeat every month.';

  @override
  String get fixedRent => 'Rent';

  @override
  String get fixedPower => 'Electricity';

  @override
  String get fixedInternet => 'Internet';

  @override
  String get fixedPhone => 'Mobile';

  @override
  String get fixedWater => 'Water';

  @override
  String get onbCardTitle => 'Do you use a credit card?';

  @override
  String get onbCardText =>
      'With closing and due days the app shows the right statement and never counts a purchase twice.';

  @override
  String get name => 'Name';

  @override
  String get limit => 'Limit';

  @override
  String get closingDay => 'Closing day';

  @override
  String get dueDay => 'Due day';

  @override
  String get continue_ => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'Finish';

  @override
  String get undoToastHint => 'Tap to undo';

  @override
  String get accountsTitle => 'Accounts and wallets';

  @override
  String get consolidatedBalance => 'Consolidated balance';

  @override
  String get transfersDontChange =>
      'Transfers between accounts do not change the total.';

  @override
  String get active => 'Active';

  @override
  String get archivedF => 'Archived';

  @override
  String get typeCashL => 'Cash';

  @override
  String get typeCheckingL => 'Bank account';

  @override
  String get typeSavingsL => 'Savings';

  @override
  String get typeDigitalL => 'Digital wallet';

  @override
  String get typeInvestmentL => 'Investment';

  @override
  String get typeOtherL => 'Other';

  @override
  String get outOfAvailability => ' · outside can spend';

  @override
  String get accountNotFound => 'Account not found';

  @override
  String get currentBalance => 'Current balance';

  @override
  String openingBalanceLine(String value, String date) {
    return 'Opening balance $value on $date';
  }

  @override
  String get archivedSuffix => ' · archived';

  @override
  String get history => 'History';

  @override
  String get noMovements => 'No movements';

  @override
  String get reactivateAccount => 'Reactivate account';

  @override
  String get archiveAccount => 'Archive account';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get archiveAccountQ => 'Archive account?';

  @override
  String get archiveAccountText =>
      'It disappears from lists and \'can spend\', but the history stays. You can reactivate later.';

  @override
  String get archive => 'Archive';

  @override
  String get deleteAccountQ => 'Delete account?';

  @override
  String get deleteAccountText =>
      'Only accounts without transactions can be deleted. If there are movements, archive it.';

  @override
  String get accountHasTransactions =>
      'This account has transactions. Archive it or move the transactions before deleting.';

  @override
  String get editAccount => 'Edit account';

  @override
  String get newAccount => 'New account';

  @override
  String get accountNameHint => 'E.g. Nubank, Wallet';

  @override
  String get type => 'Type';

  @override
  String get openingBalanceOnDate => 'Opening balance (on the date below)';

  @override
  String get openingHelpEdit =>
      'To correct today\'s balance, use the adjustment below.';

  @override
  String get openingHelpNew =>
      'Today\'s balance becomes the account\'s opening balance.';

  @override
  String get openingDate => 'Opening balance date';

  @override
  String get includeInAvailability => 'Count in \"can spend\"';

  @override
  String get includeHelp =>
      'Turn off for reserves, investments or accounts you don\'t use daily.';

  @override
  String get color => 'Color';

  @override
  String get adjustBalance => 'Adjust balance';

  @override
  String adjustHelp(String value) {
    return 'Calculated balance today: $value. Enter the real balance and the app creates an adjustment with the difference (reconciliation).';
  }

  @override
  String get realBalanceToday => 'Real balance today';

  @override
  String get registerAdjustment => 'Record adjustment';

  @override
  String get balanceAdjustment => 'Balance adjustment';

  @override
  String get nameAccountErr => 'Give the account a name.';

  @override
  String freeLimitAccounts(int n) {
    return 'Free plan: up to $n accounts. Unlimited accounts in SerenaCash Plus.';
  }

  @override
  String get newCategory => 'New category';

  @override
  String get categoryNameHint => 'E.g. Delivery';

  @override
  String get subcategoryOf => 'Subcategory of (optional)';

  @override
  String get expenseCategories => 'Expense categories';

  @override
  String get incomeCategories => 'Income categories';

  @override
  String get reactivate => 'Reactivate';

  @override
  String get archivedLower => 'archived';

  @override
  String get tagsHelp =>
      'Tags mark transactions across categories (e.g. trip, reimbursable).';

  @override
  String get newTag => 'New tag';

  @override
  String get tagHint => 'E.g. trip';

  @override
  String get creditCards => 'Credit cards';

  @override
  String closesDueDays(int closing, int due) {
    return 'closes day $closing · due day $due';
  }

  @override
  String cardSummary(String month, String state, String free, String limit) {
    return 'Statement $month ($state) · free limit $free of $limit';
  }

  @override
  String get noCardListText =>
      'With closing and due days the app shows the right statement.';

  @override
  String get cardNotFound => 'Card not found';

  @override
  String get previousInvoice => 'Previous statement';

  @override
  String get nextInvoice => 'Next statement';

  @override
  String invoiceOf(String label) {
    return 'Statement $label';
  }

  @override
  String invoiceState(String state) {
    return 'Statement $state';
  }

  @override
  String closesOn(String date) {
    return 'closes $date';
  }

  @override
  String totalPaid(String total, String paid) {
    return 'Total $total · paid $paid';
  }

  @override
  String get limitCommittedLabel => 'Limit committed';

  @override
  String limitBreakdown(
    String free,
    String limit,
    String current,
    String closed,
    String future,
  ) {
    return 'Free limit $free of $limit (current statement $current + closed $closed + future $future)';
  }

  @override
  String get purchasesThisInvoice => 'Purchases in this statement';

  @override
  String get newPurchase => 'New purchase';

  @override
  String get purchase => 'Purchase';

  @override
  String installmentOf(int n, int of) {
    return ' · installment $n/$of';
  }

  @override
  String get noPurchasesInvoice => 'No purchases in this statement.';

  @override
  String get payments => 'Payments';

  @override
  String get payInvoice => 'Pay statement';

  @override
  String get payInvoiceHelp =>
      'The payment leaves the account and reduces the statement. It is not an expense again: purchases already counted when they happened.';

  @override
  String totalOf(String value) {
    return 'Total $value';
  }

  @override
  String get minimum15 => 'Minimum (15%)';

  @override
  String get paymentDate => 'Payment date';

  @override
  String get registerPayment => 'Record payment';

  @override
  String get invoiceHistory => 'Statement history';

  @override
  String get noInvoicesYet => 'No statements yet.';

  @override
  String invoiceRule(int day) {
    return 'Rule: purchases up to day $day go into the month\'s statement; after that, into the next. Installments fall one per statement.';
  }

  @override
  String invoicePaymentDesc(String label) {
    return 'Statement payment $label';
  }

  @override
  String get editCard => 'Edit card';

  @override
  String get newCard => 'New card';

  @override
  String get cardNameHint => 'E.g. Purple card';

  @override
  String get closingHelp =>
      'Purchases after this day go to the next statement.';

  @override
  String get paymentAccount => 'Account used to pay the statement';

  @override
  String get nameCardErr => 'Give the card a name.';

  @override
  String get daysRangeErr => 'Closing and due days must be between 1 and 31.';

  @override
  String get closingChangeErr =>
      'The closing day of a card with purchases cannot change: statements would move months. Create another card.';

  @override
  String freeLimitCards(int n) {
    return 'Free plan: $n card. Unlimited cards in SerenaCash Plus.';
  }

  @override
  String get committedPerInvoice => 'Committed per statement';

  @override
  String installmentsCount(int n) {
    return '$n installment(s)';
  }

  @override
  String get noFutureInstallments => 'No future installments';

  @override
  String get perPurchase => 'Per purchase';

  @override
  String get installmentPurchase => 'Installment purchase';

  @override
  String pastInvoicesRemaining(int paid, int of, String value) {
    return '$paid/$of past statements · $value remaining';
  }

  @override
  String get noInstallmentPurchase => 'No installment purchase.';

  @override
  String plannedSuffix(String value) {
    return ' · $value planned';
  }

  @override
  String paceUsed(String pace, int used, int expected) {
    return '$pace · $used% used, $expected% of month';
  }

  @override
  String get noBudgetListText =>
      'Set a limit for a category or the whole month. Today\'s mark shows whether spending follows what is planned for the day.';

  @override
  String get budgetRules =>
      'Within plan: spending up to today\'s mark. Slightly above: up to 10 points beyond the mark. Above plan: beyond that or over the limit. Subcategories add up into the parent category budget.';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get newBudget => 'New budget';

  @override
  String get forLabel => 'For';

  @override
  String get wholeMonth => 'The whole month';

  @override
  String get monthlyLimit => 'Monthly limit';

  @override
  String get onlyThisMonth => 'Only this month';

  @override
  String get onlyThisMonthHelp =>
      'Off = applies every month until you change it.';

  @override
  String get limitErr => 'Enter the limit.';

  @override
  String freeLimitBudgets(int n) {
    return 'Free plan: up to $n budgets. Unlimited in SerenaCash Plus.';
  }

  @override
  String get deleteBudget => 'Delete budget';

  @override
  String get deleteBudgetQ => 'Delete budget?';

  @override
  String get deleteBudgetText => 'Transactions are not affected.';

  @override
  String get goalKindSavings => 'Savings';

  @override
  String get goalKindEmergency => 'Emergency fund';

  @override
  String get goalKindPurchase => 'Purchase';

  @override
  String get goalKindDebt => 'Pay off debt';

  @override
  String get goalKindOther => 'Other';

  @override
  String get protectedSuffix => ' · protected';

  @override
  String untilDate(String date) {
    return ' · until $date';
  }

  @override
  String goalSummary(int percent, String target, String remaining) {
    return '$percent% of $target · $remaining to go';
  }

  @override
  String saveMonthly(String value, int months) {
    return ' · save $value/month ($months months)';
  }

  @override
  String suggestionMonthly(String value) {
    return ' · suggestion $value/month';
  }

  @override
  String get deposit => 'Save';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get noGoalListText =>
      'An emergency fund with 3 months of expenses is a great first goal.';

  @override
  String get goalNotFound => 'Goal not found';

  @override
  String get saved => 'Saved';

  @override
  String get leavesAccount => 'Leaves the account';

  @override
  String get goesToAccount => 'Goes to the account';

  @override
  String get movements => 'Movements';

  @override
  String get noMovementsYet => 'No movements yet.';

  @override
  String depositDesc(String name) {
    return 'Saved: $name';
  }

  @override
  String withdrawDesc(String name) {
    return 'Withdrawal: $name';
  }

  @override
  String get editGoal => 'Edit goal';

  @override
  String get newGoal => 'New goal';

  @override
  String get goalNameHint => 'E.g. Emergency fund';

  @override
  String get goalAmount => 'Goal amount';

  @override
  String get hasDeadline => 'Has a deadline';

  @override
  String get untilWhen => 'Until when';

  @override
  String get whereMoney => 'Where the money is';

  @override
  String get outsideApp => 'Outside the app\'s accounts';

  @override
  String get whereMoneyHelp =>
      'If kept inside an account counted in \"can spend\", the saved amount is deducted from it.';

  @override
  String get protectFromAvail => 'Protect from \"can spend\"';

  @override
  String get protectHelp => 'The saved amount never shows as available.';

  @override
  String get archiveGoal => 'Archive goal';

  @override
  String get nameGoalErr => 'Give the goal a name.';

  @override
  String get goalAmountErr => 'Enter the goal amount.';

  @override
  String freeLimitGoals(int n) {
    return 'Free plan: up to $n goals. Unlimited in SerenaCash Plus.';
  }

  @override
  String loanLineList(String system, String rate, int paid, int total) {
    return '$system · $rate% p.m. · $paid/$total paid';
  }

  @override
  String overdueInstallments(int n) {
    return ' · $n overdue';
  }

  @override
  String get installmentsPaid => 'Installments paid';

  @override
  String nextAndPayoff(String value, String date, String payoff) {
    return 'Next: $value on $date · pay off today ≈ $payoff';
  }

  @override
  String get paidOffCap => 'Paid off';

  @override
  String get noLoanListText =>
      'Register financing, credit or debts to see outstanding balance, interest and payoff simulation.';

  @override
  String get loanNotFound => 'Loan not found';

  @override
  String get outstanding => 'Outstanding balance';

  @override
  String paidSummary(int paid, int total, String value) {
    return '$paid of $total installments paid · $value paid';
  }

  @override
  String extraPaid(String value) {
    return ' ($value beyond installments)';
  }

  @override
  String payoffToday(String value) {
    return 'Pay off today ≈ $value (present value of remaining installments at the contract rate, no fees)';
  }

  @override
  String overdueInstallmentsMsg(int n) {
    return '$n overdue installment(s).';
  }

  @override
  String get simulateExtra => 'Simulate extra payment';

  @override
  String get extraAmount => 'Extra amount';

  @override
  String get reduceTerm => 'Reduce term';

  @override
  String get reduceInstallment => 'Reduce installment';

  @override
  String get paysOffLoan => 'Pays off the loan.';

  @override
  String newTerm(int n, String value, int before) {
    return 'New term: $n installments of $value (before $before).';
  }

  @override
  String newInstallment(String value, int n) {
    return 'New installment: $value for $n months.';
  }

  @override
  String get registerExtra => 'Record extra payment';

  @override
  String amortization(String name) {
    return 'Amortization: $name';
  }

  @override
  String get table => 'Schedule';

  @override
  String get editLoan => 'Edit loan';

  @override
  String get newLoan => 'New loan';

  @override
  String get loanNameHint => 'E.g. Car financing';

  @override
  String get borrowed => 'Amount borrowed';

  @override
  String get monthlyRate => 'Interest (% per month)';

  @override
  String get system => 'System';

  @override
  String get priceSystem => 'Price (fixed installment)';

  @override
  String get sacSystem => 'SAC (decreasing)';

  @override
  String get firstDue => 'First due date';

  @override
  String get monthlyFee => 'Monthly fee/insurance (optional)';

  @override
  String get registerDisbursement => 'Record the money entering the account';

  @override
  String get registerDisbursementHelp =>
      'Turn on if the amount landed in the account today.';

  @override
  String get createInstallments => 'Create installments as planned bills';

  @override
  String get createInstallmentsHelp =>
      'They go into \'bills to pay\' and \'can spend\' month by month.';

  @override
  String get preview => 'Preview';

  @override
  String previewLine(int n, String first) {
    return '$n installments · first $first';
  }

  @override
  String lastInstallment(String value) {
    return ' · last $value';
  }

  @override
  String totalInterestCost(String interest, String cost) {
    return 'Total interest $interest · total cost $cost';
  }

  @override
  String get loanAssumptions =>
      'Assumptions: nominal monthly rate on the outstanding balance; rounding per installment; taxes and insurance only if entered.';

  @override
  String get loanFormErr =>
      'Fill in name, amount, rate (% per month) and term.';

  @override
  String get disbursementLabel => 'Disbursement';

  @override
  String dayItems(String day, int n) {
    return '$day: $n transaction(s)';
  }

  @override
  String get nothingThisDay => 'Nothing on this day.';

  @override
  String dayTotal(String value) {
    return 'Day result: $value';
  }

  @override
  String get thisMonth => 'This month';

  @override
  String get days90 => '90 days';

  @override
  String overdueTotal(String value) {
    return 'Overdue · $value';
  }

  @override
  String get pay => 'Pay';

  @override
  String dueUntil(String date, String value) {
    return 'Due until $date · $value';
  }

  @override
  String alreadyPaid(String value) {
    return ' · already paid $value';
  }

  @override
  String get nothingDuePeriod => 'Nothing due in the period';

  @override
  String get billsHelp =>
      '\"Pay\" marks as paid today on the transaction\'s account. To pay part, open the transaction.';

  @override
  String get cashflowReport => 'Cash flow';

  @override
  String get cashflowDesc =>
      'Income, expenses and balance month by month; monthly and yearly comparison';

  @override
  String get categoriesDesc => 'Where the money went, with filters';

  @override
  String get recurringReport => 'Recurring expenses';

  @override
  String get recurringDesc => 'Subscriptions and repeating bills';

  @override
  String get projectionDesc => 'How the balance evolves with what is planned';

  @override
  String get indicatorsReport => 'Indicators and net worth';

  @override
  String get indicatorsDesc => 'Savings rate, commitment, net worth';

  @override
  String get exportHint =>
      'CSV and PDF export in the menu, under Export and backup.';

  @override
  String get months6 => '6 months';

  @override
  String get months12 => '12 months';

  @override
  String get incomeVsExpenses => 'Income × expenses';

  @override
  String get monthByMonth => 'Month by month';

  @override
  String balanceShort(String value) {
    return 'balance $value';
  }

  @override
  String get compareWithPrevious => 'Comparison with previous month';

  @override
  String yearLabel(int year) {
    return 'Year $year';
  }

  @override
  String bestWorst(String best, String worst) {
    return 'Best month: $best · worst: $worst';
  }

  @override
  String get groupSubcategories => 'Group subcategories';

  @override
  String get includePlanned => 'Include planned';

  @override
  String totalLabel(String value) {
    return 'Total $value';
  }

  @override
  String transactionsCount(int n) {
    return '$n transaction(s)';
  }

  @override
  String get seeMonthTransactions => 'See month\'s transactions';

  @override
  String get plusFeature => 'SerenaCash Plus feature';

  @override
  String get indicatorsPlusText =>
      'Savings rate, income commitment and net worth evolution over the last 12 months.';

  @override
  String get knowPlus => 'Discover Plus';

  @override
  String get thisMonthTitle => 'This month';

  @override
  String get savingRateHow =>
      '(income − expenses) ÷ settled income of the month';

  @override
  String get commitmentHow =>
      '(card debt + next loan installment) ÷ income of the month';

  @override
  String get netWorthHow =>
      'accounts + reserves outside accounts − open statements − outstanding loans';

  @override
  String get netWorth12 => 'Net worth over the last 12 months';

  @override
  String assetsDebts(String assets, String debts) {
    return 'assets $assets · debts $debts';
  }

  @override
  String get indicatorsMethod =>
      'Transparent methodology, calculated only from what you recorded. Not a credit assessment nor financial advice.';

  @override
  String get days60 => '60 days';

  @override
  String onDate(String date) {
    return 'On $date';
  }

  @override
  String negativeWarning(String value, String date) {
    return 'Attention: the balance goes negative ($value) on $date.';
  }

  @override
  String minBalance(String value, String date) {
    return 'Lowest balance in the period: $value on $date.';
  }

  @override
  String balanceAfter(String date, String value) {
    return '$date · balance after $value';
  }

  @override
  String get nothingPlanned =>
      'Nothing planned in the period. Register planned bills and income to project.';

  @override
  String get projectionRules =>
      'Considers planned transactions, loan installments and card statements until due. Overdue statements enter today.';

  @override
  String get perMonthLabel => 'Per month';

  @override
  String get recurringHelp =>
      'Registered series and repeated expenses (same description and amount in 3+ of the last 6 months).';

  @override
  String recurringLine(int n, String kind) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n months',
      one: '1 month',
    );
    return '$_temp0 · $kind';
  }

  @override
  String get series => 'series';

  @override
  String get detected => 'detected';

  @override
  String get recurring => 'Recurring';

  @override
  String get nothingRecurring => 'Nothing recurring detected';

  @override
  String get nothingRecurringText =>
      'With 3 months of history the app finds subscriptions and repeated bills.';

  @override
  String recurringTip(String month, String year) {
    return 'Tip: review subscriptions you don\'t use; each $month/month is $year/year.';
  }

  @override
  String get assistantIntro =>
      'Answers calculated from your data, on the device. No question leaves the phone.';

  @override
  String get askHint => 'Ask: can I buy something for 300.00?';

  @override
  String get ask => 'Ask';

  @override
  String get question => 'Question';

  @override
  String get calculationBasis => 'Calculation basis';

  @override
  String get suggestionsForYou => 'Suggestions for you';

  @override
  String get allCalmNoSuggestion => 'No suggestion right now.';

  @override
  String get assistantRules =>
      'Transparent rules: overdue bills, budgets above pace, card above 80% of limit, negative month, ≥ 20% left without a reserve, 3+ recurring expenses.';

  @override
  String get q1 => 'How much can I spend?';

  @override
  String get q2 => 'Which bills are due this week?';

  @override
  String get q3 => 'Where am I spending the most?';

  @override
  String get q4 => 'How much did I spend on groceries?';

  @override
  String get q5 => 'How much is left for my goal?';

  @override
  String get q6 => 'How much is committed in installments?';

  @override
  String get q7 => 'How is the month going?';

  @override
  String get q8 => 'How do I organize my bills?';

  @override
  String get importTitle => 'Import';

  @override
  String get importIntroTitle => 'CSV, OFX or backup';

  @override
  String get importIntro =>
      'CSV from your bank or another app (date, description, amount, type); bank statement OFX (Plus); or a SerenaCash / previous app backup. You review everything before confirming and the app flags possible duplicates.';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get fileReadError => 'Could not read the file.';

  @override
  String columnsOf(String file) {
    return 'Columns of $file';
  }

  @override
  String rowsCheck(int n) {
    return '$n rows. Check the columns:';
  }

  @override
  String columnN(int n) {
    return 'Column $n';
  }

  @override
  String get typeColumn => 'Type (income/expense)';

  @override
  String get noTypeHelp =>
      'Without a type column, negative amounts become expenses and positive ones income.';

  @override
  String get chooseDateAmount => 'Choose the date and amount columns.';

  @override
  String get reviewTransactions => 'Review transactions';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get backupPassphrase => 'Backup passphrase';

  @override
  String warningsCount(int n, String text) {
    return '$n warning(s): $text';
  }

  @override
  String get restoreReplaces =>
      'Restoring replaces ALL current data on this device.';

  @override
  String get replaceWithBackup => 'Replace my data with this backup';

  @override
  String get restoreQ => 'Replace all data?';

  @override
  String get restoreText =>
      'Current data will be erased and replaced by the backup. Export first if you want to keep it.';

  @override
  String get restore => 'Restore';

  @override
  String foundTransactions(int n) {
    return '$n transactions found';
  }

  @override
  String dupesInfo(int d, int e) {
    return '$d possible duplicate(s) and $e with errors were unchecked. Tap to include or exclude.';
  }

  @override
  String get targetAccount => 'Target account';

  @override
  String get categoriesByName => 'Use categories by name';

  @override
  String get include => 'Include';

  @override
  String get alreadyImported => 'already imported';

  @override
  String get sameAsExisting => 'same as an existing transaction';

  @override
  String get similarToExisting => 'similar to an existing transaction';

  @override
  String importN(int n) {
    return 'Import $n';
  }

  @override
  String get chooseTargetAccount => 'Choose the target account.';

  @override
  String importResult(int n, int skipped) {
    return '$n transaction(s) imported; $skipped ignored.';
  }

  @override
  String get importDone => 'Import complete';

  @override
  String get restored => 'Backup restored.';

  @override
  String get backToStart => 'Back to home';

  @override
  String get exportTitle => 'Export and backup';

  @override
  String get allScope => 'Everything';

  @override
  String get csvSheet => 'CSV (spreadsheet)';

  @override
  String get pdfReport => 'PDF (report)';

  @override
  String get fullBackup => 'Full backup';

  @override
  String get backupHelp =>
      'A file with everything (accounts, transactions, cards, budgets, goals, loans, preferences, attachments). Keep it somewhere safe; restore in Import.';

  @override
  String get encryptedBackup => 'Encrypted backup (recommended)';

  @override
  String get plainBackup => 'Plain backup (compatible with the previous app)';

  @override
  String get plainWarning =>
      'No passphrase: anyone with the file can read your data.';

  @override
  String get passphraseMin => 'Passphrase with at least 8 characters';

  @override
  String get fileGenerated => 'File generated.';

  @override
  String get exportFailed => 'Export failed.';

  @override
  String reportOf(String month) {
    return 'Report of $month';
  }

  @override
  String get fullReport => 'Full report';

  @override
  String generatedOn(String date) {
    return 'generated on $date';
  }

  @override
  String get byCategory => 'By category';

  @override
  String get pdfFooter =>
      'Settled and planned amounts as recorded by the user. Card purchases count on the purchase date; statement payments are not expenses.';

  @override
  String get privacyTitle => 'Privacy and data';

  @override
  String get whatWeKeep => 'What we keep';

  @override
  String get privacy1 =>
      'Accounts, transactions, cards, budgets, goals, loans, lists and purchases: everything stays on this device, in an encrypted local database.';

  @override
  String get privacy2 =>
      'We don\'t ask for e-mail, tax id or bank password. There is no bank connection. No financial data is sent to servers.';

  @override
  String get privacy3 =>
      'Subscriptions are processed by Apple or Google; we only receive confirmation of access, never payment data.';

  @override
  String get privacy4 =>
      'The camera is used only to read tags and codes while shopping; images are not kept.';

  @override
  String get yourRights => 'Your rights';

  @override
  String get exportAllData => 'Export all my data';

  @override
  String get eraseAll => 'Erase everything on this device';

  @override
  String get eraseHelp =>
      'Erasing removes data, preferences, database key and subscription cache. Store purchases can be restored later.';

  @override
  String get privacyPolicyNote =>
      'Full privacy policy and terms will be published at serenacash.app/privacidade before the store launch.';

  @override
  String get eraseQ => 'Erase everything?';

  @override
  String get eraseText =>
      'This cannot be undone. Export a backup first if you want to keep the history.';

  @override
  String get eraseConfirm => 'Erase permanently';

  @override
  String get helpTitle => 'Help';

  @override
  String get faq1q => 'What is \"can spend\"?';

  @override
  String get faq1a =>
      'Money in the counted accounts, minus planned bills until the end of the period (including overdue), minus open card statements, minus reserves kept inside accounts and the cushion you set. Planned income only counts in optimistic mode. It is an estimate, not a balance.';

  @override
  String get faq2q => 'Does a card purchase count twice?';

  @override
  String get faq2a =>
      'No. The purchase is an expense on the date it happened (in its category). Paying the statement only takes money from the account and reduces the statement.';

  @override
  String get faq3q => 'How does the statement work?';

  @override
  String get faq3a =>
      'Purchases up to the closing day go into the month\'s statement; after that, the next. Installments fall one per statement. The due date is the day you registered.';

  @override
  String get faq4q => 'What is today\'s mark?';

  @override
  String get faq4a =>
      'On budget bars, the mark shows where spending would be today if spread evenly over the days of the month. Before it: within plan. Up to 10 points after: slightly above. Beyond that or over the limit: above plan.';

  @override
  String get faq5q => 'Planned × settled';

  @override
  String get faq5a =>
      'Planned is what is still to happen (bill to pay, salary to receive). Settled already happened and changes the balance. A partial payment stays \"partial\" until complete.';

  @override
  String get faq6q => 'Reserves and goals';

  @override
  String get faq6a =>
      'Saving money into a goal takes the amount from the source account. If the goal sits inside a counted account, the saved amount is deducted from \"can spend\" (when protected).';

  @override
  String get faq7q => 'Loans';

  @override
  String get faq7a =>
      'Price table (fixed installment) or SAC (decreasing installment), with a monthly rate on the outstanding balance. \"Pay off today\" is the present value of the remaining installments at the contract rate, no fees: an estimate for negotiating.';

  @override
  String get faq8q => 'Supermarket';

  @override
  String get faq8a =>
      'A barcode identifies the product, not the price. The price comes from the scanned tag (OCR), your history or you. Nothing is added without confirmation, and the cart total uses scale rounding.';

  @override
  String get faq9q => 'My data';

  @override
  String get faq9a =>
      'Everything stays on the device, encrypted. Export backups in the menu, under Export and backup. Erase everything in Privacy.';

  @override
  String featurePartOfPlus(String feature) {
    return '\"$feature\" is part of Plus.';
  }

  @override
  String thanksSupport(String plan) {
    return '$plan plan. Thank you for supporting SerenaCash.';
  }

  @override
  String get whatChanges => 'What changes';

  @override
  String get limitsRow => 'Accounts / cards / budgets / goals';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get ocrRow => 'Tag reading (OCR)';

  @override
  String perMonthN(int n) {
    return '$n/month';
  }

  @override
  String get unlimitedF => 'Unlimited';

  @override
  String get reportsPdfRow => 'Advanced reports and PDF';

  @override
  String get yes => 'Yes';

  @override
  String get ofxAttachRow => 'OFX import and attachments';

  @override
  String get priceHistoryRow => 'Price history per store';

  @override
  String get syncRow => 'Sync across devices';

  @override
  String get syncWhen => 'Subscription (when available)';

  @override
  String get essentialFree =>
      'The essentials (accounts, transactions, 1 card, budgets, goals, lists and cart) are free forever.';

  @override
  String get recommended => 'recommended';

  @override
  String get lifetimeDesc =>
      'One-time payment. Includes everything that works on the device, forever. Does not include services with recurring cost (sync).';

  @override
  String get yearlyDesc => 'Billed once a year. Cancel anytime in the store.';

  @override
  String get monthlyDesc => 'Billed monthly. Cancel anytime in the store.';

  @override
  String get planCoverage => 'Plan coverage';

  @override
  String get perYear => ' / year';

  @override
  String get perMonthShort => ' / month';

  @override
  String get loadingPrice => 'Loading store price…';

  @override
  String get priceInStore =>
      'Price and purchase available in the store version.';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get manageSubscription => 'Manage subscription in the store';

  @override
  String get thanksActive => 'Thank you! Your plan is active.';

  @override
  String get purchaseFailed => 'Purchase not completed.';

  @override
  String get purchasesRestored => 'Purchases restored.';

  @override
  String get noPurchasesFound => 'No purchases found in this store account.';

  @override
  String get restoreFailed => 'Could not restore.';

  @override
  String get subscriptionTerms =>
      'Subscriptions renew automatically until cancelled in the App Store or Google Play. Refunds follow the stores\' policies. Terms and privacy: More → Privacy.';

  @override
  String get storeProcesses =>
      'Payment processed by the store; we never see your payment data.';

  @override
  String plusFeaturesList(String list) {
    return 'Plus features: $list';
  }

  @override
  String get stayFree => 'Stay on free';

  @override
  String get notFound => 'Not found';

  @override
  String get attachmentsTitle => 'Attachments and receipts';

  @override
  String get addPhoto => 'Take photo';

  @override
  String get addFile => 'Choose file';

  @override
  String get attachmentTooBig => 'File larger than 10 MB.';

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String attachmentCount(int n) {
    return '$n attachment(s)';
  }

  @override
  String get openAttachment => 'Open';

  @override
  String get attachmentsPlusHint => 'Attachments are part of SerenaCash Plus.';

  @override
  String get changeHistory => 'Change history';

  @override
  String get changeHistoryDesc => 'Change log and sync state';

  @override
  String get syncStatus => 'Sync';

  @override
  String get syncLocalOnly =>
      'On this device only. Cross-device sync arrives as a subscription service; meanwhile every change is recorded for future upload.';

  @override
  String pendingChanges(int n) {
    return '$n change(s) recorded and pending upload';
  }

  @override
  String deviceLabel(String id) {
    return 'Device $id';
  }

  @override
  String get recentChanges => 'Recent changes';

  @override
  String get opUpsert => 'saved';

  @override
  String get opDelete => 'deleted';

  @override
  String get opRestore => 'restored';

  @override
  String versionN(int n) {
    return 'v$n';
  }

  @override
  String get noChangesYet => 'No change recorded yet.';

  @override
  String get entityAccount => 'Account';

  @override
  String get entityCategory => 'Category';

  @override
  String get entityTag => 'Tag';

  @override
  String get entityCard => 'Card';

  @override
  String get entityTransaction => 'Transaction';

  @override
  String get entityBudget => 'Budget';

  @override
  String get entityGoal => 'Goal';

  @override
  String get entityLoan => 'Loan';

  @override
  String get entityRecurrence => 'Recurrence';

  @override
  String get entityPrefs => 'Preferences';

  @override
  String get entityList => 'Shopping list';

  @override
  String get entitySession => 'Shopping session';

  @override
  String get entityProduct => 'Product';

  @override
  String get entityObservation => 'Price observation';

  @override
  String get entityLedger => 'Restore';

  @override
  String get conflicts => 'Conflicts';

  @override
  String get noConflicts =>
      'No conflicts. Monetary fields are never resolved automatically.';

  @override
  String get annualPlanning => 'Annual planning';

  @override
  String get annualDesc => 'Year view: result per month, budget and goals';

  @override
  String get previousYear => 'Previous year';

  @override
  String get nextYear => 'Next year';

  @override
  String get yearResult => 'Year result';

  @override
  String get monthCol => 'Month';

  @override
  String get budgetCol => 'Budget';

  @override
  String get annualGoals => 'Goals by year end';

  @override
  String goalNeedPerMonth(String name, String remaining, String value) {
    return '$name: $remaining to go · $value/month';
  }

  @override
  String get annualBudgetNote =>
      'Monthly budget = general limit in force that month. Future months show what is already planned.';

  @override
  String get plannedShort => 'plan.';

  @override
  String get newList => 'New list';

  @override
  String get create => 'Create';

  @override
  String get listNameHint => 'E.g. Monthly shopping';

  @override
  String get storeOptional => 'Supermarket (optional)';

  @override
  String get storeHint => 'E.g. Good Market';

  @override
  String get listBudgetLabel => 'Budget for this purchase (optional)';

  @override
  String get listBudgetHelp =>
      'At the store, the cart shows how much still fits.';

  @override
  String freeLimitLists(int n) {
    return 'Free plan: up to $n lists.';
  }

  @override
  String get defaultListName => 'Monthly shopping';

  @override
  String get listNotFound => 'List not found';

  @override
  String get buy => 'Shop';

  @override
  String estimateWithPrice(int known, int total) {
    return 'Estimate ($known of $total priced)';
  }

  @override
  String get budget => 'Budget';

  @override
  String get estimateVsBudget => 'Estimate against budget';

  @override
  String checkedCount(int checked, int total) {
    return '$checked/$total checked';
  }

  @override
  String unpricedItems(int n) {
    return ' · $n item(s) without price (not estimated)';
  }

  @override
  String get addItem => 'Add item';

  @override
  String get itemNameHint => 'E.g. Rice 5kg';

  @override
  String get itemName => 'Item name';

  @override
  String get qty => 'Qty';

  @override
  String get unit => 'Unit';

  @override
  String get categoryAndPrice => 'Category and estimated price';

  @override
  String get estimatedUnitPrice => 'Estimated unit price (optional)';

  @override
  String get estimatedPriceHelp =>
      'Without a price the item joins the list but not the estimate. If bought before, history fills it in.';

  @override
  String editItem(String name) {
    return 'Edit $name';
  }

  @override
  String get historySuffix => ' (history)';

  @override
  String get noPrice => ' · no price';

  @override
  String get emptyList => 'Empty list';

  @override
  String get emptyListText =>
      'Add items above. Units: un, kg, g, L, mL, pack, dozen, box.';

  @override
  String get startWithList => 'Start shopping with this list';

  @override
  String get uncheckAll => 'Uncheck all';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get deleteListQ => 'Delete list?';

  @override
  String get deleteListText =>
      'Items will be removed. Finished purchases are not affected.';

  @override
  String get editItemTitle => 'Edit item';

  @override
  String get removeItem => 'Remove item';

  @override
  String get newPurchase2 => 'New purchase';

  @override
  String fromList(String name, int n) {
    return 'From the list \"$name\" ($n items).';
  }

  @override
  String get noListSession => 'No list: add items by camera or manually.';

  @override
  String get sessionBudgetLabel => 'Budget for this purchase (optional)';

  @override
  String get sessionBudgetHelp => 'The cart shows how much still fits.';

  @override
  String get start => 'Start';

  @override
  String get orChooseList => 'Or choose a list';

  @override
  String finishedOn(String date) {
    return 'Finished on $date';
  }

  @override
  String itemsInCart(int n) {
    return '$n item(s) in the cart';
  }

  @override
  String get exit => 'Leave';

  @override
  String get cartTotal => 'Cart total';

  @override
  String stillFits(String remaining, String budget) {
    return '$remaining of $budget still fits';
  }

  @override
  String overBudgetBy(String over, String budget) {
    return '$over over the budget of $budget';
  }

  @override
  String get cartVsBudget => 'Cart against budget';

  @override
  String get noBudgetSession => 'No budget set for this purchase.';

  @override
  String lowConfidenceItems(int n) {
    return '$n item(s) with low-confidence reading.';
  }

  @override
  String discountLine(String value) {
    return ' · discount $value';
  }

  @override
  String get checkSuffix => ' · check';

  @override
  String removeLine(String name) {
    return 'Remove $name';
  }

  @override
  String get emptyCart => 'Empty cart';

  @override
  String get emptyCartText => 'Read the price tag or barcode, or add manually.';

  @override
  String fromListMissing(int n) {
    return 'From the list ($n missing)';
  }

  @override
  String get summary => 'Summary';

  @override
  String plannedVsActualLine(String planned, String actual, String diff) {
    return 'Planned (priced): $planned · Actual: $actual · Difference: $diff';
  }

  @override
  String boughtLine(int bought, int notBought, int extra) {
    return '$bought from the list bought · $notBought not bought · $extra extras';
  }

  @override
  String receiptRead(String key) {
    return 'Receipt read: key …$key (tax authority lookup not available offline).';
  }

  @override
  String get expenseRegistered => 'Expense recorded in finances.';

  @override
  String registerAsExpense(String value) {
    return 'Record $value as expense';
  }

  @override
  String get registerOnceHelp =>
      'Creates a single transaction in Groceries. It is never recorded twice.';

  @override
  String get tagBtn => 'Tag';

  @override
  String get codeBtn => 'Code';

  @override
  String get manualBtn => 'Manual';

  @override
  String get finishPurchase => 'Finish purchase';

  @override
  String get confirmItem => 'Confirm item';

  @override
  String readingConfidence(int percent) {
    return 'Reading confidence: $percent%';
  }

  @override
  String get product => 'Product';

  @override
  String get productNameHint => 'Product name';

  @override
  String pricePer(String unit) {
    return 'Price per $unit';
  }

  @override
  String get unitPrice => 'Unit price';

  @override
  String previousTagPrice(String value) {
    return 'Previous tag price: $value';
  }

  @override
  String quantityUnit(String unit) {
    return 'Quantity ($unit)';
  }

  @override
  String get quantity => 'Quantity';

  @override
  String get promotion => 'Promotion';

  @override
  String get take3pay2 => 'Buy 3 pay 2';

  @override
  String get take2pay1 => 'Buy 2 pay 1';

  @override
  String get off10 => '10% off';

  @override
  String get off20 => '20% off';

  @override
  String subtotal(String value) {
    return 'Subtotal: $value';
  }

  @override
  String get addToCart => 'Add to cart';

  @override
  String get leavePurchaseQ => 'Leave the purchase?';

  @override
  String get leavePurchaseText =>
      'The cart stays saved and you can continue later from the Shopping tab.';

  @override
  String get leaveKeep => 'Leave and keep';

  @override
  String get newProductWarn => 'New product: enter the name and the tag price.';

  @override
  String get scaleCodeWarn =>
      'Scale code: the embedded value may be weight or price; confirm.';

  @override
  String get ocrUnavailableWarn => 'Reading unavailable: enter manually.';

  @override
  String variationWarn(String percent, String value) {
    return '$percent% vs the last price ($value).';
  }

  @override
  String get lowConfidenceWarn =>
      'Low-confidence reading: check name and price.';

  @override
  String get noPriceInListWarn => 'No price in the list: enter the tag price.';

  @override
  String get groceriesCategory => 'Groceries';

  @override
  String get camera => 'Camera';

  @override
  String get cameraPermissionText =>
      'To read price labels and bar codes, SerenaCash needs the camera. Label photos stay only on this device, inside the encrypted database, and are sent nowhere. If the permission was denied before, allow the camera in Android settings.';

  @override
  String get allowCamera => 'Allow camera';

  @override
  String get enterManually => 'Enter manually';

  @override
  String get back => 'Back';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get frameTag => 'Frame the whole tag, without glare, and tap Read';

  @override
  String get pointBarcode => 'Point at the barcode or the receipt QR';

  @override
  String get closeCamera => 'Close camera';

  @override
  String get torchOn => 'Turn torch on';

  @override
  String get torchOff => 'Turn torch off';

  @override
  String get readTag => 'Read tag';

  @override
  String get readingTag => 'Reading the tag…';

  @override
  String get scanningAuto => 'Scanning automatically…';

  @override
  String get qrNotReceipt => 'QR read, but it is not a tax receipt (NFC-e).';

  @override
  String get invalidCode => 'Invalid code; try again.';

  @override
  String get readFailed => 'Reading failed. Try again.';

  @override
  String get ocrUnavailable =>
      'Text reading unavailable on this device/version. Enter the price manually.';

  @override
  String get photoFailed => 'Could not capture the photo.';

  @override
  String get dayTotalHint =>
      'Income minus expenses. Transfers, invoice payments and reserves only move money and are left out.';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorCopper => 'Copper';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorRed => 'Red';

  @override
  String get colorGray => 'Gray';

  @override
  String colorOther(String hex) {
    return 'Color $hex';
  }

  @override
  String countAccounts(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String countCategories(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n categories',
      one: '1 category',
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
      other: '$n cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String countTransactions(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String countBudgets(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n budgets',
      one: '1 budget',
    );
    return '$_temp0';
  }

  @override
  String countGoals(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n goals',
      one: '1 goal',
    );
    return '$_temp0';
  }

  @override
  String countLoans(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n loans',
      one: '1 loan',
    );
    return '$_temp0';
  }

  @override
  String countAttachments(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n attachments',
      one: '1 attachment',
    );
    return '$_temp0';
  }

  @override
  String countRecurrenceRules(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n series',
      one: '1 series',
    );
    return '$_temp0';
  }

  @override
  String countShoppingLists(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n shopping lists',
      one: '1 shopping list',
    );
    return '$_temp0';
  }

  @override
  String countShoppingSessions(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n purchases',
      one: '1 purchase',
    );
    return '$_temp0';
  }

  @override
  String countProducts(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String countPriceObservations(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n recorded prices',
      one: '1 recorded price',
    );
    return '$_temp0';
  }

  @override
  String countOther(int n, String name) {
    return '$n $name';
  }

  @override
  String get finishPurchaseQ => 'Finish the purchase?';

  @override
  String finishPurchaseText(String total) {
    return 'The cart is closed at $total. You then choose whether to record it as an expense.';
  }

  @override
  String get finishPurchasePending =>
      'The item you were confirming has not been added yet and will be left out.';

  @override
  String get finishConfirm => 'Finish';

  @override
  String get showSecret => 'Show';

  @override
  String get hideSecret => 'Hide';

  @override
  String get homeSetupTitle => 'Set up your balance';

  @override
  String get homeSetupText =>
      'Add your first account to see how much you can spend.';

  @override
  String get heroBalances => 'Balance in accounts';

  @override
  String get heroCommitted => 'Committed';

  @override
  String heroPlannedIncome(String value) {
    return 'Includes $value of planned income.';
  }

  @override
  String get quickBill => 'Bill to pay';

  @override
  String get quickTransfer => 'Transfer';

  @override
  String get quickIncome => 'Income';

  @override
  String get quickAccounts => 'Accounts';

  @override
  String get seeAllFem => 'See all';

  @override
  String get seeAllMasc => 'See all';

  @override
  String get seeCards => 'See cards';

  @override
  String billsPendingUntil(String date) {
    return 'Pending until $date';
  }

  @override
  String billsOverdueCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String dueInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Due in $n days',
      one: 'Due in 1 day',
    );
    return '$_temp0';
  }

  @override
  String dueOnDate(String date) {
    return 'Due $date';
  }

  @override
  String overdueSince(String date) {
    return 'Overdue since $date';
  }

  @override
  String get noBillPlanned => 'No bills planned';

  @override
  String moreBills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n more bills',
      one: '1 more bill',
    );
    return '$_temp0';
  }

  @override
  String get firstCard => 'Add your first card';

  @override
  String get invoiceDueLabel => 'Due date';

  @override
  String invoiceCloses(String date) {
    return 'Closes on $date';
  }

  @override
  String freeLimit(String value) {
    return 'Free limit $value';
  }

  @override
  String moreCards(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n more cards',
      one: '1 more card',
    );
    return '$_temp0';
  }

  @override
  String get noTransactionYet => 'No transactions yet';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String get useLightTheme => 'Use light theme';

  @override
  String periodControl(String period) {
    return '$period. Change period and customize';
  }

  @override
  String get homeLoading => 'Loading your data';

  @override
  String get noSpendingYet => 'No spending in this period';

  @override
  String get noGoalYet => 'No goal created';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get canSpendThisMonth => 'Can spend this month';

  @override
  String get heroAfterCommitted => 'After planned commitments';

  @override
  String get heroCommittedMonth => 'Commitments this month';

  @override
  String get quickEntry => 'Entry';

  @override
  String get invoiceCurrent => 'Current invoice';

  @override
  String get profile => 'Profile';

  @override
  String get yourName => 'Your name';

  @override
  String get yourNameEmpty => 'Not set';

  @override
  String get yourNameLabel => 'What should we call you';

  @override
  String get yourNameHelp =>
      'Shown in the greeting on the home screen. Stays on this device only.';

  @override
  String get catTitle => 'Categories';

  @override
  String get catNewSub => 'New subcategory';

  @override
  String get catEdit => 'Edit category';

  @override
  String get catEditSub => 'Edit subcategory';

  @override
  String get catIcon => 'Icon';

  @override
  String get catSearchIcon => 'Search icon (e.g. groceries, health)';

  @override
  String catNoIcon(String q) {
    return 'No icon for “$q”.';
  }

  @override
  String get catPreview => 'Preview';

  @override
  String get catPreviewName => 'Category name';

  @override
  String get catParent => 'Main category';

  @override
  String get catParentNone => 'None: it is a main category';

  @override
  String get catParentHelp =>
      'A subcategory details its main category. The main category totals already include its subcategories.';

  @override
  String get catParentLocked =>
      'This category has subcategories, so it stays a main category.';

  @override
  String catSubCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n subcategories',
      one: '1 subcategory',
      zero: 'No subcategories',
    );
    return '$_temp0';
  }

  @override
  String catAddSubTo(String name) {
    return 'Add subcategory to $name';
  }

  @override
  String get catAddSub => 'Subcategory';

  @override
  String get catArchivedSection => 'Archived';

  @override
  String get catArchivedHelp =>
      'Archived categories stay on past entries and in reports, but leave the pickers.';

  @override
  String get catArchive => 'Archive';

  @override
  String get catArchiveText =>
      'It leaves the pickers. Entries that already use this category stay as they are.';

  @override
  String get catReactivate => 'Reactivate';

  @override
  String get catDelete => 'Delete';

  @override
  String catDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get catDeleteUnused => 'No entry uses this category.';

  @override
  String catDeleteUsed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n entries use this category',
      one: '1 entry uses this category',
    );
    return '$_temp0. Choose what to do with them:';
  }

  @override
  String catDeleteSubs(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Its $n subcategories will be deleted too',
      one: 'Its subcategory will be deleted too',
    );
    return '$_temp0.';
  }

  @override
  String catDeleteBudgets(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n budgets of this category will be removed',
      one: '1 budget of this category will be removed',
    );
    return '$_temp0.';
  }

  @override
  String get catMoveTo => 'Move to another category';

  @override
  String get catMoveToPick => 'Choose the destination category';

  @override
  String get catLeaveNone => 'Leave without a category';

  @override
  String get catDeleteConfirm => 'Delete category';

  @override
  String catDeleted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Category deleted. $n entries reclassified.',
      one: 'Category deleted. 1 entry reclassified.',
      zero: 'Category deleted.',
    );
    return '$_temp0';
  }

  @override
  String get catErrEmpty => 'Enter a name.';

  @override
  String get catErrDuplicate =>
      'A category with this name already exists at this level.';

  @override
  String get catErrParent => 'Choose a valid main category of the same kind.';

  @override
  String get catErrHasSubs =>
      'A category with subcategories cannot become a subcategory.';

  @override
  String get catErrTarget => 'Choose another destination category.';

  @override
  String get catSearch => 'Search category';

  @override
  String catNotFound(String q) {
    return 'No category for “$q”.';
  }

  @override
  String catCreateNamed(String q) {
    return 'Create “$q”';
  }

  @override
  String get catNone => 'No category';

  @override
  String get catChoose => 'Choose category';

  @override
  String get catSubcategory => 'Subcategory';

  @override
  String get catSubNone => 'None';

  @override
  String get catNewSubShort => 'New';

  @override
  String catUsage(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n entries',
      one: '1 entry',
      zero: 'No entries',
    );
    return '$_temp0';
  }

  @override
  String get catEmptyKind => 'No category here yet.';

  @override
  String get catAllCategories => 'All categories';

  @override
  String get catFilter => 'Category';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorSky => 'Light blue';

  @override
  String get colorOlive => 'Olive';

  @override
  String get colorGold => 'Gold';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorLightGray => 'Light gray';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get navMenu => 'Menu';

  @override
  String get navGroupMain => 'Main';

  @override
  String get navGroupMoves => 'Activity';

  @override
  String get navGroupPlanning => 'Planning';

  @override
  String get navGroupRegisters => 'Registers';

  @override
  String get navGroupSettings => 'App';

  @override
  String get navCards => 'Credit cards';

  @override
  String get navCategories => 'Categories and subcategories';

  @override
  String get addTitle => 'Add';

  @override
  String get addExpense => 'Expense';

  @override
  String get addExpenseDesc => 'Money that left an account';

  @override
  String get addIncome => 'Income';

  @override
  String get addIncomeDesc => 'Money that came into an account';

  @override
  String get addTransfer => 'Transfer';

  @override
  String get addTransferDesc => 'Between two of your accounts';

  @override
  String get addCardPurchase => 'Card purchase';

  @override
  String get addCardPurchaseDesc => 'Goes on the credit card invoice';

  @override
  String get addBill => 'Bill to pay';

  @override
  String get addBillDesc => 'Expense with a due date, not paid yet';

  @override
  String get addReceivable => 'Amount to receive';

  @override
  String get addReceivableDesc => 'Expected income, not received yet';

  @override
  String get repDirectInCategory => 'Directly in the category';

  @override
  String get repSubsIncluded =>
      'Each category total already includes the subcategories listed under it.';

  @override
  String get billsBoth => 'Payable and receivable';

  @override
  String get segPayable => 'To pay';

  @override
  String get segReceivable => 'To receive';

  @override
  String get receive => 'Receive';

  @override
  String receivableUntil(String date, String value) {
    return 'To receive until $date · $value';
  }

  @override
  String receivableLate(String value) {
    return 'Late · $value';
  }

  @override
  String get nothingToReceive => 'Nothing to receive in the period';

  @override
  String get newReceivable => 'New amount to receive';

  @override
  String get receivablesHelp =>
      '“Receive” marks it as received today in the entry\'s account. To receive part of it, open the entry.';

  @override
  String expectedOn(String date) {
    return 'Expected on $date';
  }

  @override
  String expectedSince(String date) {
    return 'Expected since $date';
  }

  @override
  String get plannedHelpIncome =>
      'Expected income shows under \"To receive\" and only enters the balance when you mark it as received.';

  @override
  String get bootKeyMissing =>
      'The key that protects your data is no longer on this device, so the database cannot be opened. This happens, for example, when the app data is copied from another device.';

  @override
  String get bootKeyInvalid =>
      'The key that protects your data is damaged, so the database cannot be opened.';

  @override
  String get bootGeneric =>
      'The protected database did not open. It may be a passing device failure or a damaged file.';

  @override
  String get bootRecoverHelp =>
      'Try again first. If it keeps failing, the way out is to erase the data on this device and start over; afterwards you can restore a backup exported by SerenaCash.';

  @override
  String get bootRetry => 'Try again';

  @override
  String get bootReset => 'Erase data and start over';

  @override
  String get bootResetQ => 'Erase the data on this device?';

  @override
  String get bootResetText =>
      'Everything SerenaCash keeps on this device will be erased and cannot be recovered from here. A backup exported earlier remains valid and can be restored afterwards.';

  @override
  String bootDetails(String detail) {
    return 'Technical detail: $detail';
  }

  @override
  String pinLockedFor(String time) {
    return 'Too many attempts. Try again in $time.';
  }

  @override
  String pinAttemptsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Wrong PIN. $n attempts left before a pause.',
      one: 'Wrong PIN. 1 attempt left before a pause.',
    );
    return '$_temp0';
  }

  @override
  String get pinForgot => 'I forgot the PIN';

  @override
  String get pinForgotTitle => 'The PIN cannot be recovered';

  @override
  String get pinForgotText =>
      'SerenaCash does not keep the PIN anywhere it could be read from, nor sends anything off the device. Without the PIN, the only way out is to erase the data on this device and start over. If you exported a backup, you can restore it afterwards.';

  @override
  String get pinCurrent => 'Current PIN';

  @override
  String get pinDisableTitle => 'Confirm the PIN to turn it off';

  @override
  String get lockScreenProtected =>
      'With the lock on, the app also hides its content in the recent apps list and blocks screenshots.';

  @override
  String get lockRecover => 'I cannot unlock';

  @override
  String get lockRecoverText =>
      'If the device unlock no longer works here, the only way out is to erase the data on this device and start over. If you exported a backup, you can restore it afterwards.';

  @override
  String get biometricConfirmToEnable =>
      'Confirm on the device to turn the lock on';

  @override
  String get biometricNotEnabled =>
      'Could not confirm on the device; the lock was not turned on. Set up a screen lock or biometrics in Android and try again.';

  @override
  String get openCalendar => 'Open calendar';

  @override
  String get payWith => 'Paid with';

  @override
  String get payWithAccount => 'Account or wallet';

  @override
  String get payWithCard => 'Credit card';

  @override
  String get newAccountChip => 'New account';

  @override
  String get newCardChip => 'New card';

  @override
  String get transferNeedsTwo =>
      'A transfer needs two accounts. Add the destination account.';

  @override
  String get cardPurchaseHelp =>
      'Goes to the card statement. No account is charged now; the account is only charged when the statement is paid.';

  @override
  String installmentsExact(String first, String rest) {
    return '$first on the first and $rest on the others';
  }

  @override
  String get bioCanceled =>
      'Confirmation cancelled; the lock was not turned on.';

  @override
  String get bioFailedEnable =>
      'The device did not confirm your identity; the lock was not turned on.';

  @override
  String get bioNotSetUp =>
      'This device has no screen lock and no biometrics set up. Set one up in Android\'s security settings and try again.';

  @override
  String get bioNoHardware =>
      'This device offers neither biometrics nor a screen lock. Use the app PIN.';

  @override
  String get bioLockedOut =>
      'Too many attempts. Android suspended biometrics for a while; wait and try again.';

  @override
  String get bioUnavailableNow =>
      'Android could not open the confirmation now. Try again.';

  @override
  String get bioOpenSettings => 'Open settings';

  @override
  String get unlockNotSetUp =>
      'This device\'s screen lock was removed. Set up a screen lock or biometrics in Android to unlock.';

  @override
  String annualNoData(String year) {
    return 'No entries and no budget in $year.';
  }

  @override
  String get annualNoDataHint =>
      'The app only shows what was recorded: a budget or a goal created later does not apply backwards.';

  @override
  String annualGoalsOfYear(String year) {
    return 'Goals in $year';
  }

  @override
  String annualNoGoalsInYear(String year) {
    return 'No goal existed in $year.';
  }

  @override
  String annualGoalPast(String name, String saved, String total) {
    return '$name: $saved put aside in the year · $total accumulated by December';
  }

  @override
  String annualGoalByDate(
    String name,
    String remaining,
    String value,
    String date,
  ) {
    return '$name: $remaining to go · $value/month until $date';
  }

  @override
  String annualGoalByYearEnd(String name, String remaining, String value) {
    return '$name: $remaining to go · $value/month to finish by December (goal without a deadline)';
  }

  @override
  String annualGoalFutureDate(String name, String remaining, String date) {
    return '$name: $remaining to go today · due $date';
  }

  @override
  String annualGoalFutureOpen(String name, String remaining) {
    return '$name: $remaining to go today · no deadline';
  }

  @override
  String get annualFutureNote =>
      'Future year: only what is already planned in the entries and the budget in force are shown.';

  @override
  String get biometricConfirmToDisable =>
      'Confirm on the device to turn the lock off';

  @override
  String get bioDisableDenied =>
      'The device did not confirm your identity; the lock stays on.';

  @override
  String get takePhoto => 'Take photo';

  @override
  String scanCart(String total) {
    return 'Cart $total';
  }

  @override
  String scanCartBudget(String total, String left) {
    return 'Cart $total · $left left';
  }

  @override
  String get reviewTapDefines => 'A tap on the photo sets';

  @override
  String get reviewPhotoHint =>
      'Tap a marked text on the photo to use it. Pinch to zoom.';

  @override
  String get reviewPickName => 'Name';

  @override
  String get reviewPickPrice => 'Price';

  @override
  String get reviewNoPriceInLine =>
      'That piece has no price. Tap the amount on the label.';

  @override
  String get reviewPrices => 'Prices read on the label';

  @override
  String get reviewOtherNames => 'Other texts read';

  @override
  String get reviewConfirmPrice => 'I checked the price against the photo';

  @override
  String get reviewConfirmPriceHelp =>
      'The reading of this price is doubtful. Compare with the label before adding.';

  @override
  String get reviewNeedsCheck =>
      'Review needed: check the price on the photo, fix it or mark it as checked.';

  @override
  String priceRetail(String value) {
    return 'Retail $value';
  }

  @override
  String priceWholesale(String value, int n) {
    return 'Wholesale $value from $n units';
  }

  @override
  String priceWholesaleNoMin(String value) {
    return 'Wholesale $value';
  }

  @override
  String pricePerKg(String value) {
    return 'Per kilo: $value (printed for comparison; not the item price)';
  }

  @override
  String pricePerLiter(String value) {
    return 'Per liter: $value (printed for comparison; not the item price)';
  }

  @override
  String pricePerPackUnit(String value) {
    return 'Small print amount: $value (not the item price)';
  }

  @override
  String wholesaleHelp(int n) {
    return 'Applies only when the quantity in the cart reaches $n. Below that the retail price counts.';
  }

  @override
  String get wholesaleNoMinHelp =>
      'The label does not say from how many units it applies, so it is not applied.';

  @override
  String get addAndScanNext => 'Add and read the next';

  @override
  String get addProductPhoto => 'Product photo';

  @override
  String get replaceProductPhoto => 'Replace product photo';

  @override
  String get evidenceTitle => 'Evidence';

  @override
  String get evidenceLabel => 'Shelf label';

  @override
  String get evidenceProduct => 'Product';

  @override
  String get evidenceReceipt => 'Receipt';

  @override
  String get evidenceNote =>
      'Photos stay only on this device, inside the encrypted database. They are your record of what was announced, not legal proof.';

  @override
  String evidenceReadVsConfirmed(String read, String confirmed) {
    return 'Read on the label: $read · confirmed by you: $confirmed';
  }

  @override
  String evidenceTakenAt(String date) {
    return 'Photo from $date';
  }

  @override
  String get evidenceDelete => 'Delete this photo';

  @override
  String get evidenceDeleteQ => 'Delete the photo?';

  @override
  String get evidenceDeleteText =>
      'The photo leaves the device and cannot be recovered. The item and the price stay in the cart.';

  @override
  String codeFound(String code) {
    return 'Product from your catalog, found by code $code.';
  }

  @override
  String codeDecodedUnknown(String code) {
    return 'Code $code read. It is not in your catalog yet: enter name and price and the product is saved with this code.';
  }

  @override
  String codeNotStandard(String code) {
    return 'Code $code was read, but it does not check as a standard product code (EAN/UPC). It is kept as is.';
  }

  @override
  String codeLastPrice(String value, String date) {
    return 'Last recorded price: $value, on $date. Check today\'s price on the label.';
  }

  @override
  String get photoNoReading =>
      'Nothing was read on the photo. It stays attached to the item; enter name and price.';

  @override
  String get evidenceEmpty => 'No photos in this purchase';

  @override
  String get evidenceEmptyText =>
      'Label, product and receipt photos show up here.';

  @override
  String get evidenceOpen => 'Open the photo';

  @override
  String evidenceCount(int n) {
    return 'Evidence ($n)';
  }

  @override
  String get receiptTitle => 'Check receipt';

  @override
  String get receiptCheck => 'Check against the receipt';

  @override
  String get receiptIntro =>
      'Photograph the receipt or pick a photo. The app reads the items on the device, pairs them with the cart and shows the announced price next to the charged price. Nothing leaves the phone.';

  @override
  String get receiptPhoto => 'Photograph receipt';

  @override
  String get receiptGallery => 'Pick a photo';

  @override
  String get receiptSummary => 'Announced × charged';

  @override
  String receiptAnnouncedCharged(String announced, String charged) {
    return 'On paired items: $announced announced on the shelf and $charged charged.';
  }

  @override
  String get receiptNoDifference => 'No difference on paired items';

  @override
  String receiptChargedMore(String value) {
    return 'Charged $value more';
  }

  @override
  String receiptChargedLess(String value) {
    return 'Charged $value less';
  }

  @override
  String get receiptSummaryNote =>
      'The comparison covers paired items. Till discounts, offers with a validity and weighed items can explain a difference; check the photos before complaining.';

  @override
  String get receiptSeePhoto => 'See the receipt photo';

  @override
  String get receiptSeeShelfPhoto => 'See the label photo';

  @override
  String get receiptEqual => 'Same price as announced';

  @override
  String receiptDiffMore(String value) {
    return 'Difference: $value more per unit';
  }

  @override
  String receiptDiffLess(String value) {
    return 'Difference: $value less per unit';
  }

  @override
  String get receiptSuspected => 'Suspected difference';

  @override
  String get receiptSuspectedHelp =>
      'The receipt text is not enough to be sure it is the same item. Tap to confirm or change the pair.';

  @override
  String get receiptUnmatched => 'No pair in the cart';

  @override
  String receiptShelfVsTill(String name, String shelf, String till) {
    return '$name: shelf $shelf · receipt $till';
  }

  @override
  String get receiptPairTitle => 'Which cart item does this line match?';

  @override
  String get receiptNoPair => 'None (leave unpaired)';

  @override
  String get receiptMissing => 'In the cart and not found on the receipt';

  @override
  String get receiptMissingHelp =>
      'They may be outside the photo, have been read under another name or not have gone through the till.';

  @override
  String loanLineFree(String system, String paid) {
    return '$system · $paid paid';
  }

  @override
  String get loanPaidShare => 'Share of the principal already paid';

  @override
  String get loanFreeNote => 'No installments or due date: paid when possible.';

  @override
  String get loanSystemAmericanShort => 'American';

  @override
  String get loanSystemBulletShort => 'Single payment';

  @override
  String get loanSystemFreeShort => 'No installments';

  @override
  String get loanLentTag => 'Lent';

  @override
  String get loanDirection => 'Who owes';

  @override
  String get loanBorrowed => 'I owe';

  @override
  String get loanLent => 'I am owed';

  @override
  String get loanMode => 'How it is paid';

  @override
  String get loanModeScheduled => 'With installments';

  @override
  String get loanModeFree => 'When possible';

  @override
  String get loanModeFreeHelp =>
      'No number of installments and no term. Each payment is recorded when it happens, for whatever amount.';

  @override
  String get loanCreditor => 'Creditor (who I owe)';

  @override
  String get loanDebtor => 'Debtor (who owes me)';

  @override
  String get loanLentAmount => 'Amount I lent';

  @override
  String get loanSystemAmerican => 'American (periodic interest)';

  @override
  String get loanSystemBullet => 'Single payment at the end';

  @override
  String get loanSystemPriceHelp =>
      'Equal installments; at the start most of it is interest.';

  @override
  String get loanSystemSacHelp =>
      'Equal amortization each month; the installment falls over time.';

  @override
  String get loanSystemAmericanHelp =>
      'Each month only the interest on the whole amount is paid; the principal goes with the last installment.';

  @override
  String get loanSystemBulletHelp =>
      'Nothing is paid until the end of the term; at maturity the principal is paid with interest compounded month by month.';

  @override
  String get loanInterest => 'Interest';

  @override
  String get loanInterestNone => 'No interest';

  @override
  String get loanInterestSimple => 'Simple interest';

  @override
  String get loanInterestCompound => 'Compound interest';

  @override
  String get loanInterestNoneHelp =>
      'The balance only changes when there is a payment. Time adds nothing.';

  @override
  String get loanInterestSimpleHelp =>
      'Interest on the principal still owed, in proportion to the days (30-day month). Each payment covers interest first, then principal.';

  @override
  String get loanInterestCompoundHelp =>
      'Interest on the whole balance, unpaid interest included, in proportion to the days (30-day month). Each payment covers interest first, then principal.';

  @override
  String get loanRateYear => 'Interest (% per year)';

  @override
  String get loanTermMonths => 'Term (months)';

  @override
  String get loanRateStated => 'The contract rate is';

  @override
  String get loanRatePerMonth => 'Per month';

  @override
  String get loanRatePerYearEffective => 'Per year, effective';

  @override
  String get loanRatePerYearNominal => 'Per year, nominal';

  @override
  String loanRateEquivalent(String rate) {
    return 'Equals $rate% per month, the rate used in the calculations.';
  }

  @override
  String get loanOriginDate => 'Date the debt began';

  @override
  String get loanHandoverLabel => 'Loan granted';

  @override
  String get loanRegisterHandover => 'Record the money leaving the account';

  @override
  String get loanRegisterHandoverHelp =>
      'Turn on if the amount left the account today.';

  @override
  String get loanFormErrBasic => 'Enter the name and the amount.';

  @override
  String get loanFormErrRate => 'Enter the interest rate.';

  @override
  String get loanFormErrTerm =>
      'Enter the number of installments, from 1 to 480.';

  @override
  String get loanOwedToYou => 'Owed to you';

  @override
  String loanFreeSummary(String principal, String date, String paid) {
    return 'Original amount $principal on $date · $paid already paid';
  }

  @override
  String loanFreeInterestLine(
    String mode,
    String rate,
    String accrued,
    String paid,
  ) {
    return '$mode at $rate% per month · $accrued of interest due today · $paid of interest already paid';
  }

  @override
  String get loanFreeNoInterest =>
      'No interest: the balance only changes with payments.';

  @override
  String get loanRegisterPayment => 'Record payment';

  @override
  String get loanRegisterReceipt => 'Record receipt';

  @override
  String loanSettleWith(String value) {
    return 'Settle: fill in $value';
  }

  @override
  String get loanFreePayNote =>
      'The payment leaves the account chosen in the registration and does not count as an expense of the month: it is money being paid back.';

  @override
  String loanPayTooMuch(String owed) {
    return 'The amount is larger than the balance on that date ($owed). To settle, record $owed.';
  }

  @override
  String loanPaymentOf(String name) {
    return 'Payment: $name';
  }

  @override
  String loanReceiptOf(String name) {
    return 'Receipt: $name';
  }

  @override
  String get loanStatement => 'Statement';

  @override
  String get loanNoPaymentsYet => 'No payments recorded yet.';

  @override
  String loanEventSplit(String interest, String principal, String balance) {
    return '$interest interest · $principal principal · balance $balance';
  }

  @override
  String loanEventBalance(String balance) {
    return 'Balance after: $balance';
  }

  @override
  String get chartTotal => 'Total';

  @override
  String get chartOthers => 'Others';

  @override
  String chartOthersCount(int n) {
    return '$n smaller categories';
  }
}
