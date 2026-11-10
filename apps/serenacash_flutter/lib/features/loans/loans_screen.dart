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
                    description: p.loan.system == 'free'
                        ? l.loanLineFree(
                            loanSystemLabel(l, p.loan),
                            brl(p.paidCents),
                          )
                        : l.loanLineList(
                            loanSystemLabel(l, p.loan),
                            _rate(p.loan.monthlyRatePercent),
                            p.paidInstallments,
                            p.schedule.length,
                          ),
                    trailing: Money(
                      p.outstandingCents,
                      role: MoneyRole.title,
                      hidden: hidden,
                    ),
                    chevron: true,
                    onTap: () => context.push('/loans/${p.loan.id}'),
                  ),
                  if (p.loan.system == 'free')
                    RhythmBar(
                      percent: p.loan.principalCents > 0
                          ? (1 - p.outstandingCents / p.loan.principalCents)
                                    .clamp(0, 1) *
                                100
                          : 0,
                      label: l.loanPaidShare,
                    )
                  else
                    RhythmBar(
                      percent: p.schedule.isNotEmpty
                          ? p.paidInstallments / p.schedule.length * 100
                          : 0,
                      label: l.installmentsPaid,
                    ),
                  const SizedBox(height: 6),
                  Text(
                    p.loan.system == 'free'
                        ? (p.outstandingCents == 0
                              ? l.paidOffCap
                              : l.loanFreeNote)
                        : p.nextDue != null
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

/// How a loan is called on screen: its system and, for money lent, whose debt it is.
String loanSystemLabel(AppLocalizations l, Loan loan) {
  final system = switch (loan.system) {
    'price' => 'Price',
    'sac' => 'SAC',
    'american' => l.loanSystemAmericanShort,
    'bullet' => l.loanSystemBulletShort,
    _ => l.loanSystemFreeShort,
  };
  return loan.direction == 'lent' ? '${l.loanLentTag} · $system' : system;
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
    if (loan.system == 'free') return _FreeDebtDetail(loan: loan);
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
                '${l.paidSummary(p.paidInstallments, p.schedule.length, brl(p.paidCents))}${p.extraAmortizationCents > 0 ? l.extraPaid(brl(p.extraAmortizationCents)) : ''}',
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
                              .registerLoanPayment(
                                loanId: loan.id,
                                amountCents: _extra!,
                                date: s.today,
                                description: l.amortization(loan.name),
                                tooMuchMessage: l.loanPayTooMuch,
                                invalidAmountMessage: l.errAmount,
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
  late final _party = TextEditingController(text: existing?.lender ?? '');
  late int? _principal = existing?.principalCents;
  late final _rate = TextEditingController(
    text: existing == null
        ? ''
        : _rate2(existing!.rateInputPercent ?? existing!.monthlyRatePercent),
  );
  late final _term = TextEditingController(
    text: existing != null && existing!.termMonths > 0
        ? '${existing!.termMonths}'
        : '12',
  );
  late String _system = existing?.system ?? 'price';
  late String _direction = existing?.direction ?? 'borrowed';
  late String _interest = existing?.interestMode ?? 'none';
  late String _ratePeriod = existing?.ratePeriod ?? 'month';
  late String _rateKind = existing?.rateKind ?? 'effective';
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

  bool get _free => _system == 'free';
  static String _rate2(double r) => r.toString().replaceAll('.', ',');

  /// Any edit clears the message of the last attempt.
  void _set(VoidCallback change) {
    if (_error != null) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      _error = null;
      change();
    });
  }

  /// The form is long: a message at the end of it would be out of sight when the save button is
  /// tapped at the top, so it is shown over the screen.
  void _fail(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    setState(() => _error = message);
  }

  @override
  void dispose() {
    _name.dispose();
    _party.dispose();
    _rate.dispose();
    _term.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final rateInput = double.tryParse(_rate.text.replaceAll(',', '.'));
    final termNum = int.tryParse(_term.text);
    // Every calculation uses the effective monthly rate; what was typed is kept next to it.
    final monthly = rateInput == null
        ? null
        : monthlyRateFrom(rateInput, period: _ratePeriod, kind: _rateKind);
    final needsRate = !_free || _interest != 'none';
    List<ScheduleRow>? preview;
    if (!_free &&
        (_principal ?? 0) > 0 &&
        monthly != null &&
        monthly >= 0 &&
        termNum != null &&
        termNum >= 1 &&
        termNum <= 480) {
      preview = buildSchedule(
        Loan(
          id: '',
          name: '',
          principalCents: _principal!,
          monthlyRatePercent: monthly,
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

    Future<void> save() async {
      final badRate = needsRate && (monthly == null || monthly < 0);
      final badFreeInterest =
          _free && _interest != 'none' && (monthly ?? 0) <= 0;
      if (_name.text.trim().isEmpty || (_principal ?? 0) <= 0) {
        return _fail(l.loanFormErrBasic);
      }
      if (badRate || badFreeInterest) {
        return _fail(l.loanFormErrRate);
      }
      if (!_free && (termNum == null || termNum < 1 || termNum > 480)) {
        return _fail(l.loanFormErrTerm);
      }
      await ref
          .read(appControllerProvider.notifier)
          .saveLoan(
            id: existing?.id,
            name: _name.text.trim(),
            lender: _party.text.trim().isEmpty ? null : _party.text.trim(),
            principalCents: _principal!,
            monthlyRatePercent: needsRate ? monthly! : 0,
            termMonths: _free ? 0 : termNum!,
            firstDueDate: _firstDue,
            system: _system,
            direction: _direction,
            interestMode: _free ? _interest : 'none',
            ratePeriod: _ratePeriod,
            rateKind: _rateKind,
            rateInputPercent: needsRate ? rateInput : null,
            monthlyFeeCents: _free ? 0 : (_fee ?? 0),
            accountId: _accountId,
            registerDisbursement: existing == null && _registerDisbursement,
            createInstallments:
                existing == null && !_free && _createInstallments,
            disbursementLabel: _direction == 'lent'
                ? l.loanHandoverLabel
                : l.disbursementLabel,
          );
      if (context.mounted) context.pop();
    }

    return StackScreen(
      title: existing != null ? l.editLoan : l.newLoan,
      actions: [
        SButton(label: l.save, variant: SButtonVariant.ghost, onPressed: save),
      ],
      children: [
        Field(
          label: l.loanDirection,
          child: Segmented<String>(
            options: [('borrowed', l.loanBorrowed), ('lent', l.loanLent)],
            value: _direction,
            onChanged: (v) => _set(() => _direction = v),
          ),
        ),
        Field(
          label: l.loanMode,
          help: _free ? l.loanModeFreeHelp : null,
          child: Segmented<String>(
            options: [
              ('scheduled', l.loanModeScheduled),
              ('free', l.loanModeFree),
            ],
            value: _free ? 'free' : 'scheduled',
            onChanged: (v) => _set(
              () => _system = v == 'free'
                  ? 'free'
                  : (_system == 'free' ? 'price' : _system),
            ),
          ),
        ),
        STextField(
          label: l.name,
          controller: _name,
          placeholder: l.loanNameHint,
          onChanged: (_) => _set(() {}),
        ),
        STextField(
          label: _direction == 'lent' ? l.loanDebtor : l.loanCreditor,
          controller: _party,
          placeholder: l.optional,
        ),
        MoneyField(
          label: _direction == 'lent' ? l.loanLentAmount : l.borrowed,
          cents: _principal,
          onChanged: (v) => _set(() => _principal = v),
        ),
        if (!_free)
          Field(
            label: l.system,
            help: switch (_system) {
              'price' => l.loanSystemPriceHelp,
              'sac' => l.loanSystemSacHelp,
              'american' => l.loanSystemAmericanHelp,
              _ => l.loanSystemBulletHelp,
            },
            child: ChipSelect<String>(
              options: [
                ('price', l.priceSystem),
                ('sac', l.sacSystem),
                ('american', l.loanSystemAmerican),
                ('bullet', l.loanSystemBullet),
              ],
              value: _system,
              onChanged: (v) => _set(() => _system = v ?? _system),
            ),
          )
        else
          Field(
            label: l.loanInterest,
            help: switch (_interest) {
              'simple' => l.loanInterestSimpleHelp,
              'compound' => l.loanInterestCompoundHelp,
              _ => l.loanInterestNoneHelp,
            },
            child: ChipSelect<String>(
              options: [
                ('none', l.loanInterestNone),
                ('simple', l.loanInterestSimple),
                ('compound', l.loanInterestCompound),
              ],
              value: _interest,
              onChanged: (v) => _set(() => _interest = v ?? 'none'),
            ),
          ),
        if (needsRate) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: STextField(
                  label: _ratePeriod == 'year' ? l.loanRateYear : l.monthlyRate,
                  controller: _rate,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  placeholder: '1,99',
                  onChanged: (_) => _set(() {}),
                ),
              ),
              if (!_free) ...[
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: STextField(
                    label: _system == 'bullet'
                        ? l.loanTermMonths
                        : l.installments,
                    controller: _term,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _set(() {}),
                  ),
                ),
              ],
            ],
          ),
          Field(
            label: l.loanRateStated,
            help: _ratePeriod == 'year' && monthly != null && monthly > 0
                ? l.loanRateEquivalent(_rate3(monthly))
                : null,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SChip(
                  label: l.loanRatePerMonth,
                  selected: _ratePeriod == 'month',
                  onTap: () => _set(() => _ratePeriod = 'month'),
                ),
                SChip(
                  label: l.loanRatePerYearEffective,
                  selected: _ratePeriod == 'year' && _rateKind == 'effective',
                  onTap: () => _set(() {
                    _ratePeriod = 'year';
                    _rateKind = 'effective';
                  }),
                ),
                SChip(
                  label: l.loanRatePerYearNominal,
                  selected: _ratePeriod == 'year' && _rateKind == 'nominal',
                  onTap: () => _set(() {
                    _ratePeriod = 'year';
                    _rateKind = 'nominal';
                  }),
                ),
              ],
            ),
          ),
        ],
        DateField(
          label: _free ? l.loanOriginDate : l.firstDue,
          value: _firstDue,
          onChanged: (d) => _set(() => _firstDue = d),
          today: s.today,
          todayLabel: l.today,
          yesterdayLabel: l.yesterday,
          tomorrowLabel: l.tomorrow,
          invalidLabel: l.invalidDate,
          calendarLabel: l.openCalendar,
        ),
        if (!_free)
          MoneyField(
            label: l.monthlyFee,
            cents: _fee,
            onChanged: (v) => _set(() => _fee = v),
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
            onChanged: (v) => _set(() => _accountId = v),
          ),
        ),
        if (existing == null) ...[
          ToggleRow(
            label: _direction == 'lent'
                ? l.loanRegisterHandover
                : l.registerDisbursement,
            value: _registerDisbursement,
            help: _direction == 'lent'
                ? l.loanRegisterHandoverHelp
                : l.registerDisbursementHelp,
            onChanged: (v) => _set(() => _registerDisbursement = v),
          ),
          if (!_free)
            ToggleRow(
              label: l.createInstallments,
              value: _createInstallments,
              help: l.createInstallmentsHelp,
              onChanged: (v) => _set(() => _createInstallments = v),
            ),
        ],
        if (preview != null && preview.isNotEmpty)
          SCard(
            inset: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.preview, style: Type.label.copyWith(color: c.textMuted)),
                Text(
                  '${l.previewLine(preview.length, brl(preview.first.installmentCents))}${preview.length > 1 && preview.last.installmentCents != preview.first.installmentCents ? l.lastInstallment(brl(preview.last.installmentCents)) : ''}',
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
      ],
    );
  }
}

