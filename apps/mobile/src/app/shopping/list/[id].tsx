import React, { useState } from 'react';
import { View, Pressable } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { estimateList, groupByCategory, addItem, updateItem, removeItem, toggleItem, uncheckAll, duplicateList, listProgress, priceHistory, findProduct, DEFAULT_CATEGORIES, UNITS, UNIT_IDS, formatQuantity, type ListItem, type Unit } from '@financas/shopping';
import { formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, MoneyInput, Input, Icon, Chip, RhythmBar, EmptyState, useColors, spacing, touch, radius } from '../../../design';
import { useAppStore } from '../../../state/appStore';
import { StackHeader } from '../../../features/shared/ScreenHeader';
import { Field, ChipSelect, ConfirmSheet, Collapsible } from '../../../features/shared/FormBits';
import { newId } from '../../../state/ids';

/** Shopping list: items by category, units, quantities, known-price estimate, check-off, duplicate, start session. */
export default function ListDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const c = useColors();
  const { shoppingLists, saveShoppingList, deleteShoppingList, products, priceObservations } = useAppStore();
  const list = shoppingLists.find((l) => l.id === id);
  const [name, setName] = useState('');
  const [qty, setQty] = useState('1');
  const [unit, setUnit] = useState<Unit>('un');
  const [category, setCategory] = useState<string>('Mercearia');
  const [price, setPrice] = useState<number | null>(null);
  const [editing, setEditing] = useState<ListItem | null>(null);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const now = () => new Date().toISOString();
  if (!list) return <View><StackHeader title="Lista" /><EmptyState icon="alert" title="Lista não encontrada" /></View>;
  const est = estimateList(list);
  const prog = listProgress(list);
  const groups = groupByCategory(list.items);
  const suggestPrice = (n: string) => { const p = findProduct(products, { name: n }); if (!p) return undefined; const h = priceHistory(priceObservations, p.product.id); return h.lastCents !== undefined ? { cents: h.lastCents, productId: p.product.id } : undefined; };
  const add = async () => {
    if (!name.trim()) return;
    const q = Number(qty.replace(',', '.')) || 1;
    const sug = price === null ? suggestPrice(name) : undefined;
    const next = addItem(list, { id: newId(), name: name.trim(), unit, quantity: q, category, estimatedUnitPriceCents: price ?? sug?.cents, estimateSource: price !== null ? 'manual' : sug ? 'history' : undefined, productId: sug?.productId }, now());
    await saveShoppingList(next); setName(''); setQty('1'); setPrice(null);
  };
  const saveEdit = async () => { if (!editing) return; await saveShoppingList(updateItem(list, editing.id, editing, now())); setEditing(null); };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={list.name} right={<Button title="Comprar" variant="ghost" icon="cart" compact onPress={() => router.push(`/shopping/session?listId=${list.id}`)} />} />
      <Screen>
        <Card style={{ marginBottom: spacing.sm }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-end' }}>
            <View><Text role="label" color="textMuted">Estimativa ({est.knownItems} de {est.totalItems} com preço)</Text><Money cents={est.knownCents} role="headline" /></View>
            {list.budgetCents !== undefined ? <View style={{ alignItems: 'flex-end' }}><Text role="label" color="textMuted">Orçamento</Text><Money cents={list.budgetCents} /></View> : null}
          </View>
          {list.budgetCents ? <View style={{ marginTop: 8 }}><RhythmBar percent={(est.knownCents / list.budgetCents) * 100} label="Estimativa contra o orçamento" /></View> : null}
          <Text role="caption" color="textMuted" style={{ marginTop: 6 }}>{list.store ? `${list.store} · ` : ''}{prog.checked}/{prog.total} marcados{est.unknownItems ? ` · ${est.unknownItems} item(ns) sem preço (não estimados)` : ''}</Text>
        </Card>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Adicionar item" />
          <Input value={name} onChangeText={setName} placeholder="Ex.: Arroz 5kg" accessibilityLabel="Nome do item" returnKeyType="done" onSubmitEditing={() => void add()} />
          <View style={{ flexDirection: 'row', gap: 8, alignItems: 'flex-end' }}>
            <View style={{ width: 90 }}><Input label="Qtd" value={qty} onChangeText={setQty} keyboardType="decimal-pad" /></View>
            <View style={{ flex: 1 }}><Field label="Unidade"><ChipSelect options={UNIT_IDS.map((u) => ({ value: u, label: UNITS[u].label }))} value={unit} onChange={(v) => setUnit(v ?? 'un')} /></Field></View>
          </View>
          <Collapsible title="Categoria e preço estimado">
            <ChipSelect options={DEFAULT_CATEGORIES.map((k) => ({ value: k, label: k }))} value={category} onChange={(v) => setCategory(v ?? 'Outros')} />
            <MoneyInput label="Preço estimado por unidade (opcional)" valueCents={price} onChangeCents={setPrice} help="Sem preço, o item entra na lista mas não na estimativa. Se já comprou antes, o histórico preenche sozinho." />
          </Collapsible>
          <Button title="Adicionar" icon="plus" onPress={() => void add()} disabled={!name.trim()} fullWidth />
        </Card>
        {groups.length ? groups.map((g) => (
          <Card key={g.category} style={{ marginBottom: spacing.sm }}>
            <Text role="label" color="textMuted" style={{ marginBottom: 4 }}>{g.category}</Text>
            {g.items.map((it) => (
              <View key={it.id} style={{ flexDirection: 'row', alignItems: 'center', gap: spacing.sm, minHeight: 52 }}>
                <Pressable accessibilityRole="checkbox" accessibilityState={{ checked: it.checked }} accessibilityLabel={`${it.name}, ${formatQuantity(it.quantity, it.unit)}`} onPress={() => void saveShoppingList(toggleItem(list, it.id, now()))} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}>
                  <View style={{ width: 24, height: 24, borderRadius: 7, borderWidth: 2, borderColor: it.checked ? c.primary : c.borderStrong, backgroundColor: it.checked ? c.primary : 'transparent', alignItems: 'center', justifyContent: 'center' }}>{it.checked ? <Icon name="check" size={16} color={c.onPrimary} /> : null}</View>
                </Pressable>
                <Pressable accessibilityRole="button" accessibilityLabel={`Editar ${it.name}`} onPress={() => setEditing({ ...it })} style={{ flex: 1 }}>
                  <Text role="body" style={{ textDecorationLine: it.checked ? 'line-through' : 'none' }} color={it.checked ? 'textMuted' : 'text'}>{it.name}</Text>
                  <Text role="caption" color="textMuted">{formatQuantity(it.quantity, it.unit)}{it.estimatedUnitPriceCents !== undefined ? ` × ${formatBRL(it.estimatedUnitPriceCents)}${UNITS[it.unit].measured ? `/${UNITS[it.unit].label}` : ''}${it.estimateSource === 'history' ? ' (histórico)' : ''}` : ' · sem preço'}</Text>
                </Pressable>
                {it.estimatedUnitPriceCents !== undefined ? <Money cents={Math.round(it.estimatedUnitPriceCents * it.quantity)} role="bodySmall" /> : null}
              </View>
            ))}
          </Card>
        )) : <Card style={{ marginBottom: spacing.sm }}><EmptyState icon="list" title="Lista vazia" text="Adicione os itens acima. Unidades: un, kg, g, L, mL, pacote, dúzia, caixa." /></Card>}
        <View style={{ gap: spacing.xs }}>
          <Button title="Iniciar compra com esta lista" icon="cart" onPress={() => router.push(`/shopping/session?listId=${list.id}`)} fullWidth />
          <View style={{ flexDirection: 'row', gap: 8 }}>
            <Button title="Desmarcar tudo" variant="ghost" compact onPress={() => void saveShoppingList(uncheckAll(list, now()))} />
            <Button title="Duplicar" variant="ghost" compact onPress={async () => { const copy = duplicateList(list, newId(), newId, now()); await saveShoppingList(copy); router.replace(`/shopping/list/${copy.id}`); }} />
            <Button title="Excluir" variant="ghost" compact onPress={() => setConfirmDelete(true)} />
          </View>
        </View>
      </Screen>
      {editing ? (
        <View style={{ position: 'absolute', left: 0, right: 0, bottom: 0, top: 0, backgroundColor: c.overlay, justifyContent: 'flex-end' }}>
          <View style={{ backgroundColor: c.surface, borderTopLeftRadius: radius.lg, borderTopRightRadius: radius.lg, padding: spacing.lg, gap: spacing.sm }}>
            <Text role="title">Editar item</Text>
            <Input label="Nome" value={editing.name} onChangeText={(v) => setEditing({ ...editing, name: v })} />
            <View style={{ flexDirection: 'row', gap: 8 }}><View style={{ width: 100 }}><Input label="Qtd" value={String(editing.quantity).replace('.', ',')} onChangeText={(v) => setEditing({ ...editing, quantity: Number(v.replace(',', '.')) || 0 })} keyboardType="decimal-pad" /></View><View style={{ flex: 1 }}><Field label="Unidade"><ChipSelect options={UNIT_IDS.map((u) => ({ value: u, label: UNITS[u].label }))} value={editing.unit} onChange={(v) => setEditing({ ...editing, unit: v ?? 'un' })} /></Field></View></View>
            <MoneyInput label="Preço estimado" valueCents={editing.estimatedUnitPriceCents ?? null} onChangeCents={(v) => setEditing({ ...editing, estimatedUnitPriceCents: v ?? undefined, estimateSource: v === null ? undefined : 'manual' })} />
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>{DEFAULT_CATEGORIES.map((k) => <Chip key={k} label={k} selected={editing.category === k} onPress={() => setEditing({ ...editing, category: k })} />)}</View>
            <Button title="Salvar" onPress={() => void saveEdit()} fullWidth />
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Button title="Remover" variant="ghost" onPress={async () => { await saveShoppingList(removeItem(list, editing.id, now())); setEditing(null); }} /><Button title="Cancelar" variant="ghost" onPress={() => setEditing(null)} /></View>
          </View>
        </View>
      ) : null}
      <ConfirmSheet visible={confirmDelete} title="Excluir lista?" text="Os itens serão perdidos. Compras já finalizadas continuam no histórico." confirmLabel="Excluir" onConfirm={async () => { setConfirmDelete(false); await deleteShoppingList(list.id); router.back(); }} onCancel={() => setConfirmDelete(false)} />
    </View>
  );
}
