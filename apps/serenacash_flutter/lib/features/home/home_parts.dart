/// Building blocks of the home screen, sized after the reference mockup: compact header, the "pode gastar"
/// summary panel, quick actions, section cards and their dense rows. All values come from
/// [DashboardData]; nothing here computes money on its own.
library;

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme/tokens.dart';
import '../../domain/availability/availability.dart';
import '../../domain/dates/dates.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';

/// Measures of the home screen (logical pixels).
abstract final class HomeMetrics {
  /// Side margin of the cards; the header text sits 4 px further in.
  static const gutter = Layout.gutter;
  static const radius = Radii.md;
  static const cardPadding = EdgeInsets.fromLTRB(14, 12, 14, 8);
  static const tile = Layout.tile;
  static const action = 40.0;
}

/// Greeting with the period as a quiet control underneath. The whole block opens the period and layout
/// options, so the touch target is 48 px even though the period line is small.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.period,
    required this.onPeriodTap,
    this.onPrevious,
    this.onNext,
  });
  final String greeting;
  final String period;
  final VoidCallback onPeriodTap;

  /// Steps to the month before and after the one on screen. Without them (a period that is not a
  /// month) the arrows are not shown.
  final VoidCallback? onPrevious, onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    Widget arrow(SIconName icon, String label, VoidCallback onTap) => Semantics(
      container: true,
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox(
          width: Touch.min,
          height: Touch.min,
          child: Center(child: SIcon(icon, size: 20, color: c.primary)),
        ),
      ),
    );
    final label = Semantics(
      container: true,
      button: true,
      label: '$greeting. ${l.periodControl(period)}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onPeriodTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Touch.target),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xxs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: Type.headline.copyWith(color: c.text, fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        period,
                        style: Type.link.copyWith(color: c.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    SIcon(SIconName.chevronDown, size: 16, color: c.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (onPrevious == null || onNext == null) return label;
    return Row(
      children: [
        Flexible(child: label),
        arrow(SIconName.chevronLeft, l.homePrevMonth, onPrevious!),
        arrow(SIconName.chevronRight, l.homeNextMonth, onNext!),
      ],
    );
  }
}

/// The focal point of the home screen. With an account it shows "pode gastar" and the two figures that
/// explain it, taken from the same lines the "Como calculamos" screen lists (tapping the panel opens it).
/// Without an account the amount is unknown, so it asks for the first account instead of showing R$ 0,00.
class SummaryPanel extends StatelessWidget {
  const SummaryPanel({
    super.key,
    required this.availability,
    required this.hidden,
    required this.monthHorizon,
    required this.onExplain,
    required this.onAddAccount,
  });
  final Availability availability;
  final bool hidden;

  /// The horizon is the end of the month, so the panel can say "neste mês" instead of a date.
  final bool monthHorizon;
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
              style: Type.headline.copyWith(color: c.onHero, fontSize: 20),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              l.homeSetupText,
              style: Type.rowText.copyWith(color: c.onHeroMuted),
            ),
            const SizedBox(height: Spacing.sm),
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
        : l.heroAfterCommitted;

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
              monthHorizon ? l.canSpendThisMonth : l.canSpendUntil(date),
              style: Type.link.copyWith(color: fg),
            ),
            const SizedBox(height: 2),
            // Large values and large text scale down instead of being cut.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Money(
                av.availableCents,
                role: MoneyRole.heroFlat,
                color: fg,
                hidden: hidden,
              ),
            ),
            const SizedBox(height: 2),
            Text(message, style: Type.rowMeta.copyWith(color: muted)),
            if (extraIncome != 0)
              Text(
                l.heroPlannedIncome(formatBRL(extraIncome, hidden: hidden)),
                style: Type.rowMeta.copyWith(color: muted),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 1, color: divider),
            ),
            HomeFigures(
              dividerColor: divider,
              left: HomeFigure(
                label: l.heroBalances,
                labelColor: muted,
                value: Money(
                  balances,
                  role: MoneyRole.dense,
                  color: fg,
                  hidden: hidden,
                ),
              ),
              right: HomeFigure(
                label: monthHorizon ? l.heroCommittedMonth : l.heroCommitted,
                labelColor: muted,
                value: Money(
                  committed,
                  role: MoneyRole.dense,
                  color: fg,
                  hidden: hidden,
                ),
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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: child,
    );
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(HomeMetrics.radius),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

/// A small label over its value (a figure of the summary panel or of a card invoice).
class HomeFigure extends StatelessWidget {
  const HomeFigure({
    super.key,
    required this.label,
    required this.value,
    required this.labelColor,
    this.labelWeight,
  });
  final String label;
  final Widget value;
  final Color labelColor;
  final FontWeight? labelWeight;

  // Label on top, value at the bottom: when one label wraps, the two values still share a baseline.
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: Type.rowMeta.copyWith(
          color: labelColor,
          fontWeight: labelWeight,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: value,
      ),
    ],
  );
}

