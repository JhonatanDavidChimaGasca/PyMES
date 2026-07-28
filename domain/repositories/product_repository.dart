import '../entities/product.dart';

/// Puerto: define QUÉ se puede hacer con productos, sin decir CÓMO.
/// Las pantallas dependen de esta interfaz, nunca de Firestore directamente.
abstract class ProductRepository {
  Stream<List<Product>> getProducts();
  Stream<List<Product>> searchProducts(String query);
  Future<void> addProduct(Product product);
}
