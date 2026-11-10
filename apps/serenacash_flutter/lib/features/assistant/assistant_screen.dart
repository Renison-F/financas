import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/assistant/assistant.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

/// Deterministic assistant: answers computed from the user's data, each with its basis. No external AI.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});
  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _q = TextEditingController();
  final List<(String, Answer)> _history = [];

  void _ask(String text) {
    if (text.trim().isEmpty) return;
    final s = ref.read(appControllerProvider).requireValue;
    setState(() {
      _history.insert(0, (text, answer(s.ledger, text, s.today)));
      _q.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final recs = recommendations(s.ledger, s.today);
    final suggestions = [l.q1, l.q2, l.q3, l.q4, l.q5, l.q6, l.q7, l.q8];
    return StackScreen(
      title: l.assistant,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.assistantIntro,
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Spacing.sm),
              STextField(
                controller: _q,
                placeholder: l.askHint,
                semanticLabel: l.question,
                textInputAction: TextInputAction.send,
                onSubmitted: _ask,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: Spacing.sm),
              SButton(
                label: l.ask,
                fullWidth: true,
                onPressed: _q.text.trim().isEmpty ? null : () => _ask(_q.text),
              ),
              const SizedBox(height: Spacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final q in suggestions)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SChip(label: q, onTap: () => _ask(q)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final (q, a) in _history)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q, style: Type.label.copyWith(color: c.textMuted)),
                const SizedBox(height: 4),
                Text(a.title, style: Type.title.copyWith(color: c.text)),
                if (a.cents != null)
                  Money(
                    a.cents!,
                    role: MoneyRole.headline,
                    signed:
                        a.intent == 'can_afford' || a.intent == 'month_status',
                    hidden: hidden,
                  ),
                const SizedBox(height: 6),
                Text(a.text, style: Type.body.copyWith(color: c.text)),
                if (a.basis.isNotEmpty) ...[
                  Divider(height: Spacing.md, color: c.border),
                  Text(
                    l.calculationBasis,
                    style: Type.caption.copyWith(color: c.textMuted),
                  ),
                  for (final b in a.basis)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            b.detail == null
                                ? b.label
                                : '${b.label} · ${b.detail}',
                            style: Type.caption.copyWith(color: c.textMuted),
                          ),
                        ),
                        Money(
                          b.cents,
                          role: MoneyRole.bodySmall,
                          signed: true,
                          hidden: hidden,
                        ),
                      ],
                    ),
                ],
                if (a.route != null)
                  SButton(
                    label: l.open,
                    variant: SButtonVariant.ghost,
                    compact: true,
                    onPressed: () => context.push(a.route!),
                  ),
              ],
            ),
          ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.suggestionsForYou,
                style: Type.title.copyWith(color: c.text),
              ),
              const SizedBox(height: 6),
              if (recs.isEmpty)
                Text(
                  l.allCalmNoSuggestion,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final r in recs)
                  ListRow(
                    icon: r.severity == 'urgent'
                        ? SIconName.alert
                        : r.severity == 'attention'
                        ? SIconName.info
                        : SIconName.sparkle,
                    iconColor: r.severity == 'urgent'
                        ? c.negative
                        : r.severity == 'attention'
                        ? c.warning
                        : c.primary,
                    title: r.title,
                    description: r.text,
                    onTap: r.route == null
                        ? null
                        : () => context.push(r.route!),
                  ),
              const SizedBox(height: 8),
              Text(
                l.assistantRules,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
