// preferences/app_preferences.dart
//
// Idioma y apariencia elegidos por la persona. Se guardan solo en el
// dispositivo (no viajan a la API) y se aplican al instante.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/active_locale.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences._(this._prefs, this._themeMode, this._locale) {
    ActiveLocale.choose(_locale);
  }

  static const supportedLocales = [Locale('es'), Locale('en'), Locale('pt')];
  static const _themeKey = 'pref.themeMode';
  static const _localeKey = 'pref.locale';

  final SharedPreferences? _prefs;
  ThemeMode _themeMode;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;

  /// null = seguir el idioma del sistema (si no es compatible, español).
  Locale? get locale => _locale;

  /// Si el almacenamiento falla la app sigue con los valores por defecto.
  static Future<AppPreferences> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = ThemeMode.values.where(
        (m) => m.name == prefs.getString(_themeKey),
      );
      final code = prefs.getString(_localeKey);
      final locale = supportedLocales.where((l) => l.languageCode == code);
      return AppPreferences._(
        prefs,
        theme.isEmpty ? ThemeMode.system : theme.first,
        locale.isEmpty ? null : locale.first,
      );
    } catch (_) {
      return AppPreferences._(null, ThemeMode.system, null);
    }
  }

  /// Constructor para pruebas, sin almacenamiento.
  AppPreferences.memory({
    ThemeMode themeMode = ThemeMode.system,
    Locale? locale,
  }) : this._(null, themeMode, locale);

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs?.setString(_themeKey, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale?.languageCode == _locale?.languageCode) return;
    _locale = locale;
    ActiveLocale.choose(locale);
    notifyListeners();
    if (locale == null) {
      await _prefs?.remove(_localeKey);
    } else {
      await _prefs?.setString(_localeKey, locale.languageCode);
    }
  }
}
