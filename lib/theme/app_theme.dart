// theme/app_theme.dart
//
// Temas claro y oscuro de la app. La identidad (verdes de marca, tipografía)
// es la misma; cambian las superficies y el color de énfasis.

import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'NunitoSans',
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.verdeOscuro),
    scaffoldBackgroundColor: AppColors.fondo,
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'NunitoSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.verdeAcento,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.fondoOscuro,
  );
}
