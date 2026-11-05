import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/tokens.dart';
import '../../domain/dates/dates.dart';
import '../../domain/money/money.dart';
import '../icons.dart';
import 'buttons.dart';
import 'chips.dart';

class Field extends StatelessWidget {
  const Field({super.key, required this.label, required this.child, this.help});
  final String label;
  final Widget child;
  final String? help;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Type.label.copyWith(color: c.textMuted)),
        const SizedBox(height: 6),
        child,
        if (help != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              help!,
              style: Type.caption.copyWith(color: c.textMuted),
            ),
          ),
      ],
    );
  }
}

class STextField extends StatelessWidget {
  const STextField({
    super.key,
    this.label,
    this.controller,
    this.onChanged,
    this.placeholder,
    this.keyboardType,
    this.maxLength,
    this.error,
    this.autofocus = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
    this.onSubmitted,
    this.prefixText,
    this.semanticLabel,
    this.enabled = true,
    this.obscureText = false,
    this.suffix,
  });
  final String? label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? error;
  final bool autofocus;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? prefixText;
  final String? semanticLabel;
  final bool enabled;
  final bool obscureText;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final field = TextField(
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLength: maxLength,
      autofocus: autofocus,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      enabled: enabled,
      style: Type.body.copyWith(color: c.text),
      decoration: InputDecoration(
        hintText: placeholder,
        errorText: error,
        counterText: '',
        prefixText: prefixText,
        prefixStyle: Type.body.copyWith(color: c.textMuted),
        suffixIcon: suffix,
        constraints: BoxConstraints(
          minHeight: maxLines == 1 ? Touch.comfortable : 0,
        ),
      ),
    );
    final wrapped = Semantics(
      label: semanticLabel ?? label,
      textField: true,
      child: field,
    );
    return label == null ? wrapped : Field(label: label!, child: wrapped);
  }
}

/// Text field for a PIN or a passphrase: hidden by default, with a show/hide button so a typo in a
/// backup passphrase can still be caught before it locks the file.
class SecretField extends StatefulWidget {
  const SecretField({
    super.key,
    required this.label,
    required this.controller,
    required this.showLabel,
    required this.hideLabel,
    this.placeholder,
    this.keyboardType,
    this.maxLength,
    this.autofocus = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });
  final String label;
  final TextEditingController controller;
  final String showLabel;
  final String hideLabel;
  final String? placeholder;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  @override
  State<SecretField> createState() => _SecretFieldState();
}

class _SecretFieldState extends State<SecretField> {
  bool _hidden = true;
  @override
  Widget build(BuildContext context) => STextField(
    label: widget.label,
    controller: widget.controller,
    placeholder: widget.placeholder,
    keyboardType: widget.keyboardType,
    maxLength: widget.maxLength,
    autofocus: widget.autofocus,
    textInputAction: widget.textInputAction,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
    obscureText: _hidden,
    suffix: IconButton(
      tooltip: _hidden ? widget.showLabel : widget.hideLabel,
      onPressed: () => setState(() => _hidden = !_hidden),
      icon: SIcon(
        _hidden ? SIconName.eye : SIconName.eyeOff,
        color: context.colors.textMuted,
      ),
    ),
  );
}

/// Money input: numeric keyboard, pt-BR mask, cents always visible, "R$" prefix in Cinza-mar.
class MoneyField extends StatefulWidget {
  const MoneyField({
    super.key,
    required this.label,
    required this.cents,
    required this.onChanged,
    this.autofocus = false,
    this.error,
    this.help,
  });
  final String label;
  final int? cents;
  final ValueChanged<int?> onChanged;
  final bool autofocus;
  final String? error;
  final String? help;
  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  late final TextEditingController _c = TextEditingController(
    text: widget.cents == null ? '' : _fmt(widget.cents!),
  );
  static String _fmt(int cents) =>
      formatBRL(cents).replaceAll(RegExp(r'^R\$\s?'), '').replaceAll(' ', '');
  @override
  void didUpdateWidget(MoneyField old) {
    super.didUpdateWidget(old);
    if (widget.cents != old.cents) {
      final current = _parse(_c.text);
      if (current != widget.cents) {
        _c.text = widget.cents == null ? '' : _fmt(widget.cents!);
      }
    }
  }

  int? _parse(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return int.parse(digits);
  }

