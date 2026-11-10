/// Daily control: what was spent and received each day, how the balance moved, and daily targets.
///
/// Everything here is counted by the same rule as the month totals ([monthTotals]): income as
/// received, expenses as paid, card purchases on the day of the purchase (never again when the
/// invoice is paid), transfers and loan movements left out. The sum of the days of a month is the
/// month's total, to the cent.
///
/// Two things are kept apart on purpose:
/// - spending less than a limit is not saving. A saving target only counts money actually set
///   aside (deposits into goals);
/// - a target says what it was on each day. Changing a target starts a new period; the days already
///   lived keep the target they had.
library;

import '../dates/dates.dart';
import '../entities/entities.dart';
import '../ledger/ledger.dart';
import '../money/money.dart';

/// One calendar day of a month.
class DayFlow {
  const DayFlow({
    required this.date,
    required this.incomeCents,
    required this.expenseCents,
    required this.plannedIncomeCents,
    required this.plannedExpenseCents,
    this.balanceCents,
    this.projectedBalanceCents,
  });
  final ISODate date;

  /// Received and spent on the day (settled).
  final Cents incomeCents, expenseCents;

  /// Still planned for the day (not received / not paid yet).
  final Cents plannedIncomeCents, plannedExpenseCents;

  /// Money in the accounts at the end of the day. Only for days up to today: it is a fact.
  final Cents? balanceCents;

  /// For days after today: today's balance plus what is planned to come in and minus what is planned
  /// to go out until that day. A projection of what is recorded, not a forecast of behaviour.
  final Cents? projectedBalanceCents;

  Cents get resultCents => incomeCents - expenseCents;
}

Cents _expenseOf(Transaction t, {Id? categoryId, Ledger? ledger}) {
  if (categoryId != null) {
    final own = t.categoryId == categoryId;
    final child = ledger?.categoryById(t.categoryId)?.parentId == categoryId;
    if (!own && !child) return 0;
  }
  return switch (t.kind) {
    TransactionKind.cardPurchase => t.amountCents,
    TransactionKind.cardRefund => -t.amountCents,
    TransactionKind.expense => effectiveCents(t),
    _ => 0,
  };
}

/// Spent on [date], by the rule of the month totals; optionally only one category (its
/// subcategories included).
Cents spentOn(Ledger ledger, ISODate date, {Id? categoryId}) {
  var total = 0;
  for (final t in ledger.transactions) {
    if (!isActive(t) || t.date != date) continue;
    total = addCents(
      total,
      _expenseOf(t, categoryId: categoryId, ledger: ledger),
    );
  }
  return total;
}

/// Day by day of [month]. The balance starts from the real money in the accounts at the end of the
/// day before the month; nothing is smoothed and no day is invented.
///
/// With [accountId] only what moved that account is counted and the balance is the balance of that
/// account. A card purchase belongs to no account until its invoice is paid, so it is left out.
List<DayFlow> dailyFlow(
  Ledger ledger,
  MonthKey month,
  ISODate today, {
  Id? accountId,
}) {
  final first = startOfMonth(month), last = endOfMonth(month);
  final income = <ISODate, int>{}, expense = <ISODate, int>{};
  final plannedIn = <ISODate, int>{}, plannedOut = <ISODate, int>{};
  Cents balanceOn(ISODate d) => accountId == null
      ? consolidatedBalance(ledger, asOf: d)
      : accountBalance(ledger, accountId, d);
  for (final t in ledger.transactions) {
    if (!isActive(t) || monthKeyOf(t.date) != month) continue;
    if (accountId != null && t.accountId != accountId) continue;
    if (isIncomeLike(t)) {
      income[t.date] = addCents(income[t.date] ?? 0, effectiveCents(t));
      plannedIn[t.date] = addCents(plannedIn[t.date] ?? 0, pendingCents(t));
    }
    final e = _expenseOf(t);
    if (e != 0) expense[t.date] = addCents(expense[t.date] ?? 0, e);
    if (t.kind == TransactionKind.expense) {
      plannedOut[t.date] = addCents(plannedOut[t.date] ?? 0, pendingCents(t));
    }
  }
  final out = <DayFlow>[];
  // The projection starts from today's balance. A month that has not begun starts from what is
  // expected on its eve: today's balance plus everything planned between tomorrow and that day.
  var projected = compareISO(first, today) > 0
      ? projectedBalance(
          ledger,
          addDays(first, -1),
          today,
          accountId: accountId,
        )
      : balanceOn(today);
  for (var d = first; compareISO(d, last) <= 0; d = addDays(d, 1)) {
    final past = compareISO(d, today) <= 0;
    if (!past) {
      projected = projected + (plannedIn[d] ?? 0) - (plannedOut[d] ?? 0);
    }
    out.add(
      DayFlow(
        date: d,
        incomeCents: income[d] ?? 0,
        expenseCents: expense[d] ?? 0,
        plannedIncomeCents: plannedIn[d] ?? 0,
        plannedExpenseCents: plannedOut[d] ?? 0,
        balanceCents: past ? balanceOn(d) : null,
        projectedBalanceCents: past ? null : projected,
      ),
    );
  }
  return out;
}

