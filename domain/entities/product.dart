/// Entidad de dominio pura. No sabe nada de Firestore, HTTP, ni de cómo
/// se guarda o se lee — eso es responsabilidad de los adaptadores en `data/`.
class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final String brand;
  final double price;
  final int quantity;
  final String imageUrl;
  final String userId;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.brand,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.userId,
    required this.createdAt,
  });
}
