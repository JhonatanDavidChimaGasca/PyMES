import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';

class FirestoreProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _auth;

  /// Depende del PUERTO AuthRepository, no de FirebaseAuth directamente —
  /// así este adaptador no necesita saber cómo se resuelve el usuario actual.
  FirestoreProductRepository(this._auth);

  Product _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _toMap(Product product) => {
        'name': product.name,
        'category': product.category,
        'description': product.description,
        'brand': product.brand,
        'price': product.price,
        'quantity': product.quantity,
        'imageUrl': product.imageUrl,
        'userId': product.userId,
        'createdAt': Timestamp.fromDate(product.createdAt),
      };

  @override
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .where('userId', isEqualTo: _auth.currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) return Stream.value([]);

    return _firestore
        .collection('products')
        .where('userId', isEqualTo: _auth.currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(_fromDoc)
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.category.toLowerCase().contains(query.toLowerCase()) ||
                product.brand.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  @override
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(_toMap(product));
  }
}
