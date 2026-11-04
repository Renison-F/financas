import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/shopping/shopping.dart';

/// Hands a scan result from the camera screen back to the session screen.
class ScanResult {
  const ScanResult.label(this.reading)
    : kind = 'label',
      barcode = null,
      nfceKey = null;
  const ScanResult.barcode(this.barcode)
    : kind = 'barcode',
      reading = null,
      nfceKey = null;
  const ScanResult.nfce(this.nfceKey)
    : kind = 'nfce',
      reading = null,
      barcode = null;
  const ScanResult.manual()
    : kind = 'label',
      reading = null,
      barcode = null,
      nfceKey = null;
  final String kind;
  final PriceTagReading? reading;
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
