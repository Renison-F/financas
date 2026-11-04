// WCAG contrast check for the DESIGN.md palette (Prumo). Run: node docs/qa/contrast-check.mjs
const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255).map((c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4));
const L = (h) => { const [r, g, b] = hex(h); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
const cr = (a, b) => { const x = L(a), y = L(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
const themes = {
  light: { bg: '#F6F3EC', surface: '#FFFFFF', inset: '#EEEAE0', text: '#1B1F24', muted: '#5B6670', primary: '#24477A', onPrimary: '#FFFFFF', primaryContainer: '#D9E4F4', onPrimaryContainer: '#14294A', accent: '#B07A1E', positive: '#176B4E', negative: '#A3362A', negativeContainer: '#F7DDD6', warning: '#8A5200', warningContainer: '#F6E3BE', borderStrong: '#78857D' },
  dark: { bg: '#0F1419', surface: '#181E26', inset: '#222A34', text: '#ECEDE8', muted: '#A6ADB6', primary: '#8FB4F0', onPrimary: '#0F1419', primaryContainer: '#1C3356', onPrimaryContainer: '#CFE0FA', accent: '#E3B35A', positive: '#6FD3A8', negative: '#F0907F', negativeContainer: '#4A1F18', warning: '#F2B86B', warningContainer: '#4A3410', borderStrong: '#6C7784' },
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
