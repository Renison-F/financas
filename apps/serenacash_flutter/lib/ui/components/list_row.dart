import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../icons.dart';

/// Dense list row (56 px): icon, title, description, trailing value, optional chevron.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.trailing,
    this.onTap,
    this.chevron = false,
    this.leading,
    this.descriptionWidget,
  });
  final SIconName? icon;
  final Color? iconColor;
  final String title;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;
  final Widget? leading;

  /// Shown under the title instead of [description] (a badge, for example).
  final Widget? descriptionWidget;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LayoutBuilder(
          builder: (context, box) => Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: Spacing.sm),
              ] else if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.surfaceInset,
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Center(
                    child: SIcon(
                      icon!,
                      size: 20,
                      color: iconColor ?? c.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Type.body.copyWith(color: c.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (descriptionWidget != null)
                      descriptionWidget!
                    else if (description != null)
                      Text(
                        description!,
                        style: Type.bodySmall.copyWith(color: c.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: Spacing.xs),
                // A very large amount (or large text) scales down instead of pushing the title out.
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: box.maxWidth * 0.5),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: trailing!,
                  ),
                ),
              ],
              if (chevron) ...[
                const SizedBox(width: 4),
                SIcon(SIconName.chevronRight, size: 20, color: c.borderStrong),
              ],
            ],
          ),
        ),
      ),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: row,
      ),
    );
  }
}