/// Money in the accounts when the month began (end of the day before its first day).
Cents openingBalance(Ledger ledger, MonthKey month) =>
    consolidatedBalance(ledger, asOf: addDays(startOfMonth(month), -1));

/// Balance at the end of [date]. Up to [today] it is the real balance. After today it is today's
/// balance plus what is planned to come in and minus what is planned to go out from tomorrow to
/// [date]: a sum of what is recorded, not a forecast of behaviour.
Cents projectedBalance(
  Ledger ledger,
  ISODate date,
  ISODate today, {
  Id? accountId,
}) {
  Cents balanceOn(ISODate d) => accountId == null
      ? consolidatedBalance(ledger, asOf: d)
      : accountBalance(ledger, accountId, d);
  if (compareISO(date, today) <= 0) return balanceOn(date);
  var total = balanceOn(today);
  for (final t in ledger.transactions) {
    if (!isActive(t)) continue;
    if (accountId != null && t.accountId != accountId) continue;
    if (compareISO(t.date, today) <= 0 || compareISO(t.date, date) > 0) {
      continue;
    }
    if (isIncomeLike(t)) total = addCents(total, pendingCents(t));
    if (t.kind == TransactionKind.expense) {
      total = addCents(total, -pendingCents(t));
    }
  }
  return total;
}

/// The entries of one day, in the order they were recorded: what the day view of the timeline lists.
List<Transaction> entriesOn(Ledger ledger, ISODate date) =>
    ledger.transactions.where((t) => isActive(t) && t.date == date).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

class DailySummary {
  const DailySummary({
    required this.today,
    required this.spentTodayCents,
    required this.spentYesterdayCents,
    required this.receivedTodayCents,
    required this.receivedYesterdayCents,
    required this.spentMonthCents,
    required this.receivedMonthCents,
    required this.daysElapsed,
    required this.daysWithSpending,
    required this.openingBalanceCents,
    required this.balanceTodayCents,
    this.previousMonthSameDaysCents,
  });
  final ISODate today;
  final Cents spentTodayCents, spentYesterdayCents;
  final Cents receivedTodayCents, receivedYesterdayCents;

  /// Month to date.
  final Cents spentMonthCents, receivedMonthCents;

  /// Calendar days of the month up to and including today.
  final int daysElapsed;

  /// Days of the month, up to today, on which something was spent.
  final int daysWithSpending;
  final Cents openingBalanceCents, balanceTodayCents;

  /// Spent in the same number of days of the previous month; null when that month has no entries
  /// at all (nothing to compare with, which is different from "spent zero").
  final Cents? previousMonthSameDaysCents;

  Cents get resultTodayCents => receivedTodayCents - spentTodayCents;

  /// Average per calendar day of the month so far.
  Cents get averagePerCalendarDayCents => daysElapsed == 0
      ? 0
      : divCents(spentMonthCents, daysElapsed.toDouble(), RoundingMode.halfUp);

  /// Average per day on which something was spent. Null when there was no such day.
  Cents? get averagePerSpendingDayCents => daysWithSpending == 0
      ? null
      : divCents(
          spentMonthCents,
          daysWithSpending.toDouble(),
          RoundingMode.halfUp,
        );
}

