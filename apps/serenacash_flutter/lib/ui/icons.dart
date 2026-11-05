/// Own icon set (24 px grid, 1.75 stroke, rounded caps), drawn from the brand SVG paths. Never emoji.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum SIconName {
  home,
  list,
  cart,
  plan,
  more,
  plus,
  check,
  close,
  chevronRight,
  chevronLeft,
  chevronUp,
  chevronDown,
  wallet,
  card,
  calendar,
  tag,
  search,
  eye,
  eyeOff,
  camera,
  barcode,
  flash,
  flashOff,
  settings,
  info,
  alert,
  trash,
  edit,
  arrowUp,
  arrowDown,
  swap,
  target,
  bank,
  receipt,
  help,
  lock,
  download,
  upload,
  sparkle,
  drag,
  star,
  moon,
  sun,
  layers,
  chart,
}

sealed class _Shape {
  const _Shape();
}

class _P extends _Shape {
  const _P(this.d);
  final String d;
}

class _C extends _Shape {
  const _C(this.cx, this.cy, this.r);
  final double cx, cy, r;
}

class _R extends _Shape {
  const _R(this.x, this.y, this.w, this.h, this.rx);
  final double x, y, w, h, rx;
}

const _shapes = <SIconName, List<_Shape>>{
  SIconName.home: [
    _P('M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z'),
  ],
  SIconName.list: [
    _P('M8 6h13M8 12h13M8 18h13'),
    _C(4, 6, 1),
    _C(4, 12, 1),
    _C(4, 18, 1),
  ],
  SIconName.cart: [
    _P('M3 4h2l2.4 11.2a1 1 0 0 0 1 .8h9.7a1 1 0 0 0 1-.8L21 8H6'),
    _C(9, 20, 1.2),
    _C(17, 20, 1.2),
  ],
  SIconName.plan: [_C(12, 12, 9), _P('M12 7v5l3.5 2')],
  SIconName.more: [_C(5, 12, 1.2), _C(12, 12, 1.2), _C(19, 12, 1.2)],
  SIconName.plus: [_P('M12 5v14M5 12h14')],
  SIconName.check: [_P('M5 12.5l4.5 4.5L19 7.5')],
  SIconName.close: [_P('M6 6l12 12M18 6L6 18')],
  SIconName.chevronRight: [_P('M9 6l6 6-6 6')],
  SIconName.chevronLeft: [_P('M15 6l-6 6 6 6')],
  SIconName.chevronUp: [_P('M6 15l6-6 6 6')],
  SIconName.chevronDown: [_P('M6 9l6 6 6-6')],
  SIconName.wallet: [_R(3, 6, 18, 13, 3), _P('M3 10h18M16 14.5h2')],
  SIconName.card: [_R(2, 5, 20, 14, 3), _P('M2 10h20M6 15h4')],
  SIconName.calendar: [_R(3, 5, 18, 16, 3), _P('M3 10h18M8 3v4M16 3v4')],
  SIconName.tag: [_P('M3 12V4h8l9 9-8 8z'), _C(7.5, 8.5, 1.2)],
  SIconName.search: [_C(11, 11, 6.5), _P('M16 16l4.5 4.5')],
  SIconName.eye: [
    _P('M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6z'),
    _C(12, 12, 2.8),
  ],
  SIconName.eyeOff: [
    _P(
      'M3 3l18 18M10.6 6.3A10 10 0 0 1 12 6c6 0 9.5 6 9.5 6a16 16 0 0 1-3.2 3.8M6.6 6.6A16 16 0 0 0 2.5 12s3.5 6 9.5 6a9 9 0 0 0 3.6-.7',
    ),
  ],
  SIconName.camera: [
    _P(
      'M4 8h3l1.5-2h7L17 8h3a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z',
    ),
    _C(12, 13, 3.2),
  ],
  SIconName.barcode: [_P('M4 6v12M8 6v12M11 6v12M14 6v12M17 6v12M20 6v12')],
  SIconName.flash: [_P('M13 2L5 13h6l-1 9 8-11h-6z')],
  SIconName.flashOff: [
    _P('M13 2L8.5 8.2M5 13h6l-1 9 4.8-6.6M3 3l18 18M12.5 9H18l-2.6 3.6'),
  ],
  SIconName.settings: [
    _C(12, 12, 3),
    _P(
      'M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.3 5.3l2.1 2.1M16.6 16.6l2.1 2.1M5.3 18.7l2.1-2.1M16.6 7.4l2.1-2.1',
    ),
  ],
  SIconName.info: [_C(12, 12, 9), _P('M12 11v5M12 8v.5')],
  SIconName.alert: [_P('M12 3l9.5 16.5h-19z'), _P('M12 10v4M12 17v.5')],
  SIconName.trash: [_P('M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13')],
  SIconName.edit: [
    _P('M4 20h4l10.5-10.5a2 2 0 0 0 0-2.8l-1.2-1.2a2 2 0 0 0-2.8 0L4 16z'),
  ],
  SIconName.arrowUp: [_P('M12 19V5M6 11l6-6 6 6')],
  SIconName.arrowDown: [_P('M12 5v14M6 13l6 6 6-6')],
  SIconName.swap: [_P('M7 7h13m-4-4 4 4-4 4M17 17H4m4-4-4 4 4 4')],
  SIconName.target: [_C(12, 12, 9), _C(12, 12, 5), _C(12, 12, 1.2)],
  SIconName.bank: [_P('M3 10l9-6 9 6M5 10v8M9 10v8M15 10v8M19 10v8M3 20h18')],
  SIconName.receipt: [
    _P('M6 3h12v18l-2-1.5-2 1.5-2-1.5-2 1.5-2-1.5L6 21z'),
    _P('M9 8h6M9 12h6'),
  ],
  SIconName.help: [
    _C(12, 12, 9),
    _P('M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.3-1 .8-1 1.7M12 17v.5'),
  ],
  SIconName.lock: [_R(5, 11, 14, 10, 2), _P('M8 11V8a4 4 0 0 1 8 0v3')],
  SIconName.download: [_P('M12 4v11M7 10l5 5 5-5M4 20h16')],
  SIconName.upload: [_P('M12 15V4M7 9l5-5 5 5M4 20h16')],
  SIconName.sparkle: [
    _P(
      'M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8zM19 16l.8 2.2L22 19l-2.2.8L19 22l-.8-2.2L16 19l2.2-.8z',
    ),
  ],
  SIconName.drag: [
    _C(9, 7, 1.2),
    _C(15, 7, 1.2),
    _C(9, 12, 1.2),
    _C(15, 12, 1.2),
    _C(9, 17, 1.2),
    _C(15, 17, 1.2),
  ],
  SIconName.star: [
    _P(
      'M12 3.5l2.6 5.4 5.9.8-4.3 4.1 1.1 5.9L12 16.9l-5.3 2.8 1.1-5.9-4.3-4.1 5.9-.8z',
    ),
  ],
  SIconName.moon: [_P('M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z')],
  SIconName.sun: [
    _C(12, 12, 4),
    _P(
      'M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5.3 5.3l1.4 1.4M17.3 17.3l1.4 1.4M5.3 18.7l1.4-1.4M17.3 6.7l1.4-1.4',
    ),
  ],
  SIconName.layers: [
    _P('M12 3.5l9 4.5-9 4.5-9-4.5z'),
    _P('M3 12.2l9 4.5 9-4.5M3 16.4l9 4.5 9-4.5'),
  ],
  SIconName.chart: [_P('M4 20.5h16M7 17v-4M12 17V8M17 17V4.5')],
};

