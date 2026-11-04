import { describe, it, expect } from 'vitest';
import { estimateList, addItem, updateItem, removeItem, toggleItem, duplicateList, groupByCategory, listProgress, type ShoppingList } from './lists';
import { findProduct, priceHistory, priceVariation, type Product, type PriceObservation } from './products';
import { startSession, addToSession, finishSession, plannedVsActual, lineFromListItem, markRegistered, sessionTotals } from './session';

const now = '2026-11-04T10:00:00.000Z';
let n = 0; const id = () => `id${++n}`;
const base: ShoppingList = { id: 'L', name: 'Compra do mês', store: 'Mercado Bom', budgetCents: 30000, items: [], archived: false, createdAt: now, updatedAt: now };

describe('shopping lists', () => {
  it('adds, merges, updates, toggles and removes items', () => {
    let l = addItem(base, { id: id(), name: 'Arroz', unit: 'un', quantity: 1, category: 'Mercearia', estimatedUnitPriceCents: 2490, estimateSource: 'history' }, now);
    l = addItem(l, { id: id(), name: 'arroz', unit: 'un', quantity: 1, category: 'Mercearia' }, now);
    expect(l.items).toHaveLength(1); expect(l.items[0]!.quantity).toBe(2);
    l = addItem(l, { id: id(), name: 'Banana', unit: 'kg', quantity: 1.5, category: 'Hortifruti' }, now);
    l = addItem(l, { id: id(), name: 'Sabão', unit: 'un', quantity: 1, category: 'Limpeza', estimatedUnitPriceCents: 1290, estimateSource: 'manual' }, now);
    const est = estimateList(l);
    expect(est).toMatchObject({ knownCents: 2 * 2490 + 1290, knownItems: 2, unknownItems: 1, coveragePercent: 67, remainingCents: 30000 - 6270 });
    expect(groupByCategory(l.items).map((g) => g.category)).toEqual(['Hortifruti', 'Mercearia', 'Limpeza']);
    l = toggleItem(l, l.items[0]!.id, now);
    expect(listProgress(l)).toEqual({ checked: 1, total: 3, percent: 33 });
    l = updateItem(l, l.items[1]!.id, { quantity: 2 }, now);
    expect(l.items[1]!.quantity).toBe(2);
    l = removeItem(l, l.items[0]!.id, now);
    expect(l.items.map((i) => i.sortOrder)).toEqual([0, 1]);
    const copy = duplicateList(l, 'L2', id, now);
    expect(copy.items.every((i) => !i.checked)).toBe(true);
    expect(copy.items[0]!.id).not.toBe(l.items[0]!.id);
  });
});

describe('products and price history', () => {
  const p: Product = { id: 'p1', name: 'Arroz Tio João Tipo 1 5kg', brand: 'Tio João', barcode: '7891000100103', internalCodes: [{ store: 'Mercado Bom', code: '123456' }], defaultUnit: 'un', favorite: false, createdAt: now, updatedAt: now };
  const obs: PriceObservation[] = [
    { id: 'o1', productId: 'p1', store: 'Mercado Bom', unit: 'un', unitPriceCents: 2590, observedAt: '2026-09-01T00:00:00Z', source: 'manual' },
    { id: 'o2', productId: 'p1', store: 'Super Barato', unit: 'un', unitPriceCents: 2390, observedAt: '2026-10-01T00:00:00Z', source: 'label_ocr' },
    { id: 'o3', productId: 'p1', store: 'Mercado Bom', unit: 'un', unitPriceCents: 2490, observedAt: '2026-11-01T00:00:00Z', source: 'label_ocr' },
  ];
  it('finds products by barcode, store code and fuzzy name', () => {
    expect(findProduct([p], { barcode: '7891000100103' })?.match).toBe('barcode');
    expect(findProduct([p], { internalCode: '123456', store: 'Mercado Bom' })?.match).toBe('internal_code');
    expect(findProduct([p], { name: 'ARROZ TIO JOAO 5KG' })?.match).toBe('name');
    expect(findProduct([p], { name: 'Feijão carioca' })).toBeUndefined();
  });
  it('summarizes history per store and detects variation', () => {
    const h = priceHistory(obs, 'p1');
    expect(h).toMatchObject({ lastCents: 2490, lastStore: 'Mercado Bom', minCents: 2390, maxCents: 2590, avgCents: 2490, observations: 3 });
    expect(h.byStore[0]).toMatchObject({ store: 'Super Barato', lastCents: 2390 });
    expect(priceVariation(h, 2739)).toEqual({ percent: 10, vsCents: 2490 });
    expect(priceHistory(obs, 'zzz').observations).toBe(0);
  });
});

describe('shopping session', () => {
  it('runs from a list to a finished session with planned × actual and a single suggested expense', () => {
    let list = addItem(base, { id: 'i1', name: 'Arroz', unit: 'un', quantity: 2, estimatedUnitPriceCents: 2490, productId: 'p1' }, now);
    list = addItem(list, { id: 'i2', name: 'Leite', unit: 'un', quantity: 6, estimatedUnitPriceCents: 549 }, now);
    list = addItem(list, { id: 'i3', name: 'Banana', unit: 'kg', quantity: 1.5 }, now); // unknown price
    let s = startSession('S1', now, { list });
    expect(s.budgetCents).toBe(30000); expect(s.store).toBe('Mercado Bom');
    expect(lineFromListItem(list.items[2]!, 'x')).toBeNull(); // no invented price
    s = addToSession(s, { ...lineFromListItem(list.items[0]!, 'l1')!, unitPriceCents: 2590, priceSource: 'label_ocr', confidence: 0.9 }, now);
    s = addToSession(s, lineFromListItem(list.items[1]!, 'l2')!, now);
    s = addToSession(s, { id: 'l3', name: 'Banana', unit: 'kg', quantity: 1.5, unitPriceCents: 699, priceSource: 'manual', checked: true, listItemId: 'i3' }, now);
    s = addToSession(s, { id: 'l4', name: 'Chocolate', unit: 'un', quantity: 1, unitPriceCents: 899, priceSource: 'manual', checked: true }, now);
    const t = sessionTotals(s);
    expect(t.totalCents).toBe(2 * 2590 + 6 * 549 + 1049 + 899);
    const pva = plannedVsActual(s, list);
    expect(pva.bought).toBe(3); expect(pva.notBought).toHaveLength(0); expect(pva.extra.map((l) => l.name)).toEqual(['Chocolate']);
    expect(pva.plannedKnownCents).toBe(2 * 2490 + 6 * 549);
    const r = finishSession(s, now, id);
    expect(r.session.status).toBe('finished');
    expect(r.observations).toHaveLength(1); // only lines with productId and a real (non-estimate) price
    expect(r.observations[0]).toMatchObject({ productId: 'p1', unitPriceCents: 2590, source: 'label_ocr' });
    expect(r.suggestedTransaction).toMatchObject({ amountCents: t.totalCents, externalRef: 'shopping:S1', merchant: 'Mercado Bom' });
    const registered = markRegistered(r.session, 'tx9', now);
    expect(finishSession(registered, now, id).suggestedTransaction).toBeNull(); // never twice
  });
});
