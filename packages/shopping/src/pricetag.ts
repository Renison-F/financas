import { parseMoneyBR, type Cents } from '@financas/core';
import { parseUnit, type Unit } from './units';

/**
 * Parser for OCR text of Brazilian shelf price tags. Pure and engine-agnostic: it receives the lines
 * recognized by ML Kit (or any OCR) and returns the best interpretation with a confidence score and
 * the alternatives, so the user confirms before anything is added to the cart.
 */
export interface OCRLine { text: string; confidence?: number | undefined; /** bounding box height in px, used to weight the biggest number as the price */ height?: number | undefined; y?: number | undefined; }

export interface PriceCandidate { cents: Cents; source: string; score: number; kind: 'price' | 'promo_from' | 'promo_to' | 'per_unit' | 'installment'; unit?: Unit | undefined; }

export interface PriceTagReading {
  name?: string | undefined;
  brand?: string | undefined;
  /** presentation like "500 g", "1,5 L", "12 un" */
  presentation?: { quantity: number; unit: Unit } | undefined;
  priceCents?: Cents | undefined;
  promoFromCents?: Cents | undefined;
  pricePerUnit?: { cents: Cents; unit: Unit } | undefined;
  /** unit the main price refers to (kg for weighed goods) */
  priceUnit: Unit;
  internalCode?: string | undefined;
  barcode?: string | undefined;
  confidence: number; // 0..1
  candidates: PriceCandidate[];
  warnings: string[];
}

const MONEY_RE = /(?:R\$\s*)?(\d{1,3}(?:\.\d{3})*|\d+)\s*[,.]\s*(\d{2})(?!\d)/g;
const PER_UNIT_RE = /(?:R\$\s*)?(\d{1,3}(?:\.\d{3})*|\d+)[,.](\d{2})(?:\s*(?:\/|por|p\/)\s*|\s+(?:o\s+|a\s+)?)(kg|g|l|lt|ml|un|und|m)\b/i;
const PRESENTATION_RE = /(\d+(?:[,.]\d+)?)\s*(kg|g|gr|l|lt|ml|un|und|unid|pç|pc|m)\b/i;
const PROMO_FROM_RE = /\bde\s*(?:R\$)?\s*(\d{1,3}(?:\.\d{3})*|\d+)[,.](\d{2})/i;
const PROMO_TO_RE = /\bpor\s*(?:R\$)?\s*(\d{1,3}(?:\.\d{3})*|\d+)[,.](\d{2})/i;
const INSTALLMENT_RE = /(\d{1,2})\s*x\s*(?:de\s*)?(?:R\$)?\s*(\d{1,3}(?:\.\d{3})*|\d+)[,.](\d{2})/i;
const CODE_RE = /\b(?:cod|cód|codigo|código|sku)[.:\s]*(\d{3,8})\b/i;
const BARCODE_RE = /\b(\d{13}|\d{8})\b/;
const NOISE_RE = /^(?:oferta|promo[cç][aã]o|desconto|leve|pague|economize|preço|preco|valor|unid|un\.?|clube|app|s[oó] hoje|validade|at[eé]|apenas|a partir de)\b/i;

const toCents = (int: string, frac: string): Cents | null => parseMoneyBR(`${int},${frac}`);

