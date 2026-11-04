import React from 'react';
import { View, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Icon, useColors, spacing, touch } from '../../design';

/** Inline header for stacked screens: system-style back button + title + optional right action. */
export function StackHeader({ title, right }: { title: string; right?: React.ReactNode }) {
  const router = useRouter();
  const c = useColors();
  const insets = useSafeAreaInsets();
  return (
    <View style={{ paddingTop: insets.top, backgroundColor: c.bg }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: spacing.xs, minHeight: 52 }}>
        <Pressable accessibilityRole="button" accessibilityLabel="Voltar" onPress={() => (router.canGoBack() ? router.back() : router.replace('/'))} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="chevron-left" color={c.primary} /></Pressable>
        <Text role="title" numberOfLines={1} style={{ flex: 1 }}>{title}</Text>
        {right ?? <View style={{ width: touch.min }} />}
      </View>
    </View>
  );
}
