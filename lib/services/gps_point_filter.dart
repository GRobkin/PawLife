// services/gps_point_filter.dart
//
// Decide qué lecturas del GPS entran en el recorrido de un paseo.
//
// Sin filtro, cada lectura se dibujaba: entre edificios el GPS da posiciones
// con 50–100 m de error, y la línea del paseo iba a la cuadra de al lado y
// volvía, atravesando manzanas enteras. Antes solo se descartaban los saltos
// para calcular la velocidad máxima, pero el punto malo se seguía dibujando y
// sumando a la distancia.
//
// Es Dart puro, sin plugins, para poder probarlo con recorridos simulados
// (ver test/gps_point_filter_test.dart).

import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Una lectura tal como llega del servicio de ubicación.
class LecturaGps {
  const LecturaGps({
    required this.latitud,
    required this.longitud,
    required this.momento,
    this.precisionMetros,
  });

  final double latitud;
  final double longitud;

  /// Cuándo se tomó la posición, no cuándo llegó a la app: con la pantalla
  /// apagada Android entrega varias lecturas juntas y llegan todas a la vez.
  final DateTime momento;

  /// Radio de error estimado por el sistema. null si no se conoce.
  final double? precisionMetros;

  LatLng get punto => LatLng(latitud, longitud);
}

/// Por qué se descartó una lectura. Útil para depurar en el teléfono.
enum MotivoDescarte {
  /// Coordenadas o precisión que no representan una lectura GPS válida.
  invalida,

  /// El error estimado es demasiado grande para fiarse de la posición.
  precision,

  /// Es una posición en caché de antes de empezar el paseo: dibujaría una
  /// línea desde donde estaba el teléfono un rato antes.
  anterior,

  /// No es posterior a la última aceptada (duplicada o fuera de orden).
  desordenada,

  /// Implica una velocidad imposible a pie: es un salto del GPS.
  salto,
}

class GpsPointFilter {
  GpsPointFilter({
    required this.inicio,
    this.precisionMaxima = 25,
    this.precisionTolerada = 50,
    this.esperaAntesDeTolerar = const Duration(seconds: 30),
    this.velocidadMaximaKmh = 30,
  });

  /// Cuándo empezó el paseo. Lo anterior es caché del sistema.
  final DateTime inicio;

  /// Error máximo aceptado normalmente, en metros. Al aire libre el GPS da
  /// 3–10 m; entre edificios, 10–20 m en una buena lectura.
  final double precisionMaxima;

  /// Error aceptado cuando lleva un rato sin entrar ningún punto. Sin este
  /// margen, bajo árboles o entre edificios altos todas las lecturas podían
  /// quedar fuera y el paseo no registraba nada en ese tramo: mejor un punto
  /// algo impreciso que un agujero de varias cuadras.
  final double precisionTolerada;
  final Duration esperaAntesDeTolerar;

  /// Por encima de esto no se va caminando, ni siquiera trotando con el perro.
  final double velocidadMaximaKmh;

  static const _distancia = Distance();

  LecturaGps? _ultima;

  /// La última lectura aceptada, o null si todavía no entró ninguna.
  LecturaGps? get ultima => _ultima;

  /// Devuelve null si la lectura entra en el recorrido, o el motivo por el
  /// que se descarta.
  ///
  /// Los saltos se miden contra la última lectura ACEPTADA. Si alguna vez se
  /// colara un punto malo, el filtro no se queda atascado: la velocidad
  /// aparente hacia las lecturas buenas baja a medida que pasa el tiempo, y en
  /// unos segundos vuelven a entrar.
  MotivoDescarte? evaluar(LecturaGps lectura) {
    final precision = lectura.precisionMetros;
    if (!lectura.latitud.isFinite ||
        !lectura.longitud.isFinite ||
        lectura.latitud.abs() > 90 ||
        lectura.longitud.abs() > 180 ||
        (precision != null && (!precision.isFinite || precision < 0))) {
      return MotivoDescarte.invalida;
    }
    // Margen de unos segundos por el desfase entre el reloj del sistema y el
    // del GPS.
    if (lectura.momento.isBefore(inicio.subtract(const Duration(seconds: 5)))) {
      return MotivoDescarte.anterior;
    }

    final anterior = _ultima;

    if (precision != null && precision > precisionMaxima) {
      final desde = anterior?.momento ?? inicio;
      final sinPuntos = lectura.momento.difference(desde);
      final tolerable =
          sinPuntos >= esperaAntesDeTolerar && precision <= precisionTolerada;
      if (!tolerable) return MotivoDescarte.precision;
    }

    if (anterior != null) {
      if (!lectura.momento.isAfter(anterior.momento)) {
        return MotivoDescarte.desordenada;
      }

      final metros = _distancia.as(
        LengthUnit.Meter,
        anterior.punto,
        lectura.punto,
      );
      // Con lecturas muy seguidas, el ruido normal del GPS (unos metros) da
      // velocidades disparatadas: 10 m en medio segundo son 72 km/h. Se
      // cuenta como mínimo 2 s, así ese ruido no descarta puntos buenos y un
      // salto de verdad (decenas de metros) se sigue detectando.
      final segundos = math.max(
        2.0,
        lectura.momento.difference(anterior.momento).inMilliseconds / 1000,
      );
      final kmh = metros / segundos * 3.6;
      if (kmh > velocidadMaximaKmh) return MotivoDescarte.salto;
    }

    _ultima = lectura;
    return null;
  }
}
