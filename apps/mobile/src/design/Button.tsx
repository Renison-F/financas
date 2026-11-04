import React from 'react';
import { Pressable, ActivityIndicator, View, type ViewStyle, type StyleProp } from 'react-native';
import * as Haptics from 'expo-haptics';
import { Text } from './Text';
import { useColors } from './theme';
import { radius, spacing, touch } from './tokens';
import { Icon, type IconName } from './icons';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'destructive';

export interface ButtonProps { title: string; onPress: () => void; variant?: ButtonVariant; disabled?: boolean; loading?: boolean; icon?: IconName; fullWidth?: boolean; style?: StyleProp<ViewStyle>; accessibilityHint?: string; haptic?: boolean; testID?: string; compact?: boolean; }

export function Button({ title, onPress, variant = 'primary', disabled, loading, icon, fullWidth, style, accessibilityHint, haptic, testID, compact }: ButtonProps) {
  const c = useColors();
  const bg = { primary: c.primary, secondary: c.primaryContainer, ghost: 'transparent', destructive: c.negativeContainer }[variant];
  const fg = { primary: 'onPrimary', secondary: 'onPrimaryContainer', ghost: 'primary', destructive: 'negative' }[variant] as 'onPrimary' | 'onPrimaryContainer' | 'primary' | 'negative';
  const height = variant === 'ghost' || compact ? touch.min : touch.comfortable;
  return (
    <Pressable
      testID={testID}
      accessibilityRole="button" accessibilityLabel={title} accessibilityHint={accessibilityHint} accessibilityState={{ disabled: !!disabled || !!loading, busy: !!loading }}
      disabled={disabled || loading}
      onPress={() => { if (haptic) void Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {}); onPress(); }}
      style={({ pressed }) => [{ height, minWidth: touch.min, paddingHorizontal: compact ? spacing.sm : spacing.lg, borderRadius: radius.md, backgroundColor: bg, alignItems: 'center', justifyContent: 'center', flexDirection: 'row', gap: spacing.xs, opacity: disabled ? 0.4 : 1, transform: [{ scale: pressed ? 0.98 : 1 }], alignSelf: fullWidth ? 'stretch' : 'flex-start' }, pressed && variant === 'primary' ? { backgroundColor: c.onPrimaryContainer } : null, style]}
    >
      {loading ? <ActivityIndicator color={c[fg]} /> : (
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: spacing.xs }}>
          {icon ? <Icon name={icon} size={20} color={c[fg]} /> : null}
          <Text role="label" color={fg} style={{ fontSize: 16, lineHeight: 20 }}>{title}</Text>
        </View>
      )}
    </Pressable>
  );
}
