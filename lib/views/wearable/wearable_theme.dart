import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Paleta del reloj: negro puro, texto blanco y el verde de la marca como
/// único acento. Todos los pares texto/fondo superan 7:1.
abstract final class WearableColors {
  static const Color fondo = Colors.black;
  static const Color texto = Colors.white;
  static const Color textoTenue = Color(0xFFB8B8B8);
  static const Color acento = AppColors.verdeAcento;
  static const Color sobreAcento = Colors.black;
  static const Color secundario = Color(0xFF2B2B2B);
  static const Color error = Color(0xFFFF8A80);

  /// Lado del marco circular, en píxeles lógicos.
  static const double lado = 250;

  static const TextStyle tiempo = TextStyle(
    fontFamily: 'NunitoSans',
    fontWeight: FontWeight.w900,
    fontSize: 46,
    height: 1,
    color: texto,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle etiqueta = TextStyle(
    fontFamily: 'NunitoSans',
    fontWeight: FontWeight.w800,
    fontSize: 12,
    letterSpacing: 0.6,
    color: texto,
  );
}
