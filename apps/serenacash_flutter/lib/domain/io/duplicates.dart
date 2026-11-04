/// Duplicate detection between import candidates and existing transactions. Mirrors `io/duplicates.ts`.
library;

import '../dates/dates.dart';
import '../entities/entities.dart';
import '../text/normalize.dart';
import 'csv.dart';

String _norm(String s) => normalizeText(s).replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

/// Jaccard similarity on word tokens.
double textSimilarity(String a, String b) {
  final sa = _norm(a).split(' ').where((w) => w.isNotEmpty).toSet();
  final sb = _norm(b).split(' ').where((w) => w.isNotEmpty).toSet();
  if (sa.isEmpty && sb.isEmpty) return 1;
  final inter = sa.intersection(sb).length;
  return inter / (sa.length + sb.length - inter);
}

class DuplicateMatch {
  const DuplicateMatch({required this.candidateIndex, required this.existingId, required this.reason, required this.score});
  final int candidateIndex;
  final String existingId;
  final String reason; // external_ref | exact | similar
  final double score;
  Map<String, dynamic> toJson() => {'candidateIndex': candidateIndex, 'existingId': existingId, 'reason': reason, 'score': score};
}

List<DuplicateMatch> findDuplicates(Ledger ledger, List<ImportCandidate> candidates, [List<Transaction>? existingList]) {
  final existing = existingList ?? ledger.transactions;
  final out = <DuplicateMatch>[];
  final byRef = {for (final t in existing) if (t.externalRef != null) t.externalRef!: t};
  for (var i = 0; i < candidates.length; i++) {
    final c = candidates[i];
    if (c.externalRef != null && byRef.containsKey(c.externalRef)) {
      out.add(DuplicateMatch(candidateIndex: i, existingId: byRef[c.externalRef]!.id, reason: 'external_ref', score: 1));
      continue;
    }
    if (c.problems.isNotEmpty) continue;
    DuplicateMatch? best;
    for (final t in existing) {
      if (t.deletedAt != null || t.amountCents != c.amountCents) continue;
      if ((c.kind == 'income') != (t.kind == TransactionKind.income)) continue;
      final days = diffDays(t.date, c.date).abs();
      if (days > 2) continue;
      final sim = textSimilarity(t.description, c.description);
      DuplicateMatch? m;
      if (days == 0 && sim >= 0.6) {
        m = DuplicateMatch(candidateIndex: i, existingId: t.id, reason: 'exact', score: 0.9 + sim / 10);
      } else if (sim >= 0.8) {
        m = DuplicateMatch(candidateIndex: i, existingId: t.id, reason: 'similar', score: 0.7 + sim / 10 - days * 0.05);
      }
      if (m != null && (best == null || m.score > best.score)) best = m;
    }
    if (best != null) out.add(best);
  }
  final seen = <String, int>{};
  for (var i = 0; i < candidates.length; i++) {
    final c = candidates[i];
    final key = '${c.date}|${c.amountCents}|${c.kind}|${_norm(c.description)}';
    final first = seen[key];
    if (first != null && !out.any((m) => m.candidateIndex == i)) {
      out.add(DuplicateMatch(candidateIndex: i, existingId: 'batch:$first', reason: 'exact', score: 0.95));
    } else {
      seen.putIfAbsent(key, () => i);
    }
  }
  return out;
}
