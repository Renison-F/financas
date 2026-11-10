/// Side menu of the tab shell: every module that is not a bottom-bar destination, grouped, with the
/// current section highlighted. Only destinations that exist are listed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_screen.dart' show BrandSymbol;
import '../ui/icons.dart';
import 'app.dart';
import 'router.dart';
import 'state/app_controller.dart';
import 'theme/tokens.dart';

/// Version and build number as in pubspec.yaml, shown in the menu so the installed build can be told
/// apart without a computer (a test checks the two stay equal).
const appVersion = '0.2.0 (build 4)';

class _Item {
  const _Item(this.icon, this.label, {this.route, this.tab});
  final SIconName icon;
  final String label;

  /// A screen pushed on top of the tabs…
  final String? route;

  /// …or one of the tabs themselves.
  final int? tab;
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    super.key,
    required this.currentTab,
    required this.onSelectTab,
  });
  final int currentTab;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final access = ref.watch(appControllerProvider).value?.access;
    final groups = <(String, List<_Item>)>[
      (
        l.navGroupMain,
        [
          _Item(SIconName.home, l.tabHome, tab: 0),
          _Item(SIconName.list, l.tabTransactions, tab: 1),
          _Item(SIconName.cart, l.tabShopping, tab: 2),
          _Item(SIconName.chart, l.tabPlan, tab: 3),
        ],
      ),
      (
        l.navGroupMoves,
        [
          _Item(SIconName.receipt, l.billsBoth, route: '/bills'),
          _Item(SIconName.calendar, l.financialCalendar, route: '/calendar'),
          _Item(SIconName.document, l.changeHistory, route: '/history'),
        ],
      ),
      (
        l.navGroupPlanning,
        [
          _Item(SIconName.plan, l.budgets, route: '/budgets'),
          _Item(SIconName.target, l.goals, route: '/goals'),
          _Item(SIconName.bank, l.loans, route: '/loans'),
          _Item(SIconName.calendar, l.annualPlanning, route: '/plan/annual'),
          _Item(SIconName.chart, l.dailyTitle, route: '/daily'),
        ],
      ),
      (
        l.navGroupRegisters,
        [
          _Item(SIconName.wallet, l.accountsWallets, route: '/accounts'),
          _Item(SIconName.card, l.navCards, route: '/cards'),
          _Item(SIconName.tag, l.navCategories, route: '/categories'),
        ],
      ),
      (
        l.groupAnalysis,
        [
          _Item(SIconName.trending, l.reports, route: '/reports'),
          _Item(SIconName.sparkle, l.financialAssistant, route: '/assistant'),
        ],
      ),
      (
        l.groupData,
        [
          _Item(SIconName.upload, l.importData, route: '/import'),
          _Item(SIconName.download, l.exportBackup, route: '/export'),
        ],
      ),
      (
        l.navGroupSettings,
        [
          _Item(SIconName.settings, l.settings, route: Routes.settings),
          _Item(SIconName.lock, l.privacyData, route: '/privacy'),
          _Item(SIconName.help, l.help, route: '/help'),
          _Item(SIconName.star, l.plusTitle, route: '/paywall'),
        ],
      ),
    ];

    void open(_Item it) {
      // Close first: the destination must not open with the menu still over it.
      Navigator.of(context).pop();
      if (it.tab != null) {
        onSelectTab(it.tab!);
      } else {
        context.push(it.route!);
      }
    }

    final width = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: width * 0.86 > 320 ? 320 : width * 0.86,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.sm,
            Spacing.sm,
            Spacing.sm,
            Spacing.lg,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xs,
                Spacing.xxs,
                Spacing.xs,
                Spacing.sm,
              ),
              child: Row(
                children: [
                  const BrandSymbol(size: 36),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SerenaCash',
                          style: Type.headline.copyWith(
                            color: c.text,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          access == null || access.tier == 'free'
                              ? l.freePlan
                              : access.reason,
                          style: Type.rowMeta.copyWith(color: c.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (final (title, items) in groups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.xs,
                  Spacing.sm,
                  Spacing.xs,
                  Spacing.xxs,
                ),
                child: Text(
                  title,
                  style: Type.label.copyWith(color: c.textMuted),
                ),
              ),
              for (final it in items)
                _DrawerRow(
                  item: it,
                  selected: it.tab != null && it.tab == currentTab,
                  onTap: () => open(it),
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xs,
                Spacing.md,
                Spacing.xs,
                0,
              ),
              child: Text(
                l.footerLocal(appVersion),
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerRow extends StatelessWidget {
  const _DrawerRow({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final _Item item;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Touch.min),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              child: Row(
                children: [
                  SIcon(
                    item.icon,
                    size: 20,
                    color: selected ? c.primary : c.textMuted,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Type.rowTitle.copyWith(
                        color: selected ? c.onPrimaryContainer : c.text,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
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
    );
  }
}
