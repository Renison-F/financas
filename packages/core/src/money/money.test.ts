import { describe, it, expect } from 'vitest';
import {
  cents, addCents, subCents, mulCents, divCents, allocate, parseMoneyBR, formatBRL, percentOf,
  assertCents, negate, sumCents, type Cents,
} from './money';

describe('cents()', () => {
  it('builds integer cents from a decimal amount', () => {
    expect(cents(24.9)).toBe(2490);
    expect(cents(0.1 + 0.2)).toBe(30); // float noise is removed
    expect(cents(-5.49)).toBe(-549);
    expect(cents(1e-3)).toBe(0);
  });
  it('rejects non-finite values', () => {
    expect(() => cents(NaN)).toThrow();
    expect(() => cents(Infinity)).toThrow();
  });
});

describe('assertCents()', () => {
  it('accepts safe integers', () => { expect(assertCents(100)).toBe(100); });
  it('rejects fractions and unsafe numbers', () => {
    expect(() => assertCents(1.5)).toThrow();
    expect(() => assertCents(2 ** 53)).toThrow();
  });
});

describe('arithmetic', () => {
  it('adds and subtracts without drift over many iterations', () => {
    let total: Cents = 0;
    for (let i = 0; i < 10000; i++) total = addCents(total, 1); // R$ 0,01 x 10.000
    expect(total).toBe(10000);
    expect(subCents(total, 10000)).toBe(0);
    expect(sumCents([1, 2, 3])).toBe(6);
    expect(negate(5)).toBe(-5);
  });
  it('multiplies by a factor with half-even rounding by default', () => {
    expect(mulCents(1000, 0.125)).toBe(125);
    expect(mulCents(1005, 0.5)).toBe(502); // 502.5 -> 502 (half even)
    expect(mulCents(1015, 0.5)).toBe(508); // 507.5 -> 508 (half even)
    expect(mulCents(699, 1.5)).toBe(1048); // 10,485 -> 10,48 (half-even); carts use half-up (below)
  });
  it('supports half-up rounding for cashier-style weighing', () => {
    expect(mulCents(699, 1.5, 'half-up')).toBe(1049); // 10,485 -> 10,49
    expect(mulCents(1005, 0.5, 'half-up')).toBe(503);
  });
  it('divides with rounding and rejects division by zero', () => {
    expect(divCents(1000, 3)).toBe(333);
    expect(() => divCents(1, 0)).toThrow();
  });
  it('computes percentages', () => {
    expect(percentOf(20000, 15)).toBe(3000);
    expect(percentOf(999, 33.33)).toBe(333);
  });
});

describe('allocate()', () => {
  it('splits into n parts that sum exactly to the total, remainder on the first parts', () => {
    expect(allocate(10000, 3)).toEqual([3334, 3333, 3333]);
    expect(allocate(100, 3)).toEqual([34, 33, 33]);
    expect(allocate(5, 10)).toEqual([1, 1, 1, 1, 1, 0, 0, 0, 0, 0]);
  });
  it('places the remainder on the last part when asked', () => {
    expect(allocate(10000, 3, 'last')).toEqual([3333, 3333, 3334]);
  });
  it('handles negative totals and n=1', () => {
    expect(allocate(-10000, 3)).toEqual([-3334, -3333, -3333]);
    expect(allocate(777, 1)).toEqual([777]);
  });
  it('rejects n < 1', () => { expect(() => allocate(100, 0)).toThrow(); });
  it('sums exactly for every n in a range', () => {
    for (let n = 1; n <= 60; n++) {
      const parts = allocate(123457, n);
      expect(parts.reduce((a, b) => a + b, 0)).toBe(123457);
      expect(Math.max(...parts) - Math.min(...parts)).toBeLessThanOrEqual(1);
    }
  });
});

describe('parseMoneyBR()', () => {
  it('parses Brazilian formats', () => {
    expect(parseMoneyBR('R$ 1.234,56')).toBe(123456);
    expect(parseMoneyBR('1234,56')).toBe(123456);
    expect(parseMoneyBR('24,9')).toBe(2490);
    expect(parseMoneyBR('24')).toBe(2400);
    expect(parseMoneyBR('-R$ 5,00')).toBe(-500);
    expect(parseMoneyBR('R$ -5,00')).toBe(-500);
    expect(parseMoneyBR(' 0,05 ')).toBe(5);
  });
  it('parses dot-decimal when unambiguous', () => {
    expect(parseMoneyBR('1234.56')).toBe(123456);
    expect(parseMoneyBR('1,234.56')).toBe(123456);
  });
  it('returns null for garbage', () => {
    expect(parseMoneyBR('')).toBeNull();
    expect(parseMoneyBR('abc')).toBeNull();
    expect(parseMoneyBR('1,2,3')).toBeNull();
  });
});

describe('formatBRL()', () => {
  it('formats with pt-BR conventions', () => {
    expect(formatBRL(123456)).toBe('R$ 1.234,56');
    expect(formatBRL(-500)).toBe('-R$ 5,00');
    expect(formatBRL(0)).toBe('R$ 0,00');
  });
  it('can hide the value for privacy mode', () => {
    expect(formatBRL(123456, { hidden: true })).toBe('R$ ••••');
  });
});
