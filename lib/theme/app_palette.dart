// theme/app_palette.dart
//
// Colores que cambian entre claro y oscuro. Las pantallas los piden por
// contexto en vez de declarar constantes propias; los verdes de marca se
// conservan (en oscuro el acento pasa a ser el color de énfasis).
//
// Escala de superficies del modo oscuro (de menor a mayor elevación):
//   fondoPantalla < superficie < relleno/campo < superficieAlta.

import 'package:flutter/material.dart';

import 'app_colors.dart';

extension AppPalette on BuildContext {
  bool get esOscuro => Theme.of(this).brightness == Brightness.dark;

  /// Color de títulos y enlaces de marca.
  Color get marca => esOscuro ? AppColors.verdeAcento : AppColors.verdeOscuro;

  /// Enlaces dentro de un formulario: el verde de acento no alcanza contraste
  /// sobre blanco, así que en claro se usa un verde medio.
  Color get enlace =>
      esOscuro ? AppColors.verdeAcento : const Color(0xFF2A7D55);

  /// Fondo y texto de los botones principales.
  Color get botonFondo =>
      esOscuro ? AppColors.verdeAcento : AppColors.verdeOscuro;
  Color get botonTexto => esOscuro ? AppColors.verdeOscuro : Colors.white;

  /// Texto sobre el verde de acento (botones de acción): verde oscuro en ambos
  /// temas, porque el blanco sobre `#5CC58F` no tiene contraste suficiente.
  Color get sobreAcento => AppColors.verdeOscuro;

  Color get fondoPantalla => Theme.of(this).scaffoldBackgroundColor;
  Color get superficie => esOscuro ? AppColors.oscuroNivel1 : Colors.white;
  Color get superficieAlta =>
      esOscuro ? AppColors.oscuroNivel3 : const Color(0xFFF1F3F6);

  /// Campos de formulario.
  Color get campo =>
      esOscuro ? AppColors.oscuroNivel2 : const Color(0xFFFBFCFD);

  /// Rellenos neutros (selectores, iconos en recuadro, insignias).
  Color get relleno =>
      esOscuro ? AppColors.oscuroNivel2 : const Color(0xFFEDF2F7);
  Color get rellenoNeutro =>
      esOscuro ? const Color(0xFF222E28) : const Color(0xFFF0F1F3);

  /// Fondos con tinte de marca.
  Color get mentaSuave =>
      esOscuro ? const Color(0xFF1D3328) : AppColors.verdeSuave;
  Color get tarjetaMenta =>
      esOscuro ? AppColors.oscuroNivel1 : const Color(0xFFF1F8F4);
  Color get fondoMenta => esOscuro ? fondoPantalla : AppColors.verdeSuave;

  Color get bordeSuave => esOscuro ? AppColors.oscuroBorde : AppColors.borde;

  Color get texto => Theme.of(this).colorScheme.onSurface;
  Color get textoSuave =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.68);
  Color get textoTenue =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.62);

  Color get errorFondo =>
      esOscuro ? const Color(0xFF3A1B1B) : AppColors.alertaSuave;
  Color get errorBorde =>
      esOscuro ? const Color(0xFF6B2D2D) : const Color(0xFFF5C6C6);
  Color get errorTexto =>
      esOscuro ? const Color(0xFFF2B8B5) : const Color(0xFF8E2A22);
  Color get errorIcono => esOscuro ? const Color(0xFFE57368) : AppColors.alerta;

  /// Rojo para texto de alerta: `#C0392B` no alcanza 3:1 sobre las superficies
  /// oscuras, así que en oscuro se aclara.
  Color get alertaTexto => errorIcono;
}
