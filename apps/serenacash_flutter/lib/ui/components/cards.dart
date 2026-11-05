import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Flat card: Branco over Névoa, 14 px radius, no shadow, no border (Regra do Plano).
class SCard extends StatelessWidget {
  const SCard({
    super.key,
    required this.child,
    this.inset = false,
    this.color,
    this.padding,
    this.onTap,
    this.semanticHint,
    this.radius,
  });
  final Widget child;
  final bool inset;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final String? semanticHint;

  /// Corner radius; defaults to 14 (10 when inset).
  final double? radius;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(
      this.radius ?? (inset ? Radii.sm : Radii.md),
    );
    final body = Padding(
      padding:
          padding ??
          (inset ? const EdgeInsets.all(Spacing.sm) : Layout.cardPadding),
      child: child,
    );
    final box = Material(
      color: color ?? (inset ? c.surfaceInset : c.surface),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
    return onTap == null
        ? box
        : Semantics(button: true, hint: semanticHint, child: box);
  }
}

/// Section title of a card, with an optional action or link on the right.
class CardHeader extends StatelessWidget {
  const CardHeader({super.key, required this.title, this.action, this.link});
  final String title;
  final Widget? action;

  /// Plain link text on the right (the card itself is the touch target).
  final String? link;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: action == null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: Type.title.copyWith(color: c.text),
              // Two lines keep the title readable at large text sizes next to the action.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?action,
          if (link != null)
            Padding(
              padding: const EdgeInsets.only(left: Spacing.xs, top: 2),
              child: Text(link!, style: Type.link.copyWith(color: c.primary)),
            ),
        ],
      ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.k, this.v, {super.key});
  final String k;
  final String v;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(k, style: Type.bodySmall.copyWith(color: c.textMuted)),
        ),
        Text(
          v,
          style: Type.bodySmall.copyWith(
            color: c.text,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
