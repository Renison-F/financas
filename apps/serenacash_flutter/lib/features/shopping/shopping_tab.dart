import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/money/money.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';

class ShoppingTab extends ConsumerWidget {
  const ShoppingTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).value;
    final hidden = ref.watch(privacyHiddenProvider);
    if (s == null) return const SizedBox();
    final lists = s.shoppingLists.where((x) => !x.archived).toList();
    final active = s.sessions.where((x) => x.status == 'active').firstOrNull;
    final finished = s.sessions.where((x) => x.status == 'finished').toList()
      ..sort((a, b) => (b.finishedAt ?? '').compareTo(a.finishedAt ?? ''));
    String brl(int v) => formatBRL(v, hidden: hidden);
    return SScreen(
      title: l.shoppingTitle,
      subtitle: l.shoppingSubtitle,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: active != null
                    ? l.shoppingInProgress
                    : l.shoppingAssistant,
              ),
              Text(
                active != null
                    ? l.sessionLine(
                        active.lines.length,
                        brl(sessionSummary(active).totalCents),
                      )
                    : l.shoppingIntro,
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: 10),
              SButton(
                label: active != null ? l.continueShopping : l.startShopping,
                icon: SIconName.cart,
                onPressed: () => context.push(
                  active != null
                      ? '/shopping/session?id=${active.id}'
                      : '/shopping/session',
                ),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.lists,
                action: SButton(
                  label: l.newF,
                  variant: SButtonVariant.ghost,
                  compact: true,
                  icon: SIconName.plus,
                  onPressed: () => context.push('/shopping/list/new'),
                ),
              ),
              if (lists.isEmpty)
                EmptyState(
                  icon: SIconName.list,
                  title: l.noList,
                  text: l.noListText,
                  actionLabel: l.createList,
                  onAction: () => context.push('/shopping/list/new'),
                )
              else
                for (final x in lists)
                  Builder(
                    builder: (_) {
                      final e = estimateList(x);
                      final p = listProgress(x);
                      return ListRow(
                        icon: SIconName.list,
                        title: x.name,
                        description:
                            '${l.itemsCount(p.total)}${x.store != null ? ' · ${x.store}' : ''} · ${e.knownItems > 0 ? l.estimated(brl(e.knownCents)) : l.noPricesYet}${e.unknownItems > 0 ? l.withoutPrice(e.unknownItems) : ''}',
                        trailing: x.budgetCents != null
                            ? Money(x.budgetCents!, hidden: hidden)
                            : null,
                        chevron: true,
                        onTap: () => context.push('/shopping/list/${x.id}'),
                      );
                    },
                  ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.previousPurchases,
                action: SButton(
                  label: l.priceHistoryTitle,
                  variant: SButtonVariant.ghost,
                  compact: true,
                  onPressed: () => context.push('/shopping/prices'),
                ),
              ),
              if (finished.isEmpty)
                Text(
                  l.previousPurchasesText,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final x in finished.take(5))
                  Builder(
                    builder: (_) {
                      final sm = sessionSummary(x);
                      return ListRow(
                        icon: SIconName.receipt,
                        title: x.store ?? l.supermarket,
                        description:
                            '${l.itemsCount(sm.lines)} · ${x.finishedAt!.substring(8, 10)}/${x.finishedAt!.substring(5, 7)}${x.transactionId != null ? ' · ${l.registered}' : ''}',
                        trailing: Money(sm.totalCents, hidden: hidden),
                        chevron: true,
                        onTap: () =>
                            context.push('/shopping/session?id=${x.id}'),
                      );
                    },
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
