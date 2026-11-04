/** Barcode and QR helpers. A barcode identifies a product; it never carries a shelf price (except GS1 variable-measure codes). */
export type BarcodeKind = 'ean13' | 'ean8' | 'upc_a' | 'upc_e' | 'gs1_variable_measure' | 'internal' | 'unknown';

export interface ParsedBarcode {
  raw: string;
  kind: BarcodeKind;
  valid: boolean;
  /** GTIN-13 normalized (UPC-A padded) when applicable */
  gtin?: string | undefined;
  /** For in-store variable measure codes (prefix 2): item code and embedded price or weight */
  variableMeasure?: { itemCode: string; embedded: 'price' | 'weight' | 'unknown'; valueCents?: number | undefined; grams?: number | undefined } | undefined;
}

export function gtinChecksumValid(digits: string): boolean {
  if (!/^\d{8}$|^\d{12,14}$/.test(digits)) return false;
  const body = digits.slice(0, -1), check = Number(digits.slice(-1));
  let sum = 0;
  for (let i = 0; i < body.length; i++) {
    const d = Number(body[body.length - 1 - i]);
    sum += d * (i % 2 === 0 ? 3 : 1);
  }
  return (10 - (sum % 10)) % 10 === check;
}

/**
 * Parses a scanned barcode. Brazilian in-store variable-measure labels (bakery, deli, produce) use
 * prefix "2": 2IIIIIVVVVVC where IIIII = item, VVVVV = price in cents or weight in grams (store-defined),
 * C = check digit. We do NOT assume which one: the UI must confirm (the briefing forbids inventing prices).
 */
export function parseBarcode(raw: string): ParsedBarcode {
  const s = raw.replace(/\s+/g, '');
  if (!/^\d+$/.test(s)) return { raw, kind: 'unknown', valid: false };
  if (s.length === 13) {
    const valid = gtinChecksumValid(s);
    if (s.startsWith('2') && /^2[0-9]{12}$/.test(s)) {
      const value = Number(s.slice(7, 12));
      return { raw, kind: 'gs1_variable_measure', valid, gtin: s, variableMeasure: { itemCode: s.slice(1, 7), embedded: 'unknown', valueCents: value, grams: value } };
    }
    return { raw, kind: 'ean13', valid, gtin: s };
  }
  if (s.length === 8) return { raw, kind: 'ean8', valid: gtinChecksumValid(s), gtin: '00000' + s };
  if (s.length === 12) return { raw, kind: 'upc_a', valid: gtinChecksumValid(s), gtin: '0' + s };
  if (s.length === 14) return { raw, kind: 'ean13', valid: gtinChecksumValid(s), gtin: s.slice(1) };
  if (s.length >= 4 && s.length <= 7) return { raw, kind: 'internal', valid: true };
  return { raw, kind: 'unknown', valid: false };
}

/** Brazilian NFC-e QR code: URL with `p=` param "chave|versao|ambiente|[cIdToken]|assinatura". */
export interface NFCeQR { accessKey: string; uf?: string | undefined; emissionYearMonth?: string | undefined; cnpj?: string | undefined; url: string; }

export function parseNFCeQR(data: string): NFCeQR | null {
  const m = data.match(/[?&]p=([0-9]{44})\|/i) ?? data.match(/chNFe=([0-9]{44})/i);
  if (!m) return null;
  const key = m[1]!;
  return { accessKey: key, uf: key.slice(0, 2), emissionYearMonth: `20${key.slice(2, 4)}-${key.slice(4, 6)}`, cnpj: key.slice(6, 20), url: data };
}
