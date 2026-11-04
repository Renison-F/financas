import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/billing/billing.dart';
import '../../domain/money/money.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

class ListFormScreen extends ConsumerStatefulWidget {
  const ListFormScreen({super.key});
  @override
  ConsumerState<ListFormScreen> createState() => _ListFormScreenState();
}

class _ListFormScreenState extends ConsumerState<ListFormScreen> {
  final _name = TextEditingController();
  final _store = TextEditingController();
  int? _budget;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final lim = withinLimit(
      s.access,
      'shoppingLists',
      s.shoppingLists.where((x) => !x.archived).length,
    );
    return StackScreen(
      title: l.newList,
      actions: [
        SButton(
          label: l.create,
          variant: SButtonVariant.ghost,
          onPressed: () async {
            if (!lim.ok) {
              await context.push('/paywall?feature=shared_lists');
              return;
            }
            final ctl = ref.read(appControllerProvider.notifier);
            final now = ctl.nowISO();
            final list = ShoppingList(
              id: ctl.newId(),
              name: _name.text.trim().isEmpty
                  ? l.defaultListName
                  : _name.text.trim(),
              store: _store.text.trim().isEmpty ? null : _store.text.trim(),
              budgetCents: _budget,
              items: const [],
              archived: false,
              createdAt: now,
              updatedAt: now,
            );
            await ctl.saveShoppingList(list);
            if (context.mounted) {
              context.pushReplacement('/shopping/list/${list.id}');
            }
          },
        ),
      ],
      children: [
        STextField(
          label: l.name,
          controller: _name,
          placeholder: l.listNameHint,
          autofocus: true,
        ),
        STextField(
          label: l.storeOptional,
          controller: _store,
          placeholder: l.storeHint,
        ),
        MoneyField(
          label: l.listBudgetLabel,
          cents: _budget,
          onChanged: (v) => setState(() => _budget = v),
          help: l.listBudgetHelp,
        ),
        if (!lim.ok)
          Text(
            l.freeLimitLists(lim.limit ?? 0),
            style: Type.bodySmall.copyWith(color: c.warning),
          ),
      ],
    );
  }
}

