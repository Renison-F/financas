import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../icons.dart';

/// Scrollable screen with headline title, optional subtitle and header actions; max width 600 on tablets.
class SScreen extends StatelessWidget {
  const SScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.children,
    this.fab,
    this.showBack = false,
    this.bottomPadding = 120,
    this.compactTitle = false,
    this.header,
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;
  final Widget? fab;
  final bool showBack;
  final double bottomPadding;
  final bool compactTitle;

  /// Replaces the title/subtitle block (the header actions stay on the right).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final width = MediaQuery.sizeOf(context).width;
    final gutter = width >= 400 ? 20.0 : 16.0;
    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: fab,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    gutter,
                    Spacing.sm,
                    gutter,
                    Spacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showBack)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              tooltip: MaterialLocalizations.of(context)
                                  .backButtonTooltip,
                              icon: SIcon(
                                SIconName.chevronLeft,
                                color: c.primary,
                              ),
                            ),
                          ),
                        Expanded(
                          child:
                              header ??
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style:
                                        (compactTitle
                                                ? Type.title
                                                : Type.headline)
                                            .copyWith(color: c.text),
                                    maxLines: 2,
                                  ),
                                  if (subtitle != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        subtitle!,
                                        style: Type.bodySmall.copyWith(
                                          color: c.textMuted,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                        ),
                        ...actions,
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    gutter,
                    0,
                    gutter,
                    bottomPadding,
                  ),
                  sliver: SliverList.list(
                    children: [
                      for (var i = 0; i < children.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == children.length - 1 ? 0 : Spacing.sm,
                          ),
                          child: children[i],
                        ),
                    ],
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

/// Modal-style header: Cancel · Title · Save.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    required this.leading,
    this.trailing,
  });
  final String title;
  final Widget leading;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.xs,
      vertical: Spacing.xs,
    ),
    // The side actions keep their natural width (a fixed slot cut "Cancelar" short) and the title
    // takes what is left, centered when it fits.
    // The toolbar fills the height it is given, so the row height follows the text scale.
    child: SizedBox(
      height: MediaQuery.textScalerOf(context).scale(20) + 36,
      child: NavigationToolbar(
        leading: leading,
        middle: Text(
          title,
          style: Type.title.copyWith(fontSize: 17, color: context.colors.text),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing,
        middleSpacing: Spacing.xs,
      ),
    ),
  );
}

class AddFab extends StatelessWidget {
  const AddFab({super.key, required this.onPressed, required this.label});
  final VoidCallback onPressed;
  final String label;
  @override
  Widget build(BuildContext context) => FloatingActionButton(
    heroTag: null,
    onPressed: onPressed,
    tooltip: label,
    child: SIcon(SIconName.plus, size: 28, color: context.colors.onPrimary),
  );
}
