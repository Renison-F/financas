import 'package:intl/intl.dart';

import '../../app/app.dart';
import '../../domain/entities/entities.dart';

/// Greeting for the hour of the day (0-23): morning from 5h, afternoon from 12h, evening from 18h
/// through the small hours.
String greetingFor(AppLocalizations l, int hour) => hour >= 5 && hour < 12
    ? l.greetingMorning
    : hour >= 12 && hour < 18
    ? l.greetingAfternoon
    : l.greetingEvening;

String dayMonth(String iso) => '${iso.substring(8, 10)}/${iso.substring(5, 7)}';

/// Day and abbreviated month, as on a card statement: "08 nov".
String dayMonthShort(String iso, String locale) =>
    '${iso.substring(8, 10)} ${monthLabelShort(iso.substring(0, 7), locale)}';

String monthLabelShort(String key, String locale) {
  final d = DateTime(
    int.parse(key.substring(0, 4)),
    int.parse(key.substring(5, 7)),
  );
  return DateFormat.MMM(locale).format(d).replaceAll('.', '');
}

String monthLabelLong(String key, String locale) {
  final d = DateTime(
    int.parse(key.substring(0, 4)),
    int.parse(key.substring(5, 7)),
  );
  final s = DateFormat.yMMMM(locale).format(d);
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

String dayTitle(String iso, String locale) {
  final d = DateTime(
    int.parse(iso.substring(0, 4)),
    int.parse(iso.substring(5, 7)),
    int.parse(iso.substring(8, 10)),
  );
  final s = DateFormat('EEEE, dd MMM', locale).format(d).replaceAll('.', '');
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Human label for one entry of an import report's counts ("2 contas").
String importCountLabel(AppLocalizations l, String key, int n) => switch (key) {
  'accounts' => l.countAccounts(n),
  'categories' => l.countCategories(n),
  'tags' => l.countTags(n),
  'cards' => l.countCards(n),
  'transactions' => l.countTransactions(n),
  'budgets' => l.countBudgets(n),
  'goals' => l.countGoals(n),
  'loans' => l.countLoans(n),
  'attachments' => l.countAttachments(n),
  'recurrenceRules' => l.countRecurrenceRules(n),
  'shoppingLists' => l.countShoppingLists(n),
  'shoppingSessions' => l.countShoppingSessions(n),
  'products' => l.countProducts(n),
  'priceObservations' => l.countPriceObservations(n),
  _ => l.countOther(n, key),
};

String kindLabel(AppLocalizations l, TransactionKind k) => switch (k) {
  TransactionKind.income => l.kindIncome,
  TransactionKind.expense => l.kindExpense,
  TransactionKind.transfer => l.kindTransfer,
  TransactionKind.cardPurchase => l.kindCardPurchase,
  TransactionKind.cardPayment => l.kindCardPayment,
  TransactionKind.goalDeposit => l.kindGoalDeposit,
  TransactionKind.goalWithdrawal => l.kindGoalWithdrawal,
  TransactionKind.loanDisbursement => l.kindLoanDisbursement,
  TransactionKind.loanPayment => l.kindLoanPayment,
  TransactionKind.balanceAdjustment => l.kindBalanceAdjustment,
  TransactionKind.cardRefund => l.kindCardRefund,
};

String frequencyLabel(AppLocalizations l, String f) => switch (f) {
  'weekly' => l.frequencyWeekly,
  'biweekly' => l.frequencyBiweekly,
  'yearly' => l.frequencyYearly,
  _ => l.frequencyMonthly,
};

/// Sign of a transaction in lists (Regra do Sinal): income-like positive, outflows negative, neutral moves unsigned.
int signedAmount(Transaction t) => switch (t.kind) {
  TransactionKind.income ||
  TransactionKind.loanDisbursement ||
  TransactionKind.goalWithdrawal ||
  TransactionKind.cardRefund => t.amountCents,
  TransactionKind.transfer ||
  TransactionKind.balanceAdjustment => t.amountCents,
  _ => -t.amountCents,
};

bool isNeutralKind(TransactionKind k) =>
    k == TransactionKind.transfer || k == TransactionKind.balanceAdjustment;
