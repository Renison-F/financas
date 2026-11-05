import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../icons.dart';

enum SButtonVariant { primary, secondary, ghost, destructive }

/// Buttons per DESIGN.md: 10 px radius, 48 px (44 ghost and compact), label 600/15.
class SButton extends StatelessWidget {
  const SButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SButtonVariant.primary,
    this.icon,
    this.compact = false,
    this.loading = false,
    this.fullWidth = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final SButtonVariant variant;
  final SIconName? icon;
  final bool compact;
  final bool loading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (variant) {
      SButtonVariant.primary => (c.primary, c.onPrimary),
      SButtonVariant.secondary => (c.primaryContainer, c.onPrimaryContainer),
      SButtonVariant.ghost => (Colors.transparent, c.primary),
      SButtonVariant.destructive => (c.negativeContainer, c.negative),
    };
    final height = variant == SButtonVariant.ghost || compact
        ? Touch.min
        : Touch.comfortable;
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                SIcon(icon!, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: (compact ? Type.link : Type.button).copyWith(
                    color: fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
    // Material replaces (not merges) the ambient text style inside buttons; keep the platform body family.
    final base = Theme.of(context).textTheme.labelLarge ?? const TextStyle();
    final style = ButtonStyle(
      textStyle: WidgetStatePropertyAll(
        base.merge(compact ? Type.link : Type.button),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.pressed) && variant == SButtonVariant.primary
            ? const Color(0xFF083E48)
            : bg,
      ),
      foregroundColor: WidgetStatePropertyAll(fg),
      overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.08)),
      minimumSize: WidgetStatePropertyAll(
        Size(fullWidth ? double.infinity : 0, height),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: compact ? 10 : 18),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
      ),
      elevation: const WidgetStatePropertyAll(0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return Opacity(
      opacity: onPressed == null && !loading ? 0.4 : 1,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: TextButton(
          onPressed: loading ? null : onPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

class SIconButton extends StatelessWidget {
  const SIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.size = 24,
  });
  final SIconName icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Opacity(
      opacity: onPressed == null ? 0.3 : 1,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        constraints: const BoxConstraints(
          minWidth: Touch.target,
          minHeight: Touch.target,
        ),
        icon: SIcon(icon, size: size, color: color ?? c.textMuted),
      ),
    );
  }
}
