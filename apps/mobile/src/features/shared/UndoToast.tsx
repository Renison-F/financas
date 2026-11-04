import React, { useEffect } from 'react';
import { View, Pressable } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAppStore } from '../../state/appStore';
import { Text, useColors, radius, spacing } from '../../design';

/** Toast with "Desfazer" (10 s) shown after destructive actions. */
export function UndoToast() {
  const undo = useAppStore((s) => s.undo);
  const setUndo = useAppStore((s) => s.setUndo);
  const c = useColors();
  const insets = useSafeAreaInsets();
  useEffect(() => { if (!undo) return; const t = setTimeout(() => setUndo(null), 10000); return () => clearTimeout(t); }, [undo, setUndo]);
  if (!undo) return null;
  return (
    <View accessibilityLiveRegion="polite" style={{ position: 'absolute', left: spacing.md, right: spacing.md, bottom: 72 + insets.bottom, backgroundColor: c.text, borderRadius: radius.md, padding: spacing.sm, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', shadowColor: c.shadow, shadowOpacity: 1, shadowRadius: 12, shadowOffset: { width: 0, height: 6 }, elevation: 6 }}>
      <Text role="bodySmall" color="bg">{undo.label}</Text>
      <Pressable accessibilityRole="button" onPress={() => void undo.run()} style={{ minHeight: 44, justifyContent: 'center', paddingHorizontal: spacing.sm }}><Text role="label" color="primary" style={{ fontSize: 15 }}>Desfazer</Text></Pressable>
    </View>
  );
}