/// Icon stored on a category ("cart", "arrow-up"…); unknown keys fall back to [fallback].
SIconName iconByKey(String key, {SIconName fallback = SIconName.tag}) {
  final parts = key.split('-');
  final camel =
      parts.first +
      parts
          .skip(1)
          .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
          .join();
  for (final n in SIconName.values) {
    if (n.name == camel) return n;
  }
  return fallback;
}

class SIcon extends StatelessWidget {
  const SIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color,
    this.filled = false,
    this.semanticLabel,
  });
  final SIconName name;
  final double size;
  final Color? color;
  final bool filled;
  final String? semanticLabel;
  @override
  Widget build(BuildContext context) {
    final c =
        color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFF162022);
    final child = CustomPaint(
      size: Size.square(size),
      painter: _IconPainter(_shapes[name]!, c, filled),
    );
    return ExcludeSemantics(
      excluding: semanticLabel == null,
      child: Semantics(label: semanticLabel, child: child),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.shapes, this.color, this.filled);
  final List<_Shape> shapes;
  final Color color;
  final bool filled;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k, k);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final s in shapes) {
      final path = switch (s) {
        _P(:final d) => parseSvgPath(d),
        _C(:final cx, :final cy, :final r) =>
          Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
        _R(:final x, :final y, :final w, :final h, :final rx) =>
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, w, h),
              Radius.circular(rx),
            ),
          ),
      };
      if (filled) canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.shapes != shapes || old.color != color || old.filled != filled;
}

