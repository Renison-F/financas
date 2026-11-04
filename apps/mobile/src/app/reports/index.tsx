import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { Screen, Card, ListRow, Text, spacing } from '../../design';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { useAppStore } from '../../state/appStore';

export default function ReportsIndex() {
  const router = useRouter();
  const access = useAppStore((s) => s.access);
  const items = [
    { route: '/reports/cashflow', icon: 'arrow-up' as const, title: 'Fluxo de caixa', description: 'Receitas, despesas e saldo mês a mês; comparativo mensal e anual' },
    { route: '/reports/categories', icon: 'tag' as const, title: 'Gastos por categoria', description: 'Para onde o dinheiro foi, com filtros' },
    { route: '/reports/recurring', icon: 'receipt' as const, title: 'Gastos recorrentes', description: 'Assinaturas e contas que se repetem' },
    { route: '/reports/projection', icon: 'calendar' as const, title: 'Projeção de saldo', description: 'Como o saldo evolui com o que está previsto' },
    { route: '/reports/indicators', icon: 'sparkle' as const, title: 'Indicadores e patrimônio', description: access.tier === 'free' ? 'SerenaCash Plus' : 'Taxa de poupança, comprometimento, patrimônio' },
  ];
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Relatórios" />
      <Screen>
        <Card>{items.map((it) => <ListRow key={it.route} icon={it.icon} title={it.title} description={it.description} onPress={() => router.push(it.route as never)} chevron />)}</Card>
        <Text role="caption" color="textMuted" style={{ marginTop: spacing.sm }}>Exportação em CSV e PDF em Mais → Exportar.</Text>
      </Screen>
    </View>
  );
}
