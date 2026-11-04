import type { ImportCandidate } from './csv';
import { isISODate } from '../dates/dates';

/**
 * Minimal OFX 1.x (SGML) / 2.x (XML) parser for bank statements (STMTTRN) and credit card statements.
 * Extracts DTPOSTED, TRNAMT, MEMO/NAME, FITID, TRNTYPE. Tolerates unclosed SGML tags.
 */
export interface OFXTransaction { fitId: string; date: string; amountCents: number; memo: string; type: string; }
export interface OFXStatement { currency?: string | undefined; accountId?: string | undefined; bankId?: string | undefined; transactions: OFXTransaction[]; balanceCents?: number | undefined; balanceDate?: string | undefined; }

function tag(block: string, name: string): string | undefined {
  const m = block.match(new RegExp(`<${name}>([^<\\r\\n]*)`, 'i'));
  return m?.[1]?.trim();
}

function ofxDate(raw: string | undefined): string | undefined {
  if (!raw) return undefined;
  const m = raw.match(/^(\d{4})(\d{2})(\d{2})/);
  if (!m) return undefined;
  const d = `${m[1]}-${m[2]}-${m[3]}`;
  return isISODate(d) ? d : undefined;
}

function ofxAmount(raw: string | undefined): number | undefined {
  if (!raw) return undefined;
  const s = raw.replace(/\s/g, '').replace(',', '.');
  const n = Number(s);
  if (!Number.isFinite(n)) return undefined;
  return Math.round(n * 100);
}

export function parseOFX(text: string): OFXStatement {
  const body = text.replace(/\r\n?/g, '\n');
  const txBlocks = body.match(/<STMTTRN>[\s\S]*?(?=<\/STMTTRN>|<STMTTRN>|<\/BANKTRANLIST>|<\/CCSTMTRS>|$)/gi) ?? [];
  const transactions: OFXTransaction[] = [];
  for (const b of txBlocks) {
    const date = ofxDate(tag(b, 'DTPOSTED'));
    const amountCents = ofxAmount(tag(b, 'TRNAMT'));
    if (!date || amountCents === undefined) continue;
    transactions.push({ fitId: tag(b, 'FITID') ?? '', date, amountCents, memo: tag(b, 'MEMO') ?? tag(b, 'NAME') ?? '', type: (tag(b, 'TRNTYPE') ?? '').toUpperCase() });
  }
  return {
    currency: tag(body, 'CURDEF'), accountId: tag(body, 'ACCTID'), bankId: tag(body, 'BANKID'),
    transactions, balanceCents: ofxAmount(tag(body, 'BALAMT')), balanceDate: ofxDate(tag(body, 'DTASOF')),
  };
}

export function candidatesFromOFX(stmt: OFXStatement): ImportCandidate[] {
  return stmt.transactions.map((t, i) => ({
    rowIndex: i, date: t.date, description: t.memo.slice(0, 140), amountCents: Math.abs(t.amountCents),
    kind: t.amountCents < 0 ? 'expense' : 'income', externalRef: t.fitId ? `ofx:${t.fitId}` : undefined, problems: [],
  }));
}
