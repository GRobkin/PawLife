// Filtro de lecturas GPS del paseo.
//
// El síntoma que corrige: los paseos dibujaban líneas que atravesaban
// manzanas enteras, porque cada lectura del GPS entraba al recorrido aunque
// tuviera 80 m de error. El test principal simula un paseo doblando una
// esquina, con el tipo de lecturas malas que da el GPS en la ciudad, y
// comprueba que lo dibujado no se aparta de las calles.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pawlife/services/gps_point_filter.dart';

// Montevideo. Los metros se pasan a grados con una proyección local, que a
// escala de un paseo es exacta de sobra.
const _lat0 = -34.9011;
const _lng0 = -56.1645;
const _mPorGradoLat = 111320.0;
final _mPorGradoLng = 111320.0 * math.cos(_lat0 * math.pi / 180);

LatLng _desdeMetros(double este, double norte) =>
    LatLng(_lat0 + norte / _mPorGradoLat, _lng0 + este / _mPorGradoLng);

(double este, double norte) _aMetros(LatLng p) => (
  (p.longitude - _lng0) * _mPorGradoLng,
  (p.latitude - _lat0) * _mPorGradoLat,
);

/// Distancia de un punto al recorrido real: la calle de A(0,0) a B(200,0) y
/// la de B a C(200,200).
double _distanciaALaCalle(LatLng p) {
  final (x, y) = _aMetros(p);
  // Punto más cercano de cada tramo de calle, y la menor de las dos
  // distancias.
  final cx = x.clamp(0.0, 200.0);
  final cy = y.clamp(0.0, 200.0);
  final aLaPrimera = math.sqrt((x - cx) * (x - cx) + y * y);
  final aLaSegunda = math.sqrt((x - 200) * (x - 200) + (y - cy) * (y - cy));
  return math.min(aLaPrimera, aLaSegunda);
}

double _longitud(List<LatLng> puntos) {
  const d = Distance();
  var total = 0.0;
  for (var i = 1; i < puntos.length; i++) {
    total += d.as(LengthUnit.Meter, puntos[i - 1], puntos[i]);
  }
  return total;
}

/// Lecturas de un paseo de 400 m doblando una esquina, a 1,4 m/s y una cada
/// 4 s, con los defectos típicos del GPS en la ciudad.
List<LecturaGps> _paseoConRuido(DateTime inicio) {
  final azar = math.Random(7);
  final lecturas = <LecturaGps>[];

  // Una posición en caché de hace dos minutos, a medio kilómetro: es lo que
  // a veces entrega Android como primera lectura.
  final cache = _desdeMetros(-500, 300);
  lecturas.add(
    LecturaGps(
      latitud: cache.latitude,
      longitud: cache.longitude,
      momento: inicio.subtract(const Duration(minutes: 2)),
      precisionMetros: 8,
    ),
  );

  for (var i = 0; i <= 72; i++) {
    final recorrido = i * 5.6;
    var (este, norte) = recorrido <= 200
        ? (recorrido, 0.0)
        : (200.0, recorrido - 200);

    // Ruido normal de una buena lectura.
    este += (azar.nextDouble() - 0.5) * 3;
    norte += (azar.nextDouble() - 0.5) * 3;
    var precision = 5 + azar.nextDouble() * 7;

    // Saltos hacia dentro de la manzana, que es lo que dibujaba las líneas
    // atravesando cuadras. En algunos la precisión MIENTE (dice 15 m) y solo
    // los puede atrapar el control de velocidad.
    if (i == 10 || i == 30 || i == 60) {
      norte += 90;
      precision = 15;
    }
    if (i == 20 || i == 45) {
      este -= 70;
      precision = 60;
    }

    final p = _desdeMetros(este, norte);
    final momento = inicio.add(Duration(seconds: 4 * i + 1));
    lecturas.add(
      LecturaGps(
        latitud: p.latitude,
        longitud: p.longitude,
        momento: momento,
        precisionMetros: precision,
      ),
    );

    // Una lectura duplicada que llega dos veces.
    if (i == 25) {
      lecturas.add(
        LecturaGps(
          latitud: p.latitude,
          longitud: p.longitude,
          momento: momento,
          precisionMetros: precision,
        ),
      );
    }
  }
  return lecturas;
}

