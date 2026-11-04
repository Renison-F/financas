import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../ui/components/components.dart';
import '../shared/helpers.dart';
import '../shared/stack_screen.dart';

String accountTypeLabel(AppLocalizations l, String type) => switch (type) {
  'cash' => l.typeCashL,
  'checking' => l.typeCheckingL,
  'savings' => l.typeSavingsL,
  'digital_wallet' => l.typeDigitalL,
  'investment' => l.typeInvestmentL,
  _ => l.typeOtherL,
};

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final hidden = ref.watch(privacyHiddenProvider);
    final active = ledger.accounts.where((a) => a.isActive).toList();
    final archived = ledger.accounts
        .where((a) => a.archived && a.deletedAt == null)
        .toList();
    return StackScreen(
      title: l.accountsTitle,
      actions: [
        SButton(
          label: l.newF,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.plus,
          onPressed: () => context.push('/accounts/new'),
        ),
      ],
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.consolidatedBalance,
                style: Type.label.copyWith(color: c.textMuted),
              ),
              Money(
                consolidatedBalance(ledger),
                role: MoneyRole.headline,
                signed: true,
                hidden: hidden,
              ),
              Text(
                l.transfersDontChange,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.active),
              if (active.isEmpty)
                EmptyState(
                  icon: SIconName.wallet,
                  title: l.noAccount,
                  actionLabel: l.addAccount,
                  onAction: () => context.push('/accounts/new'),
                )
              else
                for (final a in active)
                  ListRow(
                    icon: a.type == 'cash' ? SIconName.wallet : SIconName.bank,
                    title: a.name,
                    description:
                        '${accountTypeLabel(l, a.type)}${a.includeInAvailability ? '' : l.outOfAvailability}',
                    trailing: Money(
                      accountBalance(ledger, a.id),
                      signed: true,
                      hidden: hidden,
                    ),
                    chevron: true,
                    onTap: () => context.push('/accounts/${a.id}'),
                  ),
            ],
          ),
        ),
        if (archived.isNotEmpty)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.archivedF),
                for (final a in archived)
                  ListRow(
                    icon: SIconName.wallet,
                    title: a.name,
                    trailing: Money(
                      accountBalance(ledger, a.id),
                      hidden: hidden,
                    ),
                    chevron: true,
                    onTap: () => context.push('/accounts/${a.id}'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  String? _err;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final hidden = ref.watch(privacyHiddenProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final account = ledger.accountById(widget.id);
    if (account == null) {
      return StackScreen(
        title: l.account,
        children: [EmptyState(icon: SIconName.alert, title: l.accountNotFound)],
      );
    }
    final history =
        ledger.transactions
            .where(
              (t) =>
                  t.deletedAt == null &&
                  (t.accountId == account.id || t.toAccountId == account.id),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    int signed(Transaction t) =>
        (t.kind == TransactionKind.income ||
            t.kind == TransactionKind.loanDisbursement ||
            t.kind == TransactionKind.goalWithdrawal ||
            ((t.kind == TransactionKind.transfer ||
                    t.kind == TransactionKind.balanceAdjustment ||
                    t.kind == TransactionKind.goalDeposit) &&
                t.toAccountId == account.id))
        ? t.amountCents
        : -t.amountCents;
    return StackScreen(
      title: account.name,
      actions: [
        SButton(
          label: l.edit,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.edit,
          onPressed: () => context.push('/accounts/edit?id=${account.id}'),
        ),
      ],
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.currentBalance,
                style: Type.label.copyWith(color: c.textMuted),
              ),
              Money(
                accountBalance(ledger, account.id),
                role: MoneyRole.headline,
                signed: true,
                hidden: hidden,
              ),
              Text(
                '${l.openingBalanceLine(formatBRLHidden(account.openingBalanceCents, hidden), fmtDateBR(account.openingDate))}${account.archived ? l.archivedSuffix : ''}',
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.history,
                action: SButton(
                  label: l.new_,
                  variant: SButtonVariant.ghost,
                  compact: true,
                  icon: SIconName.plus,
                  onPressed: () => context.push('/transaction'),
                ),
              ),
              if (history.isEmpty)
                EmptyState(icon: SIconName.list, title: l.noMovements)
              else
                for (final t in history.take(50))
                  ListRow(
                    icon: t.kind == TransactionKind.income
                        ? SIconName.arrowDown
                        : t.kind == TransactionKind.transfer
                        ? SIconName.swap
                        : SIconName.arrowUp,
                    title: t.description.isEmpty
                        ? kindLabelOf(l, t)
                        : t.description,
                    description:
                        '${t.date.substring(8, 10)}/${t.date.substring(5, 7)} · ${kindLabelOf(l, t)}${t.status != TransactionStatus.settled ? ' · ${l.planned}' : ''}',
                    trailing: Money(signed(t), signed: true, hidden: hidden),
                    onTap: () => context.push('/transaction?id=${t.id}'),
                  ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs),
        SButton(
          label: account.archived ? l.reactivateAccount : l.archiveAccount,
          variant: SButtonVariant.secondary,
          fullWidth: true,
          onPressed: () async {
            if (account.archived) {
              await ctl.archiveAccount(account.id, archived: false);
              if (context.mounted) context.pop();
              return;
            }
            final ok = await confirmSheet(
              context,
              title: l.archiveAccountQ,
              text: l.archiveAccountText,
              confirmLabel: l.archive,
              cancelLabel: l.cancel,
              destructive: false,
            );
            if (!ok) return;
            await ctl.archiveAccount(account.id);
            if (context.mounted) context.pop();
          },
        ),
        SButton(
          label: l.deleteAccount,
          variant: SButtonVariant.destructive,
          icon: SIconName.trash,
          fullWidth: true,
          onPressed: () async {
            final ok = await confirmSheet(
              context,
              title: l.deleteAccountQ,
              text: l.deleteAccountText,
              confirmLabel: l.delete,
              cancelLabel: l.cancel,
            );
            if (!ok) return;
            final r = await ctl.deleteAccount(
              account.id,
              l.accountHasTransactions,
            );
            if (!context.mounted) return;
            if (r.ok) {
              context.pop();
            } else {
              setState(() => _err = r.reason);
            }
          },
        ),
        if (_err != null)
          Text(_err!, style: Type.bodySmall.copyWith(color: c.negative)),
      ],
    );
  }
}
