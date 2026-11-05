import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/categories/categories.dart';
import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../domain/reports/reports.dart';
import '../../ui/components/components.dart';
import '../categories/category_widgets.dart';
import '../shared/add_sheet.dart';
import '../shared/format.dart';

/// Entries of a month: totals, search, filters by kind and by category, and the entries grouped by day.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key, this.kind});
  final String? kind;
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late String _month = monthKeyOf(ref.read(todayProvider));
  late String _filter = widget.kind ?? 'all';
  String _query = '';
  String? _categoryId;

  @override
  void didUpdateWidget(TransactionsScreen old) {
    super.didUpdateWidget(old);
    if (widget.kind != old.kind && widget.kind != null) {
      _setFilter(widget.kind!);
    }
  }

  /// Income categories only make sense with income; anything else works with expense categories.
  String get _categoryKind => _filter == 'income' ? 'income' : 'expense';

  void _setFilter(String f) {
    _filter = f;
    final cat = ref.read(ledgerProvider).categoryById(_categoryId);
    // A category of the other kind (or any category, for transfers) would always give an empty list.
    if (cat != null && (f == 'transfer' || cat.kind != _categoryKind)) {
      _categoryId = null;
    }
  }

  Future<void> _pickCategory() async {
    final l = context.l10n;
    final choice = await showCategoryPicker(
      context,
      kind: _categoryKind,
      selectedId: _categoryId,
      title: l.catFilter,
      allowNone: true,
      noneLabel: l.catAllCategories,
      allowCreate: false,
    );
    if (choice != null && mounted) setState(() => _categoryId = choice.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final hidden = ref.watch(privacyHiddenProvider);
    final locale = Localizations.localeOf(context).toString();
    final kinds = _filter == 'all' || _filter == 'planned'
        ? null
        : [kindFromWire(_filter)];
    final category = ledger.categoryById(_categoryId);
    final items = searchTransactions(
      ledger,
      _query,
      SearchFilters(
        kinds: kinds,
        // A main category brings its subcategories along.
        categoryIds: category == null
            ? null
            : categoryFamily(ledger, category.id).toList(),
        from: '$_month-01',
        to: endOfMonth(_month),
        status: _filter == 'planned'
            ? const [TransactionStatus.planned, TransactionStatus.partiallyPaid]
            : null,
      ),
    );
    final byDay = <String, List<Transaction>>{};
    for (final t in items) {
      (byDay[t.date] ??= []).add(t);
    }
    final totals = monthTotals(ledger, _month);
    final filters = [
      ('all', l.filterAll),
      ('expense', l.expenses),
      ('income', l.income),
      ('card_purchase', l.filterCard),
      ('transfer', l.filterTransfers),
      ('planned', l.filterPlanned),
    ];
    final filtered = _query.isNotEmpty || _filter != 'all' || category != null;
    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: AddFab(
        label: l.addTitle,
        onPressed: () => showAddSheet(context),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Layout.gutter,
                      Spacing.xxs,
                      Layout.gutter,
                      Spacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            SIconButton(
                              icon: SIconName.chevronLeft,
                              label: l.previousMonth,
                              color: c.primary,
                              onPressed: () => setState(
                                () => _month = addMonthsToKey(_month, -1),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                monthLabelLong(_month, locale),
                                style: Type.headline.copyWith(
                                  color: c.text,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SIconButton(
                              icon: SIconName.chevronRight,
                              label: l.nextMonth,
                              color: c.primary,
                              onPressed: () => setState(
                                () => _month = addMonthsToKey(_month, 1),
                              ),
                            ),
                          ],
                        ),
                        SCard(
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _Total(
                                    l.inflow,
                                    Money(
                                      totals.incomeSettled,
                                      role: MoneyRole.dense,
                                      color: c.positive,
                                      hidden: hidden,
                                    ),
                                  ),
                                ),
                                const _Rule(),
                                Expanded(
                                  child: _Total(
                                    l.outflow,
                                    Money(
                                      totals.expenseSettled,
                                      role: MoneyRole.dense,
                                      hidden: hidden,
                                    ),
                                  ),
                                ),
                                const _Rule(),
                                Expanded(
                                  child: _Total(
                                    l.result,
                                    Money(
                                      totals.net,
                                      role: MoneyRole.dense,
                                      signed: true,
                                      spacedSign: true,
                                      hidden: hidden,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        STextField(
                          placeholder: l.searchTransactions,
                          semanticLabel: l.searchTransactions,
                          onChanged: (v) => setState(() => _query = v),
                          textInputAction: TextInputAction.search,
                        ),
                        const SizedBox(height: Spacing.xs),
                        // One line that scrolls sideways: the filters never push the list down.
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (_filter != 'transfer') ...[
                                SChip(
                                  label: category == null
                                      ? l.catFilter
                                      : (categoryPath(ledger, category.id) ??
                                            category.name),
                                  icon: SIconName.filter,
                                  selected: category != null,
                                  onTap: _pickCategory,
                                ),
                                const SizedBox(width: 6),
                              ],
                              for (final f in filters) ...[
                                SChip(
                                  label: f.$2,
                                  selected: _filter == f.$1,
                                  onTap: () => setState(() => _setFilter(f.$1)),
                                ),
                                const SizedBox(width: 6),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(Layout.gutter),
                      child: SCard(
                        child: EmptyState(
                          icon: SIconName.list,
                          title: filtered
                              ? l.nothingFound
                              : l.noTransactionMonth,
                          text: _query.isNotEmpty
                              ? l.tryAnotherWord
                              : filtered
                              ? null
                              : l.registerWithPlus,
                          actionLabel: filtered ? null : l.register,
                          onAction: () => showAddSheet(context),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Layout.gutter,
                      0,
                      Layout.gutter,
                      120,
                    ),
                    sliver: SliverList.list(
                      children: [
                        for (final e in byDay.entries) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Spacing.xxs,
                              Spacing.sm,
                              Spacing.xxs,
                              6,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dayTitle(e.key, locale),
                                    style: Type.label.copyWith(
                                      color: c.textMuted,
                                    ),
                                  ),
                                ),
                                // What the day did to the money: income minus spending.
                                Money(
                                  resultCents(e.value),
                                  role: MoneyRole.dense,
                                  size: 12,
                                  color: c.textMuted,
                                  spacedSign: true,
                                  hidden: hidden,
                                ),
                              ],
                            ),
                          ),
                          SCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 2,
                            ),
                            child: Column(
                              children: dividedRows([
                                for (final t in e.value)
                                  _TxRow(t: t, ledger: ledger, hidden: hidden),
                              ]),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
    child: VerticalDivider(
      width: 1,
      thickness: 1,
      color: context.colors.surfaceInset,
    ),
  );
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value);
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Type.rowMeta.copyWith(color: context.colors.textMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: value,
      ),
    ],
  );
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.t, required this.ledger, required this.hidden});
  final Transaction t;
  final Ledger ledger;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final category = ledger.categoryById(t.categoryId);
    final icon = switch (t.kind) {
      TransactionKind.income => SIconName.arrowDown,
      TransactionKind.transfer => SIconName.swap,
      TransactionKind.cardPurchase => SIconName.card,
      TransactionKind.cardPayment => SIconName.receipt,
      _ => SIconName.arrowUp,
    };
    final status = t.status == TransactionStatus.planned
        ? ' · ${l.planned}'
        : t.status == TransactionStatus.partiallyPaid
        ? ' · ${l.paidPart(formatBRL(t.paidCents ?? 0, hidden: hidden))}'
        : '';
    final inst = t.installment != null
        ? ' · ${t.installment!.number}/${t.installment!.of}'
        : '';
    final income = t.kind == TransactionKind.income;
    return ListRow(
      // The category's own mark when there is one; the kind of entry otherwise.
      leading: category == null ? null : CategoryMark.of(category),
      icon: category == null ? icon : null,
      title: t.description.isEmpty ? kindLabel(l, t.kind) : t.description,
      description:
          '${categoryPath(ledger, t.categoryId) ?? kindLabel(l, t.kind)}$status$inst',
      // Regra do Sinal: green marks money coming in; routine spending stays in the text color.
      trailing: Money(
        signedAmount(t),
        role: MoneyRole.dense,
        color: income
            ? c.positive
            : t.status == TransactionStatus.planned
            ? c.textMuted
            : c.text,
        showPlus: income,
        spacedSign: true,
        hidden: hidden,
      ),
      onTap: () => context.push('/transaction?id=${t.id}'),
    );
  }
}
