import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/di.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

/// LGPD: what is collected (nothing leaves the device), export and full erasure.
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    Widget p(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: Type.body.copyWith(color: c.text)),
    );
    return StackScreen(
      title: l.privacyTitle,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.whatWeKeep),
              p(l.privacy1),
              p(l.privacy2),
              p(l.privacy3),
              p(l.privacy4),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.yourRights),
              SButton(
                label: l.exportAllData,
                variant: SButtonVariant.secondary,
                icon: SIconName.download,
                fullWidth: true,
                onPressed: () => context.push('/export'),
              ),
              const SizedBox(height: Spacing.xs),
              SButton(
                label: l.eraseAll,
                variant: SButtonVariant.destructive,
                icon: SIconName.trash,
                fullWidth: true,
                onPressed: () async {
                  final container = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );
                  final ok = await confirmSheet(
                    context,
                    title: l.eraseQ,
                    text: l.eraseText,
                    confirmLabel: l.eraseConfirm,
                    cancelLabel: l.cancel,
                  );
                  if (!ok) return;
                  // File, key and PIN go together: destroying only the key would leave an
                  // encrypted file that nothing can open on the next launch.
                  await eraseLocalData(container);
                  container.invalidate(appControllerProvider);
                  await container.read(appControllerProvider.future);
                  if (context.mounted) context.go('/onboarding');
                },
              ),
              const SizedBox(height: 6),
              Text(
                l.eraseHelp,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        Text(
          l.privacyPolicyNote,
          style: Type.caption.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final faq = [
      (l.faq1q, l.faq1a),
      (l.faq2q, l.faq2a),
      (l.faq3q, l.faq3a),
      (l.faq4q, l.faq4a),
      (l.faq5q, l.faq5a),
      (l.faq6q, l.faq6a),
      (l.faq7q, l.faq7a),
      (l.faq8q, l.faq8a),
      (l.faq9q, l.faq9a),
    ];
    return StackScreen(
      title: l.helpTitle,
      children: [
        for (final (q, a) in faq)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q, style: Type.title.copyWith(color: c.text)),
                const SizedBox(height: 6),
                Text(a, style: Type.body.copyWith(color: c.textMuted)),
              ],
            ),
          ),
      ],
    );
  }
}
