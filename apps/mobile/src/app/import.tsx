import React, { useState } from 'react';
import { View, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { parseCSV, guessColumnMapping, candidatesFromCSV, parseOFX, candidatesFromOFX, findDuplicates, isLegacyBackup, importLegacyBackup, validateBackup, hasFeature, type ImportCandidate, type ColumnMapping, type Transaction } from '@financas/core';
import { Screen, Card, CardHeader, Text, Button, Chip, Money, spacing, useColors } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';
import { Field, ChipSelect, ConfirmSheet } from '../features/shared/FormBits';
import { pickTextFile } from '../services/files';
import { newId } from '../state/ids';

type Stage = 'pick' | 'map' | 'review' | 'done';

/** CSV/OFX/backup import with preview, column mapping, duplicate detection and explicit confirmation. Nothing is written before "Importar". */
export default function ImportScreen() {
  const router = useRouter();
  const c = useColors();
  const { ledger, importTransactions, restoreLedger, access } = useAppStore();
  const [stage, setStage] = useState<Stage>('pick');
  const [fileName, setFileName] = useState('');
  const [table, setTable] = useState<ReturnType<typeof parseCSV> | null>(null);
  const [mapping, setMapping] = useState<ColumnMapping>({});
  const [candidates, setCandidates] = useState<ImportCandidate[]>([]);
  const [dupes, setDupes] = useState<Map<number, string>>(new Map());
  const [skip, setSkip] = useState<Set<number>>(new Set());
  const [accountId, setAccountId] = useState<string | undefined>(ledger.accounts[0]?.id);
  const [categoryByName, setCategoryByName] = useState(true);
  const [error, setError] = useState<string | undefined>();
  const [legacy, setLegacy] = useState<ReturnType<typeof importLegacyBackup> | null>(null);
  const [confirmRestore, setConfirmRestore] = useState(false);
  const [result, setResult] = useState<string>('');

  const pick = async () => {
    setError(undefined);
    try {
      const f = await pickTextFile(); if (!f) return;
      setFileName(f.name);
      const trimmed = f.text.trimStart();
      if (trimmed.startsWith('{')) {
        const json = JSON.parse(trimmed);
        if (isLegacyBackup(json)) { setLegacy(importLegacyBackup(json)); setStage('review'); return; }
        const v = validateBackup(json);
        if (v.ok) { setLegacy({ ledger: v.backup.ledger, warnings: [], counts: { transactions: v.backup.ledger.transactions.length, accounts: v.backup.ledger.accounts.length } }); setStage('review'); return; }
        throw new Error(v.error);
      }
      if (/<OFX>|OFXHEADER/i.test(trimmed)) {
        if (!hasFeature(access, 'ofx_import')) { router.push('/paywall?feature=ofx_import'); return; }
        const cands = candidatesFromOFX(parseOFX(f.text));
        finishCandidates(cands);
        return;
      }
      const t = parseCSV(f.text); setTable(t); setMapping(guessColumnMapping(t.headers)); setStage('map');
    } catch (e) { setError(e instanceof Error ? e.message : 'Não foi possível ler o arquivo.'); }
  };
  const finishCandidates = (cands: ImportCandidate[]) => {
    setCandidates(cands);
    const d = findDuplicates(ledger, cands);
    setDupes(new Map(d.map((m) => [m.candidateIndex, m.reason === 'external_ref' ? 'já importado' : m.reason === 'exact' ? 'igual a um lançamento existente' : 'parecido com um lançamento existente'])));
    setSkip(new Set([...d.map((m) => m.candidateIndex), ...cands.filter((x) => x.problems.length).map((x) => x.rowIndex)]));
    setStage('review');
  };
  const applyMapping = () => { if (!table) return; if (mapping.date === undefined || mapping.amount === undefined) return setError('Escolha as colunas de data e valor.'); finishCandidates(candidatesFromCSV(table, mapping)); };
  const doImport = async () => {
    if (!accountId) return setError('Escolha a conta de destino.');
    const list: Transaction[] = candidates.filter((x) => !skip.has(x.rowIndex) && !x.problems.length).map((x) => {
      const cat = categoryByName && x.categoryName ? ledger.categories.find((k) => k.name.toLowerCase() === x.categoryName!.toLowerCase() && k.kind === x.kind) : undefined;
      return { id: newId(), kind: x.kind, amountCents: x.amountCents, currency: ledger.prefs.currency, date: x.date, description: x.description, accountId, categoryId: cat?.id, status: 'settled', tags: [], attachments: [], notes: x.notes, externalRef: x.externalRef ?? `import:${fileName}:${x.rowIndex}:${x.date}:${x.amountCents}`, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() };
    });
    const n = await importTransactions(list);
    setResult(`${n} lançamento(s) importado(s); ${candidates.length - n} ignorado(s).`); setStage('done');
  };
  const cols = table?.headers.map((h, i) => ({ value: String(i), label: h || `Coluna ${i + 1}` })) ?? [];
  const mapField = (k: keyof ColumnMapping, label: string) => <Field key={k} label={label}><ChipSelect options={cols} value={mapping[k] !== undefined ? String(mapping[k]) : undefined} onChange={(v) => setMapping({ ...mapping, [k]: v === undefined ? undefined : Number(v) })} allowNone /></Field>;
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Importar" />
      <Screen>
        {stage === 'pick' ? <Card style={{ gap: spacing.sm }}>
          <Text role="title">CSV, OFX ou backup</Text>
          <Text role="bodySmall" color="textMuted">CSV do seu banco ou de outro app (data, descrição, valor, tipo); OFX de extrato bancário (Plus); ou um backup do SerenaCash / do app anterior. Você revisa tudo antes de confirmar e o app aponta possíveis duplicidades.</Text>
          <Button title="Escolher arquivo" icon="upload" onPress={() => void pick()} fullWidth />
          {error ? <Text role="bodySmall" color="negative">{error}</Text> : null}
        </Card> : null}
        {stage === 'map' && table ? <Card style={{ gap: spacing.md }}>
          <CardHeader title={`Colunas de ${fileName}`} />
          <Text role="bodySmall" color="textMuted">{table.rows.length} linhas. Confira as colunas:</Text>
          {mapField('date', 'Data')}{mapField('description', 'Descrição')}{mapField('amount', 'Valor')}{mapField('type', 'Tipo (receita/despesa)')}{mapField('category', 'Categoria')}{mapField('notes', 'Observações')}
          <Text role="caption" color="textMuted">Sem coluna de tipo, valores negativos viram despesas e positivos, receitas.</Text>
          {error ? <Text role="bodySmall" color="negative">{error}</Text> : null}
          <Button title="Revisar lançamentos" onPress={applyMapping} fullWidth />
        </Card> : null}
        {stage === 'review' && legacy ? <Card style={{ gap: spacing.sm }}>
          <CardHeader title="Restaurar backup" />
          <Text role="body">{Object.entries(legacy.counts).map(([k, v]) => `${v} ${k}`).join(' · ')}</Text>
          {legacy.warnings.length ? <Text role="bodySmall" color="warning">{legacy.warnings.length} aviso(s): {legacy.warnings.slice(0, 3).join(' ')}</Text> : null}
          <Text role="bodySmall" color="negative">Restaurar substitui TODOS os dados atuais deste aparelho.</Text>
          <Button title="Substituir meus dados por este backup" variant="destructive" onPress={() => setConfirmRestore(true)} fullWidth />
        </Card> : null}
        {stage === 'review' && !legacy ? <View style={{ gap: spacing.sm }}>
          <Card style={{ gap: spacing.sm }}>
            <CardHeader title={`${candidates.length} lançamentos encontrados`} />
            <Text role="bodySmall" color="textMuted">{dupes.size} possível(is) duplicidade(s) e {candidates.filter((x) => x.problems.length).length} com erro foram desmarcados. Toque para incluir ou excluir.</Text>
            <Field label="Conta de destino"><ChipSelect options={ledger.accounts.filter((a) => !a.archived).map((a) => ({ value: a.id, label: a.name }))} value={accountId} onChange={setAccountId} /></Field>
            <View style={{ flexDirection: 'row', gap: 8 }}><Chip label="Usar categorias pelo nome" selected={categoryByName} onPress={() => setCategoryByName(!categoryByName)} /></View>
          </Card>
          <Card>
            <ScrollView style={{ maxHeight: 420 }}>
              {candidates.map((x) => { const off = skip.has(x.rowIndex); const why = x.problems[0] ?? dupes.get(x.rowIndex); return (
                <View key={x.rowIndex} style={{ flexDirection: 'row', alignItems: 'center', gap: 8, paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: c.border, opacity: off ? 0.55 : 1 }}>
                  <Chip label={off ? 'Incluir' : 'OK'} selected={!off} onPress={() => { const s = new Set(skip); if (off) s.delete(x.rowIndex); else s.add(x.rowIndex); setSkip(s); }} />
                  <View style={{ flex: 1 }}><Text role="bodySmall" numberOfLines={1}>{x.description || '(sem descrição)'}</Text><Text role="caption" color={why ? (x.problems.length ? 'negative' : 'warning') : 'textMuted'}>{x.date.slice(8, 10)}/{x.date.slice(5, 7)}/{x.date.slice(0, 4)}{why ? ` · ${why}` : ''}</Text></View>
                  <Money cents={x.kind === 'income' ? x.amountCents : -x.amountCents} signed role="bodySmall" />
                </View>); })}
            </ScrollView>
          </Card>
          {error ? <Text role="bodySmall" color="negative">{error}</Text> : null}
          <Button title={`Importar ${candidates.filter((x) => !skip.has(x.rowIndex) && !x.problems.length).length} lançamento(s)`} onPress={() => void doImport()} fullWidth />
        </View> : null}
        {stage === 'done' ? <Card style={{ gap: spacing.sm }}><Text role="title">Pronto</Text><Text role="body">{result}</Text><Button title="Ver lançamentos" onPress={() => router.replace('/transactions')} fullWidth /></Card> : null}
      </Screen>
      <ConfirmSheet visible={confirmRestore} title="Substituir todos os dados?" text="Os dados atuais serão apagados e trocados pelo backup. Não é possível desfazer." confirmLabel="Restaurar backup" onConfirm={async () => { setConfirmRestore(false); if (legacy) { await restoreLedger(legacy.ledger); setResult('Backup restaurado.'); setStage('done'); } }} onCancel={() => setConfirmRestore(false)} />
    </View>
  );
}
