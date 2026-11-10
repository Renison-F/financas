/// Review of one cart item before it enters the cart: what was read (or typed) is shown in fields
/// the user can correct, next to the photo it came from, and nothing is added until they confirm.
///
/// It is a screen of its own, over the session: the cart stays as it was underneath, the fields
/// scroll, and the actions stay above the keyboard and the system bars.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/theme/tokens.dart';
import '../../data/ocr/ocr_service.dart';
import '../../data/ocr/region_reader.dart';
import '../../domain/money/money.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';
import 'region_layer.dart';
import 'scan_screen.dart';

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
    this.notes = const [],
    this.lineId,
    this.listItemId,
    this.discountPercent,
    this.promo,
    this.promoFromCents,
    this.photo,
    this.page,
    this.analysis,
    this.advertisedPriceCents,
    this.wholesaleCents,
    this.wholesaleMinQuantity,
    this.chargedUnitPriceCents,
    this.fromScanner = false,
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

  /// Things to check before confirming.
  List<String> warnings;

  /// Plain information about where the data came from (not a problem).
  List<String> notes;
  String? lineId;
  String? listItemId;
  double? discountPercent;
  Promo? promo;
  int? promoFromCents;

  /// The photo of the shelf label, as taken, and what was read on it.
  Uint8List? photo;
  OcrPage? page;
  LabelAnalysis? analysis;

  /// The price as read on the label, before any correction.
  int? advertisedPriceCents;
  int? wholesaleCents;
  int? wholesaleMinQuantity;

  /// Price on the receipt, once compared; carried through an edit untouched.
  int? chargedUnitPriceCents;

  /// A picture of the product itself, taken on this screen.
  Uint8List? productPhoto;

  /// The item came from the scanner, so "add and read the next" makes sense.
  bool fromScanner;

  /// The user looked at a price flagged for review and stood by it (or replaced it).
  bool priceChecked = false;

  double get qty => double.tryParse(quantity.replaceAll(',', '.')) ?? 0;
  bool get needsPriceCheck =>
      priceSource == 'label_ocr' &&
      (analysis?.needsReview ?? false) &&
      !priceChecked;
  bool get complete =>
      unitPriceCents != null && name.trim().isNotEmpty && qty > 0;
}

enum ReviewOutcome { cancel, add, addAndScanNext }

/// Opens the review over everything else and says what the user decided.
Future<ReviewOutcome> showItemReview(
  BuildContext context,
  ItemDraft draft,
) async {
  final r = await Navigator.of(context, rootNavigator: true)
      .push<ReviewOutcome>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ItemReviewScreen(draft: draft),
        ),
      );
  return r ?? ReviewOutcome.cancel;
}

class ItemReviewScreen extends ConsumerStatefulWidget {
  const ItemReviewScreen({super.key, required this.draft});
  final ItemDraft draft;
  @override
  ConsumerState<ItemReviewScreen> createState() => _ItemReviewScreenState();
}

/// Amounts written in a piece of text read from a label ("9,99", "R$ 16.99", "4 , 99").
List<int> pricesIn(String text) => [
  for (final m in RegExp(
    r'(\d{1,4})\s*[,.]\s*[,.]?\s*(\d{2})(?!\d)',
  ).allMatches(text))
    int.parse(m[1]!) * 100 + int.parse(m[2]!),
];

class _ItemReviewScreenState extends ConsumerState<ItemReviewScreen> {
  // One controller per field for the whole life of the screen. Creating a controller on every
  // rebuild is what used to throw the cursor to the end at each key typed in the middle of a name.
  late final _name = TextEditingController(text: widget.draft.name);
  late final _qty = TextEditingController(text: widget.draft.quantity);

  /// What a tap on the photo fills in.
  String _pick = 'name';
  final List<int> _nameLines = [];
  int? _priceLine;
  String? _pickMessage;

  /// Marking a region of the photo to be read again: on or off, the region (fractions of the
  /// photo), whether a reading is running and the amounts found when there was more than one.
  bool _marking = false;
  Rect? _region;
  bool _readingRegion = false;
  List<int> _regionPrices = const [];

  ItemDraft get d => widget.draft;

