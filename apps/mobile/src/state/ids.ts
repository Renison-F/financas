import * as Crypto from 'expo-crypto';
export function newId(): string {
  try { return Crypto.randomUUID(); } catch { return 'id-' + Date.now().toString(36) + '-' + Math.random().toString(36).slice(2, 10); }
}
