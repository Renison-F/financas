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
import '../shared/format.dart';
import 'widgets.dart';

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
    if (data == null || layout == null) return const SizedBox();
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l.greetingMorning
        : hour < 18
        ? l.greetingAfternoon
        : l.greetingEvening;
    return UndoHost(
      child: SScreen(
        title: greeting,
        subtitle: monthLabelLong(
          data.month,
          Localizations.localeOf(context).toString(),
        ),
        actions: [
          SIconButton(
            icon: hidden ? SIconName.eyeOff : SIconName.eye,
            label: hidden ? l.showValues : l.hideValues,
            onPressed: () => ref
                .read(appControllerProvider.notifier)
                .setPrefs((p) => p.copyWith(privacyMode: !hidden)),
          ),
          SIconButton(
            icon: SIconName.settings,
            label: l.customizeHome,
            onPressed: () => context.push(Routes.customize),
          ),
        ],
        fab: AddFab(
          label: l.addTransaction,
          onPressed: () => context.push(Routes.transaction),
        ),
        children: [
          for (final id in layout.order)
            WidgetBoundary(
              key: ValueKey(id),
              title: dash.widgetById(id).title,
              child: DashboardWidget(id: id, data: data),
            ),
          if (layout.order.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(
                l.noWidgetsVisible,
                style: Type.bodySmall.copyWith(color: c.textMuted),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