String _rate3(double r) => r
    .toStringAsFixed(4)
    .replaceAll(RegExp(r'0+$'), '')
    .replaceAll(RegExp(r'\.$'), '')
    .replaceAll('.', ',');

/// A debt paid when possible: what is owed today, how it got there, and a way to register a payment
/// of any amount on any date.
class _FreeDebtDetail extends ConsumerStatefulWidget {
  const _FreeDebtDetail({required this.loan});
  final Loan loan;
  @override
  ConsumerState<_FreeDebtDetail> createState() => _FreeDebtDetailState();
}

class _FreeDebtDetailState extends ConsumerState<_FreeDebtDetail> {
  int? _amount;
  late String _date = ref.read(todayProvider);
  String? _error;
  bool _saving = false;

  Future<void> _pay() async {
    if (_saving) return;
    final l = context.l10n;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(appControllerProvider.notifier)
          .registerLoanPayment(
            loanId: widget.loan.id,
            amountCents: _amount ?? 0,
            date: _date,
            description: widget.loan.direction == 'lent'
                ? l.loanReceiptOf(widget.loan.name)
                : l.loanPaymentOf(widget.loan.name),
            tooMuchMessage: l.loanPayTooMuch,
            invalidAmountMessage: l.errAmount,
          );
      if (mounted) setState(() => _amount = null);
    } on AppError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final loan = s.ledger.loanById(widget.loan.id) ?? widget.loan;
    final st = freeDebtStatement(loan, loanRepayments(s.ledger, loan), s.today);
    final lent = loan.direction == 'lent';
    String brl(int v) => formatBRL(v, hidden: hidden);
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
                lent ? l.loanOwedToYou : l.outstanding,
                style: Type.label.copyWith(color: c.textMuted),
              ),
              Money(
                st.outstandingCents,
                role: MoneyRole.headline,
                hidden: hidden,
              ),
              const SizedBox(height: 4),
              Text(
                l.loanFreeSummary(
                  brl(loan.principalCents),
                  fmtDateBR(loan.firstDueDate),
                  brl(st.paidCents),
                ),
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              if (loan.interestMode != 'none' && loan.monthlyRatePercent > 0)
                Text(
                  l.loanFreeInterestLine(
                    loan.interestMode == 'simple'
                        ? l.loanInterestSimple
                        : l.loanInterestCompound,
                    _rate3(loan.monthlyRatePercent),
                    brl(st.accruedInterestCents),
                    brl(st.interestPaidCents),
                  ),
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                Text(
                  l.loanFreeNoInterest,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
              if (st.settled)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l.paidOffCap,
                    style: Type.label.copyWith(color: c.positive),
                  ),
                ),
            ],
          ),
        ),
        if (!st.settled)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardHeader(
                  title: lent ? l.loanRegisterReceipt : l.loanRegisterPayment,
                ),
                MoneyField(
                  label: l.amount,
                  cents: _amount,
                  onChanged: (v) => setState(() {
                    _amount = v;
                    _error = null;
                  }),
                ),
                const SizedBox(height: Spacing.sm),
                DateField(
                  label: l.date,
                  value: _date,
                  onChanged: (d) => setState(() {
                    _date = d;
                    _error = null;
                  }),
                  today: s.today,
                  todayLabel: l.today,
                  yesterdayLabel: l.yesterday,
                  tomorrowLabel: l.tomorrow,
                  invalidLabel: l.invalidDate,
                  calendarLabel: l.openCalendar,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.xs),
                    child: Text(
                      _error!,
                      style: Type.bodySmall.copyWith(color: c.negative),
                    ),
                  ),
                const SizedBox(height: Spacing.sm),
                SButton(
                  label: lent ? l.loanRegisterReceipt : l.loanRegisterPayment,
                  fullWidth: true,
                  loading: _saving,
                  onPressed: (_amount ?? 0) > 0 ? _pay : null,
                ),
                const SizedBox(height: 4),
                SButton(
                  label: l.loanSettleWith(brl(st.outstandingCents)),
                  variant: SButtonVariant.ghost,
                  fullWidth: true,
                  compact: true,
                  onPressed: () => setState(() {
                    _amount = st.outstandingCents;
                    _date = s.today;
                    _error = null;
                  }),
                ),
                Text(
                  l.loanFreePayNote,
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.loanStatement),
              if (st.events.isEmpty)
                Text(
                  l.loanNoPaymentsYet,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                ...dividedRows([
                  for (final e in st.events.reversed)
                    ListRow(
                      icon: lent ? SIconName.arrowDown : SIconName.arrowUp,
                      title: '${fmtDateBR(e.date)} · ${brl(e.paidCents)}',
                      description: e.interestCents > 0
                          ? l.loanEventSplit(
                              brl(e.interestCents),
                              brl(e.principalCents),
                              brl(e.balanceAfterCents),
                            )
                          : l.loanEventBalance(brl(e.balanceAfterCents)),
                      chevron: true,
                      // The payment is an entry like any other: it is corrected or undone there.
                      onTap: () =>
                          context.push('/transaction?id=${e.transactionId}'),
                    ),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}