/// Minimal SVG path parser (M, L, H, V, C, S, A, Z and relative forms) sufficient for the icon set.
Path parseSvgPath(String d) {
  final path = Path();
  final tokens = RegExp(r'[MmLlHhVvCcSsAaZz]|-?\d*\.?\d+(?:e-?\d+)?')
      .allMatches(d)
      .map((m) => m.group(0)!)
      .toList();
  var i = 0;
  var cx = 0.0, cy = 0.0, sx = 0.0, sy = 0.0;
  double? lastCx, lastCy; // last cubic control point for S
  String cmd = 'M';
  double num() => double.parse(tokens[i++]);
  bool isNum() =>
      i < tokens.length && !RegExp(r'^[A-Za-z]$').hasMatch(tokens[i]);
  while (i < tokens.length) {
    if (!isNum()) cmd = tokens[i++];
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        var x = num(), y = num();
        if (rel) {
          x += cx;
          y += cy;
        }
        path.moveTo(x, y);
        cx = x;
        cy = y;
        sx = x;
        sy = y;
        lastCx = null;
        cmd = rel ? 'l' : 'L';
      case 'L':
        var x = num(), y = num();
        if (rel) {
          x += cx;
          y += cy;
        }
        path.lineTo(x, y);
        cx = x;
        cy = y;
        lastCx = null;
      case 'H':
        var x = num();
        if (rel) x += cx;
        path.lineTo(x, cy);
        cx = x;
        lastCx = null;
      case 'V':
        var y = num();
        if (rel) y += cy;
        path.lineTo(cx, y);
        cy = y;
        lastCx = null;
      case 'C':
        var x1 = num(),
            y1 = num(),
            x2 = num(),
            y2 = num(),
            x = num(),
            y = num();
        if (rel) {
          x1 += cx;
          y1 += cy;
          x2 += cx;
          y2 += cy;
          x += cx;
          y += cy;
        }
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastCx = x2;
        lastCy = y2;
        cx = x;
        cy = y;
      case 'S':
        var x2 = num(), y2 = num(), x = num(), y = num();
        if (rel) {
          x2 += cx;
          y2 += cy;
          x += cx;
          y += cy;
        }
        final x1 = lastCx == null ? cx : 2 * cx - lastCx;
        final y1 = lastCy == null ? cy : 2 * cy - lastCy;
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastCx = x2;
        lastCy = y2;
        cx = x;
        cy = y;
      case 'A':
        final rx = num(), ry = num(), rot = num(), large = num(), sweep = num();
        var x = num(), y = num();
        if (rel) {
          x += cx;
          y += cy;
        }
        _arcTo(path, cx, cy, rx, ry, rot, large != 0, sweep != 0, x, y);
        cx = x;
        cy = y;
        lastCx = null;
      case 'Z':
        path.close();
        cx = sx;
        cy = sy;
        lastCx = null;
    }
  }
  return path;
}

/// SVG elliptical arc → cubic approximation (standard endpoint-to-center conversion).
void _arcTo(
  Path path,
  double x1,
  double y1,
  double rx,
  double ry,
  double rotDeg,
  bool large,
  bool sweep,
  double x2,
  double y2,
) {
  if (rx == 0 || ry == 0) {
    path.lineTo(x2, y2);
    return;
  }
  final phi = rotDeg * math.pi / 180;
  final cosPhi = math.cos(phi), sinPhi = math.sin(phi);
  final dx = (x1 - x2) / 2, dy = (y1 - y2) / 2;
  final x1p = cosPhi * dx + sinPhi * dy, y1p = -sinPhi * dx + cosPhi * dy;
  var rxa = rx.abs(), rya = ry.abs();
  final lambda = (x1p * x1p) / (rxa * rxa) + (y1p * y1p) / (rya * rya);
  if (lambda > 1) {
    rxa *= math.sqrt(lambda);
    rya *= math.sqrt(lambda);
  }
  final num =
      rxa * rxa * rya * rya - rxa * rxa * y1p * y1p - rya * rya * x1p * x1p;
  final den = rxa * rxa * y1p * y1p + rya * rya * x1p * x1p;
  var coef = math.sqrt(math.max(0, num / den));
  if (large == sweep) coef = -coef;
  final cxp = coef * (rxa * y1p / rya), cyp = coef * -(rya * x1p / rxa);
  final cx = cosPhi * cxp - sinPhi * cyp + (x1 + x2) / 2,
      cy = sinPhi * cxp + cosPhi * cyp + (y1 + y2) / 2;
  double ang(double ux, double uy, double vx, double vy) {
    final dot = ux * vx + uy * vy,
        len = math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
    var a = math.acos((dot / len).clamp(-1, 1));
    if (ux * vy - uy * vx < 0) a = -a;
    return a;
  }

  final theta1 = ang(1, 0, (x1p - cxp) / rxa, (y1p - cyp) / rya);
  var delta = ang(
    (x1p - cxp) / rxa,
    (y1p - cyp) / rya,
    (-x1p - cxp) / rxa,
    (-y1p - cyp) / rya,
  );
  if (!sweep && delta > 0) delta -= 2 * math.pi;
  if (sweep && delta < 0) delta += 2 * math.pi;
  final segments = (delta.abs() / (math.pi / 2)).ceil().clamp(1, 4);
  final step = delta / segments;
  var t = theta1;
  for (var s = 0; s < segments; s++) {
    final t2 = t + step;
    final alpha = 4 / 3 * math.tan((t2 - t) / 4);
    final p1x = math.cos(t),
        p1y = math.sin(t),
        p2x = math.cos(t2),
        p2y = math.sin(t2);
    Offset map(double ex, double ey) => Offset(
      cosPhi * rxa * ex - sinPhi * rya * ey + cx,
      sinPhi * rxa * ex + cosPhi * rya * ey + cy,
    );
    final c1 = map(p1x - alpha * p1y, p1y + alpha * p1x),
        c2 = map(p2x + alpha * p2y, p2y - alpha * p2x),
        end = map(p2x, p2y);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    t = t2;
  }
}
