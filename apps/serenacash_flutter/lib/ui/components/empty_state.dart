import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../icons.dart';
import 'buttons.dart';

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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.surfaceInset,
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Center(child: SIcon(icon, size: 20, color: c.textMuted)),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Type.body.copyWith(
                        color: c.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
