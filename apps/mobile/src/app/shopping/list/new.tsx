import React, { useState } from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { withinLimit } from '@financas/core';
import type { ShoppingList } from '@financas/shopping';
import { Screen, Button, MoneyInput, Input, Text, spacing } from '../../../design';
import { useAppStore } from '../../../state/appStore';
import { StackHeader } from '../../../features/shared/ScreenHeader';
import { newId } from '../../../state/ids';

export default function NewList() {
  const router = useRouter();
  const { saveShoppingList, shoppingLists, access } = useAppStore();
  const [name, setName] = useState('');
  const [store, setStore] = useState('');
  const [budget, setBudget] = useState<number | null>(null);
  const lim = withinLimit(access, 'shoppingLists', shoppingLists.filter((l) => !l.archived).length);
  const save = async () => {
    if (!lim.ok) return router.push('/paywall?feature=unlimited_accounts');
    const now = new Date().toISOString();
    const list: ShoppingList = { id: newId(), name: name.trim() || 'Compra do mês', store: store.trim() || undefined, budgetCents: budget ?? undefined, items: [], archived: false, createdAt: now, updatedAt: now };
    await saveShoppingList(list);
    router.replace(`/shopping/list/${list.id}`);
  };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Nova lista" right={<Button title="Criar" variant="ghost" onPress={() => void save()} />} />
      <Screen>
        <View style={{ gap: spacing.md }}>
          <Input label="Nome" value={name} onChangeText={setName} placeholder="Ex.: Compra do mês" autoFocus />
          <Input label="Supermercado (opcional)" value={store} onChangeText={setStore} placeholder="Ex.: Mercado Bom" />
          <MoneyInput label="Orçamento para esta compra (opcional)" valueCents={budget} onChangeCents={setBudget} help="No mercado, o carrinho mostra quanto ainda cabe." />
          {!lim.ok ? <Text role="bodySmall" color="warning">Plano gratuito: até {lim.limit} listas.</Text> : null}
        </View>
      </Screen>
    </View>
  );
}
