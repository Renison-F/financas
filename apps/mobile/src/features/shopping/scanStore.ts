import { create } from 'zustand';
import type { PriceTagReading, ParsedBarcode } from '@financas/shopping';

/** Hands a scan result from the camera screen back to the session screen (navigation params cannot carry objects safely). */
export interface ScanResult { kind: 'label' | 'barcode' | 'nfce'; reading?: PriceTagReading | undefined; barcode?: ParsedBarcode | undefined; nfceKey?: string | undefined; at: number; }
export const useScanStore = create<{ result: ScanResult | null; set: (r: ScanResult | null) => void }>((set) => ({ result: null, set: (result) => set({ result }) }));
