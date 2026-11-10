import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ocr/ocr_service.dart';
import '../../domain/shopping/shopping.dart';

/// Hands a scan result from the camera screen back to the session screen.
class ScanResult {
  /// A photographed label: the photo itself (kept as evidence), what was read on it and how that
  /// was understood. [analysis] is null when no reading was possible; the photo still goes along.
  const ScanResult.label({this.analysis, this.photo, this.page})
    : kind = 'label',
      barcode = null,
      nfceKey = null;
  const ScanResult.barcode(this.barcode)
    : kind = 'barcode',
      analysis = null,
      photo = null,
      page = null,
      nfceKey = null;
  const ScanResult.nfce(this.nfceKey)
    : kind = 'nfce',
      analysis = null,
      photo = null,
      page = null,
      barcode = null;
  const ScanResult.manual()
    : kind = 'manual',
      analysis = null,
      photo = null,
      page = null,
      barcode = null,
      nfceKey = null;
  final String kind;
  final LabelAnalysis? analysis;
  final Uint8List? photo;
  final OcrPage? page;
  final ParsedBarcode? barcode;
  final String? nfceKey;
}

class ScanResultNotifier extends Notifier<ScanResult?> {
  @override
  ScanResult? build() => null;
  void set(ScanResult? r) => state = r;
}

final scanResultProvider = NotifierProvider<ScanResultNotifier, ScanResult?>(
  ScanResultNotifier.new,
);
