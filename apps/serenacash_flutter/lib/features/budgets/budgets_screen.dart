import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/categories/categories.dart';
import '../../domain/billing/billing.dart';
import '../../domain/budgets/budgets.dart';
import '../../domain/dates/dates.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../cards/cards_screen.dart';
import '../home/widgets.dart';
import '../categories/category_widgets.dart';
import '../shared/stack_screen.dart';

class MonthChips extends StatelessWidget {
  const MonthChips({super.key, required this.month, required this.onChanged});
  final String month;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      SChip(
        label: '‹ ${monthShortKey(addMonthsToKey(month, -1))}',
        onTap: () => onChanged(addMonthsToKey(month, -1)),
      ),
      SChip(label: monthShortKey(month), selected: true),
      SChip(
        label: '${monthShortKey(addMonthsToKey(month, 1))} ›',
        onTap: () => onChanged(addMonthsToKey(month, 1)),
      ),
    ],
  );
}

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});
  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  late String _month = monthKeyOf(ref.read(todayProvider));
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final statuses = budgetsForMonth(s.ledger, _month, s.today);
    String brl(int v) => formatBRL(v, hidden: hidden);
    return StackScreen(
      title: l.budgets,
      actions: [
        SButton(
          label: l.new_,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.plus,
          onPressed: () => context.push('/budgets/new'),
        ),
      ],
      children: [
        MonthChips(month: _month, onChanged: (m) => setState(() => _month = m)),
        if (statuses.isEmpty)
          SCard(
            child: EmptyState(
              icon: SIconName.plan,
              title: l.noBudget,
              text: l.noBudgetListText,
              actionLabel: l.createBudget,
              onAction: () => context.push('/budgets/new'),
            ),
          )
        else
          for (final b in statuses)
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
                              b.category?.name ?? l.monthlyBudget,
                              style: Type.title.copyWith(color: c.text),
                            ),
                            Text(
                              '${brl(b.spentCents)} ${l.ofLimit(brl(b.limitCents))}${b.plannedCents > 0 ? l.plannedSuffix(brl(b.plannedCents)) : ''}',
                              style: Type.bodySmall.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Money(b.remainingCents, signed: true, hidden: hidden),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RhythmBar(
                    percent: b.percentUsed,
                    expectedPercent: b.expectedPercent,
                    state: b.pace,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l.paceUsed(
                            paceLabel(l, b.pace),
                            b.percentUsed.round(),
                            b.expectedPercent.round(),
                          ),
                          style: Type.label.copyWith(
                            color: b.pace == PaceStatus.sereno
                                ? c.positive
                                : b.pace == PaceStatus.atencao
                                ? c.warning
                                : c.negative,
                          ),
                        ),
                      ),
                      SButton(
                        label: l.edit,
                        variant: SButtonVariant.ghost,
                        compact: true,
                        onPressed: () =>
                            context.push('/budgets/new?id=${b.budget.id}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        Text(l.budgetRules, style: Type.caption.copyWith(color: c.textMuted)),
      ],
    );
  }
}

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({super.key, this.id});
  final String? id;
  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  late final existing = widget.id == null
      ? null
      : ref
            .read(ledgerProvider)
            .budgets
            .where((b) => b.id == widget.id)
            .firstOrNull;
  late String? _categoryId = existing?.categoryId;
  late int? _limit = existing?.limitCents;
  late bool _onlyThisMonth = existing?.month != null;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final ctl = ref.read(appControllerProvider.notifier);
    final lim = withinLimit(
      s.access,
      'budgets',
      s.ledger.budgets.where((b) => b.deletedAt == null).length,
    );
    return StackScreen(
      title: existing != null ? l.editBudget : l.newBudget,
      actions: [
        SButton(
          label: l.save,
          variant: SButtonVariant.ghost,
          onPressed: () async {
            if ((_limit ?? 0) <= 0) return setState(() => _error = l.limitErr);
            if (existing == null && !lim.ok) {
              unawaited(context.push('/paywall?feature=unlimited_budgets'));
              return;
            }
            await ctl.saveBudget(
              id: existing?.id,
              categoryId: _categoryId,
              limitCents: _limit!,
              month: _onlyThisMonth ? monthKeyOf(s.today) : null,
            );
            if (context.mounted) context.pop();
          },
        ),
      ],
      children: [
        Field(
          label: l.forLabel,
          // A budget for a main category already counts what is spent in its subcategories.
          child: SCard(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            onTap: () async {
              final choice = await showCategoryPicker(
                context,
                kind: 'expense',
                selectedId: _categoryId,
                allowNone: true,
                noneLabel: l.wholeMonth,
              );
              if (choice != null && mounted) {
                setState(() => _categoryId = choice.id);
              }
            },
            child: () {
              final cat = s.ledger.categoryById(_categoryId);
              return ListRow(
                leading: cat == null
                    ? IconTile(
                        icon: SIconName.calendar,
                        color: c.textMuted,
                        background: c.surfaceInset,
                      )
                    : CategoryMark.of(cat),
                title: cat == null
                    ? l.wholeMonth
                    : (categoryPath(s.ledger, cat.id) ?? cat.name),
                titleMaxLines: 2,
                chevron: true,
              );
            }(),
          ),
        ),
        MoneyField(
          label: l.monthlyLimit,
          cents: _limit,
          onChanged: (v) => setState(() => _limit = v),
          error: _error,
          autofocus: existing == null,
        ),
        ToggleRow(
          label: l.onlyThisMonth,
          value: _onlyThisMonth,
          help: l.onlyThisMonthHelp,
          onChanged: (v) => setState(() => _onlyThisMonth = v),
        ),
        if (!lim.ok && existing == null)
          Text(
            l.freeLimitBudgets(lim.limit ?? 0),
            style: Type.bodySmall.copyWith(color: c.warning),
          ),
        if (existing != null)
          SButton(
            label: l.deleteBudget,
            variant: SButtonVariant.destructive,
            icon: SIconName.trash,
            fullWidth: true,
            onPressed: () async {
              final ok = await confirmSheet(
                context,
                title: l.deleteBudgetQ,
                text: l.deleteBudgetText,
                confirmLabel: l.delete,
                cancelLabel: l.cancel,
              );
              if (!ok) return;
              await ctl.deleteBudget(existing!.id);
              if (context.mounted) context.pop();
            },
          ),
      ],
    );
  }
}
