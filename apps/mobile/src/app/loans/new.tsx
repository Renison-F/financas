import React, { useMemo, useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { buildSchedule, totalInterest, totalCost, formatBRL, type AmortizationSystem } from '@financas/core';
import { Screen, Button, MoneyInput, Input, Text, Card, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Field, ChipSelect, Toggle, DateField, Segmented } from '../../features/shared/FormBits';

export default function LoanEdit() {
  const { id } = useLocalSearchParams<{ id?: string }>();
  const router = useRouter();
  const { ledger, saveLoan, today } = useAppStore();
  const existing = id ? ledger.loans.find((l) => l.id === id) : undefined;
  const [name, setName] = useState(existing?.name ?? '');
  const [principal, setPrincipal] = useState<number | null>(existing?.principalCents ?? null);
  const [rate, setRate] = useState(existing ? String(existing.monthlyRatePercent).replace('.', ',') : '');
  const [term, setTerm] = useState(existing ? String(existing.termMonths) : '12');
  const [system, setSystem] = useState<AmortizationSystem>(existing?.system ?? 'price');
  const [firstDue, setFirstDue] = useState(existing?.firstDueDate ?? today());
  const [fee, setFee] = useState<number | null>(existing?.monthlyFeeCents ?? null);
  const [accountId, setAccountId] = useState<string | undefined>(existing?.accountId ?? ledger.accounts[0]?.id);
  const [registerDisbursement, setRegisterDisbursement] = useState(false);
  const [createInstallments, setCreateInstallments] = useState(true);
  const [error, setError] = useState<string | undefined>();
  const rateNum = Number(rate.replace(',', '.'));
  const termNum = Number(term);
  const preview = useMemo(() => (principal && Number.isFinite(rateNum) && termNum >= 1 && termNum <= 480 ? buildSchedule({ principalCents: principal, monthlyRatePercent: rateNum, termMonths: termNum, system, firstDueDate: firstDue, monthlyFeeCents: fee ?? 0, upfrontFeesCents: 0 }) : null), [principal, rateNum, termNum, system, firstDue, fee]);
  const save = async () => {
    if (!name.trim() || !principal || !Number.isFinite(rateNum) || rateNum < 0 || !Number.isInteger(termNum) || termNum < 1) return setError('Preencha nome, valor, taxa (% ao mês) e prazo.');
    await saveLoan({ id: existing?.id, name: name.trim(), principalCents: principal, monthlyRatePercent: rateNum, termMonths: termNum, system, firstDueDate: firstDue, monthlyFeeCents: fee ?? 0, accountId }, { registerDisbursement: !existing && registerDisbursement, createInstallments: !existing && createInstallments });
    router.back();
  };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={existing ? 'Editar empréstimo' : 'Novo empréstimo'} right={<Button title="Salvar" variant="ghost" onPress={() => void save()} />} />
      <Screen>
        <View style={{ gap: spacing.md }}>
          <Input label="Nome" value={name} onChangeText={setName} placeholder="Ex.: Financiamento do carro" />
          <MoneyInput label="Valor emprestado" valueCents={principal} onChangeCents={setPrincipal} />
          <View style={{ flexDirection: 'row', gap: spacing.sm }}><View style={{ flex: 1 }}><Input label="Juros (% ao mês)" value={rate} onChangeText={setRate} keyboardType="decimal-pad" placeholder="1,99" /></View><View style={{ flex: 1 }}><Input label="Parcelas" value={term} onChangeText={setTerm} keyboardType="number-pad" /></View></View>
          <Field label="Sistema"><Segmented options={[{ value: 'price', label: 'Price (parcela fixa)' }, { value: 'sac', label: 'SAC (decrescente)' }]} value={system} onChange={setSystem} /></Field>
          <DateField label="Primeiro vencimento" value={firstDue} onChange={setFirstDue} />
          <MoneyInput label="Tarifa/seguro mensal (opcional)" valueCents={fee} onChangeCents={setFee} />
          <Field label="Conta"><ChipSelect options={ledger.accounts.filter((a) => !a.archived).map((a) => ({ value: a.id, label: a.name }))} value={accountId} onChange={setAccountId} allowNone /></Field>
          {!existing ? <><Toggle label="Registrar a entrada do dinheiro na conta" value={registerDisbursement} onChange={setRegisterDisbursement} help="Ligue se o valor caiu na conta hoje." /><Toggle label="Criar as parcelas como contas previstas" value={createInstallments} onChange={setCreateInstallments} help="Entram em 'contas a pagar' e no 'pode gastar' mês a mês." /></> : null}
          {preview ? <Card inset><Text role="label" color="textMuted">Prévia</Text><Text role="body">{preview.length} parcelas · primeira {formatBRL(preview[0]!.installmentCents)}{system === 'sac' ? ` · última ${formatBRL(preview[preview.length - 1]!.installmentCents)}` : ''}</Text><Text role="bodySmall" color="textMuted">Juros totais {formatBRL(totalInterest(preview))} · custo total {formatBRL(totalCost(preview))}</Text><Text role="caption" color="textMuted">Hipóteses: taxa nominal mensal sobre o saldo devedor; arredondamento por parcela; IOF e seguros só se informados.</Text></Card> : null}
          {error ? <Text role="bodySmall" color="negative">{error}</Text> : null}
        </View>
      </Screen>
    </View>
  );
}
