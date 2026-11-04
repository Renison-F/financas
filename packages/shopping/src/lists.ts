import { mulCents, sumCents, type Cents } from '@financas/core';
import { normalizeQuantity, UNITS, type Quantity, type Unit } from './units';

export interface ShoppingList {
  id: string;
  name: string;
  store?: string | undefined; // supermarket / establishment
  budgetCents?: Cents | undefined;
  items: ListItem[];
  archived: boolean;
  createdAt: string;
  updatedAt: string;
  /** when a session finished from this list */
  lastCompletedAt?: string | undefined;
  shareToken?: string | undefined; // optional sharing (future)
}

export interface ListItem {
  id: string;
  name: string;
  brand?: string | undefined;
  category?: string | undefined; // e.g. "Hortifruti", "Limpeza"
  unit: Unit;
  quantity: Quantity;
  /** last known / estimated unit price (from history or user); undefined = unknown, never invented */
  estimatedUnitPriceCents?: Cents | undefined;
  estimateSource?: 'history' | 'manual' | 'last_purchase' | undefined;
  productId?: string | undefined;
  barcode?: string | undefined;
  checked: boolean;
  note?: string | undefined;
  sortOrder: number;
}

export const DEFAULT_CATEGORIES: readonly string[] = ['Hortifruti', 'Padaria', 'Açougue e peixaria', 'Frios e laticínios', 'Mercearia', 'Bebidas', 'Limpeza', 'Higiene e beleza', 'Pet', 'Bebê', 'Outros'];

export interface ListEstimate { knownCents: Cents; knownItems: number; unknownItems: number; totalItems: number; coveragePercent: number; budgetCents?: Cents | undefined; remainingCents?: Cents | undefined; }

/** Estimated cost: only items with a known price are summed; unknown items are counted, never guessed. */
export function estimateList(list: ShoppingList): ListEstimate {
  const active = list.items;
  const known = active.filter((i) => i.estimatedUnitPriceCents !== undefined);
  const knownCents = sumCents(known.map((i) => mulCents(i.estimatedUnitPriceCents!, normalizeQuantity(i.quantity, i.unit), 'half-up')));
  const est: ListEstimate = { knownCents, knownItems: known.length, unknownItems: active.length - known.length, totalItems: active.length, coveragePercent: active.length ? Math.round((known.length / active.length) * 100) : 0 };
  if (list.budgetCents !== undefined) { est.budgetCents = list.budgetCents; est.remainingCents = list.budgetCents - knownCents; }
  return est;
}

export function groupByCategory(items: ListItem[]): { category: string; items: ListItem[] }[] {
  const map = new Map<string, ListItem[]>();
  for (const it of [...items].sort((a, b) => a.sortOrder - b.sortOrder)) {
    const k = it.category ?? 'Outros';
    map.set(k, [...(map.get(k) ?? []), it]);
  }
  const order = [...DEFAULT_CATEGORIES];
  return [...map.entries()].sort((a, b) => (order.indexOf(a[0]) === -1 ? 99 : order.indexOf(a[0])) - (order.indexOf(b[0]) === -1 ? 99 : order.indexOf(b[0]))).map(([category, items]) => ({ category, items }));
}

export function addItem(list: ShoppingList, item: Omit<ListItem, 'id' | 'sortOrder' | 'checked'> & { id: string }, now: string): ShoppingList {
  const existing = list.items.find((i) => i.name.trim().toLowerCase() === item.name.trim().toLowerCase() && i.unit === item.unit && !UNITS[i.unit].measured);
  if (existing) return updateItem(list, existing.id, { quantity: existing.quantity + item.quantity }, now);
  return { ...list, updatedAt: now, items: [...list.items, { ...item, checked: false, sortOrder: list.items.length }] };
}
export function updateItem(list: ShoppingList, id: string, patch: Partial<ListItem>, now: string): ShoppingList {
  return { ...list, updatedAt: now, items: list.items.map((i) => (i.id === id ? { ...i, ...patch } : i)) };
}
export function removeItem(list: ShoppingList, id: string, now: string): ShoppingList {
  return { ...list, updatedAt: now, items: list.items.filter((i) => i.id !== id).map((i, idx) => ({ ...i, sortOrder: idx })) };
}
export function toggleItem(list: ShoppingList, id: string, now: string): ShoppingList {
  return updateItem(list, id, { checked: !list.items.find((i) => i.id === id)?.checked }, now);
}
export function uncheckAll(list: ShoppingList, now: string): ShoppingList { return { ...list, updatedAt: now, items: list.items.map((i) => ({ ...i, checked: false })) }; }

/** Duplicates a list (unchecked), e.g. "compra do mês" reused next month. */
export function duplicateList(list: ShoppingList, newId: string, itemId: () => string, now: string, name = `${list.name} (cópia)`): ShoppingList {
  return { ...list, id: newId, name, archived: false, createdAt: now, updatedAt: now, lastCompletedAt: undefined, shareToken: undefined, items: list.items.map((i) => ({ ...i, id: itemId(), checked: false })) };
}

export function listProgress(list: ShoppingList): { checked: number; total: number; percent: number } {
  const total = list.items.length, checked = list.items.filter((i) => i.checked).length;
  return { checked, total, percent: total ? Math.round((checked / total) * 100) : 0 };
}
