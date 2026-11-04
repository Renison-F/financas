/// Goals/reserves. Mirrors `packages/core/src/domain/goals.ts`.
library;

import '../dates/dates.dart';
import '../entities/entities.dart';
import '../ledger/ledger.dart';
import '../money/money.dart';

Cents goalSavedCents(Ledger ledger, Id goalId) {
  var total = 0;
  for (final t in ledger.transactions) {
    if (!isActive(t) || t.goalId != goalId) continue;
    if (t.kind == TransactionKind.goalDeposit) {
      total = addCents(total, effectiveCents(t));
    }
    if (t.kind == TransactionKind.goalWithdrawal) {
      total = addCents(total, -effectiveCents(t));
    }
  }
  return total;
}

class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.savedCents,
    required this.remainingCents,
    required this.percent,
    this.suggestedMonthlyCents,
    this.monthsLeft,
    this.expectedPercent,
  });
  final Goal goal;
  final Cents savedCents;
  final Cents remainingCents;
  final double percent;
  final Cents? suggestedMonthlyCents;
  final int? monthsLeft;
  final double? expectedPercent;
  Map<String, dynamic> toJson() => {
    'goal': goal.id,
    'savedCents': savedCents,
    'remainingCents': remainingCents,
    'percent': percent,
    if (suggestedMonthlyCents != null)
      'suggestedMonthlyCents': suggestedMonthlyCents,
    if (monthsLeft != null) 'monthsLeft': monthsLeft,
    if (expectedPercent != null) 'expectedPercent': expectedPercent,
  };
}

double _round1(double v) =>
    (v * 10).roundToDouble() / 10; // JS Math.round(x*10)/10 for positive values

GoalProgress goalProgress(Ledger ledger, Goal goal, ISODate today) {
  final saved = goalSavedCents(ledger, goal.id);
  final remaining = (goal.targetCents - saved).clamp(0, maxSafeCents);
  final percent = goal.targetCents > 0
      ? _round1(saved / goal.targetCents * 100)
      : 0.0;
  Cents? suggested;
  int? monthsLeft;
  double? expected;
  if (goal.targetDate != null && compareISO(goal.targetDate!, today) > 0) {
    final days = diffDays(today, goal.targetDate!);
    monthsLeft = (days / 30.4375).ceil().clamp(1, 1 << 30);
    suggested = remaining == 0
        ? 0
        : divCents(remaining, monthsLeft.toDouble(), RoundingMode.halfUp);
    final start = goal.createdAt.substring(0, 10);
    final totalDays = diffDays(start, goal.targetDate!);
    if (totalDays > 0) {
      expected = _round1(diffDays(start, today) / totalDays * 100)
          .clamp(0, 100);
    }
  }
  return GoalProgress(
    goal: goal,
    savedCents: saved,
    remainingCents: remaining,
    percent: percent,
    suggestedMonthlyCents: suggested,
    monthsLeft: monthsLeft,
    expectedPercent: expected,
  );
}

Cents totalReservedCents(Ledger ledger) => sumCents(
  ledger.goals
      .where((g) => g.reserved && g.isActive)
      .map((g) => goalSavedCents(ledger, g.id)),
);