  @override
  void initState() {
    super.initState();
    final a = d.analysis;
    if (a != null) {
      _nameLines.addAll(a.name?.lines ?? const []);
      _priceLine = a.price?.line;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  void _setName(String v) {
    d.name = v;
    _name.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
  }

  void _setQuantity(String v) {
    d.quantity = v;
    _qty.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
    setState(() {});
  }

  void _setPrice(int cents, {int? line}) => setState(() {
    d.unitPriceCents = cents;
    d.priceChecked = true;
    _priceLine = line;
    _pickMessage = null;
  });

  /// A tap on a line of the photo: in "name" mode the line becomes (or joins) the description; in
  /// "price" mode the amount written on it becomes the price.
  void _tapLine(int i) {
    final page = d.page;
    if (page == null) return;
    final l = context.l10n;
    final line = page.lines[i];
    if (_pick == 'name') {
      setState(() {
        if (_nameLines.contains(i)) {
          _nameLines.remove(i);
        } else {
          _nameLines.add(i);
        }
        _nameLines.sort((a, b) {
          final ya = page.lines[a].top, yb = page.lines[b].top;
          return (ya - yb).abs() > page.lines[a].height * 0.5
              ? ya.compareTo(yb)
              : page.lines[a].left.compareTo(page.lines[b].left);
        });
        _setName(_nameLines.map((x) => page.lines[x].text.trim()).join(' '));
        _pickMessage = null;
      });
      return;
    }
    final found = pricesIn(line.text);
    if (found.isEmpty) {
      setState(() => _pickMessage = l.reviewNoPriceInLine);
      return;
    }
    _setPrice(found.first, line: i);
  }

  /// Reads again only the region the user marked. In "name" mode what is read becomes the
  /// description; in "price" mode the amount found becomes the price, and when there is more than
  /// one the user chooses. Nothing is filled in when nothing was read.
  Future<void> _readRegion() async {
    final region = _region, photo = d.photo;
    if (region == null || photo == null || _readingRegion) return;
    final l = context.l10n;
    setState(() {
      _readingRegion = true;
      _pickMessage = null;
      _regionPrices = const [];
    });
    try {
      final lines = await ref.read(regionReaderProvider).read(photo, region);
      if (!mounted) return;
      final text = lines.map((x) => x.text.trim()).where((x) => x.isNotEmpty);
      if (text.isEmpty) {
        setState(() => _pickMessage = l.regionNothingRead);
      } else if (_pick == 'name') {
        setState(() {
          _nameLines.clear();
          _setName(text.join(' '));
          _marking = false;
        });
      } else {
        final found = pricesIn(text.join('  ')).toSet().toList();
        if (found.isEmpty) {
          setState(() => _pickMessage = l.regionNoPrice(text.join(' ')));
        } else if (found.length == 1) {
          _setPrice(found.single);
          setState(() => _marking = false);
        } else {
          setState(() {
            _regionPrices = found;
            _pickMessage = l.regionManyPrices;
          });
        }
      }
    } on OcrUnavailable {
      if (mounted) setState(() => _pickMessage = l.regionUnavailable);
    } catch (_) {
      if (mounted) setState(() => _pickMessage = l.regionFailed);
    } finally {
      if (mounted) setState(() => _readingRegion = false);
    }
  }

  Future<void> _addProductPhoto() async {
    final bytes = await capturePhoto(context);
    if (bytes == null || !mounted) return;
    setState(() => d.productPhoto = bytes);
  }

  String _priceLabel(AppLocalizations l, LabelPrice p) {
    final v = formatBRL(p.cents);
    return switch (p.role) {
      LabelPriceRole.retail => l.priceRetail(v),
      LabelPriceRole.wholesale =>
        p.minQuantity == null
            ? l.priceWholesaleNoMin(v)
            : l.priceWholesale(v, p.minQuantity!),
      LabelPriceRole.perMeasure =>
        p.unit == 'kg' ? l.pricePerKg(v) : l.pricePerLiter(v),
      LabelPriceRole.perUnitOfPack => l.pricePerPackUnit(v),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final measured = units[d.unit]!.measured;
    final a = d.analysis;
    final ok = d.complete && !d.needsPriceCheck;
    final wholesale = a?.wholesale;
    final otherNames = a == null
        ? const <LabelName>[]
        : a.names.where((n) => n.text != d.name).take(3).toList();
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
                onPressed: () =>
                    Navigator.of(context).pop(ReviewOutcome.cancel),
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
                  if (d.photo != null) ...[
                    _LabelPhoto(
                      photo: d.photo!,
                      page: d.page,
                      nameLines: _nameLines,
                      priceLine: _priceLine,
                      onTapLine: _tapLine,
                      marking: _marking,
                      region: _region,
                      onRegion: (r) => setState(() {
                        _region = r;
                        _regionPrices = const [];
                      }),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Field(
                      label: _marking ? l.regionDefines : l.reviewTapDefines,
                      help:
                          _pickMessage ??
                          (_marking ? l.regionHint : l.reviewPhotoHint),
                      child: Segmented<String>(
                        options: [
                          ('name', l.reviewPickName),
                          ('price', l.reviewPickPrice),
                        ],
                        value: _pick,
                        onChanged: (v) => setState(() {
                          _pick = v;
                          _pickMessage = null;
                          _regionPrices = const [];
                        }),
                      ),
                    ),
                    if (_regionPrices.isNotEmpty) ...[
                      const SizedBox(height: Spacing.xs),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final cents in _regionPrices)
                            SChip(
                              label: formatBRL(cents),
                              onTap: () {
                                _setPrice(cents);
                                setState(() {
                                  _regionPrices = const [];
                                  _marking = false;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: Spacing.xs),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (!_marking)
                          SButton(
                            label: l.regionStart,
                            icon: SIconName.edit,
                            variant: SButtonVariant.secondary,
                            compact: true,
                            onPressed: () => setState(() {
                              _marking = true;
                              _pickMessage = null;
                            }),
                          )
                        else ...[
                          SButton(
                            label: _readingRegion
                                ? l.regionReading
                                : l.regionRead,
                            icon: SIconName.search,
                            compact: true,
                            onPressed: _region == null || _readingRegion
                                ? null
                                : _readRegion,
                          ),
                          SButton(
                            label: l.regionStop,
                            variant: SButtonVariant.ghost,
                            compact: true,
                            onPressed: () => setState(() {
                              _marking = false;
                              _region = null;
                              _regionPrices = const [];
                              _pickMessage = null;
                            }),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                  ],
                  for (final w in [...d.warnings, ...?a?.reviewReasons])
                    _Note(text: w, color: c.warning, icon: SIconName.alert),
                  for (final n in d.notes)
                    _Note(text: n, color: c.textMuted, icon: SIconName.info),
                  const SizedBox(height: Spacing.xs),
                  STextField(
                    label: l.product,
                    controller: _name,
                    placeholder: l.productNameHint,
                    autofocus: d.name.isEmpty && d.photo == null,
                    maxLength: 120,
                    onChanged: (v) => setState(() => d.name = v),
                  ),
                  if (otherNames.isNotEmpty) ...[
                    const SizedBox(height: Spacing.xs),
                    Field(
                      label: l.reviewOtherNames,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final n in otherNames)
                            SChip(
                              label: n.text,
                              onTap: () => setState(() {
                                _nameLines
                                  ..clear()
                                  ..addAll(n.lines);
                                _setName(n.text);
                              }),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.sm),
                  MoneyField(
                    label: measured
                        ? l.pricePer(units[d.unit]!.label)
                        : l.unitPrice,
                    cents: d.unitPriceCents,
                    onChanged: (v) => setState(() {
                      if (v != d.unitPriceCents) {
                        if (d.priceSource == 'label_ocr') {
                          d.priceSource = 'manual';
                        }
                        d.priceChecked = true;
                        _priceLine = null;
                      }
                      d.unitPriceCents = v;
                    }),
                  ),
                  if (a != null && a.prices.isNotEmpty) ...[
                    const SizedBox(height: Spacing.xs),
                    Field(
                      label: l.reviewPrices,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final p in a.prices.where(
                                (p) => p.role == LabelPriceRole.retail,
                              ))
                                SChip(
                                  label: _priceLabel(l, p),
                                  selected:
                                      d.unitPriceCents == p.cents &&
                                      d.priceChecked,
                                  onTap: () => _setPrice(p.cents, line: p.line),
                                ),
                            ],
                          ),
                          // Comparison print is shown for what it is and cannot be picked by
                          // accident as the price of the item.
                          for (final p in a.prices.where(
                            (p) =>
                                p.role == LabelPriceRole.perMeasure ||
                                p.role == LabelPriceRole.perUnitOfPack,
                          ))
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _priceLabel(l, p),
                                style: Type.caption.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (wholesale != null)
                    ToggleRow(
                      label: _priceLabel(l, wholesale),
                      value: d.wholesaleCents != null,
                      help: wholesale.minQuantity == null
                          ? l.wholesaleNoMinHelp
                          : l.wholesaleHelp(wholesale.minQuantity!),
                      onChanged: wholesale.minQuantity == null
                          ? (_) {}
                          : (v) => setState(() {
                              d.wholesaleCents = v ? wholesale.cents : null;
                              d.wholesaleMinQuantity = v
                                  ? wholesale.minQuantity
                                  : null;
                            }),
                    ),
                  if (d.promoFromCents != null)
                    Text(
                      l.previousTagPrice(formatBRL(d.promoFromCents!)),
                      style: Type.caption.copyWith(color: c.textMuted),
                    ),
                  if (d.priceSource == 'label_ocr' && (a?.needsReview ?? false))
                    ToggleRow(
                      label: l.reviewConfirmPrice,
                      value: d.priceChecked,
                      help: l.reviewConfirmPriceHelp,
                      onChanged: (v) => setState(() => d.priceChecked = v),
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
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      if (d.productPhoto != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Radii.xs),
                          child: Image.memory(
                            d.productPhoto!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            semanticLabel: l.evidenceProduct,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                      ],
                      Expanded(
                        child: SButton(
                          label: d.productPhoto == null
                              ? l.addProductPhoto
                              : l.replaceProductPhoto,
                          icon: SIconName.camera,
                          variant: SButtonVariant.secondary,
                          compact: true,
                          onPressed: _addProductPhoto,
                        ),
                      ),
                    ],
                  ),
                  if (d.photo != null || d.productPhoto != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        l.evidenceNote,
                        style: Type.caption.copyWith(color: c.textMuted),
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
                  if (d.complete)
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
                                wholesalePriceCents: d.wholesaleCents,
                                wholesaleMinQuantity: d.wholesaleMinQuantity,
                              ),
                            ).netCents,
                          ),
                        ),
                        style: Type.body.copyWith(color: c.text),
                      ),
                    ),
                  if (d.complete && d.needsPriceCheck)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.xs),
                      child: Text(
                        l.reviewNeedsCheck,
                        style: Type.bodySmall.copyWith(color: c.warning),
                      ),
                    ),
                  SButton(
                    label: d.lineId != null ? l.save : l.addToCart,
                    fullWidth: true,
                    onPressed: ok
                        ? () => Navigator.of(context).pop(ReviewOutcome.add)
                        : null,
                  ),
                  if (d.fromScanner && d.lineId == null) ...[
                    const SizedBox(height: 4),
                    SButton(
                      label: l.addAndScanNext,
                      variant: SButtonVariant.ghost,
                      fullWidth: true,
                      compact: true,
                      onPressed: ok
                          ? () =>
                                Navigator.of(context)
                                    .pop(ReviewOutcome.addAndScanNext)
                          : null,
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

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.color, required this.icon});
  final String text;
  final Color color;
  final SIconName icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SIcon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: Type.bodySmall.copyWith(color: color)),
        ),
      ],
    ),
  );
}

