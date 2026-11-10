/// Supermarket session: running total, budget remaining, camera/manual add with mandatory confirmation,
/// finish and optional (idempotent) expense registration.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/app_state.dart';
import '../../app/theme/tokens.dart';
import '../../domain/billing/billing.dart';
import '../../domain/entities/entities.dart';
import '../../domain/money/money.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';
import 'item_review_screen.dart';
import 'scan_result.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, this.id, this.listId});
  final String? id;
  final String? listId;
  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  ShoppingSession? _session;
  int? _budget;
  late final _store = TextEditingController();
  bool _finishing = false;
  // One item is reviewed at a time; a new reading waits for the open review to close.
  bool _reviewing = false;
  bool _inited = false;
  int _ocrCount = 0;

  AppController get _ctl => ref.read(appControllerProvider.notifier);

  Future<void> _persist(ShoppingSession s) async {
    setState(() => _session = s);
    await _ctl.saveSession(s);
  }

  void _init(AppState s) {
    if (_inited) return;
    _inited = true;
    final existing = widget.id != null
        ? s.sessions.where((x) => x.id == widget.id).firstOrNull
        : s.sessions
              .where(
                (x) =>
                    x.status == 'active' &&
                    (widget.listId == null || x.listId == widget.listId),
              )
              .firstOrNull;
    _session = existing;
    final list = s.shoppingLists
        .where((x) => x.id == (existing?.listId ?? widget.listId))
        .firstOrNull;
    _budget = list?.budgetCents;
    _store.text = list?.store ?? '';
  }

  void _consumeScan(ScanResult scan, AppState s, ShoppingList? list) {
    final l = context.l10n;
    final session = _session!;
    ref.read(scanResultProvider.notifier).set(null);
    if (scan.kind == 'nfce') {
      _persist(
        session.copyWith(
          receiptAccessKey: scan.nfceKey,
          events: [
            ...session.events,
            SessionEvent(at: _ctl.nowISO(), type: 'scan', detail: 'nfce'),
          ],
        ),
      );
      return;
    }
    if (scan.kind == 'barcode' && scan.barcode != null) {
      final b = scan.barcode!;
      final code = b.gtin ?? b.raw;
      final found = findProduct(
        s.products,
        barcode: code,
        store: session.store,
      );
      final hist = found == null
          ? null
          : priceHistory(s.observations, found.product.id);
      final listItem = list?.items
          .where(
            (i) =>
                i.barcode == code ||
                (found != null && i.productId == found.product.id),
          )
          .firstOrNull;
      _review(
        ItemDraft(
          name: found?.product.name ?? '',
          brand: found?.product.brand,
          unit: found?.product.defaultUnit ?? 'un',
          quantity: listItem != null ? _q(listItem.quantity) : '1',
          unitPriceCents: hist?.lastCents ?? listItem?.estimatedUnitPriceCents,
          barcode: code,
          productId: found?.product.id,
          priceSource: hist?.lastCents != null ? 'history' : 'manual',
          warnings: [
            if (found == null) l.newProductWarn,
            if (b.kind == 'gs1_variable_measure') l.scaleCodeWarn,
          ],
          listItemId: listItem?.id,
        ),
      );
      return;
    }
    final r = scan.reading;
    if (r == null) {
      _review(
        ItemDraft(
          name: '',
          unit: 'un',
          quantity: '1',
          priceSource: 'manual',
          warnings: [l.ocrUnavailableWarn],
        ),
      );
      return;
    }
    if (!withinLimit(s.access, 'ocrScansPerMonth', _ocrCount).ok &&
        !s.access.features.contains('unlimited_ocr')) {
      context.push('/paywall?feature=unlimited_ocr');
      return;
    }
    _ocrCount++;
    final found = r.barcode != null
        ? findProduct(s.products, barcode: r.barcode)
        : r.internalCode != null
        ? findProduct(
            s.products,
            internalCode: r.internalCode,
            store: session.store,
          )
        : r.name != null
        ? findProduct(s.products, name: r.name)
        : null;
    final hist = found == null
        ? null
        : priceHistory(s.observations, found.product.id);
    final variation = hist != null && r.priceCents != null
        ? priceVariation(hist, r.priceCents!)
        : null;
    final warnings = [...r.warnings];
    if (variation != null && variation.percent.abs() >= 10) {
      warnings.add(
        l.variationWarn(
          '${variation.percent > 0 ? '+' : ''}${variation.percent}',
          formatBRL(variation.vsCents),
        ),
      );
    }
    if (r.confidence < 0.75) warnings.add(l.lowConfidenceWarn);
    _review(
      ItemDraft(
        name: found?.product.name ?? r.name ?? '',
        unit: r.priceUnit,
        quantity: '1',
        unitPriceCents: r.priceCents,
        barcode: r.barcode,
        productId: found?.product.id,
        priceSource: 'label_ocr',
        confidence: r.confidence,
        warnings: warnings,
        promoFromCents: r.promoFromCents,
      ),
    );
  }

  static String _q(double v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toString().replaceAll('.', ',');

  /// Opens the review of one item over the cart; the item only enters the cart when confirmed there.
  Future<void> _review(ItemDraft d) async {
    setState(() => _reviewing = true);
    final ok = await showItemReview(context, d);
    if (!mounted) return;
    // Rebuilding here also picks up a reading that arrived while the review was open.
    setState(() => _reviewing = false);
    if (ok) await _confirmDraft(d);
  }

  Future<void> _confirmDraft(ItemDraft d) async {
    final session = _session;
    if (session == null || !d.complete) return;
    var productId = d.productId;
    if (productId == null && (d.barcode != null || d.name.trim().isNotEmpty)) {
      productId = _ctl.newId();
      await _ctl.saveProduct(
        Product(
          id: productId,
          name: d.name.trim(),
          brand: d.brand,
          barcode: d.barcode,
          internalCodes: const [],
          defaultUnit: d.unit,
          favorite: false,
          createdAt: _ctl.nowISO(),
          updatedAt: _ctl.nowISO(),
        ),
      );
    }
    final line = CartLine(
      id: d.lineId ?? _ctl.newId(),
      productId: productId,
      name: d.name.trim(),
      brand: d.brand,
      barcode: d.barcode,
      unit: d.unit,
      quantity: d.qty,
      unitPriceCents: d.unitPriceCents!,
      priceSource: d.priceSource,
      confidence: d.lineId != null ? 1 : d.confidence,
      listItemId: d.listItemId,
      checked: true,
      discountPercent: d.discountPercent,
      promo: d.promo,
    );
    final next = d.lineId != null
        ? updateSessionLine(session, d.lineId!, (_) => line, _ctl.nowISO())
        : addToSession(session, line, _ctl.nowISO());
    await _persist(next);
    unawaitedHaptic();
  }

  void unawaitedHaptic() {
    if (ref.read(prefsProvider).hapticsEnabled) HapticFeedback.lightImpact();
  }

  Future<void> _addFromList(ShoppingList list, String itemId) async {
    final l = context.l10n;
    final it = list.items.where((i) => i.id == itemId).firstOrNull;
    if (it == null) return;
    final line = lineFromListItem(it, _ctl.newId());
    if (line != null) {
      await _persist(addToSession(_session!, line, _ctl.nowISO()));
    } else {
      await _review(
        ItemDraft(
          name: it.name,
          unit: it.unit,
          quantity: _q(it.quantity),
          priceSource: 'manual',
          warnings: [l.noPriceInListWarn],
          listItemId: it.id,
          productId: it.productId,
          barcode: it.barcode,
        ),
      );
    }
  }

  /// Finishing closes the cart for good, so it is confirmed first.
  Future<void> _confirmFinish(String total) async {
    final l = context.l10n;
    final ok = await confirmSheet(
      context,
      title: l.finishPurchaseQ,
      text: l.finishPurchaseText(total),
      confirmLabel: l.finishConfirm,
      cancelLabel: l.cancel,
      destructive: false,
    );
    if (!ok || !mounted) return;
    await _finish();
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    try {
      final r = finishSession(_session!, _ctl.nowISO(), _ctl.newId);
      await _persist(r.session);
      await _ctl.addPriceObservations(r.observations);
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  Future<void> _registerExpense(AppState s) async {
    final l = context.l10n;
    final r = finishSession(_session!, _ctl.nowISO(), _ctl.newId);
    final st = r.suggestedTransaction;
    if (st == null) return;
    final cat =
        s.ledger.categories
            .where((k) => k.name == l.groceriesCategory)
            .firstOrNull ??
        s.ledger.categories
            .where((k) => k.name == 'Supermercado')
            .firstOrNull ??
        s.ledger.categories.where((k) => k.name == 'Alimentação').firstOrNull;
    try {
      final created = await _ctl.saveTransaction(
        TransactionInput(
          kind: TransactionKind.expense,
          amountCents: st.amountCents,
          date: s.today,
          description: st.description,
          merchant: st.merchant,
          categoryId: cat?.id,
          accountId: s.ledger.accounts.where((a) => a.isActive).firstOrNull?.id,
          status: TransactionStatus.settled,
          externalRef: st.externalRef,
        ),
      );
      if (created.isNotEmpty) {
        await _persist(
          markRegistered(_session!, created.first.id, _ctl.nowISO()),
        );
      }
    } on AppError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    _init(s);
    final list = s.shoppingLists
        .where((x) => x.id == (_session?.listId ?? widget.listId))
        .firstOrNull;
    final scan = ref.watch(scanResultProvider);
    if (scan != null && _session != null && !_reviewing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _consumeScan(scan, s, list);
      });
    }
    String brl(int v) => formatBRL(v, hidden: hidden);
    final session = _session;
    if (session == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(Spacing.md),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.newPurchase2,
                        style: Type.headline.copyWith(color: c.text),
                      ),
                      SButton(
                        label: l.close,
                        variant: SButtonVariant.ghost,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    list != null
                        ? l.fromList(list.name, list.items.length)
                        : l.noListSession,
                    style: Type.body.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(height: Spacing.md),
                  STextField(
                    label: l.supermarket,
                    controller: _store,
                    placeholder: l.storeHint,
                  ),
                  const SizedBox(height: Spacing.md),
                  MoneyField(
                    label: l.sessionBudgetLabel,
                    cents: _budget,
                    onChanged: (v) => setState(() => _budget = v),
                    help: l.sessionBudgetHelp,
                  ),
                  const SizedBox(height: Spacing.md),
                  SButton(
                    label: l.start,
                    icon: SIconName.cart,
                    fullWidth: true,
                    onPressed: () => _persist(
                      startSession(
                        _ctl.newId(),
                        _ctl.nowISO(),
                        store: _store.text.trim().isEmpty
                            ? null
                            : _store.text.trim(),
                        list: list,
                        budgetCents: _budget,
                      ),
                    ),
                  ),
                  if (list == null && s.shoppingLists.any((x) => !x.archived))
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.md),
                      child: Field(
                        label: l.orChooseList,
                        child: ChipSelect<String>(
                          options: [
                            for (final x in s.shoppingLists.where(
                              (x) => !x.archived,
                            ))
                              (x.id, x.name),
                          ],
                          value: null,
                          onChanged: (v) {
                            if (v != null) {
                              context.pushReplacement(
                                '/shopping/session?listId=$v',
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final totals = sessionTotals(session);
    final readOnly = session.status == 'finished';
    final pva = list == null ? null : plannedVsActual(session, list);
    final remainingItems = list == null
        ? const <ListItem>[]
        : list.items
              .where((i) => !session.lines.any((x) => x.listItemId == i.id))
              .toList();
    final progressPct = list != null && list.items.isNotEmpty
        ? (list.items.length - remainingItems.length) / list.items.length * 100
        : null;
    final agitado = totals.state == 'agitado',
        atencao = totals.state == 'atencao';
    final heroBg = agitado
        ? c.negativeContainer
        : atencao
        ? c.warningContainer
        : c.primaryContainer;
    final heroFg = agitado
        ? c.negative
        : atencao
        ? c.warning
        : c.onPrimaryContainer;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.xs,
                Spacing.xs,
                Spacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.store ?? l.supermarket,
                          style: Type.title.copyWith(color: c.text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          readOnly
                              ? l.finishedOn(
                                  dayMonth(
                                    session.finishedAt ?? session.startedAt,
                                  ),
                                )
                              : l.itemsInCart(session.lines.length),
                          style: Type.caption.copyWith(color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                  SButton(
                    label: readOnly ? l.close : l.exit,
                    variant: SButtonVariant.ghost,
                    onPressed: () async {
                      if (readOnly) return context.pop();
                      final ok = await confirmSheet(
                        context,
                        title: l.leavePurchaseQ,
                        text: l.leavePurchaseText,
                        confirmLabel: l.leaveKeep,
                        cancelLabel: l.cancel,
                        destructive: false,
                      );
                      if (ok && context.mounted) context.pop();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: SCard(
                color: heroBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.cartTotal,
                      style: Type.label.copyWith(color: heroFg),
                    ),
                    Money(
                      totals.totalCents,
                      role: MoneyRole.hero,
                      color: agitado ? c.negative : c.onPrimaryContainer,
                      hidden: hidden,
                    ),
                    if (totals.budgetCents != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        totals.remainingCents! >= 0
                            ? l.stillFits(
                                brl(totals.remainingCents!),
                                brl(totals.budgetCents!),
                              )
                            : l.overBudgetBy(
                                brl(-totals.remainingCents!),
                                brl(totals.budgetCents!),
                              ),
                        style: Type.bodySmall.copyWith(
                          color: agitado ? c.negative : c.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RhythmBar(
                        percent: totals.budgetCents! > 0
                            ? totals.totalCents / totals.budgetCents! * 100
                            : 0,
                        expectedPercent: progressPct,
                        label: l.cartVsBudget,
                      ),
                    ] else
                      Text(
                        l.noBudgetSession,
                        style: Type.caption.copyWith(
                          color: c.onPrimaryContainer,
                        ),
                      ),
                    if (totals.unconfirmedLines > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l.lowConfidenceItems(totals.unconfirmedLines),
                          style: Type.caption.copyWith(color: c.warning),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.md,
                  Spacing.md,
                ),
                children: [
                  if (session.lines.isEmpty)
                    SCard(
                      child: EmptyState(
                        icon: SIconName.cart,
                        title: l.emptyCart,
                        text: l.emptyCartText,
                      ),
                    )
                  else
                    for (final line in session.lines)
                      Builder(
                        builder: (_) {
                          final t = lineTotal(line);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: Spacing.xs),
                            child: SCard(
                              padding: const EdgeInsets.all(Spacing.sm),
                              onTap: readOnly
                                  ? null
                                  : () => _review(
                                      ItemDraft(
                                        name: line.name,
                                        brand: line.brand,
                                        unit: line.unit,
                                        quantity: _q(line.quantity),
                                        unitPriceCents: line.unitPriceCents,
                                        barcode: line.barcode,
                                        productId: line.productId,
                                        priceSource: line.priceSource,
                                        confidence: line.confidence,
                                        lineId: line.id,
                                        listItemId: line.listItemId,
                                        discountPercent: line.discountPercent,
                                        promo: line.promo,
                                      ),
                                    ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          line.name,
                                          style: Type.body.copyWith(
                                            color: c.text,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${formatQuantity(line.quantity, line.unit)} × ${brl(line.unitPriceCents)}${units[line.unit]!.measured ? '/${units[line.unit]!.label}' : ''}${t.discountCents > 0 ? l.discountLine(brl(t.discountCents)) : ''}${line.priceSource == 'label_ocr' && (line.confidence ?? 1) < 0.75 ? l.checkSuffix : ''}',
                                          style: Type.caption.copyWith(
                                            color: c.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Money(t.netCents, hidden: hidden),
                                  if (!readOnly)
                                    SIconButton(
                                      icon: SIconName.close,
                                      label: l.removeLine(line.name),
                                      size: 18,
                                      onPressed: () => _persist(
                                        removeFromSession(
                                          session,
                                          line.id,
                                          _ctl.nowISO(),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  if (!readOnly && remainingItems.isNotEmpty)
                    SCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.fromListMissing(remainingItems.length),
                            style: Type.label.copyWith(color: c.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final i in remainingItems)
                                SChip(
                                  label:
                                      '${i.name} · ${formatQuantity(i.quantity, i.unit)}',
                                  onTap: () => _addFromList(list!, i.id),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (readOnly)
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.xs),
                      child: SCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l.summary,
                              style: Type.title.copyWith(color: c.text),
                            ),
                            if (pva != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                l.plannedVsActualLine(
                                  brl(pva.plannedKnownCents),
                                  brl(pva.actualCents),
                                  brl(pva.differenceCents),
                                ),
                                style: Type.bodySmall.copyWith(color: c.text),
                              ),
                              Text(
                                l.boughtLine(
                                  pva.bought,
                                  pva.notBought.length,
                                  pva.extra.length,
                                ),
                                style: Type.bodySmall.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                            if (session.receiptAccessKey != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  l.receiptRead(
                                    session.receiptAccessKey!.substring(
                                      session.receiptAccessKey!.length - 8,
                                    ),
                                  ),
                                  style: Type.caption.copyWith(
                                    color: c.textMuted,
                                  ),
                                ),
                              ),
                            const SizedBox(height: Spacing.sm),
                            if (session.transactionId != null)
                              Text(
                                l.expenseRegistered,
                                style: Type.bodySmall.copyWith(
                                  color: c.positive,
                                ),
                              )
                            else ...[
                              SButton(
                                label: l.registerAsExpense(
                                  brl(totals.totalCents),
                                ),
                                fullWidth: true,
                                onPressed: () => _registerExpense(s),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.registerOnceHelp,
                                style: Type.caption.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!readOnly)
              Container(
                decoration: BoxDecoration(
                  color: c.bg,
                  border: Border(top: BorderSide(color: c.border)),
                ),
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.xs,
                  Spacing.md,
                  Spacing.xs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SButton(
                            label: l.tagBtn,
                            icon: SIconName.camera,
                            compact: true,
                            fullWidth: true,
                            onPressed: () =>
                                context.push('/shopping/scan?mode=label'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SButton(
                            label: l.codeBtn,
                            icon: SIconName.barcode,
                            variant: SButtonVariant.secondary,
                            compact: true,
                            fullWidth: true,
                            onPressed: () =>
                                context.push('/shopping/scan?mode=barcode'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SButton(
                            label: l.manualBtn,
                            icon: SIconName.plus,
                            variant: SButtonVariant.secondary,
                            compact: true,
                            fullWidth: true,
                            onPressed: () => _review(
                              ItemDraft(
                                name: '',
                                unit: 'un',
                                quantity: '1',
                                priceSource: 'manual',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SButton(
                      label: l.finishPurchase,
                      variant: SButtonVariant.ghost,
                      fullWidth: true,
                      loading: _finishing,
                      onPressed: session.lines.isEmpty
                          ? null
                          : () => _confirmFinish(brl(totals.totalCents)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
