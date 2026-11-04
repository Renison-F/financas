import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/app_state.dart';
import '../../app/theme/tokens.dart';
import '../../domain/billing/billing.dart';
import '../../domain/entities/entities.dart';
import '../../domain/goals/goals.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

String goalKindLabel(AppLocalizations l, String k) => switch (k) {
  'savings' => l.goalKindSavings,
  'emergency_fund' => l.goalKindEmergency,
  'purchase' => l.goalKindPurchase,
  'debt_payoff' => l.goalKindDebt,
  _ => l.goalKindOther,
};

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final goals = s.ledger.goals
        .where((g) => g.isActive)
        .map((g) => goalProgress(s.ledger, g, s.today))
        .toList();
    String brl(int v) => formatBRL(v, hidden: hidden);
    return StackScreen(
      title: l.goalsAndReserves,
      actions: [
        SButton(
          label: l.newF,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.plus,
          onPressed: () => context.push('/goals/new'),
        ),
      ],
      children: [
        if (goals.isEmpty)
          SCard(
            child: EmptyState(
              icon: SIconName.target,
              title: l.noGoal,
              text: l.noGoalListText,
              actionLabel: l.createGoal,
              onAction: () => context.push('/goals/new'),
            ),
          )
        else
          for (final p in goals)
            SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.goal.name,
                              style: Type.title.copyWith(color: c.text),
                            ),
                            Text(
                              '${goalKindLabel(l, p.goal.kind)}${p.goal.reserved ? l.protectedSuffix : ''}${p.goal.targetDate != null ? l.untilDate(fmtDateBR(p.goal.targetDate!)) : ''}',
                              style: Type.bodySmall.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Money(
                        p.savedCents,
                        role: MoneyRole.title,
                        hidden: hidden,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RhythmBar(
                    percent: p.percent,
                    expectedPercent: p.expectedPercent,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l.goalSummary(p.percent.round(), brl(p.goal.targetCents), brl(p.remainingCents))}${p.suggestedMonthlyCents != null ? l.saveMonthly(brl(p.suggestedMonthlyCents!), p.monthsLeft ?? 0) : ''}',
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      SButton(
                        label: l.deposit,
                        variant: SButtonVariant.secondary,
                        compact: true,
                        onPressed: () =>
                            context.push('/goals/${p.goal.id}?action=deposit'),
                      ),
                      SButton(
                        label: l.withdraw,
                        variant: SButtonVariant.ghost,
                        compact: true,
                        onPressed: () =>
                            context.push('/goals/${p.goal.id}?action=withdraw'),
                      ),
                      SButton(
                        label: l.edit,
                        variant: SButtonVariant.ghost,
                        compact: true,
                        onPressed: () =>
                            context.push('/goals/new?id=${p.goal.id}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.id, this.action});
  final String id;
  final String? action;
  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  late String _mode = widget.action == 'withdraw' ? 'withdraw' : 'deposit';
  int? _amount;
  String? _accountId;
  late String _date = ref.read(todayProvider);
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final goal = s.ledger.goalById(widget.id);
    if (goal == null) {
      return StackScreen(
        title: l.goals,
        children: [EmptyState(icon: SIconName.alert, title: l.goalNotFound)],
      );
    }
    _accountId ??=
        goal.accountId ??
        s.ledger.accounts.where((a) => a.isActive).firstOrNull?.id;
    final p = goalProgress(s.ledger, goal, s.today);
    final moves =
        s.ledger.transactions
            .where((t) => t.goalId == goal.id && t.deletedAt == null)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    String brl(int v) => formatBRL(v, hidden: hidden);
    return StackScreen(
      title: goal.name,
      actions: [
        SButton(
          label: l.edit,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.edit,
          onPressed: () => context.push('/goals/new?id=${goal.id}'),
        ),
      ],
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.saved, style: Type.label.copyWith(color: c.textMuted)),
              Money(p.savedCents, role: MoneyRole.headline, hidden: hidden),
              const SizedBox(height: 10),
              RhythmBar(percent: p.percent, expectedPercent: p.expectedPercent),
              const SizedBox(height: 6),
              Text(
                '${l.goalSummary(p.percent.round(), brl(goal.targetCents), brl(p.remainingCents))}${p.suggestedMonthlyCents != null ? l.suggestionMonthly(brl(p.suggestedMonthlyCents!)) : ''}',
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Segmented<String>(
                options: [('deposit', l.deposit), ('withdraw', l.withdraw)],
                value: _mode,
                onChanged: (v) => setState(() => _mode = v),
              ),
              const SizedBox(height: Spacing.sm),
              MoneyField(
                label: l.amount,
                cents: _amount,
                onChanged: (v) => setState(() => _amount = v),
              ),
              const SizedBox(height: Spacing.sm),
              Field(
                label: _mode == 'deposit' ? l.leavesAccount : l.goesToAccount,
                child: ChipSelect<String>(
                  options: [
                    for (final a in s.ledger.accounts.where((a) => a.isActive))
                      (a.id, a.name),
                  ],
                  value: _accountId,
                  onChanged: (v) => setState(() => _accountId = v),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              DateField(
                label: l.date,
                value: _date,
                onChanged: (d) => setState(() => _date = d),
                today: s.today,
                todayLabel: l.today,
                yesterdayLabel: l.yesterday,
                tomorrowLabel: l.tomorrow,
                invalidLabel: l.invalidDate,
              ),
              const SizedBox(height: Spacing.sm),
              SButton(
                label: _mode == 'deposit' ? l.deposit : l.withdraw,
                fullWidth: true,
                loading: _busy,
                onPressed:
                    (_amount ?? 0) <= 0 ||
                        (_accountId == null && goal.accountId == null)
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        try {
                          final ctl = ref.read(appControllerProvider.notifier);
                          if (_mode == 'deposit') {
                            await ctl.saveTransaction(
                              TransactionInput(
                                kind: TransactionKind.goalDeposit,
                                amountCents: _amount!,
                                date: _date,
                                description: l.depositDesc(goal.name),
                                accountId: _accountId,
                                toAccountId: goal.accountId,
                                goalId: goal.id,
                                status: TransactionStatus.settled,
                              ),
                            );
                          } else {
                            await ctl.saveTransaction(
                              TransactionInput(
                                kind: TransactionKind.goalWithdrawal,
                                amountCents: _amount!,
                                date: _date,
                                description: l.withdrawDesc(goal.name),
                                accountId: goal.accountId ?? _accountId,
                                toAccountId: _accountId,
                                goalId: goal.id,
                                status: TransactionStatus.settled,
                              ),
                            );
                          }
                          setState(() => _amount = null);
                        } on AppError catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.movements),
              if (moves.isEmpty)
                Text(
                  l.noMovementsYet,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final t in moves)
                  ListRow(
                    icon: t.kind == TransactionKind.goalDeposit
                        ? SIconName.arrowUp
                        : SIconName.arrowDown,
                    title: t.description,
                    description: fmtDateBR(t.date),
                    trailing: Money(
                      t.kind == TransactionKind.goalDeposit
                          ? t.amountCents
                          : -t.amountCents,
                      signed: true,
                      hidden: hidden,
                    ),
                    onTap: () => context.push('/transaction?id=${t.id}'),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key, this.id});
  final String? id;
  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  late final existing = widget.id == null
      ? null
      : ref.read(ledgerProvider).goalById(widget.id);
  late final _name = TextEditingController(text: existing?.name ?? '');
  late String _kind = existing?.kind ?? 'emergency_fund';
  late int? _target = existing?.targetCents;
  late bool _hasDate = existing?.targetDate != null;
  late String _date = existing?.targetDate ?? ref.read(todayProvider);
  late String? _accountId = existing?.accountId;
  late bool _reserved = existing?.reserved ?? true;
  late bool _archived = existing?.archived ?? false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final lim = withinLimit(
      s.access,
      'goals',
      s.ledger.goals.where((g) => g.isActive).length,
    );
    return StackScreen(
      title: existing != null ? l.editGoal : l.newGoal,
      actions: [
        SButton(
          label: l.save,
          variant: SButtonVariant.ghost,
          onPressed: () async {
            if (_name.text.trim().isEmpty) {
              return setState(() => _error = l.nameGoalErr);
            }
            if ((_target ?? 0) <= 0) {
              return setState(() => _error = l.goalAmountErr);
            }
            if (existing == null && !lim.ok) {
              unawaited(context.push('/paywall?feature=unlimited_goals'));
              return;
            }
            await ref
                .read(appControllerProvider.notifier)
                .saveGoal(
                  id: existing?.id,
                  name: _name.text.trim(),
                  kind: _kind,
                  targetCents: _target!,
                  targetDate: _hasDate ? _date : null,
                  accountId: _accountId,
                  reserved: _reserved,
                  archived: _archived,
                );
            if (context.mounted) context.pop();
          },
        ),
      ],
      children: [
        STextField(
          label: l.name,
          controller: _name,
          placeholder: l.goalNameHint,
          autofocus: existing == null,
          error: _error != null && _name.text.trim().isEmpty ? _error : null,
        ),
        Field(
          label: l.type,
          child: ChipSelect<String>(
            options: [
              for (final k in const [
                'emergency_fund',
                'savings',
                'purchase',
                'debt_payoff',
                'other',
              ])
                (k, goalKindLabel(l, k)),
            ],
            value: _kind,
            onChanged: (v) => setState(() => _kind = v ?? 'other'),
          ),
        ),
        MoneyField(
          label: l.goalAmount,
          cents: _target,
          onChanged: (v) => setState(() => _target = v),
          error: _error != null && (_target ?? 0) <= 0 ? _error : null,
        ),
        ToggleRow(
          label: l.hasDeadline,
          value: _hasDate,
          onChanged: (v) => setState(() => _hasDate = v),
        ),
        if (_hasDate)
          DateField(
            label: l.untilWhen,
            value: _date,
            onChanged: (d) => setState(() => _date = d),
            today: s.today,
            todayLabel: l.today,
            yesterdayLabel: l.yesterday,
            tomorrowLabel: l.tomorrow,
            invalidLabel: l.invalidDate,
          ),
        Field(
          label: l.whereMoney,
          help: l.whereMoneyHelp,
          child: ChipSelect<String>(
            options: [
              ('__none__', l.outsideApp),
              for (final a in s.ledger.accounts.where((a) => a.isActive))
                (a.id, a.name),
            ],
            value: _accountId ?? '__none__',
            onChanged: (v) =>
                setState(() => _accountId = v == '__none__' ? null : v),
          ),
        ),
        ToggleRow(
          label: l.protectFromAvail,
          value: _reserved,
          help: l.protectHelp,
          onChanged: (v) => setState(() => _reserved = v),
        ),
        if (existing != null)
          ToggleRow(
            label: l.archiveGoal,
            value: _archived,
            onChanged: (v) => setState(() => _archived = v),
          ),
        if (!lim.ok && existing == null)
          Text(
            l.freeLimitGoals(lim.limit ?? 0),
            style: Type.bodySmall.copyWith(color: c.warning),
          ),
      ],
    );
  }
}
