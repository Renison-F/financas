import React, { createContext, useContext, useMemo } from 'react';
import { useColorScheme } from 'react-native';
import { palette, type ColorScheme, type Colors } from './tokens';

export type ThemePreference = 'system' | 'light' | 'dark';

export interface Theme { scheme: ColorScheme; colors: Colors; preference: ThemePreference; }

const ThemeContext = createContext<Theme>({ scheme: 'light', colors: palette.light, preference: 'system' });

export function ThemeProvider({ preference, children }: { preference: ThemePreference; children: React.ReactNode }) {
  const system = useColorScheme();
  const scheme: ColorScheme = preference === 'system' ? (system === 'dark' ? 'dark' : 'light') : preference;
  const value = useMemo<Theme>(() => ({ scheme, colors: palette[scheme], preference }), [scheme, preference]);
  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export const useTheme = () => useContext(ThemeContext);
export const useColors = () => useContext(ThemeContext).colors;
