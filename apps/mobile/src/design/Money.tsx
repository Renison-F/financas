import React from 'react';
import { View } from 'react-native';
import { formatBRL, type Cents } from '@financas/core';
import { Text } from './Text';
import type { ColorToken, TypeRole } from './tokens';
import { usePrivacy } from './privacy';

export interface MoneyProps { cents: Cents; role?: TypeRole; /** color by sign (Regra do Sinal) */ signed?: boolean; color?: ColorToken; showPlus?: boolean; currency?: string; hidden?: boolean; testID?: string; }

/** Reads as "mil duzentos e trinta e quatro reais e cinquenta e seis centavos" for screen readers. */
export function moneyAccessibilityLabel(cents: Cents, currency = 'BRL'): string {
  const abs = Math.abs(cents);
  const reais = Math.floor(abs / 100), cent = abs % 100;
  const unit = currency === 'BRL' ? (reais === 1 ? 'real' : 'reais') : currency;
  const parts = [`${reais} ${unit}`];
  if (cent) parts.push(`${cent} ${cent === 1 ? 'centavo' : 'centavos'}`);
  return `${cents < 0 ? 'menos ' : ''}${parts.join(' e ')}`;
}

export function Money({ cents, role = 'moneyRow', signed = false, color, showPlus = false, currency = 'BRL', hidden, testID }: MoneyProps) {
  const privacy = usePrivacy();
  const isHidden = hidden ?? privacy.hidden;
  const tone: ColorToken = color ?? (signed ? (cents < 0 ? 'negative' : cents > 0 ? 'positive' : 'text') : 'text');
  const text = formatBRL(cents, { currency, hidden: isHidden });
  const label = isHidden ? 'valor oculto' : moneyAccessibilityLabel(cents, currency);
  if (role === 'moneyHero' && !isHidden) {
    // "Regra dos Centavos": cents at 60% size in the hero.
    const idx = text.lastIndexOf(',');
    const main = idx >= 0 ? text.slice(0, idx) : text;
    const cent = idx >= 0 ? text.slice(idx) : '';
    return (
      <View accessible accessibilityLabel={label} testID={testID} style={{ flexDirection: 'row', alignItems: 'flex-end' }}>
        <Text role="moneyHero" color={tone} tabular>{showPlus && cents > 0 ? '+' : ''}{main}</Text>
        <Text role="moneyHero" color={tone} tabular style={{ fontSize: 26, lineHeight: 40, fontFamily: 'BricolageGrotesque_600SemiBold' }}>{cent}</Text>
      </View>
    );
  }
  return <Text role={role} color={tone} tabular accessibilityLabel={label} testID={testID}>{showPlus && cents > 0 ? '+' : ''}{text}</Text>;
}
