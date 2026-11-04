// Platform resolution: Metro picks sqliteDatabase.native.ts (expo-sqlite) or sqliteDatabase.web.ts (memory).
// This file exists only for TypeScript's benefit; it re-exports the native implementation's types.
export { SQLiteDatabase } from './sqliteDatabase.native';
