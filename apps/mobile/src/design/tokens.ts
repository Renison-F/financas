/** Normative tokens mirror DESIGN.md (SerenaCash). Semantic names only; screens never use raw hex. */
export const palette = {
  light: {
    bg: '#F3F6F5', surface: '#FFFFFF', surfaceInset: '#E6ECEA', border: '#D3DCDA', borderStrong: '#74848A',
    text: '#162022', textMuted: '#4F5E61', primary: '#0B5563', onPrimary: '#FFFFFF', primaryContainer: '#D4ECEF', onPrimaryContainer: '#083E48',
    accent: '#C0703E', positive: '#176B4E', positiveContainer: '#D7EFE3', negative: '#A93A29', negativeContainer: '#F7DDD6', warning: '#8A5200', warningContainer: '#F6E3BE',
    overlay: 'rgba(22,32,34,0.45)', shadow: 'rgba(22,32,34,0.14)',
  },
  dark: {
    bg: '#0C1517', surface: '#152022', surfaceInset: '#1E2B2E', border: '#263437', borderStrong: '#71818A',
    text: '#E8EEEC', textMuted: '#A3B1B3', primary: '#6FC8D6', onPrimary: '#0C1517', primaryContainer: '#123F48', onPrimaryContainer: '#C8ECF2',
    accent: '#F0B48A', positive: '#6FD3A8', positiveContainer: '#134A38', negative: '#F0907F', negativeContainer: '#4A1F18', warning: '#F2B86B', warningContainer: '#4A3410',
    overlay: 'rgba(0,0,0,0.55)', shadow: 'rgba(0,0,0,0.5)',
  },
} as const;

export type ColorScheme = keyof typeof palette;
export type Colors = (typeof palette)[ColorScheme];
export type ColorToken = keyof Colors;

export const spacing = { xxs: 4, xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 48 } as const;
export const radius = { xs: 6, sm: 10, md: 14, lg: 20, pill: 999 } as const;

export const fonts = {
  display: 'BricolageGrotesque_600SemiBold',
  displayBold: 'BricolageGrotesque_700Bold',
  /** body uses the platform font (SF Pro / Roboto) on purpose */
  body: undefined as string | undefined,
} as const;

export type TypeRole = 'moneyHero' | 'display' | 'headline' | 'title' | 'body' | 'bodySmall' | 'label' | 'moneyRow' | 'caption';

export const typeScale: Record<TypeRole, { fontSize: number; lineHeight: number; fontFamily?: string | undefined; fontWeight?: '400' | '500' | '600' | '700'; letterSpacing?: number }> = {
  moneyHero: { fontSize: 44, lineHeight: 46, fontFamily: fonts.displayBold, letterSpacing: -1.3 },
  display: { fontSize: 40, lineHeight: 42, fontFamily: fonts.display, letterSpacing: -0.8 },
  headline: { fontSize: 28, lineHeight: 32, fontFamily: fonts.display, letterSpacing: -0.4 },
  title: { fontSize: 20, lineHeight: 25, fontFamily: fonts.display, letterSpacing: -0.2 },
  body: { fontSize: 17, lineHeight: 24, fontWeight: '400' },
  bodySmall: { fontSize: 15, lineHeight: 21, fontWeight: '400' },
  label: { fontSize: 13, lineHeight: 17, fontWeight: '500', letterSpacing: 0.1 },
  moneyRow: { fontSize: 17, lineHeight: 22, fontWeight: '600' },
  caption: { fontSize: 12, lineHeight: 16, fontWeight: '400' },
};

export const touch = { min: 44, comfortable: 52 } as const;
export const motion = { fast: 120, base: 220, slow: 320 } as const;
