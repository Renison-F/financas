import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../domain/budgets/budgets.dart';

/// "Barra de ritmo": track + fill + "marca de hoje" (a small wave over a thin line), DESIGN.md's signature component.
class RhythmBar extends StatelessWidget {
  const RhythmBar({
    super.key,
    required this.percent,
    this.expectedPercent,
    this.state,
    this.label,
    this.overLabel,
  });
  final double percent;
  final double? expectedPercent;
  final PaceStatus? state;
  final String? label;
  final String Function(int overPercent)? overLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = percent.clamp(0, 100).toDouble();
    final over = percent > 100;
    final fill = state == PaceStatus.agitado || over
        ? c.negative
        : state == PaceStatus.atencao
        ? c.warning
        : c.primary;
    final expected = expectedPercent?.clamp(0, 100).toDouble();
    return Semantics(
      label: label ?? '${percent.round()}% do limite',
      value: '${pct.round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: expected != null ? 10 : 0),
            child: LayoutBuilder(
              builder: (context, box) => SizedBox(
                height: 12,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: c.surfaceInset,
                        borderRadius: BorderRadius.circular(Radii.xs),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Motion.base,
                      width: box.maxWidth * pct / 100,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(Radii.xs),
                      ),
                    ),
                    if (expected != null)
                      Positioned(
                        left: box.maxWidth * expected / 100 - 6,
                        top: -10,
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: const Size(12, 22),
                            painter: _TodayMarkPainter(c.accent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (over)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                overLabel?.call((percent - 100).round()) ??
                    '${(percent - 100).round()}% acima do limite',
                style: Type.caption.copyWith(color: c.negative),
              ),
            ),
        ],
      ),
    );
  }
}

class _TodayMarkPainter extends CustomPainter {
  _TodayMarkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round;
    final wave = Path()
      ..moveTo(1, 4)
      ..cubicTo(3, 1, 5, 1, 6, 4)
      ..cubicTo(7, 7, 9, 7, 11, 4);
    canvas.drawPath(wave, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5, 6, 2, 16),
        const Radius.circular(1),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TodayMarkPainter old) => old.color != color;
}
