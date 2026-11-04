import React, { useState } from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { expensesByCategory, monthKeyOf, addMonthsToKey, formatBRL } from '@financas/core';
import { Screen, Card, Text, Chip, useColors, spacing, Button } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Toggle } from '../../features/shared/FormBits';

export default function CategoriesReport() {
  const { ledger, today } = useAppStore();
  const router = useRouter();
  const c = useColors();
  const [month, setMonth] = useState(monthKeyOf(today()));
  const [rollUp, setRollUp] = useState(true);
  const [planned, setPlanned] = useState(false);
  const rows = expensesByCategory(ledger, month, { rollUp, includePlanned: planned });
  const total = rows.reduce((a, r) => a + r.cents, 0);
  const label = (m: string) => `${m.slice(5, 7)}/${m.slice(0, 4)}`;
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Gastos por categoria" />
      <Screen>
        <View style={{ flexDirection: 'row', gap: 8, marginBottom: spacing.sm }}><Chip label={`‹ ${label(addMonthsToKey(month, -1))}`} onPress={() => setMonth(addMonthsToKey(month, -1))} /><Chip label={label(month)} selected /><Chip label={`${label(addMonthsToKey(month, 1))} ›`} onPress={() => setMonth(addMonthsToKey(month, 1))} /></View>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.xs }}>
          <Toggle label="Agrupar subcategorias" value={rollUp} onChange={setRollUp} />
          <Toggle label="Incluir previstos" value={planned} onChange={setPlanned} />
        </Card>
        <Card>
          <Text role="title" style={{ marginBottom: spacing.sm }}>Total {formatBRL(total)}</Text>
          {rows.length ? rows.map((r) => (
            <View key={r.categoryId ?? 'none'} style={{ marginBottom: 12 }}>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="body">{r.name}</Text><Text role="moneyRow" tabular>{formatBRL(r.cents)}</Text></View>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="caption" color="textMuted">{r.count} lançamento(s)</Text><Text role="caption" color="textMuted">{r.percent}%</Text></View>
              <View style={{ height: 10, borderRadius: 5, backgroundColor: c.surfaceInset, marginTop: 4 }}><View style={{ height: 10, borderRadius: 5, width: `${total ? (r.cents / total) * 100 : 0}%`, backgroundColor: r.color }} /></View>
            </View>
          )) : <Text role="bodySmall" color="textMuted">Sem despesas neste mês.</Text>}
          <Button title="Ver lançamentos do mês" variant="ghost" onPress={() => router.push('/transactions?kind=expense')} />
        </Card>
      </Screen>
    </View>
  );
}
