import React, { useEffect, useMemo, useState } from 'react';
import { View, Pressable, ScrollView } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { startSession, addToSession, updateSessionLine, removeFromSession, sessionTotals, lineTotal, finishSession, plannedVsActual, markRegistered, lineFromListItem, findProduct, priceHistory, priceVariation, UNITS, UNIT_IDS, formatQuantity, type CartLine, type ShoppingSession, type Unit } from '@financas/shopping';
import { formatBRL, withinLimit, hasFeature } from '@financas/core';
import { Text, Money, Button, MoneyInput, Input, Icon, Chip, RhythmBar, Card, useColors, spacing, radius, touch, EmptyState } from '../../design';
import { useAppStore } from '../../state/appStore';
import { useScanStore } from '../../features/shopping/scanStore';
import { Field, ChipSelect, ConfirmSheet, Segmented } from '../../features/shared/FormBits';
import { newId } from '../../state/ids';

interface Draft { name: string; brand?: string | undefined; unit: Unit; quantity: string; unitPriceCents: number | null; barcode?: string | undefined; productId?: string | undefined; priceSource: CartLine['priceSource']; confidence?: number | undefined; warnings: string[]; lineId?: string | undefined; listItemId?: string | undefined; discountPercent?: number | undefined; promo?: CartLine['promo'] | undefined; promoFromCents?: number | undefined; }

