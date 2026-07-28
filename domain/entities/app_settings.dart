enum AppThemeMode { light, dark, system }

/// Preferencias del vendedor que se guardan localmente en el dispositivo
/// (no tienen nada que ver con el negocio en sí, por eso no van a Firestore).
class AppSettings {
  final AppThemeMode themeMode;
  final String languageCode; // ej: 'es', 'en'

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.languageCode = 'es',
  });

  AppSettings copyWith({AppThemeMode? themeMode, String? languageCode}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
