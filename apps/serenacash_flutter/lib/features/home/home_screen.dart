import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/dashboard_data.dart';
import '../../app/theme/tokens.dart';
import '../../domain/dashboard/widgets.dart' as dash;
import '../../ui/components/components.dart';
import '../shared/add_sheet.dart';
import '../shared/format.dart';
import 'home_parts.dart';
import 'widgets.dart';

/// Home: compact header, the "pode gastar" summary as the focal point, quick actions, then the sections the
/// user keeps in the layout (order, visibility and period still come from "Personalizar tela inicial").
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final data = ref.watch(dashboardDataProvider);
    final layout = ref.watch(
      appControllerProvider.select((s) => s.value?.layout),
    );
    final hidden = ref.watch(privacyHiddenProvider);
    if (data == null || layout == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: const SafeArea(child: HomeSkeleton()),
      );
    }
    final ctl = ref.read(appControllerProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final period = layout.period == 'last_30_days'
        ? l.next30days
        : monthLabelLong(
            data.month,
            Localizations.localeOf(context).toString(),
          );

    // Same three shortcuts as the reference: a new entry, a bill to pay, the accounts.
    final quick = QuickActions(
      actions: [
        QuickAction(SIconName.plus, l.quickEntry, () => showAddSheet(context)),
        QuickAction(
          SIconName.calendar,
          l.quickBill,
          () => context.push('/transaction?kind=expense&planned=1'),
        ),
        QuickAction(
          SIconName.layers,
          l.quickAccounts,
          () => context.push('/accounts'),
        ),
      ],
    );
    final name = ref.watch(prefsProvider.select((p) => p.displayName));
    final hello = greetingFor(l, DateTime.now().hour);
    final greeting = name.isEmpty ? hello : l.greetingWithName(hello, name);
    final hasSummary = layout.order.contains('available');

    return SScreen(
      title: greeting,
      gutter: HomeMetrics.gutter,
      headerPadding: Spacing.xs,
      header: HomeHeader(
        greeting: greeting,
        period: period,
        onPeriodTap: () => context.push(Routes.customize),
      ),
      actions: [
        SIconButton(
          icon: hidden ? SIconName.eyeOff : SIconName.eye,
          label: hidden ? l.showValues : l.hideValues,
          onPressed: () =>
              ctl.setPrefs((p) => p.copyWith(privacyMode: !hidden)),
        ),
        SIconButton(
          // The icon shows the theme in use (sun in light), as in the reference.
          icon: dark ? SIconName.moon : SIconName.sun,
          label: dark ? l.useLightTheme : l.useDarkTheme,
          onPressed: () =>
              ctl.setPrefs((p) => p.copyWith(theme: dark ? 'light' : 'dark')),
        ),
      ],
      fab: AddFab(label: l.addTitle, onPressed: () => showAddSheet(context)),
      children: [
        if (!hasSummary) quick,
        for (final id in layout.order) ...[
          WidgetBoundary(
            key: ValueKey(id),
            title: dash.widgetById(id).title,
            child: DashboardWidget(id: id, data: data),
          ),
          if (id == 'available') quick,
        ],
        if (layout.order.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Text(
              l.noWidgetsVisible,
              style: Type.bodySmall.copyWith(color: c.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        Center(
          child: SButton(
            label: l.customizeHome,
            icon: SIconName.settings,
            variant: SButtonVariant.ghost,
            compact: true,
            onPressed: () => context.push(Routes.customize),
          ),
        ),
      ],
    );
  }
}
