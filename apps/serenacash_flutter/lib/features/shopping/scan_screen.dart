/// Scanner of the shopping session, inside the app from start to end.
///
/// "Etiqueta" shows the camera here, takes the photo here and reads it on the device; "Código" reads
/// EAN/UPC/QR live. Nothing is added to the cart on this screen: the photo and its reading go back
/// to the session, which opens the review. One camera is open at a time, it is released when the
/// app leaves the foreground or the screen closes, and a second tap cannot start a second capture.
library;

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../data/ocr/ocr_service.dart';
import '../../domain/money/money.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';
import 'scan_result.dart';

/// What the scanner is being used for: `label` and `barcode` feed the cart; `photo` only returns a
/// picture (of the product, of the receipt) to whoever opened it.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, this.mode = 'label'});
  final String mode;
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

/// Opens the camera to take one picture and returns its bytes (null when the user gave up).
Future<Uint8List?> capturePhoto(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ScanScreen(mode: 'photo'),
      ),
    );

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  late String _mode = switch (widget.mode) {
    'barcode' => 'barcode',
    'photo' => 'photo',
    _ => 'label',
  };
  bool get _usesStillCamera => _mode != 'barcode';

  CameraController? _camera;
  MobileScannerController? _scanner;
  // Every start gets a number; a start that finishes after a newer one began throws its camera away.
  int _generation = 0;
  String? _cameraProblem;
  bool _denied = false;
  bool _torch = false;
  bool _busy = false;
  String _status = '';
  double _zoom = 1, _minZoom = 1, _maxZoom = 1, _zoomAtPinchStart = 1;
  String? _lastCode;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    unawaited(_release(_camera));
    unawaited(_release(_scanner));
    super.dispose();
  }

  bool _releasedForBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The camera belongs to whoever is on screen: once the app is out of sight it is released.
    // "inactive" alone is not out of sight: the permission question, the notification shade and a
    // system dialog all pass through it with this screen still showing, and restarting the camera
    // there would open a second one while the first is still answering.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (!_releasedForBackground) {
        _releasedForBackground = true;
        unawaited(_stop());
      }
    } else if (state == AppLifecycleState.resumed && _releasedForBackground) {
      _releasedForBackground = false;
      unawaited(_start());
    }
  }

  /// Releasing a camera that never finished opening throws on some devices; there is nothing to
  /// do about it, and it must not surface as an unhandled error.
  static Future<void> _release(Object? controller) async {
    try {
      if (controller is CameraController) await controller.dispose();
      if (controller is MobileScannerController) await controller.dispose();
    } catch (_) {}
  }

  Future<void> _stop() async {
    _generation++;
    final cam = _camera, scan = _scanner;
    _camera = null;
    _scanner = null;
    if (mounted) setState(() => _torch = false);
    await _release(cam);
    await _release(scan);
  }

  Future<void> _start() async {
    await _stop();
    final mine = _generation;
    if (!mounted) return;
    setState(() {
      _cameraProblem = null;
      _denied = false;
      _status = '';
    });
    if (!_usesStillCamera) {
      final s = MobileScannerController(
        formats: const [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.code128,
          BarcodeFormat.qrCode,
        ],
      );
      if (mine != _generation || !mounted) return unawaited(_release(s));
      setState(() => _scanner = s);
      return;
    }
    CameraController? cam;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('noCamera', null);
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      cam = CameraController(
        back,
        // Enough detail for small print without multi-megabyte photos in the database.
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await cam.initialize();
      if (mine != _generation || !mounted) return unawaited(_release(cam));
      final min = await cam.getMinZoomLevel(),
          max = await cam.getMaxZoomLevel();
      await cam.setFlashMode(FlashMode.off);
      if (mine != _generation || !mounted) return unawaited(_release(cam));
      setState(() {
        _camera = cam;
        _minZoom = min;
        _maxZoom = max;
        _zoom = min;
      });
    } on CameraException catch (e) {
      unawaited(_release(cam));
      if (mine != _generation || !mounted) return;
      setState(() {
        _denied = e.code.contains('AccessDenied');
        _cameraProblem = e.code;
      });
    } catch (_) {
      unawaited(_release(cam));
      if (mine != _generation || !mounted) return;
      setState(() => _cameraProblem = 'unknown');
    }
  }

  Future<void> _setMode(String m) async {
    if (m == _mode) return;
    setState(() => _mode = m);
    await _start();
  }

  Future<void> _toggleTorch() async {
    try {
      if (_usesStillCamera) {
        final cam = _camera;
        if (cam == null) return;
        await cam.setFlashMode(_torch ? FlashMode.off : FlashMode.torch);
      } else {
        await _scanner?.toggleTorch();
      }
      if (mounted) setState(() => _torch = !_torch);
    } catch (_) {
      // No flash on this camera: the button simply has no effect.
    }
  }

  void _finish(ScanResult r) {
    ref.read(scanResultProvider.notifier).set(r);
    unawaited(HapticFeedback.mediumImpact());
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
      // A QR code can carry anything. Only the fiscal receipt key is taken from it, as text: no
      // link is opened and nothing in it is executed.
      final nf = parseNFCeQR(data);
      if (nf != null) return _finish(ScanResult.nfce(nf.accessKey));
      setState(() => _status = l.qrNotReceipt);
      return;
    }
    // Whatever was decoded goes back: recognising the digits and knowing the product are two
    // different things, and the session tells them apart.
    _finish(ScanResult.barcode(parseBarcode(data)));
  }

  Future<void> _capture() async {
    final cam = _camera;
    // One capture at a time: a second tap while the first is being read is ignored.
    if (_busy ||
        cam == null ||
        !cam.value.isInitialized ||
        cam.value.isTakingPicture) {
      return;
    }
    final l = context.l10n;
    setState(() {
      _busy = true;
      _status = _mode == 'photo' ? '' : l.readingTag;
    });
    File? file;
    try {
      final shot = await cam.takePicture();
      file = File(shot.path);
      final bytes = await file.readAsBytes();
      if (_mode == 'photo') {
        if (mounted) Navigator.of(context).pop(bytes);
        return;
      }
      OcrPage? page;
      try {
        page = await ref.read(ocrServiceProvider).read(shot.path);
      } on OcrUnavailable {
        page = null;
      }
      _finish(
        ScanResult.label(
          analysis: page == null ? null : analyzeLabel(page.lines),
          photo: bytes,
          page: page,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _status = l.readFailed);
    } finally {
      // The picture file in the cache is temporary: what is kept goes into the encrypted database.
      try {
        await file?.delete();
      } catch (_) {}
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _focusAt(TapUpDetails d, Size size) async {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized) return;
    try {
      final p = Offset(
        d.localPosition.dx / size.width,
        d.localPosition.dy / size.height,
      );
      await cam.setFocusPoint(p);
      await cam.setExposurePoint(p);
    } catch (_) {
      // Fixed-focus camera.
    }
  }

  Widget _problem(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return Container(
      color: c.bg,
      padding: const EdgeInsets.all(Spacing.lg),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l.camera, style: Type.headline.copyWith(color: c.text)),
            const SizedBox(height: Spacing.sm),
            Text(
              _denied ? l.cameraPermissionText : l.cameraUnavailable,
              style: Type.body.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Spacing.md),
            SButton(
              label: _denied ? l.allowCamera : l.retry,
              fullWidth: true,
              onPressed: _start,
            ),
            if (_mode != 'photo') ...[
              const SizedBox(height: Spacing.xs),
              SButton(
                label: l.enterManually,
                variant: SButtonVariant.secondary,
                fullWidth: true,
                onPressed: _manual,
              ),
            ],
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
  }

  Widget _preview() {
    final cam = _camera;
    if (_usesStillCamera) {
      if (cam == null || !cam.value.isInitialized) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFFFFF)),
        );
      }
      final size = cam.value.previewSize;
      return LayoutBuilder(
        builder: (context, box) => GestureDetector(
          onTapUp: (d) => _focusAt(d, box.biggest),
          onScaleStart: (_) => _zoomAtPinchStart = _zoom,
          onScaleUpdate: (d) async {
            final z = (_zoomAtPinchStart * d.scale).clamp(_minZoom, _maxZoom);
            if ((z - _zoom).abs() < 0.05) return;
            _zoom = z;
            try {
              await cam.setZoomLevel(z);
            } catch (_) {}
            if (mounted) setState(() {});
          },
          child: ClipRect(
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  // The sensor reports its size in landscape; the screen is portrait.
                  width: size?.height ?? 1080,
                  height: size?.width ?? 1920,
                  child: CameraPreview(cam),
                ),
              ),
            ),
          ),
        ),
      );
    }
    final scan = _scanner;
    if (scan == null) return const SizedBox.shrink();
    return MobileScanner(
      controller: scan,
      onDetect: _onDetect,
      errorBuilder: (ctx, error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _cameraProblem != null) return;
          setState(() {
            _denied =
                error.errorCode == MobileScannerErrorCode.permissionDenied;
            _cameraProblem = error.errorCode.name;
          });
        });
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    const white = Color(0xFFFFFFFF);
    if (_cameraProblem != null) {
      return Scaffold(backgroundColor: c.bg, body: _problem(context));
    }
    // The cart stays in sight while scanning: what is in it and how much of the budget is left.
    final session = _mode == 'photo'
        ? null
        : ref
              .watch(appControllerProvider)
              .value
              ?.sessions
              .where((s) => s.status == 'active')
              .firstOrNull;
    final totals = session == null ? null : sessionTotals(session);
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          Positioned.fill(child: _preview()),
          if (_mode != 'photo')
            IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: _mode == 'label' ? 300 : 260,
                      height: _mode == 'label' ? 190 : 120,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _RoundButton(
                        icon: SIconName.close,
                        label: l.closeCamera,
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: _mode == 'photo'
                            ? const SizedBox.shrink()
                            : Segmented<String>(
                                options: [
                                  ('label', l.tagBtn),
                                  ('barcode', l.codeBtn),
                                ],
                                value: _mode,
                                onChanged: _setMode,
                              ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      _RoundButton(
                        icon: _torch ? SIconName.flashOff : SIconName.flash,
                        label: _torch ? l.torchOff : l.torchOn,
                        onTap: _toggleTorch,
                      ),
                    ],
                  ),
                  if (totals != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _Pill(
                        text: totals.budgetCents == null
                            ? l.scanCart(formatBRL(totals.totalCents))
                            : l.scanCartBudget(
                                formatBRL(totals.totalCents),
                                formatBRL(totals.remainingCents ?? 0),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: Spacing.md,
            right: Spacing.md,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: Spacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_status.isNotEmpty)
                      Semantics(liveRegion: true, child: _Pill(text: _status)),
                    if (_usesStillCamera && _maxZoom > _minZoom)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${_zoom.toStringAsFixed(1).replaceAll('.', ',')}×',
                          style: Type.caption.copyWith(color: white),
                        ),
                      ),
                    const SizedBox(height: Spacing.sm),
                    if (_usesStillCamera)
                      Semantics(
                        button: true,
                        label: _mode == 'photo' ? l.takePhoto : l.readTag,
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
                                  ? const CircularProgressIndicator(
                                      color: white,
                                    )
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
                    if (_mode != 'photo') ...[
                      const SizedBox(height: Spacing.xs),
                      TextButton(
                        onPressed: _manual,
                        child: Text(
                          l.enterManually,
                          style: Type.label.copyWith(
                            color: white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xB3000000),
      borderRadius: BorderRadius.circular(Radii.sm),
    ),
    child: Text(
      text,
      style: Type.bodySmall.copyWith(color: const Color(0xFFFFFFFF)),
      textAlign: TextAlign.center,
    ),
  );
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
        child: SizedBox(
          width: Touch.min,
          height: Touch.min,
          child: Center(child: SIcon(icon, color: const Color(0xFFFFFFFF))),
        ),
      ),
    ),
  );
}
