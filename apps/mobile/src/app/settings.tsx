import React, { useEffect, useState } from 'react';
import { View, Platform } from 'react-native';
import * as LocalAuthentication from 'expo-local-authentication';
import { ensureNotificationPermission } from '../services/notifications';
import { Screen, Card, CardHeader, Text, Chip, spacing } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';
import { Toggle } from '../features/shared/FormBits';

export default function SettingsScreen() {
  const { ledger, setPrefs } = useAppStore();
  const p = ledger.prefs;
  const [bioAvailable, setBioAvailable] = useState(false);
  const [notif, setNotif] = useState<string>('');
  useEffect(() => { if (Platform.OS !== 'web') LocalAuthentication.hasHardwareAsync().then(async (hw) => setBioAvailable(hw && (await LocalAuthentication.isEnrolledAsync()))).catch(() => setBioAvailable(false)); }, []);
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Configurações" />
      <Screen>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Aparência" />
          <Text role="label" color="textMuted">Tema</Text>
          <View style={{ flexDirection: 'row', gap: 8 }}><Chip label="Automático" selected={p.theme === 'system'} onPress={() => void setPrefs({ theme: 'system' })} /><Chip label="Claro" selected={p.theme === 'light'} onPress={() => void setPrefs({ theme: 'light' })} /><Chip label="Escuro" selected={p.theme === 'dark'} onPress={() => void setPrefs({ theme: 'dark' })} /></View>
          <Toggle label="Ocultar valores" value={p.privacyMode} onChange={(v) => void setPrefs({ privacyMode: v })} help="Mostra R$ •••• em todas as telas até você desligar." />
          <Toggle label="Vibração ao confirmar" value={p.hapticsEnabled} onChange={(v) => void setPrefs({ hapticsEnabled: v })} />
        </Card>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Dinheiro" />
          <Text role="label" color="textMuted">Moeda</Text>
          <View style={{ flexDirection: 'row', gap: 8 }}>{['BRL', 'USD', 'EUR'].map((cur) => <Chip key={cur} label={cur} selected={p.currency === cur} onPress={() => void setPrefs({ currency: cur })} />)}</View>
          <Text role="caption" color="textMuted">A moeda vale para novos lançamentos. Formato e idioma seguem o aparelho (pt-BR por padrão).</Text>
          <Text role="label" color="textMuted" style={{ marginTop: 4 }}>Horizonte do "pode gastar"</Text>
          <View style={{ flexDirection: 'row', gap: 8 }}><Chip label="Fim do mês" selected={p.availabilityHorizon === 'month_end'} onPress={() => void setPrefs({ availabilityHorizon: 'month_end' })} /><Chip label="30 dias" selected={p.availabilityHorizon === 'days_30'} onPress={() => void setPrefs({ availabilityHorizon: 'days_30' })} /></View>
        </Card>
        <Card style={{ gap: spacing.sm }}>
          <CardHeader title="Segurança" />
          <Toggle label="Pedir biometria ao abrir" value={p.biometricLock} onChange={(v) => void setPrefs({ biometricLock: v })} help={bioAvailable ? 'Face ID / impressão digital do aparelho.' : 'Nenhuma biometria configurada neste aparelho (ou não disponível na web).'} />
          <Text role="caption" color="textMuted">Seus dados ficam só neste aparelho. Faça backups em Mais → Exportar.</Text>
        </Card>
        <Card style={{ marginTop: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Lembretes" />
          <Text role="bodySmall" color="textMuted">Aviso local no dia anterior e no dia do vencimento das contas previstas (próximos 7 dias). Nada sai do aparelho.</Text>
          <Chip label="Ativar lembretes de vencimento" onPress={async () => setNotif((await ensureNotificationPermission()) ? 'Lembretes ativados.' : 'Permissão de notificação negada ou indisponível (web/Expo Go limitado).')} />
          {notif ? <Text role="caption" color="textMuted">{notif}</Text> : null}
        </Card>
      </Screen>
    </View>
  );
}
