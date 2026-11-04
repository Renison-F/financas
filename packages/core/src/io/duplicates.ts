import { diffDays } from '../dates/dates';
import type { Ledger, Transaction } from '../domain/types';
import type { ImportCandidate } from './csv';

const norm = (s: string) => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9 ]+/g, ' ').replace(/\s+/g, ' ').trim();

/** Jaccard similarity on word tokens */
export function textSimilarity(a: string, b: string): number {
  const A = new Set(norm(a).split(' ').filter(Boolean)), B = new Set(norm(b).split(' ').filter(Boolean));
  if (!A.size && !B.size) return 1;
  let inter = 0;
  for (const w of A) if (B.has(w)) inter++;
  return inter / (A.size + B.size - inter);
}

export interface DuplicateMatch { candidateIndex: number; existingId: string; reason: 'external_ref' | 'exact' | 'similar'; score: number; }

/**
 * Finds likely duplicates between import candidates and existing transactions:
 * same externalRef (certain); same date, amount and ≥0.6 description similarity (likely);
 * amount equal within ±2 days and ≥0.8 similarity (possible).
 */
export function findDuplicates(ledger: Ledger, candidates: ImportCandidate[], existing: Transaction[] = ledger.transactions): DuplicateMatch[] {
  const out: DuplicateMatch[] = [];
  const byRef = new Map<string, Transaction>();
  for (const t of existing) if (t.externalRef) byRef.set(t.externalRef, t);
  candidates.forEach((c, i) => {
    if (c.externalRef && byRef.has(c.externalRef)) { out.push({ candidateIndex: i, existingId: byRef.get(c.externalRef)!.id, reason: 'external_ref', score: 1 }); return; }
    if (c.problems.length) return;
    let best: DuplicateMatch | undefined;
    for (const t of existing) {
      if (t.deletedAt || t.amountCents !== c.amountCents) continue;
      const kindMatches = (c.kind === 'income') === (t.kind === 'income');
      if (!kindMatches) continue;
      const days = Math.abs(diffDays(t.date, c.date));
      if (days > 2) continue;
      const sim = textSimilarity(t.description, c.description);
      let m: DuplicateMatch | undefined;
      if (days === 0 && sim >= 0.6) m = { candidateIndex: i, existingId: t.id, reason: 'exact', score: 0.9 + sim / 10 };
      else if (sim >= 0.8) m = { candidateIndex: i, existingId: t.id, reason: 'similar', score: 0.7 + sim / 10 - days * 0.05 };
      if (m && (!best || m.score > best.score)) best = m;
    }
    if (best) out.push(best);
  });
  // also duplicates inside the batch itself
  const seen = new Map<string, number>();
  candidates.forEach((c, i) => {
    const key = `${c.date}|${c.amountCents}|${c.kind}|${norm(c.description)}`;
    const first = seen.get(key);
    if (first !== undefined && !out.some((m) => m.candidateIndex === i)) out.push({ candidateIndex: i, existingId: `batch:${first}`, reason: 'exact', score: 0.95 });
    else if (first === undefined) seen.set(key, i);
  });
  return out;
}
