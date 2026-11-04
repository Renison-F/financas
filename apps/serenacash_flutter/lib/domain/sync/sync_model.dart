/// Offline-first synchronization model: change records, conflicts and the field-level merge policy.
/// Transport and server are not chosen (ADR-07); this is the contract future adapters implement.
library;

class ChangeRecord {
  const ChangeRecord({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.op,
    this.payload,
    required this.version,
    required this.deviceId,
    required this.at,
    required this.synced,
  });
  final String id;
  final String entityType;
  final String entityId;
  final String op; // upsert | delete
  final Map<String, dynamic>? payload;
  final int version;
  final String deviceId;
  final String at;
  final bool synced;
}

class Conflict {
  const Conflict({
    required this.entityType,
    required this.entityId,
    required this.local,
    required this.remote,
    required this.fields,
    required this.detectedAt,
  });
  final String entityType;
  final String entityId;
  final Map<String, dynamic> local;
  final Map<String, dynamic> remote;
  final List<String> fields;
  final String detectedAt;
  Map<String, dynamic> toJson() => {
    'entityType': entityType,
    'entityId': entityId,
    'local': local,
    'remote': remote,
    'fields': fields,
    'detectedAt': detectedAt,
  };
}

/// Port for a future transport (Firestore, REST over PostgreSQL…). No implementation ships in v1.
abstract interface class SyncTransport {
  Future<({List<String> accepted, List<({String id, String reason})> rejected})>
  push(List<ChangeRecord> changes);
  Future<({List<ChangeRecord> changes, String cursor})> pull(
    String? sinceCursor,
  );
}

const monetaryFields = {
  'amountCents',
  'paidCents',
  'openingBalanceCents',
  'limitCents',
  'targetCents',
  'principalCents',
};

bool _deepEq(Object? a, Object? b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !_deepEq(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEq(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

/// Last-writer-wins per field by `updatedAt`, EXCEPT monetary fields and status, which produce a Conflict
/// when both sides changed them differently since the common base (local value kept until the user decides).
({Map<String, dynamic> merged, Conflict? conflict}) mergeEntity(
  Map<String, dynamic>? base,
  Map<String, dynamic> local,
  Map<String, dynamic> remote,
  String entityType,
  String entityId,
  String now,
) {
  final merged = <String, dynamic>{...remote, ...local};
  final conflictFields = <String>[];
  for (final k in {...local.keys, ...remote.keys}) {
    final lv = local[k], rv = remote[k], bv = base?[k];
    if (_deepEq(lv, rv)) {
      merged[k] = lv;
      continue;
    }
    final localChanged = !_deepEq(lv, bv);
    final remoteChanged = !_deepEq(rv, bv);
    if (localChanged && !remoteChanged) {
      merged[k] = lv;
    } else if (!localChanged && remoteChanged) {
      merged[k] = rv;
    } else if (monetaryFields.contains(k) || k == 'status') {
      conflictFields.add(k);
      merged[k] = lv;
    } else {
      merged[k] =
          (local['updatedAt']?.toString() ?? '').compareTo(
                remote['updatedAt']?.toString() ?? '',
              ) >=
              0
          ? lv
          : rv;
    }
  }
  return (
    merged: merged,
    conflict: conflictFields.isEmpty
        ? null
        : Conflict(
            entityType: entityType,
            entityId: entityId,
            local: local,
            remote: remote,
            fields: conflictFields,
            detectedAt: now,
          ),
  );
}
