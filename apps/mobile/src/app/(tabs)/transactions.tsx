import React, { useMemo, useState } from 'react';
import { View, Pressable, SectionList } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { searchTransactions, monthTotals, addMonthsToKey, monthKeyOf, formatBRL, type Transaction } from '@financas/core';
import { Text, Money, Input, Chip, Icon, ListRow, EmptyState, useColors, spacing, touch, Card } from '../../design';
import { useAppStore } from '../../state/appStore';
import { kindLabel } from '../../features/dashboard/widgets';

type Filter = 'all' | 'income' | 'expense' | 'card_purchase' | 'transfer' | 'planned';
const FILTERS: { value: Filter; label: string }[] = [{ value: 'all', label: 'Tudo' }, { value: 'expense', label: 'Despesas' }, { value: 'income', label: 'Receitas' }, { value: 'card_purchase', label: 'Cartão' }, { value: 'transfer', label: 'Transferências' }, { value: 'planned', label: 'Previstos' }];
const monthTitle = (k: string) => { const d = new Date(Number(k.slice(0, 4)), Number(k.slice(5, 7)) - 1, 1).toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' }); return d.charAt(0).toUpperCase() + d.slice(1); };
const dayTitle = (d: string) => new Date(Number(d.slice(0, 4)), Number(d.slice(5, 7)) - 1, Number(d.slice(8, 10))).toLocaleDateString('pt-BR', { weekday: 'long', day: '2-digit', month: 'short' });

export default function TransactionsScreen() {
  const params = useLocalSearchParams<{ kind?: string }>();
  const ledger = useAppStore((s) => s.ledger);
  const today = useAppStore((s) => s.today)();
  const router = useRouter();
  const c = useColors();
  const insets = useSafeAreaInsets();
  const [month, setMonth] = useState(monthKeyOf(today));
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState<Filter>((params.kind as Filter) || 'all');
  const items = useMemo(() => {
    const kinds = filter === 'all' || filter === 'planned' ? undefined : [filter as Transaction['kind']];
    return searchTransactions(ledger, query, { kinds, from: `${month}-01`, to: `${month}-31`, status: filter === 'planned' ? ['planned', 'partially_paid'] : undefined });
  }, [ledger, query, filter, month]);
  const sections = useMemo(() => { const map = new Map<string, Transaction[]>(); for (const t of items) map.set(t.date, [...(map.get(t.date) ?? []), t]); return [...map.entries()].map(([date, data]) => ({ title: dayTitle(date), data })); }, [items]);
  const totals = monthTotals(ledger, month);
  return (
    <View style={{ flex: 1, backgroundColor: c.bg, paddingTop: insets.top }}>
      <View style={{ paddingHorizontal: spacing.md, gap: spacing.sm, paddingBottom: spacing.sm }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <Pressable accessibilityRole="button" accessibilityLabel="Mês anterior" onPress={() => setMonth(addMonthsToKey(month, -1))} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="chevron-left" color={c.primary} /></Pressable>
          <Text role="title">{monthTitle(month)}</Text>
          <Pressable accessibilityRole="button" accessibilityLabel="Próximo mês" onPress={() => setMonth(addMonthsToKey(month, 1))} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="chevron-right" color={c.primary} /></Pressable>
        </View>
        <Card inset style={{ flexDirection: 'row', justifyContent: 'space-around' }}>
          <View style={{ alignItems: 'center' }}><Text role="caption" color="textMuted">Entradas</Text><Money cents={totals.incomeSettled} color="positive" /></View>
          <View style={{ alignItems: 'center' }}><Text role="caption" color="textMuted">Saídas</Text><Money cents={totals.expenseSettled} /></View>
          <View style={{ alignItems: 'center' }}><Text role="caption" color="textMuted">Resultado</Text><Money cents={totals.net} signed /></View>
        </Card>
        <Input value={query} onChangeText={setQuery} placeholder="Buscar por descrição, loja ou observação" accessibilityLabel="Buscar lançamentos" returnKeyType="search" />
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>{FILTERS.map((f) => <Chip key={f.value} label={f.label} selected={filter === f.value} onPress={() => setFilter(f.value)} />)}</View>
      </View>
      <SectionList
        sections={sections} keyExtractor={(t) => t.id} stickySectionHeadersEnabled={false}
        contentContainerStyle={{ paddingHorizontal: spacing.md, paddingBottom: 120 }}
        renderSectionHeader={({ section }) => <Text role="label" color="textMuted" style={{ marginTop: spacing.md, marginBottom: 4, textTransform: 'capitalize' }}>{section.title}</Text>}
        renderItem={({ item: t }) => (
          <ListRow icon={t.kind === 'income' ? 'arrow-down' : t.kind === 'transfer' ? 'swap' : t.kind === 'card_purchase' ? 'card' : t.kind === 'card_payment' ? 'receipt' : 'arrow-up'} iconColor={t.status === 'planned' ? c.warning : t.kind === 'income' ? c.positive : c.primary}
            title={t.description || kindLabel(t.kind)} description={`${kindLabel(t.kind)}${t.status === 'planned' ? ' · previsto' : t.status === 'partially_paid' ? ` · pago ${formatBRL(t.paidCents ?? 0)}` : ''}${t.installment ? ` · ${t.installment.number}/${t.installment.of}` : ''}`}
            right={<Money cents={t.kind === 'income' || t.kind === 'loan_disbursement' || t.kind === 'goal_withdrawal' ? t.amountCents : t.kind === 'transfer' || t.kind === 'balance_adjustment' ? t.amountCents : -t.amountCents} signed={t.kind !== 'transfer' && t.kind !== 'balance_adjustment'} />}
            onPress={() => router.push(`/transaction?id=${t.id}`)} />
        )}
        ListEmptyComponent={<EmptyState icon="list" title={query ? 'Nada encontrado' : 'Nenhum lançamento neste mês'} text={query ? 'Tente outra palavra.' : 'Registre uma despesa ou receita com o botão +.'} actionTitle={query ? undefined : 'Registrar'} onAction={() => router.push('/transaction')} />}
      />
      <Pressable accessibilityRole="button" accessibilityLabel="Adicionar lançamento" onPress={() => router.push('/transaction')} style={{ position: 'absolute', right: spacing.md, bottom: spacing.md + insets.bottom, width: 56, height: 56, borderRadius: 18, backgroundColor: c.primary, alignItems: 'center', justifyContent: 'center', elevation: 6 }}><Icon name="plus" color={c.onPrimary} size={28} /></Pressable>
    </View>
  );
}
