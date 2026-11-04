/// Camera screen: "Etiqueta" captures a photo and runs on-device OCR; "Código" scans EAN/UPC/QR live.
/// Handles permission denied, camera unavailable, torch, manual fallback. Nothing is added to the cart here:
/// the result goes back to the session screen for confirmation.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/app.dart';
import '../../app/theme/tokens.dart';
import '../../data/ocr/ocr_service.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';
import 'scan_result.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, this.mode = 'label'});
  final String mode;
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  late String _mode = widget.mode == 'barcode' ? 'barcode' : 'label';
  late final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.qrCode,
    ],
    torchEnabled: false,
  );
  bool _torch = false;
  bool _busy = false;
  String _status = '';
  String? _cameraError;
  String? _lastCode;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish(ScanResult r) {
    ref.read(scanResultProvider.notifier).set(r);
    HapticFeedback.mediumImpact();
    if (mounted) context.pop();
  }

  void _manual() {
    ref.read(scanResultProvider.notifier).set(const ScanResult.manual());
    context.pop();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_mode != 'barcode' || _busy) return;
    final l = context.l10n;
    final b = capture.barcodes.firstOrNull;
    final data = b?.rawValue;
    if (b == null || data == null) return;
    final now = DateTime.now();
    if (_lastCode == data && now.difference(_lastAt).inMilliseconds < 2500) {
      return;
    }
    _lastCode = data;
    _lastAt = now;
    if (b.format == BarcodeFormat.qrCode) {
      final nf = parseNFCeQR(data);
      if (nf != null) return _finish(ScanResult.nfce(nf.accessKey));
      setState(() => _status = l.qrNotReceipt);
      return;
    }
    final parsed = parseBarcode(data);
    if (!parsed.valid) {
      setState(() => _status = l.invalidCode);
      return;
    }
    _finish(ScanResult.barcode(parsed));
  }

  Future<void> _capture() async {
    final l = context.l10n;
    final ocr = ref.read(ocrServiceProvider);
    if (!ocr.available) {
      setState(() => _status = l.ocrUnavailable);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) _manual();
      return;
    }
    setState(() {
      _busy = true;
      _status = l.readingTag;
    });
    try {
      await _controller.stop();
      final photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2200,
      );
      if (photo == null) {
        setState(() => _status = '');
        await _controller.start();
        return;
      }
      final lines = await ocr.recognize(photo.path);
      _finish(ScanResult.label(parsePriceTag(lines)));
    } on OcrUnavailable {
      setState(() => _status = l.ocrUnavailable);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) _manual();
    } catch (e) {
      setState(() => _status = l.readFailed);
      await _controller.start();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    const white = Color(0xFFFFFFFF);
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          Positioned.fill(
            child: _cameraError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.cameraUnavailable,
                            style: Type.title.copyWith(color: white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cameraError!,
                            style: Type.bodySmall.copyWith(color: white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.md),
                          SButton(label: l.enterManually, onPressed: _manual),
                        ],
                      ),
                    ),
                  )
                : MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    errorBuilder: (ctx, error) {
                      final denied =
                          error.errorCode ==
                          MobileScannerErrorCode.permissionDenied;
                      return Container(
                        color: c.bg,
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l.camera,
                                style: Type.headline.copyWith(color: c.text),
                              ),
                              const SizedBox(height: Spacing.sm),
                              Text(
                                denied
                                    ? l.cameraPermissionText
                                    : (error.errorDetails?.message ??
                                          l.cameraUnavailable),
                                style: Type.body.copyWith(color: c.textMuted),
                              ),
                              const SizedBox(height: Spacing.md),
                              if (denied)
                                SButton(
                                  label: l.allowCamera,
                                  fullWidth: true,
                                  onPressed: () => _controller.start(),
                                ),
                              const SizedBox(height: Spacing.xs),
                              SButton(
                                label: l.enterManually,
                                variant: SButtonVariant.secondary,
                                fullWidth: true,
                                onPressed: _manual,
                              ),
                              const SizedBox(height: Spacing.xs),
                              SButton(
                                label: l.back,
                                variant: SButtonVariant.ghost,
                                fullWidth: true,
                                onPressed: () => context.pop(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: _mode == 'label' ? 300 : 260,
                    height: _mode == 'label' ? 180 : 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: c.accent, width: 2),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _mode == 'label' ? l.frameTag : l.pointBarcode,
                    style: Type.label.copyWith(
                      color: white,
                      shadows: const [
                        Shadow(color: Color(0xFF000000), blurRadius: 4),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.md, 8, Spacing.md, 0),
              child: Row(
                children: [
                  _RoundButton(
                    icon: SIconName.close,
                    label: l.closeCamera,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Segmented<String>(
                      options: [('label', l.tagBtn), ('barcode', l.codeBtn)],
                      value: _mode,
                      onChanged: (m) => setState(() {
                        _mode = m;
                        _status = '';
                      }),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  _RoundButton(
                    icon: _torch ? SIconName.flashOff : SIconName.flash,
                    label: _torch ? l.torchOff : l.torchOn,
                    onTap: () async {
                      await _controller.toggleTorch();
                      setState(() => _torch = !_torch);
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: Spacing.md,
            right: Spacing.md,
            bottom: Spacing.lg + MediaQuery.paddingOf(context).bottom,
            child: Column(
              children: [
                if (_status.isNotEmpty)
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x99000000),
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                      child: Text(
                        _status,
                        style: Type.bodySmall.copyWith(color: white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: Spacing.sm),
                if (_mode == 'label')
                  Semantics(
                    button: true,
                    label: l.readTag,
                    child: InkWell(
                      onTap: _busy ? null : _capture,
                      borderRadius: BorderRadius.circular(38),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: white, width: 4),
                        ),
                        child: Center(
                          child: _busy
                              ? const CircularProgressIndicator(color: white)
                              : const SIcon(
                                  SIconName.camera,
                                  color: white,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SIcon(SIconName.barcode, color: white),
                      const SizedBox(width: 8),
                      Text(
                        l.scanningAuto,
                        style: Type.bodySmall.copyWith(color: white),
                      ),
                    ],
                  ),
                const SizedBox(height: Spacing.sm),
                TextButton(
                  onPressed: _manual,
                  child: Text(
                    l.enterManually,
                    style: Type.label.copyWith(color: white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final SIconName icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: const Color(0x80000000),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: Touch.min,
          height: Touch.min,
        ).withChild(SIcon(icon, color: const Color(0xFFFFFFFF))),
      ),
    ),
  );
}

extension on SizedBox {
  Widget withChild(Widget child) => SizedBox(
    width: width,
    height: height,
    child: Center(child: child),
  );
}