/// Spent from [from] to [to], both included; optionally only one category.
Cents spentBetween(Ledger ledger, ISODate from, ISODate to, {Id? categoryId}) {
  var total = 0;
  for (final t in ledger.transactions) {
    if (!isActive(t)) continue;
    if (compareISO(t.date, from) < 0 || compareISO(t.date, to) > 0) continue;
    total = addCents(
      total,
      _expenseOf(t, categoryId: categoryId, ledger: ledger),
    );
  }
  return total;
}

/// How spending is moving, from facts only. Every comparison is between periods of the same length;
/// a period with nothing recorded before it is reported as "no data" (null), never as zero.
class DailyTrend {
  const DailyTrend({
    required this.last7Cents,
    required this.previous7Cents,
    required this.sameWeekdayLastWeekCents,
    required this.daysRemaining,
    required this.monthAtCurrentPaceCents,
  });

  /// Today and the six days before it.
  final Cents last7Cents;

  /// The seven days before those; null when the ledger has nothing that old.
  final Cents? previous7Cents;

  /// Spent seven days ago; null when the ledger has nothing that old.
  final Cents? sameWeekdayLastWeekCents;

  /// Days of the month after today.
  final int daysRemaining;

  /// What the month adds up to if every remaining day costs the average of the days so far. It is
  /// arithmetic on the past, shown as such; it is not a forecast of behaviour.
  final Cents monthAtCurrentPaceCents;
}

DailyTrend dailyTrend(Ledger ledger, ISODate today, {Id? categoryId}) {
  final month = monthKeyOf(today);
  final first = startOfMonth(month), last = endOfMonth(month);
  final spentMonth = spentBetween(ledger, first, today, categoryId: categoryId);
  final elapsed = diffDays(first, today) + 1;
  final remaining = diffDays(today, last);
  final average = divCents(spentMonth, elapsed.toDouble(), RoundingMode.halfUp);
  ISODate? oldest;
  for (final t in ledger.transactions) {
    if (!isActive(t)) continue;
    if (oldest == null || compareISO(t.date, oldest) < 0) oldest = t.date;
  }
  bool known(ISODate d) => oldest != null && compareISO(oldest, d) <= 0;
  final weekAgo = addDays(today, -7);
  return DailyTrend(
    last7Cents: spentBetween(
      ledger,
      addDays(today, -6),
      today,
      categoryId: categoryId,
    ),
    previous7Cents: known(addDays(today, -13))
        ? spentBetween(
            ledger,
            addDays(today, -13),
            weekAgo,
            categoryId: categoryId,
          )
        : null,
    sameWeekdayLastWeekCents: known(weekAgo)
        ? spentOn(ledger, weekAgo, categoryId: categoryId)
        : null,
    daysRemaining: remaining,
    monthAtCurrentPaceCents: addCents(
      spentMonth,
      mulCents(average, remaining.toDouble(), RoundingMode.halfUp),
    ),
  );
}

/// What a daily limit of [amountCents] would have meant in the days of this month already lived,
/// and what it adds up to in the whole month. Used to try a value before setting it.
class LimitSimulation {
  const LimitSimulation({
    required this.daysInMonth,
    required this.monthTotalCents,
    required this.daysChecked,
    required this.daysWithin,
  });

  /// Days of the month on which the limit would apply (its weekdays).
  final int daysInMonth;
  final Cents monthTotalCents;

  /// Days up to today on which it would have applied, and on how many spending stayed within it.
  final int daysChecked, daysWithin;
}

LimitSimulation simulateLimit(
  Ledger ledger,
  Cents amountCents,
  ISODate today, {
  Id? categoryId,
  List<int> weekdays = const [],
}) {
  final month = monthKeyOf(today);
  var inMonth = 0, checked = 0, within = 0;
  for (
    var d = startOfMonth(month);
    compareISO(d, endOfMonth(month)) <= 0;
    d = addDays(d, 1)
  ) {
    if (weekdays.isNotEmpty && !weekdays.contains(_weekday(d))) continue;
    inMonth++;
    if (compareISO(d, today) > 0) continue;
    checked++;
    if (spentOn(ledger, d, categoryId: categoryId) <= amountCents) within++;
  }
  return LimitSimulation(
    daysInMonth: inMonth,
    monthTotalCents: mulCents(
      amountCents,
      inMonth.toDouble(),
      RoundingMode.halfUp,
    ),
    daysChecked: checked,
    daysWithin: within,
  );
}

