import 'package:shared_preferences/shared_preferences.dart';

import 'pawlife_models.dart';

/// Racha de días con paseo y avance de la semana, calculados con los paseos
/// que la app ya tiene (no necesitan servidor).
///
/// Los días se cuentan en hora local. La semana empieza el lunes. El plan
/// gratuito solo ve los paseos de los últimos 7 días, así que su racha no puede
/// pasar de 7; con Premium se cuenta todo el historial cargado.
class EstadisticasPaseos {
  const EstadisticasPaseos({
    required this.racha,
    required this.paseosSemana,
    required this.kmSemana,
    required this.paseoHoy,
  });

  /// Días seguidos con al menos un paseo. Si hoy todavía no hubo, la racha de
  /// ayer sigue viva hasta que termine el día.
  final int racha;
  final int paseosSemana;
  final double kmSemana;
  final bool paseoHoy;

  factory EstadisticasPaseos.calcular(Iterable<Paseo> paseos, DateTime ahora) {
    DateTime dia(DateTime d) {
      final l = d.toLocal();
      return DateTime(l.year, l.month, l.day);
    }

    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final dias = {for (final p in paseos) dia(p.fechaInicio)};
    final paseoHoy = dias.contains(hoy);

    var racha = 0;
    // Si hoy no hubo paseo todavía, se cuenta desde ayer.
    var cursor = paseoHoy ? hoy : DateTime(hoy.year, hoy.month, hoy.day - 1);
    while (dias.contains(cursor)) {
      racha++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    final lunes = DateTime(hoy.year, hoy.month, hoy.day - (hoy.weekday - 1));
    var paseosSemana = 0;
    var metros = 0.0;
    for (final p in paseos) {
      if (!dia(p.fechaInicio).isBefore(lunes)) {
        paseosSemana++;
        metros += p.distanciaMetros;
      }
    }
    return EstadisticasPaseos(
      racha: racha,
      paseosSemana: paseosSemana,
      kmSemana: metros / 1000,
      paseoHoy: paseoHoy,
    );
  }
}

/// Paseos por semana que la persona se propone. Se guarda en el dispositivo.
abstract final class MetaSemanal {
  static const opciones = [2, 3, 4, 5, 7];
  static const porOmision = 3;
  static const _clave = 'pref.goal.week';

  static Future<int> leer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getInt(_clave);
      return v != null && v >= 1 && v <= 7 ? v : porOmision;
    } catch (_) {
      return porOmision;
    }
  }

  static Future<void> guardar(int paseos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_clave, paseos.clamp(1, 7));
    } catch (_) {
      // Sin almacenamiento la meta vale solo para esta sesión.
    }
  }
}
