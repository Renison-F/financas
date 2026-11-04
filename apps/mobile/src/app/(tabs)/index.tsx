import React from 'react';
import { View, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { widgetById } from '@financas/core';
import { Screen, Text, Icon, useColors, spacing, usePrivacy, touch } from '../../design';
import { useAppStore } from '../../state/appStore';
import { useDashboardData } from '../../features/dashboard/useDashboardData';
import { Widget, WidgetErrorBoundary } from '../../features/dashboard/widgets';

const greeting = () => { const h = new Date().getHours(); return h < 12 ? 'Bom dia' : h < 18 ? 'Boa tarde' : 'Boa noite'; };

export default function HomeScreen() {
  const layout = useAppStore((s) => s.layout);
  const data = useDashboardData();
  const router = useRouter();
  const c = useColors();
  const privacy = usePrivacy();
  const insets = useSafeAreaInsets();
  const monthName = new Date(Number(data.month.slice(0, 4)), Number(data.month.slice(5, 7)) - 1, 1).toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <Screen testID="home" title={greeting()} subtitle={monthName.charAt(0).toUpperCase() + monthName.slice(1)} style={{ paddingTop: insets.top }}
        headerRight={<View style={{ flexDirection: 'row', gap: 4 }}>
          <Pressable accessibilityRole="button" accessibilityLabel={privacy.hidden ? 'Mostrar valores' : 'Ocultar valores'} onPress={privacy.toggle} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name={privacy.hidden ? 'eye-off' : 'eye'} color={c.textMuted} /></Pressable>
          <Pressable accessibilityRole="button" accessibilityLabel="Personalizar tela inicial" onPress={() => router.push('/customize')} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="settings" color={c.textMuted} /></Pressable>
        </View>}>
        <View style={{ gap: spacing.sm }}>
          {layout.order.map((id) => <WidgetErrorBoundary key={id} title={widgetById(id).title}><Widget id={id} data={data} /></WidgetErrorBoundary>)}
          {layout.order.length === 0 ? <Text role="bodySmall" color="textMuted" align="center">Nenhum widget visível. Toque na engrenagem para escolher o que ver.</Text> : null}
        </View>
      </Screen>
      <Pressable accessibilityRole="button" accessibilityLabel="Adicionar lançamento" onPress={() => router.push('/transaction')} style={{ position: 'absolute', right: spacing.md, bottom: spacing.md + insets.bottom, width: 56, height: 56, borderRadius: 18, backgroundColor: c.primary, alignItems: 'center', justifyContent: 'center', shadowColor: c.shadow, shadowOpacity: 1, shadowRadius: 20, shadowOffset: { width: 0, height: 6 }, elevation: 6 }}>
        <Icon name="plus" color={c.onPrimary} size={28} />
      </Pressable>
    </View>
  );
}
