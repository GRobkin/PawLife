import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/models/horario_silencio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  DateTime a(int h, [int m = 0, int dia = 10]) => DateTime(2026, 11, dia, h, m);

  group('franja que cruza la medianoche (22:00 a 07:00)', () {
    const s = HorarioSilencio(activo: true);

    test('contiene la noche y la madrugada, no el día', () {
      expect(s.contiene(a(22)), isTrue);
      expect(s.contiene(a(23, 59)), isTrue);
      expect(s.contiene(a(0)), isTrue);
      expect(s.contiene(a(6, 59)), isTrue);
      expect(s.contiene(a(7)), isFalse);
      expect(s.contiene(a(12)), isFalse);
      expect(s.contiene(a(21, 59)), isFalse);
    });

    test('un aviso de la noche pasa a la mañana siguiente', () {
      expect(s.ajustar(a(23)), a(7, 0, 11));
    });

    test('un aviso de la madrugada pasa a las 7 del mismo día', () {
      expect(s.ajustar(a(3)), a(7, 0, 10));
    });

    test('un aviso fuera de la franja no cambia', () {
      expect(s.ajustar(a(15, 30)), a(15, 30));
    });
  });

  test('franja dentro del mismo día (13:00 a 15:00)', () {
    const s = HorarioSilencio(
      activo: true,
      desdeMin: 13 * 60,
      hastaMin: 15 * 60,
    );
    expect(s.contiene(a(13)), isTrue);
    expect(s.contiene(a(14, 59)), isTrue);
    expect(s.contiene(a(15)), isFalse);
    expect(s.contiene(a(12, 59)), isFalse);
    expect(s.ajustar(a(14)), a(15));
  });

  test('desactivado o sin franja no cambia nada', () {
    const apagado = HorarioSilencio();
    expect(apagado.contiene(a(23)), isFalse);
    expect(apagado.ajustar(a(23)), a(23));
    const vacia = HorarioSilencio(activo: true, desdeMin: 480, hastaMin: 480);
    expect(vacia.contiene(a(8)), isFalse);
  });

  group('almacenamiento', () {
    test('sin nada guardado: desactivado, 22:00 a 07:00', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await HorarioSilencio.leer();
      expect(s.activo, isFalse);
      expect(s.desdeMin, 22 * 60);
      expect(s.hastaMin, 7 * 60);
    });

    test('guarda y vuelve a leer', () async {
      SharedPreferences.setMockInitialValues({});
      const s = HorarioSilencio(
        activo: true,
        desdeMin: 23 * 60 + 30,
        hastaMin: 6 * 60,
      );
      await s.guardar();
      expect(await HorarioSilencio.leer(), s);
    });

    test('ignora valores fuera de rango', () async {
      SharedPreferences.setMockInitialValues({
        'pref.dnd.on': true,
        'pref.dnd.from': 5000,
        'pref.dnd.to': -3,
      });
      final s = await HorarioSilencio.leer();
      expect(s.desdeMin, 22 * 60);
      expect(s.hastaMin, 7 * 60);
    });
  });
}
