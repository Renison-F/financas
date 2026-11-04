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
    return 'Month $pace';
  }

  @override
  String get paceSereno => 'serene';

  @override
  String get paceAtencao => 'needs attention';

  @override
  String get paceAgitado => 'agitated';

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
  String get allCalm => 'All calm here.';

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
    return '$n items';
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
  String get biometricLock => 'Ask for biometrics on open';

  @override
  String get biometricAvailable => 'Face ID / fingerprint of the device.';

  @override
  String get biometricNotAvailable => 'No biometrics set up on this device.';

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
      'Your data stays only on this device. Make backups in More → Export.';

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
  String get onbWelcomeTitle => 'Your money at peace.';

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
}
