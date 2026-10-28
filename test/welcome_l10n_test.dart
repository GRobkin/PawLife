import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/views/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:pawlife/preferences/app_preferences.dart';

Widget _app(Widget home, Locale locale, ThemeMode mode) =>
    ChangeNotifierProvider(
      create: (_) => AppPreferences.memory(),
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppPreferences.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: mode,
        theme: ThemeData(useMaterial3: true),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        home: home,
      ),
    );

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('bienvenida en inglés (${mode.name}) sin desbordes', (t) async {
      t.view.physicalSize = const Size(360, 740);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_app(const WelcomeScreen(), const Locale('en'), mode));
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });
  }
}
