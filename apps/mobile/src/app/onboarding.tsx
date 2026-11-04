import React, { useState } from 'react';
import { View, KeyboardAvoidingView, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Svg, { Circle, Path } from 'react-native-svg';
import { Text, Button, MoneyInput, Input, Chip, useColors, spacing, Card } from '../design';
import { useAppStore } from '../state/appStore';
import { Segmented } from '../features/shared/FormBits';

const FIXED = [{ label: 'Aluguel', cat: 'Moradia' }, { label: 'Luz', cat: 'Moradia' }, { label: 'Internet', cat: 'Moradia' }, { label: 'Celular', cat: 'Assinaturas' }, { label: 'Água', cat: 'Moradia' }];

/** ≤ 90 s onboarding: account → fixed bills → card → done. Every step can be skipped; no e-mail, no permissions. */
export default function OnboardingScreen() {
  const router = useRouter();
  const c = useColors();
  const insets = useSafeAreaInsets();
  const { saveAccount, saveTransaction, saveCard, completeOnboarding, ledger, today } = useAppStore();
  const [step, setStep] = useState(0);
  const [accountName, setAccountName] = useState('Conta principal');
  const [accountType, setAccountType] = useState<'checking' | 'cash' | 'savings' | 'digital_wallet'>('checking');
  const [balance, setBalance] = useState<number | null>(null);
  const [accountId, setAccountId] = useState<string | undefined>();
  const [bills, setBills] = useState<Record<string, number | null>>({});
  const [cardName, setCardName] = useState('Cartão');
  const [closing, setClosing] = useState('20');
  const [due, setDue] = useState('27');
  const [limit, setLimit] = useState<number | null>(null);
  const [busy, setBusy] = useState(false);
  const day = (s: string) => Math.min(31, Math.max(1, Number(s) || 1));

  const next = async () => {
    setBusy(true);
    try {
      if (step === 1) { const a = await saveAccount({ name: accountName.trim() || 'Conta principal', type: accountType, openingBalanceCents: balance ?? 0, openingDate: today() }); setAccountId(a.id); }
      if (step === 2 && accountId) {
        for (const [label, cents] of Object.entries(bills)) if (cents) { const cat = ledger.categories.find((x) => x.name === FIXED.find((f) => f.label === label)?.cat); await saveTransaction({ kind: 'expense', amountCents: cents, date: today(), description: label, accountId, categoryId: cat?.id, status: 'planned', recurrence: { frequency: 'monthly' } }); }
      }
      if (step === 3 && limit) await saveCard({ name: cardName.trim() || 'Cartão', limitCents: limit, closingDay: day(closing), dueDay: day(due) });
      if (step === 3) { await completeOnboarding(); router.replace('/'); return; }
      setStep(step + 1);
    } finally { setBusy(false); }
  };
  const skip = async () => { if (step === 3 || (step === 2 && !accountId) || step === 1) { if (step === 1) { setStep(2); return; } await completeOnboarding(); router.replace('/'); } else setStep(step + 1); };

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1, backgroundColor: c.bg, paddingTop: insets.top + spacing.lg, paddingHorizontal: spacing.md, paddingBottom: insets.bottom + spacing.md }}>
      <View style={{ flex: 1, gap: spacing.lg, maxWidth: 600, width: '100%', alignSelf: 'center' }}>
        {step === 0 ? (
          <View style={{ flex: 1, justifyContent: 'center', gap: spacing.lg }}>
            <Svg width={72} height={72} viewBox="0 0 64 64"><Circle cx="32" cy="24" r="13" fill="none" stroke={c.primary} strokeWidth={5} /><Path d="M8 50 C16 42 24 42 32 50 S48 58 56 50" fill="none" stroke={c.accent} strokeWidth={5} strokeLinecap="round" /></Svg>
            <Text role="display">Seu dinheiro em paz.</Text>
            <Text role="body" color="textMuted">Em menos de dois minutos você vai saber quanto pode gastar sem comprometer suas contas. Sem cadastro, sem senha de banco: tudo fica no seu aparelho.</Text>
          </View>
        ) : null}
        {step === 1 ? (
          <View style={{ gap: spacing.md }}>
            <Text role="headline">Quanto você tem agora?</Text>
            <Text role="body" color="textMuted">Pode ser aproximado. Você ajusta depois.</Text>
            <Input label="Nome da conta" value={accountName} onChangeText={setAccountName} />
            <Segmented options={[{ value: 'checking', label: 'Banco' }, { value: 'digital_wallet', label: 'Digital' }, { value: 'cash', label: 'Dinheiro' }, { value: 'savings', label: 'Poupança' }]} value={accountType} onChange={setAccountType} />
            <MoneyInput label="Saldo hoje" valueCents={balance} onChangeCents={setBalance} autoFocus />
          </View>
        ) : null}
        {step === 2 ? (
          <View style={{ gap: spacing.md }}>
            <Text role="headline">Contas fixas deste mês</Text>
            <Text role="body" color="textMuted">Toque nas que você paga e informe o valor. Elas viram previstas e se repetem todo mês.</Text>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>{FIXED.map((f) => <Chip key={f.label} label={f.label} selected={f.label in bills} onPress={() => setBills((b) => { const n = { ...b }; if (f.label in n) delete n[f.label]; else n[f.label] = null; return n; })} />)}</View>
            {Object.keys(bills).map((label) => <MoneyInput key={label} label={label} valueCents={bills[label] ?? null} onChangeCents={(v) => setBills((b) => ({ ...b, [label]: v }))} />)}
          </View>
        ) : null}
        {step === 3 ? (
          <View style={{ gap: spacing.md }}>
            <Text role="headline">Você usa cartão de crédito?</Text>
            <Text role="body" color="textMuted">Com fechamento e vencimento o app mostra a fatura certa e nunca conta a compra duas vezes.</Text>
            <Input label="Nome" value={cardName} onChangeText={setCardName} />
            <MoneyInput label="Limite" valueCents={limit} onChangeCents={setLimit} />
            <View style={{ flexDirection: 'row', gap: spacing.sm }}><View style={{ flex: 1 }}><Input label="Dia do fechamento" value={closing} onChangeText={setClosing} keyboardType="number-pad" maxLength={2} /></View><View style={{ flex: 1 }}><Input label="Dia do vencimento" value={due} onChangeText={setDue} keyboardType="number-pad" maxLength={2} /></View></View>
          </View>
        ) : null}
        <View style={{ marginTop: 'auto', gap: spacing.xs }}>
          <Card inset><Text role="caption" color="textMuted">Passo {step + 1} de 4 · tudo pode ser alterado depois</Text></Card>
          <Button title={step === 0 ? 'Começar' : step === 3 ? 'Concluir' : 'Continuar'} onPress={() => void next()} loading={busy} fullWidth disabled={step === 1 && !accountName.trim()} testID="onboarding-next" />
          {step > 0 ? <Button title={step === 3 ? 'Não uso cartão' : 'Pular'} variant="ghost" onPress={() => void skip()} fullWidth /> : null}
        </View>
      </View>
    </KeyboardAvoidingView>
  );
}