/// Two figures side by side with a hairline between them; stacked when the text scale or a narrow
/// screen leaves no room.
class HomeFigures extends StatelessWidget {
  const HomeFigures({
    super.key,
    required this.left,
    required this.right,
    required this.dividerColor,
  });
  final Widget left, right;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < 260 || scale > 1.4) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(child: left),
              const SizedBox(height: Spacing.xs),
              IntrinsicHeight(child: right),
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: left),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: dividerColor,
                ),
              ),
              Expanded(child: right),
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
        minimumSize: const Size(0, Touch.target),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SIcon(SIconName.plus, size: 18, color: c.hero),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              label,
              // Buttons replace the ambient text style; start from the theme's so the platform
              // font is kept (same approach as SButton).
              style:
                  (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
                      .merge(Type.rowTitle.copyWith(color: c.hero)),
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

/// Up to three shortcuts under the summary: a tinted circle with the icon and a short label.
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
                    vertical: Spacing.xxs,
                    horizontal: Spacing.xxs,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: HomeMetrics.action,
                        height: HomeMetrics.action,
                        decoration: BoxDecoration(
                          color: c.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SIcon(a.icon, size: 20, color: c.primary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Three labels share the width: past 130% a single word would break in two.
                      MediaQuery.withClampedTextScaling(
                        maxScaleFactor: 1.3,
                        child: Text(
                          a.label,
                          style: Type.rowMeta.copyWith(
                            color: c.text,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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

/// White section card of the home screen. When [onTap] is given the whole card leads to the section's
/// own screen (the link in its header is the visible cue), so the target is never smaller than the card.
class HomeCard extends StatelessWidget {
  const HomeCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticHint,
    this.padding,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticHint;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) => SCard(
    radius: HomeMetrics.radius,
    padding: padding ?? HomeMetrics.cardPadding,
    onTap: onTap,
    semanticHint: semanticHint,
    child: child,
  );
}

/// Small drawing of a credit card: a solid card in the action color with its stripe.
class CardGlyph extends StatelessWidget {
  const CardGlyph({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: HomeMetrics.tile,
      height: HomeMetrics.tile,
      child: Center(
        child: Container(
          width: 32,
          height: 22,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                height: 4,
                child: ColoredBox(color: c.onPrimary.withValues(alpha: 0.55)),
              ),
              Positioned(
                left: 5,
                bottom: 4,
                width: 9,
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.onPrimary.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        style: Type.rowMeta.copyWith(color: c.textMuted),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Radii.xs),
        ),
        child: Text(
          text,
          style: Type.rowMeta.copyWith(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
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
    Widget block(double h, {Color? color}) => Container(
      height: h,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(HomeMetrics.radius),
      ),
    );
    return Semantics(
      label: context.l10n.homeLoading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(HomeMetrics.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Touch.target + Spacing.md),
              block(150, color: c.surfaceInset),
              const SizedBox(height: Spacing.sm),
              block(64),
              const SizedBox(height: Spacing.sm),
              block(160),
            ],
          ),
        ),
      ),
    );
  }
}
