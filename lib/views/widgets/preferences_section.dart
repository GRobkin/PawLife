import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/active_locale.dart';
import '../../preferences/app_preferences.dart';
import '../../services/local_reminder_service.dart';
import '../../services/pawlife_repository.dart';
import '../../theme/app_palette.dart';
import 'selector_segmentado.dart';

/// Los avisos locales ya programados llevan el texto del idioma anterior:
/// se reprograman. Sin sesión (pantalla de bienvenida) no hay nada que hacer.
Future<void> _rescheduleReminders() async {
  try {
    if (FirebaseAuth.instance.currentUser == null) return;
    final repository = PawLifeRepository();
    await LocalReminderService.instance.syncBestEffort(repository);
    // El servidor genera algunos avisos (p. ej. falta de paseos): usa este idioma.
    await repository.updatePreferences({
      'idioma': ActiveLocale.current.languageCode,
    });
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
    final etiqueta = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: context.textoSuave,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.language, style: etiqueta),
        const SizedBox(height: 8),
        SelectorSegmentado<String>(
          valor: prefs.locale?.languageCode ?? '',
          opciones: [
            OpcionSegmento('', t.languageSystem),
            const OpcionSegmento('es', 'ES'),
            const OpcionSegmento('en', 'EN'),
            const OpcionSegmento('pt', 'PT'),
          ],
          onCambio: (codigo) async {
            await prefs.setLocale(codigo.isEmpty ? null : Locale(codigo));
            await _rescheduleReminders();
          },
        ),
        const SizedBox(height: 18),
        Text(t.appearance, style: etiqueta),
        const SizedBox(height: 8),
        SelectorSegmentado<ThemeMode>(
          valor: prefs.themeMode,
          opciones: [
            OpcionSegmento(
              ThemeMode.system,
              t.appearanceSystem,
              icono: Icons.brightness_auto_outlined,
            ),
            OpcionSegmento(
              ThemeMode.light,
              t.appearanceLight,
              icono: Icons.light_mode_outlined,
            ),
            OpcionSegmento(
              ThemeMode.dark,
              t.appearanceDark,
              icono: Icons.dark_mode_outlined,
            ),
          ],
          onCambio: prefs.setThemeMode,
        ),
      ],
    );
  }
}
