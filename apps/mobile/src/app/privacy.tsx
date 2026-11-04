import React, { useState } from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { Screen, Card, CardHeader, Text, Button, spacing } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';
import { ConfirmSheet } from '../features/shared/FormBits';

/** LGPD: what is collected (nothing leaves the device), export and full erasure. */
export default function PrivacyScreen() {
  const router = useRouter();
  const erase = useAppStore((s) => s.eraseEverything);
  const [confirm, setConfirm] = useState(false);
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Privacidade e dados" />
      <Screen>
        <Card style={{ marginBottom: spacing.sm, gap: 6 }}>
          <CardHeader title="O que guardamos" />
          <Text role="body">Contas, lançamentos, cartões, orçamentos, metas, empréstimos, listas e compras: tudo fica neste aparelho, em um banco de dados local.</Text>
          <Text role="body">Não pedimos e-mail, CPF nem senha de banco. Não há conexão bancária. Nenhum dado financeiro é enviado a servidores.</Text>
          <Text role="body">Assinaturas são processadas pela Apple ou pelo Google; recebemos apenas a confirmação do direito de acesso, nunca dados de pagamento.</Text>
          <Text role="body">A câmera é usada só para ler etiquetas e códigos durante a compra; as imagens não são guardadas.</Text>
        </Card>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Seus direitos" />
          <Button title="Exportar todos os meus dados" variant="secondary" icon="download" onPress={() => router.push('/export')} fullWidth />
          <Button title="Apagar tudo deste aparelho" variant="destructive" icon="trash" onPress={() => setConfirm(true)} fullWidth />
          <Text role="caption" color="textMuted">Apagar remove dados, preferências e cache de assinatura. Compras na loja podem ser restauradas depois.</Text>
        </Card>
        <Text role="caption" color="textMuted">Política de privacidade completa e termos: serão publicados em serenacash.app/privacidade antes do lançamento nas lojas.</Text>
      </Screen>
      <ConfirmSheet visible={confirm} title="Apagar tudo?" text="Esta ação não pode ser desfeita. Exporte um backup antes, se quiser guardar o histórico." confirmLabel="Apagar definitivamente" onConfirm={async () => { setConfirm(false); await erase(); router.replace('/onboarding'); }} onCancel={() => setConfirm(false)} />
    </View>
  );
}
