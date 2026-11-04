/** Units used in Brazilian supermarkets. Quantities are stored as integers in the unit's minor scale. */
export type Unit = 'un' | 'kg' | 'g' | 'l' | 'ml' | 'pct' | 'dz' | 'cx' | 'm';

export interface UnitDefinition {
  id: Unit;
  label: string; // short label
  name: string; // human name (singular)
  plural: string;
  /** base unit used for price-per-unit comparisons */
  base: 'un' | 'kg' | 'l' | 'm';
  /** factor to convert 1 of this unit into the base unit */
  toBase: number;
  /** how many decimals the quantity supports (0 for countable, 3 for weight/volume) */
  decimals: number;
  /** quantity is sold by weight/volume (price per base unit) */
  measured: boolean;
}

export const UNITS: Record<Unit, UnitDefinition> = {
  un: { id: 'un', label: 'un', name: 'unidade', plural: 'unidades', base: 'un', toBase: 1, decimals: 0, measured: false },
  kg: { id: 'kg', label: 'kg', name: 'quilo', plural: 'quilos', base: 'kg', toBase: 1, decimals: 3, measured: true },
  g: { id: 'g', label: 'g', name: 'grama', plural: 'gramas', base: 'kg', toBase: 0.001, decimals: 0, measured: true },
  l: { id: 'l', label: 'L', name: 'litro', plural: 'litros', base: 'l', toBase: 1, decimals: 3, measured: true },
  ml: { id: 'ml', label: 'mL', name: 'mililitro', plural: 'mililitros', base: 'l', toBase: 0.001, decimals: 0, measured: true },
  pct: { id: 'pct', label: 'pct', name: 'pacote', plural: 'pacotes', base: 'un', toBase: 1, decimals: 0, measured: false },
  dz: { id: 'dz', label: 'dz', name: 'dúzia', plural: 'dúzias', base: 'un', toBase: 12, decimals: 0, measured: false },
  cx: { id: 'cx', label: 'cx', name: 'caixa', plural: 'caixas', base: 'un', toBase: 1, decimals: 0, measured: false },
  m: { id: 'm', label: 'm', name: 'metro', plural: 'metros', base: 'm', toBase: 1, decimals: 2, measured: true },
};

export const UNIT_IDS = Object.keys(UNITS) as Unit[];

/** Quantity as a decimal number (e.g. 1.5 kg, 3 un). Stored with up to 3 decimals. */
export type Quantity = number;

export function normalizeQuantity(q: number, unit: Unit): Quantity {
  if (!Number.isFinite(q) || q < 0) throw new RangeError('Quantidade inválida');
  const d = UNITS[unit].decimals;
  return Math.round(q * 10 ** d) / 10 ** d;
}

export function formatQuantity(q: Quantity, unit: Unit, locale = 'pt-BR'): string {
  const def = UNITS[unit];
  const n = new Intl.NumberFormat(locale, { maximumFractionDigits: def.decimals, minimumFractionDigits: 0 }).format(q);
  return `${n} ${def.label}`;
}

/** Converts a quantity to the base unit (kg, L, un, m). */
export function toBaseQuantity(q: Quantity, unit: Unit): { quantity: number; base: UnitDefinition['base'] } {
  const def = UNITS[unit];
  return { quantity: q * def.toBase, base: def.base };
}

/** Parses unit tokens found on labels and user input: "kg", "KG", "g", "gr", "l", "lt", "ml", "un", "und", "pc". */
export function parseUnit(token: string): Unit | null {
  const t = token.trim().toLowerCase().replace(/\.$/, '');
  const map: Record<string, Unit> = { kg: 'kg', kilo: 'kg', quilo: 'kg', g: 'g', gr: 'g', grama: 'g', gramas: 'g', l: 'l', lt: 'l', litro: 'l', litros: 'l', ml: 'ml', un: 'un', und: 'un', unid: 'un', unidade: 'un', pc: 'un', pç: 'un', peca: 'un', peça: 'un', pct: 'pct', pacote: 'pct', dz: 'dz', duzia: 'dz', dúzia: 'dz', cx: 'cx', caixa: 'cx', m: 'm', metro: 'm' };
  return map[t] ?? null;
}
