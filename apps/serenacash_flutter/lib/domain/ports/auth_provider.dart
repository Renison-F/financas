/// Identity port. v1 ships [AnonymousLocalAuth]: one local user, no account. Future providers
/// (Firebase Auth or another IdP) implement the same interface without touching business rules.
library;

class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.anonymous = true,
  });
  final String id;
  final String? email;
  final String? displayName;
  final bool anonymous;
}

abstract interface class AuthProvider {
  Future<AuthUser?> currentUser();
  Stream<AuthUser?> watchUser();
  Future<void> signOut();
}

class AnonymousLocalAuth implements AuthProvider {
  AnonymousLocalAuth(this.localUserId);
  final String localUserId;
  @override
  Future<AuthUser?> currentUser() async => AuthUser(id: localUserId);
  @override
  Stream<AuthUser?> watchUser() => Stream.value(AuthUser(id: localUserId));
  @override
  Future<void> signOut() async {}
}
