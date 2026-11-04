import React from 'react';
import { ScrollView, View, type ViewStyle, type StyleProp, RefreshControl } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColors } from './theme';
import { spacing } from './tokens';
import { Text } from './Text';

export function Screen({ children, scroll = true, title, subtitle, padded = true, style, refreshing, onRefresh, testID, headerRight }: { children: React.ReactNode; scroll?: boolean; title?: string; subtitle?: string; padded?: boolean; style?: StyleProp<ViewStyle>; refreshing?: boolean; onRefresh?: () => void; testID?: string; headerRight?: React.ReactNode }) {
  const c = useColors();
  const insets = useSafeAreaInsets();
  const header = title ? (
    <View style={{ flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: spacing.md }}>
      <View style={{ flex: 1 }}>
        <Text role="headline">{title}</Text>
        {subtitle ? <Text role="bodySmall" color="textMuted" style={{ marginTop: 4 }}>{subtitle}</Text> : null}
      </View>
      {headerRight}
    </View>
  ) : null;
  const content = <View style={[{ paddingHorizontal: padded ? spacing.md : 0, paddingBottom: spacing.xxl + insets.bottom, maxWidth: 600, width: '100%', alignSelf: 'center' }, style]}>{header}{children}</View>;
  if (!scroll) return <View testID={testID} style={{ flex: 1, backgroundColor: c.bg }}>{content}</View>;
  return (
    <ScrollView testID={testID} style={{ flex: 1, backgroundColor: c.bg }} contentContainerStyle={{ paddingTop: spacing.md }} keyboardShouldPersistTaps="handled" refreshControl={onRefresh ? <RefreshControl refreshing={!!refreshing} onRefresh={onRefresh} tintColor={c.primary} /> : undefined}>
      {content}
    </ScrollView>
  );
}
