/**
 * Money is represented as an integer number of the currency's minor unit (cents).
 * All arithmetic is integer arithmetic; rounding only happens at explicit boundaries
 * (multiplication by a factor, division, allocation). This removes floating-point
 * drift from every financial calculation in the product.
 */
export type Cents = number;
export type RoundingMode = 'half-even' | 'half-up' | 'down';

const MAX = Number.MAX_SAFE_INTEGER;

export function assertCents(value: number): Cents {
  if (!Number.isSafeInteger(value)) {
    throw new RangeError(`Valor monetário inválido (esperado inteiro em centavos): ${value}`);
  }
  return value;
}

/** Converts a decimal amount (e.g. 24.9) to integer cents, removing float noise. */
export function cents(amount: number): Cents {
  if (!Number.isFinite(amount)) throw new RangeError(`Valor inválido: ${amount}`);
  const scaled = Math.round(amount * 100 + (amount >= 0 ? 1e-9 : -1e-9));
  return assertCents(scaled === 0 ? 0 : scaled);
}

function roundTo(value: number, mode: RoundingMode): number {
  if (mode === 'down') return value < 0 ? Math.ceil(value) : Math.floor(value);
  if (mode === 'half-up') {
    // symmetric: away from zero on .5
    const sign = value < 0 ? -1 : 1;
    return sign * Math.floor(Math.abs(value) + 0.5);
  }
  // half-even (banker's)
  const sign = value < 0 ? -1 : 1;
  const abs = Math.abs(value);
  const floor = Math.floor(abs);
  const diff = abs - floor;
  const EPS = 1e-9;
  if (Math.abs(diff - 0.5) < EPS) return sign * (floor % 2 === 0 ? floor : floor + 1);
  return sign * (diff > 0.5 ? floor + 1 : floor);
}

export function addCents(a: Cents, b: Cents): Cents {
  const r = assertCents(a) + assertCents(b);
  if (Math.abs(r) > MAX) throw new RangeError('Estouro de valor monetário');
  return r;
}
export function subCents(a: Cents, b: Cents): Cents { return addCents(a, -assertCents(b)); }
export function negate(a: Cents): Cents { return -assertCents(a) || 0; }
export function sumCents(values: Iterable<Cents>): Cents {
  let t = 0;
  for (const v of values) t = addCents(t, v);
  return t;
}

/** Multiplies cents by an arbitrary factor (quantity, rate) and rounds once. */
export function mulCents(a: Cents, factor: number, mode: RoundingMode = 'half-even'): Cents {
  if (!Number.isFinite(factor)) throw new RangeError(`Fator inválido: ${factor}`);
  const raw = assertCents(a) * factor;
  // Snap away tiny binary noise before rounding (e.g. 10.485000000000001)
  const snapped = Math.round(raw * 1e6) / 1e6;
  return assertCents(roundTo(snapped, mode)) || 0;
}

export function divCents(a: Cents, divisor: number, mode: RoundingMode = 'half-even'): Cents {
  if (!Number.isFinite(divisor) || divisor === 0) throw new RangeError('Divisão por zero');
  return mulCents(a, 1 / divisor, mode);
}

/** percent in 0..100 (e.g. 15 for 15%) */
export function percentOf(a: Cents, percent: number, mode: RoundingMode = 'half-even'): Cents {
  return mulCents(a, percent / 100, mode);
}

/**
 * Splits `total` into `n` integer parts whose sum is exactly `total`.
 * The remainder (at most n-1 cents) is distributed one cent at a time to the first
 * parts ('first', default) or the last parts ('last').
 */
