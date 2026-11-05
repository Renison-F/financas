import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../icons.dart';

/// Dense list row (48 px): tinted icon tile, title, a line underneath, trailing value, optional chevron.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    this.icon,
    this.iconColor,
    this.tileColor,
    required this.title,
    this.description,
    this.trailing,
    this.onTap,
    this.chevron = false,
    this.leading,
    this.descriptionWidget,
    this.titleMaxLines = 1,
  });
  final SIconName? icon;
  final Color? iconColor;
  final Color? tileColor;
  final String title;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;
  final Widget? leading;

  /// Shown under the title instead of [description] (a badge, for example).
  final Widget? descriptionWidget;
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Touch.target),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: LayoutBuilder(
          builder: (context, box) => Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: Spacing.sm),
              ] else if (icon != null) ...[
                IconTile(icon: icon!, color: iconColor, background: tileColor),
                const SizedBox(width: Spacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Type.rowTitle.copyWith(color: c.text),
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (descriptionWidget != null)
                      descriptionWidget!
                    else if (description != null)
                      Text(
                        description!,
                        style: Type.rowMeta.copyWith(color: c.textMuted),
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
                SIcon(SIconName.chevronRight, size: 18, color: c.borderStrong),
              ],
            ],
          ),
        ),
      ),
    );
    if (onTap == null) return row;
    // A tappable row is always its own accessibility node: when it is the only row of a card it would
    // otherwise be absorbed by the card's text and be activated in the middle of the card.
    return Semantics(
      container: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.sm),
          child: row,
        ),
      ),
    );
  }
}

/// Tinted rounded square with an icon: the leading mark of rows, pickers and empty states.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.color,
    this.background,
    this.size = Layout.tile,
  });
  final SIconName icon;
  final Color? color;
  final Color? background;
  final double size;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? c.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(
        child: SIcon(icon, size: size * 0.56, color: color ?? c.primary),
      ),
    );
  }
}

/// Hairline between rows and blocks of a card.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: context.colors.surfaceInset);
}

/// [rows] with a hairline between each pair.
List<Widget> dividedRows(List<Widget> rows) => [
  for (var i = 0; i < rows.length; i++) ...[
    if (i > 0) const RowDivider(),
    rows[i],
  ],
];
