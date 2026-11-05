/// Building blocks of the home screen: compact header, the "pode gastar" summary panel, quick actions and
/// the due-date badge. All values come from [DashboardData]; nothing here computes money on its own.
library;

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme/tokens.dart';
import '../../domain/availability/availability.dart';
import '../../domain/dates/dates.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';

/// Greeting with the period as a quiet control underneath (opens period and layout options).
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.period,
    required this.onPeriodTap,
  });
  final String greeting;
  final String period;
  final VoidCallback onPeriodTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          greeting,
          style: Type.headline.copyWith(color: c.text, fontSize: 24),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Semantics(
          button: true,
          label: l.periodControl(period),
          excludeSemantics: true,
          child: InkWell(
            onTap: onPeriodTap,
            borderRadius: BorderRadius.circular(Radii.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Touch.target),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      period,
                      style: Type.bodySmall.copyWith(
                        color: c.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Spacing.xxs),
                  SIcon(SIconName.chevronDown, size: 18, color: c.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The focal point of the home screen. With an account it shows "pode gastar" and the two figures that
/// explain it, taken from the same lines the "Como calculamos" screen lists. Without an account the amount
/// is unknown, so it asks for the first account instead of showing R$ 0,00.
class SummaryPanel extends StatelessWidget {
  const SummaryPanel({
    super.key,
    required this.availability,
    required this.hidden,
    required this.onExplain,
    required this.onAddAccount,
  });
  final Availability availability;
  final bool hidden;
  final VoidCallback onExplain;
  final VoidCallback onAddAccount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final av = availability;

    if (!av.hasAccounts) {
      return _Panel(
        color: c.hero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.homeSetupTitle,
              style: Type.headline.copyWith(color: c.onHero),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l.homeSetupText,
              style: Type.bodySmall.copyWith(color: c.onHeroMuted),
            ),
            const SizedBox(height: Spacing.md),
            _OnHeroButton(label: l.addAccount, onPressed: onAddAccount),
          ],
        ),
      );
    }

    final negative = av.status == AvailabilityStatus.negative;
    final bg = negative ? c.negativeContainer : c.hero;
    final fg = negative ? c.negative : c.onHero;
    final muted = negative ? c.negative : c.onHeroMuted;
    final divider = negative
        ? c.negative.withValues(alpha: 0.25)
        : c.heroDivider;
    final date = dayMonth(av.horizonEnd);

    // Same arithmetic as the detail screen: available = Σ sign × cents.
    final balances = av.lines
        .where((x) => x.key == 'balances')
        .fold<int>(0, (a, x) => a + x.cents);
    final committed = av.lines
        .where((x) => x.sign < 0)
        .fold<int>(0, (a, x) => a + x.cents);
    final extraIncome = av.lines
        .where((x) => x.sign > 0 && x.key != 'balances')
        .fold<int>(0, (a, x) => a + x.cents);

    final message = negative
        ? l.availNegative
        : av.status == AvailabilityStatus.tight
        ? l.availTight
        : l.availOk;

    return Semantics(
      button: true,
      hint: l.howWeCalculate,
      child: _Panel(
        color: bg,
        onTap: onExplain,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.canSpendUntil(date),
              style: Type.label.copyWith(color: muted, fontSize: 14),
            ),
            const SizedBox(height: Spacing.xs),
            // Large values and large text scale down instead of being cut.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Money(
                av.availableCents,
                role: MoneyRole.hero,
                color: fg,
                hidden: hidden,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(message, style: Type.bodySmall.copyWith(color: muted)),
            if (extraIncome != 0)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xxs),
                child: Text(
                  l.heroPlannedIncome(formatBRL(extraIncome, hidden: hidden)),
                  style: Type.bodySmall.copyWith(color: muted),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              child: Divider(height: 1, thickness: 1, color: divider),
            ),
            _Figures(
              left: (l.heroBalances, balances),
              right: (l.heroCommitted, committed),
              labelColor: muted,
              valueColor: fg,
              dividerColor: divider,
              hidden: hidden,
            ),
            const SizedBox(height: Spacing.sm),
            // Wraps to two lines when the text scale leaves no room for both.
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: Spacing.sm,
                runSpacing: Spacing.xxs,
                children: [
                  Text(
                    av.mode == 'otimista' ? l.modeOptimistic : l.modePrudent,
                    style: Type.label.copyWith(color: muted),
                  ),
                  Text(
                    l.howWeCalculate,
                    style: Type.label.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.color, required this.child, this.onTap});
  final Color color;
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(Spacing.lg - 4),
      child: child,
    );
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(Radii.lg),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

