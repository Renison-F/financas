/// Dashboard customization: presets, show/hide, reorder (drag or accessible buttons), period, accounts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/dashboard/widgets.dart' as dash;
import '../../ui/components/components.dart';

class CustomizeScreen extends ConsumerStatefulWidget {
  const CustomizeScreen({super.key});
  @override
  ConsumerState<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends ConsumerState<CustomizeScreen> {
  late dash.DashboardLayout _layout = ref
      .read(appControllerProvider)
      .requireValue
      .layout;

  void _toggleSize(String id) => setState(
    () => _layout = dash.setWidgetCompact(
      _layout,
      id,
      !_layout.compact.contains(id),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final accounts = ref
        .watch(ledgerProvider)
        .accounts
        .where((a) => !a.archived)
        .toList();
    final hidden = dash.hiddenWidgets(_layout);
    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Type.label.copyWith(color: c.textMuted)),
        const SizedBox(height: 8),
        child,
      ],
    );
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            SheetHeader(
              title: l.customizeTitle,
              leading: SButton(
                label: l.cancel,
                variant: SButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
              ),
              trailing: SButton(
                label: l.save,
                variant: SButtonVariant.ghost,
                onPressed: () async {
                  await ref
                      .read(appControllerProvider.notifier)
                      .setLayout(_layout);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  0,
                  Spacing.md,
                  Spacing.xxl,
                ),
                children: [
                  section(
                    l.presets,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in dash.presets.entries)
                          SChip(
                            label: e.value.title,
                            onTap: () => setState(
                              () => _layout = dash.applyPreset(_layout, e.key),
                            ),
                          ),
                        SChip(
                          label: l.restoreDefault,
                          onTap: () => setState(
                            () => _layout = homeDefaultLayout.copyWith(
                              privacyMode: _layout.privacyMode,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  section(
                    l.visibleWidgets,
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      onReorderItem: (from, to) => setState(
                        () => _layout = dash.moveWidget(
                          _layout,
                          _layout.order[from],
                          to,
                        ),
                      ),
                      children: [
                        for (var i = 0; i < _layout.order.length; i++)
                          Padding(
                            key: ValueKey(_layout.order[i]),
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SCard(
                              padding: const EdgeInsets.all(Spacing.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ReorderableDragStartListener(
                                        index: i,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: Spacing.xs,
                                          ),
                                          child: SIcon(
                                            SIconName.drag,
                                            color: c.borderStrong,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          dash
                                              .widgetById(_layout.order[i])
                                              .title,
                                          style: Type.body.copyWith(
                                            color: c.text,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SIconButton(
                                        icon: SIconName.chevronUp,
                                        label: l.moveUp(
                                          dash
                                              .widgetById(_layout.order[i])
                                              .title,
                                        ),
                                        color: c.primary,
                                        size: 20,
                                        onPressed: i == 0
                                            ? null
                                            : () => setState(
                                                () =>
                                                    _layout = dash.moveWidgetBy(
                                                      _layout,
                                                      _layout.order[i],
                                                      -1,
                                                    ),
                                              ),
                                      ),
                                      SIconButton(
                                        icon: SIconName.chevronDown,
                                        label: l.moveDown(
                                          dash
                                              .widgetById(_layout.order[i])
                                              .title,
                                        ),
                                        color: c.primary,
                                        size: 20,
                                        onPressed: i == _layout.order.length - 1
                                            ? null
                                            : () => setState(
                                                () =>
                                                    _layout = dash.moveWidgetBy(
                                                      _layout,
                                                      _layout.order[i],
                                                      1,
                                                    ),
                                              ),
                                      ),
                                      SIconButton(
                                        icon: SIconName.eyeOff,
                                        label: l.hideWidget(
                                          dash
                                              .widgetById(_layout.order[i])
                                              .title,
                                        ),
                                        color: c.primary,
                                        size: 20,
                                        onPressed: () => setState(
                                          () => _layout = dash.hideWidget(
                                            _layout,
                                            _layout.order[i],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // The size of the card: full, or reduced to one line.
                                  Semantics(
                                    container: true,
                                    button: true,
                                    excludeSemantics: true,
                                    label:
                                        _layout.compact.contains(
                                          _layout.order[i],
                                        )
                                        ? l.widgetExpand(
                                            dash
                                                .widgetById(_layout.order[i])
                                                .title,
                                          )
                                        : l.widgetCompact(
                                            dash
                                                .widgetById(_layout.order[i])
                                                .title,
                                          ),
                                    onTap: () => _toggleSize(_layout.order[i]),
                                    child: SChip(
                                      label: l.widgetSizeReduced,
                                      selected: _layout.compact.contains(
                                        _layout.order[i],
                                      ),
                                      onTap: () =>
                                          _toggleSize(_layout.order[i]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hidden.isNotEmpty) ...[
                    const SizedBox(height: Spacing.md),
                    section(
                      l.hiddenWidgets,
                      Column(
                        children: [
                          for (final id in hidden)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SCard(
                                padding: const EdgeInsets.all(Spacing.sm),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dash.widgetById(id).title,
                                            style: Type.body.copyWith(
                                              color: c.text,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            dash.widgetById(id).description,
                                            style: Type.caption.copyWith(
                                              color: c.textMuted,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SIconButton(
                                      icon: SIconName.plus,
                                      label: l.showWidget(
                                        dash.widgetById(id).title,
                                      ),
                                      color: c.primary,
                                      size: 20,
                                      onPressed: () => setState(
                                        () => _layout = dash.showWidget(
                                          _layout,
                                          id,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.lg),
                  section(
                    l.indicatorsPeriod,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SChip(
                          label: l.currentMonth,
                          selected: _layout.period == 'current_month',
                          onTap: () => setState(
                            () => _layout = _layout.copyWith(
                              period: 'current_month',
                            ),
                          ),
                        ),
                        SChip(
                          label: l.next30days,
                          selected: _layout.period == 'last_30_days',
                          onTap: () => setState(
                            () => _layout = _layout.copyWith(
                              period: 'last_30_days',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (accounts.length > 1) ...[
                    const SizedBox(height: Spacing.lg),
                    section(
                      l.accountsConsidered,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SChip(
                            label: l.all,
                            selected: _layout.accountIds == null,
                            onTap: () => setState(
                              () => _layout = _layout.copyWith(
                                clearAccounts: true,
                              ),
                            ),
                          ),
                          for (final a in accounts)
                            SChip(
                              label: a.name,
                              selected:
                                  _layout.accountIds?.contains(a.id) ?? false,
                              onTap: () => setState(() {
                                final cur =
                                    _layout.accountIds ??
                                    accounts.map((x) => x.id).toList();
                                final sel = cur.contains(a.id);
                                final next = sel
                                    ? cur.where((x) => x != a.id).toList()
                                    : [...cur, a.id];
                                _layout = next.length == accounts.length
                                    ? _layout.copyWith(clearAccounts: true)
                                    : _layout.copyWith(accountIds: next);
                              }),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
