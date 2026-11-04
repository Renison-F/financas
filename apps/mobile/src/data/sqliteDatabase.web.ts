import { MemoryDatabase } from './memoryDatabase';
/** Web preview has no SQLite: data lives in memory for the session. Real persistence is native-only (expo-sqlite). */
export class SQLiteDatabase extends MemoryDatabase {
  static async open(_name = 'serenacash.db'): Promise<SQLiteDatabase> { return new SQLiteDatabase(); }
}
