import '../entities/promo_code.dart';

abstract class PromoCodeRepository {
  Stream<List<PromoCode>> getPromoCodes();
  Future<void> addPromoCode(PromoCode promoCode);
  Future<PromoCode?> validatePromoCode(String code);
}
