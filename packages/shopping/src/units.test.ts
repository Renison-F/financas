import { describe, it, expect } from 'vitest';
import { formatQuantity, normalizeQuantity, parseUnit, toBaseQuantity } from './units';
import { lineTotal, cartTotals, addLine, updateLine, removeLine, type CartLine } from './cart';
import { parseBarcode, gtinChecksumValid, parseNFCeQR } from './codes';

const line = (p: Partial<CartLine>): CartLine => ({ id: 'l', name: 'x', unit: 'un', quantity: 1, unitPriceCents: 100, priceSource: 'manual', checked: false, ...p });

describe('units', () => {
  it('normalizes and formats', () => {
    expect(normalizeQuantity(1.2345, 'kg')).toBe(1.235);
    expect(normalizeQuantity(2.7, 'un')).toBe(3);
    expect(formatQuantity(1.5, 'kg')).toBe('1,5 kg');
    expect(formatQuantity(6, 'un')).toBe('6 un');
    expect(toBaseQuantity(500, 'g')).toEqual({ quantity: 0.5, base: 'kg' });
    expect(parseUnit('KG')).toBe('kg'); expect(parseUnit('gr')).toBe('g'); expect(parseUnit('lt')).toBe('l'); expect(parseUnit('zz')).toBeNull();
    expect(() => normalizeQuantity(-1, 'un')).toThrow();
  });
});

describe('cart math (brief example)', () => {
  it('matches the briefing: arroz, leite, banana = R$ 93,23', () => {
    const lines = [
      line({ id: 'a', name: 'Arroz', quantity: 2, unitPriceCents: 2490 }),
      line({ id: 'b', name: 'Leite', quantity: 6, unitPriceCents: 549 }),
      line({ id: 'c', name: 'Banana', unit: 'kg', quantity: 1.5, unitPriceCents: 699 }),
    ];
    expect(lineTotal(lines[0]!).netCents).toBe(4980);
    expect(lineTotal(lines[1]!).netCents).toBe(3294);
    expect(lineTotal(lines[2]!).netCents).toBe(1049); // 10,485 -> 10,49 half-up like a scale
    const t = cartTotals(lines, 10000);
    expect(t.totalCents).toBe(9323);
    expect(t.remainingCents).toBe(677);
    expect(t.state).toBe('atencao'); // 93% of budget
    expect(t.itemCount).toBe(9);
  });
  it('applies discounts and promotions correctly', () => {
    expect(lineTotal(line({ quantity: 3, unitPriceCents: 1000, promo: { take: 3, pay: 2 } })).netCents).toBe(2000);
    expect(lineTotal(line({ quantity: 7, unitPriceCents: 1000, promo: { take: 3, pay: 2 } })).netCents).toBe(5000);
    expect(lineTotal(line({ quantity: 2, unitPriceCents: 1000, discountPercent: 10 })).netCents).toBe(1800);
    expect(lineTotal(line({ quantity: 1, unitPriceCents: 1000, discountCents: 5000 })).netCents).toBe(0); // cannot go negative
    expect(lineTotal(line({ unit: 'g', quantity: 350, unitPriceCents: 5 })).netCents).toBe(1750); // R$ 0,05/g
    expect(lineTotal(line({ unit: 'g', quantity: 350, unitPriceCents: 5 })).pricePerBaseUnitCents).toBe(5000); // R$ 50/kg
  });
  it('reports budget state, over budget and unconfirmed OCR lines', () => {
    const t = cartTotals([line({ unitPriceCents: 15000, priceSource: 'label_ocr', confidence: 0.4 })], 10000);
    expect(t.overBudget).toBe(true); expect(t.state).toBe('agitado'); expect(t.unconfirmedLines).toBe(1);
    expect(cartTotals([]).state).toBe('sem_orcamento');
  });
  it('merges identical countable items and edits lines', () => {
    let lines = addLine([], line({ id: '1', barcode: '7891000100103', quantity: 1 }));
    lines = addLine(lines, line({ id: '2', barcode: '7891000100103', quantity: 2 }));
    expect(lines).toHaveLength(1); expect(lines[0]!.quantity).toBe(3);
    lines = updateLine(lines, '1', { quantity: 5 }); expect(lines[0]!.quantity).toBe(5);
    expect(removeLine(lines, '1')).toHaveLength(0);
  });
});

describe('barcodes and QR', () => {
  it('validates GTIN check digits', () => {
    expect(gtinChecksumValid('7891000100103')).toBe(true); // Nestlé-style EAN-13 sample
    expect(gtinChecksumValid('7891000100104')).toBe(false);
    expect(gtinChecksumValid('96385074')).toBe(true); // EAN-8 sample
    expect(gtinChecksumValid('036000291452')).toBe(true); // UPC-A sample
  });
  it('classifies codes and never assumes a price in a variable-measure code', () => {
    expect(parseBarcode('7891000100103')).toMatchObject({ kind: 'ean13', valid: true, gtin: '7891000100103' });
    expect(parseBarcode('036000291452')).toMatchObject({ kind: 'upc_a', gtin: '0036000291452' });
    const vm = parseBarcode('2123456012345');
    expect(vm.kind).toBe('gs1_variable_measure');
    expect(vm.variableMeasure?.embedded).toBe('unknown');
    expect(vm.variableMeasure?.itemCode).toBe('123456');
    expect(parseBarcode('12345').kind).toBe('internal');
    expect(parseBarcode('abc').valid).toBe(false);
  });
  it('parses an NFC-e QR code', () => {
    const q = parseNFCeQR('https://www.fazenda.sp.gov.br/nfce/qrcode?p=35261112345678000199650010000012341000012345|2|1|1|ABCDEF0123');
    expect(q).toMatchObject({ uf: '35', emissionYearMonth: '2026-11', cnpj: '12345678000199' });
    expect(parseNFCeQR('https://example.com')).toBeNull();
  });
});
