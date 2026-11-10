/// Evidence of a purchase and the comparison with the store receipt.
///
/// [EvidenceScreen] lists the photos kept for a purchase (shelf labels, products, the receipt).
/// [ReceiptScreen] reads a photo of the receipt, pairs its lines with the cart and shows, item by
/// item, the price announced on the shelf next to the price charged. A difference is only stated
/// for a solid pair; a doubtful pair is shown as a suspicion for the user to settle.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../data/ocr/ocr_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/money/money.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';
import 'scan_screen.dart';

String _roleLabel(AppLocalizations l, String role) => switch (role) {
  'label' => l.evidenceLabel,
  'product' => l.evidenceProduct,
  'receipt' => l.evidenceReceipt,
  _ => l.evidenceTitle,
};

/// A photo from the encrypted database, loaded when it comes on screen.
class EvidenceImage extends ConsumerWidget {
  const EvidenceImage({
    super.key,
    required this.id,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });
  final String id;
  final BoxFit fit;
  final String? semanticLabel;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<Uint8List?>(
        future: ref.read(appControllerProvider.notifier).evidenceBytes(id),
        builder: (context, snap) {
          final bytes = snap.data;
          if (bytes == null) {
            return ColoredBox(
              color: context.colors.surfaceInset,
              child: const SizedBox.expand(),
            );
          }
          return Image.memory(
            bytes,
            fit: fit,
            gaplessPlayback: true,
            semanticLabel: semanticLabel,
          );
        },
      );
}

