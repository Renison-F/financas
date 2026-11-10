/// Dictating a cart item. The words are turned into text by the speech service of the phone, shown
/// as they are heard, and only then read into name, quantity and price. Nothing reaches the cart
/// from here: the result opens the same review screen as a typed or scanned item.
///
/// No audio is recorded or kept by the app. Whether the recognition runs on the device or uses the
/// network depends on the phone's speech service; the sheet says so before the microphone opens.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../app/app.dart';
import '../../app/theme/tokens.dart';
import '../../domain/money/money.dart';
import '../../domain/shopping/voice.dart';
import '../../ui/components/components.dart';

/// Speech to text, behind a port so the flow can be exercised without a microphone.
abstract interface class VoiceInput {
  /// Asks for the microphone and prepares the engine. False when it cannot be used.
  Future<bool> prepare();

  /// Starts listening; [onText] receives what was understood so far and whether it is final.
  Future<void> listen(void Function(String text, bool isFinal) onText);
  Future<void> stop();
}

class DeviceVoiceInput implements VoiceInput {
  final _speech = SpeechToText();
  @override
  Future<bool> prepare() async {
    try {
      return await _speech.initialize();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> listen(void Function(String text, bool isFinal) onText) =>
      _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: 'pt_BR',
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 4),
        ),
        onResult: (SpeechRecognitionResult r) =>
            onText(r.recognizedWords, r.finalResult),
      );

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {}
  }
}

final voiceInputProvider = Provider<VoiceInput>((_) => DeviceVoiceInput());

/// What the user dictated and how the amount is to be read. Null when they gave up.
class VoiceResult {
  const VoiceResult(this.item, {required this.amountIsTotal});
  final SpokenItem item;
  final bool amountIsTotal;
}

Future<VoiceResult?> showVoiceSheet(BuildContext context) =>
    showSSheet<VoiceResult>(
      context,
      useRootNavigator: true,
      builder: (_) => const _VoiceSheet(),
    );

class _VoiceSheet extends ConsumerStatefulWidget {
  const _VoiceSheet();
  @override
  ConsumerState<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends ConsumerState<_VoiceSheet> {
  late final VoiceInput _voice = ref.read(voiceInputProvider);
  String _text = '';
  bool _listening = false, _unavailable = false, _started = false;
  SpokenItem? _item;

  @override
  void dispose() {
    unawaited(_voice.stop());
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _started = true;
      _unavailable = false;
      _item = null;
      _text = '';
    });
    if (!await _voice.prepare()) {
      if (mounted) setState(() => _unavailable = true);
      return;
    }
    if (!mounted) return;
    setState(() => _listening = true);
    try {
      await _voice.listen((text, isFinal) {
        if (!mounted) return;
        setState(() {
          _text = text;
          if (isFinal) {
            _listening = false;
            _item = parseSpokenItem(text);
          }
        });
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _listening = false;
          _unavailable = true;
        });
      }
    }
  }

  Future<void> _finish() async {
    await _voice.stop();
    if (!mounted) return;
    setState(() {
      _listening = false;
      if (_text.trim().isNotEmpty) _item = parseSpokenItem(_text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final item = _item;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.voiceTitle,
            style: Type.headline.copyWith(color: c.text, fontSize: 18),
          ),
          const SizedBox(height: Spacing.xs),
          if (!_started) ...[
            Text(l.voiceIntro, style: Type.body.copyWith(color: c.text)),
            const SizedBox(height: 6),
            Text(
              l.voicePrivacy,
              style: Type.bodySmall.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Spacing.md),
            SButton(
              label: l.voiceStart,
              icon: SIconName.mic,
              fullWidth: true,
              onPressed: _start,
            ),
          ] else if (_unavailable) ...[
            Text(l.voiceUnavailable, style: Type.body.copyWith(color: c.text)),
            const SizedBox(height: Spacing.md),
            SButton(label: l.retry, fullWidth: true, onPressed: _start),
          ] else ...[
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: c.surfaceInset,
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Text(
                  _text.isEmpty
                      ? (_listening ? l.voiceListening : l.voiceNothing)
                      : _text,
                  style: Type.body.copyWith(
                    color: _text.isEmpty ? c.textMuted : c.text,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            if (_listening)
              SButton(label: l.voiceDone, fullWidth: true, onPressed: _finish)
            else if (item == null || item.cancel || item.name.isEmpty)
              SButton(
                label: l.voiceAgain,
                icon: SIconName.mic,
                fullWidth: true,
                onPressed: _start,
              )
            else ...[
              Text(
                l.voiceUnderstood(
                  item.name,
                  '${item.quantity == item.quantity.roundToDouble() ? item.quantity.toInt() : item.quantity.toString().replaceAll('.', ',')} ${item.unit}',
                  item.amountCents == null
                      ? l.voiceNoPrice
                      : formatBRL(item.amountCents!),
                ),
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Spacing.sm),
              if (item.meaning == SpokenPrice.ambiguous) ...[
                // The one thing that is not guessed: is the amount the total or the price of each?
                Text(
                  l.voiceAmbiguous(formatBRL(item.amountCents!)),
                  style: Type.body.copyWith(color: c.text),
                ),
                const SizedBox(height: Spacing.xs),
                SButton(
                  label: l.voiceIsTotal(
                    formatBRL(item.unitPriceCents(amountIsTotal: true)!),
                    item.unit,
                  ),
                  fullWidth: true,
                  onPressed: () =>
                      Navigator.of(context)
                          .pop(VoiceResult(item, amountIsTotal: true)),
                ),
                const SizedBox(height: 4),
                SButton(
                  label: l.voiceIsEach(formatBRL(item.amountCents!), item.unit),
                  variant: SButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () =>
                      Navigator.of(context)
                          .pop(VoiceResult(item, amountIsTotal: false)),
                ),
              ] else
                SButton(
                  label: l.voiceReview,
                  fullWidth: true,
                  onPressed: () => Navigator.of(context).pop(
                    VoiceResult(
                      item,
                      amountIsTotal: item.meaning == SpokenPrice.total,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              SButton(
                label: l.voiceAgain,
                variant: SButtonVariant.ghost,
                fullWidth: true,
                compact: true,
                onPressed: _start,
              ),
            ],
          ],
          const SizedBox(height: 4),
          SButton(
            label: l.cancel,
            variant: SButtonVariant.ghost,
            fullWidth: true,
            compact: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
