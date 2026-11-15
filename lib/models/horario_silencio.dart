import 'package:shared_preferences/shared_preferences.dart';

/// Franja diaria de "no molestar": dentro de ella la app no muestra avisos.
///
/// Se guarda solo en el dispositivo (como el idioma y el tema). Aplica a los
/// avisos que programa la propia app; las notificaciones push que llegan del
/// servidor con la app cerrada las filtra el servidor: la app le envía este
/// mismo horario y la zona horaria (ver `aApi`).
///
/// La franja puede cruzar la medianoche (22:00 a 07:00). Si [desdeMin] y
/// [hastaMin] coinciden no hay franja.
class HorarioSilencio {
  const HorarioSilencio({
    this.activo = false,
    this.desdeMin = 22 * 60,
    this.hastaMin = 7 * 60,
  });

  /// Minutos desde la medianoche.
  final bool activo;
  final int desdeMin;
  final int hastaMin;

  static const _claveActivo = 'pref.dnd.on';
  static const _claveDesde = 'pref.dnd.from';
  static const _claveHasta = 'pref.dnd.to';

  /// Desde y hasta coinciden: no hay franja.
  bool get sinFranja => desdeMin == hastaMin;

  /// "07:00", "22:30": siempre 24 horas y con ceros, igual que el selector.
  static String formatoHora(int minutos) =>
      '${(minutos ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutos % 60).toString().padLeft(2, '0')}';

  HorarioSilencio copyWith({bool? activo, int? desdeMin, int? hastaMin}) =>
      HorarioSilencio(
        activo: activo ?? this.activo,
        desdeMin: desdeMin ?? this.desdeMin,
        hastaMin: hastaMin ?? this.hastaMin,
      );

  /// ¿Cae [momento] dentro de la franja? Sin horario activo, nunca.
  bool contiene(DateTime momento) {
    if (!activo || desdeMin == hastaMin) return false;
    final m = momento.hour * 60 + momento.minute;
    return desdeMin < hastaMin
        ? m >= desdeMin && m < hastaMin
        : m >= desdeMin || m < hastaMin;
  }

  /// Si [momento] cae en la franja, el aviso se pospone hasta que termina; si
  /// no, queda como está.
  DateTime ajustar(DateTime momento) {
    if (!contiene(momento)) return momento;
    var fin = DateTime(
      momento.year,
      momento.month,
      momento.day,
      hastaMin ~/ 60,
      hastaMin % 60,
    );
    if (!fin.isAfter(momento)) fin = fin.add(const Duration(days: 1));
    return fin;
  }

  /// Forma que guarda el servidor (`preferencias.noMolestar`); él decide con
  /// ella si manda o no un push con la app cerrada.
  Map<String, Object> aApi(String zonaHoraria) => {
    'habilitada': activo,
    'desdeMin': desdeMin,
    'hastaMin': hastaMin,
    'zonaHoraria': zonaHoraria,
  };

  /// ¿El servidor ya tiene exactamente este horario?
  bool coincideConServidor(Object? servidor, String zonaHoraria) =>
      servidor is Map &&
      servidor['habilitada'] == activo &&
      servidor['desdeMin'] == desdeMin &&
      servidor['hastaMin'] == hastaMin &&
      servidor['zonaHoraria'] == zonaHoraria;

  /// Si el almacenamiento falla se usa el valor por defecto (desactivado).
  static Future<HorarioSilencio> leer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int minutos(String clave, int porOmision) {
        final v = prefs.getInt(clave);
        return v != null && v >= 0 && v < 24 * 60 ? v : porOmision;
      }

      return HorarioSilencio(
        activo: prefs.getBool(_claveActivo) ?? false,
        desdeMin: minutos(_claveDesde, 22 * 60),
        hastaMin: minutos(_claveHasta, 7 * 60),
      );
    } catch (_) {
      return const HorarioSilencio();
    }
  }

  Future<void> guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_claveActivo, activo);
      await prefs.setInt(_claveDesde, desdeMin);
      await prefs.setInt(_claveHasta, hastaMin);
    } catch (_) {
      // Sin almacenamiento la elección vale solo para esta sesión.
    }
  }

  @override
  bool operator ==(Object other) =>
      other is HorarioSilencio &&
      other.activo == activo &&
      other.desdeMin == desdeMin &&
      other.hastaMin == hastaMin;

  @override
  int get hashCode => Object.hash(activo, desdeMin, hastaMin);
}
