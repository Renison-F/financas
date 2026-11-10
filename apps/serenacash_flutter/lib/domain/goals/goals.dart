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

/// Where a year sits relative to today when a goal is looked at from inside that year.
enum GoalYearPhase { past, current, future }

/// A goal as seen from one calendar year. A past year only shows facts: what was put aside then.
/// The current and the future years show what is still missing as of today.
class GoalYearView {
  const GoalYearView({
    required this.goal,
    required this.phase,
    required this.savedInYearCents,
    required this.savedByYearEndCents,
    required this.remainingCents,
    required this.percent,
    this.expectedPercent,
    this.monthlyCents,
    this.monthlyUntilTargetDate = false,
  });
  final Goal goal;
  final GoalYearPhase phase;

  /// Deposits minus withdrawals dated inside the year.
  final Cents savedInYearCents;

  /// Everything put aside up to the last day of the year (or up to today, for the current year).
  final Cents savedByYearEndCents;

  /// What is missing today. Zero for a past year: "missing" has no meaning looking back.
  final Cents remainingCents;
  final double percent;
  final double? expectedPercent;

  /// Suggested amount per month, when there is a basis for one.
  final Cents? monthlyCents;

  /// True when [monthlyCents] comes from the goal's own target date; false when it only spreads
  /// what is missing over the months left in the year (an assumption, shown as such).
  final bool monthlyUntilTargetDate;
}

Cents _goalSavedBetween(Ledger ledger, Id goalId, ISODate? from, ISODate to) {
  var total = 0;
  for (final t in ledger.transactions) {
    if (!isActive(t) || t.goalId != goalId) continue;
    if (compareISO(t.date, to) > 0) continue;
    if (from != null && compareISO(t.date, from) < 0) continue;
    if (t.kind == TransactionKind.goalDeposit) {
      total = addCents(total, effectiveCents(t));
    }
    if (t.kind == TransactionKind.goalWithdrawal) {
      total = addCents(total, -effectiveCents(t));
    }
  }
  return total;
}

/// The year a goal started to exist: when it was created or, when that is unknown, its first entry.
int? goalStartYear(Ledger ledger, Goal goal) {
  if (goal.createdAt.length >= 4) {
    final y = int.tryParse(goal.createdAt.substring(0, 4));
    if (y != null) return y;
  }
  int? first;
  for (final t in ledger.transactions) {
    if (!isActive(t) || t.goalId != goal.id) continue;
    final y = int.parse(t.date.substring(0, 4));
    if (first == null || y < first) first = y;
  }
  return first;
}

/// Goals that belong in the planning of [year]. A goal never appears in a year before it existed,
/// and a past year never shows a suggestion: it shows what happened.
List<GoalYearView> goalsForYear(Ledger ledger, int year, ISODate today) {
  final thisYear = int.parse(today.substring(0, 4));
  final yearStart = '${year.toString().padLeft(4, '0')}-01-01';
  final yearEnd = '${year.toString().padLeft(4, '0')}-12-31';
  final out = <GoalYearView>[];
  for (final g in ledger.goals) {
    if (g.deletedAt != null) continue;
    final start = goalStartYear(ledger, g);
    if (year < thisYear) {
      if (start == null || start > year) continue;
      final inYear = _goalSavedBetween(ledger, g.id, yearStart, yearEnd);
      final byEnd = _goalSavedBetween(ledger, g.id, null, yearEnd);
      out.add(
        GoalYearView(
          goal: g,
          phase: GoalYearPhase.past,
          savedInYearCents: inYear,
          savedByYearEndCents: byEnd,
          remainingCents: 0,
          percent: g.targetCents > 0 ? _round1(byEnd / g.targetCents * 100) : 0,
        ),
      );
      continue;
    }
    if (!g.isActive) continue;
    final p = goalProgress(ledger, g, today);
    if (p.remainingCents <= 0) continue;
    if (year == thisYear) {
      final monthsLeftInYear = 13 - int.parse(today.substring(5, 7));
      out.add(
        GoalYearView(
          goal: g,
          phase: GoalYearPhase.current,
          savedInYearCents: _goalSavedBetween(ledger, g.id, yearStart, today),
          savedByYearEndCents: p.savedCents,
          remainingCents: p.remainingCents,
          percent: p.percent,
          expectedPercent: p.expectedPercent,
          monthlyCents:
              p.suggestedMonthlyCents ??
              divCents(
                p.remainingCents,
                monthsLeftInYear.toDouble(),
                RoundingMode.halfUp,
              ),
          monthlyUntilTargetDate: p.suggestedMonthlyCents != null,
        ),
      );
      continue;
    }
    // A future year: only goals still running then (a target date in that year or later, or none).
    final target = g.targetDate;
    if (target != null && int.parse(target.substring(0, 4)) < year) continue;
    out.add(
      GoalYearView(
        goal: g,
        phase: GoalYearPhase.future,
        savedInYearCents: 0,
        savedByYearEndCents: p.savedCents,
        remainingCents: p.remainingCents,
        percent: p.percent,
        monthlyCents: p.suggestedMonthlyCents,
        monthlyUntilTargetDate: p.suggestedMonthlyCents != null,
      ),
    );
  }
  return out;
}
