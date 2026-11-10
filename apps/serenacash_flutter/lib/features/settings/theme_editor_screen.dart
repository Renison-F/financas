/// Theme editor: the user picks the action colour and the secondary colour of the app, sees the
/// result before applying it and can go back. A colour that cannot be read is refused, with the
/// reason and a one-touch correction; the colours of income, expense and warning are not editable.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/appearance.dart';
import '../../app/theme/palettes.dart';
import '../../app/theme/theme.dart';
import '../../app/theme/tokens.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

String hexOf(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// `#RRGGBB` or `RRGGBB`, with or without spaces; anything else is null.
Color? parseHex(String text) {
  final t = text.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(t)) return null;
  return Color(0xFF000000 | int.parse(t, radix: 16));
}

class ThemeEditorScreen extends ConsumerStatefulWidget {
  const ThemeEditorScreen({super.key});
  @override
  ConsumerState<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends ConsumerState<ThemeEditorScreen> {
  late Color _primary, _accent;
  late final Color _savedPrimary, _savedAccent;
  late Brightness _preview;
  final _primaryHex = TextEditingController();
  final _accentHex = TextEditingController();
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final p = ref.read(prefsProvider);
    // Start from the palette the user made or, the first time, from the colours now in use.
    final seeds = customSeedsOf(p);
    final current = colorsFor(Brightness.light, p.palette, custom: seeds);
    _primary = seeds?.primary ?? current.primary;
    _accent = seeds?.accent ?? current.accent;
    _savedPrimary = _primary;
    _savedAccent = _accent;
    _preview = Theme.of(context).brightness;
    _primaryHex.text = hexOf(_primary);
    _accentHex.text = hexOf(_accent);
  }

  @override
  void dispose() {
    _primaryHex.dispose();
    _accentHex.dispose();
    super.dispose();
  }

  void _setPrimary(Color c, {bool fromField = false}) => setState(() {
    _primary = c;
    if (!fromField) _primaryHex.text = hexOf(c);
  });

  void _setAccent(Color c, {bool fromField = false}) => setState(() {
    _accent = c;
    if (!fromField) _accentHex.text = hexOf(c);
  });

  bool get _changed => _primary != _savedPrimary || _accent != _savedAccent;
  bool get _valid => readableOnLight(_primary) && visibleOnLight(_accent);

  Future<void> _apply() async {
    await ref
        .read(appControllerProvider.notifier)
        .setPrefs(
          (p) => p.copyWith(
            palette: customPaletteId,
            customPrimary: _primary.toARGB32(),
            customAccent: _accent.toARGB32(),
          ),
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final p = ref.watch(prefsProvider);
    final seeds = CustomSeeds(_primary, _accent);
    final previewTheme = serenaTheme(
      _preview,
      palette: customPaletteId,
      custom: seeds,
      compact: p.density == 'compact',
      look: context.look,
    );
    final primaryRatio = contrastRatio(_primary, SerenaColors.light.bg);
    final accentRatio = contrastRatio(_accent, SerenaColors.light.surface);
    String ratio(double r) => r.toStringAsFixed(1).replaceAll('.', ',');
    return StackScreen(
      title: l.themeEditorTitle,
      children: [
        Text(
          l.themeEditorIntro,
          style: Type.bodySmall.copyWith(color: c.textMuted),
        ),
        Segmented<Brightness>(
          options: [
            (Brightness.light, l.themeLight),
            (Brightness.dark, l.themeDark),
          ],
          value: _preview,
          onChanged: (v) => setState(() => _preview = v),
        ),
        Theme(data: previewTheme, child: const ThemePreview()),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.themePrimary),
              _ColorControls(
                color: _primary,
                hex: _primaryHex,
                hexLabel: l.themeHexOf(l.themePrimary),
                onChanged: _setPrimary,
              ),
              const SizedBox(height: Spacing.xs),
              _Verdict(
                ok: readableOnLight(_primary),
                okText: l.themeContrastOk(ratio(primaryRatio)),
                failText: l.themePrimaryTooLight(ratio(primaryRatio)),
                fixLabel: l.themeFix,
                onFix: () => _setPrimary(readableTone(_primary)),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.themeAccent),
              _ColorControls(
                color: _accent,
                hex: _accentHex,
                hexLabel: l.themeHexOf(l.themeAccent),
                onChanged: _setAccent,
              ),
              const SizedBox(height: Spacing.xs),
              _Verdict(
                ok: visibleOnLight(_accent),
                okText: l.themeContrastOk(ratio(accentRatio)),
                failText: l.themeAccentTooLight(ratio(accentRatio)),
                fixLabel: l.themeFix,
                onFix: () => _setAccent(visibleTone(_accent)),
              ),
            ],
          ),
        ),
        Text(
          l.themeEditorNote,
          style: Type.caption.copyWith(color: c.textMuted),
        ),
        SButton(
          label: l.themeApply,
          icon: SIconName.check,
          onPressed: _valid ? _apply : null,
        ),
        if (_changed)
          SButton(
            label: l.themeRevert,
            variant: SButtonVariant.secondary,
            onPressed: () {
              _setPrimary(_savedPrimary);
              _setAccent(_savedAccent);
            },
          ),
        if (p.palette != 'teal')
          SButton(
            label: l.themeUseDefault,
            variant: SButtonVariant.ghost,
            onPressed: () async {
              await ref
                  .read(appControllerProvider.notifier)
                  .setPrefs((x) => x.copyWith(palette: 'teal'));
              if (context.mounted) context.pop();
            },
          ),
      ],
    );
  }
}