void main() {
  final inicio = DateTime.utc(2026, 10, 18, 10);

  test('sin filtro, el recorrido atraviesa las manzanas (el bug)', () {
    final crudo = [for (final l in _paseoConRuido(inicio)) l.punto];

    final peor = crudo.map(_distanciaALaCalle).reduce(math.max);
    expect(peor, greaterThan(80), reason: 'el escenario reproduce el bug');
    expect(
      _longitud(crudo),
      greaterThan(1000),
      reason: 'los saltos inflan la distancia',
    );
  });

  test('con filtro, el recorrido se queda en las calles', () {
    final filtro = GpsPointFilter(inicio: inicio);
    final aceptados = [
      for (final l in _paseoConRuido(inicio))
        if (filtro.evaluar(l) == null) l.punto,
    ];

    final peor = aceptados.map(_distanciaALaCalle).reduce(math.max);
    expect(peor, lessThan(5), reason: 'ningún punto se aparta de la calle');

    // 400 m reales. El ruido suma un poco, nunca los cientos de metros de
    // los saltos.
    final metros = _longitud(aceptados);
    expect(metros, inInclusiveRange(390, 460));

    // Se pierden las lecturas malas, no el paseo.
    expect(aceptados.length, greaterThanOrEqualTo(65));
  });

  group('cada regla', () {
    LecturaGps lectura(
      double este,
      double norte,
      int segundo, {
      double? precision = 6,
    }) => LecturaGps(
      latitud: _desdeMetros(este, norte).latitude,
      longitud: _desdeMetros(este, norte).longitude,
      momento: inicio.add(Duration(seconds: segundo)),
      precisionMetros: precision,
    );

    test('descarta una lectura imprecisa', () {
      final filtro = GpsPointFilter(inicio: inicio);
      expect(filtro.evaluar(lectura(0, 0, 1)), isNull);
      expect(
        filtro.evaluar(lectura(5, 0, 5, precision: 40)),
        MotivoDescarte.precision,
      );
    });

    test('tolera algo de imprecisión si lleva rato sin puntos', () {
      // Bajo árboles o entre edificios altos todas las lecturas pueden venir
      // malas: mejor un punto algo impreciso que un agujero en el recorrido.
      final filtro = GpsPointFilter(inicio: inicio);
      expect(filtro.evaluar(lectura(0, 0, 1)), isNull);
      expect(
        filtro.evaluar(lectura(10, 0, 10, precision: 40)),
        MotivoDescarte.precision,
      );
      expect(filtro.evaluar(lectura(45, 0, 35, precision: 40)), isNull);
      // Pero no cualquier cosa.
      expect(
        filtro.evaluar(lectura(100, 0, 80, precision: 120)),
        MotivoDescarte.precision,
      );
    });

    test('descarta posiciones en caché de antes del paseo', () {
      final filtro = GpsPointFilter(inicio: inicio);
      expect(filtro.evaluar(lectura(0, 0, -60)), MotivoDescarte.anterior);
      // El desfase de un par de segundos entre relojes sí se acepta.
      expect(filtro.evaluar(lectura(0, 0, -2)), isNull);
    });

    test('descarta lecturas duplicadas o fuera de orden', () {
      final filtro = GpsPointFilter(inicio: inicio);
      expect(filtro.evaluar(lectura(0, 0, 10)), isNull);
      expect(filtro.evaluar(lectura(3, 0, 10)), MotivoDescarte.desordenada);
      expect(filtro.evaluar(lectura(3, 0, 6)), MotivoDescarte.desordenada);
    });

    test('el ruido de lecturas muy seguidas no cuenta como salto', () {
      final filtro = GpsPointFilter(inicio: inicio);
      final a = lectura(0, 0, 1);
      expect(filtro.evaluar(a), isNull);
      // 8 m en medio segundo serían 58 km/h, pero es ruido normal del GPS.
      final b = LecturaGps(
        latitud: _desdeMetros(8, 0).latitude,
        longitud: _desdeMetros(8, 0).longitude,
        momento: a.momento.add(const Duration(milliseconds: 500)),
        precisionMetros: 6,
      );
      expect(filtro.evaluar(b), isNull);
    });

    test('si se cuela un punto malo, se recupera solo', () {
      // El primer punto miente: dice 6 m de error pero está a 80 m de la
      // calle. Las lecturas buenas parecen saltos al principio, pero al pasar
      // el tiempo la velocidad aparente baja y vuelven a entrar.
      final filtro = GpsPointFilter(inicio: inicio);
      expect(filtro.evaluar(lectura(0, 80, 1)), isNull);

      MotivoDescarte? resultado = MotivoDescarte.salto;
      var segundo = 2;
      while (resultado != null && segundo < 60) {
        resultado = filtro.evaluar(lectura(segundo * 1.4, 0, segundo));
        segundo++;
      }
      expect(resultado, isNull, reason: 'el filtro no se queda atascado');
      expect(segundo, lessThan(15), reason: 'se recupera en segundos');
    });
  });
}
