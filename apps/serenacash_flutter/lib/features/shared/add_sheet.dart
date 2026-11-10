import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/theme/tokens.dart';
import '../../ui/components/components.dart';

/// What the "+" button opens: the kinds of entry that can be added, each named and explained, so the
/// button creates something instead of guessing one kind.
Future<void> showAddSheet(BuildContext context) async {
  final l = context.l10n;
  final c = context.colors;
  final options = <(SIconName, String, String, String)>[
    (
      SIconName.arrowUp,
      l.addExpense,
      l.addExpenseDesc,
      '/transaction?kind=expense',
    ),
    (
      SIconName.arrowDown,
      l.addIncome,
      l.addIncomeDesc,
      '/transaction?kind=income',
    ),
    (
      SIconName.swap,
      l.addTransfer,
      l.addTransferDesc,
      '/transaction?kind=transfer',
    ),
    (
      SIconName.card,
      l.addCardPurchase,
      l.addCardPurchaseDesc,
      '/transaction?kind=card_purchase',
    ),
    (
      SIconName.calendar,
      l.addBill,
      l.addBillDesc,
      '/transaction?kind=expense&planned=1',
    ),
    (
      SIconName.wallet,
      l.addReceivable,
      l.addReceivableDesc,
      '/transaction?kind=income&planned=1',
    ),
  ];
  final route = await showSSheet<String>(
    context,
    // Over the whole screen, bottom bar included: this is a choice to make, not part of the tab.
    useRootNavigator: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.md),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.addTitle,
              style: Type.headline.copyWith(color: c.text, fontSize: 18),
            ),
            const SizedBox(height: Spacing.xs),
            ...dividedRows([
              for (final (icon, title, text, to) in options)
                ListRow(
                  icon: icon,
                  title: title,
                  description: text,
                  chevron: true,
                  onTap: () => Navigator.of(ctx).pop(to),
                ),
            ]),
          ],
        ),
      ),
    ),
  );
  if (route != null && context.mounted) await context.push(route);
}
