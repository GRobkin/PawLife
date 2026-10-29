// theme/app_theme.dart
//
// Temas claro y oscuro de la app. La identidad (verdes de marca, tipografía
// NunitoSans) es la misma; cambian las superficies y el color de énfasis.
//
// Aquí viven la escala tipográfica y el estilo de los componentes comunes
// (campos, botones, tarjetas, diálogos). Las pantallas no deberían volver a
// declarar esos estilos a mano.

import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// Escala tipográfica de marca. Sin color: lo hereda del tema.
  static const _textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.1,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      height: 1.15,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      height: 1.2,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
    ),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 16, height: 1.4),
    bodyMedium: TextStyle(fontSize: 14, height: 1.4),
    bodySmall: TextStyle(fontSize: 12.5, height: 1.35),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
    // 11 es el mínimo legible: nada por debajo en la interfaz.
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  static final ThemeData light = _build(
    scheme: ColorScheme.fromSeed(seedColor: AppColors.verdeOscuro).copyWith(
      primary: AppColors.verdeOscuro,
      onPrimary: Colors.white,
      surface: Colors.white,
      outline: const Color(0xFF8A949E),
      outlineVariant: AppColors.borde,
    ),
    background: AppColors.fondo,
    field: const Color(0xFFFBFCFD),
    border: AppColors.borde,
    surfaceColor: Colors.white,
  );

  static final ThemeData dark = _build(
    scheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.verdeAcento,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.verdeAcento,
          onPrimary: AppColors.verdeOscuro,
          surface: AppColors.oscuroNivel1,
          onSurface: const Color(0xFFE6EDE9),
          surfaceContainerLowest: AppColors.oscuroNivel0,
          surfaceContainerLow: const Color(0xFF121F19),
          surfaceContainer: AppColors.oscuroNivel1,
          surfaceContainerHigh: AppColors.oscuroNivel2,
          surfaceContainerHighest: AppColors.oscuroNivel3,
          outline: const Color(0xFF6B8074),
          outlineVariant: AppColors.oscuroBorde,
        ),
    background: AppColors.fondoOscuro,
    field: AppColors.oscuroNivel2,
    border: AppColors.oscuroBorde,
    surfaceColor: AppColors.oscuroNivel1,
  );

  static ThemeData _build({
    required ColorScheme scheme,
    required Color background,
    required Color field,
    required Color border,
    required Color surfaceColor,
  }) {
    final radius = BorderRadius.circular(12);
    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );
    final buttonShape = RoundedRectangleBorder(borderRadius: radius);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 15);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NunitoSans',
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          fontFamily: 'NunitoSans',
          color: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.5)),
        border: outline(border),
        enabledBorder: outline(border),
        disabledBorder: outline(border.withValues(alpha: 0.5)),
        focusedBorder: outline(scheme.primary, 1.6),
        errorBorder: outline(AppColors.alerta),
        focusedErrorBorder: outline(AppColors.alerta, 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: const Size(0, 48),
          // textStyle reemplaza el estilo por defecto: hay que repetir la
          // familia o el botón cae a la fuente del sistema.
          textStyle: const TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: const Size(0, 48),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: border),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape,
          minimumSize: const Size(48, 44),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border.withValues(alpha: 0.7)),
        ),
      ),
      // Selectores de hora y fecha con la marca: esquinas grandes, cifras
      // gruesas, el acento solo en lo elegido y el resto en superficie.
      timePickerTheme: TimePickerThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        hourMinuteColor: WidgetStateColor.resolveWith(
          (estados) =>
              estados.contains(WidgetState.selected) ? scheme.primary : field,
        ),
        hourMinuteTextColor: WidgetStateColor.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurface,
        ),
        hourMinuteTextStyle: const TextStyle(
          fontFamily: 'NunitoSans',
          fontSize: 52,
          fontWeight: FontWeight.w900,
        ),
        dialBackgroundColor: field,
        dialHandColor: scheme.primary,
        dialTextColor: WidgetStateColor.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurface,
        ),
        dialTextStyle: const TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: FontWeight.w700,
        ),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        helpTextStyle: TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: FontWeight.w800,
          color: scheme.onSurface.withValues(alpha: 0.7),
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: scheme.onSurface.withValues(alpha: 0.7),
        ),
        confirmButtonStyle: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: buttonShape,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        headerHeadlineStyle: const TextStyle(
          fontFamily: 'NunitoSans',
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
        dayStyle: const TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: FontWeight.w700,
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: scheme.onSurface.withValues(alpha: 0.7),
        ),
        confirmButtonStyle: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: buttonShape,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: border),
      ),
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final plataforma in TargetPlatform.values)
            plataforma: const _TransicionPagina(),
        },
      ),
    );
  }
}

/// Entrada de pantalla: fundido con un leve desplazamiento hacia arriba, y la
/// anterior se desvanece un poco. Con "reducir movimiento" no anima.
class _TransicionPagina extends PageTransitionsBuilder {
  const _TransicionPagina();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;

    final entrada = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final salida = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(entrada),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.85).animate(salida),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(entrada),
          child: child,
        ),
      ),
    );
  }
}
