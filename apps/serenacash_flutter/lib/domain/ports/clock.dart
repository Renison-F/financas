/// Time and identity sources injected into repositories so tests stay deterministic.
library;

import 'package:uuid/uuid.dart';

abstract interface class Clock {
  /// UTC ISO-8601 instant, e.g. `2026-11-04T10:00:00.000Z`.
  String nowISO();
}

class SystemClock implements Clock {
  const SystemClock();
  @override
  String nowISO() => DateTime.now().toUtc().toIso8601String();
}

class FixedClock implements Clock {
  FixedClock(this.value);
  String value;
  @override
  String nowISO() => value;
}

abstract interface class IdGenerator {
  String newId();
}

class UuidV4IdGenerator implements IdGenerator {
  const UuidV4IdGenerator();
  static const _uuid = Uuid();
  @override
  String newId() => _uuid.v4();
}

class SequentialIdGenerator implements IdGenerator {
  SequentialIdGenerator([this.prefix = 'id']);
  final String prefix;
  int _n = 0;
  @override
  String newId() => '$prefix${++_n}';
}
