import 'dart:convert';
import 'dart:io';

/// Loads the JSON fixtures generated from the TypeScript domain (docs/flutter-migration/fixtures).
/// Every case has `name`, `input`, `expected` and an optional `note`.
class FixtureCase {
  FixtureCase(this.name, this.input, this.expected, this.note);
  final String name;
  final dynamic input;
  final dynamic expected;
  final String note;
  Map<String, dynamic> get inputMap => input as Map<String, dynamic>;
}

List<FixtureCase> loadFixtures(String name) {
  final candidates = [
    '../../docs/flutter-migration/fixtures/$name.json',
    'docs/flutter-migration/fixtures/$name.json',
    'assets/fixtures/$name.json',
  ];
  for (final c in candidates) {
    final f = File(c);
    if (f.existsSync()) {
      final json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return (json['cases'] as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return FixtureCase(
          m['name'] as String,
          m['input'],
          m['expected'],
          (m['note'] as String?) ?? '',
        );
      }).toList();
    }
  }
  throw StateError('Fixture $name.json not found');
}

/// Deep equality that treats `undefined`-dropped keys, nulls and int/double 1.0 == 1 the way JSON does.
bool jsonEquals(dynamic a, dynamic b) {
  if (a is num && b is num) return a == b;
  if (a is Map && b is Map) {
    final keys = {...a.keys, ...b.keys};
    for (final k in keys) {
      if (!jsonEquals(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!jsonEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}
