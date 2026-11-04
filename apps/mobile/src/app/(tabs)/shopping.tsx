import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { estimateList, listProgress, sessionSummary } from '@financas/shopping';
import { formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Button, ListRow, Money, EmptyState, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';

export default function ShoppingTab() {
  const lists = useAppStore((s) => s.shoppingLists.filter((l) => !l.archived));
  const sessions = useAppStore((s) => s.sessions);
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const active = sessions.find((s) => s.status === 'active');
  const finished = sessions.filter((s) => s.status === 'finished').sort((a, b) => (b.finishedAt ?? '').localeCompare(a.finishedAt ?? '')).slice(0, 5);
  return (
    <Screen title="Compras" subtitle="Listas e assistente de supermercado" style={{ paddingTop: insets.top }}>
      <View style={{ gap: spacing.sm }}>
        <Card>
          <CardHeader title={active ? 'Compra em andamento' : 'Assistente de supermercado'} />
          <Text role="bodySmall" color="textMuted">{active ? `${active.lines.length} item(ns) · ${formatBRL(sessionSummary(active).totalCents)}` : 'Leia etiquetas de preço e códigos de barras, veja o total e quanto ainda cabe no orçamento antes do caixa.'}</Text>
          <Button title={active ? 'Continuar compra' : 'Iniciar compra'} icon="cart" onPress={() => router.push(active ? `/shopping/session?id=${active.id}` : '/shopping/session')} style={{ marginTop: 10 }} />
        </Card>
        <Card>
          <CardHeader title="Listas" action={<Button title="Nova" variant="ghost" compact icon="plus" onPress={() => router.push('/shopping/list/new')} />} />
          {lists.length ? lists.map((l) => { const e = estimateList(l); const p = listProgress(l); return <ListRow key={l.id} icon="list" title={l.name} description={`${p.total} itens${l.store ? ` · ${l.store}` : ''} · ${e.knownItems ? `estimado ${formatBRL(e.knownCents)}` : 'sem preços ainda'}${e.unknownItems ? ` (${e.unknownItems} sem preço)` : ''}`} right={l.budgetCents !== undefined ? <Money cents={l.budgetCents} /> : undefined} onPress={() => router.push(`/shopping/list/${l.id}`)} chevron />; }) : <EmptyState icon="list" title="Nenhuma lista" text="Crie a lista em casa e use no mercado, mesmo sem internet." actionTitle="Criar lista" onAction={() => router.push('/shopping/list/new')} />}
        </Card>
        <Card>
          <CardHeader title="Compras anteriores" />
          {finished.length ? finished.map((s) => { const sm = sessionSummary(s); return <ListRow key={s.id} icon="receipt" title={s.store || 'Supermercado'} description={`${sm.lines} itens · ${s.finishedAt?.slice(8, 10)}/${s.finishedAt?.slice(5, 7)}${s.transactionId ? ' · lançado' : ''}`} right={<Money cents={sm.totalCents} />} onPress={() => router.push(`/shopping/session?id=${s.id}`)} chevron />; }) : <Text role="bodySmall" color="textMuted">As compras finalizadas aparecem aqui, com histórico de preços por loja.</Text>}
        </Card>
      </View>
    </Screen>
  );
}
