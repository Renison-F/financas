import { addCents, divCents, sumCents, type Cents } from '../money/money';
import { compareISO, diffDays, type ISODate } from '../dates/dates';
import type { Goal, Ledger } from './types';
import { isActive, effectiveCents } from './ledger';

export function goalSavedCents(ledger: Ledger, goalId: string): Cents {
  let total = 0;
  for (const t of ledger.transactions) {
    if (!isActive(t) || t.goalId !== goalId) continue;
    if (t.kind === 'goal_deposit') total = addCents(total, effectiveCents(t));
    else if (t.kind === 'goal_withdrawal') total = addCents(total, -effectiveCents(t));
  }
  return total;
}

export interface GoalProgress {
  goal: Goal;
  savedCents: Cents;
  remainingCents: Cents;
  percent: number; // 0..100+, 1 decimal
  /** suggested monthly deposit to reach the target by targetDate, when it has one and is in the future */
  suggestedMonthlyCents?: Cents | undefined;
  monthsLeft?: number | undefined;
  /** expected progress by now (time-based), for the "marca de hoje" marker */
  expectedPercent?: number | undefined;
}

export function goalProgress(ledger: Ledger, goal: Goal, today: ISODate): GoalProgress {
  const savedCents = goalSavedCents(ledger, goal.id);
  const remainingCents = Math.max(0, goal.targetCents - savedCents);
  const percent = goal.targetCents > 0 ? Math.round((savedCents / goal.targetCents) * 1000) / 10 : 0;
  const out: GoalProgress = { goal, savedCents, remainingCents, percent };
  if (goal.targetDate && compareISO(goal.targetDate, today) > 0) {
    const days = diffDays(today, goal.targetDate);
    const monthsLeft = Math.max(1, Math.ceil(days / 30.4375));
    out.monthsLeft = monthsLeft;
    out.suggestedMonthlyCents = remainingCents === 0 ? 0 : divCents(remainingCents, monthsLeft, 'half-up');
    const start = goal.createdAt.slice(0, 10);
    const totalDays = diffDays(start, goal.targetDate);
    if (totalDays > 0) out.expectedPercent = Math.min(100, Math.max(0, Math.round((diffDays(start, today) / totalDays) * 1000) / 10));
  }
  return out;
}

export function totalReservedCents(ledger: Ledger): Cents {
  return sumCents(ledger.goals.filter((g) => g.reserved && !g.archived && !g.deletedAt).map((g) => goalSavedCents(ledger, g.id)));
}
