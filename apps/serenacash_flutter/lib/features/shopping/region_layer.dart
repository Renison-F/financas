/// The rectangle the user draws over the photo of a label to say "read here". It is drawn by
/// dragging, moved by dragging its inside and resized by dragging a corner. The rectangle is kept
/// in fractions of the photo, so it means the same whatever the size the photo is shown at.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// How close to a corner (in logical pixels) a touch has to be to take hold of it.
const _grip = 28.0;

/// Smallest side of a region, in fractions of the photo.
const _minSide = 0.04;

enum _Drag { create, move, topLeft, topRight, bottomLeft, bottomRight }

/// A drag that is taken at the first touch. Without it the list under the photo would scroll, or
/// the photo would zoom, before the finger had moved far enough for the marking to begin, and the
/// rectangle would start away from where the finger went down.
class _ImmediatePan extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class RegionLayer extends StatefulWidget {
  const RegionLayer({
    super.key,
    required this.region,
    required this.onChanged,
    required this.semanticLabel,
  });

  /// Fractions of the photo (0 to 1), or null when nothing is marked yet.
  final Rect? region;
  final ValueChanged<Rect> onChanged;
  final String semanticLabel;
  @override
  State<RegionLayer> createState() => _RegionLayerState();
}

class _RegionLayerState extends State<RegionLayer> {
  _Drag? _drag;
  Offset _origin = Offset.zero;
  Rect? _atStart;

  Offset _fraction(Offset local, Size size) => Offset(
    (local.dx / size.width).clamp(0.0, 1.0),
    (local.dy / size.height).clamp(0.0, 1.0),
  );

  _Drag _hit(Offset local, Size size) {
    final r = widget.region;
    if (r == null) return _Drag.create;
    final px = Rect.fromLTRB(
      r.left * size.width,
      r.top * size.height,
      r.right * size.width,
      r.bottom * size.height,
    );
    bool near(Offset corner) => (local - corner).distance <= _grip;
    if (near(px.topLeft)) return _Drag.topLeft;
    if (near(px.topRight)) return _Drag.topRight;
    if (near(px.bottomLeft)) return _Drag.bottomLeft;
    if (near(px.bottomRight)) return _Drag.bottomRight;
    if (px.contains(local)) return _Drag.move;
    return _Drag.create;
  }

  Rect _normal(Offset a, Offset b) {
    var left = a.dx < b.dx ? a.dx : b.dx, right = a.dx < b.dx ? b.dx : a.dx;
    var top = a.dy < b.dy ? a.dy : b.dy, bottom = a.dy < b.dy ? b.dy : a.dy;
    if (right - left < _minSide) right = (left + _minSide).clamp(0.0, 1.0);
    if (right - left < _minSide) left = right - _minSide;
    if (bottom - top < _minSide) bottom = (top + _minSide).clamp(0.0, 1.0);
    if (bottom - top < _minSide) top = bottom - _minSide;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  void _update(Offset local, Size size) {
    final p = _fraction(local, size);
    final start = _atStart;
    switch (_drag) {
      case null:
        return;
      case _Drag.create:
        widget.onChanged(_normal(_origin, p));
      case _Drag.move:
        final d = p - _origin;
        final dx = d.dx.clamp(-start!.left, 1 - start.right);
        final dy = d.dy.clamp(-start.top, 1 - start.bottom);
        widget.onChanged(start.shift(Offset(dx, dy)));
      case _Drag.topLeft:
        widget.onChanged(_normal(p, start!.bottomRight));
      case _Drag.topRight:
        widget.onChanged(_normal(p, start!.bottomLeft));
      case _Drag.bottomLeft:
        widget.onChanged(_normal(p, start!.topRight));
      case _Drag.bottomRight:
        widget.onChanged(_normal(p, start!.topLeft));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, box.maxHeight);
        return Semantics(
          container: true,
          label: widget.semanticLabel,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _ImmediatePan:
                  GestureRecognizerFactoryWithHandlers<_ImmediatePan>(
                    _ImmediatePan.new,
                    (r) => r
                      ..onStart = (d) {
                        _drag = _hit(d.localPosition, size);
                        _origin = _fraction(d.localPosition, size);
                        _atStart = widget.region;
                      }
                      ..onUpdate = ((d) => _update(d.localPosition, size))
                      ..onEnd = ((_) => _drag = null)
                      ..onCancel = (() => _drag = null),
                  ),
            },
            child: CustomPaint(
              size: size,
              painter: _RegionPainter(
                region: widget.region,
                line: c.accent,
                shade: const Color(0x66000000),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RegionPainter extends CustomPainter {
  _RegionPainter({
    required this.region,
    required this.line,
    required this.shade,
  });
  final Rect? region;
  final Color line, shade;
  @override
  void paint(Canvas canvas, Size size) {
    final r = region;
    if (r == null) return;
    final px = Rect.fromLTRB(
      r.left * size.width,
      r.top * size.height,
      r.right * size.width,
      r.bottom * size.height,
    );
    // Everything outside the region is dimmed, so what will be read stands out.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRect(px),
      ),
      Paint()..color = shade,
    );
    canvas.drawRect(
      px,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final handle = Paint()..color = line;
    final edge = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final corner in [
      px.topLeft,
      px.topRight,
      px.bottomLeft,
      px.bottomRight,
    ]) {
      canvas.drawCircle(corner, 6, handle);
      canvas.drawCircle(corner, 6, edge);
    }
  }

  @override
  bool shouldRepaint(_RegionPainter old) =>
      old.region != region || old.line != line;
}
