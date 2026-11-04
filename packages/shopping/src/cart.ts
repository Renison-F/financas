import { mulCents, sumCents, type Cents } from '@financas/core';
import { UNITS, normalizeQuantity, toBaseQuantity, type Quantity, type Unit } from './units';

/**
 * A cart line. Prices are integer cents. For measured units (kg, L) `unitPriceCents` is the price
 * per unit of the line's unit (e.g. per kg); for countable units it is the price per item.
 * Discounts: `discountCents` (absolute, per line) or `discountPercent` (0..100), never both.
 * Promotion "leve N pague M" is expressed by `promo: { take: 3, pay: 2 }`.
 */
export interface CartLine {
  id: string;
  productId?: string | undefined;
  name: string;
  brand?: string | undefined;
  barcode?: string | undefined;
  unit: Unit;
  quantity: Quantity;
  unitPriceCents: Cents;
  discountCents?: Cents | undefined;
  discountPercent?: number | undefined;
  promo?: { take: number; pay: number } | undefined;
  /** how the price was obtained; informs the UI and never a fabricated value */
  priceSource: 'label_ocr' | 'manual' | 'history' | 'barcode_catalog' | 'list_estimate';
  confidence?: number | undefined; // 0..1 for OCR
  listItemId?: string | undefined;
  checked: boolean;
  note?: string | undefined;
}

export interface LineTotal { grossCents: Cents; discountCents: Cents; netCents: Cents; pricePerBaseUnitCents?: Cents | undefined; baseUnit: string; }

/** Weighed items are rounded half-up like a store scale/cashier (R$ 6,99/kg × 1,5 kg = R$ 10,49). */
export function lineTotal(line: CartLine): LineTotal {
  const qty = normalizeQuantity(line.quantity, line.unit);
  const def = UNITS[line.unit];
  let payable = qty;
  if (line.promo && !def.measured && line.promo.take > 0 && line.promo.pay > 0 && line.promo.pay < line.promo.take) {
    const groups = Math.floor(qty / line.promo.take);
    payable = qty - groups * (line.promo.take - line.promo.pay);
  }
  const gross = mulCents(line.unitPriceCents, qty, 'half-up');
  const afterPromo = mulCents(line.unitPriceCents, payable, 'half-up');
  let discount = gross - afterPromo;
  if (line.discountCents) discount += Math.min(afterPromo, Math.max(0, line.discountCents));
  else if (line.discountPercent) discount += mulCents(afterPromo, Math.min(100, Math.max(0, line.discountPercent)) / 100, 'half-up');
  const net = Math.max(0, gross - discount);
  const base = toBaseQuantity(1, line.unit);
  const pricePerBaseUnitCents = base.quantity > 0 ? mulCents(line.unitPriceCents, 1 / base.quantity, 'half-up') : undefined;
  return { grossCents: gross, discountCents: discount, netCents: net, pricePerBaseUnitCents, baseUnit: base.base };
}

export interface CartTotals {
  itemCount: number;
  lineCount: number;
  grossCents: Cents;
  discountCents: Cents;
  totalCents: Cents;
  budgetCents?: Cents | undefined;
  remainingCents?: Cents | undefined;
  overBudget: boolean;
  /** 'sereno' | 'atencao' | 'agitado' relative to budget */
  state: 'sereno' | 'atencao' | 'agitado' | 'sem_orcamento';
  /** low-confidence lines that still need confirmation */
  unconfirmedLines: number;
}

export function cartTotals(lines: CartLine[], budgetCents?: Cents, confidenceThreshold = 0.75): CartTotals {
  const totals = lines.map(lineTotal);
  const grossCents = sumCents(totals.map((t) => t.grossCents));
  const discountCents = sumCents(totals.map((t) => t.discountCents));
  const totalCents = sumCents(totals.map((t) => t.netCents));
  const itemCount = lines.reduce((a, l) => a + (UNITS[l.unit].measured ? 1 : l.quantity), 0);
  const unconfirmedLines = lines.filter((l) => l.priceSource === 'label_ocr' && (l.confidence ?? 0) < confidenceThreshold).length;
  if (budgetCents === undefined) return { itemCount, lineCount: lines.length, grossCents, discountCents, totalCents, overBudget: false, state: 'sem_orcamento', unconfirmedLines };
  const remainingCents = budgetCents - totalCents;
  const ratio = budgetCents > 0 ? totalCents / budgetCents : 1;
  const state = ratio > 1 ? 'agitado' : ratio >= 0.9 ? 'atencao' : 'sereno';
  return { itemCount, lineCount: lines.length, grossCents, discountCents, totalCents, budgetCents, remainingCents, overBudget: remainingCents < 0, state, unconfirmedLines };
}

export function updateLine(lines: CartLine[], id: string, patch: Partial<CartLine>): CartLine[] {
  return lines.map((l) => (l.id === id ? { ...l, ...patch } : l));
}
export function removeLine(lines: CartLine[], id: string): CartLine[] { return lines.filter((l) => l.id !== id); }
export function addLine(lines: CartLine[], line: CartLine): CartLine[] {
  // merge countable duplicates of the same product/barcode at the same price
  const i = lines.findIndex((l) => !UNITS[l.unit].measured && l.unit === line.unit && l.unitPriceCents === line.unitPriceCents && ((l.barcode && l.barcode === line.barcode) || (l.productId && l.productId === line.productId)) && !l.promo && !line.promo && !l.discountCents && !line.discountCents);
  if (i >= 0) { const next = [...lines]; next[i] = { ...next[i]!, quantity: next[i]!.quantity + line.quantity }; return next; }
  return [...lines, line];
}
