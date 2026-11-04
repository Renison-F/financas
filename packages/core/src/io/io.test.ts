import { describe, it, expect } from 'vitest';
import { parseCSV, guessColumnMapping, candidatesFromCSV, exportTransactionsCSV, parseDateFlexible } from './csv';
import { parseOFX, candidatesFromOFX } from './ofx';
import { findDuplicates, textSimilarity } from './duplicates';
import { importLegacyBackup, isLegacyBackup } from './legacy';
import { createBackup, validateBackup } from './backup';
import { account, category, ledger, tx } from '../domain/test-helpers';

describe('CSV import', () => {
  it('parses pt-BR CSV with semicolons, quotes and BOM', () => {
    const csv = '﻿Data;Descrição;Valor;Tipo\n04/11/2026;"Mercado; Bom";-R$ 1.234,56;despesa\n2026-11-05;Salário;5.000,00;receita\n05/11/2026;Ruim;abc;despesa\n';
    const table = parseCSV(csv);
    expect(table.delimiter).toBe(';');
    const map = guessColumnMapping(table.headers);
    expect(map).toMatchObject({ date: 0, description: 1, amount: 2, type: 3 });
    const c = candidatesFromCSV(table, map);
    expect(c[0]).toMatchObject({ date: '2026-11-04', description: 'Mercado; Bom', amountCents: 123456, kind: 'expense', problems: [] });
    expect(c[1]).toMatchObject({ date: '2026-11-05', amountCents: 500000, kind: 'income' });
    expect(c[2]!.problems).toContain('Valor inválido');
  });
  it('infers kind from sign when there is no type column', () => {
    const table = parseCSV('date,description,amount\n2026-11-04,Uber,-23.90\n2026-11-04,Pix recebido,100.00');
    const c = candidatesFromCSV(table, guessColumnMapping(table.headers));
    expect(c.map((x) => [x.kind, x.amountCents])).toEqual([['expense', 2390], ['income', 10000]]);
  });
  it('parses several date formats', () => {
    expect(parseDateFlexible('31/12/2026')).toBe('2026-12-31');
    expect(parseDateFlexible('2026-12-31T10:00:00Z')).toBe('2026-12-31');
    expect(parseDateFlexible('31-12-2026')).toBe('2026-12-31');
    expect(parseDateFlexible('32/12/2026')).toBeNull();
  });
  it('exports a round-trippable CSV', () => {
    const L = ledger({ accounts: [account({ id: 'a', name: 'Nubank' })], categories: [category({ id: 'c', name: 'Casa' })], transactions: [tx({ kind: 'expense', amountCents: 123456, date: '2026-11-04', description: 'Luz; "nov"', accountId: 'a', categoryId: 'c' })] });
    const out = exportTransactionsCSV(L, L.transactions);
    expect(out.startsWith('﻿data;tipo;')).toBe(true);
    expect(out).toContain('2026-11-04;despesa;"Luz; ""nov""";Casa;Nubank;;;1234,56;efetivado');
    const back = candidatesFromCSV(parseCSV(out), guessColumnMapping(parseCSV(out).headers));
    expect(back[0]).toMatchObject({ amountCents: 123456, kind: 'expense', description: 'Luz; "nov"' });
  });
});

describe('OFX import', () => {
  const ofx = `OFXHEADER:100\nDATA:OFXSGML\n<OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS><CURDEF>BRL<BANKACCTFROM><BANKID>0260<ACCTID>12345-6</BANKACCTFROM>\n<BANKTRANLIST><DTSTART>20261101<DTEND>20261130\n<STMTTRN><TRNTYPE>DEBIT<DTPOSTED>20261104120000[-3:BRT]<TRNAMT>-45.90<FITID>2026110400001<MEMO>PAG*MercadoBom</STMTTRN>\n<STMTTRN><TRNTYPE>CREDIT<DTPOSTED>20261105<TRNAMT>5000.00<FITID>2026110500002<NAME>TED SALARIO</STMTTRN>\n</BANKTRANLIST><LEDGERBAL><BALAMT>1234.56<DTASOF>20261130</LEDGERBAL></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>`;
  it('parses SGML OFX statements', () => {
    const s = parseOFX(ofx);
    expect(s.currency).toBe('BRL');
    expect(s.accountId).toBe('12345-6');
    expect(s.balanceCents).toBe(123456);
    expect(s.transactions).toHaveLength(2);
    expect(s.transactions[0]).toMatchObject({ date: '2026-11-04', amountCents: -4590, memo: 'PAG*MercadoBom', fitId: '2026110400001' });
    const c = candidatesFromOFX(s);
    expect(c[0]).toMatchObject({ kind: 'expense', amountCents: 4590, externalRef: 'ofx:2026110400001' });
    expect(c[1]).toMatchObject({ kind: 'income', amountCents: 500000, description: 'TED SALARIO' });
  });
});