export function parsePriceTag(lines: OCRLine[]): PriceTagReading {
  const warnings: string[] = [];
  const candidates: PriceCandidate[] = [];
  const text = lines.map((l) => l.text).join('\n');
  const maxHeight = Math.max(1, ...lines.map((l) => l.height ?? 0));

  // 1) explicit structures first
  const perUnit = text.match(PER_UNIT_RE);
  let pricePerUnit: PriceTagReading['pricePerUnit'];
  if (perUnit) { const c = toCents(perUnit[1]!, perUnit[2]!); const u = parseUnit(perUnit[3]!); if (c !== null && u) { pricePerUnit = { cents: c, unit: u }; candidates.push({ cents: c, source: perUnit[0], score: 0.6, kind: 'per_unit', unit: u }); } }
  const promoTo = text.match(PROMO_TO_RE); const promoFrom = text.match(PROMO_FROM_RE);
  let promoFromCents: Cents | undefined;
  if (promoFrom) { const c = toCents(promoFrom[1]!, promoFrom[2]!); if (c !== null) { promoFromCents = c; candidates.push({ cents: c, source: promoFrom[0], score: 0.3, kind: 'promo_from' }); } }
  if (promoTo) { const c = toCents(promoTo[1]!, promoTo[2]!); if (c !== null) candidates.push({ cents: c, source: promoTo[0], score: 0.95, kind: 'promo_to' }); }
  const inst = text.match(INSTALLMENT_RE);
  if (inst) { const c = toCents(inst[2]!, inst[3]!); if (c !== null) candidates.push({ cents: c, source: inst[0], score: 0.2, kind: 'installment' }); }

  // 2) every money-looking token, weighted by glyph height (the big number is the price) and position
  for (const line of lines) {
    const re = new RegExp(MONEY_RE.source, 'g');
    let m: RegExpExecArray | null;
    while ((m = re.exec(line.text))) {
      const c = toCents(m[1]!, m[2]!);
      if (c === null || c === 0) continue;
      if (candidates.some((k) => k.cents === c && k.kind !== 'price')) continue;
      const heightScore = line.height ? (line.height / maxHeight) * 0.6 : 0.3;
      const confScore = (line.confidence ?? 0.7) * 0.3;
      const hasSymbol = /R\$/.test(line.text) ? 0.1 : 0;
      candidates.push({ cents: c, source: line.text.trim(), score: Math.min(0.9, heightScore + confScore + hasSymbol), kind: 'price' });
    }
  }
  // demote values that are clearly a per-unit reference when a bigger price exists
  const priceCandidates = candidates.filter((c) => c.kind === 'price' || c.kind === 'promo_to').sort((a, b) => b.score - a.score);
  const best = priceCandidates[0];
  let priceCents = best?.cents;
  if (pricePerUnit && priceCents !== undefined && pricePerUnit.cents === priceCents && priceCandidates.length > 1) priceCents = priceCandidates[1]!.cents;

  // 3) presentation & unit for the price
  // presentation is searched with money tokens removed, so "R$ 6,99 kg" never becomes "6,99 kg of product"
  const textNoMoney = text.replace(new RegExp(MONEY_RE.source, 'g'), ' ');
  const pres = textNoMoney.match(PRESENTATION_RE);
  let presentation: PriceTagReading['presentation'];
  if (pres) { const u = parseUnit(pres[2]!); const q = Number(pres[1]!.replace(',', '.')); if (u && Number.isFinite(q) && q > 0) presentation = { quantity: q, unit: u }; }
  let priceUnit: Unit = 'un';
  if (priceCents === undefined && pricePerUnit) { priceCents = pricePerUnit.cents; priceUnit = pricePerUnit.unit; }
  else if (pricePerUnit && priceCents !== undefined && pricePerUnit.cents === priceCents) priceUnit = pricePerUnit.unit;
  else if (/\bkg\b/i.test(text) && !presentation) priceUnit = 'kg';

  // 4) name: the longest alphabetic line that is not noise, not a price, not a code
  const nameLine = lines
    .map((l) => l.text.trim())
    .filter((t) => t.length >= 3 && /[a-zA-ZÀ-ÿ]{3,}/.test(t) && !NOISE_RE.test(t) && !/R\$|\d+[,.]\d{2}/.test(t) && !CODE_RE.test(t) && !BARCODE_RE.test(t))
    .sort((a, b) => b.length - a.length)[0];
  const name = nameLine?.replace(/\s+/g, ' ');
  const code = text.match(CODE_RE)?.[1];
  const barcode = text.match(BARCODE_RE)?.[1];

  // 5) confidence
  let confidence = 0;
  if (priceCents !== undefined) confidence += best ? Math.min(0.6, best.score * 0.65) : pricePerUnit ? 0.45 : 0;
  if (name) confidence += 0.25;
  if (presentation || pricePerUnit) confidence += 0.1;
  if (priceCandidates.length > 1 && priceCandidates[1]!.score >= (best?.score ?? 0) - 0.1) { confidence -= 0.15; warnings.push('Mais de um preço parecido na etiqueta; confirme o valor.'); }
  if (!priceCents) warnings.push('Nenhum preço reconhecido; informe manualmente.');
  if (!name) warnings.push('Nome do produto não reconhecido.');
  if (lines.some((l) => (l.confidence ?? 1) < 0.5)) confidence -= 0.1;
  confidence = Math.max(0, Math.min(1, Math.round(confidence * 100) / 100));

  return { name, presentation, priceCents, promoFromCents, pricePerUnit, priceUnit, internalCode: code, barcode, confidence, candidates: candidates.sort((a, b) => b.score - a.score), warnings };
}
