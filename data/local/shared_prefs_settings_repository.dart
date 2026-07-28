import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const _keyThemeMode = 'settings.themeMode';
  static const _keyLanguageCode = 'settings.languageCode';

  @override
  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_keyThemeMode);
    final languageCode = prefs.getString(_keyLanguageCode) ?? 'es';

    final themeMode = AppThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => AppThemeMode.system,
    );

    return AppSettings(themeMode: themeMode, languageCode: languageCode);
  }

  @override
  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, themeMode.name);
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, languageCode);
  }
}