/// The photo of the label with every line that was read marked on it. A tap on a line hands it to
/// the form; pinching zooms in on small print.
class _LabelPhoto extends StatelessWidget {
  const _LabelPhoto({
    required this.photo,
    required this.page,
    required this.nameLines,
    required this.priceLine,
    required this.onTapLine,
    required this.marking,
    required this.region,
    required this.onRegion,
  });
  final Uint8List photo;
  final OcrPage? page;
  final List<int> nameLines;
  final int? priceLine;
  final ValueChanged<int> onTapLine;

  /// While marking, dragging on the photo draws the region instead of moving the photo, and the
  /// lines already read are not tappable (two fingers still zoom).
  final bool marking;
  final Rect? region;
  final ValueChanged<Rect> onRegion;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final p = page;
    final aspect = p == null || p.height == 0 ? 4 / 3 : p.width / p.height;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.36;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: aspect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: InteractiveViewer(
              maxScale: 5,
              // While marking, the finger draws the region: the photo stays where it is. Zoom in
              // first if the print is small; the region is drawn on the enlarged photo.
              panEnabled: !marking,
              scaleEnabled: !marking,
              child: LayoutBuilder(
                builder: (context, box) {
                  final scale = p == null ? 1.0 : box.maxWidth / p.width;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.memory(
                          photo,
                          fit: BoxFit.fill,
                          gaplessPlayback: true,
                          semanticLabel: l.evidenceLabel,
                        ),
                      ),
                      if (marking)
                        Positioned.fill(
                          child: RegionLayer(
                            region: region,
                            onChanged: onRegion,
                            semanticLabel: l.regionLayer,
                          ),
                        ),
                      if (p != null && !marking)
                        for (var i = 0; i < p.lines.length; i++)
                          Positioned(
                            left: p.lines[i].left * scale - 3,
                            top: p.lines[i].top * scale - 3,
                            width: p.lines[i].width * scale + 6,
                            height: p.lines[i].height * scale + 6,
                            child: Semantics(
                              button: true,
                              label: p.lines[i].text,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onTapLine(i),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width:
                                          i == priceLine ||
                                              nameLines.contains(i)
                                          ? 2.5
                                          : 1,
                                      color: i == priceLine
                                          ? c.accent
                                          : nameLines.contains(i)
                                          ? c.primary
                                          : const Color(0x99FFFFFF),
                                    ),
                                    color: i == priceLine
                                        ? c.accent.withValues(alpha: 0.18)
                                        : nameLines.contains(i)
                                        ? c.primary.withValues(alpha: 0.18)
                                        : null,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
