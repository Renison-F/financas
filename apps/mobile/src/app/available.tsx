import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { Screen, Text, Money, Card, Button, Chip, spacing, useColors } from '../design';
import { useAppStore } from '../state/appStore';
import { useDashboardData } from '../features/dashboard/useDashboardData';
import { Toggle } from '../features/shared/FormBits';

/** "Como calculamos": every line of the availability estimate, with the toggles that change it. */
export default function AvailableScreen() {
  const data = useDashboardData();
  const prefs = useAppStore((s) => s.ledger.prefs);
  const setPrefs = useAppStore((s) => s.setPrefs);
  const router = useRouter();
  const c = useColors();
  const av = data.availability;
  return (
    <Screen title="Pode gastar" subtitle={`Até ${av.horizonEnd.slice(8, 10)}/${av.horizonEnd.slice(5, 7)} · modo ${av.mode}`} headerRight={<Button title="Fechar" variant="ghost" onPress={() => router.back()} />}>
      <Card style={{ backgroundColor: av.availableCents < 0 ? c.negativeContainer : c.primaryContainer, alignItems: 'center' }}>
        <Money cents={av.availableCents} role="moneyHero" color={av.availableCents < 0 ? 'negative' : 'onPrimaryContainer'} />
        <Text role="bodySmall" color={av.availableCents < 0 ? 'negative' : 'onPrimaryContainer'} align="center" style={{ marginTop: 8 }}>É uma estimativa com o que você registrou. Não é saldo garantido.</Text>
      </Card>
      <Card style={{ marginTop: spacing.sm }}>
        <Text role="title" style={{ marginBottom: spacing.xs }}>A conta</Text>
        {av.lines.map((l) => (
          <View key={l.key} style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', minHeight: 40 }}>
            <View style={{ flex: 1 }}><Text role="body">{l.sign > 0 ? '+ ' : '− '}{l.label}</Text>{l.note ? <Text role="caption" color="textMuted">{l.note}</Text> : null}</View>
            <Money cents={l.sign * l.cents} signed={l.sign < 0 ? false : false} color={l.sign < 0 ? 'negative' : 'positive'} />
          </View>
        ))}
        <View style={{ height: 1, backgroundColor: c.border, marginVertical: spacing.xs }} />
        <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="title">= Pode gastar</Text><Money cents={av.availableCents} role="title" signed /></View>
      </Card>
      <Card style={{ marginTop: spacing.sm, gap: spacing.md }}>
        <Text role="title">Ajustes</Text>
        <Toggle label="Considerar receitas previstas" value={prefs.includePlannedIncomeInAvailability} onChange={(v) => void setPrefs({ includePlannedIncomeInAvailability: v })} help="Ligado = modo otimista: conta com dinheiro que ainda não entrou." />
        <View style={{ gap: 6 }}>
          <Text role="label" color="textMuted">Horizonte</Text>
          <View style={{ flexDirection: 'row', gap: 8 }}><Chip label="Até o fim do mês" selected={prefs.availabilityHorizon === 'month_end'} onPress={() => void setPrefs({ availabilityHorizon: 'month_end' })} /><Chip label="Próximos 30 dias" selected={prefs.availabilityHorizon === 'days_30'} onPress={() => void setPrefs({ availabilityHorizon: 'days_30' })} /></View>
        </View>
        <View style={{ gap: 6 }}>
          <Text role="label" color="textMuted">Colchão de segurança</Text>
          <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>{[0, 10000, 20000, 50000, 100000].map((v) => <Chip key={v} label={v === 0 ? 'Nenhum' : `R$ ${v / 100}`} selected={prefs.safetyCushionCents === v} onPress={() => void setPrefs({ safetyCushionCents: v })} />)}</View>
          <Text role="caption" color="textMuted">Valor que você prefere nunca tocar; sai do "pode gastar".</Text>
        </View>
      </Card>
      <Card style={{ marginTop: spacing.sm }}>
        <Text role="title">Regras</Text>
        <Text role="bodySmall" color="textMuted" style={{ marginTop: 6 }}>Entram só contas marcadas para o cálculo e dinheiro já efetivado. Saem: contas previstas até o horizonte (inclusive atrasadas), faturas de cartão já fechadas e a fatura aberta, reservas guardadas dentro das contas e o colchão. Compras no cartão nunca contam duas vezes: a compra é despesa na data; o pagamento da fatura só move dinheiro.</Text>
      </Card>
    </Screen>
  );
}
