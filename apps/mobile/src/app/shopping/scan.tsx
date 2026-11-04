import React, { useRef, useState } from 'react';
import { View, Pressable, ActivityIndicator } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { CameraView, useCameraPermissions, type BarcodeScanningResult } from 'expo-camera';
import * as Haptics from 'expo-haptics';
import { parsePriceTag, parseBarcode, parseNFCeQR } from '@financas/shopping';
import { Text, Button, Icon, useColors, spacing, radius, touch } from '../../design';
import { useScanStore } from '../../features/shopping/scanStore';
import { recognizeText, OCRUnavailableError } from '../../services/ocr';
import { Segmented } from '../../features/shared/FormBits';

type Mode = 'label' | 'barcode';

/**
 * Camera screen: "Etiqueta" captures a photo and runs on-device OCR; "Código" scans EAN/UPC/QR live.
 * Handles permission denied, camera unavailable, torch, manual capture, retry. Nothing is added to the cart here:
 * the result goes back to the session screen for confirmation.
 */
export default function ScanScreen() {
  const { mode: initialMode } = useLocalSearchParams<{ mode?: Mode }>();
  const router = useRouter();
  const c = useColors();
  const insets = useSafeAreaInsets();
  const setResult = useScanStore((s) => s.set);
  const [permission, requestPermission] = useCameraPermissions();
  const [mode, setMode] = useState<Mode>(initialMode === 'barcode' ? 'barcode' : 'label');
  const [torch, setTorch] = useState(false);
  const [busy, setBusy] = useState(false);
  const [status, setStatus] = useState<string>('');
  const [cameraError, setCameraError] = useState<string | null>(null);
  const camRef = useRef<CameraView>(null);
  const lastCode = useRef<{ data: string; at: number } | null>(null);

  const finish = (r: Parameters<typeof setResult>[0]) => { setResult(r); void Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {}); router.back(); };

  const onBarcode = (res: BarcodeScanningResult) => {
    if (mode !== 'barcode' || busy) return;
    const now = Date.now();
    if (lastCode.current && lastCode.current.data === res.data && now - lastCode.current.at < 2500) return;
    lastCode.current = { data: res.data, at: now };
    if (res.type === 'qr') { const nf = parseNFCeQR(res.data); if (nf) { finish({ kind: 'nfce', nfceKey: nf.accessKey, at: now }); return; } setStatus('QR lido, mas não é um cupom fiscal (NFC-e).'); return; }
    const parsed = parseBarcode(res.data);
    if (!parsed.valid) { setStatus('Código inválido; tente de novo.'); return; }
    finish({ kind: 'barcode', barcode: parsed, at: now });
  };

  const capture = async () => {
    if (!camRef.current || busy) return;
    setBusy(true); setStatus('Lendo a etiqueta…');
    try {
      const photo = await camRef.current.takePictureAsync({ quality: 0.8, skipProcessing: true });
      if (!photo?.uri) throw new Error('Não foi possível capturar a foto.');
      const lines = await recognizeText(photo.uri);
      const reading = parsePriceTag(lines);
      finish({ kind: 'label', reading, at: Date.now() });
    } catch (e) {
      if (e instanceof OCRUnavailableError) { setStatus(e.message); setResult({ kind: 'label', reading: undefined, at: Date.now() }); setTimeout(() => router.back(), 1200); }
      else setStatus(e instanceof Error ? e.message : 'Falha na leitura. Tente de novo.');
    } finally { setBusy(false); }
  };

  if (!permission) return <View style={{ flex: 1, backgroundColor: c.bg }} />;
  if (!permission.granted) {
    return (
      <View style={{ flex: 1, backgroundColor: c.bg, padding: spacing.lg, paddingTop: insets.top + spacing.lg, gap: spacing.md }}>
        <Text role="headline">Câmera</Text>
        <Text role="body" color="textMuted">Para ler etiquetas de preço e códigos de barras, o SerenaCash precisa da câmera. As imagens não são guardadas nem enviadas.</Text>
        <Button title={permission.canAskAgain ? 'Permitir câmera' : 'Abrir configurações'} onPress={() => (permission.canAskAgain ? void requestPermission() : void import('expo-linking').then((L) => L.openSettings()))} fullWidth />
        <Button title="Informar manualmente" variant="secondary" onPress={() => { setResult({ kind: 'label', reading: undefined, at: Date.now() }); router.back(); }} fullWidth />
        <Button title="Voltar" variant="ghost" onPress={() => router.back()} fullWidth />
      </View>
    );
  }
  return (
    <View style={{ flex: 1, backgroundColor: '#000' }}>
      {cameraError ? <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: spacing.lg, gap: spacing.md }}><Text role="title" color="bg">Câmera indisponível</Text><Text role="bodySmall" color="bg" align="center">{cameraError}</Text><Button title="Informar manualmente" onPress={() => { setResult({ kind: 'label', reading: undefined, at: Date.now() }); router.back(); }} /></View> : (
        <CameraView ref={camRef} style={{ flex: 1 }} facing="back" enableTorch={torch} onMountError={(e) => setCameraError(e.message)}
          barcodeScannerSettings={{ barcodeTypes: ['ean13', 'ean8', 'upc_a', 'upc_e', 'code128', 'qr'] }} onBarcodeScanned={mode === 'barcode' ? onBarcode : undefined} />
      )}
      {/* framing guide */}
      <View pointerEvents="none" style={{ position: 'absolute', left: 0, right: 0, top: 0, bottom: 0, alignItems: 'center', justifyContent: 'center' }}>
        <View style={{ width: mode === 'label' ? 300 : 260, height: mode === 'label' ? 180 : 120, borderWidth: 2, borderColor: c.accent, borderRadius: radius.md, backgroundColor: 'transparent' }} />
        <Text role="label" color="bg" align="center" style={{ marginTop: 12, textShadowColor: '#000', textShadowRadius: 4 }}>{mode === 'label' ? 'Enquadre a etiqueta inteira, sem reflexo, e toque em Ler' : 'Aponte para o código de barras ou QR do cupom'}</Text>
      </View>
      <View style={{ position: 'absolute', top: insets.top + 8, left: spacing.md, right: spacing.md, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
        <Pressable accessibilityRole="button" accessibilityLabel="Fechar câmera" onPress={() => router.back()} style={{ width: touch.min, height: touch.min, borderRadius: 22, backgroundColor: 'rgba(0,0,0,0.5)', alignItems: 'center', justifyContent: 'center' }}><Icon name="close" color="#fff" /></Pressable>
        <View style={{ flex: 1, marginHorizontal: spacing.sm }}><Segmented options={[{ value: 'label', label: 'Etiqueta' }, { value: 'barcode', label: 'Código' }]} value={mode} onChange={(m) => { setMode(m); setStatus(''); }} /></View>
        <Pressable accessibilityRole="button" accessibilityLabel={torch ? 'Desligar lanterna' : 'Ligar lanterna'} onPress={() => setTorch(!torch)} style={{ width: touch.min, height: touch.min, borderRadius: 22, backgroundColor: 'rgba(0,0,0,0.5)', alignItems: 'center', justifyContent: 'center' }}><Icon name={torch ? 'flash-off' : 'flash'} color="#fff" /></Pressable>
      </View>
      <View style={{ position: 'absolute', bottom: insets.bottom + spacing.lg, left: spacing.md, right: spacing.md, alignItems: 'center', gap: spacing.sm }}>
        {status ? <View accessibilityLiveRegion="polite" style={{ backgroundColor: 'rgba(0,0,0,0.6)', paddingHorizontal: 12, paddingVertical: 8, borderRadius: radius.sm }}><Text role="bodySmall" color="bg" align="center">{status}</Text></View> : null}
        {mode === 'label' ? (
          <Pressable accessibilityRole="button" accessibilityLabel="Ler etiqueta" onPress={() => void capture()} disabled={busy} style={{ width: 76, height: 76, borderRadius: 38, backgroundColor: c.accent, alignItems: 'center', justifyContent: 'center', borderWidth: 4, borderColor: '#fff' }}>{busy ? <ActivityIndicator color="#fff" /> : <Icon name="camera" color="#fff" size={30} />}</Pressable>
        ) : <View style={{ flexDirection: 'row', gap: 8 }}><Icon name="barcode" color="#fff" /><Text role="bodySmall" color="bg">Lendo automaticamente…</Text></View>}
        <Button title="Informar manualmente" variant="ghost" onPress={() => { setResult({ kind: 'label', reading: undefined, at: Date.now() }); router.back(); }} />
      </View>
    </View>
  );
}
