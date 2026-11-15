import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/models/horario_silencio.dart';
import 'package:pawlife/services/local_reminder_service.dart';

AvisoPlanificado av(String k, DateTime at) => AvisoPlanificado(k, at, 't', 'b');
DateTime d(int dia, int h, [int m = 0]) => DateTime(2026, 11, dia, h, m);

void main() {
  const noche = HorarioSilencio(activo: true);

  test('un aviso dentro de la franja se pospone al fin; fuera queda igual', () {
    final r = planificarAvisos([
      av('a', d(10, 23)),
      av('b', d(10, 12)),
      av('c', d(11, 3)),
    ], noche);
    expect(
      {for (final e in r) e.key: e.at},
      {'a': d(11, 7), 'b': d(10, 12), 'c': d(11, 7)},
    );
  });

  test('queda ordenado por hora', () {
    final r = planificarAvisos([av('x', d(12, 9)), av('y', d(10, 9))], noche);
    expect(r.map((e) => e.key), ['y', 'x']);
  });

  test('sin horario activo no mueve nada', () {
    final r = planificarAvisos([av('a', d(10, 23))], const HorarioSilencio());
    expect(r.single.at, d(10, 23));
  });

  test('se programan como máximo los 60 más próximos', () {
    final muchos = [
      for (var i = 0; i < 100; i++) av('n$i', d(10, 8).add(Duration(hours: i))),
    ];
    final r = planificarAvisos(muchos, const HorarioSilencio());
    expect(r, hasLength(maxAvisosProgramados));
    expect(r.first.key, 'n0');
    expect(r.last.key, 'n59');
  });

  test('aApi y coincideConServidor', () {
    const s = HorarioSilencio(activo: true, desdeMin: 1320, hastaMin: 420);
    final api = s.aApi('America/Montevideo');
    expect(api, {
      'habilitada': true,
      'desdeMin': 1320,
      'hastaMin': 420,
      'zonaHoraria': 'America/Montevideo',
    });
    expect(s.coincideConServidor(api, 'America/Montevideo'), isTrue);
    expect(s.coincideConServidor(api, 'UTC'), isFalse);
    expect(s.coincideConServidor(null, 'UTC'), isFalse);
    expect(
      s.copyWith(hastaMin: 480).coincideConServidor(api, 'America/Montevideo'),
      isFalse,
    );
  });
}
