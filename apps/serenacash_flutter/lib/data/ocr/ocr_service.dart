/// On-device OCR port. The ML Kit implementation runs only on Android/iOS; everywhere else (tests, desktop)
/// [UnavailableOcr] makes the UI fall back to manual entry. Images never leave the device.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/shopping/label.dart';

class OcrUnavailable implements Exception {
  const OcrUnavailable();
}

/// What was read on one photo: every line with its box, in pixels of a photo [width] × [height].
class OcrPage {
  const OcrPage({
    required this.lines,
    required this.width,
    required this.height,
  });
  final List<OcrBox> lines;
  final int width, height;
}

abstract interface class OcrService {
  bool get available;
  Future<OcrPage> read(String imagePath);
}

class UnavailableOcr implements OcrService {
  const UnavailableOcr();
  @override
  bool get available => false;
  @override
  Future<OcrPage> read(String imagePath) => throw const OcrUnavailable();
}

class MlKitOcr implements OcrService {
  MlKitOcr();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  @override
  bool get available => true;
  @override
  Future<OcrPage> read(String imagePath) async {
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    // The boxes come in the coordinates of the upright photo; its size is what places them on it.
    final codec = await ui.instantiateImageCodec(
      await File(imagePath).readAsBytes(),
    );
    final frame = await codec.getNextFrame();
    final width = frame.image.width, height = frame.image.height;
    frame.image.dispose();
    codec.dispose();
    return OcrPage(
      width: width,
      height: height,
      lines: [
        for (var b = 0; b < result.blocks.length; b++)
          for (final line in result.blocks[b].lines)
            OcrBox(
              text: line.text,
              block: b,
              left: line.boundingBox.left,
              top: line.boundingBox.top,
              width: line.boundingBox.width,
              height: line.boundingBox.height,
              confidence: line.confidence,
            ),
      ],
    );
  }
}

final ocrServiceProvider = Provider<OcrService>(
  (_) =>
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS
      ? MlKitOcr()
      : const UnavailableOcr(),
);