/// A spending limit passed today.
class LimitAlert {
  const LimitAlert({required this.target, required this.day});
  final DailyTarget target;
  final SpendLimitDay day;
  Cents get overCents => day.spentCents - day.availableCents;
}

/// The spending limits (general and by category) that today's spending went over. A day on which
/// a limit does not apply raises nothing.
List<LimitAlert> limitAlerts(
  Ledger ledger,
  List<DailyTarget> targets,
  ISODate today,
) {
  final out = <LimitAlert>[];
  final seen = <Id?>{};
  for (final t in targets) {
    if (t.kind != DailyTarget.spendLimit || !seen.add(t.categoryId)) continue;
    final inForce = targetOn(
      targets,
      DailyTarget.spendLimit,
      today,
      categoryId: t.categoryId,
    );
    if (inForce == null) continue;
    final day = spendLimitHistory(
      ledger,
      targets,
      today,
      categoryId: t.categoryId,
    ).where((d) => d.date == today).firstOrNull;
    if (day != null && !day.within) {
      out.add(LimitAlert(target: inForce, day: day));
    }
  }
  return out;
}

/// The categories that have (or had this month) a daily limit of their own.
List<Id> limitedCategories(List<DailyTarget> targets) => {
  for (final t in targets)
    if (t.kind == DailyTarget.spendLimit && t.categoryId != null) t.categoryId!,
}.toList();

/// The month so far. With [categoryId] the spending figures are those of that category (and its
/// subcategories); what was received and the balances are always of everything, because income
/// and money in the accounts do not belong to an expense category.
DailySummary dailySummary(Ledger ledger, ISODate today, {Id? categoryId}) {
  final month = monthKeyOf(today);
  final first = startOfMonth(month);
  final flow = dailyFlow(
    ledger,
    month,
    today,
  ).where((d) => compareISO(d.date, today) <= 0).toList();
  final yesterday = addDays(today, -1);
  final prevMonth = addMonthsToKey(month, -1);
  final hasPrev = ledger.transactions.any(
    (t) => isActive(t) && monthKeyOf(t.date) == prevMonth,
  );
  Cents spent(ISODate d) => spentOn(ledger, d, categoryId: categoryId);
  Cents? prevSameDays;
  if (hasPrev) {
    // The same number of days of the previous month, or the whole of it when it is shorter.
    final prevFirst = startOfMonth(prevMonth), prevLast = endOfMonth(prevMonth);
    final until = addDays(prevFirst, flow.length - 1);
    prevSameDays = spentBetween(
      ledger,
      prevFirst,
      compareISO(until, prevLast) > 0 ? prevLast : until,
      categoryId: categoryId,
    );
  }
  DayFlow? on(ISODate d) => flow.where((x) => x.date == d).firstOrNull;
  return DailySummary(
    today: today,
    spentTodayCents: spent(today),
    spentYesterdayCents: spent(yesterday),
    receivedTodayCents: on(today)?.incomeCents ?? 0,
    receivedYesterdayCents: monthKeyOf(yesterday) == month
        ? (on(yesterday)?.incomeCents ?? 0)
        : sumCents(
            ledger.transactions
                .where(
                  (t) => isActive(t) && isIncomeLike(t) && t.date == yesterday,
                )
                .map(effectiveCents),
          ),
    spentMonthCents: spentBetween(ledger, first, today, categoryId: categoryId),
    receivedMonthCents: sumCents(flow.map((d) => d.incomeCents)),
    daysElapsed: flow.length,
    daysWithSpending: flow.where((d) => spent(d.date) > 0).length,
    openingBalanceCents: openingBalance(ledger, month),
    balanceTodayCents: consolidatedBalance(ledger, asOf: today),
    previousMonthSameDaysCents: prevSameDays,
  );
}

