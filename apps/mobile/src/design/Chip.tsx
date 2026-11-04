import React from 'react';
import { Pressable } from 'react-native';
import { Text } from './Text';
import { useColors } from './theme';
import { radius, spacing } from './tokens';
import { Icon } from './icons';

export function Chip({ label, selected, onPress, testID }: { label: string; selected?: boolean; onPress?: () => void; testID?: string }) {
  const c = useColors();
  return (
    <Pressable testID={testID} accessibilityRole="button" accessibilityState={{ selected: !!selected }} onPress={onPress} style={{ height: 36, paddingHorizontal: spacing.sm, borderRadius: radius.pill, backgroundColor: selected ? c.primaryContainer : c.surfaceInset, flexDirection: 'row', alignItems: 'center', gap: 6 }}>
      {selected ? <Icon name="check" size={16} color={c.onPrimaryContainer} /> : null}
      <Text role="label" color={selected ? 'onPrimaryContainer' : 'text'}>{label}</Text>
    </Pressable>
  );
}
