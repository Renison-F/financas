import React, { useEffect, useState } from 'react';
import { View, Linking } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { PLANS, FREE_LIMITS, FEATURE_LABELS_PT, PLUS_FEATURES, mergeEntitlements, type FeatureKey } from '@financas/core';
import { Screen, Card, Text, Button, RhythmBar, useColors, spacing, Icon } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';
import { getBilling, type BillingProvider, type StoreOffer } from '../services/billing';

/** Paywall: plan comparison, store offers (when available), purchase, restore, clear lifetime policy. */
export default function PaywallScreen() {
  const { feature } = useLocalSearchParams<{ feature?: FeatureKey }>();
  const router = useRouter();
  const c = useColors();
  const { access, entitlements, setEntitlements } = useAppStore();
  const [billing, setBilling] = useState<BillingProvider | null>(null);
  const [offers, setOffers] = useState<StoreOffer[]>([]);
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState('');
  useEffect(() => { let on = true; getBilling().then(async (b) => { if (!on) return; setBilling(b); if (b.available) { try { setOffers(await b.getOffers()); const e = await b.getEntitlements(); if (e.length) await setEntitlements(mergeEntitlements(entitlements, e)); } catch { /* offline: keep cached */ } } }); return () => { on = false; }; // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  const buy = async (offer: StoreOffer) => { if (!billing) return; setBusy(offer.productId); setMsg(''); try { const e = await billing.purchase(offer); await setEntitlements(mergeEntitlements(entitlements, e)); setMsg('Obrigado! Seu plano está ativo.'); } catch (err) { setMsg(err instanceof Error ? err.message : 'Compra não concluída.'); } finally { setBusy(null); } };
  const restore = async () => { if (!billing) return; setBusy('restore'); setMsg(''); try { const e = await billing.restore(); await setEntitlements(mergeEntitlements(entitlements, e)); setMsg(e.length ? 'Compras restauradas.' : 'Nenhuma compra encontrada nesta conta da loja.'); } catch (err) { setMsg(err instanceof Error ? err.message : 'Não foi possível restaurar.'); } finally { setBusy(null); } };
  const offerFor = (planId: string) => offers.find((o) => o.planId === planId);
  const planCards = PLANS.filter((p) => p.id !== 'free');
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="SerenaCash Plus" />
      <Screen>
        {feature ? <Card inset style={{ marginBottom: spacing.sm }}><Text role="bodySmall">"{FEATURE_LABELS_PT[feature] ?? feature}" faz parte do Plus.</Text></Card> : null}
        {access.tier !== 'free' ? <Card style={{ marginBottom: spacing.sm, backgroundColor: c.primaryContainer }}><Text role="title" color="onPrimaryContainer">{access.reason}</Text><Text role="bodySmall" color="onPrimaryContainer">Plano {PLANS.find((p) => p.id === access.planId)?.name}. Obrigado por apoiar o SerenaCash.</Text></Card> : null}
        <Card style={{ marginBottom: spacing.sm }}>
          <Text role="title">O que muda</Text>
          <View style={{ marginTop: 8, gap: 6 }}>
            <Row k="Contas / cartões / orçamentos / metas" free={`${FREE_LIMITS.accounts} / ${FREE_LIMITS.cards} / ${FREE_LIMITS.budgets} / ${FREE_LIMITS.goals}`} plus="Ilimitados" />
            <Row k="Leitura de etiquetas (OCR)" free={`${FREE_LIMITS.ocrScansPerMonth}/mês`} plus="Ilimitada" />
            <Row k="Relatórios avançados e PDF" free="—" plus="Sim" />
            <Row k="Importação OFX e anexos" free="—" plus="Sim" />
            <Row k="Histórico de preços por loja" free="—" plus="Sim" />
            <Row k="Sincronização entre aparelhos" free="—" plus="Assinatura (quando disponível)" />
          </View>
          <Text role="caption" color="textMuted" style={{ marginTop: 8 }}>O essencial (contas, lançamentos, 1 cartão, orçamentos, metas, listas e carrinho) é gratuito para sempre.</Text>
        </Card>
        <View style={{ gap: spacing.sm }}>
          {planCards.map((p) => { const o = offerFor(p.id); const rec = p.id === 'plus_yearly'; return (
            <Card key={p.id} style={rec ? { backgroundColor: c.primaryContainer } : undefined}>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}><Text role="title" color={rec ? 'onPrimaryContainer' : 'text'}>{p.name}</Text>{rec ? <Text role="label" color="onPrimaryContainer">recomendado</Text> : null}</View>
              <Text role="bodySmall" color={rec ? 'onPrimaryContainer' : 'textMuted'} style={{ marginTop: 4 }}>{p.id === 'lifetime' ? 'Pagamento único. Inclui tudo o que funciona no aparelho, para sempre. Não inclui serviços com custo recorrente (sincronização).' : p.period === 'year' ? 'Cobrado uma vez por ano. Cancele quando quiser na loja.' : 'Cobrado mensalmente. Cancele quando quiser na loja.'}</Text>
              <View style={{ marginTop: 8 }}><RhythmBar percent={p.id === 'lifetime' ? 100 : p.id === 'plus_yearly' ? 70 : 40} expectedPercent={rec ? 70 : undefined} label="Abrangência do plano" /></View>
              <View style={{ marginTop: 10 }}>
                {o ? <Button title={`${o.priceString}${o.period ? (p.period === 'year' ? ' / ano' : ' / mês') : ''}`} onPress={() => void buy(o)} loading={busy === o.productId} fullWidth variant={rec ? 'primary' : 'secondary'} />
                  : <Text role="caption" color={rec ? 'onPrimaryContainer' : 'textMuted'}>{billing?.available ? 'Carregando preço da loja…' : 'Preço e compra disponíveis na versão publicada nas lojas.'}</Text>}
              </View>
            </Card>); })}
        </View>
        <View style={{ marginTop: spacing.md, gap: spacing.xs }}>
          <Button title="Restaurar compras" variant="ghost" onPress={() => void restore()} loading={busy === 'restore'} disabled={!billing?.available} fullWidth />
          {billing?.manageSubscriptionsUrl ? <Button title="Gerenciar assinatura na loja" variant="ghost" onPress={async () => { const u = await billing.manageSubscriptionsUrl?.(); if (u) void Linking.openURL(u); }} fullWidth /> : null}
          {msg ? <Text role="bodySmall" color={msg.includes('Obrigado') || msg.includes('restauradas') ? 'positive' : 'textMuted'} align="center">{msg}</Text> : null}
          <Text role="caption" color="textMuted" align="center">Assinaturas renovam automaticamente até serem canceladas na App Store ou no Google Play. Reembolsos seguem as políticas das lojas. Termos e privacidade: Mais → Privacidade.</Text>
          <View style={{ flexDirection: 'row', justifyContent: 'center', gap: 6, marginTop: 4 }}><Icon name="lock" size={14} color={c.textMuted} /><Text role="caption" color="textMuted">Pagamento processado pela loja; não vemos seus dados de pagamento.</Text></View>
        </View>
        <Text role="caption" color="textMuted" style={{ marginTop: spacing.md }}>Recursos do Plus: {PLUS_FEATURES.map((f) => FEATURE_LABELS_PT[f]).join(' · ')}</Text>
        <Button title="Continuar no gratuito" variant="ghost" onPress={() => router.back()} fullWidth />
      </Screen>
    </View>
  );
}
function Row({ k, free, plus }: { k: string; free: string; plus: string }) { return <View style={{ flexDirection: 'row', gap: 8 }}><Text role="bodySmall" style={{ flex: 2 }}>{k}</Text><Text role="bodySmall" color="textMuted" style={{ flex: 1 }}>{free}</Text><Text role="bodySmall" color="primary" style={{ flex: 1.2 }}>{plus}</Text></View>; }
