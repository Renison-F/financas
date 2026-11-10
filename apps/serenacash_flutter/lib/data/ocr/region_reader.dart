/// Reads the text of one region of a photo: the region is cut out of the original, read again by
/// the on-device OCR on its own and thrown away. The photo kept as evidence is never changed.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/shopping/label.dart';
import 'ocr_service.dart';

/// The smallest region worth reading, as a fraction of each side of the photo.
const minRegionFraction = 0.03;

/// Cuts [region] out of [photo] and returns it as a PNG. [region] is given in fractions of the
/// upright photo (0 to 1 on each axis). A small cut-out is enlarged, up to three times, because
/// small print is read better that way; nothing is sharpened or otherwise altered.
Future<Uint8List> cropImage(Uint8List photo, ui.Rect region) async {
  final codec = await ui.instantiateImageCodec(photo);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  try {
    final r = ui.Rect.fromLTRB(
      region.left.clamp(0.0, 1.0) * image.width,
      region.top.clamp(0.0, 1.0) * image.height,
      region.right.clamp(0.0, 1.0) * image.width,
      region.bottom.clamp(0.0, 1.0) * image.height,
    );
    if (r.width < 1 || r.height < 1) {
      throw ArgumentError.value(region, 'region', 'empty');
    }
    final scale = (900 / math.max(r.width, r.height)).clamp(1.0, 3.0);
    final w = math.max(1, (r.width * scale).round());
    final h = math.max(1, (r.height * scale).round());
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      image,
      r,
      ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
    final picture = recorder.endRecording();
    final cut = await picture.toImage(w, h);
    picture.dispose();
    try {
      final data = await cut.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      cut.dispose();
    }
  } finally {
    image.dispose();
    codec.dispose();
  }
}

/// Lines in reading order: top to bottom, and left to right on the same row.
List<OcrBox> inReadingOrder(List<OcrBox> lines) => [...lines]
  ..sort((a, b) {
    final sameRow = (a.top - b.top).abs() <= math.min(a.height, b.height) * 0.5;
    return sameRow ? a.left.compareTo(b.left) : a.top.compareTo(b.top);
  });

abstract interface class RegionReader {
  /// The lines read inside [region] (fractions of the photo), in reading order. Throws
  /// [OcrUnavailable] where there is no OCR.
  Future<List<OcrBox>> read(Uint8List photo, ui.Rect region);
}

class OcrRegionReader implements RegionReader {
  const OcrRegionReader(this.ocr);
  final OcrService ocr;

  @override
  Future<List<OcrBox>> read(Uint8List photo, ui.Rect region) async {
    if (!ocr.available) throw const OcrUnavailable();
    final cut = await cropImage(photo, region);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/area-${DateTime.now().microsecondsSinceEpoch}.png',
    );
    try {
      await file.writeAsBytes(cut, flush: true);
      return inReadingOrder((await ocr.read(file.path)).lines);
    } finally {
      // The cut-out exists only for the reading.
      if (file.existsSync()) await file.delete();
    }
  }
}

final regionReaderProvider = Provider<RegionReader>(
  (ref) => OcrRegionReader(ref.watch(ocrServiceProvider)),
);
