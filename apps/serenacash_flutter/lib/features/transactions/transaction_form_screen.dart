/// New/edit transaction in 3 taps: amount (keyboard open), category chips, account/card; advanced options collapsed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/app_state.dart';
import '../../app/theme/tokens.dart';
import '../../domain/categories/categories.dart';
import '../../domain/entities/entities.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../categories/category_widgets.dart';
import '../shared/format.dart';
import 'attachments_section.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    super.key,
    this.id,
    this.kind,
    this.planned = false,
    this.cardId,
    this.date,
  });
  final String? id;
  final String? kind;
  final bool planned;
  final String? cardId;
  final String? date;
  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  static const _editable = {
    TransactionKind.expense,
    TransactionKind.income,
    TransactionKind.transfer,
    TransactionKind.cardPurchase,
  };
  Transaction? _existing;
  late TransactionKind _kind;
  int? _amount;
  late final TextEditingController _desc, _notes, _merchant;
  // The main category and, when one is chosen, its subcategory; the entry stores the most specific.
  String? _categoryId, _subcategoryId;
  String? _accountId, _toAccountId, _cardId;
  late String _date;
  late bool _planned;
  int _installments = 1;
  String? _recurrence;
  late List<String> _tags;
  String? _error;
  bool _saving = false;
  int? _partial;

  @override
  void initState() {
    super.initState();
    final s = ref.read(appControllerProvider).requireValue;
    final ledger = s.ledger;
    _existing = widget.id == null ? null : ledger.transactionById(widget.id);
    final ex = _existing;
    _kind =
        ex?.kind ??
        (widget.kind == null
            ? TransactionKind.expense
            : kindFromWire(widget.kind!));
    _amount = ex?.amountCents;
    _desc = TextEditingController(text: ex?.description ?? '');
    _notes = TextEditingController(text: ex?.notes ?? '');
    _merchant = TextEditingController(text: ex?.merchant ?? '');
    final cat = ledger.categoryById(ex?.categoryId);
    _categoryId = cat?.parentId ?? cat?.id;
    _subcategoryId = cat?.parentId == null ? null : cat?.id;
    _accountId =
        ex?.accountId ??
        ledger.accounts.where((a) => a.isActive).firstOrNull?.id;
    _toAccountId = ex?.toAccountId;
    _cardId =
        ex?.cardId ??
        widget.cardId ??
        ledger.cards.where((x) => x.isActive).firstOrNull?.id;
    _date = ex?.date ?? widget.date ?? s.today;
    _planned = ex != null
        ? ex.status != TransactionStatus.settled
        : widget.planned;
    _tags = ex?.tags ?? [];
  }

  @override
  void dispose() {
    _desc.dispose();
    _notes.dispose();
    _merchant.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Two taps before the button has had time to show "saving" must still save once.
    if (_saving) return;
    final l = context.l10n;
    setState(() => _error = null);
    if (_amount == null || _amount! <= 0) {
      return setState(() => _error = l.errAmount);
    }
    if (_kind == TransactionKind.cardPurchase && _cardId == null) {
      return setState(() => _error = l.errCardFirst);
    }
    if (_kind != TransactionKind.cardPurchase && _accountId == null) {
      return setState(() => _error = l.errAccountFirst);
    }
    if (_kind == TransactionKind.transfer &&
        (_toAccountId == null || _toAccountId == _accountId)) {
      return setState(() => _error = l.errTwoAccounts);
    }
    setState(() => _saving = true);
    try {
      final ex = _existing;
      // "Not paid yet" only exists for expenses and income; a value left over from another kind of
      // entry must not turn a card purchase or a transfer into a bill.
      final planned = _planned && _canBePlanned;
      final status = _kind == TransactionKind.cardPurchase
          ? TransactionStatus.settled
          : planned
          ? TransactionStatus.planned
          : ex?.status == TransactionStatus.partiallyPaid
          ? TransactionStatus.partiallyPaid
          : TransactionStatus.settled;
      await ref
          .read(appControllerProvider.notifier)
          .saveTransaction(
            TransactionInput(
              id: ex?.id,
              kind: _kind,
              amountCents: _amount!,
              date: _date,
              description: _desc.text.trim().length > 140
                  ? _desc.text.trim().substring(0, 140)
                  : _desc.text.trim(),
              categoryId: _kind == TransactionKind.transfer
                  ? null
                  : _subcategoryId ?? _categoryId,
              accountId: _kind == TransactionKind.cardPurchase
                  ? null
                  : _accountId,
              toAccountId: _kind == TransactionKind.transfer
                  ? _toAccountId
                  : null,
              cardId: _kind == TransactionKind.cardPurchase ? _cardId : null,
              status: status,
              dueDate: planned ? _date : null,
              tags: _tags,
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              merchant: _merchant.text.trim().isEmpty
                  ? null
                  : _merchant.text.trim(),
              installments: _kind == TransactionKind.cardPurchase && ex == null
                  ? _installments
                  : null,
              recurrenceFrequency: ex == null ? _recurrence : null,
            ),
            errAmount: l.errAmount,
            errTransfer: l.errTwoAccounts,
            errCard: l.errCardFirst,
            errAccount: l.errAccountFirst,
          );
      if (mounted) context.pop();
    } on AppError catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l.errSave);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _categoryKind => _categoryKindOf(_kind);
  static String _categoryKindOf(TransactionKind k) =>
      k == TransactionKind.income ? 'income' : 'expense';
  bool get _canBePlanned =>
      _kind == TransactionKind.expense || _kind == TransactionKind.income;

  /// Any edit clears the message of the last attempt: it described a state that no longer exists.
  void _edit(VoidCallback change) => setState(() {
    _error = null;
    change();
  });

  /// Switching the kind keeps everything that still applies. An expense and a card purchase share
  /// the same categories, so going from one to the other keeps the category too.
  void _setKind(TransactionKind k) => _edit(() {
    if (_categoryKindOf(k) != _categoryKind) {
      _categoryId = null;
      _subcategoryId = null;
    }
    _kind = k;
  });

  /// Creates an account without leaving the entry: the form stays underneath with what was typed.
  Future<void> _newAccount({required bool destination}) async {
    final id = await context.push<String>('/accounts/new');
    if (id == null || !mounted) return;
    _edit(() {
      if (destination) {
        _toAccountId = id;
      } else {
        _accountId = id;
        if (_toAccountId == id) _toAccountId = null;
      }
    });
  }

  Future<void> _newCard() async {
    final id = await context.push<String>('/cards/new');
    if (id == null || !mounted) return;
    _edit(() => _cardId = id);
  }

  Widget _choices({
    required List<(String, String)> options,
    required String? value,
    required ValueChanged<String> onPick,
    required String newLabel,
    required VoidCallback onNew,
  }) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final (id, name) in options)
        SChip(label: name, selected: id == value, onTap: () => onPick(id)),
      SChip(label: newLabel, icon: SIconName.plus, onTap: onNew),
    ],
  );

  /// Opens the picker; what was typed stays, because this screen keeps its state underneath.
  Future<void> _pickCategory() async {
    final choice = await showCategoryPicker(
      context,
      kind: _categoryKind,
      selectedId: _subcategoryId ?? _categoryId,
      allowNone: true,
    );
    if (choice == null || !mounted) return;
    final ledger = ref.read(ledgerProvider);
    final picked = ledger.categoryById(choice.id);
    setState(() {
      if (picked == null) {
        _categoryId = null;
        _subcategoryId = null;
      } else if (picked.parentId != null) {
        _categoryId = picked.parentId;
        _subcategoryId = picked.id;
      } else {
        // A different main category: a subcategory of the previous one no longer applies.
        if (ledger.categoryById(_subcategoryId)?.parentId != picked.id) {
          _subcategoryId = null;
        }
        _categoryId = picked.id;
      }
    });
  }

  Future<void> _newSubcategory() async {
    final created = await openCategoryForm(
      context,
      kind: _categoryKind,
      parentId: _categoryId,
      lockKind: true,
    );
    if (created == null || !mounted) return;
    setState(() {
      // The form allows changing the main category; follow what was actually saved.
      _categoryId = created.parentId ?? created.id;
      _subcategoryId = created.parentId == null ? null : created.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final ledger = s.ledger;
    final hidden = ref.watch(privacyHiddenProvider);
    final ex = _existing;
    final editable = ex == null || _editable.contains(ex.kind);
    final category = ledger.categoryById(_categoryId);
    final subcategories = category == null
        ? const <Category>[]
        : subcategoriesOf(ledger, category.id)
              .followedBy(
                // An archived subcategory stays visible on the entry that already uses it.
                ledger.categories.where(
                  (x) => x.id == _subcategoryId && x.archived,
                ),
              )
              .toList();
    final accounts = ledger.accounts.where((a) => a.isActive).toList();
    final cards = ledger.cards.where((x) => x.isActive).toList();
    final ctl = ref.read(appControllerProvider.notifier);
    final title = ex != null
        ? (editable
              ? l.editTransaction
              : (ex.description.isEmpty ? l.transaction : ex.description))
        : l.newTransaction;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            SheetHeader(
              title: title,
              leading: SButton(
                label: l.cancel,
                variant: SButtonVariant.ghost,
                onPressed: () => context.pop(),
              ),
              trailing: editable
                  ? SButton(
                      label: l.save,
                      variant: SButtonVariant.ghost,
                      loading: _saving,
                      onPressed: _save,
                    )
                  : null,
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  0,
                  Spacing.md,
                  80,
                ),
                children: [
                  if (ex == null) ...[
                    Segmented<TransactionKind>(
                      options: [
                        (TransactionKind.expense, l.kindExpense),
                        (TransactionKind.income, l.kindIncome),
                        (TransactionKind.transfer, l.kindTransfer),
                        (TransactionKind.cardPurchase, l.card),
                      ],
                      value: _kind,
                      onChanged: _setKind,
                    ),
                    const SizedBox(height: Spacing.md),
                  ],
                  MoneyField(
                    label: l.amount,
                    cents: _amount,
                    onChanged: (v) => _edit(() => _amount = v),
                    autofocus: ex == null,
                    error: _error != null && (_amount == null || _amount == 0)
                        ? _error
                        : null,
                  ),
                  const SizedBox(height: Spacing.md),
                  STextField(
                    label: l.description,
                    controller: _desc,
                    placeholder: _kind == TransactionKind.income
                        ? l.descHintIncome
                        : _kind == TransactionKind.transfer
                        ? l.descHintTransfer
                        : l.descHintExpense,
                    maxLength: 140,
                    enabled: editable,
                  ),
                  const SizedBox(height: Spacing.md),
                  if (_kind != TransactionKind.transfer) ...[
                    Field(
                      label: l.category,
                      child: SCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                        ),
                        onTap: editable ? _pickCategory : null,
                        semanticHint: l.catChoose,
                        child: ListRow(
                          leading: category == null
                              ? IconTile(
                                  icon: SIconName.tag,
                                  color: c.textMuted,
                                  background: c.surfaceInset,
                                )
                              : CategoryMark.of(category),
                          title: category?.name ?? l.catChoose,
                          titleMaxLines: 2,
                          chevron: editable,
                        ),
                      ),
                    ),
                    if (category != null && editable) ...[
                      const SizedBox(height: Spacing.sm),
                      Field(
                        label: l.catSubcategory,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final x in subcategories)
                              SChip(
                                label: x.name,
                                selected: x.id == _subcategoryId,
                                onTap: () => setState(
                                  () => _subcategoryId = x.id == _subcategoryId
                                      ? null
                                      : x.id,
                                ),
                              ),
                            SChip(
                              label: subcategories.isEmpty
                                  ? l.catNewSub
                                  : l.catNewSubShort,
                              icon: SIconName.plus,
                              onTap: _newSubcategory,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.md),
                  ],
                  // An expense already typed can go to the card statement instead of an account
                  // without starting over: both are the same entry with a different destination.
                  if (ex == null &&
                      (_kind == TransactionKind.expense ||
                          _kind == TransactionKind.cardPurchase)) ...[
                    Field(
                      label: l.payWith,
                      help: _kind == TransactionKind.cardPurchase
                          ? l.cardPurchaseHelp
                          : null,
                      child: Segmented<TransactionKind>(
                        options: [
                          (TransactionKind.expense, l.payWithAccount),
                          (TransactionKind.cardPurchase, l.payWithCard),
                        ],
                        value: _kind,
                        onChanged: _setKind,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                  ],
                  if (_kind == TransactionKind.cardPurchase)
                    Field(
                      label: l.card,
                      child: _choices(
                        options: [for (final x in cards) (x.id, x.name)],
                        value: _cardId,
                        onPick: (v) => _edit(() => _cardId = v),
                        newLabel: cards.isEmpty
                            ? l.registerCard
                            : l.newCardChip,
                        onNew: _newCard,
                      ),
                    )
                  else
                    Field(
                      label: _kind == TransactionKind.transfer
                          ? l.from
                          : l.account,
                      child: _choices(
                        options: [for (final x in accounts) (x.id, x.name)],
                        value: _accountId,
                        onPick: (v) => _edit(() {
                          _accountId = v;
                          if (_toAccountId == v) _toAccountId = null;
                        }),
                        newLabel: accounts.isEmpty
                            ? l.registerAccount
                            : l.newAccountChip,
                        onNew: () => _newAccount(destination: false),
                      ),
                    ),
                  const SizedBox(height: Spacing.md),
                  if (_kind == TransactionKind.transfer) ...[
                    Field(
                      label: l.to,
                      help: accounts.length < 2 ? l.transferNeedsTwo : null,
                      child: _choices(
                        options: [
                          for (final x in accounts.where(
                            (a) => a.id != _accountId,
                          ))
                            (x.id, x.name),
                        ],
                        value: _toAccountId,
                        onPick: (v) => _edit(() => _toAccountId = v),
                        newLabel: l.newAccountChip,
                        onNew: () => _newAccount(destination: true),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                  ],
                  DateField(
                    label: _planned && _canBePlanned ? l.dueDate : l.date,
                    value: _date,
                    onChanged: (d) => _edit(() => _date = d),
                    today: s.today,
                    todayLabel: l.today,
                    yesterdayLabel: l.yesterday,
                    tomorrowLabel: l.tomorrow,
                    invalidLabel: l.invalidDate,
                    calendarLabel: l.openCalendar,
                  ),
                  const SizedBox(height: Spacing.md),
                  if (_kind != TransactionKind.cardPurchase &&
                      _kind != TransactionKind.transfer) ...[
                    ToggleRow(
                      label: _kind == TransactionKind.income
                          ? l.notReceivedYet
                          : l.notPaidYet,
                      value: _planned,
                      help: _kind == TransactionKind.income
                          ? l.plannedHelpIncome
                          : l.plannedHelp,
                      onChanged: (v) => _edit(() => _planned = v),
                    ),
                    const SizedBox(height: Spacing.md),
                  ],
                  if (_kind == TransactionKind.cardPurchase && ex == null) ...[
                    Field(
                      label: l.installments,
                      help: _installments > 1 && _amount != null
                          ? l.installmentsHelp(
                              _installments,
                              formatBRL(
                                (_amount! / _installments).round(),
                                hidden: hidden,
                              ),
                            )
                          : null,
                      child: ChipSelect<int>(
                        options: [
                          for (final n in const [
                            1,
                            2,
                            3,
                            4,
                            5,
                            6,
                            10,
                            12,
                            18,
                            24,
                          ])
                            (n, n == 1 ? l.cashPayment : '${n}x'),
                        ],
                        value: _installments,
                        onChanged: (v) =>
                            setState(() => _installments = v ?? 1),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                  ],
                  Collapsible(
                    title: l.moreOptions,
                    children: [
                      if (ex == null)
                        Field(
                          label: l.repeat,
                          help: l.repeatHelp,
                          child: ChipSelect<String>(
                            options: [
                              for (final f in const [
                                'monthly',
                                'weekly',
                                'biweekly',
                                'yearly',
                              ])
                                (f, frequencyLabel(l, f)),
                            ],
                            value: _recurrence,
                            allowNone: true,
                            onChanged: (v) => setState(() => _recurrence = v),
                          ),
                        ),
                      if (ledger.tags.isNotEmpty)
                        Field(
                          label: l.tags,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final t in ledger.tags)
                                SChip(
                                  label: t.name,
                                  selected: _tags.contains(t.id),
                                  onTap: () => setState(
                                    () => _tags.contains(t.id)
                                        ? _tags.remove(t.id)
                                        : _tags.add(t.id),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      STextField(
                        label: l.merchant,
                        controller: _merchant,
                        placeholder: l.optional,
                      ),
                      STextField(
                        label: l.notes,
                        controller: _notes,
                        placeholder: l.optional,
                        maxLines: 3,
                        maxLength: 500,
                      ),
                    ],
                  ),
                  if (ex != null) ...[
                    const SizedBox(height: Spacing.md),
                    AttachmentsSection(transaction: ex),
                  ],
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.sm),
                      child: Text(
                        _error!,
                        style: Type.bodySmall.copyWith(color: c.negative),
                      ),
                    ),
                  if (ex != null &&
                      ex.status != TransactionStatus.settled &&
                      ex.status != TransactionStatus.cancelled) ...[
                    const SizedBox(height: Spacing.md),
                    Text(
                      l.payment,
                      style: Type.label.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: Spacing.sm),
                    SButton(
                      label: ex.kind == TransactionKind.income
                          ? l.markReceived
                          : l.markPaid,
                      icon: SIconName.check,
                      fullWidth: true,
                      onPressed: () async {
                        await ctl.settleTransaction(ex.id);
                        if (context.mounted) context.pop();
                      },
                    ),
                    const SizedBox(height: Spacing.sm),
                    MoneyField(
                      label: l.payPart(
                        formatBRL(
                          ex.amountCents - (ex.paidCents ?? 0),
                          hidden: hidden,
                        ),
                      ),
                      cents: _partial,
                      onChanged: (v) => setState(() => _partial = v),
                    ),
                    const SizedBox(height: Spacing.sm),
                    SButton(
                      label: l.registerPartial,
                      variant: SButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: _partial == null || _partial == 0
                          ? null
                          : () async {
                              await ctl.settleTransaction(
                                ex.id,
                                paidCents: _partial,
                              );
                              if (context.mounted) context.pop();
                            },
                    ),
                  ],
                  if (ex != null) ...[
                    const SizedBox(height: Spacing.md),
                    SButton(
                      label: ex.seriesId != null || ex.installment != null
                          ? l.deleteThisAndNext
                          : l.deleteTransaction,
                      variant: SButtonVariant.destructive,
                      icon: SIconName.trash,
                      fullWidth: true,
                      onPressed: () async {
                        final ok = await confirmSheet(
                          context,
                          title: l.deleteTransactionQ,
                          text: ex.seriesId != null
                              ? l.deleteSeriesText
                              : l.deleteOneText,
                          confirmLabel: l.delete,
                          cancelLabel: l.cancel,
                        );
                        if (!ok || !context.mounted) return;
                        await ctl.deleteTransaction(
                          ex.id,
                          series: ex.seriesId != null,
                          undoLabel: (n) =>
                              n > 1 ? l.deletedMany(n) : l.deletedOne,
                        );
                        if (context.mounted) context.pop();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
