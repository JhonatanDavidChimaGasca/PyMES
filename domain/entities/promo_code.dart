/// Entidad de dominio pura. No sabe nada de Firestore.
class PromoCode {
  final String id;
  final String code;
  final String status; // 'Habilitado', 'Deshabilitado', 'Expirado'
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final double discount;

  const PromoCode({
    required this.id,
    required this.code,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.userId,
    required this.discount,
  });

  /// Regla de negocio: el estado real depende de la fecha actual, no solo
  /// del campo guardado. Esto vive en la entidad porque es lógica de
  /// dominio pura (no depende de ninguna fuente de datos).
  String getStatus() {
    final now = DateTime.now();
    if (now.isAfter(endDate)) {
      return 'Expirado';
    } else if (status == 'Deshabilitado') {
      return 'Deshabilitado';
    } else {
      return 'Habilitado';
    }
  }
}