/// A daily target, valid for a period.
class DailyTarget {
  const DailyTarget({
    required this.id,
    required this.kind,
    required this.amountCents,
    this.categoryId,
    this.weekdays = const [],
    required this.validFrom,
    this.validUntil,
    this.carryOver = false,
    this.goalId,
  });
  final String id;

  /// For a saving target: only deposits into this goal count. Null = any goal.
  final Id? goalId;

  /// `spend_limit` (most that should be spent in a day) or `saving` (amount to set aside a day).
  final String kind;
  final Cents amountCents;

  /// For a spending limit: only this category (and its subcategories). Null = all spending.
  final Id? categoryId;

  /// 1 = Monday … 7 = Sunday. Empty = every day.
  final List<int> weekdays;

  /// First day the target applies.
  final ISODate validFrom;

  /// First day it no longer applies (it was replaced or ended).
  final ISODate? validUntil;

  /// Whether what was not spent on earlier days of the month adds to today's limit. Off unless the
  /// user turns it on: an unused limit does not become money on its own.
  final bool carryOver;

  static const spendLimit = 'spend_limit', saving = 'saving';

  factory DailyTarget.fromJson(Map<String, dynamic> j) => DailyTarget(
    id: j['id'] as String,
    kind: j['kind'] as String,
    amountCents: (j['amountCents'] as num).toInt(),
    categoryId: j['categoryId'] as String?,
    weekdays: [
      for (final w in j['weekdays'] as List? ?? const []) (w as num).toInt(),
    ],
    validFrom: j['validFrom'] as String,
    validUntil: j['validUntil'] as String?,
    carryOver: j['carryOver'] as bool? ?? false,
    goalId: j['goalId'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'amountCents': amountCents,
    if (categoryId != null) 'categoryId': categoryId,
    if (weekdays.isNotEmpty) 'weekdays': weekdays,
    'validFrom': validFrom,
    if (validUntil != null) 'validUntil': validUntil,
    if (carryOver) 'carryOver': true,
    if (goalId != null) 'goalId': goalId,
  };

  DailyTarget endedOn(ISODate day) => DailyTarget(
    id: id,
    kind: kind,
    amountCents: amountCents,
    categoryId: categoryId,
    weekdays: weekdays,
    validFrom: validFrom,
    validUntil: day,
    carryOver: carryOver,
    goalId: goalId,
  );
}

int _weekday(ISODate d) {
  final p = parts(d);
  return DateTime.utc(p.year, p.month, p.day).weekday;
}

/// Whether [t] applies on [day]: inside its period and on one of its weekdays.
bool targetAppliesOn(DailyTarget t, ISODate day) {
  if (compareISO(day, t.validFrom) < 0) return false;
  if (t.validUntil != null && compareISO(day, t.validUntil!) >= 0) return false;
  return t.weekdays.isEmpty || t.weekdays.contains(_weekday(day));
}

/// The target of a kind (and category) in force on [day], if any.
DailyTarget? targetOn(
  List<DailyTarget> targets,
  String kind,
  ISODate day, {
  Id? categoryId,
}) {
  DailyTarget? best;
  for (final t in targets) {
    if (t.kind != kind || t.categoryId != categoryId) continue;
    if (!targetAppliesOn(t, day)) continue;
    if (best == null || compareISO(t.validFrom, best.validFrom) > 0) best = t;
  }
  return best;
}

/// The target of a kind (and category) whose period includes [day], whether or not [day] is one of
/// its weekdays: what the user has set, as opposed to what applies on that particular day.
DailyTarget? targetSetOn(
  List<DailyTarget> targets,
  String kind,
  ISODate day, {
  Id? categoryId,
}) {
  DailyTarget? best;
  for (final t in targets) {
    if (t.kind != kind || t.categoryId != categoryId) continue;
    if (compareISO(day, t.validFrom) < 0) continue;
    if (t.validUntil != null && compareISO(day, t.validUntil!) >= 0) continue;
    if (best == null || compareISO(t.validFrom, best.validFrom) > 0) best = t;
  }
  return best;
}

/// Replaces the target of the same kind and category from [today] on: the one in force is ended
/// today and the new one starts today, so every earlier day keeps what it had.
List<DailyTarget> setTarget(
  List<DailyTarget> targets,
  DailyTarget next,
  ISODate today,
) => [
  for (final t in targets)
    if (t.kind != next.kind || t.categoryId != next.categoryId)
      t
    // A target that would start and end on the same day never applied: it is dropped.
    else if (compareISO(t.validFrom, today) < 0)
      (t.validUntil == null || compareISO(t.validUntil!, today) > 0)
          ? t.endedOn(today)
          : t,
  next,
];

/// Ends the target of a kind and category today, keeping its past.
List<DailyTarget> endTarget(
  List<DailyTarget> targets,
  String kind,
  ISODate today, {
  Id? categoryId,
}) => [
  for (final t in targets)
    if (t.kind != kind || t.categoryId != categoryId)
      t
    else if (compareISO(t.validFrom, today) < 0)
      (t.validUntil == null || compareISO(t.validUntil!, today) > 0)
          ? t.endedOn(today)
          : t,
];

class SpendLimitDay {
  const SpendLimitDay({
    required this.date,
    required this.limitCents,
    required this.carriedCents,
    required this.spentCents,
  });
  final ISODate date;

