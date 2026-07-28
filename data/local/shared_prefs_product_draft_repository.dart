import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/product_draft.dart';
import '../../domain/repositories/product_draft_repository.dart';

class SharedPrefsProductDraftRepository implements ProductDraftRepository {
  String _keyFor(String userId) => 'productDraft.$userId';

  @override
  Future<ProductDraft?> getDraft(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(userId));
    if (raw == null) return null;
    try {
      return ProductDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Si el JSON guardado quedó corrupto por cualquier razón, mejor
      // ignorarlo que romper la pantalla de "Agregar producto".
      return null;
    }
  }

  @override
  Future<void> saveDraft(String userId, ProductDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    if (draft.isEmpty) {
      await prefs.remove(_keyFor(userId));
      return;
    }
    await prefs.setString(_keyFor(userId), jsonEncode(draft.toJson()));
  }

  @override
  Future<void> clearDraft(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(userId));
  }
}
