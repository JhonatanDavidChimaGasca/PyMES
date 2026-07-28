import '../entities/product_draft.dart';

/// Puerto para el borrador del formulario de "Agregar producto". Cada
/// vendedor tiene su propio borrador (se guarda con su uid como parte de
/// la llave), para no mezclar borradores si cambian de cuenta en el mismo
/// dispositivo.
abstract class ProductDraftRepository {
  Future<ProductDraft?> getDraft(String userId);
  Future<void> saveDraft(String userId, ProductDraft draft);
  Future<void> clearDraft(String userId);
}
