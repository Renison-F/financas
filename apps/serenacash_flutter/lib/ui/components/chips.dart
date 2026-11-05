import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../icons.dart';

/// Filter chip: Bruma/pill/36 px; selected = Sereno-claro + check. Filters are chips, actions never.
class SChip extends StatelessWidget {
  const SChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final SIconName? icon;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onPrimaryContainer : c.text;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.primaryContainer : c.surfaceInset,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          // Min height, not fixed: a long label wraps instead of overflowing on narrow phones.
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  SIcon(SIconName.check, size: 16, color: fg),
                  const SizedBox(width: 6),
                ] else if (icon != null) ...[
                  SIcon(icon!, size: 16, color: fg),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: Type.link.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChipSelect<T> extends StatelessWidget {
  const ChipSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.allowNone = false,
  });
  final List<(T, String)> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final bool allowNone;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final (v, l) in options)
        SChip(
          label: l,
          selected: v == value,
          onTap: () => onChanged(v == value && allowNone ? null : v),
        ),
    ],
  );
}

class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceInset,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          for (final (v, l) in options)
            Expanded(
              child: Semantics(
                selected: v == value,
                button: true,
                child: Material(
                  color: v == value ? c.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(Spacing.xs),
                  child: InkWell(
                    onTap: () => onChanged(v),
                    borderRadius: BorderRadius.circular(Spacing.xs),
                    child: SizedBox(
                      height: Touch.min - 4,
                      child: Center(
                        child: Text(
                          l,
                          style: Type.link.copyWith(
                            fontWeight: v == value
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: v == value ? c.primary : c.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
