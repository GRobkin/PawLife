// theme/app_palette.dart
//
// Colores que cambian entre claro y oscuro. Las pantallas migradas los piden
// por contexto en vez de usar constantes fijas; los verdes de marca se
// conservan (en oscuro el acento pasa a ser el color de énfasis).

import 'package:flutter/material.dart';

import 'app_colors.dart';

extension AppPalette on BuildContext {
  bool get esOscuro => Theme.of(this).brightness == Brightness.dark;

  /// Color de títulos y enlaces de marca.
  Color get marca => esOscuro ? AppColors.verdeAcento : AppColors.verdeOscuro;

  /// Fondo y texto de los botones principales.
  Color get botonFondo =>
      esOscuro ? AppColors.verdeAcento : AppColors.verdeOscuro;
  Color get botonTexto => esOscuro ? AppColors.verdeOscuro : Colors.white;

  Color get superficie => esOscuro ? const Color(0xFF16241D) : Colors.white;
  Color get campo =>
      esOscuro ? const Color(0xFF1D2D25) : const Color(0xFFFBFCFD);
  Color get bordeSuave => esOscuro ? const Color(0xFF33463C) : AppColors.borde;
  Color get fondoPantalla => Theme.of(this).scaffoldBackgroundColor;

  Color get texto => Theme.of(this).colorScheme.onSurface;
  Color get textoSuave =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.68);
  Color get textoTenue =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.5);

  Color get errorFondo =>
      esOscuro ? const Color(0xFF3A1B1B) : AppColors.alertaSuave;
  Color get errorBorde =>
      esOscuro ? const Color(0xFF6B2D2D) : const Color(0xFFF5C6C6);
  Color get errorTexto =>
      esOscuro ? const Color(0xFFF2B8B5) : const Color(0xFF8E2A22);
  Color get errorIcono => esOscuro ? const Color(0xFFE57368) : AppColors.alerta;
}
