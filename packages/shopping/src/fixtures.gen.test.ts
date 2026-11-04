import { it } from 'vitest';
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { normalizeQuantity, formatQuantity, toBaseQuantity, parseUnit } from './units';
import { lineTotal, cartTotals, addLine, type CartLine } from './cart';
import { parseBarcode, gtinChecksumValid, parseNFCeQR } from './codes';
import { parsePriceTag } from './pricetag';
import { estimateList, addItem, toggleItem, duplicateList, groupByCategory, listProgress, type ShoppingList } from './lists';
import { findProduct, priceHistory, priceVariation, type Product, type PriceObservation } from './products';
import { startSession, addToSession, finishSession, plannedVsActual, lineFromListItem, markRegistered, sessionTotals } from './session';

const OUT = resolve(__dirname, '../../../docs/flutter-migration/fixtures');
const write = (name: string, cases: unknown[]) => writeFileSync(resolve(OUT, `${name}.json`), JSON.stringify({ generatedFrom: 'packages/shopping (TypeScript) @ ae2c229', cases }, null, 2));
const c = (name: string, input: unknown, expected: unknown, note = '') => ({ name, input, expected, note });
const line = (p: Partial<CartLine>): CartLine => ({ id: 'l', name: 'x', unit: 'un', quantity: 1, unitPriceCents: 100, priceSource: 'manual', checked: false, ...p });
const now = '2026-11-04T10:00:00.000Z';

