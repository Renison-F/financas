import { describe, it, expect } from 'vitest';
import { WIDGETS, WIDGET_IDS, DEFAULT_LAYOUT, applyPreset, showWidget, hideWidget, moveWidget, moveWidgetBy, hiddenWidgets, normalizeLayout, PRESETS } from './widgets';

describe('dashboard widgets', () => {
  it('has the 24 widgets required by the brief with unique ids', () => {
    expect(WIDGETS).toHaveLength(24);
    expect(new Set(WIDGET_IDS).size).toBe(24);
  });
  it('presets only reference known widgets', () => {
    for (const p of Object.values(PRESETS)) for (const id of p.widgets) expect(WIDGET_IDS).toContain(id);
  });
  it('show/hide/move keep order consistent', () => {
    let l = applyPreset(DEFAULT_LAYOUT, 'focus');
    expect(l.order).toEqual(['available', 'bills_to_pay', 'recent_transactions']);
    l = showWidget(l, 'goals', 1);
    expect(l.order[1]).toBe('goals');
    l = showWidget(l, 'goals'); // idempotent
    expect(l.order.filter((x) => x === 'goals')).toHaveLength(1);
    l = moveWidgetBy(l, 'goals', -1);
    expect(l.order[0]).toBe('goals');
    l = moveWidgetBy(l, 'goals', -1); // clamps at top
    expect(l.order[0]).toBe('goals');
    l = moveWidget(l, 'goals', 99);
    expect(l.order[l.order.length - 1]).toBe('goals');
    l = hideWidget(l, 'goals');
    expect(l.order).not.toContain('goals');
    expect(hiddenWidgets(l)).toContain('goals');
  });
  it('normalizes corrupted layouts', () => {
    const l = normalizeLayout({ order: ['available', 'bogus', 'available', 'goals'], period: 'weird', privacyMode: 'yes', accountIds: ['a', 2] });
    expect(l).toEqual({ order: ['available', 'goals'], period: 'current_month', selectedMonth: undefined, accountIds: ['a'], privacyMode: false, version: 1 });
    expect(normalizeLayout(null).order).toEqual(DEFAULT_LAYOUT.order);
  });
});
