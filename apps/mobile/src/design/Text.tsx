import React from 'react';
import { Text as RNText, type TextProps as RNTextProps, type TextStyle } from 'react-native';
import { typeScale, type TypeRole, type ColorToken } from './tokens';
import { useColors } from './theme';

export interface TextProps extends Omit<RNTextProps, 'role'> { role?: TypeRole; color?: ColorToken; align?: TextStyle['textAlign'] | undefined; tabular?: boolean | undefined; }

/** Typography roles from DESIGN.md. Uses system font for body roles and Bricolage Grotesque for display roles. */
export function Text({ role = 'body', color = 'text', align, tabular, style, maxFontSizeMultiplier, ...rest }: TextProps) {
  const colors = useColors();
  const t = typeScale[role];
  const s: TextStyle = {
    fontSize: t.fontSize, lineHeight: t.lineHeight, color: colors[color], textAlign: align,
    ...(t.fontFamily ? { fontFamily: t.fontFamily } : t.fontWeight ? { fontWeight: t.fontWeight } : {}),
    ...(t.letterSpacing !== undefined ? { letterSpacing: t.letterSpacing } : {}),
    ...(tabular ? { fontVariant: ['tabular-nums' as const] } : {}),
  };
  // Money hero shrinks instead of overflowing at large font scales; others follow Dynamic Type up to 2x.
  const maxMult = maxFontSizeMultiplier ?? (role === 'moneyHero' ? 1.3 : 2);
  return <RNText accessibilityRole={role === 'headline' || role === 'display' || role === 'title' ? 'header' : undefined} maxFontSizeMultiplier={maxMult} style={[s, style]} {...rest} />;
}
