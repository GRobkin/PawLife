import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../preferences/app_preferences.dart';
import '../../services/local_reminder_service.dart';
import '../../services/pawlife_repository.dart';

/// Los avisos locales ya programados llevan el texto del idioma anterior:
/// se reprograman. Sin sesión (pantalla de bienvenida) no hay nada que hacer.
Future<void> _rescheduleReminders() async {
  try {
    if (FirebaseAuth.instance.currentUser == null) return;
    await LocalReminderService.instance.syncBestEffort(PawLifeRepository());
  } catch (_) {
    // Best effort: se reprogramarán al volver a abrir la app.
  }
}

/// Selectores de idioma y apariencia. Se usa en Perfil y en la bienvenida.
class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final prefs = context.watch<AppPreferences>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.language, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in [
              ('', t.languageSystem),
              ('es', t.languageEs),
              ('en', t.languageEn),
              ('pt', t.languagePt),
            ])
              ChoiceChip(
                label: Text(option.$2),
                selected: (prefs.locale?.languageCode ?? '') == option.$1,
                onSelected: (_) async {
                  await prefs.setLocale(
                    option.$1.isEmpty ? null : Locale(option.$1),
                  );
                  await _rescheduleReminders();
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(t.appearance, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in [
              (ThemeMode.system, t.appearanceSystem),
              (ThemeMode.light, t.appearanceLight),
              (ThemeMode.dark, t.appearanceDark),
            ])
              ChoiceChip(
                label: Text(option.$2),
                selected: prefs.themeMode == option.$1,
                onSelected: (_) => prefs.setThemeMode(option.$1),
              ),
          ],
        ),
      ],
    );
  }
}
