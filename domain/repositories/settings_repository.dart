import '../entities/app_settings.dart';

/// Puerto para preferencias locales del vendedor (tema, idioma). Listo para
/// cuando armes la pantalla de "Configuración" — solo tienes que llamar
/// estos métodos, sin preocuparte de si se guardan en SharedPreferences,
/// un archivo, o cualquier otro mecanismo local.
abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveThemeMode(AppThemeMode themeMode);
  Future<void> saveLanguageCode(String languageCode);
}
