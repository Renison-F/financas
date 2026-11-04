import React, { useState } from 'react';
import { View, Pressable, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { PRESETS, WIDGETS, widgetById, applyPreset, showWidget, hideWidget, moveWidgetBy, hiddenWidgets, DEFAULT_LAYOUT, type DashboardLayout, type DashboardPreset, type WidgetId } from '@financas/core';
import { Text, Button, Chip, Icon, Card, useColors, spacing, radius, touch } from '../design';
import { useAppStore } from '../state/appStore';
import { DraggableList } from '../features/dashboard/DraggableList';

/** Dashboard customization: presets, show/hide, reorder (drag or accessible buttons), period, accounts, privacy, reset. */
export default function CustomizeScreen() {
  const saved = useAppStore((s) => s.layout);
  const setLayout = useAppStore((s) => s.setLayout);
  const allAccounts = useAppStore((s) => s.ledger.accounts);
  const accounts = allAccounts.filter((a) => !a.archived);
  const [layout, setLocal] = useState<DashboardLayout>(saved);
  const router = useRouter();
  const c = useColors();
  const insets = useSafeAreaInsets();
  const save = async () => { await setLayout(layout); router.back(); };
  const hidden = hiddenWidgets(layout);
  return (
    <View style={{ flex: 1, backgroundColor: c.bg, paddingTop: insets.top }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: spacing.md, paddingVertical: spacing.sm }}>
        <Button title="Cancelar" variant="ghost" onPress={() => router.back()} />
        <Text role="title">Tela inicial</Text>
        <Button title="Salvar" variant="ghost" onPress={() => void save()} testID="save-layout" />
      </View>
      <ScrollView contentContainerStyle={{ padding: spacing.md, paddingBottom: spacing.xxl + insets.bottom, gap: spacing.lg }}>
        <View>
          <Text role="label" color="textMuted" style={{ marginBottom: 8 }}>Modelos</Text>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
            {(Object.keys(PRESETS) as DashboardPreset[]).map((p) => <Chip key={p} label={PRESETS[p].title} onPress={() => setLocal(applyPreset(layout, p))} />)}
            <Chip label="Restaurar padrão" onPress={() => setLocal({ ...DEFAULT_LAYOUT, privacyMode: layout.privacyMode })} />
          </View>
        </View>
        <View>
          <Text role="label" color="textMuted" style={{ marginBottom: 8 }}>Visíveis (segure e arraste, ou use as setas)</Text>
          <DraggableList
            items={layout.order}
            onReorder={(order) => setLocal({ ...layout, order })}
            renderItem={(id, index, dragHandle) => (
              <Card key={id} style={{ flexDirection: 'row', alignItems: 'center', gap: spacing.sm, padding: spacing.sm, marginBottom: 8 }}>
                {dragHandle}
                <View style={{ flex: 1, minWidth: 0 }}><Text role="body" numberOfLines={1}>{widgetById(id).title}</Text></View>
                <IconButton name="chevron-up" label={`Mover ${widgetById(id).title} para cima`} disabled={index === 0} onPress={() => setLocal(moveWidgetBy(layout, id, -1))} />
                <IconButton name="chevron-down" label={`Mover ${widgetById(id).title} para baixo`} disabled={index === layout.order.length - 1} onPress={() => setLocal(moveWidgetBy(layout, id, 1))} />
                <IconButton name="eye-off" label={`Ocultar ${widgetById(id).title}`} onPress={() => setLocal(hideWidget(layout, id))} />
              </Card>
            )}
          />
        </View>
        {hidden.length ? <View>
          <Text role="label" color="textMuted" style={{ marginBottom: 8 }}>Ocultos</Text>
          {hidden.map((id) => <Card key={id} style={{ flexDirection: 'row', alignItems: 'center', gap: spacing.sm, padding: spacing.sm, marginBottom: 8 }}><View style={{ flex: 1, minWidth: 0 }}><Text role="body" numberOfLines={1}>{widgetById(id).title}</Text><Text role="caption" color="textMuted" numberOfLines={1}>{WIDGETS.find((w) => w.id === id)?.description}</Text></View><IconButton name="plus" label={`Mostrar ${widgetById(id).title}`} onPress={() => setLocal(showWidget(layout, id as WidgetId))} /></Card>)}
        </View> : null}
        <View>
          <Text role="label" color="textMuted" style={{ marginBottom: 8 }}>Período dos indicadores</Text>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
            <Chip label="Mês atual" selected={layout.period === 'current_month'} onPress={() => setLocal({ ...layout, period: 'current_month' })} />
            <Chip label="Próximos 30 dias" selected={layout.period === 'last_30_days'} onPress={() => setLocal({ ...layout, period: 'last_30_days' })} />
          </View>
        </View>
        {accounts.length > 1 ? <View>
          <Text role="label" color="textMuted" style={{ marginBottom: 8 }}>Contas consideradas</Text>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
            <Chip label="Todas" selected={!layout.accountIds} onPress={() => setLocal({ ...layout, accountIds: undefined })} />
            {accounts.map((a) => { const sel = layout.accountIds?.includes(a.id) ?? false; return <Chip key={a.id} label={a.name} selected={sel} onPress={() => { const cur = layout.accountIds ?? accounts.map((x) => x.id); const next = sel ? cur.filter((x) => x !== a.id) : [...cur, a.id]; setLocal({ ...layout, accountIds: next.length === accounts.length ? undefined : next }); }} />; })}
          </View>
        </View> : null}
      </ScrollView>
    </View>
  );
}

function IconButton({ name, label, onPress, disabled }: { name: 'chevron-up' | 'chevron-down' | 'eye-off' | 'plus'; label: string; onPress: () => void; disabled?: boolean }) {
  const c = useColors();
  return <Pressable accessibilityRole="button" accessibilityLabel={label} accessibilityState={{ disabled: !!disabled }} disabled={disabled} onPress={onPress} hitSlop={6} style={{ width: 36, height: touch.min, alignItems: 'center', justifyContent: 'center', borderRadius: radius.sm, opacity: disabled ? 0.3 : 1 }}><Icon name={name} size={20} color={c.primary} /></Pressable>;
}