/// Whether a colour can be used, in words and with the measured ratio; colour is not the only cue.
class _Verdict extends StatelessWidget {
  const _Verdict({
    required this.ok,
    required this.okText,
    required this.failText,
    required this.fixLabel,
    required this.onFix,
  });
  final bool ok;
  final String okText, failText, fixLabel;
  final VoidCallback onFix;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: SIcon(
                  ok ? SIconName.check : SIconName.alert,
                  size: 16,
                  color: ok ? c.positive : c.negative,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ok ? okText : failText,
                  style: Type.caption.copyWith(
                    color: ok ? c.textMuted : c.negative,
                  ),
                ),
              ),
            ],
          ),
          if (!ok)
            SButton(
              label: fixLabel,
              variant: SButtonVariant.ghost,
              compact: true,
              onPressed: onFix,
            ),
        ],
      ),
    );
  }
}

/// Hue, saturation and lightness sliders plus the colour code, for one colour.
class _ColorControls extends StatefulWidget {
  const _ColorControls({
    required this.color,
    required this.hex,
    required this.hexLabel,
    required this.onChanged,
  });
  final Color color;
  final TextEditingController hex;
  final String hexLabel;
  final void Function(Color color, {bool fromField}) onChanged;

  @override
  State<_ColorControls> createState() => _ColorControlsState();
}

class _ColorControlsState extends State<_ColorControls> {
  // Hue and saturation are kept here, not read back from the colour: near white or black a colour
  // no longer says what its hue was, and the sliders would jump while the user drags lightness.
  late HSLColor _hsl = HSLColor.fromColor(widget.color);

  @override
  void didUpdateWidget(_ColorControls old) {
    super.didUpdateWidget(old);
    // A colour that came from outside (the code typed, the correction, undo) replaces the sliders.
    if (_hsl.toColor() != widget.color) {
      _hsl = HSLColor.fromColor(widget.color);
    }
  }

  void _set(HSLColor next) {
    setState(() => _hsl = next);
    widget.onChanged(next.toColor());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final hsl = _hsl;
    final color = widget.color;
    final hex = widget.hex;
    final hexLabel = widget.hexLabel;
    final onChanged = widget.onChanged;
    Widget slider(
      String label,
      double value,
      double max,
      String shown,
      ValueChanged<double> onValue,
    ) => Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: Type.rowMeta.copyWith(color: c.textMuted)),
        ),
        Expanded(
          // One control for a screen reader: its name and its value, in the unit shown.
          child: Semantics(
            container: true,
            label: label,
            child: Slider(
              value: value.clamp(0, max),
              max: max,
              semanticFormatterCallback: (_) => shown,
              onChanged: onValue,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            shown,
            textAlign: TextAlign.end,
            style: Type.rowMeta.copyWith(
              color: c.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Semantics(
              label: hexOf(color),
              image: true,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(Radii.sm),
                  border: Border.all(color: c.borderStrong),
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: STextField(
                controller: hex,
                semanticLabel: hexLabel,
                placeholder: '#0B5563',
                maxLength: 7,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                ],
                onChanged: (v) {
                  final parsed = parseHex(v);
                  if (parsed != null) onChanged(parsed, fromField: true);
                },
              ),
            ),
          ],
        ),
        slider(
          l.themeHue,
          hsl.hue,
          360,
          '${hsl.hue.round()}°',
          (v) => _set(hsl.withHue(v.clamp(0, 359.99))),
        ),
        slider(
          l.themeSaturation,
          hsl.saturation * 100,
          100,
          '${(hsl.saturation * 100).round()}%',
          (v) => _set(hsl.withSaturation(v / 100)),
        ),
        slider(
          l.themeLightness,
          hsl.lightness * 100,
          100,
          '${(hsl.lightness * 100).round()}%',
          (v) => _set(hsl.withLightness(v / 100)),
        ),
      ],
    );
  }
}

/// A small piece of the app drawn with the theme around it: the summary panel, a button, a chip, a
/// link and an amount of each sign. Used by the editor to show a palette before it is applied.
class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return Semantics(
      container: true,
      label: l.themePreview,
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: c.hero,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.themePreviewPanel,
                    style: Type.rowMeta.copyWith(color: c.onHeroMuted),
                  ),
                  Text(
                    formatBRL(123456),
                    style: Type.headline.copyWith(color: c.onHero),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xs),
            SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const IconTile(icon: SIconName.wallet),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          l.themePreviewRow,
                          style: Type.rowTitle.copyWith(color: c.text),
                        ),
                      ),
                      Text(
                        l.themePreviewLink,
                        style: Type.link.copyWith(color: c.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SChip(label: l.themePreviewChip, selected: true),
                      SIcon(SIconName.tag, size: 22, color: c.accent),
                      Text(
                        '+ ${formatBRL(25000)}',
                        style: Type.rowValue.copyWith(color: c.positive),
                      ),
                      Text(
                        '− ${formatBRL(8990)}',
                        style: Type.rowValue.copyWith(color: c.negative),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  SButton(label: l.themePreviewButton, onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