/// Two labelled amounts side by side; stacked when the text scale or a narrow screen leaves no room.
class _Figures extends StatelessWidget {
  const _Figures({
    required this.left,
    required this.right,
    required this.labelColor,
    required this.valueColor,
    required this.dividerColor,
    required this.hidden,
  });
  final (String, int) left, right;
  final Color labelColor, valueColor, dividerColor;
  final bool hidden;

  // Label on top, amount at the bottom: when one label wraps, the two amounts still share a baseline.
  Widget _figure((String, int) f) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        f.$1,
        style: Type.label.copyWith(color: labelColor),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Money(
          f.$2,
          role: MoneyRole.row,
          color: valueColor,
          hidden: hidden,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < 280 || scale > 1.4) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(child: _figure(left)),
              const SizedBox(height: Spacing.sm),
              IntrinsicHeight(child: _figure(right)),
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _figure(left)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: dividerColor,
                ),
              ),
              Expanded(child: _figure(right)),
            ],
          ),
        );
      },
    );
  }
}

/// Primary action on top of the summary panel: light surface, panel-colored label.
class _OnHeroButton extends StatelessWidget {
  const _OnHeroButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: c.onHero,
        foregroundColor: c.hero,
        minimumSize: const Size(0, Touch.comfortable),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg - 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SIcon(SIconName.plus, size: 20, color: c.hero),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              label,
              // Buttons replace the ambient text style; start from the theme's so the platform
              // font is kept (same approach as SButton).
              style:
                  (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
                      .merge(
                        Type.label.copyWith(
                          fontSize: 16,
                          color: c.hero,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAction {
  const QuickAction(this.icon, this.label, this.onTap);
  final SIconName icon;
  final String label;
  final VoidCallback onTap;
}

/// Up to three shortcuts under the summary. They complement the "+" button (which adds a transaction)
/// instead of repeating it.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions});
  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in actions.take(3))
          Expanded(
            child: Semantics(
              button: true,
              label: a.label,
              excludeSemantics: true,
              child: InkWell(
                onTap: a.onTap,
                borderRadius: BorderRadius.circular(Radii.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Spacing.xs,
                    horizontal: Spacing.xxs,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: Touch.target,
                        height: Touch.target,
                        decoration: BoxDecoration(
                          color: c.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SIcon(
                            a.icon,
                            size: 24,
                            color: c.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        a.label,
                        style: Type.label.copyWith(color: c.text, fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum DueTone { overdue, soon, normal }

/// How a due date reads from [today]: overdue, today, tomorrow, within a week, or the plain date.
({String text, DueTone tone}) dueLabel(
  AppLocalizations l,
  String due,
  String today,
) {
  final days = diffDays(today, due);
  if (days < 0) {
    return (text: l.overdueSince(dayMonth(due)), tone: DueTone.overdue);
  }
  if (days == 0) return (text: l.dueToday, tone: DueTone.soon);
  if (days == 1) return (text: l.dueTomorrow, tone: DueTone.soon);
  if (days <= 7) return (text: l.dueInDays(days), tone: DueTone.normal);
  return (text: l.dueOnDate(dayMonth(due)), tone: DueTone.normal);
}

/// Due date under a bill: tinted pill for overdue and due soon (color plus wording), plain text otherwise.
class DueBadge extends StatelessWidget {
  const DueBadge({super.key, required this.text, required this.tone});
  final String text;
  final DueTone tone;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (tone == DueTone.normal) {
      return Text(
        text,
        style: Type.bodySmall.copyWith(color: c.textMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final (bg, fg) = tone == DueTone.overdue
        ? (c.negativeContainer, c.negative)
        : (c.warningContainer, c.warning);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Radii.xs),
        ),
        child: Text(
          text,
          style: Type.label.copyWith(color: fg, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Static placeholder while the data loads (no shimmer: nothing on this screen moves to call attention).
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget block(double h, {Color? color, double? width}) => Container(
      height: h,
      width: width,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
    );
    return Semantics(
      label: context.l10n.homeLoading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.xl),
              block(200, color: c.surfaceInset),
              const SizedBox(height: Spacing.md),
              block(72),
              const SizedBox(height: Spacing.sm),
              block(72),
            ],
          ),
        ),
      ),
    );
  }
}