  /// The limit of the target in force that day.
  final Cents limitCents;

  /// What earlier days of the month left unused (or overspent), when the target carries over.
  final Cents carriedCents;
  final Cents spentCents;
  Cents get availableCents => limitCents + carriedCents;
  Cents get remainingCents => availableCents - spentCents;
  bool get within => spentCents <= availableCents;
}

/// The spending limit day by day, from the start of [today]'s month up to today. Days without a
/// target in force are simply absent: there was nothing to compare them with.
List<SpendLimitDay> spendLimitHistory(
  Ledger ledger,
  List<DailyTarget> targets,
  ISODate today, {
  Id? categoryId,
}) {
  final out = <SpendLimitDay>[];
  var carried = 0;
  for (
    var d = startOfMonth(monthKeyOf(today));
    compareISO(d, today) <= 0;
    d = addDays(d, 1)
  ) {
    final t = targetOn(
      targets,
      DailyTarget.spendLimit,
      d,
      categoryId: categoryId,
    );
    if (t == null) {
      carried = 0;
      continue;
    }
    final spent = spentOn(ledger, d, categoryId: categoryId);
    final day = SpendLimitDay(
      date: d,
      limitCents: t.amountCents,
      carriedCents: t.carryOver ? carried : 0,
      spentCents: spent,
    );
    out.add(day);
    carried = t.carryOver ? day.remainingCents : 0;
  }
  return out;
}

class SavingDay {
  const SavingDay({
    required this.date,
    required this.targetCents,
    required this.confirmedCents,
  });
  final ISODate date;
  final Cents targetCents;

  /// Money actually set aside that day: deposits into goals, minus withdrawals.
  final Cents confirmedCents;
  Cents get pendingCents =>
      (targetCents - confirmedCents).clamp(0, maxSafeCents);
  bool get met => confirmedCents >= targetCents;
}

Cents savedOn(Ledger ledger, ISODate date, {Id? goalId}) {
  var total = 0;
  for (final t in ledger.transactions) {
    if (!isActive(t) || t.date != date) continue;
    if (goalId != null && t.goalId != goalId) continue;
    if (t.kind == TransactionKind.goalDeposit) {
      total = addCents(total, effectiveCents(t));
    } else if (t.kind == TransactionKind.goalWithdrawal) {
      total = subCents(total, effectiveCents(t));
    }
  }
  return total;
}

/// The saving target day by day in [today]'s month, up to today. What counts is what was put into
/// goals; spending under a limit is not counted as saved.
List<SavingDay> savingHistory(
  Ledger ledger,
  List<DailyTarget> targets,
  ISODate today,
) {
  final out = <SavingDay>[];
  for (
    var d = startOfMonth(monthKeyOf(today));
    compareISO(d, today) <= 0;
    d = addDays(d, 1)
  ) {
    final t = targetOn(targets, DailyTarget.saving, d);
    if (t == null) continue;
    out.add(
      SavingDay(
        date: d,
        targetCents: t.amountCents,
        confirmedCents: savedOn(ledger, d, goalId: t.goalId),
      ),
    );
  }
  return out;
}
