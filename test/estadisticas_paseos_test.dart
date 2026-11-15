import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/models/estadisticas_paseos.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Martes 10/11/2026 a las 15:00. La semana empezó el lunes 9.
final ahora = DateTime(2026, 11, 10, 15);

Paseo paseo(DateTime cuando, {double metros = 1000}) => Paseo(
  id: '${cuando.microsecondsSinceEpoch}',
  fechaInicio: cuando,
  fechaFin: cuando.add(const Duration(minutes: 20)),
  duracionSegundos: 1200,
  distanciaMetros: metros,
  velocidadMaximaKmh: 5,
  ruta: const [],
);

void main() {
  test('sin paseos: sin racha y semana en cero', () {
    final e = EstadisticasPaseos.calcular(const [], ahora);
    expect(e.racha, 0);
    expect(e.paseosSemana, 0);
    expect(e.paseoHoy, isFalse);
  });

  test('semana lunes a domingo, día de hoy y km de los últimos 7 días', () {
    final e = EstadisticasPaseos.calcular([
      paseo(DateTime(2026, 11, 10, 8), metros: 2000),
      paseo(DateTime(2026, 11, 10, 18), metros: 500),
      paseo(DateTime(2026, 11, 8, 9), metros: 3000),
      paseo(DateTime(2026, 11, 2, 9), metros: 9000),
    ], ahora);
    expect(e.diaHoy, 1);
    expect(e.semana, [false, true, false, false, false, false, false]);
    expect(e.kmUltimos7, [0, 0, 0, 0, 3.0, 0, 2.5]);
  });

  test('racha de días seguidos que incluye hoy', () {
    final e = EstadisticasPaseos.calcular([
      paseo(DateTime(2026, 11, 10, 8)),
      paseo(DateTime(2026, 11, 9, 19)),
      paseo(DateTime(2026, 11, 8, 10)),
    ], ahora);
    expect(e.racha, 3);
    expect(e.paseoHoy, isTrue);
  });

  test('si hoy no hubo paseo la racha de ayer sigue viva', () {
    final e = EstadisticasPaseos.calcular([
      paseo(DateTime(2026, 11, 9, 19)),
      paseo(DateTime(2026, 11, 8, 10)),
    ], ahora);
    expect(e.racha, 2);
    expect(e.paseoHoy, isFalse);
  });

  test('un día sin paseo corta la racha', () {
    final e = EstadisticasPaseos.calcular([
      paseo(DateTime(2026, 11, 10, 8)),
      paseo(DateTime(2026, 11, 8, 10)), // falta el 9
    ], ahora);
    expect(e.racha, 1);
  });

  test('si ni hoy ni ayer hubo paseo no hay racha', () {
    final e = EstadisticasPaseos.calcular([
      paseo(DateTime(2026, 11, 7, 10)),
    ], ahora);
    expect(e.racha, 0);
  });

  test('varios paseos el mismo día cuentan un solo día de racha', () {
    final e = EstadisticasPaseos.calcular([
      paseo(DateTime(2026, 11, 10, 8)),
      paseo(DateTime(2026, 11, 10, 18)),
    ], ahora);
    expect(e.racha, 1);
    expect(e.paseosSemana, 2);
  });

  test('la semana empieza el lunes y suma los km', () {
    final e = EstadisticasPaseos.calcular([
      paseo(DateTime(2026, 11, 10, 8), metros: 2500),
      paseo(DateTime(2026, 11, 9, 7), metros: 1500),
      paseo(
        DateTime(2026, 11, 8, 23, 50),
        metros: 9000,
      ), // domingo: semana anterior
    ], ahora);
    expect(e.paseosSemana, 2);
    expect(e.kmSemana, closeTo(4.0, 0.001));
  });

  group('meta semanal', () {
    test('por omisión 3 paseos', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await MetaSemanal.leer(), 3);
    });

    test('guarda y vuelve a leer', () async {
      SharedPreferences.setMockInitialValues({});
      await MetaSemanal.guardar(5);
      expect(await MetaSemanal.leer(), 5);
    });

    test('un valor guardado fuera de rango se ignora', () async {
      SharedPreferences.setMockInitialValues({'pref.goal.week': 40});
      expect(await MetaSemanal.leer(), 3);
    });
  });
}
