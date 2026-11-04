import React, { useEffect, useState } from 'react';
import { View, Platform, AppState } from 'react-native';
import * as LocalAuthentication from 'expo-local-authentication';
import { Text, Button, useColors, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';

/** Locks the UI behind device biometrics (Face ID / digital) when the preference is on; falls back to device passcode. */
export function BiometricGate({ children }: { children: React.ReactNode }) {
  const enabled = useAppStore((s) => s.ledger.prefs.biometricLock);
  const [unlocked, setUnlocked] = useState(!enabled || Platform.OS === 'web');
  const [error, setError] = useState('');
  const c = useColors();
  const authenticate = async () => {
    setError('');
    try {
      const r = await LocalAuthentication.authenticateAsync({ promptMessage: 'Desbloquear SerenaCash', cancelLabel: 'Cancelar', disableDeviceFallback: false });
      if (r.success) setUnlocked(true); else setError('Não foi possível confirmar sua identidade.');
    } catch { setError('Biometria indisponível neste aparelho.'); }
  };
  useEffect(() => { if (enabled && Platform.OS !== 'web') { setUnlocked(false); void authenticate(); } else setUnlocked(true); }, [enabled]); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => {
    if (!enabled || Platform.OS === 'web') return;
    const sub = AppState.addEventListener('change', (st) => { if (st === 'background') setUnlocked(false); });
    return () => sub.remove();
  }, [enabled]);
  if (unlocked) return <>{children}</>;
  return (
    <View style={{ flex: 1, backgroundColor: c.bg, alignItems: 'center', justifyContent: 'center', padding: spacing.lg, gap: spacing.md }}>
      <Text role="headline" align="center">Bloqueado</Text>
      <Text role="body" color="textMuted" align="center">Confirme sua identidade para ver seus dados.</Text>
      {error ? <Text role="bodySmall" color="negative" align="center">{error}</Text> : null}
      <Button title="Desbloquear" icon="lock" onPress={() => void authenticate()} />
    </View>
  );
}
