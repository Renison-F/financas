import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// One slice of a [DonutChart]: its share is what is drawn; label and value are what is read.
class DonutSlice {
  const DonutSlice({
    required this.label,
    required this.value,
    required this.share,
    required this.color,
    this.detail,
  });
  final String label;

  /// The amount, already formatted (or hidden) by the caller.
  final String value;

  /// "97,8%".
  final String share;
  final Color color;

  /// Fraction of the ring, 0..1, taken from [share] by the caller.
  double get fraction => _fraction;
  static double _parse(String s) =>
      (double.tryParse(s.replaceAll('%', '').replaceAll(',', '.')) ?? 0) / 100;
  double get _fraction => _parse(share);
  final String? detail;
}

/// A ring chart with its legend. The same component is used on the home screen (compact) and in
/// the category report (with tap to highlight), fed by the same query, so the two never disagree.
/// Colour is never the only code: every slice is also a row of text with name, share and value.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    required this.centerLabel,
    required this.centerValue,
    this.diameter = 132,
    this.selected,
    this.onSelect,
    this.compact = false,
    this.semanticLabel,
  });
  final List<DonutSlice> slices;
  final String centerLabel, centerValue;
  final double diameter;
  final int? selected;
  final ValueChanged<int?>? onSelect;

  /// Legend beside the ring (home) instead of below it (report).
  final bool compact;
  final String? semanticLabel;

  int? _hit(Offset p, double diameter) {
    final c = Offset(diameter / 2, diameter / 2);
    final d = p - c;
    final r = d.distance;
    if (r < diameter * 0.26 || r > diameter / 2 + 6) return null;
    var angle = math.atan2(d.dy, d.dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    var acc = 0.0;
    for (var i = 0; i < slices.length; i++) {
      acc += slices[i].fraction * 2 * math.pi;
      if (angle <= acc) return i;
    }
    return slices.isEmpty ? null : slices.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // "Compact charts" in the appearance settings: a smaller ring; the legend keeps every row,
    // because the text is what says the numbers.
    final diameter = context.look.compactCharts
        ? (this.diameter * 0.74).roundToDouble()
        : this.diameter;
    final ring = Semantics(
      image: true,
      label:
          semanticLabel ??
          slices.map((s) => '${s.label} ${s.share}').join(', '),
      child: GestureDetector(
        onTapUp: onSelect == null
            ? null
            : (d) {
                final i = _hit(d.localPosition, diameter);
                onSelect!(i == selected ? null : i);
              },
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: CustomPaint(
            painter: _DonutPainter(
              slices: slices,
              selected: selected,
              track: c.surfaceInset,
              gap: c.surface,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(diameter * 0.2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerLabel,
                        style: Type.caption.copyWith(color: c.textMuted),
                      ),
                      Text(
                        centerValue,
                        style: Type.rowTitle.copyWith(
                          color: c.text,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final legend = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < slices.length; i++)
          _LegendRow(
            slice: slices[i],
            selected: i == selected,
            dense: compact,
            onTap: onSelect == null
                ? null
                : () => onSelect!(i == selected ? null : i),
          ),
      ],
    );
    if (compact) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ring,
          const SizedBox(width: Spacing.md),
          Expanded(child: legend),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: ring),
        const SizedBox(height: Spacing.sm),
        legend,
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.selected,
    required this.dense,
    this.onTap,
  });
  final DonutSlice slice;
  final bool selected, dense;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 3 : 6, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: slice.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              slice.detail == null || dense
                  ? slice.label
                  : '${slice.label} · ${slice.detail}',
              style: Type.rowText.copyWith(
                color: c.text,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            dense ? slice.share : '${slice.share} · ${slice.value}',
            style: Type.rowText.copyWith(
              color: selected ? c.text : c.textMuted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return MergeSemantics(child: row);
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.xs),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Touch.min),
          child: Align(alignment: Alignment.centerLeft, child: row),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.slices,
    required this.selected,
    required this.track,
    required this.gap,
  });
  final List<DonutSlice> slices;
  final int? selected;
  final Color track, gap;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.16;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - stroke / 2 - 3,
    );
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    var start = -math.pi / 2;
    for (var i = 0; i < slices.length; i++) {
      final sweep = slices[i].fraction * 2 * math.pi;
      if (sweep <= 0) continue;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == selected ? stroke + 6 : stroke
          ..color = selected == null || i == selected
              ? slices[i].color
              : slices[i].color.withValues(alpha: 0.35),
      );
      start += sweep;
    }
    // Thin separators so neighbouring slices of similar colour still read as two.
    if (slices.where((s) => s.fraction > 0).length > 1) {
      start = -math.pi / 2;
      final sep = Paint()
        ..color = gap
        ..strokeWidth = 2;
      final c = size.center(Offset.zero);
      final inner = rect.width / 2 - stroke / 2 - 3,
          outer = rect.width / 2 + stroke / 2 + 3;
      for (final s in slices) {
        if (s.fraction <= 0) continue;
        canvas.drawLine(
          c + Offset(math.cos(start), math.sin(start)) * inner,
          c + Offset(math.cos(start), math.sin(start)) * outer,
          sep,
        );
        start += s.fraction * 2 * math.pi;
      }
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.slices != slices || old.selected != selected;
}
