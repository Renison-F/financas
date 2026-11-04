/// Minimal OFX 1.x (SGML) / 2.x (XML) parser for bank and card statements. Mirrors `io/ofx.ts`.
library;

import '../dates/dates.dart';
import 'csv.dart';

class OFXTransaction {
  const OFXTransaction({
    required this.fitId,
    required this.date,
    required this.amountCents,
    required this.memo,
    required this.type,
  });
  final String fitId;
  final String date;
  final int amountCents;
  final String memo;
  final String type;
  Map<String, dynamic> toJson() => {
    'fitId': fitId,
    'date': date,
    'amountCents': amountCents,
    'memo': memo,
    'type': type,
  };
}

class OFXStatement {
  const OFXStatement({
    this.currency,
    this.accountId,
    this.bankId,
    required this.transactions,
    this.balanceCents,
    this.balanceDate,
  });
  final String? currency;
  final String? accountId;
  final String? bankId;
  final List<OFXTransaction> transactions;
  final int? balanceCents;
  final String? balanceDate;
  Map<String, dynamic> toJson() => {
    if (currency != null) 'currency': currency,
    if (accountId != null) 'accountId': accountId,
    if (bankId != null) 'bankId': bankId,
    'transactions': transactions.map((t) => t.toJson()).toList(),
    if (balanceCents != null) 'balanceCents': balanceCents,
    if (balanceDate != null) 'balanceDate': balanceDate,
  };
}

String? _tag(String block, String name) {
  final m = RegExp(
    '<$name>([^<\\r\\n]*)',
    caseSensitive: false,
  ).firstMatch(block);
  return m?.group(1)?.trim();
}

String? _date(String? raw) {
  if (raw == null) return null;
  final m = RegExp(r'^(\d{4})(\d{2})(\d{2})').firstMatch(raw);
  if (m == null) return null;
  final d = '${m[1]}-${m[2]}-${m[3]}';
  return isISODate(d) ? d : null;
}

int? _amount(String? raw) {
  if (raw == null) return null;
  final s = raw.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
  final n = double.tryParse(s);
  if (n == null || !n.isFinite) return null;
  return (n * 100 + (n >= 0 ? 0.5 : -0.5)).truncate(); // JS Math.round for half-away in both directions is close enough: see fixture
}

OFXStatement parseOFX(String text) {
  final body = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final blocks = RegExp(
    r'<STMTTRN>[\s\S]*?(?=</STMTTRN>|<STMTTRN>|</BANKTRANLIST>|</CCSTMTRS>|$)',
    caseSensitive: false,
  ).allMatches(body).map((m) => m.group(0)!);
  final txs = <OFXTransaction>[];
  for (final b in blocks) {
    final date = _date(_tag(b, 'DTPOSTED'));
    final amount = _amount(_tag(b, 'TRNAMT'));
    if (date == null || amount == null) continue;
    txs.add(
      OFXTransaction(
        fitId: _tag(b, 'FITID') ?? '',
        date: date,
        amountCents: amount,
        memo: _tag(b, 'MEMO') ?? _tag(b, 'NAME') ?? '',
        type: (_tag(b, 'TRNTYPE') ?? '').toUpperCase(),
      ),
    );
  }
  return OFXStatement(
    currency: _tag(body, 'CURDEF'),
    accountId: _tag(body, 'ACCTID'),
    bankId: _tag(body, 'BANKID'),
    transactions: txs,
    balanceCents: _amount(_tag(body, 'BALAMT')),
    balanceDate: _date(_tag(body, 'DTASOF')),
  );
}

List<ImportCandidate> candidatesFromOFX(OFXStatement stmt) => [
  for (var i = 0; i < stmt.transactions.length; i++)
    ImportCandidate(
      rowIndex: i,
      date: stmt.transactions[i].date,
      description: stmt.transactions[i].memo.length > 140
          ? stmt.transactions[i].memo.substring(0, 140)
          : stmt.transactions[i].memo,
      amountCents: stmt.transactions[i].amountCents.abs(),
      kind: stmt.transactions[i].amountCents < 0 ? 'expense' : 'income',
      externalRef: stmt.transactions[i].fitId.isNotEmpty
          ? 'ofx:${stmt.transactions[i].fitId}'
          : null,
      problems: const [],
    ),
];
