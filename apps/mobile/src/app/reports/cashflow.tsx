import React, { useState } from 'react';
import { View } from 'react-native';
import { cashflow, compareMonths, yearSummary, monthKeyOf, formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Chip, useColors, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

const ml = (k: string) => new Date(Number(k.slice(0, 4)), Number(k.slice(5, 7)) - 1, 1).toLocaleDateString('pt-BR', { month: 'short' }).replace('.', '');

export default function CashflowReport() {
  const { ledger, today } = useAppStore();
  const c = useColors();
  const [range, setRange] = useState<6 | 12>(6);
  const month = monthKeyOf(today());
  const points = cashflow(ledger, month, range);
  const max = Math.max(1, ...points.map((p) => Math.max(p.incomeSettled, p.expenseSettled)));
  const cmp = compareMonths(ledger, month);
  const year = yearSummary(ledger, Number(month.slice(0, 4)));
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Fluxo de caixa" />
      <Screen>
        <View style={{ flexDirection: 'row', gap: 8, marginBottom: spacing.sm }}><Chip label="6 meses" selected={range === 6} onPress={() => setRange(6)} /><Chip label="12 meses" selected={range === 12} onPress={() => setRange(12)} /></View>
        <Card style={{ marginBottom: spacing.sm }}>
          <CardHeader title="Receitas × despesas" />
          <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 6, height: 150 }}>
            {points.map((p) => <View key={p.month} style={{ flex: 1, alignItems: 'center', gap: 4 }}><View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 2, height: 120 }}><View accessibilityLabel={`Receitas ${ml(p.month)} ${formatBRL(p.incomeSettled)}`} style={{ width: range === 6 ? 12 : 7, height: Math.max(2, (p.incomeSettled / max) * 120), backgroundColor: c.positive, borderRadius: 3 }} /><View accessibilityLabel={`Despesas ${ml(p.month)} ${formatBRL(p.expenseSettled)}`} style={{ width: range === 6 ? 12 : 7, height: Math.max(2, (p.expenseSettled / max) * 120), backgroundColor: c.primary, borderRadius: 3 }} /></View><Text role="caption" color="textMuted">{ml(p.month)}</Text></View>)}
          </View>
          <View style={{ flexDirection: 'row', gap: 12, marginTop: 8 }}><Legend color={c.positive} label="Receitas" /><Legend color={c.primary} label="Despesas" /></View>
        </Card>
        <Card style={{ marginBottom: spacing.sm }}>
          <CardHeader title="Mês a mês" />
          {points.slice().reverse().map((p) => <View key={p.month} style={{ flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 6 }}><Text role="bodySmall" style={{ width: 44, textTransform: 'capitalize' }}>{ml(p.month)}</Text><Text role="bodySmall" color="positive" tabular style={{ flex: 1, textAlign: 'right' }}>{formatBRL(p.incomeSettled)}</Text><Text role="bodySmall" tabular style={{ flex: 1, textAlign: 'right' }}>{formatBRL(p.expenseSettled)}</Text><Text role="bodySmall" color={p.net < 0 ? 'negative' : 'text'} tabular style={{ flex: 1, textAlign: 'right' }}>{formatBRL(p.net)}</Text><Text role="caption" color="textMuted" tabular style={{ flex: 1.2, textAlign: 'right' }}>saldo {formatBRL(p.balanceEnd)}</Text></View>)}
        </Card>
        <Card style={{ marginBottom: spacing.sm }}>
          <CardHeader title="Comparativo com o mês anterior" />
          <Row k="Receitas" v={<Money cents={cmp.incomeDeltaCents} signed showPlus />} />
          <Row k="Despesas" v={<Text role="bodySmall" color={cmp.expenseDeltaCents > 0 ? 'negative' : 'positive'} tabular>{cmp.expenseDeltaCents > 0 ? '+' : ''}{formatBRL(cmp.expenseDeltaCents)}{cmp.expenseDeltaPercent !== null ? ` (${cmp.expenseDeltaPercent > 0 ? '+' : ''}${cmp.expenseDeltaPercent}%)` : ''}</Text>} />
        </Card>
        <Card>
          <CardHeader title={`Ano ${year.year}`} />
          <Row k="Receitas" v={<Money cents={year.incomeCents} color="positive" />} /><Row k="Despesas" v={<Money cents={year.expenseCents} />} /><Row k="Resultado" v={<Money cents={year.netCents} signed />} />
          {year.bestMonth ? <Text role="caption" color="textMuted" style={{ marginTop: 6 }}>Melhor mês: {ml(year.bestMonth)} · pior: {year.worstMonth ? ml(year.worstMonth) : '—'}</Text> : null}
        </Card>
      </Screen>
    </View>
  );
}
function Legend({ color, label }: { color: string; label: string }) { return <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}><View style={{ width: 10, height: 10, borderRadius: 3, backgroundColor: color }} /><Text role="caption" color="textMuted">{label}</Text></View>; }
function Row({ k, v }: { k: string; v: React.ReactNode }) { return <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', minHeight: 32 }}><Text role="bodySmall" color="textMuted">{k}</Text>{v}</View>; }