  @override
  Widget build(BuildContext context) {
    return STextField(
      label: widget.label,
      controller: _c,
      autofocus: widget.autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      prefixText: 'R\$ ',
      placeholder: '0,00',
      error: widget.error,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CentsFormatter(),
      ],
      onChanged: (v) => widget.onChanged(_parse(v)),
      semanticLabel: '${widget.label}, em reais',
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}

/// Keeps the text as a pt-BR money mask while the user types digits (cents enter from the right).
class _CentsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final cents = int.parse(
      digits.length > 15 ? digits.substring(digits.length - 15) : digits,
    );
    final text = _MoneyFieldState._fmt(cents);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String fmtDateBR(String iso) =>
    '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';

/// Dependency-free date field: quick chips (today, yesterday, tomorrow) + typed dd/mm/aaaa.
class DateField extends StatefulWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.today,
    required this.todayLabel,
    required this.yesterdayLabel,
    required this.tomorrowLabel,
    required this.invalidLabel,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String today;
  final String todayLabel, yesterdayLabel, tomorrowLabel, invalidLabel;
  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late final TextEditingController _c = TextEditingController(
    text: fmtDateBR(widget.value),
  );
  String? _err;
  void _set(String iso) {
    widget.onChanged(iso);
    _c.text = fmtDateBR(iso);
    setState(() => _err = null);
  }

  void _typed(String t) {
    final digits = t.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 8) {
      final iso =
          '${digits.substring(4, 8)}-${digits.substring(2, 4)}-${digits.substring(0, 2)}';
      if (isISODate(iso)) {
        setState(() => _err = null);
        widget.onChanged(iso);
        return;
      }
    }
    setState(() => _err = digits.length >= 8 ? widget.invalidLabel : null);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.today;
    return Field(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SChip(
                label: widget.todayLabel,
                selected: widget.value == t,
                onTap: () => _set(t),
              ),
              SChip(
                label: widget.yesterdayLabel,
                selected: widget.value == addDays(t, -1),
                onTap: () => _set(addDays(t, -1)),
              ),
              SChip(
                label: widget.tomorrowLabel,
                selected: widget.value == addDays(t, 1),
                onTap: () => _set(addDays(t, 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          STextField(
            controller: _c,
            onChanged: _typed,
            placeholder: 'dd/mm/aaaa',
            keyboardType: TextInputType.number,
            maxLength: 10,
            error: _err,
            semanticLabel: widget.label,
            inputFormatters: [_DateMaskFormatter()],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}

class _DateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = newValue.text.replaceAll(RegExp(r'\D'), '');
    final b = StringBuffer();
    for (var i = 0; i < d.length && i < 8; i++) {
      if (i == 2 || i == 4) b.write('/');
      b.write(d[i]);
    }
    final s = b.toString();
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.help,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? help;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Touch.min),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Type.body.copyWith(color: c.text)),
                    if (help != null)
                      Text(
                        help!,
                        style: Type.caption.copyWith(color: c.textMuted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Switch.adaptive(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class Collapsible extends StatefulWidget {
  const Collapsible({
    super.key,
    required this.title,
    required this.children,
    this.initiallyOpen = false,
  });
  final String title;
  final List<Widget> children;
  final bool initiallyOpen;
  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  late bool _open = widget.initiallyOpen;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            onTap: () => setState(() => _open = !_open),
            child: SizedBox(
              height: Touch.min,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: Type.label.copyWith(color: c.primary, fontSize: 15),
                  ),
                  SIcon(
                    _open ? SIconName.chevronUp : SIconName.chevronDown,
                    size: 20,
                    color: c.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: Motion.base,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final w in widget.children)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.md),
                          child: w,
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Confirmation sheet for destructive actions (never a bare system alert).
Future<bool> confirmSheet(
  BuildContext context, {
  required String title,
  required String text,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = true,
}) async {
  final c = context.colors;
  final r = await showModalBottomSheet<bool>(
    context: context,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.xs,
        Spacing.lg,
        Spacing.lg + MediaQuery.paddingOf(ctx).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Type.title.copyWith(color: c.text)),
          const SizedBox(height: Spacing.sm),
          Text(text, style: Type.body.copyWith(color: c.textMuted)),
          const SizedBox(height: Spacing.md),
          SButton(
            label: confirmLabel,
            variant: destructive
                ? SButtonVariant.destructive
                : SButtonVariant.primary,
            fullWidth: true,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
          const SizedBox(height: Spacing.xs),
          SButton(
            label: cancelLabel,
            variant: SButtonVariant.ghost,
            fullWidth: true,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    ),
  );
  return r ?? false;
}
