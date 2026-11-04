import React, { useState } from 'react';
import { View, Pressable, Modal, ScrollView, Switch } from 'react-native';
import { isISODate, addDays, todayISO } from '@financas/core';
import { Text, Chip, Input, Button, Icon, useColors, spacing, radius, touch } from '../../design';

export function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return <View style={{ gap: 6 }}><Text role="label" color="textMuted">{label}</Text>{children}</View>;
}

export function Segmented<T extends string>({ options, value, onChange }: { options: { value: T; label: string }[]; value: T; onChange: (v: T) => void }) {
  const c = useColors();
  return (
    <View accessibilityRole="tablist" style={{ flexDirection: 'row', backgroundColor: c.surfaceInset, borderRadius: radius.md, padding: 3 }}>
      {options.map((o) => { const sel = o.value === value; return <Pressable key={o.value} accessibilityRole="tab" accessibilityState={{ selected: sel }} onPress={() => onChange(o.value)} style={{ flex: 1, height: touch.min - 4, borderRadius: radius.sm, alignItems: 'center', justifyContent: 'center', backgroundColor: sel ? c.surface : 'transparent' }}><Text role="label" color={sel ? 'primary' : 'textMuted'} style={{ fontSize: 14 }}>{o.label}</Text></Pressable>; })}
    </View>
  );
}

export function ChipSelect<T extends string>({ options, value, onChange, allowNone }: { options: { value: T; label: string }[]; value: T | undefined; onChange: (v: T | undefined) => void; allowNone?: boolean }) {
  return <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>{options.map((o) => <Chip key={o.value} label={o.label} selected={o.value === value} onPress={() => onChange(o.value === value && allowNone ? undefined : o.value)} />)}</View>;
}

const fmt = (d: string) => `${d.slice(8, 10)}/${d.slice(5, 7)}/${d.slice(0, 4)}`;

/** Simple, dependency-free date field: quick chips (hoje, ontem, amanhã) + typed dd/mm/aaaa. */
export function DateField({ label, value, onChange }: { label: string; value: string; onChange: (d: string) => void }) {
  const [text, setText] = useState(fmt(value));
  const [err, setErr] = useState<string | undefined>();
  const today = todayISO();
  const apply = (t: string) => {
    setText(t);
    const digits = t.replace(/\D/g, '');
    if (digits.length === 8) { const iso = `${digits.slice(4, 8)}-${digits.slice(2, 4)}-${digits.slice(0, 2)}`; if (isISODate(iso)) { setErr(undefined); onChange(iso); return; } }
    if (digits.length >= 8) setErr('Data inválida (dd/mm/aaaa)'); else setErr(undefined);
  };
  return (
    <View style={{ gap: 6 }}>
      <Text role="label" color="textMuted">{label}</Text>
      <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
        <Chip label="Hoje" selected={value === today} onPress={() => { onChange(today); setText(fmt(today)); setErr(undefined); }} />
        <Chip label="Ontem" selected={value === addDays(today, -1)} onPress={() => { const d = addDays(today, -1); onChange(d); setText(fmt(d)); setErr(undefined); }} />
        <Chip label="Amanhã" selected={value === addDays(today, 1)} onPress={() => { const d = addDays(today, 1); onChange(d); setText(fmt(d)); setErr(undefined); }} />
      </View>
      <Input value={text} onChangeText={apply} placeholder="dd/mm/aaaa" keyboardType="number-pad" maxLength={10} error={err} accessibilityLabel={label} />
    </View>
  );
}

export function Toggle({ label, value, onChange, help }: { label: string; value: boolean; onChange: (v: boolean) => void; help?: string }) {
  const c = useColors();
  // Platform Switch (iOS/Material) themed with the design tokens; the row is the touch target.
  return (
    <Pressable accessibilityRole="switch" accessibilityState={{ checked: value }} accessibilityLabel={label} onPress={() => onChange(!value)} style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', minHeight: touch.min, gap: spacing.sm }}>
      <View style={{ flex: 1 }}><Text role="body">{label}</Text>{help ? <Text role="caption" color="textMuted">{help}</Text> : null}</View>
      <Switch value={value} onValueChange={onChange} trackColor={{ false: c.borderStrong, true: c.primary }} thumbColor={c.surface} ios_backgroundColor={c.borderStrong} accessibilityElementsHidden importantForAccessibility="no-hide-descendants" />
    </Pressable>
  );
}

export function Collapsible({ title, children, defaultOpen }: { title: string; children: React.ReactNode; defaultOpen?: boolean }) {
  const [open, setOpen] = useState(!!defaultOpen);
  const c = useColors();
  return (
    <View>
      <Pressable accessibilityRole="button" accessibilityState={{ expanded: open }} onPress={() => setOpen(!open)} style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', minHeight: touch.min }}><Text role="label" color="primary" style={{ fontSize: 15 }}>{title}</Text><Icon name={open ? 'chevron-up' : 'chevron-down'} size={20} color={c.primary} /></Pressable>
      {open ? <View style={{ gap: spacing.md, marginTop: spacing.xs }}>{children}</View> : null}
    </View>
  );
}

/** Confirmation sheet for destructive actions (never a bare system alert). */
export function ConfirmSheet({ visible, title, text, confirmLabel, onConfirm, onCancel, destructive = true }: { visible: boolean; title: string; text: string; confirmLabel: string; onConfirm: () => void; onCancel: () => void; destructive?: boolean }) {
  const c = useColors();
  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onCancel}>
      <Pressable accessibilityLabel="Fechar" onPress={onCancel} style={{ flex: 1, backgroundColor: c.overlay, justifyContent: 'flex-end' }}>
        <Pressable onPress={() => {}} style={{ backgroundColor: c.surface, borderTopLeftRadius: radius.lg, borderTopRightRadius: radius.lg, padding: spacing.lg, gap: spacing.md }}>
          <Text role="title">{title}</Text>
          <Text role="body" color="textMuted">{text}</Text>
          <Button title={confirmLabel} variant={destructive ? 'destructive' : 'primary'} onPress={onConfirm} fullWidth />
          <Button title="Cancelar" variant="ghost" onPress={onCancel} fullWidth />
        </Pressable>
      </Pressable>
    </Modal>
  );
}

export function SheetScroll({ children }: { children: React.ReactNode }) { return <ScrollView keyboardShouldPersistTaps="handled" contentContainerStyle={{ padding: spacing.md, gap: spacing.md, paddingBottom: 80 }}>{children}</ScrollView>; }
