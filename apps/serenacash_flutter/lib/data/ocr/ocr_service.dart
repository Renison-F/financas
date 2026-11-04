/// On-device OCR port. The ML Kit implementation runs only on Android/iOS; everywhere else (tests, desktop)
/// [UnavailableOcr] makes the UI fall back to manual entry. Images never leave the device.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/shopping/pricetag.dart';

class OcrUnavailable implements Exception {
  const OcrUnavailable();
}

abstract interface class OcrService {
  bool get available;
  Future<List<OCRLine>> recognize(String imagePath);
}

class UnavailableOcr implements OcrService {
  const UnavailableOcr();
  @override
  bool get available => false;
  @override
  Future<List<OCRLine>> recognize(String imagePath) =>
      throw const OcrUnavailable();
}

class MlKitOcr implements OcrService {
  MlKitOcr();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  @override
  bool get available => true;
  @override
  Future<List<OCRLine>> recognize(String imagePath) async {
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    return [
      for (final block in result.blocks)
        for (final line in block.lines)
          OCRLine(
            text: line.text,
            height: line.boundingBox.height,
            y: line.boundingBox.top,
          ),
    ];
  }
}

final ocrServiceProvider = Provider<OcrService>(
  (_) =>
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS
      ? MlKitOcr()
      : const UnavailableOcr(),
);
