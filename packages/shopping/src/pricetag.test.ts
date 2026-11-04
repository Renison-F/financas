import { describe, it, expect } from 'vitest';
import { parsePriceTag } from './pricetag';

describe('price tag parser', () => {
  it('reads a typical tag: name, presentation, big price and per-unit reference', () => {
    const r = parsePriceTag([
      { text: 'ARROZ TIO JOAO TIPO 1 5KG', confidence: 0.9, height: 18 },
      { text: 'R$ 24,90', confidence: 0.95, height: 48 },
      { text: 'R$ 4,98/kg', confidence: 0.8, height: 14 },
      { text: 'COD 123456', confidence: 0.9, height: 12 },
    ]);
    expect(r.priceCents).toBe(2490);
    expect(r.name).toBe('ARROZ TIO JOAO TIPO 1 5KG');
    expect(r.presentation).toEqual({ quantity: 5, unit: 'kg' });
    expect(r.pricePerUnit).toEqual({ cents: 498, unit: 'kg' });
    expect(r.internalCode).toBe('123456');
    expect(r.priceUnit).toBe('un');
    expect(r.confidence).toBeGreaterThanOrEqual(0.75);
  });
  it('prefers the "por" price in a de/por promotion and keeps the old price', () => {
    const r = parsePriceTag([{ text: 'LEITE INTEGRAL 1L', height: 16 }, { text: 'DE R$ 6,49', height: 20 }, { text: 'POR R$ 5,49', height: 44 }]);
    expect(r.priceCents).toBe(549);
    expect(r.promoFromCents).toBe(649);
    expect(r.presentation).toEqual({ quantity: 1, unit: 'l' });
  });
  it('detects weighed goods priced per kg', () => {
    const r = parsePriceTag([{ text: 'BANANA PRATA', height: 20 }, { text: 'R$ 6,99 kg', height: 50 }]);
    expect(r.priceCents).toBe(699);
    expect(r.priceUnit).toBe('kg');
  });
  it('does not treat installment text as the price and flags ambiguity', () => {
    const r = parsePriceTag([{ text: 'CAFETEIRA ELETRICA', height: 16 }, { text: 'R$ 199,90', height: 40 }, { text: '10x de R$ 19,99', height: 14 }, { text: 'R$ 189,90 no app', height: 38 }]);
    expect(r.priceCents).toBe(19990);
    expect(r.candidates.find((c) => c.kind === 'installment')?.cents).toBe(1999);
    expect(r.warnings.join(' ')).toContain('Mais de um preço');
    expect(r.confidence).toBeLessThan(0.75);
  });
  it('handles OCR noise without a price', () => {
    const r = parsePriceTag([{ text: 'OFERTA', height: 10 }, { text: 'S0 HOJE', confidence: 0.3, height: 10 }]);
    expect(r.priceCents).toBeUndefined();
    expect(r.warnings).toContain('Nenhum preço reconhecido; informe manualmente.');
    expect(r.confidence).toBeLessThan(0.3);
  });
  it('finds barcodes printed on the tag', () => {
    expect(parsePriceTag([{ text: 'SABAO EM PO 1KG' }, { text: '7891000100103' }, { text: '12,90' }]).barcode).toBe('7891000100103');
  });
});
