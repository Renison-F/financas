import { Platform } from 'react-native';
import * as DocumentPicker from 'expo-document-picker';
import * as Sharing from 'expo-sharing';
import * as Print from 'expo-print';
import { File, Paths } from 'expo-file-system';

/** Picks a text file (CSV/OFX/JSON) and returns its contents. */
export async function pickTextFile(): Promise<{ name: string; text: string } | null> {
  const res = await DocumentPicker.getDocumentAsync({ type: ['text/csv', 'text/comma-separated-values', 'application/json', 'application/x-ofx', 'text/plain', '*/*'], copyToCacheDirectory: true, multiple: false });
  if (res.canceled || !res.assets[0]) return null;
  const asset = res.assets[0];
  if (Platform.OS === 'web') { const r = await fetch(asset.uri); return { name: asset.name, text: await r.text() }; }
  const file = new File(asset.uri);
  return { name: asset.name, text: await file.text() };
}

/** Writes text to the cache dir and opens the share sheet (Files, e-mail, Drive...). */
export async function shareText(fileName: string, text: string, mimeType: string): Promise<void> {
  if (Platform.OS === 'web') {
    const blob = new Blob([text], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a'); a.href = url; a.download = fileName; a.click(); setTimeout(() => URL.revokeObjectURL(url), 1000);
    return;
  }
  const file = new File(Paths.cache, fileName);
  if (file.exists) file.delete();
  file.create();
  file.write(text);
  if (await Sharing.isAvailableAsync()) await Sharing.shareAsync(file.uri, { mimeType, dialogTitle: fileName });
}

/** Renders HTML to PDF and shares it. */
export async function sharePDF(fileName: string, html: string): Promise<void> {
  if (Platform.OS === 'web') { await Print.printAsync({ html }); return; }
  const { uri } = await Print.printToFileAsync({ html });
  if (await Sharing.isAvailableAsync()) await Sharing.shareAsync(uri, { mimeType: 'application/pdf', dialogTitle: fileName, UTI: 'com.adobe.pdf' });
}