it('generates shopping fixtures', () => {
  write('shopping_units', [c('normalize kg', { q: 1.2345, unit: 'kg' }, normalizeQuantity(1.2345, 'kg')), c('normalize un', { q: 2.7, unit: 'un' }, normalizeQuantity(2.7, 'un')), c('format kg', { q: 1.5, unit: 'kg' }, formatQuantity(1.5, 'kg')), c('format un', { q: 6, unit: 'un' }, formatQuantity(6, 'un')), c('toBase g', { q: 500, unit: 'g' }, toBaseQuantity(500, 'g')), ...['KG', 'gr', 'lt', 'zz', 'und', 'pç', 'dúzia'].map((t) => c(`parseUnit ${t}`, { token: t }, parseUnit(t)))]);
  const brief = [line({ id: 'a', name: 'Arroz', quantity: 2, unitPriceCents: 2490 }), line({ id: 'b', name: 'Leite', quantity: 6, unitPriceCents: 549 }), line({ id: 'c', name: 'Banana', unit: 'kg', quantity: 1.5, unitPriceCents: 699 })];
  const lines: [string, CartLine][] = [['promo 3x2 q3', line({ quantity: 3, unitPriceCents: 1000, promo: { take: 3, pay: 2 } })], ['promo 3x2 q7', line({ quantity: 7, unitPriceCents: 1000, promo: { take: 3, pay: 2 } })], ['pct 10', line({ quantity: 2, unitPriceCents: 1000, discountPercent: 10 })], ['abs over', line({ quantity: 1, unitPriceCents: 1000, discountCents: 5000 })], ['g 350', line({ unit: 'g', quantity: 350, unitPriceCents: 5 })], ['kg 1.5 half-up', line({ unit: 'kg', quantity: 1.5, unitPriceCents: 699 })], ['kg 0.333', line({ unit: 'kg', quantity: 0.333, unitPriceCents: 2999 })], ['ml 750', line({ unit: 'ml', quantity: 750, unitPriceCents: 1 })]];
  write('shopping_cart', [...brief.map((l) => c(`lineTotal ${l.name}`, { line: l }, lineTotal(l))), ...lines.map(([n, l]) => c(`lineTotal ${n}`, { line: l }, lineTotal(l))), c('cartTotals brief budget 10000', { lines: brief, budget: 10000 }, cartTotals(brief, 10000)), c('cartTotals over', { lines: [line({ unitPriceCents: 15000, priceSource: 'label_ocr', confidence: 0.4 })], budget: 10000 }, cartTotals([line({ unitPriceCents: 15000, priceSource: 'label_ocr', confidence: 0.4 })], 10000)), c('cartTotals empty', { lines: [] }, cartTotals([])), c('addLine merge', { a: line({ id: '1', barcode: '7891000100103', quantity: 1 }), b: line({ id: '2', barcode: '7891000100103', quantity: 2 }) }, addLine(addLine([], line({ id: '1', barcode: '7891000100103', quantity: 1 })), line({ id: '2', barcode: '7891000100103', quantity: 2 })))]);
  write('shopping_codes', [...['7891000100103', '7891000100104', '96385074', '036000291452', '2123456012345', '12345', 'abc', '07891000100103', '4006381333931'].map((s) => c(`parseBarcode ${s}`, { raw: s }, parseBarcode(s))), ...['7891000100103', '7891000100104', '96385074', '036000291452'].map((s) => c(`gtin ${s}`, { digits: s }, gtinChecksumValid(s))), c('nfce', { data: 'https://www.fazenda.sp.gov.br/nfce/qrcode?p=35261112345678000199650010000012341000012345|2|1|1|ABCDEF0123' }, parseNFCeQR('https://www.fazenda.sp.gov.br/nfce/qrcode?p=35261112345678000199650010000012341000012345|2|1|1|ABCDEF0123')), c('nfce none', { data: 'https://example.com' }, parseNFCeQR('https://example.com'))]);
  const tags: [string, Parameters<typeof parsePriceTag>[0]][] = [
    ['typical', [{ text: 'ARROZ TIO JOAO TIPO 1 5KG', confidence: 0.9, height: 18 }, { text: 'R$ 24,90', confidence: 0.95, height: 48 }, { text: 'R$ 4,98/kg', confidence: 0.8, height: 14 }, { text: 'COD 123456', confidence: 0.9, height: 12 }]],
    ['de/por', [{ text: 'LEITE INTEGRAL 1L', height: 16 }, { text: 'DE R$ 6,49', height: 20 }, { text: 'POR R$ 5,49', height: 44 }]],
    ['per kg', [{ text: 'BANANA PRATA', height: 20 }, { text: 'R$ 6,99 kg', height: 50 }]],
    ['installments ambiguity', [{ text: 'CAFETEIRA ELETRICA', height: 16 }, { text: 'R$ 199,90', height: 40 }, { text: '10x de R$ 19,99', height: 14 }, { text: 'R$ 189,90 no app', height: 38 }]],
    ['noise', [{ text: 'OFERTA', height: 10 }, { text: 'S0 HOJE', confidence: 0.3, height: 10 }]],
    ['barcode on tag', [{ text: 'SABAO EM PO 1KG' }, { text: '7891000100103' }, { text: '12,90' }]],
    ['no heights', [{ text: 'QUEIJO MUSSARELA' }, { text: '39,90' }, { text: 'kg' }]],
    ['promo only por', [{ text: 'BISCOITO 200G' }, { text: 'POR 3,99' }]],
  ];
  write('shopping_pricetag', tags.map(([n, l]) => c(`parsePriceTag ${n}`, { lines: l }, parsePriceTag(l))));
  const base: ShoppingList = { id: 'L', name: 'Compra do mês', store: 'Mercado Bom', budgetCents: 30000, items: [], archived: false, createdAt: now, updatedAt: now };
  let l = addItem(base, { id: 'i1', name: 'Arroz', unit: 'un', quantity: 1, category: 'Mercearia', estimatedUnitPriceCents: 2490, estimateSource: 'history' }, now);
  l = addItem(l, { id: 'i2', name: 'arroz', unit: 'un', quantity: 1, category: 'Mercearia' }, now);
  l = addItem(l, { id: 'i3', name: 'Banana', unit: 'kg', quantity: 1.5, category: 'Hortifruti' }, now);
  l = addItem(l, { id: 'i4', name: 'Sabão', unit: 'un', quantity: 1, category: 'Limpeza', estimatedUnitPriceCents: 1290, estimateSource: 'manual' }, now);
  const lt = toggleItem(l, 'i1', now);
  let n = 0; const id = () => `id${++n}`;
  write('shopping_lists', [c('list after adds', { ops: 'add Arroz(2490) + arroz(merge) + Banana kg + Sabão' }, l), c('estimate', { list: l }, estimateList(l)), c('groups', { list: l }, groupByCategory(l.items).map((g) => ({ category: g.category, items: g.items.map((i) => i.id) }))), c('progress after toggle', { list: lt }, listProgress(lt)), c('duplicate', { list: lt }, { ...duplicateList(lt, 'L2', id, now), items: duplicateList(lt, 'L2', () => 'x', now).items.map((i) => ({ ...i, id: undefined })) })]);
  const p: Product = { id: 'p1', name: 'Arroz Tio João Tipo 1 5kg', brand: 'Tio João', barcode: '7891000100103', internalCodes: [{ store: 'Mercado Bom', code: '123456' }], defaultUnit: 'un', favorite: false, createdAt: now, updatedAt: now };
  const obs: PriceObservation[] = [{ id: 'o1', productId: 'p1', store: 'Mercado Bom', unit: 'un', unitPriceCents: 2590, observedAt: '2026-09-01T00:00:00Z', source: 'manual' }, { id: 'o2', productId: 'p1', store: 'Super Barato', unit: 'un', unitPriceCents: 2390, observedAt: '2026-10-01T00:00:00Z', source: 'label_ocr' }, { id: 'o3', productId: 'p1', store: 'Mercado Bom', unit: 'un', unitPriceCents: 2490, observedAt: '2026-11-01T00:00:00Z', source: 'label_ocr' }];
  write('shopping_products', [c('find barcode', { products: [p], q: { barcode: '7891000100103' } }, findProduct([p], { barcode: '7891000100103' })), c('find internal', { products: [p], q: { internalCode: '123456', store: 'Mercado Bom' } }, findProduct([p], { internalCode: '123456', store: 'Mercado Bom' })), c('find name', { products: [p], q: { name: 'ARROZ TIO JOAO 5KG' } }, findProduct([p], { name: 'ARROZ TIO JOAO 5KG' })), c('find none', { products: [p], q: { name: 'Feijão carioca' } }, findProduct([p], { name: 'Feijão carioca' }) ?? null), c('history', { obs, productId: 'p1' }, priceHistory(obs, 'p1')), c('variation', { history: priceHistory(obs, 'p1'), current: 2739 }, priceVariation(priceHistory(obs, 'p1'), 2739)), c('history none', { obs, productId: 'zzz' }, priceHistory(obs, 'zzz'))]);
  let list = addItem(base, { id: 'i1', name: 'Arroz', unit: 'un', quantity: 2, estimatedUnitPriceCents: 2490, productId: 'p1' }, now);
  list = addItem(list, { id: 'i2', name: 'Leite', unit: 'un', quantity: 6, estimatedUnitPriceCents: 549 }, now);
  list = addItem(list, { id: 'i3', name: 'Banana', unit: 'kg', quantity: 1.5 }, now);
  let s = startSession('S1', now, { list });
  s = addToSession(s, { ...lineFromListItem(list.items[0]!, 'l1')!, unitPriceCents: 2590, priceSource: 'label_ocr', confidence: 0.9 }, now);
  s = addToSession(s, lineFromListItem(list.items[1]!, 'l2')!, now);
  s = addToSession(s, { id: 'l3', name: 'Banana', unit: 'kg', quantity: 1.5, unitPriceCents: 699, priceSource: 'manual', checked: true, listItemId: 'i3' }, now);
  s = addToSession(s, { id: 'l4', name: 'Chocolate', unit: 'un', quantity: 1, unitPriceCents: 899, priceSource: 'manual', checked: true }, now);
  n = 0; const r = finishSession(s, now, id);
  write('shopping_session', [c('start', { list, now }, startSession('S1', now, { list })), c('lineFromListItem unknown price', { item: list.items[2] }, lineFromListItem(list.items[2]!, 'x')), c('totals', { session: s }, sessionTotals(s)), c('plannedVsActual', { session: s, list }, { ...plannedVsActual(s, list), perItem: plannedVsActual(s, list).perItem.map((x) => ({ item: x.item.id, line: x.line?.id ?? null, plannedCents: x.plannedCents ?? null, actualCents: x.actualCents ?? null })), notBought: plannedVsActual(s, list).notBought.map((i) => i.id), extra: plannedVsActual(s, list).extra.map((l) => l.id) }), c('finish', { session: s, now }, { status: r.session.status, observations: r.observations.map((o) => ({ ...o, id: undefined })), suggestedTransaction: r.suggestedTransaction }), c('finish after registered', { session: markRegistered(r.session, 'tx9', now) }, finishSession(markRegistered(r.session, 'tx9', now), now, id).suggestedTransaction)]);
});
