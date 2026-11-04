import 'package:flutter/material.dart';

import '../../ui/components/components.dart';

/// Stacked (non-tab) screen: compact title with system back.
class StackScreen extends StatelessWidget {
  const StackScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.children,
    this.fab,
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;
  final Widget? fab;
  @override
  Widget build(BuildContext context) => SScreen(
    title: title,
    subtitle: subtitle,
    actions: actions,
    showBack: true,
    compactTitle: true,
    fab: fab,
    bottomPadding: 48,
    children: children,
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}
