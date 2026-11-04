/// Change history + sync state (ADR-04/05): every local mutation is listed with version and device;
/// pending count shows what a future sync transport would send; conflicts are listed when present.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/di.dart';
import '../../app/theme/tokens.dart';
import '../../domain/ports/ledger_repository.dart';
import '../../domain/sync/sync_model.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

final _historyProvider =
    FutureProvider.autoDispose<
      ({
        List<ChangeRecord> recent,
        int pending,
        List<Conflict> conflicts,
        String device,
      })
    >((ref) async {
      final log = await ref.watch(changeLogProvider.future);
      final device = await ref.watch(deviceIdProvider.future);
      final pending = await log.pending(limit: 5000);
      return (
        recent: await log.recent(limit: 100),
        pending: pending.length,
        conflicts: await log.openConflicts(),
        device: device,
      );
    });

String entityLabel(AppLocalizations l, String type) => switch (type) {
  EntityTypes.account => l.entityAccount,
  EntityTypes.category => l.entityCategory,
  EntityTypes.tag => l.entityTag,
  EntityTypes.card => l.entityCard,
  EntityTypes.transaction => l.entityTransaction,
  EntityTypes.budget => l.entityBudget,
  EntityTypes.goal => l.entityGoal,
  EntityTypes.loan => l.entityLoan,
  EntityTypes.recurrenceRule => l.entityRecurrence,
  EntityTypes.prefs => l.entityPrefs,
  EntityTypes.shoppingList => l.entityList,
  EntityTypes.shoppingSession => l.entitySession,
  EntityTypes.product => l.entityProduct,
  EntityTypes.priceObservation => l.entityObservation,
  'ledger' => l.entityLedger,
  _ => type,
};

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final data = ref.watch(_historyProvider);
    return StackScreen(
      title: l.changeHistory,
      children: data.when(
        loading: () => [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(Spacing.lg),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
        error: (e, _) => [
          Text('$e', style: Type.bodySmall.copyWith(color: c.negative)),
        ],
        data: (d) => [
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.syncStatus),
                Text(
                  l.syncLocalOnly,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  l.pendingChanges(d.pending),
                  style: Type.body.copyWith(color: c.text),
                ),
                Text(
                  l.deviceLabel(
                    d.device.length > 8 ? d.device.substring(0, 8) : d.device,
                  ),
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.conflicts),
                if (d.conflicts.isEmpty)
                  Text(
                    l.noConflicts,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  )
                else
                  for (final x in d.conflicts)
                    ListRow(
                      icon: SIconName.alert,
                      iconColor: c.warning,
                      title: '${entityLabel(l, x.entityType)} ${x.entityId}',
                      description: x.fields.join(', '),
                    ),
              ],
            ),
          ),
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.recentChanges),
                if (d.recent.isEmpty)
                  Text(
                    l.noChangesYet,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  )
                else
                  for (final r in d.recent)
                    ListRow(
                      icon: r.op == 'delete'
                          ? SIconName.trash
                          : r.op == 'restore'
                          ? SIconName.arrowUp
                          : SIconName.edit,
                      title:
                          '${entityLabel(l, r.entityType)} · ${r.op == 'delete'
                              ? l.opDelete
                              : r.op == 'restore'
                              ? l.opRestore
                              : l.opUpsert}',
                      description:
                          '${r.at.replaceFirst('T', ' ').substring(0, 16)} · ${l.versionN(r.version)} · ${r.deviceId.length > 8 ? r.deviceId.substring(0, 8) : r.deviceId}${r.synced ? '' : ' · ⏳'}',
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
