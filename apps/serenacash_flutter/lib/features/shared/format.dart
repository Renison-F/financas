import 'package:intl/intl.dart';

import '../../app/app.dart';
import '../../domain/entities/entities.dart';

String dayMonth(String iso) => '${iso.substring(8, 10)}/${iso.substring(5, 7)}';

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
