/// CSV/OFX/backup import with preview, column mapping, duplicate detection and explicit confirmation.
/// Nothing is written before "Importar".
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/di.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../data/backup/backup_service.dart';
import '../../data/files/file_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/io/csv.dart';
import '../../domain/io/duplicates.dart';
import '../../domain/io/ofx.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

enum _Stage { pick, map, review, restore, done }

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});
  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  _Stage _stage = _Stage.pick;
  String _fileName = '';
  String _rawText = '';
  CSVTable? _table;
  ColumnMapping _mapping = const ColumnMapping();
  List<ImportCandidate> _candidates = const [];
  final Map<int, String> _dupes = {};
  final Set<int> _skip = {};
  String? _accountId;
  bool _categoryByName = true;
  String? _error;
  bool _encrypted = false;
  final _pass = TextEditingController();
  String _result = '';
  ImportReport? _report;

  Future<void> _pick() async {
    final l = context.l10n;
    setState(() => _error = null);
    try {
      final f = await ref.read(fileServiceProvider).pickTextFile();
      if (f == null) return;
      final trimmed = f.text.trimLeft();
      _fileName = f.name;
      _rawText = f.text;
      if (trimmed.startsWith('{')) {
        _encrypted = trimmed.contains('serenacash-backup-enc');
        setState(() => _stage = _Stage.restore);
        return;
      }
      if (RegExp(r'<OFX>|OFXHEADER', caseSensitive: false).hasMatch(trimmed)) {
        final access = ref.read(appControllerProvider).requireValue.access;
        if (!access.features.contains('ofx_import')) {
          if (mounted) unawaited(context.push('/paywall?feature=ofx_import'));
          return;
        }
        _finishCandidates(candidatesFromOFX(parseOFX(f.text)));
        return;
      }
      final t = parseCSV(f.text);
      setState(() {
        _table = t;
        _mapping = guessColumnMapping(t.headers);
        _stage = _Stage.map;
      });
    } catch (e) {
      setState(
        () => _error = e is FormatException ? e.message : l.fileReadError,
      );
    }
  }

  void _finishCandidates(List<ImportCandidate> cands) {
    final l = context.l10n;
    final ledger = ref.read(ledgerProvider);
    final d = findDuplicates(ledger, cands);
    setState(() {
      _candidates = cands;
      _dupes
        ..clear()
        ..addEntries(
          d.map(
            (m) => MapEntry(
              cands[m.candidateIndex].rowIndex,
              m.reason == 'external_ref'
                  ? l.alreadyImported
                  : m.reason == 'exact'
                  ? l.sameAsExisting
                  : l.similarToExisting,
            ),
          ),
        );
      _skip
        ..clear()
        ..addAll(d.map((m) => cands[m.candidateIndex].rowIndex))
        ..addAll(
          cands.where((x) => x.problems.isNotEmpty).map((x) => x.rowIndex),
        );
      _accountId ??= ledger.accounts.where((a) => a.isActive).firstOrNull?.id;
      _stage = _Stage.review;
    });
  }

  Future<void> _doImport() async {
    final l = context.l10n;
    final s = ref.read(appControllerProvider).requireValue;
    if (_accountId == null) {
      return setState(() => _error = l.chooseTargetAccount);
    }
    final ctl = ref.read(appControllerProvider.notifier);
    final now = ctl.nowISO();
    final list = <Transaction>[];
    for (final x in _candidates) {
      if (_skip.contains(x.rowIndex) || x.problems.isNotEmpty) continue;
      final cat = _categoryByName && x.categoryName != null
          ? s.ledger.categories
                .where(
                  (k) =>
                      k.name.toLowerCase() == x.categoryName!.toLowerCase() &&
                      k.kind == x.kind,
                )
                .firstOrNull
          : null;
      list.add(
        Transaction(
          id: ctl.newId(),
          kind: kindFromWire(x.kind),
          amountCents: x.amountCents,
          currency: s.ledger.prefs.currency,
          date: x.date,
          description: x.description,
          accountId: _accountId,
          categoryId: cat?.id,
          status: TransactionStatus.settled,
          notes: x.notes,
          externalRef:
              x.externalRef ??
              'import:$_fileName:${x.rowIndex}:${x.date}:${x.amountCents}',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    final n = await ctl.importTransactions(list);
    setState(() {
      _result = l.importResult(n, _candidates.length - n);
      _stage = _Stage.done;
    });
  }

  Future<void> _restore() async {
    final l = context.l10n;
    final ok = await confirmSheet(
      context,
      title: l.restoreQ,
      text: l.restoreText,
      confirmLabel: l.restore,
      cancelLabel: l.cancel,
    );
    if (!ok) return;
    final svc = await ref.read(backupServiceProvider.future);
    final report = await svc.importFromText(
      _rawText,
      passphrase: _encrypted ? _pass.text : null,
    );
    if (!mounted) return;
    if (report.ok) {
      await ref.read(appControllerProvider.notifier).reload();
      setState(() {
        _report = report;
        _result = l.restored;
        _stage = _Stage.done;
      });
    } else {
      setState(() => _error = report.errors.join(' '));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final cols = [
      for (var i = 0; i < (_table?.headers.length ?? 0); i++)
        (i, _table!.headers[i].isEmpty ? l.columnN(i + 1) : _table!.headers[i]),
    ];
    Widget mapField(
      String label,
      int? value,
      ColumnMapping Function(int?) set,
    ) => Field(
      label: label,
      child: ChipSelect<int>(
        options: cols,
        value: value,
        allowNone: true,
        onChanged: (v) => setState(() => _mapping = set(v)),
      ),
    );
    Widget err() => _error == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: Type.bodySmall.copyWith(color: c.negative),
            ),
          );
    return StackScreen(
      title: l.importTitle,
      children: [
        if (_stage == _Stage.pick)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.importIntroTitle,
                  style: Type.title.copyWith(color: c.text),
                ),
                const SizedBox(height: 6),
                Text(
                  l.importIntro,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Spacing.sm),
                SButton(
                  label: l.chooseFile,
                  icon: SIconName.upload,
                  fullWidth: true,
                  onPressed: _pick,
                ),
                err(),
              ],
            ),
          ),
        if (_stage == _Stage.map && _table != null)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardHeader(title: l.columnsOf(_fileName)),
                Text(
                  l.rowsCheck(_table!.rows.length),
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Spacing.sm),
                mapField(
                  l.date,
                  _mapping.date,
                  (v) => ColumnMapping(
                    date: v,
                    description: _mapping.description,
                    amount: _mapping.amount,
                    type: _mapping.type,
                    category: _mapping.category,
                    account: _mapping.account,
                    notes: _mapping.notes,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                mapField(
                  l.description,
                  _mapping.description,
                  (v) => ColumnMapping(
                    date: _mapping.date,
                    description: v,
                    amount: _mapping.amount,
                    type: _mapping.type,
                    category: _mapping.category,
                    account: _mapping.account,
                    notes: _mapping.notes,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                mapField(
                  l.amount,
                  _mapping.amount,
                  (v) => ColumnMapping(
                    date: _mapping.date,
                    description: _mapping.description,
                    amount: v,
                    type: _mapping.type,
                    category: _mapping.category,
                    account: _mapping.account,
                    notes: _mapping.notes,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                mapField(
                  l.typeColumn,
                  _mapping.type,
                  (v) => ColumnMapping(
                    date: _mapping.date,
                    description: _mapping.description,
                    amount: _mapping.amount,
                    type: v,
                    category: _mapping.category,
                    account: _mapping.account,
                    notes: _mapping.notes,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                mapField(
                  l.category,
                  _mapping.category,
                  (v) => ColumnMapping(
                    date: _mapping.date,
                    description: _mapping.description,
                    amount: _mapping.amount,
                    type: _mapping.type,
                    category: v,
                    account: _mapping.account,
                    notes: _mapping.notes,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                mapField(
                  l.notes,
                  _mapping.notes,
                  (v) => ColumnMapping(
                    date: _mapping.date,
                    description: _mapping.description,
                    amount: _mapping.amount,
                    type: _mapping.type,
                    category: _mapping.category,
                    account: _mapping.account,
                    notes: v,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.noTypeHelp,
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
                err(),
                const SizedBox(height: Spacing.sm),
                SButton(
                  label: l.reviewTransactions,
                  fullWidth: true,
                  onPressed: () {
                    if (_mapping.date == null || _mapping.amount == null) {
                      return setState(() => _error = l.chooseDateAmount);
                    }
                    _finishCandidates(candidatesFromCSV(_table!, _mapping));
                  },
                ),
              ],
            ),
          ),
        if (_stage == _Stage.restore)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardHeader(title: l.restoreBackup),
                Text(
                  _fileName,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
                if (_encrypted) ...[
                  const SizedBox(height: Spacing.sm),
                  SecretField(
                    label: l.backupPassphrase,
                    controller: _pass,
                    showLabel: l.showSecret,
                    hideLabel: l.hideSecret,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ],
                const SizedBox(height: Spacing.sm),
                Text(
                  l.restoreReplaces,
                  style: Type.bodySmall.copyWith(color: c.negative),
                ),
                const SizedBox(height: Spacing.sm),
                SButton(
                  label: l.replaceWithBackup,
                  variant: SButtonVariant.destructive,
                  fullWidth: true,
                  onPressed: _restore,
                ),
                err(),
              ],
            ),
          ),
        if (_stage == _Stage.review) ...[
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.foundTransactions(_candidates.length)),
                Text(
                  l.dupesInfo(
                    _dupes.length,
                    _candidates.where((x) => x.problems.isNotEmpty).length,
                  ),
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Spacing.sm),
                Field(
                  label: l.targetAccount,
                  child: ChipSelect<String>(
                    options: [
                      for (final a in s.ledger.accounts.where(
                        (a) => a.isActive,
                      ))
                        (a.id, a.name),
                    ],
                    value: _accountId,
                    onChanged: (v) => setState(() => _accountId = v),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                SChip(
                  label: l.categoriesByName,
                  selected: _categoryByName,
                  onTap: () =>
                      setState(() => _categoryByName = !_categoryByName),
                ),
              ],
            ),
          ),
          SCard(
            child: Column(
              children: [
                for (final x in _candidates)
                  Builder(
                    builder: (_) {
                      final off = _skip.contains(x.rowIndex);
                      final why = x.problems.firstOrNull ?? _dupes[x.rowIndex];
                      return Opacity(
                        opacity: off ? 0.55 : 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: c.border)),
                          ),
                          child: Row(
                            children: [
                              SChip(
                                label: off ? l.include : l.ok,
                                selected: !off,
                                onTap: () => setState(
                                  () => off
                                      ? _skip.remove(x.rowIndex)
                                      : _skip.add(x.rowIndex),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      x.description.isEmpty
                                          ? kindLabel(l, kindFromWire(x.kind))
                                          : x.description,
                                      style: Type.bodySmall.copyWith(
                                        color: c.text,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${dayMonth(x.date)}${x.categoryName != null ? ' · ${x.categoryName}' : ''}${why != null ? ' · $why' : ''}',
                                      style: Type.caption.copyWith(
                                        color:
                                            why != null && x.problems.isNotEmpty
                                            ? c.negative
                                            : c.textMuted,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Money(
                                x.kind == 'income'
                                    ? x.amountCents
                                    : -x.amountCents,
                                signed: true,
                                hidden: hidden,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          err(),
          SButton(
            label: l.importN(
              _candidates
                  .where(
                    (x) => !_skip.contains(x.rowIndex) && x.problems.isEmpty,
                  )
                  .length,
            ),
            fullWidth: true,
            onPressed: _doImport,
          ),
        ],
        if (_stage == _Stage.done)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardHeader(title: l.importDone),
                Text(_result, style: Type.body.copyWith(color: c.text)),
                if (_report != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _report!.counts.entries
                        .where((e) => e.value > 0)
                        .map((e) => importCountLabel(l, e.key, e.value))
                        .join(' · '),
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  ),
                  if (_report!.warnings.isNotEmpty)
                    Text(
                      l.warningsCount(
                        _report!.warnings.length,
                        _report!.warnings.take(3).join(' '),
                      ),
                      style: Type.bodySmall.copyWith(color: c.warning),
                    ),
                ],
                const SizedBox(height: Spacing.sm),
                SButton(
                  label: l.backToStart,
                  fullWidth: true,
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
