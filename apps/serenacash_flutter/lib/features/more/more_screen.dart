import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../ui/components/components.dart';

const appVersion = '0.1.0';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final access = ref.watch(appControllerProvider).value?.access;
    final groups = <(String, List<(SIconName, String, String, String)>)>[
      (
        l.groupMoney,
        [
          (
            SIconName.wallet,
            l.accountsWallets,
            l.accountsWalletsDesc,
            '/accounts',
          ),
          (
            SIconName.tag,
            l.categoriesTags,
            l.categoriesTagsDesc,
            '/categories',
          ),
          (
            SIconName.calendar,
            l.financialCalendar,
            l.financialCalendarDesc,
            '/calendar',
          ),
          (SIconName.receipt, l.billsToPay, l.billsDesc, '/bills'),
        ],
      ),
      (
        l.groupAnalysis,
        [
          (SIconName.arrowUp, l.reports, l.reportsDesc, '/reports'),
          (
            SIconName.sparkle,
            l.financialAssistant,
            l.financialAssistantDesc,
            '/assistant',
          ),
        ],
      ),
      (
        l.groupData,
        [
          (SIconName.upload, l.importData, l.importDesc, '/import'),
          (SIconName.download, l.exportBackup, l.exportDesc, '/export'),
        ],
      ),
      (
        l.groupAccount,
        [
          (SIconName.star, l.plusTitle, l.plusDesc, '/paywall'),
          (SIconName.settings, l.settings, l.settingsDesc, '/settings'),
          (SIconName.lock, l.privacyData, l.privacyDataDesc, '/privacy'),
          (SIconName.help, l.help, l.helpDesc, '/help'),
        ],
      ),
    ];
    return SScreen(
      title: l.moreTitle,
      subtitle: access == null || access.tier == 'free'
          ? l.freePlan
          : access.reason,
      children: [
        for (final g in groups)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    g.$1,
                    style: Type.label.copyWith(color: c.textMuted),
                  ),
                ),
                for (final it in g.$2)
                  ListRow(
                    icon: it.$1,
                    title: it.$2,
                    description: it.$3,
                    chevron: true,
                    onTap: () => context.push(it.$4),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: Spacing.xs),
          child: Text(
            l.footerLocal(appVersion),
            style: Type.caption.copyWith(color: c.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
