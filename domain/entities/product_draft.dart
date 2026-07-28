/// Borrador del formulario de "Agregar producto" sin enviar todavía.
/// Se guarda localmente para que el vendedor no pierda lo que escribió si
/// cambia de pestaña, sale de la app, o el sistema la cierra en segundo plano.
class ProductDraft {
  final String name;
  final String description;
  final String brand;
  final String price;
  final String quantity;
  final String category;
  final String imageUrl;

  const ProductDraft({
    this.name = '',
    this.description = '',
    this.brand = '',
    this.price = '',
    this.quantity = '',
    this.category = '',
    this.imageUrl = '',
  });

  /// True si no hay absolutamente nada que valga la pena restaurar.
  bool get isEmpty =>
      name.isEmpty &&
      description.isEmpty &&
      brand.isEmpty &&
      price.isEmpty &&
      quantity.isEmpty &&
      imageUrl.isEmpty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'brand': brand,
        'price': price,
        'quantity': quantity,
        'category': category,
        'imageUrl': imageUrl,
      };

  factory ProductDraft.fromJson(Map<String, dynamic> json) => ProductDraft(
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        brand: json['brand'] ?? '',
        price: json['price'] ?? '',
        quantity: json['quantity'] ?? '',
        category: json['category'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
      );
}
