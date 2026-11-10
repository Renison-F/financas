import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Opens a bottom sheet whose content never sits behind the system navigation bar or the keyboard.
///
/// Flutter's modal sheet leaves the bottom inset to its content (`useSafeArea` only covers the top
/// and the sides), and without `isScrollControlled` it caps the sheet at 9/16 of the screen and
/// clips what does not fit. Every sheet in the app goes through here so that neither can hide an
/// option again.
Future<T?> showSSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool useRootNavigator = false,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: useRootNavigator,
  isScrollControlled: true,
  useSafeArea: true,
  // With reduced motion the sheet appears in place instead of sliding up.
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : null,
  builder: (ctx) => SheetInsets(child: Builder(builder: builder)),
);

/// Pads its child by whatever covers the bottom of the screen (three-button bar, gesture handle or
/// keyboard) and hands the child a [MediaQuery] with that inset already consumed, so content that
/// adds its own bottom inset does not add it twice.
class SheetInsets extends StatelessWidget {
  const SheetInsets({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottom = math.max(mq.viewInsets.bottom, mq.viewPadding.bottom);
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: MediaQuery.removeViewPadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
      ),
    );
  }
}