describe('duplicate detection', () => {
  it('scores text similarity', () => {
    expect(textSimilarity('Mercado Bom', 'MERCADO BOM LTDA')).toBeCloseTo(2 / 3);
    expect(textSimilarity('a', 'b')).toBe(0);
  });
  it('flags external refs, exact matches, near matches and in-batch duplicates', () => {
    const L = ledger({ transactions: [
      tx({ id: 't1', kind: 'expense', amountCents: 4590, date: '2026-11-04', description: 'Mercado Bom', externalRef: 'ofx:X' }),
      tx({ id: 't2', kind: 'expense', amountCents: 10000, date: '2026-11-10', description: 'Conta de luz' }),
    ] });
    const cands = [
      { rowIndex: 0, date: '2026-11-04', description: 'whatever', amountCents: 1, kind: 'expense' as const, externalRef: 'ofx:X', problems: [] },
      { rowIndex: 1, date: '2026-11-11', description: 'conta de luz', amountCents: 10000, kind: 'expense' as const, problems: [] },
      { rowIndex: 2, date: '2026-11-20', description: 'Novo', amountCents: 500, kind: 'expense' as const, problems: [] },
      { rowIndex: 3, date: '2026-11-20', description: 'novo', amountCents: 500, kind: 'expense' as const, problems: [] },
      { rowIndex: 4, date: '2026-11-10', description: 'Conta de luz', amountCents: 10000, kind: 'income' as const, problems: [] },
    ];
    const d = findDuplicates(L, cands);
    expect(d.find((m) => m.candidateIndex === 0)).toMatchObject({ existingId: 't1', reason: 'external_ref' });
    expect(d.find((m) => m.candidateIndex === 1)).toMatchObject({ existingId: 't2', reason: 'similar' });
    expect(d.find((m) => m.candidateIndex === 2)).toBeUndefined();
    expect(d.find((m) => m.candidateIndex === 3)).toMatchObject({ existingId: 'batch:2' });
    expect(d.find((m) => m.candidateIndex === 4)).toBeUndefined(); // kind differs
  });
});

describe('legacy backup import', () => {
  const legacy = {
    version: 1, prefs: { name: 'Eu', theme: 'dark', safetyCushion: 150.5 },
    accounts: [{ id: 'a1', name: 'Carteira', type: 'cash', balance: 10.1 }],
    categories: [{ id: 'c1', name: 'Alimentação', type: 'expense', icon: '🍽️', color: '#cb856a' }],
    cards: [{ id: 'k1', name: 'Roxo', limit: 1500, closing: 20, due: 27 }],
    transactions: [
      { id: 't1', type: 'expense', amount: 24.9, date: '2026-11-03', accountId: 'a1', categoryId: 'c1', description: 'Padaria', paid: true, tags: [] },
      { id: 't2', type: 'card_expense', amount: 99.99, date: '2026-11-25', cardId: 'k1', categoryId: 'c1', description: 'Mercado', paid: true },
      { id: 't3', type: 'card_payment', amount: 50, date: '2026-11-27', accountId: 'a1', cardId: 'k1', invoiceKey: '2026-11', paid: true },
      { id: 't4', type: 'expense', amount: 1, date: 'not-a-date', accountId: 'a1' },
    ],
    budgets: [{ id: 'b1', categoryId: 'c1', limit: 500 }], goals: [{ id: 'g1', name: 'Viagem', target: 3000 }], loans: [], tags: [],
  };
  it('recognizes and converts the legacy format into cents and new kinds', () => {
    expect(isLegacyBackup(legacy)).toBe(true);
    const r = importLegacyBackup(legacy as never, '2026-11-04T00:00:00.000Z');
    expect(r.counts.transactions).toBe(3);
    expect(r.warnings).toHaveLength(1);
    expect(r.ledger.accounts[0]).toMatchObject({ openingBalanceCents: 1010, type: 'cash' });
    expect(r.ledger.cards[0]).toMatchObject({ limitCents: 150000, closingDay: 20, dueDay: 27 });
    const t2 = r.ledger.transactions.find((t) => t.id === 't2')!;
    expect(t2).toMatchObject({ kind: 'card_purchase', amountCents: 9999, invoiceMonth: '2026-12', status: 'settled' });
    expect(r.ledger.transactions.find((t) => t.id === 't3')).toMatchObject({ kind: 'card_payment', invoiceMonth: '2026-11' });
    expect(r.ledger.prefs).toMatchObject({ theme: 'dark', safetyCushionCents: 15050 });
    expect(r.ledger.categories[0]!.icon).toBe('tag'); // emoji dropped
  });
});

describe('backup validation', () => {
  it('round-trips and rejects foreign files', () => {
    const L = ledger({ accounts: [account()] });
    const b = createBackup(L, '2026-11-04T00:00:00.000Z');
    expect(validateBackup(JSON.parse(JSON.stringify(b)))).toMatchObject({ ok: true });
    expect(validateBackup({ app: 'other' })).toMatchObject({ ok: false });
    expect(validateBackup({ app: 'serenacash', schemaVersion: 99, ledger: L })).toMatchObject({ ok: false });
    expect(validateBackup({ app: 'serenacash', schemaVersion: 1, ledger: { ...L, transactions: null } })).toMatchObject({ ok: false });
  });
});