/** Supermarket session: running total, budget remaining, camera/manual add with mandatory confirmation, finish and optional expense. */
export default function SessionScreen() {
  const { id, listId } = useLocalSearchParams<{ id?: string; listId?: string }>();
  const router = useRouter();
  const c = useColors();
  const insets = useSafeAreaInsets();
  const { sessions, shoppingLists, saveSession, saveProduct, addPriceObservations, products, priceObservations, saveTransaction, ledger, access, today } = useAppStore();
  const scan = useScanStore((s) => s.result);
  const clearScan = useScanStore((s) => s.set);
  const existing = id ? sessions.find((s) => s.id === id) : sessions.find((s) => s.status === 'active' && (!listId || s.listId === listId));
  const list = shoppingLists.find((l) => l.id === (existing?.listId ?? listId));
  const [session, setSession] = useState<ShoppingSession | null>(existing ?? null);
  const [draft, setDraft] = useState<Draft | null>(null);
  const [budgetInput, setBudgetInput] = useState<number | null>(list?.budgetCents ?? null);
  const [storeInput, setStoreInput] = useState(list?.store ?? '');
  const [finishing, setFinishing] = useState(false);
  const [confirmAbandon, setConfirmAbandon] = useState(false);
  const [registered, setRegistered] = useState<string | null>(null);
  const [ocrCount, setOcrCount] = useState(0);
  const now = () => new Date().toISOString();
  const persist = async (s: ShoppingSession) => { setSession(s); await saveSession(s); };
  const totals = useMemo(() => (session ? sessionTotals(session) : null), [session]);
  const readOnly = session?.status === 'finished';

  // consume scan results
  useEffect(() => {
    if (!scan || !session) return;
    clearScan(null);
    if (scan.kind === 'nfce') { void persist({ ...session, receiptAccessKey: scan.nfceKey, events: [...session.events, { at: now(), type: 'scan', detail: 'nfce' }] }); return; }
    if (scan.kind === 'barcode' && scan.barcode) {
      const b = scan.barcode;
      const found = findProduct(products, { barcode: b.gtin ?? b.raw, store: session.store });
      const hist = found ? priceHistory(priceObservations, found.product.id) : null;
      const listItem = list?.items.find((i) => i.barcode === (b.gtin ?? b.raw) || (found && i.productId === found.product.id));
      setDraft({ name: found?.product.name ?? '', brand: found?.product.brand, unit: found?.product.defaultUnit ?? 'un', quantity: listItem ? String(listItem.quantity) : '1', unitPriceCents: hist?.lastCents ?? listItem?.estimatedUnitPriceCents ?? null, barcode: b.gtin ?? b.raw, productId: found?.product.id, priceSource: hist?.lastCents !== undefined ? 'history' : 'manual', warnings: [...(found ? [] : ['Produto novo: informe o nome e o preço da etiqueta.']), ...(b.kind === 'gs1_variable_measure' ? ['Código de balança: o valor embutido pode ser peso ou preço; confirme.'] : [])], listItemId: listItem?.id, promoFromCents: undefined });
      return;
    }
    if (scan.kind === 'label') {
      const r = scan.reading;
      if (!r) { setDraft({ name: '', unit: 'un', quantity: '1', unitPriceCents: null, priceSource: 'manual', warnings: ['Leitura indisponível: informe manualmente.'] }); return; }
      if (!withinLimit(access, 'ocrScansPerMonth', ocrCount).ok && !hasFeature(access, 'unlimited_ocr')) { router.push('/paywall?feature=unlimited_ocr'); return; }
      setOcrCount((n) => n + 1);
      const found = r.barcode ? findProduct(products, { barcode: r.barcode }) : r.internalCode ? findProduct(products, { internalCode: r.internalCode, store: session.store }) : r.name ? findProduct(products, { name: r.name }) : undefined;
      const hist = found ? priceHistory(priceObservations, found.product.id) : null;
      const variation = hist && r.priceCents !== undefined ? priceVariation(hist, r.priceCents) : undefined;
      const warnings = [...r.warnings];
      if (variation && Math.abs(variation.percent) >= 10) warnings.push(`${variation.percent > 0 ? '+' : ''}${variation.percent}% em relação ao último preço (${formatBRL(variation.vsCents)}).`);
      if (r.confidence < 0.75) warnings.push('Leitura com baixa confiança: confira nome e preço.');
      setDraft({ name: found?.product.name ?? r.name ?? '', unit: r.priceUnit, quantity: r.priceUnit === 'kg' ? '1' : '1', unitPriceCents: r.priceCents ?? null, barcode: r.barcode, productId: found?.product.id, priceSource: 'label_ocr', confidence: r.confidence, warnings, promoFromCents: r.promoFromCents });
    }
  }, [scan]); // eslint-disable-line react-hooks/exhaustive-deps

  if (!session) {
    return (
      <View style={{ flex: 1, backgroundColor: c.bg, paddingTop: insets.top }}>
        <View style={{ padding: spacing.md, gap: spacing.md, maxWidth: 600, width: '100%', alignSelf: 'center' }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}><Text role="headline">Nova compra</Text><Button title="Fechar" variant="ghost" onPress={() => router.back()} /></View>
          <Text role="body" color="textMuted">{list ? `A partir da lista "${list.name}" (${list.items.length} itens).` : 'Sem lista: adicione itens pela câmera ou manualmente.'}</Text>
          <Input label="Supermercado" value={storeInput} onChangeText={setStoreInput} placeholder="Ex.: Mercado Bom" />
          <MoneyInput label="Orçamento desta compra (opcional)" valueCents={budgetInput} onChangeCents={setBudgetInput} help="O carrinho mostra quanto ainda cabe." />
          <Button title="Começar" icon="cart" onPress={() => void persist(startSession(newId(), now(), { store: storeInput.trim() || undefined, list, budgetCents: budgetInput ?? undefined }))} fullWidth />
          {!list && shoppingLists.length ? <Field label="Ou escolha uma lista"><ChipSelect options={shoppingLists.filter((l) => !l.archived).map((l) => ({ value: l.id, label: l.name }))} value={undefined} onChange={(v) => v && router.replace(`/shopping/session?listId=${v}`)} /></Field> : null}
        </View>
      </View>
    );
  }

  const openManual = () => setDraft({ name: '', unit: 'un', quantity: '1', unitPriceCents: null, priceSource: 'manual', warnings: [] });
  const openEdit = (l: CartLine) => setDraft({ name: l.name, brand: l.brand, unit: l.unit, quantity: String(l.quantity).replace('.', ','), unitPriceCents: l.unitPriceCents, barcode: l.barcode, productId: l.productId, priceSource: l.priceSource, confidence: l.confidence, warnings: [], lineId: l.id, listItemId: l.listItemId, discountPercent: l.discountPercent, promo: l.promo });
  const confirmDraft = async () => {
    if (!draft || draft.unitPriceCents === null || !draft.name.trim()) return;
    const q = Number(draft.quantity.replace(',', '.'));
    if (!Number.isFinite(q) || q <= 0) return;
    let productId = draft.productId;
    if (!productId && (draft.barcode || draft.name.trim())) {
      productId = newId();
      await saveProduct({ id: productId, name: draft.name.trim(), brand: draft.brand, barcode: draft.barcode, internalCodes: [], defaultUnit: draft.unit, favorite: false, createdAt: now(), updatedAt: now() });
    }
    const line: CartLine = { id: draft.lineId ?? newId(), productId, name: draft.name.trim(), brand: draft.brand, barcode: draft.barcode, unit: draft.unit, quantity: q, unitPriceCents: draft.unitPriceCents, priceSource: draft.priceSource, confidence: draft.lineId ? 1 : draft.confidence, listItemId: draft.listItemId, checked: true, discountPercent: draft.discountPercent, promo: draft.promo };
    const next = draft.lineId ? updateSessionLine(session, draft.lineId, line, now()) : addToSession(session, line, now());
    await persist(next); setDraft(null);
    void Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});
  };
  const addFromList = async (itemId: string) => { const it = list?.items.find((i) => i.id === itemId); if (!it) return; const l = lineFromListItem(it, newId()); if (l) await persist(addToSession(session, { ...l, checked: true }, now())); else setDraft({ name: it.name, unit: it.unit, quantity: String(it.quantity), unitPriceCents: null, priceSource: 'manual', warnings: ['Sem preço na lista: informe o preço da etiqueta.'], listItemId: it.id, productId: it.productId, barcode: it.barcode }); };
  const finish = async () => {
    setFinishing(true);
    try { const r = finishSession(session, now(), newId); await persist(r.session); await addPriceObservations(r.observations); } finally { setFinishing(false); }
  };
  const registerExpense = async () => {
    const r = finishSession(session, now(), newId);
    if (!r.suggestedTransaction) return;
    const cat = ledger.categories.find((k) => k.name === 'Supermercado') ?? ledger.categories.find((k) => k.name === 'Alimentação');
    const [t] = await saveTransaction({ kind: 'expense', amountCents: r.suggestedTransaction.amountCents, date: today(), description: r.suggestedTransaction.description, merchant: r.suggestedTransaction.merchant, categoryId: cat?.id, accountId: ledger.accounts.find((a) => !a.archived)?.id, status: 'settled', externalRef: r.suggestedTransaction.externalRef });
    if (t) { await persist(markRegistered(session, t.id, now())); setRegistered(t.id); }
  };
  const pva = list ? plannedVsActual(session, list) : null;
  const remainingListItems = list ? list.items.filter((i) => !session.lines.some((l) => l.listItemId === i.id)) : [];
  const progressPct = list && list.items.length ? ((list.items.length - remainingListItems.length) / list.items.length) * 100 : undefined;
  return (
    <View style={{ flex: 1, backgroundColor: c.bg, paddingTop: insets.top }}>
      <View style={{ paddingHorizontal: spacing.md, paddingBottom: spacing.sm, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
        <View style={{ flex: 1 }}><Text role="title" numberOfLines={1}>{session.store || 'Supermercado'}</Text><Text role="caption" color="textMuted">{readOnly ? `Finalizada em ${session.finishedAt?.slice(8, 10)}/${session.finishedAt?.slice(5, 7)}` : `${session.lines.length} item(ns) no carrinho`}</Text></View>
        <Button title={readOnly ? 'Fechar' : 'Sair'} variant="ghost" onPress={() => (readOnly ? router.back() : setConfirmAbandon(true))} />
      </View>
      <View style={{ paddingHorizontal: spacing.md }}>
        <Card style={{ backgroundColor: totals?.state === 'agitado' ? c.negativeContainer : totals?.state === 'atencao' ? c.warningContainer : c.primaryContainer }}>
          <Text role="label" color={totals?.state === 'agitado' ? 'negative' : totals?.state === 'atencao' ? 'warning' : 'onPrimaryContainer'}>Total do carrinho</Text>
          <Money cents={totals?.totalCents ?? 0} role="moneyHero" color={totals?.state === 'agitado' ? 'negative' : 'onPrimaryContainer'} />
          {totals?.budgetCents !== undefined ? <><Text role="bodySmall" color={totals.state === 'agitado' ? 'negative' : 'onPrimaryContainer'} style={{ marginTop: 4 }}>{totals.remainingCents! >= 0 ? `Ainda cabe ${formatBRL(totals.remainingCents!)} de ${formatBRL(totals.budgetCents)}` : `${formatBRL(-totals.remainingCents!)} acima do orçamento de ${formatBRL(totals.budgetCents)}`}</Text><View style={{ marginTop: 8 }}><RhythmBar percent={(totals.totalCents / totals.budgetCents) * 100} expectedPercent={progressPct} state={totals.state === 'sem_orcamento' ? undefined : totals.state} label="Carrinho contra o orçamento" /></View></> : <Text role="caption" color="onPrimaryContainer">Sem orçamento definido para esta compra.</Text>}
          {totals?.unconfirmedLines ? <Text role="caption" color="warning" style={{ marginTop: 4 }}>{totals.unconfirmedLines} item(ns) com leitura de baixa confiança.</Text> : null}
        </Card>
      </View>
      <ScrollView contentContainerStyle={{ padding: spacing.md, paddingBottom: 160, gap: spacing.sm }}>
        {session.lines.length ? session.lines.map((l) => { const t = lineTotal(l); return (
          <Pressable key={l.id} accessibilityRole="button" accessibilityLabel={`${l.name}, ${formatQuantity(l.quantity, l.unit)}, ${formatBRL(t.netCents)}`} disabled={readOnly} onPress={() => openEdit(l)} style={{ backgroundColor: c.surface, borderRadius: radius.md, padding: spacing.sm, flexDirection: 'row', alignItems: 'center', gap: spacing.sm }}>
            <View style={{ flex: 1 }}><Text role="body" numberOfLines={1}>{l.name}</Text><Text role="caption" color="textMuted">{formatQuantity(l.quantity, l.unit)} × {formatBRL(l.unitPriceCents)}{UNITS[l.unit].measured ? `/${UNITS[l.unit].label}` : ''}{t.discountCents ? ` · desconto ${formatBRL(t.discountCents)}` : ''}{l.priceSource === 'label_ocr' && (l.confidence ?? 1) < 0.75 ? ' · confira' : ''}</Text></View>
            <Money cents={t.netCents} />
            {!readOnly ? <Pressable accessibilityRole="button" accessibilityLabel={`Remover ${l.name}`} onPress={() => void persist(removeFromSession(session, l.id, now()))} hitSlop={8} style={{ width: 36, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="close" size={18} color={c.textMuted} /></Pressable> : null}
          </Pressable>); }) : <EmptyState icon="cart" title="Carrinho vazio" text="Leia a etiqueta de preço ou o código de barras, ou adicione manualmente." />}
        {!readOnly && remainingListItems.length ? <Card><Text role="label" color="textMuted" style={{ marginBottom: 4 }}>Da lista ({remainingListItems.length} faltando)</Text><View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>{remainingListItems.map((i) => <Chip key={i.id} label={`${i.name} · ${formatQuantity(i.quantity, i.unit)}`} onPress={() => void addFromList(i.id)} />)}</View></Card> : null}
        {readOnly ? <Card style={{ gap: 6 }}>
          <Text role="title">Resumo</Text>
          {pva ? <><Text role="bodySmall">Planejado (com preço): {formatBRL(pva.plannedKnownCents)} · Realizado: {formatBRL(pva.actualCents)} · Diferença: {formatBRL(pva.differenceCents)}</Text><Text role="bodySmall" color="textMuted">{pva.bought} da lista comprados · {pva.notBought.length} não comprados · {pva.extra.length} extras</Text></> : null}
          {session.receiptAccessKey ? <Text role="caption" color="textMuted">Cupom fiscal lido: chave …{session.receiptAccessKey.slice(-8)} (consulta à SEFAZ não disponível offline).</Text> : null}
          {session.transactionId || registered ? <Text role="bodySmall" color="positive">Despesa registrada nas finanças.</Text> : <><Button title={`Registrar ${formatBRL(totals?.totalCents ?? 0)} como despesa`} onPress={() => void registerExpense()} fullWidth /><Text role="caption" color="textMuted">Cria um único lançamento em Supermercado. Nunca é registrado duas vezes.</Text></>}
        </Card> : null}
      </ScrollView>
      {!readOnly ? (
        <View style={{ position: 'absolute', left: spacing.md, right: spacing.md, bottom: insets.bottom + spacing.md, gap: 8 }}>
          <View style={{ flexDirection: 'row', gap: 8 }}>
            <Button title="Etiqueta" icon="camera" onPress={() => router.push('/shopping/scan?mode=label')} style={{ flex: 1 }} fullWidth />
            <Button title="Código" icon="barcode" variant="secondary" onPress={() => router.push('/shopping/scan?mode=barcode')} style={{ flex: 1 }} fullWidth />
            <Button title="Manual" icon="plus" variant="secondary" onPress={openManual} style={{ flex: 1 }} fullWidth />
          </View>
          <Button title="Finalizar compra" variant="ghost" onPress={() => void finish()} loading={finishing} disabled={!session.lines.length} fullWidth />
        </View>
      ) : null}
      {draft ? (
        <View style={{ position: 'absolute', left: 0, right: 0, top: 0, bottom: 0, backgroundColor: c.overlay, justifyContent: 'flex-end' }}>
          <ScrollView keyboardShouldPersistTaps="handled" style={{ maxHeight: '88%' }} contentContainerStyle={{ backgroundColor: c.surface, borderTopLeftRadius: radius.lg, borderTopRightRadius: radius.lg, padding: spacing.lg, gap: spacing.sm, paddingBottom: insets.bottom + spacing.lg }}>
            <Text role="title">{draft.lineId ? 'Editar item' : 'Confirmar item'}</Text>
            {draft.warnings.map((w, i) => <Text key={i} role="bodySmall" color="warning">{w}</Text>)}
            {draft.confidence !== undefined ? <Text role="caption" color="textMuted">Confiança da leitura: {Math.round(draft.confidence * 100)}%</Text> : null}
            <Input label="Produto" value={draft.name} onChangeText={(v) => setDraft({ ...draft, name: v })} placeholder="Nome do produto" autoFocus={!draft.name} />
            <MoneyInput label={UNITS[draft.unit].measured ? `Preço por ${UNITS[draft.unit].label}` : 'Preço unitário'} valueCents={draft.unitPriceCents} onChangeCents={(v) => setDraft({ ...draft, unitPriceCents: v, priceSource: draft.priceSource === 'label_ocr' && v !== draft.unitPriceCents ? 'manual' : draft.priceSource })} />
            {draft.promoFromCents ? <Text role="caption" color="textMuted">Preço anterior na etiqueta: {formatBRL(draft.promoFromCents)}</Text> : null}
            <View style={{ flexDirection: 'row', gap: 8, alignItems: 'flex-end' }}>
              <View style={{ width: 110 }}><Input label={UNITS[draft.unit].measured ? `Quantidade (${UNITS[draft.unit].label})` : 'Quantidade'} value={draft.quantity} onChangeText={(v) => setDraft({ ...draft, quantity: v })} keyboardType="decimal-pad" /></View>
              {!UNITS[draft.unit].measured ? <View style={{ flexDirection: 'row', gap: 4 }}><Button title="−" variant="secondary" compact onPress={() => setDraft({ ...draft, quantity: String(Math.max(1, (Number(draft.quantity) || 1) - 1)) })} /><Button title="+" variant="secondary" compact onPress={() => setDraft({ ...draft, quantity: String((Number(draft.quantity) || 0) + 1) })} /></View> : null}
            </View>
            <Field label="Unidade"><Segmented options={[{ value: 'un', label: 'un' }, { value: 'kg', label: 'kg' }, { value: 'g', label: 'g' }, { value: 'l', label: 'L' }, { value: 'ml', label: 'mL' }]} value={(['un', 'kg', 'g', 'l', 'ml'] as Unit[]).includes(draft.unit) ? (draft.unit as 'un') : 'un'} onChange={(u) => setDraft({ ...draft, unit: u })} /></Field>
            <Field label="Promoção"><View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}><Chip label="Nenhuma" selected={!draft.promo && !draft.discountPercent} onPress={() => setDraft({ ...draft, promo: undefined, discountPercent: undefined })} /><Chip label="Leve 3 pague 2" selected={draft.promo?.take === 3} onPress={() => setDraft({ ...draft, promo: { take: 3, pay: 2 }, discountPercent: undefined })} /><Chip label="Leve 2 pague 1" selected={draft.promo?.take === 2} onPress={() => setDraft({ ...draft, promo: { take: 2, pay: 1 }, discountPercent: undefined })} /><Chip label="10% off" selected={draft.discountPercent === 10} onPress={() => setDraft({ ...draft, discountPercent: 10, promo: undefined })} /><Chip label="20% off" selected={draft.discountPercent === 20} onPress={() => setDraft({ ...draft, discountPercent: 20, promo: undefined })} /></View></Field>
            {draft.unitPriceCents !== null && Number(draft.quantity.replace(',', '.')) > 0 ? <Text role="body">Subtotal: {formatBRL(lineTotal({ id: 'x', name: draft.name, unit: draft.unit, quantity: Number(draft.quantity.replace(',', '.')), unitPriceCents: draft.unitPriceCents, priceSource: draft.priceSource, checked: true, promo: draft.promo, discountPercent: draft.discountPercent }).netCents)}</Text> : null}
            <Button title={draft.lineId ? 'Salvar' : 'Adicionar ao carrinho'} onPress={() => void confirmDraft()} disabled={draft.unitPriceCents === null || !draft.name.trim()} fullWidth />
            <Button title="Cancelar" variant="ghost" onPress={() => setDraft(null)} fullWidth />
            {UNIT_IDS.length ? null : null}
          </ScrollView>
        </View>
      ) : null}
      <ConfirmSheet visible={confirmAbandon} title="Sair da compra?" text="O carrinho fica salvo e você pode continuar depois pela aba Compras." confirmLabel="Sair e manter" destructive={false} onConfirm={() => { setConfirmAbandon(false); router.back(); }} onCancel={() => setConfirmAbandon(false)} />
    </View>
  );
}
