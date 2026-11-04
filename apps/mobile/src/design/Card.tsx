import React from 'react';
import { View, type ViewProps } from 'react-native';
import { useColors } from './theme';
import { radius, spacing } from './tokens';
import { Text } from './Text';

export function Card({ style, children, inset, ...rest }: ViewProps & { inset?: boolean }) {
  const c = useColors();
  return <View style={[{ backgroundColor: inset ? c.surfaceInset : c.surface, borderRadius: inset ? radius.md : radius.lg, padding: inset ? spacing.sm : spacing.md }, style]} {...rest}>{children}</View>;
}

export function CardHeader({ title, action }: { title: string; action?: React.ReactNode }) {
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: spacing.sm, minHeight: 28 }}>
      <Text role="title">{title}</Text>
      {action}
    </View>
  );
}

export function Divider() { const c = useColors(); return <View style={{ height: 1, backgroundColor: c.border, marginVertical: spacing.xs }} />; }
