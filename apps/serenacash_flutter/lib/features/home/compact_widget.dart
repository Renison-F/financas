/// A home card in its reduced size: one line with the title, the main figure of the card when it
/// has one, and the way into the full screen. The user chooses the size of each card in
/// "Personalizar tela inicial".
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/dashboard_data.dart';
import '../../app/theme/tokens.dart';
import '../../domain/dashboard/widgets.dart' as dash;
import '../../domain/ledger/ledger.dart';
import '../../ui/components/components.dart';
import 'home_parts.dart';

/// The one amount that sums a card up, or null when the card is a list or a chart with no single
/// figure. Every value comes from the same data the full card shows.
int? widgetHeadlineCents(String id, DashboardData d) => switch (id) {
  'available' =>
    d.availability.hasAccounts ? d.availability.availableCents : null,
  'consolidated_balance' ||
  'account_balances' ||
  'period_balance' => d.accounts.isEmpty ? null : d.consolidated,
  'income' => d.totals.incomeSettled,
  'expenses' ||
  'spending_by_category' ||
  'breakdown' => d.totals.expenseSettled,
  'bills_to_pay' => d.bills.fold<int>(0, (a, t) => a + pendingCents(t)),
  'overdue_bills' => d.overdue.fold<int>(0, (a, t) => a + pendingCents(t)),
  'upcoming_due' => d.next7.fold<int>(0, (a, t) => a + pendingCents(t)),
  'cards_invoices' =>
    d.cards.isEmpty
        ? null
        : d.cards.fold<int>(
            0,
            (a, x) =>
                a +
                x.commitment.currentInvoiceCents +
                x.commitment.closedUnpaidCents,
          ),
  'installments' => d.cards.isEmpty ? null : d.installmentsFuture,
  'evolution' || 'overview' => d.totals.net,
  _ => null,
};

class CompactWidget extends StatelessWidget {
  const CompactWidget({
    super.key,
    required this.id,
    required this.data,
    required this.hidden,
  });
  final String id;
  final DashboardData data;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final def = dash.widgetById(id);
    final cents = widgetHeadlineCents(id, data);
    return HomeCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: () => context.push(def.route),
      semanticHint: l.widgetOpen(def.title),
      child: Row(
        children: [
          Expanded(
            child: Text(
              def.title,
              style: Type.rowTitle.copyWith(color: c.text),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (cents != null) ...[
            const SizedBox(width: Spacing.xs),
            Money(
              cents,
              role: MoneyRole.dense,
              hidden: hidden,
              signed: id == 'evolution' || id == 'overview',
              color: cents < 0 ? c.negative : null,
            ),
          ],
          const SizedBox(width: 4),
          SIcon(SIconName.chevronRight, size: 18, color: c.textMuted),
        ],
      ),
    );
  }
}
