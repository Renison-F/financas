/// Review of one cart item before it enters the cart: what was read (or typed) is shown in fields
/// the user can correct, and nothing is added until they confirm.
///
/// It is a screen of its own, over the session: the cart stays as it was underneath, the fields
/// scroll, and the action stays above the keyboard and the system bars.
library;

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme/tokens.dart';
import '../../domain/money/money.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';

/// The item being reviewed. Mutable on purpose: the review screen edits it in place and the session
/// reads it back only when the user confirms.
class ItemDraft {
  ItemDraft({
    required this.name,
    this.brand,
    required this.unit,
    required this.quantity,
    this.unitPriceCents,
    this.barcode,
    this.productId,
    required this.priceSource,
    this.confidence,
    this.warnings = const [],
    this.lineId,
    this.listItemId,
    this.discountPercent,
    this.promo,
    this.promoFromCents,
  });
  String name;
  String? brand;
  String unit;
  String quantity;
  int? unitPriceCents;
  String? barcode;
  String? productId;
  String priceSource;
  double? confidence;
  List<String> warnings;
  String? lineId;
  String? listItemId;
  double? discountPercent;
  Promo? promo;
  int? promoFromCents;
  double get qty => double.tryParse(quantity.replaceAll(',', '.')) ?? 0;
  bool get complete =>
      unitPriceCents != null && name.trim().isNotEmpty && qty > 0;
}

/// Opens the review over everything else. Returns true when the user confirmed the item.
Future<bool> showItemReview(BuildContext context, ItemDraft draft) async {
  final ok = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ItemReviewScreen(draft: draft),
    ),
  );
  return ok ?? false;
}

class ItemReviewScreen extends StatefulWidget {
  const ItemReviewScreen({super.key, required this.draft});
  final ItemDraft draft;
  @override
  State<ItemReviewScreen> createState() => _ItemReviewScreenState();
}

class _ItemReviewScreenState extends State<ItemReviewScreen> {
  // One controller per field for the whole life of the screen. Creating a controller on every
  // rebuild is what used to throw the cursor to the end at each key typed in the middle of a name.
  late final _name = TextEditingController(text: widget.draft.name);
  late final _qty = TextEditingController(text: widget.draft.quantity);

  ItemDraft get d => widget.draft;

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  void _setQuantity(String v) {
    d.quantity = v;
    _qty.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final measured = units[d.unit]!.measured;
    final ok = d.complete;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            SheetHeader(
              title: d.lineId != null ? l.editItemTitle : l.confirmItem,
              leading: SButton(
                label: l.cancel,
                variant: SButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  0,
                  Spacing.md,
                  Spacing.md,
                ),
                children: [
                  for (final w in d.warnings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SIcon(SIconName.info, size: 16, color: c.warning),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              w,
                              style: Type.bodySmall.copyWith(color: c.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (d.confidence != null)
                    Text(
                      l.readingConfidence((d.confidence! * 100).round()),
                      style: Type.caption.copyWith(color: c.textMuted),
                    ),
                  const SizedBox(height: Spacing.sm),
                  STextField(
                    label: l.product,
                    controller: _name,
                    placeholder: l.productNameHint,
                    autofocus: d.name.isEmpty,
                    maxLength: 120,
                    onChanged: (v) => setState(() => d.name = v),
                  ),
                  const SizedBox(height: Spacing.sm),
                  MoneyField(
                    label: measured
                        ? l.pricePer(units[d.unit]!.label)
                        : l.unitPrice,
                    cents: d.unitPriceCents,
                    onChanged: (v) => setState(() {
                      if (d.priceSource == 'label_ocr' &&
                          v != d.unitPriceCents) {
                        d.priceSource = 'manual';
                      }
                      d.unitPriceCents = v;
                    }),
                  ),
                  if (d.promoFromCents != null)
                    Text(
                      l.previousTagPrice(formatBRL(d.promoFromCents!)),
                      style: Type.caption.copyWith(color: c.textMuted),
                    ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 120,
                        child: STextField(
                          label: measured
                              ? l.quantityUnit(units[d.unit]!.label)
                              : l.quantity,
                          controller: _qty,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) => setState(() => d.quantity = v),
                        ),
                      ),
                      if (!measured) ...[
                        const SizedBox(width: 8),
                        SButton(
                          label: '−',
                          variant: SButtonVariant.secondary,
                          compact: true,
                          onPressed: () => _setQuantity(
                            '${(d.qty.round() - 1).clamp(1, 999)}',
                          ),
                        ),
                        const SizedBox(width: 4),
                        SButton(
                          label: '+',
                          variant: SButtonVariant.secondary,
                          compact: true,
                          onPressed: () => _setQuantity('${d.qty.round() + 1}'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Field(
                    label: l.unit,
                    child: Segmented<String>(
                      options: const [
                        ('un', 'un'),
                        ('kg', 'kg'),
                        ('g', 'g'),
                        ('l', 'L'),
                        ('ml', 'mL'),
                      ],
                      value: const ['un', 'kg', 'g', 'l', 'ml'].contains(d.unit)
                          ? d.unit
                          : 'un',
                      onChanged: (u) => setState(() => d.unit = u),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Field(
                    label: l.promotion,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SChip(
                          label: l.none,
                          selected:
                              d.promo == null && d.discountPercent == null,
                          onTap: () => setState(() {
                            d.promo = null;
                            d.discountPercent = null;
                          }),
                        ),
                        SChip(
                          label: l.take3pay2,
                          selected: d.promo?.take == 3,
                          onTap: () => setState(() {
                            d.promo = const Promo(3, 2);
                            d.discountPercent = null;
                          }),
                        ),
                        SChip(
                          label: l.take2pay1,
                          selected: d.promo?.take == 2,
                          onTap: () => setState(() {
                            d.promo = const Promo(2, 1);
                            d.discountPercent = null;
                          }),
                        ),
                        SChip(
                          label: l.off10,
                          selected: d.discountPercent == 10,
                          onTap: () => setState(() {
                            d.discountPercent = 10;
                            d.promo = null;
                          }),
                        ),
                        SChip(
                          label: l.off20,
                          selected: d.discountPercent == 20,
                          onTap: () => setState(() {
                            d.discountPercent = 20;
                            d.promo = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Outside the scroll: with the keyboard open the screen shrinks and this stays in
            // sight, above the keyboard and above the system navigation bar.
            Container(
              decoration: BoxDecoration(
                color: c.bg,
                border: Border(top: BorderSide(color: c.border)),
              ),
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.xs,
                Spacing.md,
                Spacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (ok)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.xs),
                      child: Text(
                        l.subtotal(
                          formatBRL(
                            lineTotal(
                              CartLine(
                                id: 'x',
                                name: d.name,
                                unit: d.unit,
                                quantity: d.qty,
                                unitPriceCents: d.unitPriceCents!,
                                priceSource: d.priceSource,
                                checked: true,
                                promo: d.promo,
                                discountPercent: d.discountPercent,
                              ),
                            ).netCents,
                          ),
                        ),
                        style: Type.body.copyWith(color: c.text),
                      ),
                    ),
                  SButton(
                    label: d.lineId != null ? l.save : l.addToCart,
                    fullWidth: true,
                    onPressed: ok
                        ? () => Navigator.of(context).pop(true)
                        : null,
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
