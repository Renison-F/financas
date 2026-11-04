import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Screen, Card, ListRow, Text, spacing, type IconName } from '../../design';
import { useAppStore } from '../../state/appStore';

const GROUPS: { title: string; items: { icon: IconName; title: string; description: string; route: string }[] }[] = [
  { title: 'Meu dinheiro', items: [
    { icon: 'wallet', title: 'Contas e carteiras', description: 'Saldos, ajustes, arquivamento', route: '/accounts' },
    { icon: 'tag', title: 'Categorias e tags', description: 'Organize seus lançamentos', route: '/categories' },
    { icon: 'calendar', title: 'Calendário financeiro', description: 'Vencimentos e recebimentos', route: '/calendar' },
    { icon: 'receipt', title: 'Contas a pagar', description: 'Previstas, atrasadas, parciais', route: '/bills' },
  ] },
  { title: 'Análises', items: [
    { icon: 'arrow-up', title: 'Relatórios', description: 'Fluxo de caixa, categorias, comparativos, projeções', route: '/reports' },
    { icon: 'sparkle', title: 'Assistente financeiro', description: 'Pergunte sobre o seu dinheiro', route: '/assistant' },
  ] },
  { title: 'Dados', items: [
    { icon: 'upload', title: 'Importar CSV ou OFX', description: 'Com revisão e sem duplicidades', route: '/import' },
    { icon: 'download', title: 'Exportar e backup', description: 'CSV, PDF e backup completo', route: '/export' },
  ] },
  { title: 'Conta', items: [
    { icon: 'star', title: 'SerenaCash Plus', description: 'Planos, assinatura e restauração', route: '/paywall' },
    { icon: 'settings', title: 'Configurações', description: 'Tema, moeda, privacidade, biometria', route: '/settings' },
    { icon: 'lock', title: 'Privacidade e dados', description: 'Exportar ou apagar tudo', route: '/privacy' },
    { icon: 'help', title: 'Ajuda', description: 'Como o app calcula as coisas', route: '/help' },
  ] },
];

export default function MoreScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const access = useAppStore((s) => s.access);
  return (
    <Screen title="Mais" subtitle={access.tier === 'free' ? 'Plano gratuito' : access.reason} style={{ paddingTop: insets.top }}>
      <View style={{ gap: spacing.sm }}>
        {GROUPS.map((g) => <Card key={g.title}><Text role="label" color="textMuted" style={{ marginBottom: 4 }}>{g.title}</Text>{g.items.map((it) => <ListRow key={it.route} icon={it.icon} title={it.title} description={it.description} onPress={() => router.push(it.route as never)} chevron />)}</Card>)}
        <Text role="caption" color="textMuted" align="center">SerenaCash · dados guardados neste aparelho · versão 0.1.0</Text>
      </View>
    </Screen>
  );
}
