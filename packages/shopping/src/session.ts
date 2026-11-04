import type { Cents } from '@financas/core';
import { cartTotals, type CartLine, type CartTotals } from './cart';
import type { ShoppingList, ListItem } from './lists';
import type { PriceObservation } from './products';
import { UNITS } from './units';

export type SessionStatus = 'active' | 'finished' | 'abandoned';

export interface ShoppingSession {
  id: string;
  store?: string | undefined;
  listId?: string | undefined;
  budgetCents?: Cents | undefined;
  lines: CartLine[];
  status: SessionStatus;
  startedAt: string;
  finishedAt?: string | undefined;
  /** id of the finance transaction created from this session, to prevent double registration */
  transactionId?: string | undefined;
  /** receipt QR (NFC-e) if scanned at checkout */
  receiptAccessKey?: string | undefined;
  events: SessionEvent[];
}

export interface SessionEvent { at: string; type: 'start' | 'add' | 'update' | 'remove' | 'scan' | 'finish' | 'abandon' | 'register'; lineId?: string | undefined; detail?: string | undefined; }

export function startSession(id: string, now: string, opts: { store?: string | undefined; list?: ShoppingList | undefined; budgetCents?: Cents | undefined } = {}): ShoppingSession {
  return { id, store: opts.store ?? opts.list?.store, listId: opts.list?.id, budgetCents: opts.budgetCents ?? opts.list?.budgetCents, lines: [], status: 'active', startedAt: now, events: [{ at: now, type: 'start' }] };
}

export function sessionTotals(s: ShoppingSession): CartTotals { return cartTotals(s.lines, s.budgetCents); }

export function addToSession(s: ShoppingSession, line: CartLine, now: string): ShoppingSession {
  return { ...s, lines: [...s.lines, line], events: [...s.events, { at: now, type: 'add', lineId: line.id, detail: line.name }] };
}
export function updateSessionLine(s: ShoppingSession, lineId: string, patch: Partial<CartLine>, now: string): ShoppingSession {
  return { ...s, lines: s.lines.map((l) => (l.id === lineId ? { ...l, ...patch } : l)), events: [...s.events, { at: now, type: 'update', lineId }] };
}
export function removeFromSession(s: ShoppingSession, lineId: string, now: string): ShoppingSession {
  return { ...s, lines: s.lines.filter((l) => l.id !== lineId), events: [...s.events, { at: now, type: 'remove', lineId }] };
}

/** Builds a cart line from a list item (no price is invented: unknown estimates stay undefined → user must confirm). */
export function lineFromListItem(item: ListItem, lineId: string): CartLine | null {
  if (item.estimatedUnitPriceCents === undefined) return null;
  return { id: lineId, name: item.name, brand: item.brand, unit: item.unit, quantity: item.quantity, unitPriceCents: item.estimatedUnitPriceCents, priceSource: 'list_estimate', listItemId: item.id, productId: item.productId, barcode: item.barcode, checked: true };
}

export interface PlannedVsActual {
  plannedKnownCents: Cents; actualCents: Cents; differenceCents: Cents;
  bought: number; notBought: ListItem[]; extra: CartLine[];
  perItem: { item: ListItem; line?: CartLine | undefined; plannedCents?: Cents | undefined; actualCents?: Cents | undefined }[];
}

export function plannedVsActual(s: ShoppingSession, list: ShoppingList): PlannedVsActual {
  const perItem = list.items.map((item) => {
    const line = s.lines.find((l) => l.listItemId === item.id) ?? s.lines.find((l) => l.productId && l.productId === item.productId) ?? s.lines.find((l) => l.barcode && l.barcode === item.barcode);
    const plannedCents = item.estimatedUnitPriceCents !== undefined ? Math.round(item.estimatedUnitPriceCents * item.quantity) : undefined;
    const actualCents = line ? cartTotals([line]).totalCents : undefined;
    return { item, line, plannedCents, actualCents };
  });
  const matched = new Set(perItem.map((p) => p.line?.id).filter(Boolean));
  return {
    plannedKnownCents: perItem.reduce((a, p) => a + (p.plannedCents ?? 0), 0),
    actualCents: cartTotals(s.lines).totalCents,
    differenceCents: cartTotals(s.lines).totalCents - perItem.reduce((a, p) => a + (p.plannedCents ?? 0), 0),
    bought: perItem.filter((p) => p.line).length,
    notBought: perItem.filter((p) => !p.line).map((p) => p.item),
    extra: s.lines.filter((l) => !matched.has(l.id)),
    perItem,
  };
}

export interface FinishResult { session: ShoppingSession; observations: PriceObservation[]; suggestedTransaction: { amountCents: Cents; description: string; merchant?: string | undefined; externalRef: string } | null; }

/** Finishes the session, emits price observations for history and a suggested (not created) expense. */
export function finishSession(s: ShoppingSession, now: string, obsId: () => string): FinishResult {
  const totals = sessionTotals(s);
  const finished: ShoppingSession = { ...s, status: 'finished', finishedAt: now, lines: s.lines.map((l) => ({ ...l, checked: true })), events: [...s.events, { at: now, type: 'finish' }] };
  const observations: PriceObservation[] = s.lines.filter((l) => l.productId && l.priceSource !== 'list_estimate').map((l) => ({ id: obsId(), productId: l.productId!, store: s.store, unit: l.unit, unitPriceCents: l.unitPriceCents, observedAt: now, source: l.priceSource === 'label_ocr' ? 'label_ocr' : 'manual', sessionId: s.id, promo: !!(l.promo || l.discountCents || l.discountPercent) }));
  const suggestedTransaction = totals.totalCents > 0 && !s.transactionId ? { amountCents: totals.totalCents, description: s.store ? `Compras em ${s.store}` : 'Compras de supermercado', merchant: s.store, externalRef: `shopping:${s.id}` } : null;
  return { session: finished, observations, suggestedTransaction };
}

export function markRegistered(s: ShoppingSession, transactionId: string, now: string): ShoppingSession {
  return { ...s, transactionId, events: [...s.events, { at: now, type: 'register', detail: transactionId }] };
}

/** Summary for the "última compra" widget */
export function sessionSummary(s: ShoppingSession): { totalCents: Cents; lines: number; items: number; store?: string | undefined; finishedAt?: string | undefined } {
  const t = sessionTotals(s);
  return { totalCents: t.totalCents, lines: t.lineCount, items: s.lines.reduce((a, l) => a + (UNITS[l.unit].measured ? 1 : l.quantity), 0), store: s.store, finishedAt: s.finishedAt };
}
