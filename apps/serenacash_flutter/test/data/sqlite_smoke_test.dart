import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('sqlite3 native opens in-memory db', () {
    final db = sqlite3.openInMemory();
    db.execute(
      'CREATE TABLE t (id INTEGER PRIMARY KEY, v TEXT NOT NULL) STRICT',
    );
    db.execute('INSERT INTO t (v) VALUES (?)', ['x']);
    final r = db.select(
      'SELECT sqlite_version() AS v, (SELECT count(*) FROM t) AS n',
    );
    // ignore: avoid_print
    print('sqlite ${r.first['v']} rows=${r.first['n']}');
    final cipher = db.select("PRAGMA cipher_version");
    // ignore: avoid_print
    print(
      'cipher_version rows=${cipher.length} ${cipher.isEmpty ? '' : cipher.first.values}',
    );
    expect(r.first['n'], 1);
    db.close();
  });
}
