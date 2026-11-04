import React from 'react';
import { Pressable, View } from 'react-native';
import { Text } from './Text';
import { Icon, type IconName } from './icons';
import { useColors } from './theme';
import { spacing } from './tokens';

/** 56px dense list row: icon bubble, title + description, right slot (usually <Money/>). */
export function ListRow({ icon, iconColor, title, description, right, onPress, testID, chevron }: { icon?: IconName | undefined; iconColor?: string | undefined; title: string; description?: string | undefined; right?: React.ReactNode; onPress?: (() => void) | undefined; testID?: string | undefined; chevron?: boolean | undefined }) {
  const c = useColors();
  const body = (
    <View style={{ minHeight: 56, flexDirection: 'row', alignItems: 'center', gap: spacing.sm, paddingVertical: 6 }}>
      {icon ? <View style={{ width: 36, height: 36, borderRadius: 12, backgroundColor: c.surfaceInset, alignItems: 'center', justifyContent: 'center' }}><Icon name={icon} size={20} color={iconColor ?? c.primary} /></View> : null}
      <View style={{ flex: 1, minWidth: 0 }}>
        <Text role="body" numberOfLines={1}>{title}</Text>
        {description ? <Text role="bodySmall" color="textMuted" numberOfLines={1}>{description}</Text> : null}
      </View>
      {right}
      {chevron ? <Icon name="chevron-right" size={18} color={c.textMuted} /> : null}
    </View>
  );
  if (!onPress) return <View testID={testID}>{body}</View>;
  return <Pressable testID={testID} accessibilityRole="button" onPress={onPress} style={({ pressed }) => ({ opacity: pressed ? 0.7 : 1 })}>{body}</Pressable>;
}
