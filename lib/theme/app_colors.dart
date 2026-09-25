// theme/app_colors.dart
//
// Paleta de PawLife en un solo sitio.
//
// Las pantallas antiguas (home, login, route, walk_summary, welcome) declaran
// estos mismos colores como constantes privadas cada una. No se han tocado
// para no remover código que ya funciona, pero lo nuevo tira de aquí: si algún
// día se cambia el verde, conviene que haya un único sitio donde cambiarlo.

import 'package:flutter/material.dart';

abstract final class AppColors {
  /// Verde oscuro de la marca: botones principales, títulos, iconos activos.
  static const Color verdeOscuro = Color(0xFF12352A);

  /// Verde claro de acento: botón de acción, estados correctos.
  static const Color verdeAcento = Color(0xFF5CC58F);

  /// Verde suave de fondo para insignias tipo "Healthy".
  static const Color verdeSuave = Color(0xFFE8F5EE);

  /// Fondo general de las pantallas.
  static const Color fondo = Color(0xFFF7F8FA);

  /// Fondo alternativo, un pelín más azulado (el del Home).
  static const Color fondoAlterno = Color(0xFFF4F5F7);

  /// Borde de tarjetas y campos.
  static const Color borde = Color(0xFFDDE1E6);

  /// Rojo de advertencia: vacuna vencida, errores.
  static const Color alerta = Color(0xFFC0392B);

  /// Fondo del aviso de error.
  static const Color alertaSuave = Color(0xFFFDECEC);

  /// Naranja de "próximo" / pendiente.
  static const Color aviso = Color(0xFFE08D2F);
}
