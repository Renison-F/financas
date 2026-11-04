import React, { useState } from 'react';
import { View } from 'react-native';
import { Screen, Card, CardHeader, Text, Button, Input, ListRow, Chip, spacing } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';
import { Segmented, ChipSelect } from '../features/shared/FormBits';

export default function CategoriesScreen() {
  const { ledger, saveCategory, saveTag } = useAppStore();
  const [kind, setKind] = useState<'expense' | 'income'>('expense');
  const [name, setName] = useState('');
  const [parentId, setParentId] = useState<string | undefined>();
  const [tag, setTag] = useState('');
  const cats = ledger.categories.filter((c) => c.kind === kind && !c.deletedAt);
  const roots = cats.filter((c) => !c.parentId);
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Categorias e tags" />
      <Screen>
        <Segmented options={[{ value: 'expense', label: 'Despesas' }, { value: 'income', label: 'Receitas' }]} value={kind} onChange={(v) => { setKind(v); setParentId(undefined); }} />
        <Card style={{ marginTop: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Nova categoria" />
          <Input label="Nome" value={name} onChangeText={setName} placeholder="Ex.: Delivery" />
          <Text role="label" color="textMuted">Subcategoria de (opcional)</Text>
          <ChipSelect options={roots.map((c) => ({ value: c.id, label: c.name }))} value={parentId} onChange={setParentId} allowNone />
          <Button title="Adicionar" disabled={!name.trim()} onPress={async () => { await saveCategory({ name: name.trim(), kind, parentId }); setName(''); setParentId(undefined); }} />
        </Card>
        <Card style={{ marginTop: spacing.sm }}>
          <CardHeader title={kind === 'expense' ? 'Categorias de despesa' : 'Categorias de receita'} />
          {roots.map((c) => <View key={c.id}><ListRow icon="tag" iconColor={c.color} title={c.name} description={c.archived ? 'arquivada' : undefined} right={<Button title={c.archived ? 'Reativar' : 'Arquivar'} variant="ghost" compact onPress={() => void saveCategory({ id: c.id, name: c.name, kind: c.kind, archived: !c.archived })} />} />{cats.filter((s) => s.parentId === c.id).map((s) => <ListRow key={s.id} title={`↳ ${s.name}`} right={<Button title={s.archived ? 'Reativar' : 'Arquivar'} variant="ghost" compact onPress={() => void saveCategory({ id: s.id, name: s.name, kind: s.kind, archived: !s.archived })} />} />)}</View>)}
        </Card>
        <Card style={{ marginTop: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Tags" />
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>{ledger.tags.map((t) => <Chip key={t.id} label={t.name} />)}{!ledger.tags.length ? <Text role="bodySmall" color="textMuted">Tags marcam lançamentos de forma transversal (ex.: viagem, reembolsável).</Text> : null}</View>
          <View style={{ flexDirection: 'row', gap: 8, alignItems: 'flex-end' }}><View style={{ flex: 1 }}><Input label="Nova tag" value={tag} onChangeText={setTag} placeholder="Ex.: viagem" /></View><Button title="Adicionar" disabled={!tag.trim()} onPress={async () => { await saveTag({ name: tag.trim() }); setTag(''); }} /></View>
        </Card>
      </Screen>
    </View>
  );
}
