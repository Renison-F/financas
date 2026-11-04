import { mulCents, type Cents } from '@financas/core';
import { toBaseQuantity, type Unit } from './units';

/** Local product catalog built from the user's own scans and entries. No external catalog is assumed. */
export interface Product {
  id: string;
  name: string;
  brand?: string | undefined;
  barcode?: string | undefined; // GTIN
  internalCodes: { store: string; code: string }[];
  defaultUnit: Unit;
  presentation?: { quantity: number; unit: Unit } | undefined;
  category?: string | undefined;
  favorite: boolean;
  createdAt: string;
  updatedAt: string;
}

/** One observed price: where, when, how much, how it was captured. The raw material for price history. */
export interface PriceObservation {
  id: string;
  productId: string;
  store?: string | undefined;
  unit: Unit;
  unitPriceCents: Cents;
  observedAt: string; // ISO datetime
  source: 'label_ocr' | 'manual' | 'receipt' | 'history';
  sessionId?: string | undefined;
  promo?: boolean | undefined;
}

const norm = (s: string) => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9 ]+/g, ' ').replace(/\s+/g, ' ').trim();

/** Finds a product by barcode, by store internal code, or by fuzzy name (token overlap ≥ 0.6). */
export function findProduct(products: Product[], q: { barcode?: string | undefined; store?: string | undefined; internalCode?: string | undefined; name?: string | undefined }): { product: Product; match: 'barcode' | 'internal_code' | 'name'; score: number } | undefined {
  if (q.barcode) { const p = products.find((p) => p.barcode === q.barcode); if (p) return { product: p, match: 'barcode', score: 1 }; }
  if (q.internalCode) { const p = products.find((p) => p.internalCodes.some((c) => c.code === q.internalCode && (!q.store || c.store === q.store))); if (p) return { product: p, match: 'internal_code', score: 0.95 }; }
  if (q.name) {
    const A = new Set(norm(q.name).split(' ').filter((w) => w.length > 1));
    let best: { product: Product; score: number } | undefined;
    for (const p of products) {
      const B = new Set(norm(`${p.name} ${p.brand ?? ''}`).split(' ').filter((w) => w.length > 1));
      let inter = 0; for (const w of A) if (B.has(w)) inter++;
      const score = A.size && B.size ? inter / Math.max(A.size, B.size) : 0;
      if (score >= 0.6 && (!best || score > best.score)) best = { product: p, score };
    }
    if (best) return { product: best.product, match: 'name', score: best.score };
  }
  return undefined;
}

export interface PriceHistory {
  lastCents?: Cents | undefined;
  lastStore?: string | undefined;
  lastAt?: string | undefined;
  minCents?: Cents | undefined;
  maxCents?: Cents | undefined;
  avgCents?: Cents | undefined;
  byStore: { store: string; lastCents: Cents; lastAt: string; count: number }[];
  observations: number;
  /** price per base unit (kg/L/un) of the last observation, for comparing presentations */
  lastPerBaseUnitCents?: Cents | undefined;
}

export function priceHistory(observations: PriceObservation[], productId: string, unit?: Unit): PriceHistory {
  const obs = observations.filter((o) => o.productId === productId && (!unit || o.unit === unit)).sort((a, b) => a.observedAt.localeCompare(b.observedAt));
  if (!obs.length) return { byStore: [], observations: 0 };
  const last = obs[obs.length - 1]!;
  const prices = obs.map((o) => o.unitPriceCents);
  const byStoreMap = new Map<string, { store: string; lastCents: Cents; lastAt: string; count: number }>();
  for (const o of obs) { const k = o.store ?? 'Sem loja'; const cur = byStoreMap.get(k); byStoreMap.set(k, { store: k, lastCents: o.unitPriceCents, lastAt: o.observedAt, count: (cur?.count ?? 0) + 1 }); }
  const base = toBaseQuantity(1, last.unit);
  return {
    lastCents: last.unitPriceCents, lastStore: last.store, lastAt: last.observedAt,
    minCents: Math.min(...prices), maxCents: Math.max(...prices), avgCents: Math.round(prices.reduce((a, b) => a + b, 0) / prices.length),
    byStore: [...byStoreMap.values()].sort((a, b) => a.lastCents - b.lastCents), observations: obs.length,
    lastPerBaseUnitCents: base.quantity > 0 ? mulCents(last.unitPriceCents, 1 / base.quantity, 'half-up') : undefined,
  };
}

/** Price variation alert: current vs last observation at any store (percent, positive = more expensive). */
export function priceVariation(history: PriceHistory, currentCents: Cents): { percent: number; vsCents: Cents } | undefined {
  if (history.lastCents === undefined || history.lastCents === 0) return undefined;
  return { percent: Math.round(((currentCents - history.lastCents) / history.lastCents) * 1000) / 10, vsCents: history.lastCents };
}
