import { moneyAccessibilityLabel } from './Money';
import { formatBRL } from '@financas/core';

describe('Money accessibility and privacy', () => {
  it('reads amounts in words-friendly form for screen readers', () => {
    expect(moneyAccessibilityLabel(123456)).toBe('1234 reais e 56 centavos');
    expect(moneyAccessibilityLabel(100)).toBe('1 real');
    expect(moneyAccessibilityLabel(1)).toBe('0 reais e 1 centavo');
    expect(moneyAccessibilityLabel(-500)).toBe('menos 5 reais');
  });
  it('hides values in privacy mode and never shows negative zero', () => {
    expect(formatBRL(123456, { hidden: true })).toBe('R$ ••••');
    expect(formatBRL(-0)).toBe('R$ 0,00');
  });
});
