import React from 'react';
import { View } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { useColors } from './theme';
import { radius } from './tokens';
import { Text } from './Text';

export type RhythmState = 'sereno' | 'atencao' | 'agitado';
export const RHYTHM_LABEL: Record<RhythmState, string> = { sereno: 'sereno', atencao: 'atenção', agitado: 'agitado' };

export interface RhythmBarProps { percent: number; /** expected position today, 0..100; omit to hide the marker */ expectedPercent?: number | undefined; state?: RhythmState | undefined; label?: string; testID?: string; }

/** "Barra de ritmo": track + fill + "marca de hoje" (a small wave on a thin line) — DESIGN.md signature component. */
export function RhythmBar({ percent, expectedPercent, state, label, testID }: RhythmBarProps) {
  const c = useColors();
  const pct = Math.max(0, Math.min(100, percent));
  const over = percent > 100;
  const fill = state === 'agitado' || over ? c.negative : state === 'atencao' ? c.warning : c.primary;
  return (
    <View testID={testID} accessible accessibilityRole="progressbar" accessibilityLabel={label ?? `${Math.round(percent)}% do limite`} accessibilityValue={{ min: 0, max: 100, now: Math.round(pct) }} style={{ paddingTop: expectedPercent !== undefined ? 10 : 0 }}>
      <View style={{ height: 12, borderRadius: radius.xs, backgroundColor: c.surfaceInset, overflow: 'visible' }}>
        <View style={{ height: 12, width: `${pct}%`, borderRadius: radius.xs, backgroundColor: fill }} />
        {expectedPercent !== undefined ? (
          <View pointerEvents="none" style={{ position: 'absolute', left: `${Math.max(0, Math.min(100, expectedPercent))}%`, top: -10, marginLeft: -6, alignItems: 'center' }}>
            <Svg width={12} height={6} viewBox="0 0 12 6"><Path d="M1 4 C3 1 5 1 6 4 S9 7 11 4" stroke={c.accent} strokeWidth={1.75} fill="none" strokeLinecap="round" /></Svg>
            <View style={{ width: 2, height: 16, backgroundColor: c.accent, borderRadius: 1 }} />
          </View>
        ) : null}
      </View>
      {over ? <Text role="caption" color="negative" style={{ marginTop: 4 }}>{Math.round(percent - 100)}% acima do limite</Text> : null}
    </View>
  );
}
