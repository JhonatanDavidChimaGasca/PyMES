/// Representa al vendedor autenticado, sin exponer el tipo `User` de
/// firebase_auth al resto de la app. Así, si el día de mañana cambias el
/// proveedor de autenticación, solo tocas el adaptador — nunca las pantallas.
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}
