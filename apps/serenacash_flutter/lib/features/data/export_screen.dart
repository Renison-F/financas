import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../app/app.dart';
import '../../app/di.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../data/files/file_service.dart';
import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/io/csv.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../domain/reports/reports.dart';
import '../../ui/components/components.dart';
import '../cards/cards_screen.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});
  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _scope = 'month';
  String? _busy;
  String _msg = '';
  bool _encrypted = true;
  final _pass = TextEditingController();

  Future<void> _run(String key, Future<void> Function() fn) async {
    final l = context.l10n;
    setState(() {
      _busy = key;
      _msg = '';
    });
    try {
      await fn();
      setState(() => _msg = l.fileGenerated);
    } catch (e) {
      setState(
        () => _msg = e.toString().isEmpty ? l.exportFailed : e.toString(),
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  List<Transaction> _tx(Ledger ledger, String month) => _scope == 'month'
      ? searchTransactions(
          ledger,
          '',
          SearchFilters(from: '$month-01', to: endOfMonth(month)),
        )
      : searchTransactions(ledger, '');

  Future<List<int>> _pdf(
    Ledger ledger,
    String month,
    String today,
    List<Transaction> tx,
  ) async {
    final l = context.l10n;
    final t = monthTotals(ledger, month);
    final cats = expensesByCategory(ledger, month, rollUp: true);
    final doc = pw.Document(title: 'SerenaCash');
    final primary = PdfColor.fromHex('#0B5563');
    final muted = PdfColor.fromHex('#4F5E61');
    pw.Widget kv(String k, String v) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(k, style: pw.TextStyle(color: muted, fontSize: 10)),
        pw.Text(
          v,
          style: const pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Text(
            'SerenaCash',
            style: pw.TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '${_scope == 'month' ? l.reportOf(monthShortKey(month)) : l.fullReport} · ${l.generatedOn(today)}',
            style: pw.TextStyle(color: muted, fontSize: 10),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              kv(l.income, formatBRL(t.incomeSettled)),
              pw.SizedBox(width: 24),
              kv(l.expenses, formatBRL(t.expenseSettled)),
              pw.SizedBox(width: 24),
              kv(l.result, formatBRL(t.net)),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            l.byCategory,
            style: const pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.TableHelper.fromTextArray(
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(fontSize: 9, color: muted),
            headers: [l.category, l.amount, '%'],
            data: [
              for (final k in cats)
                [k.name, formatBRL(k.cents), '${k.percent.round()}%'],
            ],
            cellAlignments: {
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            l.tabTransactions,
            style: const pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.TableHelper.fromTextArray(
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(fontSize: 9, color: muted),
            headers: [l.date, l.description, l.category, l.amount],
            data: [
              for (final x in tx)
                [
                  dayMonth(x.date),
                  x.description.isEmpty ? kindLabel(l, x.kind) : x.description,
                  ledger.categoryById(x.categoryId)?.name ?? '',
                  '${x.kind == TransactionKind.income ? '' : '−'}${formatBRL(x.amountCents)}',
                ],
            ],
            cellAlignments: {3: pw.Alignment.centerRight},
          ),
          pw.SizedBox(height: 12),
          pw.Text(l.pdfFooter, style: pw.TextStyle(color: muted, fontSize: 8)),
        ],
      ),
    );
    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final month = monthKeyOf(s.today);
    final tx = _tx(s.ledger, month);
    final files = ref.read(fileServiceProvider);
    return StackScreen(
      title: l.exportTitle,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.tabTransactions),
              Wrap(
                spacing: 8,
                children: [
                  SChip(
                    label: l.thisMonth,
                    selected: _scope == 'month',
                    onTap: () => setState(() => _scope = 'month'),
                  ),
                  SChip(
                    label: l.allScope,
                    selected: _scope == 'all',
                    onTap: () => setState(() => _scope = 'all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.transactionsCount(tx.length),
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Spacing.sm),
              SButton(
                label: l.csvSheet,
                icon: SIconName.download,
                variant: SButtonVariant.secondary,
                fullWidth: true,
                loading: _busy == 'csv',
                onPressed: () => _run(
                  'csv',
                  () => files.shareText(
                    'serenacash-${_scope == 'month' ? month : 'tudo'}.csv',
                    exportTransactionsCSV(s.ledger, tx),
                    'text/csv',
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              SButton(
                label: l.pdfReport,
                icon: SIconName.download,
                variant: SButtonVariant.secondary,
                fullWidth: true,
                loading: _busy == 'pdf',
                onPressed: () => s.access.features.contains('pdf_export')
                    ? _run(
                        'pdf',
                        () async => files.sharePdf(
                          'serenacash-${_scope == 'month' ? month : 'completo'}.pdf',
                          await _pdf(s.ledger, month, s.today, tx),
                        ),
                      )
                    : context.push('/paywall?feature=pdf_export'),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.fullBackup),
              Text(
                l.backupHelp,
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SChip(
                    label: l.encryptedBackup,
                    selected: _encrypted,
                    icon: SIconName.lock,
                    onTap: () => setState(() => _encrypted = true),
                  ),
                  SChip(
                    label: l.plainBackup,
                    selected: !_encrypted,
                    onTap: () => setState(() => _encrypted = false),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              if (_encrypted)
                SecretField(
                  label: l.backupPassphrase,
                  controller: _pass,
                  showLabel: l.showSecret,
                  hideLabel: l.hideSecret,
                  keyboardType: TextInputType.visiblePassword,
                  placeholder: l.passphraseMin,
                  onChanged: (_) => setState(() {}),
                )
              else
                Text(
                  l.plainWarning,
                  style: Type.bodySmall.copyWith(color: c.warning),
                ),
              const SizedBox(height: Spacing.sm),
              SButton(
                label: l.fullBackup,
                icon: SIconName.download,
                fullWidth: true,
                loading: _busy == 'bk',
                onPressed: _encrypted && _pass.text.length < 8
                    ? null
                    : () => _run('bk', () async {
                        final svc = await ref.read(
                          backupServiceProvider.future,
                        );
                        if (_encrypted) {
                          await files.shareText(
                            'serenacash-backup-${s.today}.scbk',
                            await svc.exportEncrypted(_pass.text),
                            'application/json',
                          );
                        } else {
                          await files.shareText(
                            'serenacash-backup-${s.today}.json',
                            await svc.exportPlainJson(),
                            'application/json',
                          );
                        }
                      }),
              ),
              if (_msg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _msg,
                    style: Type.bodySmall.copyWith(
                      color: _msg == l.fileGenerated ? c.positive : c.negative,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
