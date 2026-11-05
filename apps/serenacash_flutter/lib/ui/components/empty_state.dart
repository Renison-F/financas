import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../icons.dart';
import 'buttons.dart';
import 'list_row.dart';

/// One-line empty state: icon, what is missing and one quiet action on the right. Used where several
/// empty sections would otherwise stack as tall onboarding cards.
class EmptyRow extends StatelessWidget {
  const EmptyRow({
    super.key,
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });
  final SIconName icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Touch.target),
      child: Row(
        children: [
          IconTile(icon: icon, color: c.textMuted, background: c.surfaceInset),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              title,
              style: Type.rowText.copyWith(color: c.text, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null && onAction != null)
            SButton(
              label: actionLabel!,
              variant: SButtonVariant.ghost,
              compact: true,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}

/// Empty state with a useful action (DESIGN.md: every widget has empty/loading/error states).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.text,
    this.actionLabel,
    this.onAction,
    this.compact = true,
  });
  final SIconName icon;
  final String title;
  final String? text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? Spacing.xs : Spacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(
                icon: icon,
                color: c.textMuted,
                background: c.surfaceInset,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Type.rowTitle.copyWith(color: c.text)),
                    if (text != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          text!,
                          style: Type.bodySmall.copyWith(color: c.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: SButton(
                label: actionLabel!,
                variant: SButtonVariant.secondary,
                compact: true,
                onPressed: onAction,
              ),
            ),
        ],
      ),
    );
  }
}
