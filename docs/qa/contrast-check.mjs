// WCAG contrast check for the DESIGN.md palette. Run: node docs/qa/contrast-check.mjs
const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255).map((c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4));
const L = (h) => { const [r, g, b] = hex(h); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
const cr = (a, b) => { const x = L(a), y = L(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
const themes = {
  light: { bg: '#F6F3EC', surface: '#FFFFFF', inset: '#EEEAE0', text: '#1B211E', muted: '#5B6962', primary: '#0F5C45', onPrimary: '#FFFFFF', primaryContainer: '#D7EFE3', onPrimaryContainer: '#0A3B2D', positive: '#176B4E', negative: '#A3362A', negativeContainer: '#F7DDD6', warning: '#8A5200', warningContainer: '#F6E3BE', borderStrong: '#78857D' },
  dark: { bg: '#0E1311', surface: '#171D1A', inset: '#202825', text: '#ECEDE8', muted: '#A3ADA7', primary: '#6FD3A8', onPrimary: '#0E1311', primaryContainer: '#134A38', onPrimaryContainer: '#C8F0DE', positive: '#6FD3A8', negative: '#F0907F', negativeContainer: '#4A1F18', warning: '#F2B86B', warningContainer: '#4A3410', borderStrong: '#5E6B65' },
};
let failures = 0;
for (const [name, t] of Object.entries(themes)) {
  const checks = [];
  for (const fg of ['text', 'muted', 'primary', 'positive', 'negative', 'warning']) for (const bg of ['bg', 'surface', 'inset']) checks.push([fg, bg, 4.5]);
  checks.push(['onPrimary', 'primary', 4.5], ['onPrimaryContainer', 'primaryContainer', 4.5], ['negative', 'negativeContainer', 4.5], ['warning', 'warningContainer', 4.5], ['borderStrong', 'bg', 3], ['borderStrong', 'surface', 3]);
  for (const [fg, bg, min] of checks) {
    const r = cr(t[fg], t[bg]);
    const ok = r >= min;
    if (!ok) failures++;
    console.log(`${ok ? 'OK  ' : 'FAIL'} ${name.padEnd(5)} ${fg.padEnd(18)} on ${bg.padEnd(16)} ${r.toFixed(2)} (min ${min})`);
  }
}
if (failures) { console.error(`${failures} contrast failure(s)`); process.exit(1); }
console.log('All contrast checks passed');
