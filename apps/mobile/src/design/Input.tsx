import React, { useState } from 'react';
import { TextInput, View, Platform, type TextInputProps, type TextStyle } from 'react-native';

/** Browser default focus ring belongs to no design system; the field draws its own 2px focus border. */
const webNoOutline: TextStyle = Platform.OS === 'web' ? ({ outlineStyle: 'none' } as unknown as TextStyle) : {};
import { parseMoneyBR, type Cents } from '@financas/core';
import { Text } from './Text';
import { useColors } from './theme';
import { radius, spacing, touch } from './tokens';

export interface InputProps extends TextInputProps { label?: string; help?: string; error?: string | undefined; }

export function Input({ label, help, error, style, ...rest }: InputProps) {
  const c = useColors();
  const [focused, setFocused] = useState(false);
  return (
    <View style={{ gap: 6 }}>
      {label ? <Text role="label" color="textMuted">{label}</Text> : null}
      <TextInput
        accessibilityLabel={label} placeholderTextColor={c.textMuted}
        onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}
        style={[{ height: touch.comfortable, borderRadius: radius.sm, backgroundColor: c.surface, color: c.text, paddingHorizontal: 14, fontSize: 17, borderWidth: focused ? 2 : 1, borderColor: error ? c.negative : focused ? c.primary : c.borderStrong }, webNoOutline, style]}
        {...rest}
      />
      {error ? <Text role="caption" color="negative">{error}</Text> : help ? <Text role="caption" color="textMuted">{help}</Text> : null}
    </View>
  );
}

/** Masks pt-BR currency as the user types digits ("1234" → "12,34"). Emits integer cents. */
export function MoneyInput({ label, valueCents, onChangeCents, error, help, autoFocus, testID }: { label?: string; valueCents: Cents | null; onChangeCents: (c: Cents | null) => void; error?: string | undefined; help?: string; autoFocus?: boolean; testID?: string }) {
  const c = useColors();
  const [focused, setFocused] = useState(false);
  const display = valueCents === null ? '' : new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(valueCents / 100);
  const onChange = (t: string) => {
    const digits = t.replace(/\D/g, '');
    if (!digits) return onChangeCents(null);
    const cents = Number(digits.slice(0, 13));
    onChangeCents(Number.isSafeInteger(cents) ? cents : parseMoneyBR(t));
  };
  return (
    <View style={{ gap: 6 }}>
      {label ? <Text role="label" color="textMuted">{label}</Text> : null}
      <View style={{ height: touch.comfortable, borderRadius: radius.sm, backgroundColor: c.surface, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 14, borderWidth: focused ? 2 : 1, borderColor: error ? c.negative : focused ? c.primary : c.borderStrong }}>
        <Text role="body" color="textMuted" style={{ marginRight: 6 }}>R$</Text>
        <TextInput testID={testID} accessibilityLabel={label ?? 'Valor'} value={display} onChangeText={onChange} keyboardType="number-pad" autoFocus={autoFocus} selectTextOnFocus placeholder="0,00" placeholderTextColor={c.textMuted}
          onFocus={() => setFocused(true)} onBlur={() => setFocused(false)} style={[{ flex: 1, fontSize: 22, color: c.text, fontVariant: ['tabular-nums'], height: '100%', paddingVertical: 0 }, webNoOutline]} />
      </View>
      {error ? <Text role="caption" color="negative">{error}</Text> : help ? <Text role="caption" color="textMuted">{help}</Text> : null}
    </View>
  );
}
