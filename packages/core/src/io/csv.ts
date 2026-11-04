import { parseMoneyBR, formatBRL, type Cents } from '../money/money';
import { isISODate, type ISODate } from '../dates/dates';
import type { Ledger, Transaction } from '../domain/types';

export function parseCSVLine(line: string, delimiter: string): string[] {
  const out: string[] = [];
  let cur = '', quoted = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i]!;
    if (ch === '"') { if (quoted && line[i + 1] === '"') { cur += '"'; i++; } else quoted = !quoted; }
    else if (ch === delimiter && !quoted) { out.push(cur); cur = ''; }
    else cur += ch;
  }
  out.push(cur);
  return out;
}

export function detectDelimiter(headerLine: string): string {
  const counts = [';', ',', '\t', '|'].map((d) => [d, (headerLine.match(new RegExp('\\' + d, 'g')) ?? []).length] as const);
  return counts.sort((a, b) => b[1] - a[1])[0]![0];
}

export interface CSVTable { headers: string[]; rows: string[][]; delimiter: string; }

export function parseCSV(text: string, maxRows = 10000): CSVTable {
  const lines = text.replace(/^﻿/, '').replace(/\r\n?/g, '\n').split('\n').filter((l) => l.trim().length > 0);
  if (lines.length === 0) throw new Error('Arquivo vazio.');
  if (lines.length - 1 > maxRows) throw new Error(`Limite de ${maxRows} linhas por importação.`);
  const delimiter = detectDelimiter(lines[0]!);
  const headers = parseCSVLine(lines[0]!, delimiter).map((h) => h.trim());
  const rows = lines.slice(1).map((l) => parseCSVLine(l, delimiter));
  return { headers, rows, delimiter };
}

export const normalizeHeader = (h: string) => h.toLowerCase().trim().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]+/g, '_');

/** Guesses which column holds date/description/amount/type/category from header names (pt-BR and en). */
export function guessColumnMapping(headers: string[]): ColumnMapping {
  const n = headers.map(normalizeHeader);
  const find = (...cands: string[]) => { const i = n.findIndex((h) => cands.some((c) => h === c || h.startsWith(c))); return i >= 0 ? i : undefined; };
  return {
    date: find('data', 'date', 'dt', 'data_lancamento', 'data_da_transacao'),
    description: find('descricao', 'description', 'historico', 'memo', 'estabelecimento', 'titulo', 'title', 'lancamento'),
    amount: find('valor', 'amount', 'value', 'montante', 'quantia'),
    type: find('tipo', 'type', 'natureza'),
    category: find('categoria', 'category'),
    account: find('conta', 'account'),
    notes: find('observacoes', 'observacao', 'notes', 'obs'),
  };
}

export interface ColumnMapping { date?: number | undefined; description?: number | undefined; amount?: number | undefined; type?: number | undefined; category?: number | undefined; account?: number | undefined; notes?: number | undefined; }

export function parseDateFlexible(raw: string): ISODate | null {
  const s = raw.trim();
  if (isISODate(s)) return s;
  const patterns: [RegExp, (m: RegExpMatchArray) => string][] = [
    [/^(\d{2})\/(\d{2})\/(\d{4})/, (m) => `${m[3]}-${m[2]}-${m[1]}`],
    [/^(\d{4})-(\d{2})-(\d{2})T/, (m) => `${m[1]}-${m[2]}-${m[3]}`],
    [/^(\d{2})-(\d{2})-(\d{4})$/, (m) => `${m[3]}-${m[2]}-${m[1]}`],
    [/^(\d{2})\/(\d{2})\/(\d{2})$/, (m) => `20${m[3]}-${m[2]}-${m[1]}`],
  ];
  for (const [re, build] of patterns) {
    const m = s.match(re);
    if (m) { const d = build(m); return isISODate(d) ? d : null; }
  }
  return null;
}

export interface ImportCandidate {
  rowIndex: number;
  date: ISODate;
  description: string;
  amountCents: Cents; // absolute
  kind: 'income' | 'expense';
  categoryName?: string | undefined;
  notes?: string | undefined;
  externalRef?: string | undefined;
  problems: string[];
}

