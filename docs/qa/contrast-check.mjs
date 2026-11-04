// WCAG contrast check for the DESIGN.md palette (SerenaCash). Run: node docs/qa/contrast-check.mjs
const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255).map((c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4));
const L = (h) => { const [r, g, b] = hex(h); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
const cr = (a, b) => { const x = L(a), y = L(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
export const themes = {
  light: { bg: '#F3F6F5', surface: '#FFFFFF', inset: '#E6ECEA', text: '#162022', muted: '#4F5E61', primary: '#0B5563', onPrimary: '#FFFFFF', primaryContainer: '#D4ECEF', onPrimaryContainer: '#083E48', accent: '#C0703E', positive: '#176B4E', negative: '#A93A29', negativeContainer: '#F7DDD6', warning: '#8A5200', warningContainer: '#F6E3BE', borderStrong: '#74848A' },
  dark: { bg: '#0C1517', surface: '#152022', inset: '#1E2B2E', text: '#E8EEEC', muted: '#A3B1B3', primary: '#6FC8D6', onPrimary: '#0C1517', primaryContainer: '#123F48', onPrimaryContainer: '#C8ECF2', accent: '#F0B48A', positive: '#6FD3A8', negative: '#F0907F', negativeContainer: '#4A1F18', warning: '#F2B86B', warningContainer: '#4A3410', borderStrong: '#71818A' },
};
let failures = 0;
for (const [name, t] of Object.entries(themes)) {
  const checks = [];
  for (const fg of ['text', 'muted', 'primary', 'positive', 'negative', 'warning']) for (const bg of ['bg', 'surface', 'inset']) checks.push([fg, bg, 4.5]);
  checks.push(['onPrimary', 'primary', 4.5], ['onPrimaryContainer', 'primaryContainer', 4.5], ['negative', 'negativeContainer', 4.5], ['warning', 'warningContainer', 4.5], ['borderStrong', 'bg', 3], ['borderStrong', 'surface', 3], ['borderStrong', 'inset', 3], ['accent', 'bg', 3], ['accent', 'inset', 3]);
  for (const [fg, bg, min] of checks) {
    const r = cr(t[fg], t[bg]);
    const ok = r >= min;
    if (!ok) failures++;
    console.log(`${ok ? 'OK  ' : 'FAIL'} ${name.padEnd(5)} ${fg.padEnd(18)} on ${bg.padEnd(16)} ${r.toFixed(2)} (min ${min})`);
  }
}
if (failures) { console.error(`${failures} contrast failure(s)`); process.exit(1); }
console.log('All contrast checks passed');
