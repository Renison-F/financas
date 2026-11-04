import React, { useState } from 'react';
import { View, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { answer, recommendations, type Answer } from '@financas/core';
import { Screen, Card, Text, Money, Button, Input, Chip, ListRow, useColors, spacing } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';

const SUGGESTIONS = ['Quanto posso gastar?', 'Quais contas vencem esta semana?', 'Onde estou gastando mais?', 'Quanto gastei com supermercado?', 'Quanto falta para minha meta?', 'Quanto tenho comprometido em parcelas?', 'Como está o mês?', 'Como organizar minhas contas?'];

/** Deterministic assistant: answers computed from the user's data, each with its basis. No external AI required. */
export default function AssistantScreen() {
  const { ledger, today } = useAppStore();
  const router = useRouter();
  const c = useColors();
  const [q, setQ] = useState('');
  const [history, setHistory] = useState<{ q: string; a: Answer }[]>([]);
  const ask = (text: string) => { if (!text.trim()) return; setHistory((h) => [{ q: text, a: answer(ledger, text, today()) }, ...h]); setQ(''); };
  const recs = recommendations(ledger, today());
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Assistente" />
      <Screen>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <Text role="bodySmall" color="textMuted">Respostas calculadas com os seus dados, no aparelho. Nenhuma pergunta sai do celular.</Text>
          <Input value={q} onChangeText={setQ} placeholder="Pergunte: posso comprar algo de 300,00?" onSubmitEditing={() => ask(q)} returnKeyType="send" accessibilityLabel="Pergunta" />
          <Button title="Perguntar" onPress={() => ask(q)} disabled={!q.trim()} fullWidth />
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 8 }}>{SUGGESTIONS.map((s) => <Chip key={s} label={s} onPress={() => ask(s)} />)}</ScrollView>
        </Card>
        {history.map((h, i) => (
          <Card key={i} style={{ marginBottom: spacing.sm }}>
            <Text role="label" color="textMuted">{h.q}</Text>
            <Text role="title" style={{ marginTop: 4 }}>{h.a.title}</Text>
            {h.a.cents !== undefined ? <Money cents={h.a.cents} role="headline" signed={h.a.intent === 'can_afford' || h.a.intent === 'month_status'} /> : null}
            <Text role="body" style={{ marginTop: 6 }}>{h.a.text}</Text>
            {h.a.basis.length ? <View style={{ marginTop: 8, borderTopWidth: 1, borderTopColor: c.border, paddingTop: 6 }}><Text role="caption" color="textMuted">Base do cálculo</Text>{h.a.basis.map((b, j) => <View key={j} style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="caption" color="textMuted">{b.label}</Text><Money cents={b.cents} role="caption" signed /></View>)}</View> : null}
            {h.a.route ? <Button title="Abrir" variant="ghost" compact onPress={() => router.push(h.a.route as never)} /> : null}
          </Card>
        ))}
        <Card>
          <Text role="title" style={{ marginBottom: 6 }}>Sugestões para você</Text>
          {recs.length ? recs.map((r) => <ListRow key={r.id} icon={r.severity === 'urgent' ? 'alert' : r.severity === 'attention' ? 'info' : 'sparkle'} iconColor={r.severity === 'urgent' ? c.negative : r.severity === 'attention' ? c.warning : c.primary} title={r.title} description={r.text} onPress={r.route ? () => router.push(r.route as never) : undefined} />) : <Text role="bodySmall" color="textMuted">Tudo sereno. Nenhuma sugestão agora.</Text>}
          <Text role="caption" color="textMuted" style={{ marginTop: 8 }}>Regras transparentes: contas atrasadas, orçamentos acima do ritmo, cartão acima de 80% do limite, mês negativo, sobra ≥ 20% sem reserva, 3+ gastos recorrentes.</Text>
        </Card>
      </Screen>
    </View>
  );
}
