import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/promo_code.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/promo_code_repository.dart';

class FirestorePromoCodeRepository implements PromoCodeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _auth;

  FirestorePromoCodeRepository(this._auth);

  PromoCode _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromoCode(
      id: doc.id,
      code: data['code'] ?? '',
      status: data['status'] ?? 'Habilitado',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      discount: (data['discount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> _toMap(PromoCode promoCode) => {
        'code': promoCode.code,
        'status': promoCode.status,
        'startDate': Timestamp.fromDate(promoCode.startDate),
        'endDate': Timestamp.fromDate(promoCode.endDate),
        'userId': promoCode.userId,
        'discount': promoCode.discount,
      };

  @override
  Stream<List<PromoCode>> getPromoCodes() {
    return _firestore
        .collection('promo_codes')
        .where('userId', isEqualTo: _auth.currentUserId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> addPromoCode(PromoCode promoCode) async {
    await _firestore.collection('promo_codes').add(_toMap(promoCode));
  }

  @override
  Future<PromoCode?> validatePromoCode(String code) async {
    try {
      final snapshot = await _firestore
          .collection('promo_codes')
          .where('userId', isEqualTo: _auth.currentUserId)
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final promoCode = _fromDoc(snapshot.docs.first);
        if (promoCode.getStatus() == 'Habilitado') {
          return promoCode;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