export function allocate(total: Cents, n: number, remainderOn: 'first' | 'last' = 'first'): Cents[] {
  assertCents(total);
  if (!Number.isInteger(n) || n < 1) throw new RangeError(`Número de partes inválido: ${n}`);
  const sign = total < 0 ? -1 : 1;
  const abs = Math.abs(total);
  const base = Math.floor(abs / n);
  let remainder = abs - base * n;
  const parts: Cents[] = new Array<number>(n).fill(base);
  if (remainderOn === 'first') {
    for (let i = 0; i < n && remainder > 0; i++, remainder--) parts[i] = base + 1;
  } else {
    for (let i = n - 1; i >= 0 && remainder > 0; i--, remainder--) parts[i] = base + 1;
  }
  return parts.map((p) => (p === 0 ? 0 : sign * p));
}

/**
 * Parses user/OCR input into cents. Accepts "R$ 1.234,56", "1234,56", "24,9", "24",
 * "1,234.56", "1234.56". Returns null when the text is not a single monetary value.
 */
export function parseMoneyBR(input: string): Cents | null {
  if (typeof input !== 'string') return null;
  let s = input.trim().replace(/\s+/g, '');
  if (!s) return null;
  let negative = false;
  if (s.startsWith('-')) { negative = true; s = s.slice(1); }
  s = s.replace(/^R\$/i, '');
  if (s.startsWith('-')) { negative = !negative; s = s.slice(1); }
  if (!/^[\d.,]+$/.test(s)) return null;
  const commas = (s.match(/,/g) ?? []).length;
  const dots = (s.match(/\./g) ?? []).length;
  let intPart: string;
  let fracPart = '';
  if (commas === 1 && dots === 0) {
    [intPart, fracPart] = s.split(',') as [string, string];
  } else if (dots === 1 && commas === 0) {
    const [i, f] = s.split('.') as [string, string];
    // "1.234" (thousands) vs "1234.5" (decimal): treat 3-digit group after a dot as thousands
    if (f.length === 3 && i.length <= 3) { intPart = i + f; } else { intPart = i; fracPart = f; }
  } else if (commas === 1 && dots >= 1) {
    if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
      const [i, f] = s.split(',') as [string, string];
      if (!/^\d{1,3}(\.\d{3})+$/.test(i)) return null;
      intPart = i.replace(/\./g, ''); fracPart = f;
    } else {
      const [i, f] = s.split('.') as [string, string];
      if (!/^\d{1,3}(,\d{3})+$/.test(i)) return null;
      intPart = i.replace(/,/g, ''); fracPart = f;
    }
  } else if (commas === 0 && dots === 0) {
    intPart = s;
  } else if (commas === 0 && dots > 1) {
    if (!/^\d{1,3}(\.\d{3})+$/.test(s)) return null;
    intPart = s.replace(/\./g, '');
  } else {
    return null;
  }
  if (!/^\d+$/.test(intPart) || !/^\d{0,2}$/.test(fracPart)) return null;
  const value = Number(intPart) * 100 + Number((fracPart + '00').slice(0, 2));
  if (!Number.isSafeInteger(value)) return null;
  return negative ? -value || 0 : value;
}

export interface FormatOptions { hidden?: boolean; currency?: string; locale?: string; }

const formatters = new Map<string, Intl.NumberFormat>();
function formatter(locale: string, currency: string): Intl.NumberFormat {
  const key = locale + '|' + currency;
  let f = formatters.get(key);
  if (!f) { f = new Intl.NumberFormat(locale, { style: 'currency', currency }); formatters.set(key, f); }
  return f;
}

export function formatBRL(value: Cents, opts: FormatOptions = {}): string {
  const locale = opts.locale ?? 'pt-BR';
  const currency = opts.currency ?? 'BRL';
  if (opts.hidden) {
    const symbol = formatter(locale, currency).formatToParts(0).find((p) => p.type === 'currency')?.value ?? currency;
    return `${symbol} ••••`;
  }
  const v = assertCents(value);
  return formatter(locale, currency).format((v === 0 ? 0 : v) / 100); // normalizes -0
}

/** Alias: formats any currency using locale; BRL by default. */
export const formatMoney = formatBRL;
