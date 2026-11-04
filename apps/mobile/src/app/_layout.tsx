import 'react-native-gesture-handler';
import React, { useEffect, useMemo, useState } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { Stack, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as SplashScreen from 'expo-splash-screen';
import { useFonts, BricolageGrotesque_600SemiBold, BricolageGrotesque_700Bold } from '@expo-google-fonts/bricolage-grotesque';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { ThemeProvider, PrivacyProvider, useTheme, palette } from '../design';
import { useAppStore } from '../state/appStore';
import { DataStore } from '../data/store';
import { SQLiteDatabase } from '../data/sqliteDatabase';
import { UndoToast } from '../features/shared/UndoToast';

void SplashScreen.preventAutoHideAsync().catch(() => {});

async function openDatabase() {
  // sqliteDatabase.native.ts uses expo-sqlite; sqliteDatabase.web.ts falls back to memory (preview only).
  return SQLiteDatabase.open();
}

function Gate({ children }: { children: React.ReactNode }) {
  const loadState = useAppStore((s) => s.loadState);
  const onboarded = useAppStore((s) => s.onboarded);
  const error = useAppStore((s) => s.error);
  const segments = useSegments();
  const router = useRouter();
  const { colors } = useTheme();
  useEffect(() => {
    if (loadState !== 'ready') return;
    const inOnboarding = segments[0] === 'onboarding';
    if (!onboarded && !inOnboarding) router.replace('/onboarding');
    if (onboarded && inOnboarding) router.replace('/');
  }, [loadState, onboarded, segments, router]);
  if (loadState !== 'ready') {
    return <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: colors.bg }}>{loadState === 'error' ? null : <ActivityIndicator color={colors.primary} />}{error ? <View /> : null}</View>;
  }
  return <>{children}</>;
}

export default function RootLayout() {
  const [fontsLoaded] = useFonts({ BricolageGrotesque_600SemiBold, BricolageGrotesque_700Bold });
  const init = useAppStore((s) => s.init);
  const loadState = useAppStore((s) => s.loadState);
  const theme = useAppStore((s) => s.ledger.prefs.theme);
  const privacyMode = useAppStore((s) => s.ledger.prefs.privacyMode);
  const setPrefs = useAppStore((s) => s.setPrefs);
  const [dbError, setDbError] = useState<string | null>(null);
  useEffect(() => { if (loadState === 'idle') openDatabase().then((db) => DataStore.open(db)).then(init).catch((e) => setDbError(String(e))); }, [init, loadState]);
  useEffect(() => { if (fontsLoaded && (loadState === 'ready' || loadState === 'error' || dbError)) void SplashScreen.hideAsync().catch(() => {}); }, [fontsLoaded, loadState, dbError]);
  const privacy = useMemo(() => ({ hidden: privacyMode, toggle: () => void setPrefs({ privacyMode: !privacyMode }) }), [privacyMode, setPrefs]);
  if (!fontsLoaded) return null;
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <ThemeProvider preference={theme}>
          <PrivacyProvider value={privacy}>
            <Shell dbError={dbError} />
          </PrivacyProvider>
        </ThemeProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

function Shell({ dbError }: { dbError: string | null }) {
  const { scheme, colors } = useTheme();
  return (
    <>
      <StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />
      <Gate>
        <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: colors.bg } }}>
          <Stack.Screen name="(tabs)" />
          <Stack.Screen name="onboarding" options={{ animation: 'fade' }} />
          <Stack.Screen name="transaction" options={{ presentation: 'modal' }} />
          <Stack.Screen name="customize" options={{ presentation: 'modal' }} />
          <Stack.Screen name="available" options={{ presentation: 'modal' }} />
        </Stack>
      </Gate>
      <UndoToast />
      {dbError ? <View style={{ position: 'absolute', bottom: 0, left: 0, right: 0, padding: 16, backgroundColor: palette.light.negativeContainer }} /> : null}
    </>
  );
}
