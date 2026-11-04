import React, { useState } from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { exportTransactionsCSV, createBackup, monthKeyOf, expensesByCategory, monthTotals, formatBRL, hasFeature, searchTransactions } from '@financas/core';
import { Screen, Card, CardHeader, Text, Button, Chip, spacing } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';
import { shareText, sharePDF } from '../services/files';

const esc = (s: string) => s.replace(/[&<>"]/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);

export default function ExportScreen() {
  const router = useRouter();
  const { ledger, today, access } = useAppStore();
  const [scope, setScope] = useState<'month' | 'all'>('month');
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState('');
  const month = monthKeyOf(today());
  const tx = scope === 'month' ? searchTransactions(ledger, '', { from: `${month}-01`, to: `${month}-31` }) : searchTransactions(ledger, '');
  const run = async (key: string, fn: () => Promise<void>) => { setBusy(key); setMsg(''); try { await fn(); setMsg('Arquivo gerado.'); } catch (e) { setMsg(e instanceof Error ? e.message : 'Falha ao exportar.'); } finally { setBusy(null); } };
  const pdf = () => {
    const t = monthTotals(ledger, month); const cats = expensesByCategory(ledger, month, { rollUp: true });
    const rows = tx.map((x) => `<tr><td>${x.date.slice(8, 10)}/${x.date.slice(5, 7)}</td><td>${esc(x.description || x.kind)}</td><td>${esc(ledger.categories.find((k) => k.id === x.categoryId)?.name ?? '')}</td><td style="text-align:right">${x.kind === 'income' ? '' : '−'}${formatBRL(x.amountCents)}</td></tr>`).join('');
    const html = `<html><head><meta charset="utf-8"><style>body{font-family:-apple-system,Roboto,Helvetica,Arial;color:#162022;padding:24px}h1{color:#0B5563;margin:0}table{width:100%;border-collapse:collapse;font-size:12px}td,th{padding:6px;border-bottom:1px solid #D3DCDA}th{text-align:left;color:#4F5E61}.k{display:flex;gap:24px;margin:16px 0}.k div b{display:block;font-size:18px}</style></head><body><h1>SerenaCash</h1><p>Relatório ${scope === 'month' ? `de ${month.slice(5, 7)}/${month.slice(0, 4)}` : 'completo'} · gerado em ${today()}</p><div class="k"><div>Receitas<b>${formatBRL(t.incomeSettled)}</b></div><div>Despesas<b>${formatBRL(t.expenseSettled)}</b></div><div>Resultado<b>${formatBRL(t.net)}</b></div></div><h3>Por categoria</h3><table>${cats.map((k) => `<tr><td>${esc(k.name)}</td><td style="text-align:right">${formatBRL(k.cents)}</td><td style="text-align:right">${k.percent}%</td></tr>`).join('')}</table><h3>Lançamentos</h3><table><tr><th>Data</th><th>Descrição</th><th>Categoria</th><th style="text-align:right">Valor</th></tr>${rows}</table><p style="color:#4F5E61;font-size:11px">Valores efetivados e previstos conforme registrados pelo usuário. Compras no cartão contam na data da compra; pagamentos de fatura não são despesas.</p></body></html>`;
    return sharePDF(`serenacash-${scope === 'month' ? month : 'completo'}.pdf`, html);
  };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Exportar e backup" />
      <Screen>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Lançamentos" />
          <View style={{ flexDirection: 'row', gap: 8 }}><Chip label="Este mês" selected={scope === 'month'} onPress={() => setScope('month')} /><Chip label="Tudo" selected={scope === 'all'} onPress={() => setScope('all')} /></View>
          <Text role="bodySmall" color="textMuted">{tx.length} lançamento(s)</Text>
          <Button title="CSV (planilha)" icon="download" variant="secondary" loading={busy === 'csv'} onPress={() => void run('csv', () => shareText(`serenacash-${scope === 'month' ? month : 'tudo'}.csv`, exportTransactionsCSV(ledger, tx), 'text/csv'))} fullWidth />
          <Button title="PDF (relatório)" icon="download" variant="secondary" loading={busy === 'pdf'} onPress={() => (hasFeature(access, 'pdf_export') ? void run('pdf', pdf) : router.push('/paywall?feature=pdf_export'))} fullWidth />
        </Card>
        <Card style={{ gap: spacing.sm }}>
          <CardHeader title="Backup completo" />
          <Text role="bodySmall" color="textMuted">Arquivo JSON com tudo (contas, lançamentos, cartões, orçamentos, metas, empréstimos, preferências). Guarde em local seguro; restaure em Importar.</Text>
          <Button title="Gerar backup" icon="download" loading={busy === 'bk'} onPress={() => void run('bk', () => shareText(`serenacash-backup-${today()}.json`, JSON.stringify(createBackup(ledger), null, 2), 'application/json'))} fullWidth />
          {msg ? <Text role="bodySmall" color={msg.includes('gerado') ? 'positive' : 'negative'}>{msg}</Text> : null}
        </Card>
      </Screen>
    </View>
  );
}
