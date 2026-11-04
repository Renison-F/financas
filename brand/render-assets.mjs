// Renders brand SVGs to the PNG sizes Expo needs (Playwright + Chromium required).
// Run: node brand/render-assets.mjs   (or PLAYWRIGHT_PATH=/path/to/playwright node brand/render-assets.mjs)
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
function loadPlaywright() {
  for (const c of [process.env.PLAYWRIGHT_PATH, 'playwright', '/opt/node-tools/node_modules/playwright'].filter(Boolean)) {
    try { return require(c); } catch {}
  }
  throw new Error('Playwright não encontrado. Instale `playwright` ou defina PLAYWRIGHT_PATH.');
}
const { chromium } = loadPlaywright();
import { readFileSync, mkdirSync } from 'node:fs';
import { resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const out = resolve(root, 'apps/mobile/assets');
mkdirSync(out, { recursive: true });
const jobs = [
  ['app-icon.svg', 'icon.png', 1024, 1024, null],
  ['adaptive-foreground.svg', 'android-icon-foreground.png', 1024, 1024, null],
  ['adaptive-monochrome.svg', 'android-icon-monochrome.png', 1024, 1024, null],
  [null, 'android-icon-background.png', 1024, 1024, '#0F5C45'],
  ['splash-icon.svg', 'splash-icon.png', 400, 400, null],
  ['app-icon.svg', 'favicon.png', 48, 48, null],
  ['wordmark.svg', '../../../brand/wordmark.png', 900, 240, null],
];
const browser = await chromium.launch();
const page = await browser.newPage();
for (const [svg, png, w, h, solid] of jobs) {
  const body = solid
    ? `<div style="width:${w}px;height:${h}px;background:${solid}"></div>`
    : readFileSync(resolve(root, 'brand', svg), 'utf8').replace(/width="\d+" height="\d+"/, `width="${w}" height="${h}"`);
  await page.setViewportSize({ width: w, height: h });
  await page.setContent(`<html><body style="margin:0;background:transparent">${body}</body></html>`);
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({ path: resolve(out, png), omitBackground: true, clip: { x: 0, y: 0, width: w, height: h } });
  console.log('wrote', png);
}
await browser.close();
