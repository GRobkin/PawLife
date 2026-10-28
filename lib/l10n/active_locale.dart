// l10n/active_locale.dart
//
// Idioma efectivo de la app para código sin BuildContext (avisos locales).
// AppPreferences lo mantiene al día; sin elección explícita se usa el del
// sistema y, si no está soportado, español.

import 'dart:ui';

import 'app_localizations.dart';

abstract final class ActiveLocale {
  static Locale? _chosen;

  static void choose(Locale? locale) => _chosen = locale;

  static Locale get current {
    final wanted = _chosen ?? PlatformDispatcher.instance.locale;
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == wanted.languageCode) return supported;
    }
    return const Locale('es');
  }

  static AppLocalizations get strings => lookupAppLocalizations(current);
}
