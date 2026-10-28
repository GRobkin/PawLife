import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('sin datos guardados: sistema y sin idioma fijo', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await AppPreferences.load();
    expect(p.themeMode, ThemeMode.system);
    expect(p.locale, isNull);
  });

  test('persiste tema e idioma entre cargas', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await AppPreferences.load();
    await p.setThemeMode(ThemeMode.dark);
    await p.setLocale(const Locale('pt'));
    final again = await AppPreferences.load();
    expect(again.themeMode, ThemeMode.dark);
    expect(again.locale, const Locale('pt'));
    await again.setLocale(null);
    expect((await AppPreferences.load()).locale, isNull);
  });

  test('valores guardados no válidos se ignoran', () async {
    SharedPreferences.setMockInitialValues({
      'pref.themeMode': 'neon',
      'pref.locale': 'fr',
    });
    final p = await AppPreferences.load();
    expect(p.themeMode, ThemeMode.system);
    expect(p.locale, isNull);
  });
}