/// One photo, full screen, with pinch to zoom.
Future<void> showEvidence(BuildContext context, Evidence e, String title) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          backgroundColor: const Color(0xFF000000),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    maxScale: 6,
                    child: EvidenceImage(id: e.id, semanticLabel: title),
                  ),
                ),
                Positioned(
                  left: Spacing.sm,
                  top: Spacing.sm,
                  child: Material(
                    color: const Color(0x80000000),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: ctx.l10n.close,
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const SIcon(
                        SIconName.close,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

class EvidenceScreen extends ConsumerStatefulWidget {
  const EvidenceScreen({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends ConsumerState<EvidenceScreen> {
  late Future<List<Evidence>> _items = _load();
  Future<List<Evidence>> _load() =>
      ref.read(appControllerProvider.notifier).evidenceOf(widget.sessionId);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final session = ref
        .watch(appControllerProvider)
        .requireValue
        .sessions
        .where((s) => s.id == widget.sessionId)
        .firstOrNull;
    final lines = {
      for (final x in session?.lines ?? const <CartLine>[]) x.id: x,
    };
    return StackScreen(
      title: l.evidenceTitle,
      children: [
        Text(
          l.evidenceNote,
          style: Type.bodySmall.copyWith(color: c.textMuted),
        ),
        FutureBuilder<List<Evidence>>(
          future: _items,
          builder: (context, snap) {
            final items = snap.data ?? const <Evidence>[];
            if (snap.connectionState != ConnectionState.done) {
              return const SizedBox(height: 80);
            }
            if (items.isEmpty) {
              return SCard(
                child: EmptyState(
                  icon: SIconName.camera,
                  title: l.evidenceEmpty,
                  text: l.evidenceEmptyText,
                ),
              );
            }
            return Column(
              children: [
                for (final e in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: SCard(
                      padding: const EdgeInsets.all(Spacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            button: true,
                            label: l.evidenceOpen,
                            child: InkWell(
                              onTap: () => showEvidence(
                                context,
                                e,
                                lines[e.lineId]?.name ?? _roleLabel(l, e.role),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Radii.xs),
                                child: SizedBox(
                                  width: 84,
                                  height: 84,
                                  child: EvidenceImage(
                                    id: e.id,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lines[e.lineId]?.name ??
                                      _roleLabel(l, e.role),
                                  style: Type.rowTitle.copyWith(color: c.text),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_roleLabel(l, e.role)} · ${l.evidenceTakenAt(_stamp(e.capturedAt))}',
                                  style: Type.rowMeta.copyWith(
                                    color: c.textMuted,
                                  ),
                                ),
                                if (lines[e.lineId] != null &&
                                    e.role == 'label' &&
                                    lines[e.lineId]!.advertisedPriceCents !=
                                        null)
                                  Text(
                                    l.evidenceReadVsConfirmed(
                                      formatBRL(
                                        lines[e.lineId]!.advertisedPriceCents!,
                                      ),
                                      formatBRL(
                                        lines[e.lineId]!.unitPriceCents,
                                      ),
                                    ),
                                    style: Type.rowMeta.copyWith(color: c.text),
                                  ),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: SButton(
                                    label: l.evidenceDelete,
                                    variant: SButtonVariant.ghost,
                                    compact: true,
                                    onPressed: () async {
                                      final ok = await confirmSheet(
                                        context,
                                        title: l.evidenceDeleteQ,
                                        text: l.evidenceDeleteText,
                                        confirmLabel: l.delete,
                                        cancelLabel: l.cancel,
                                      );
                                      if (!ok) return;
                                      await ref
                                          .read(appControllerProvider.notifier)
                                          .deleteEvidence(e.id);
                                      if (mounted) {
                                        setState(() => _items = _load());
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _stamp(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return iso;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  List<ReceiptLine>? _lines;
  List<Evidence> _evidence = const [];
  List<String> _warnings = const [];
  bool _busy = false;
  String? _error;

  AppController get _ctl => ref.read(appControllerProvider.notifier);
  ShoppingSession? get _session => ref
      .read(appControllerProvider)
      .requireValue
      .sessions
      .where((s) => s.id == widget.sessionId)
      .firstOrNull;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final lines = await _ctl.receiptLines(widget.sessionId);
    final ev = await _ctl.evidenceOf(widget.sessionId);
    if (!mounted) return;
    setState(() {
      _lines = lines;
      _evidence = ev;
    });
  }

  /// The expense registered for this purchase next to what the receipt adds up to, and the way to
  /// bring the first to the second. Nothing changes without the user asking and confirming.
  Widget _expenseCard(Reconciliation rec) {
    final l = context.l10n;
    final c = context.colors;
    final hidden = ref.watch(privacyHiddenProvider);
    final session = _session;
    final ledger = ref.watch(ledgerProvider);
    final tx = session?.transactionId == null
        ? null
        : ledger.transactionById(session!.transactionId!);
    final receiptTotal = sumCents(rec.lines.map((r) => r.totalCents));
    if (rec.lines.isEmpty) return const SizedBox.shrink();
    String brl(int v) => formatBRL(v, hidden: hidden);
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Type.rowText.copyWith(color: c.text)),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Type.rowText.copyWith(
              color: c.text,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
    return SCard(
      padding: const EdgeInsets.all(Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.receiptExpenseTitle,
            style: Type.rowTitle.copyWith(color: c.text),
          ),
          const SizedBox(height: 4),
          row(l.receiptItemsTotal, brl(receiptTotal)),
          if (tx == null || tx.deletedAt != null)
            Text(
              l.receiptNoExpense,
              style: Type.caption.copyWith(color: c.textMuted),
            )
          else ...[
            row(l.receiptExpenseRegistered, brl(tx.amountCents)),
            if (tx.amountCents == receiptTotal)
              Text(
                l.receiptExpenseSame,
                style: Type.caption.copyWith(color: c.textMuted),
              )
            else if (!AppController.canAdjustFromReceipt(tx))
              Text(
                l.receiptExpenseLocked,
                style: Type.caption.copyWith(color: c.textMuted),
              )
            else ...[
              Text(
                l.receiptExpenseDiffers,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SButton(
                  label: l.receiptAdjust,
                  variant: SButtonVariant.secondary,
                  compact: true,
                  onPressed: () => _adjustExpense(tx, receiptTotal),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _adjustExpense(Transaction tx, int receiptTotal) async {
    final l = context.l10n;
    final amount = await showSSheet<int>(
      context,
      useRootNavigator: true,
      builder: (sheet) {
        int? value = receiptTotal;
        return StatefulBuilder(
          builder: (context, setSheet) => Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              0,
              Spacing.md,
              Spacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l.receiptAdjust,
                    style: Type.title.copyWith(color: context.colors.text),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  l.receiptAdjustText(formatBRL(tx.amountCents)),
                  style: Type.bodySmall.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                MoneyField(
                  label: l.receiptAdjustField,
                  cents: value,
                  onChanged: (v) => setSheet(() => value = v),
                ),
                const SizedBox(height: Spacing.sm),
                SButton(
                  label: l.receiptAdjustConfirm,
                  fullWidth: true,
                  onPressed: (value ?? 0) <= 0 || value == tx.amountCents
                      ? null
                      : () => Navigator.of(sheet).pop(value),
                ),
                SButton(
                  label: l.cancel,
                  variant: SButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: () => Navigator.of(sheet).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (amount == null || !mounted) return;
    final ok = await _ctl.adjustAmountFromReceipt(
      tx.id,
      amount,
      note: l.receiptAdjustNote(
        fmtDateBR(ref.read(todayProvider)),
        formatBRL(tx.amountCents),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l.receiptAdjusted(formatBRL(amount)) : l.receiptExpenseLocked,
        ),
      ),
    );
    setState(() {});
  }

  /// Stores the pairing and records, on each cart line with a settled pair, the price charged.
  /// The price the user confirmed at the shelf is never overwritten.
  Future<void> _store(List<ReceiptLine> lines) async {
    final session = _session;
    if (session == null) return;
    final rec = reconcile(session.lines, lines);
    await _ctl.saveReceiptLines(session.id, rec.lines);
    final charged = <String, int>{
      for (final r in rec.lines)
        if (r.matchedLineId != null &&
            r.matchStatus != ReceiptMatch.suspected &&
            r.matchStatus != ReceiptMatch.unmatched)
          r.matchedLineId!: r.effectiveUnitCents,
    };
    final updated = ShoppingSession(
      id: session.id,
      store: session.store,
      listId: session.listId,
      budgetCents: session.budgetCents,
      lines: [
        for (final c in session.lines)
          charged.containsKey(c.id)
              ? c.copyWith(chargedUnitPriceCents: charged[c.id])
              : c.copyWith(clearCharged: true),
      ],
      status: session.status,
      startedAt: session.startedAt,
      finishedAt: session.finishedAt,
      transactionId: session.transactionId,
      receiptAccessKey: session.receiptAccessKey,
      events: session.events,
    );
    await _ctl.saveSession(updated);
    if (mounted) setState(() => _lines = rec.lines);
  }

  Future<void> _read(Uint8List bytes) async {
    final l = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    File? tmp;
    try {
      final dir = await getTemporaryDirectory();
      tmp = File(
        '${dir.path}/cupom-${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await tmp.writeAsBytes(bytes, flush: true);
      final page = await ref.read(ocrServiceProvider).read(tmp.path);
      final reading = parseReceipt(receiptRows(page.lines), newId: _ctl.newId);
      await _ctl.saveEvidence(
        sessionId: widget.sessionId,
        role: 'receipt',
        bytes: bytes,
        width: page.width,
        height: page.height,
        ocr: page.lines,
      );
      _warnings = reading.warnings;
      await _store(reading.lines);
      await _reload();
    } on OcrUnavailable {
      setState(() => _error = l.ocrUnavailable);
    } catch (_) {
      setState(() => _error = l.readFailed);
    } finally {
      try {
        await tmp?.delete();
      } catch (_) {}
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fromCamera() async {
    final bytes = await capturePhoto(context);
    if (bytes != null && mounted) await _read(bytes);
  }

  Future<void> _fromGallery() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2400,
      imageQuality: 90,
    );
    if (x == null || !mounted) return;
    final bytes = await x.readAsBytes();
    // The picker leaves a copy in the app cache; the photo that matters goes to the database.
    try {
      await File(x.path).delete();
    } catch (_) {}
    if (mounted) await _read(bytes);
  }

  Future<void> _repair(ReceiptLine line) async {
    final session = _session;
    final lines = _lines;
    if (session == null || lines == null) return;
    final l = context.l10n;
    final c = context.colors;
    final taken = {
      for (final r in lines)
        if (r.id != line.id && r.matchedLineId != null) r.matchedLineId!,
    };
    final pick = await showSSheet<String>(
      context,
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          0,
          Spacing.md,
          Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.receiptPairTitle,
              style: Type.headline.copyWith(color: c.text, fontSize: 18),
            ),
            Text(
              line.rawText,
              style: Type.bodySmall.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Spacing.xs),
            ...dividedRows([
              for (final x in session.lines.where((x) => !taken.contains(x.id)))
                ListRow(
                  icon: SIconName.cart,
                  title: x.name,
                  titleMaxLines: 2,
                  description:
                      '${formatQuantity(x.quantity, x.unit)} × ${formatBRL(announcedUnitCents(x))}',
                  trailing: x.id == line.matchedLineId
                      ? SIcon(SIconName.check, size: 20, color: c.primary)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(x.id),
                ),
              ListRow(
                icon: SIconName.close,
                title: l.receiptNoPair,
                onTap: () => Navigator.of(ctx).pop(''),
              ),
            ]),
          ],
        ),
      ),
    );
    if (pick == null) return;
    await _store([
      for (final r in lines)
        if (r.id != line.id)
          r
        else if (pick.isEmpty)
          r.copyWith(clearMatch: true, matchStatus: ReceiptMatch.unmatched)
        else
          r.copyWith(
            matchedLineId: pick,
            matchStatus: ReceiptMatch.confirmed,
            matchScore: 1,
          ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final session = s.sessions
        .where((x) => x.id == widget.sessionId)
        .firstOrNull;
    final lines = _lines;
    final cart = {
      for (final x in session?.lines ?? const <CartLine>[]) x.id: x,
    };
    final rec = session == null || lines == null
        ? null
        : reconcile(session.lines, lines);
    final receiptPhoto = _evidence.where((e) => e.role == 'receipt').lastOrNull;
    return StackScreen(
      title: l.receiptTitle,
      children: [
        Text(
          l.receiptIntro,
          style: Type.bodySmall.copyWith(color: c.textMuted),
        ),
        Row(
          children: [
            Expanded(
              child: SButton(
                label: l.receiptPhoto,
                icon: SIconName.camera,
                compact: true,
                fullWidth: true,
                loading: _busy,
                onPressed: _busy ? null : _fromCamera,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SButton(
                label: l.receiptGallery,
                icon: SIconName.upload,
                variant: SButtonVariant.secondary,
                compact: true,
                fullWidth: true,
                onPressed: _busy ? null : _fromGallery,
              ),
            ),
          ],
        ),
        if (_error != null)
          Text(_error!, style: Type.bodySmall.copyWith(color: c.negative)),
        for (final w in _warnings)
          Text(w, style: Type.bodySmall.copyWith(color: c.warning)),
        if (rec != null && lines!.isNotEmpty) ...[
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.receiptSummary),
                Text(
                  l.receiptAnnouncedCharged(
                    formatBRL(rec.announcedCents),
                    formatBRL(rec.chargedCents),
                  ),
                  style: Type.body.copyWith(color: c.text),
                ),
                const SizedBox(height: 2),
                Text(
                  rec.differenceCents == 0
                      ? l.receiptNoDifference
                      : rec.differenceCents > 0
                      ? l.receiptChargedMore(formatBRL(rec.differenceCents))
                      : l.receiptChargedLess(formatBRL(-rec.differenceCents)),
                  style: Type.sectionValue.copyWith(
                    color: rec.differenceCents > 0 ? c.negative : c.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.receiptSummaryNote,
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
                if (receiptPhoto != null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SButton(
                      label: l.receiptSeePhoto,
                      variant: SButtonVariant.ghost,
                      compact: true,
                      onPressed: () => showEvidence(
                        context,
                        receiptPhoto,
                        l.evidenceReceipt,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _expenseCard(rec),
          for (final r in rec.lines)
            Builder(
              builder: (context) {
                final paired = cart[r.matchedLineId];
                final diff = paired == null
                    ? 0
                    : r.effectiveUnitCents - announcedUnitCents(paired);
                final (label, color) = switch (r.matchStatus) {
                  ReceiptMatch.equal => (l.receiptEqual, c.positive),
                  ReceiptMatch.divergent => (
                    diff > 0
                        ? l.receiptDiffMore(formatBRL(diff))
                        : l.receiptDiffLess(formatBRL(-diff)),
                    c.negative,
                  ),
                  ReceiptMatch.suspected => (l.receiptSuspected, c.warning),
                  ReceiptMatch.confirmed => (
                    diff == 0
                        ? l.receiptEqual
                        : diff > 0
                        ? l.receiptDiffMore(formatBRL(diff))
                        : l.receiptDiffLess(formatBRL(-diff)),
                    diff == 0 ? c.positive : c.negative,
                  ),
                  _ => (l.receiptUnmatched, c.textMuted),
                };
                final labelPhoto = _evidence
                    .where((e) => e.role == 'label' && e.lineId == paired?.id)
                    .firstOrNull;
                return SCard(
                  padding: const EdgeInsets.all(Spacing.sm),
                  onTap: () => _repair(r),
                  semanticHint: l.receiptPairTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              r.description,
                              style: Type.rowTitle.copyWith(color: c.text),
                            ),
                          ),
                          Money(
                            r.totalCents,
                            role: MoneyRole.dense,
                            hidden: ref.watch(privacyHiddenProvider),
                          ),
                        ],
                      ),
                      Text(
                        '${formatQuantity(r.quantity, r.unit)} × ${formatBRL(r.effectiveUnitCents)}',
                        style: Type.rowMeta.copyWith(color: c.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(label, style: Type.label.copyWith(color: color)),
                      if (paired != null)
                        Text(
                          l.receiptShelfVsTill(
                            paired.name,
                            formatBRL(announcedUnitCents(paired)),
                            formatBRL(r.effectiveUnitCents),
                          ),
                          style: Type.rowMeta.copyWith(color: c.text),
                        ),
                      if (r.matchStatus == ReceiptMatch.suspected)
                        Text(
                          l.receiptSuspectedHelp,
                          style: Type.caption.copyWith(color: c.textMuted),
                        ),
                      if (labelPhoto != null && diff != 0)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SButton(
                            label: l.receiptSeeShelfPhoto,
                            variant: SButtonVariant.ghost,
                            compact: true,
                            onPressed: () => showEvidence(
                              context,
                              labelPhoto,
                              paired?.name ?? l.evidenceLabel,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          if (rec.notOnReceipt.isNotEmpty)
            SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHeader(title: l.receiptMissing),
                  for (final x in rec.notOnReceipt)
                    Text(
                      '${x.name} · ${formatQuantity(x.quantity, x.unit)} × ${formatBRL(announcedUnitCents(x))}',
                      style: Type.bodySmall.copyWith(color: c.text),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    l.receiptMissingHelp,
                    style: Type.caption.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