/// Shopping list: items by category, units, quantities, known-price estimate, check-off, duplicate, start session.
class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  final _name = TextEditingController();
  final _qty = TextEditingController(text: '1');
  String _unit = 'un';
  String _category = 'Mercearia';
  int? _price;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final list = s.shoppingLists.where((x) => x.id == widget.id).firstOrNull;
    if (list == null) {
      return StackScreen(
        title: l.lists,
        children: [EmptyState(icon: SIconName.alert, title: l.listNotFound)],
      );
    }
    final est = estimateList(list);
    final prog = listProgress(list);
    final groups = groupByCategory(list.items);
    String brl(int v) => formatBRL(v, hidden: hidden);
    ({int cents, String productId})? suggest(String n) {
      final p = findProduct(s.products, name: n);
      if (p == null) return null;
      final h = priceHistory(s.observations, p.product.id);
      return h.lastCents == null
          ? null
          : (cents: h.lastCents!, productId: p.product.id);
    }

    Future<void> add() async {
      if (_name.text.trim().isEmpty) return;
      final q = double.tryParse(_qty.text.replaceAll(',', '.')) ?? 1;
      final sug = _price == null ? suggest(_name.text) : null;
      final next = addItem(
        list,
        ListItem(
          id: ctl.newId(),
          name: _name.text.trim(),
          unit: _unit,
          quantity: q <= 0 ? 1 : q,
          category: _category,
          estimatedUnitPriceCents: _price ?? sug?.cents,
          estimateSource: _price != null
              ? 'manual'
              : sug != null
              ? 'history'
              : null,
          productId: sug?.productId,
          checked: false,
          sortOrder: 0,
        ),
        ctl.nowISO(),
      );
      await ctl.saveShoppingList(next);
      setState(() {
        _name.clear();
        _qty.text = '1';
        _price = null;
      });
    }

    return StackScreen(
      title: list.name,
      actions: [
        SButton(
          label: l.buy,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.cart,
          onPressed: () => context.push('/shopping/session?listId=${list.id}'),
        ),
      ],
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.estimateWithPrice(est.knownItems, est.totalItems),
                          style: Type.label.copyWith(color: c.textMuted),
                        ),
                        Money(
                          est.knownCents,
                          role: MoneyRole.headline,
                          hidden: hidden,
                        ),
                      ],
                    ),
                  ),
                  if (list.budgetCents != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l.budget,
                          style: Type.label.copyWith(color: c.textMuted),
                        ),
                        Money(list.budgetCents!, hidden: hidden),
                      ],
                    ),
                ],
              ),
              if ((list.budgetCents ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: RhythmBar(
                    percent: est.knownCents / list.budgetCents! * 100,
                    label: l.estimateVsBudget,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                '${list.store != null ? '${list.store} · ' : ''}${l.checkedCount(prog.checked, prog.total)}${est.unknownItems > 0 ? l.unpricedItems(est.unknownItems) : ''}',
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.addItem),
              STextField(
                controller: _name,
                placeholder: l.itemNameHint,
                semanticLabel: l.itemName,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => add(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: STextField(
                      label: l.qty,
                      controller: _qty,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Field(
                      label: l.unit,
                      child: ChipSelect<String>(
                        options: [
                          for (final u in unitIds) (u, units[u]!.label),
                        ],
                        value: _unit,
                        onChanged: (v) => setState(() => _unit = v ?? 'un'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Collapsible(
                title: l.categoryAndPrice,
                children: [
                  ChipSelect<String>(
                    options: [for (final k in defaultCategories) (k, k)],
                    value: _category,
                    onChanged: (v) => setState(() => _category = v ?? 'Outros'),
                  ),
                  MoneyField(
                    label: l.estimatedUnitPrice,
                    cents: _price,
                    onChanged: (v) => setState(() => _price = v),
                    help: l.estimatedPriceHelp,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              SButton(
                label: l.add,
                icon: SIconName.plus,
                fullWidth: true,
                onPressed: _name.text.trim().isEmpty ? null : add,
              ),
            ],
          ),
        ),
        if (groups.isEmpty)
          SCard(
            child: EmptyState(
              icon: SIconName.list,
              title: l.emptyList,
              text: l.emptyListText,
            ),
          )
        else
          for (final g in groups)
            SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.category,
                    style: Type.label.copyWith(color: c.textMuted),
                  ),
                  for (final it in g.items)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: Row(
                        children: [
                          Semantics(
                            checked: it.checked,
                            label:
                                '${it.name}, ${formatQuantity(it.quantity, it.unit)}',
                            child: Checkbox(
                              value: it.checked,
                              onChanged: (_) => ctl.saveShoppingList(
                                toggleItem(list, it.id, ctl.nowISO()),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => _edit(context, list, it),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    it.name,
                                    style: Type.body.copyWith(
                                      color: it.checked ? c.textMuted : c.text,
                                      decoration: it.checked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    '${formatQuantity(it.quantity, it.unit)}${it.estimatedUnitPriceCents != null ? ' × ${brl(it.estimatedUnitPriceCents!)}${units[it.unit]!.measured ? '/${units[it.unit]!.label}' : ''}${it.estimateSource == 'history' ? l.historySuffix : ''}' : l.noPrice}',
                                    style: Type.caption.copyWith(
                                      color: c.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (it.estimatedUnitPriceCents != null)
                            Money(
                              (it.estimatedUnitPriceCents! * it.quantity)
                                  .round(),
                              role: MoneyRole.bodySmall,
                              hidden: hidden,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        SButton(
          label: l.startWithList,
          icon: SIconName.cart,
          fullWidth: true,
          onPressed: () => context.push('/shopping/session?listId=${list.id}'),
        ),
        Wrap(
          spacing: 8,
          children: [
            SButton(
              label: l.uncheckAll,
              variant: SButtonVariant.ghost,
              compact: true,
              onPressed: () =>
                  ctl.saveShoppingList(uncheckAll(list, ctl.nowISO())),
            ),
            SButton(
              label: l.duplicate,
              variant: SButtonVariant.ghost,
              compact: true,
              onPressed: () async {
                final copy = duplicateList(
                  list,
                  ctl.newId(),
                  ctl.newId,
                  ctl.nowISO(),
                );
                await ctl.saveShoppingList(copy);
                if (context.mounted) {
                  context.pushReplacement('/shopping/list/${copy.id}');
                }
              },
            ),
            SButton(
              label: l.delete,
              variant: SButtonVariant.ghost,
              compact: true,
              onPressed: () async {
                final ok = await confirmSheet(
                  context,
                  title: l.deleteListQ,
                  text: l.deleteListText,
                  confirmLabel: l.delete,
                  cancelLabel: l.cancel,
                );
                if (!ok) return;
                await ctl.deleteShoppingList(list.id);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    ShoppingList list,
    ListItem it,
  ) async {
    final l = context.l10n;
    final ctl = ref.read(appControllerProvider.notifier);
    final name = TextEditingController(text: it.name);
    final qty = TextEditingController(
      text: it.quantity.toString().replaceAll('.', ','),
    );
    var price = it.estimatedUnitPriceCents;
    var unit = it.unit;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.xs,
            Spacing.lg,
            Spacing.lg +
                MediaQuery.viewInsetsOf(ctx).bottom +
                MediaQuery.paddingOf(ctx).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.editItemTitle,
                  style: Type.title.copyWith(color: ctx.colors.text),
                ),
                const SizedBox(height: Spacing.sm),
                STextField(label: l.name, controller: name),
                const SizedBox(height: Spacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: STextField(
                        label: l.qty,
                        controller: qty,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Field(
                        label: l.unit,
                        child: ChipSelect<String>(
                          options: [
                            for (final u in unitIds) (u, units[u]!.label),
                          ],
                          value: unit,
                          onChanged: (v) => setS(() => unit = v ?? 'un'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                MoneyField(
                  label: l.estimatedUnitPrice,
                  cents: price,
                  onChanged: (v) => setS(() => price = v),
                ),
                const SizedBox(height: Spacing.md),
                SButton(
                  label: l.save,
                  fullWidth: true,
                  onPressed: () async {
                    final q =
                        double.tryParse(qty.text.replaceAll(',', '.')) ??
                        it.quantity;
                    await ctl.saveShoppingList(
                      updateItem(
                        list,
                        it.id,
                        (x) => ListItem(
                          id: x.id,
                          name: name.text.trim().isEmpty
                              ? x.name
                              : name.text.trim(),
                          brand: x.brand,
                          category: x.category,
                          unit: unit,
                          quantity: q <= 0 ? x.quantity : q,
                          estimatedUnitPriceCents: price,
                          estimateSource: price == null
                              ? null
                              : (price == x.estimatedUnitPriceCents
                                    ? x.estimateSource
                                    : 'manual'),
                          productId: x.productId,
                          barcode: x.barcode,
                          checked: x.checked,
                          note: x.note,
                          sortOrder: x.sortOrder,
                        ),
                        ctl.nowISO(),
                      ),
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: Spacing.xs),
                SButton(
                  label: l.removeItem,
                  variant: SButtonVariant.destructive,
                  fullWidth: true,
                  onPressed: () async {
                    await ctl.saveShoppingList(
                      removeItem(list, it.id, ctl.nowISO()),
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: Spacing.xs),
                SButton(
                  label: l.cancel,
                  variant: SButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    name.dispose();
    qty.dispose();
  }
}
