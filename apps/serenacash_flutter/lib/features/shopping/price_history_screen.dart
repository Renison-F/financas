/// Price history: what was paid for each product, purchase after purchase, by store.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/money/money.dart';
import '../../domain/reports/shares.dart';
import '../../domain/shopping/shopping.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

class PriceHistoryScreen extends ConsumerStatefulWidget {
  const PriceHistoryScreen({super.key});
  @override
  ConsumerState<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends ConsumerState<PriceHistoryScreen> {
  String _query = '';
  String? _open;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    String brl(int v) => formatBRL(v, hidden: hidden);
    final q = foldForSearch(_query.trim());
    final rows =
        [
          for (final p in s.products)
            if (q.isEmpty || foldForSearch(p.name).contains(q))
              (product: p, points: priceTimeline(s.observations, p.id)),
        ].where((r) => r.points.isNotEmpty).toList()..sort(
          (a, b) => b.points.last.observation.observedAt.compareTo(
            a.points.last.observation.observedAt,
          ),
        );
    String date(String iso) =>
        '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
    String unitOf(PriceObservation o) => units[o.unit]?.label ?? o.unit;
    String change(PricePoint p) {
      final d = p.changeCents;
      if (d == null) return l.priceFirst;
      if (d == 0) return l.priceSame;
      final pct = p.changePerMille;
      final pctText = pct == null
          ? ''
          : ' (${pct > 0 ? '+' : '−'}${perMilleLabel(pct.abs())}%)';
      return d > 0 ? l.priceUp(brl(d), pctText) : l.priceDown(brl(-d), pctText);
    }

    return StackScreen(
      title: l.priceHistoryTitle,
      children: [
        Text(
          l.priceHistoryIntro,
          style: Type.bodySmall.copyWith(color: c.textMuted),
        ),
        STextField(
          placeholder: l.priceHistorySearch,
          semanticLabel: l.priceHistorySearch,
          onChanged: (v) => setState(() => _query = v),
        ),
        if (rows.isEmpty)
          SCard(
            child: EmptyState(
              icon: SIconName.receipt,
              title: l.priceHistoryEmpty,
              text: l.priceHistoryEmptyText,
            ),
          )
        else
          for (final r in rows)
            Builder(
              builder: (context) {
                final last = r.points.last;
                final open = _open == r.product.id;
                final h = priceHistory(s.observations, r.product.id);
                return SCard(
                  padding: const EdgeInsets.all(Spacing.sm),
                  onTap: () =>
                      setState(() => _open = open ? null : r.product.id),
                  semanticHint: l.priceHistoryOpen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.product.name,
                                  style: Type.rowTitle.copyWith(color: c.text),
                                ),
                                Text(
                                  '${date(last.observation.observedAt)}${last.observation.store != null ? ' · ${last.observation.store}' : ''} · ${change(last)}',
                                  style: Type.rowMeta.copyWith(
                                    color: (last.changeCents ?? 0) > 0
                                        ? c.negative
                                        : c.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${brl(last.observation.unitPriceCents)}/${unitOf(last.observation)}',
                            style: Type.rowText.copyWith(
                              color: c.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (open) ...[
                        Divider(height: Spacing.md, color: c.border),
                        Text(
                          r.points.length < 2
                              ? l.priceOnePoint
                              : l.priceRange(
                                  brl(h.minCents ?? 0),
                                  brl(h.maxCents ?? 0),
                                  r.points.length,
                                ),
                          style: Type.caption.copyWith(color: c.textMuted),
                        ),
                        const SizedBox(height: 4),
                        for (final p in r.points.reversed)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${date(p.observation.observedAt)}${p.observation.store != null ? ' · ${p.observation.store}' : ''}${p.observation.promo == true ? ' · ${l.pricePromo}' : ''} · ${change(p)}',
                                    style: Type.rowMeta.copyWith(color: c.text),
                                  ),
                                ),
                                Text(
                                  '${brl(p.observation.unitPriceCents)}/${unitOf(p.observation)}',
                                  style: Type.rowMeta.copyWith(
                                    color: c.text,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (h.byStore.length > 1) ...[
                          const SizedBox(height: 4),
                          Text(
                            l.priceByStore(
                              h.byStore
                                  .map((x) => '${x.store} ${brl(x.lastCents)}')
                                  .join(' · '),
                            ),
                            style: Type.caption.copyWith(color: c.textMuted),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          l.priceNotInflation,
                          style: Type.caption.copyWith(color: c.textMuted),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }
}
