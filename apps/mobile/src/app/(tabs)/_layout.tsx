import React from 'react';
import { Tabs } from 'expo-router';
import { Platform } from 'react-native';
import { useTheme, Icon, type IconName } from '../../design';

const TABS: { name: string; title: string; icon: IconName }[] = [
  { name: 'index', title: 'Início', icon: 'home' },
  { name: 'transactions', title: 'Lançamentos', icon: 'list' },
  { name: 'shopping', title: 'Compras', icon: 'cart' },
  { name: 'plan', title: 'Planejar', icon: 'plan' },
  { name: 'more', title: 'Mais', icon: 'more' },
];

export default function TabsLayout() {
  const { colors } = useTheme();
  return (
    <Tabs screenOptions={{ headerShown: false, tabBarActiveTintColor: colors.primary, tabBarInactiveTintColor: colors.textMuted, tabBarStyle: { backgroundColor: colors.surface, borderTopColor: colors.border, height: Platform.OS === 'ios' ? 84 : 64, paddingTop: 6 }, tabBarLabelStyle: { fontSize: 10, fontWeight: '500' } }}>
      {TABS.map((t) => (
        <Tabs.Screen key={t.name} name={t.name} options={{ title: t.title, tabBarIcon: ({ color, focused }) => <Icon name={t.icon} color={String(color)} filled={focused && t.icon === 'home'} /> }} />
      ))}
    </Tabs>
  );
}
