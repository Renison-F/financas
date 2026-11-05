/// ≤ 90 s onboarding: account → fixed bills → card → done. Every step can be skipped; no e-mail, no permissions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/app_state.dart';
import '../../app/theme/tokens.dart';
import '../../domain/entities/entities.dart';
import '../../ui/components/components.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  late final _accountName = TextEditingController(
    text: context.l10n.mainAccount,
  );
  String _accountType = 'checking';
  int? _balance;
  String? _accountId;
  final Map<String, int?> _bills = {};
  late final _cardName = TextEditingController(text: context.l10n.card);
  final _closing = TextEditingController(text: '20');
  final _due = TextEditingController(text: '27');
  int? _limit;
  bool _busy = false;

  List<(String, String)> _fixed(AppLocalizations l) => [
    (l.fixedRent, 'Moradia'),
    (l.fixedPower, 'Moradia'),
    (l.fixedInternet, 'Moradia'),
    (l.fixedPhone, 'Assinaturas'),
    (l.fixedWater, 'Moradia'),
  ];
  int _day(String s) => (int.tryParse(s) ?? 1).clamp(1, 31);

  Future<void> _next() async {
    final l = context.l10n;
    final ctl = ref.read(appControllerProvider.notifier);
    final s = ref.read(appControllerProvider).requireValue;
    setState(() => _busy = true);
    try {
      if (_step == 1) {
        // Going back a step, or reopening the app in the middle of the setup, must update the account
        // that was already created instead of adding a second one with the same balance.
        _accountId ??= s.ledger.accounts
            .where((a) => a.deletedAt == null)
            .firstOrNull
            ?.id;
        final a = await ctl.saveAccount(
          id: _accountId,
          name: _accountName.text.trim().isEmpty
              ? l.mainAccount
              : _accountName.text.trim(),
          type: _accountType,
          openingBalanceCents: _balance ?? 0,
          openingDate: s.today,
        );
        _accountId = a.id;
      }
      if (_step == 2 && _accountId != null) {
        for (final e in _bills.entries) {
          final cents = e.value;
          if (cents == null || cents <= 0) continue;
          // Already registered in an earlier pass through this step.
          if (s.ledger.transactions.any(
            (t) =>
                t.deletedAt == null &&
                t.description == e.key &&
                t.status == TransactionStatus.planned,
          )) {
            continue;
          }
          final catName = _fixed(l).where((f) => f.$1 == e.key).firstOrNull?.$2;
          final cat = s.ledger.categories
              .where((x) => x.name == catName)
              .firstOrNull;
          await ctl.saveTransaction(
            TransactionInput(
              kind: TransactionKind.expense,
              amountCents: cents,
              date: s.today,
              description: e.key,
              accountId: _accountId,
              categoryId: cat?.id,
              status: TransactionStatus.planned,
              dueDate: s.today,
              recurrenceFrequency: 'monthly',
            ),
          );
        }
      }
      if (_step == 3) {
        if (_limit != null && _limit! > 0) {
          await ctl.saveCard(
            // Same rule as the account: a card from an interrupted setup is updated, not repeated.
            id: s.ledger.cards
                .where((x) => x.deletedAt == null)
                .firstOrNull
                ?.id,
            name: _cardName.text.trim().isEmpty
                ? l.card
                : _cardName.text.trim(),
            limitCents: _limit!,
            closingDay: _day(_closing.text),
            dueDay: _day(_due.text),
          );
        }
        await ctl.completeOnboarding();
        return;
      }
      setState(() => _step++);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _skip() async {
    if (_step == 1) return setState(() => _step = 2);
    if (_step == 3 || (_step == 2 && _accountId == null)) {
      await ref.read(appControllerProvider.notifier).completeOnboarding();
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    Widget headline(String t) =>
        Text(t, style: Type.headline.copyWith(color: c.text));
    Widget body(String t) =>
        Text(t, style: Type.body.copyWith(color: c.textMuted));
    final content = switch (_step) {
      0 => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandSymbol(size: 72),
          const SizedBox(height: Spacing.lg),
          Text(l.onbWelcomeTitle, style: Type.display.copyWith(color: c.text)),
          const SizedBox(height: Spacing.md),
          body(l.onbWelcomeText),
        ],
      ),
      1 => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headline(l.onbAccountTitle),
          const SizedBox(height: Spacing.xs),
          body(l.onbAccountText),
          const SizedBox(height: Spacing.md),
          STextField(label: l.accountName, controller: _accountName),
          const SizedBox(height: Spacing.md),
          Segmented<String>(
            options: [
              ('checking', l.typeBank),
              ('digital_wallet', l.typeDigital),
              ('cash', l.typeCash),
              ('savings', l.typeSavings),
            ],
            value: _accountType,
            onChanged: (v) => setState(() => _accountType = v),
          ),
          const SizedBox(height: Spacing.md),
          MoneyField(
            label: l.balanceToday,
            cents: _balance,
            onChanged: (v) => setState(() => _balance = v),
            autofocus: true,
          ),
        ],
      ),
      2 => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headline(l.onbBillsTitle),
          const SizedBox(height: Spacing.xs),
          body(l.onbBillsText),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in _fixed(l))
                SChip(
                  label: f.$1,
                  selected: _bills.containsKey(f.$1),
                  onTap: () => setState(
                    () => _bills.containsKey(f.$1)
                        ? _bills.remove(f.$1)
                        : _bills[f.$1] = null,
                  ),
                ),
            ],
          ),
          for (final k in _bills.keys.toList())
            Padding(
              padding: const EdgeInsets.only(top: Spacing.md),
              child: MoneyField(
                label: k,
                cents: _bills[k],
                onChanged: (v) => setState(() => _bills[k] = v),
              ),
            ),
        ],
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headline(l.onbCardTitle),
          const SizedBox(height: Spacing.xs),
          body(l.onbCardText),
          const SizedBox(height: Spacing.md),
          STextField(label: l.name, controller: _cardName),
          const SizedBox(height: Spacing.md),
          MoneyField(
            label: l.limit,
            cents: _limit,
            onChanged: (v) => setState(() => _limit = v),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: STextField(
                  label: l.closingDay,
                  controller: _closing,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: STextField(
                  label: l.dueDay,
                  controller: _due,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    };
    // The system back button returns one step; only the first step leaves the app.
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) setState(() => _step--);
      },
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.lg,
                  Spacing.md,
                  Spacing.md,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _step == 0
                          ? content
                          : SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: content,
                            ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Semantics(
                      label: 'Passo ${_step + 1} de 4',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < 4; i++)
                            Container(
                              width: i == _step ? 20 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i == _step ? c.primary : c.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    SButton(
                      label: _step == 0
                          ? l.onbStart
                          : _step == 3
                          ? l.finish
                          : l.continue_,
                      fullWidth: true,
                      loading: _busy,
                      onPressed: _next,
                    ),
                    if (_step > 0)
                      SButton(
                        label: l.skip,
                        variant: SButtonVariant.ghost,
                        fullWidth: true,
                        onPressed: _busy ? null : _skip,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand symbol: a coin/moon reflected on a calm waterline (Sereno + Aurora).
class BrandSymbol extends StatelessWidget {
  const BrandSymbol({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _SymbolPainter(context.colors.primary, context.colors.accent),
  );
}

class _SymbolPainter extends CustomPainter {
  _SymbolPainter(this.coin, this.wave);
  final Color coin, wave;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 64;
    canvas.scale(k, k);
    canvas.drawCircle(
      const Offset(32, 24),
      13,
      Paint()
        ..color = coin
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    final p = Path()
      ..moveTo(8, 50)
      ..cubicTo(16, 42, 24, 42, 32, 50)
      ..cubicTo(40, 58, 48, 58, 56, 50);
    canvas.drawPath(
      p,
      Paint()
        ..color = wave
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SymbolPainter old) =>
      old.coin != coin || old.wave != wave;
}
