import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/domain/dashboard/widgets.dart' as dash;

abstract final class KvCompanionFactory {
  static KvCompanion onboarded() => const KvCompanion(
    key: Value('onboarded'),
    json: Value('true'),
    updatedAt: Value('2026-11-04T00:00:00Z'),
  );
  static KvCompanion completeLayout() => KvCompanion(
    key: const Value('dashboard_layout'),
    json: Value(
      jsonEncode(dash.applyPreset(dash.defaultLayout, 'complete').toJson()),
    ),
    updatedAt: const Value('2026-11-04T00:00:00Z'),
  );
}
