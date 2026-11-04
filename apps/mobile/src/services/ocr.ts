import { Platform } from 'react-native';
import type { OCRLine } from '@financas/shopping';

export class OCRUnavailableError extends Error { constructor() { super('Leitura de texto indisponível neste aparelho/versão. Informe o preço manualmente.'); } }

/**
 * On-device OCR for a captured photo. Uses Google ML Kit text recognition (Latin script) through
 * @react-native-ml-kit/text-recognition, loaded lazily: it only works in a development/production build,
 * never in Expo Go or on the web, where the caller falls back to manual entry. Images never leave the device.
 */
export async function recognizeText(imageUri: string): Promise<OCRLine[]> {
  if (Platform.OS === 'web') throw new OCRUnavailableError();
  let mod: typeof import('@react-native-ml-kit/text-recognition');
  try { mod = await import('@react-native-ml-kit/text-recognition'); } catch { throw new OCRUnavailableError(); }
  try {
    const result = await mod.default.recognize(imageUri);
    const lines: OCRLine[] = [];
    for (const block of result.blocks) for (const line of block.lines) {
      const h = line.frame ? line.frame.height : undefined;
      lines.push({ text: line.text, height: h, y: line.frame?.top, confidence: undefined });
    }
    return lines;
  } catch (e) {
    if (e instanceof Error && /not linked|null|undefined is not an object|Cannot read/i.test(e.message)) throw new OCRUnavailableError();
    throw e;
  }
}
