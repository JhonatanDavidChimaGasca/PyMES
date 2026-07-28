import '../entities/app_user.dart';

/// Excepción de dominio: mensaje legible para mostrar en la UI, sin filtrar
/// detalles de Firebase (códigos internos, stack traces, etc.) hacia arriba.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  /// Id del vendedor autenticado actualmente. Lanza [StateError] si no hay
  /// sesión activa — los repositorios de datos (products/promos) lo usan
  /// para filtrar "solo lo mío", igual que antes.
  String get currentUserId;

  Future<AppUser?> registerWithEmail(String email, String password);
  Future<AppUser?> signInWithEmail(String email, String password);
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();
}
