import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/app_state.dart';
import '../../app/theme/tokens.dart';
import '../../domain/entities/entities.dart';
import '../../domain/loans/loans.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final loans = s.ledger.loans
        .where((x) => x.isActive)
        .map((x) => loanPosition(s.ledger, x, s.today))
        .toList();
    String brl(int v) => formatBRL(v, hidden: hidden);
    return StackScreen(
      title: l.loansAndDebts,
      actions: [
        SButton(
          label: l.new_,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.plus,
          onPressed: () => context.push('/loans/new'),
        ),
      ],
      children: [
        if (loans.isEmpty)
          SCard(
            child: EmptyState(
              icon: SIconName.bank,
              title: l.noLoan,
              text: l.noLoanListText,
              actionLabel: l.registerLoan,
              onAction: () => context.push('/loans/new'),
            ),
          )
        else
          for (final p in loans)
            SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListRow(
                    icon: SIconName.bank,
                    title: p.loan.name,
                    description:
                        '${l.loanLineList(p.loan.system == 'price' ? 'Price' : 'SAC', _rate(p.loan.monthlyRatePercent), p.paidInstallments, p.loan.termMonths)}${p.overdueInstallments.isNotEmpty ? l.overdueInstallments(p.overdueInstallments.length) : ''}',
                    trailing: Money(
                      p.outstandingCents,
                      role: MoneyRole.title,
                      hidden: hidden,
                    ),
                    chevron: true,
                    onTap: () => context.push('/loans/${p.loan.id}'),
                  ),
                  RhythmBar(
                    percent: p.loan.termMonths > 0
                        ? p.paidInstallments / p.loan.termMonths * 100
                        : 0,
                    label: l.installmentsPaid,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.nextDue != null
                        ? l.nextAndPayoff(
                            brl(p.nextDue!.installmentCents),
                            dayMonth(p.nextDue!.dueDate),
                            brl(p.payoffTodayCents),
                          )
                        : l.paidOffCap,
                    style: Type.caption.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

String _rate(double r) =>
    r.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '').replaceAll('.', ',');

class LoanDetailScreen extends ConsumerStatefulWidget {
  const LoanDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends ConsumerState<LoanDetailScreen> {
  int? _extra;
  String _mode = 'reduce_term';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final loan = s.ledger.loanById(widget.id);
    if (loan == null) {
      return StackScreen(
        title: l.loans,
        children: [EmptyState(icon: SIconName.alert, title: l.loanNotFound)],
      );
    }
    final p = loanPosition(s.ledger, loan, s.today);
    final remaining = p.schedule.length - p.paidInstallments;
    final sim = (_extra ?? 0) > 0
        ? simulateExtraPayment(
            loan,
            p.outstandingCents,
            _extra!,
            remaining < 1 ? 1 : remaining,
            _mode,
          )
        : null;
    String brl(int v) => formatBRL(v, hidden: hidden);
    final rowStyle = Type.bodySmall.copyWith(
      color: c.text,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final capStyle = Type.caption.copyWith(
      color: c.textMuted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return StackScreen(
      title: loan.name,
      actions: [
        SButton(
          label: l.edit,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.edit,
          onPressed: () => context.push('/loans/new?id=${loan.id}'),
        ),
      ],
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.outstanding,
                style: Type.label.copyWith(color: c.textMuted),
              ),
              Money(
                p.outstandingCents,
                role: MoneyRole.headline,
                hidden: hidden,
              ),
              const SizedBox(height: 4),
              Text(
                '${l.paidSummary(p.paidInstallments, loan.termMonths, brl(p.paidCents))}${p.extraAmortizationCents > 0 ? l.extraPaid(brl(p.extraAmortizationCents)) : ''}',
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              Text(
                l.payoffToday(brl(p.payoffTodayCents)),
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              if (p.overdueInstallments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l.overdueInstallmentsMsg(p.overdueInstallments.length),
                    style: Type.bodySmall.copyWith(color: c.negative),
                  ),
                ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.simulateExtra),
              MoneyField(
                label: l.extraAmount,
                cents: _extra,
                onChanged: (v) => setState(() => _extra = v),
              ),
              const SizedBox(height: Spacing.sm),
              Segmented<String>(
                options: [
                  ('reduce_term', l.reduceTerm),
                  ('reduce_installment', l.reduceInstallment),
                ],
                value: _mode,
                onChanged: (v) => setState(() => _mode = v),
              ),
              if (sim != null)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: Text(
                    sim.newBalanceCents == 0
                        ? l.paysOffLoan
                        : _mode == 'reduce_term'
                        ? l.newTerm(
                            sim.newTermMonths,
                            brl(sim.newInstallmentCents),
                            remaining,
                          )
                        : l.newInstallment(
                            brl(sim.newInstallmentCents),
                            sim.newTermMonths,
                          ),
                    style: Type.body.copyWith(color: c.text),
                  ),
                ),
              const SizedBox(height: Spacing.sm),
              SButton(
                label: l.registerExtra,
                variant: SButtonVariant.secondary,
                fullWidth: true,
                onPressed: (_extra ?? 0) <= 0
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(appControllerProvider.notifier)
                              .saveTransaction(
                                TransactionInput(
                                  kind: TransactionKind.loanPayment,
                                  amountCents: _extra!,
                                  date: s.today,
                                  description: l.amortization(loan.name),
                                  accountId: loan.accountId,
                                  loanId: loan.id,
                                  status: TransactionStatus.settled,
                                ),
                              );
                          setState(() => _extra = null);
                        } on AppError catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        }
                      },
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.table),
              for (final r in p.schedule)
                Opacity(
                  opacity: r.number <= p.paidInstallments ? 0.5 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text('${r.number}', style: rowStyle),
                        ),
                        SizedBox(
                          width: 64,
                          child: Text(
                            '${r.dueDate.substring(8, 10)}/${r.dueDate.substring(5, 7)}/${r.dueDate.substring(2, 4)}',
                            style: Type.bodySmall.copyWith(color: c.textMuted),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            brl(r.installmentCents),
                            style: rowStyle,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'j ${brl(r.interestCents)}',
                            style: capStyle,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            brl(r.balanceAfterCents),
                            style: capStyle,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoanFormScreen extends ConsumerStatefulWidget {
  const LoanFormScreen({super.key, this.id});
  final String? id;
  @override
  ConsumerState<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends ConsumerState<LoanFormScreen> {
  late final existing = widget.id == null
      ? null
      : ref.read(ledgerProvider).loanById(widget.id);
  late final _name = TextEditingController(text: existing?.name ?? '');
  late int? _principal = existing?.principalCents;
  late final _rate = TextEditingController(
    text: existing != null ? _rate2(existing!.monthlyRatePercent) : '',
  );
  late final _term = TextEditingController(
    text: existing != null ? '${existing!.termMonths}' : '12',
  );
  late String _system = existing?.system ?? 'price';
  late String _firstDue = existing?.firstDueDate ?? ref.read(todayProvider);
  late int? _fee = existing?.monthlyFeeCents;
  late String? _accountId =
      existing?.accountId ??
      ref
          .read(ledgerProvider)
          .accounts
          .where((a) => a.isActive)
          .firstOrNull
          ?.id;
  bool _registerDisbursement = false;
  bool _createInstallments = true;
  String? _error;

  static String _rate2(double r) => r.toString().replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final rateNum = double.tryParse(_rate.text.replaceAll(',', '.'));
    final termNum = int.tryParse(_term.text);
    List<ScheduleRow>? preview;
    if ((_principal ?? 0) > 0 &&
        rateNum != null &&
        rateNum >= 0 &&
        termNum != null &&
        termNum >= 1 &&
        termNum <= 480) {
      preview = buildSchedule(
        Loan(
          id: '',
          name: '',
          principalCents: _principal!,
          monthlyRatePercent: rateNum,
          termMonths: termNum,
          system: _system,
          firstDueDate: _firstDue,
          monthlyFeeCents: _fee ?? 0,
          upfrontFeesCents: 0,
          archived: false,
          createdAt: '',
          updatedAt: '',
        ),
      );
    }
    String brl(int v) => formatBRL(v, hidden: hidden);
    return StackScreen(
      title: existing != null ? l.editLoan : l.newLoan,
      actions: [
        SButton(
          label: l.save,
          variant: SButtonVariant.ghost,
          onPressed: () async {
            if (_name.text.trim().isEmpty ||
                (_principal ?? 0) <= 0 ||
                rateNum == null ||
                rateNum < 0 ||
                termNum == null ||
                termNum < 1) {
              return setState(() => _error = l.loanFormErr);
            }
            await ref
                .read(appControllerProvider.notifier)
                .saveLoan(
                  id: existing?.id,
                  name: _name.text.trim(),
                  principalCents: _principal!,
                  monthlyRatePercent: rateNum,
                  termMonths: termNum,
                  firstDueDate: _firstDue,
                  system: _system,
                  monthlyFeeCents: _fee ?? 0,
                  accountId: _accountId,
                  registerDisbursement:
                      existing == null && _registerDisbursement,
                  createInstallments: existing == null && _createInstallments,
                  disbursementLabel: l.disbursementLabel,
                );
            if (context.mounted) context.pop();
          },
        ),
      ],
      children: [
        STextField(
          label: l.name,
          controller: _name,
          placeholder: l.loanNameHint,
        ),
        MoneyField(
          label: l.borrowed,
          cents: _principal,
          onChanged: (v) => setState(() => _principal = v),
        ),
        Row(
          children: [
            Expanded(
              child: STextField(
                label: l.monthlyRate,
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                placeholder: '1,99',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: STextField(
                label: l.installments,
                controller: _term,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        Field(
          label: l.system,
          child: Segmented<String>(
            options: [('price', l.priceSystem), ('sac', l.sacSystem)],
            value: _system,
            onChanged: (v) => setState(() => _system = v),
          ),
        ),
        DateField(
          label: l.firstDue,
          value: _firstDue,
          onChanged: (d) => setState(() => _firstDue = d),
          today: s.today,
          todayLabel: l.today,
          yesterdayLabel: l.yesterday,
          tomorrowLabel: l.tomorrow,
          invalidLabel: l.invalidDate,
        ),
        MoneyField(
          label: l.monthlyFee,
          cents: _fee,
          onChanged: (v) => setState(() => _fee = v),
        ),
        Field(
          label: l.account,
          child: ChipSelect<String>(
            options: [
              for (final a in s.ledger.accounts.where((a) => a.isActive))
                (a.id, a.name),
            ],
            value: _accountId,
            allowNone: true,
            onChanged: (v) => setState(() => _accountId = v),
          ),
        ),
        if (existing == null) ...[
          ToggleRow(
            label: l.registerDisbursement,
            value: _registerDisbursement,
            help: l.registerDisbursementHelp,
            onChanged: (v) => setState(() => _registerDisbursement = v),
          ),
          ToggleRow(
            label: l.createInstallments,
            value: _createInstallments,
            help: l.createInstallmentsHelp,
            onChanged: (v) => setState(() => _createInstallments = v),
          ),
        ],
        if (preview != null)
          SCard(
            inset: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.preview, style: Type.label.copyWith(color: c.textMuted)),
                Text(
                  '${l.previewLine(preview.length, brl(preview.first.installmentCents))}${_system == 'sac' ? l.lastInstallment(brl(preview.last.installmentCents)) : ''}',
                  style: Type.body.copyWith(color: c.text),
                ),
                Text(
                  l.totalInterestCost(
                    brl(totalInterest(preview)),
                    brl(totalCost(preview)),
                  ),
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
                Text(
                  l.loanAssumptions,
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        if (_error != null)
          Text(_error!, style: Type.bodySmall.copyWith(color: c.negative)),
      ],
    );
  }
}