/** Converts CSV rows into import candidates. Never writes anything; the UI reviews before confirming. */
export function candidatesFromCSV(table: CSVTable, mapping: ColumnMapping): ImportCandidate[] {
  const out: ImportCandidate[] = [];
  table.rows.forEach((cols, i) => {
    const problems: string[] = [];
    const rawDate = mapping.date !== undefined ? cols[mapping.date] ?? '' : '';
    const date = parseDateFlexible(rawDate);
    if (!date) problems.push('Data inválida');
    const rawAmount = mapping.amount !== undefined ? cols[mapping.amount] ?? '' : '';
    const parsed = parseMoneyBR(rawAmount.replace(/[A-Za-z$\s]/g, '').replace(/^\((.*)\)$/, '-$1'));
    if (parsed === null) problems.push('Valor inválido');
    const rawType = mapping.type !== undefined ? (cols[mapping.type] ?? '').toLowerCase().trim() : '';
    let kind: 'income' | 'expense';
    if (['receita', 'income', 'credito', 'crédito', 'entrada', 'c'].includes(rawType)) kind = 'income';
    else if (['despesa', 'expense', 'debito', 'débito', 'saida', 'saída', 'd'].includes(rawType)) kind = 'expense';
    else kind = (parsed ?? 0) < 0 ? 'expense' : rawType ? 'expense' : 'expense';
    if (!rawType && (parsed ?? 0) > 0 && mapping.type === undefined) kind = 'income';
    out.push({
      rowIndex: i, date: date ?? '0000-00-00', description: (mapping.description !== undefined ? cols[mapping.description] ?? '' : '').trim().slice(0, 140),
      amountCents: Math.abs(parsed ?? 0), kind,
      categoryName: mapping.category !== undefined ? (cols[mapping.category] ?? '').trim() || undefined : undefined,
      notes: mapping.notes !== undefined ? (cols[mapping.notes] ?? '').trim() || undefined : undefined,
      problems,
    });
  });
  return out;
}

const csvEscape = (v: unknown) => { const s = String(v ?? ''); return /[";\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s; };

/** Exports transactions to a pt-BR friendly CSV (semicolon, BOM, comma decimals). */
export function exportTransactionsCSV(ledger: Ledger, transactions: Transaction[]): string {
  const name = (list: { id: string; name: string }[], id?: string) => list.find((x) => x.id === id)?.name ?? '';
  const header = ['data', 'tipo', 'descricao', 'categoria', 'conta', 'conta_destino', 'cartao', 'valor', 'situacao', 'vencimento', 'parcela', 'tags', 'observacoes'];
  const kinds: Record<Transaction['kind'], string> = { income: 'receita', expense: 'despesa', transfer: 'transferencia', card_purchase: 'compra_cartao', card_payment: 'pagamento_fatura', goal_deposit: 'deposito_reserva', goal_withdrawal: 'resgate_reserva', loan_disbursement: 'entrada_emprestimo', loan_payment: 'parcela_emprestimo', balance_adjustment: 'ajuste_saldo' };
  const status: Record<Transaction['status'], string> = { planned: 'previsto', settled: 'efetivado', partially_paid: 'parcial', cancelled: 'cancelado' };
  const rows = transactions.map((t) => [
    t.date, kinds[t.kind], t.description, name(ledger.categories, t.categoryId), name(ledger.accounts, t.accountId), name(ledger.accounts, t.toAccountId), name(ledger.cards, t.cardId),
    (t.amountCents / 100).toFixed(2).replace('.', ','), status[t.status], t.dueDate ?? '', t.installment ? `${t.installment.number}/${t.installment.of}` : '',
    t.tags.map((id) => name(ledger.tags, id)).join('|'), t.notes ?? '',
  ].map(csvEscape).join(';'));
  return '﻿' + [header.join(';'), ...rows].join('\r\n');
}

export const formatForCSV = (cents: Cents) => formatBRL(cents);
