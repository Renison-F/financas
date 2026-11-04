import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { netWorth, monthTotals, monthKeyOf, cardCommitment, loanPosition, formatBRL, hasFeature } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

/** Advanced indicators with explicit methodology; premium feature. */
export default function IndicatorsReport() {
  const { ledger, today, access } = useAppStore();
  const router = useRouter();
  const t = today(), month = monthKeyOf(t);
  if (!hasFeature(access, 'advanced_reports')) return <View style={{ flex: 1 }}><StackHeader title="Indicadores" /><Screen><Card><Text role="title">Recurso do SerenaCash Plus</Text><Text role="bodySmall" color="textMuted" style={{ marginVertical: 8 }}>Taxa de poupança, comprometimento de renda e evolução do patrimônio nos últimos 12 meses.</Text><Button title="Conhecer o Plus" onPress={() => router.push('/paywall?feature=advanced_reports')} /></Card></Screen></View>;
  const nw = netWorth(ledger, month, 12, t);
  const tot = monthTotals(ledger, month);
  const inc = tot.incomeSettled;
  const cardDebt = ledger.cards.filter((c) => !c.archived).reduce((a, c) => a + cardCommitment(ledger, c, t).outstandingCents, 0);
  const loanInst = ledger.loans.filter((l) => !l.archived).reduce((a, l) => a + (loanPosition(ledger, l, t).nextDue?.installmentCents ?? 0), 0);
  const savingRate = inc ? ((inc - tot.expenseSettled) / inc) * 100 : null;
  const commitment = inc ? ((cardDebt + loanInst) / inc) * 100 : null;
  const last = nw[nw.length - 1];
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Indicadores e patrimônio" />
      <Screen>
        <Card style={{ marginBottom: spacing.sm, gap: 8 }}>
          <CardHeader title="Este mês" />
          <Ind k="Taxa de poupança" v={savingRate === null ? '—' : `${savingRate.toFixed(1)}%`} how="(receitas − despesas) ÷ receitas efetivadas do mês" />
          <Ind k="Renda comprometida" v={commitment === null ? '—' : `${commitment.toFixed(1)}%`} how="(saldo devedor dos cartões + próxima parcela de empréstimos) ÷ receitas do mês" />
          <Ind k="Patrimônio líquido" v={last ? formatBRL(last.netCents) : '—'} how="contas + reservas fora das contas − faturas em aberto − saldo devedor de empréstimos" />
        </Card>
        <Card>
          <CardHeader title="Patrimônio nos últimos 12 meses" />
          {nw.map((p) => <View key={p.month} style={{ flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 4 }}><Text role="bodySmall" color="textMuted">{p.month.slice(5, 7)}/{p.month.slice(0, 4)}</Text><Text role="caption" color="textMuted" tabular>ativos {formatBRL(p.assetsCents)} · dívidas {formatBRL(p.debtsCents)}</Text><Money cents={p.netCents} signed /></View>)}
        </Card>
        <Text role="caption" color="textMuted" style={{ marginTop: spacing.sm }}>Metodologia transparente, calculada só com o que você registrou. Não é avaliação de crédito nem diagnóstico financeiro.</Text>
      </Screen>
    </View>
  );
}
function Ind({ k, v, how }: { k: string; v: string; how: string }) { return <View><View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="body">{k}</Text><Text role="moneyRow" tabular>{v}</Text></View><Text role="caption" color="textMuted">{how}</Text></View>; }
