/// Who may read/write a record. v1: one local user owns everything.
library;

abstract interface class FamilySharePolicy {
  bool canRead(String userId, String entityType, String entityId);
  bool canWrite(String userId, String entityType, String entityId);
}

class SingleUserPolicy implements FamilySharePolicy {
  const SingleUserPolicy();
  @override
  bool canRead(String userId, String entityType, String entityId) => true;
  @override
  bool canWrite(String userId, String entityType, String entityId) => true;
}
