import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/models/pawlife_models.dart';

Vacuna _dosis(String id, String nombre, DateTime aplicada, DateTime proxima) =>
    Vacuna(
      id: id,
      nombre: nombre,
      fechaAplicacion: aplicada,
      proximaFecha: proxima,
    );

void main() {
  test('la dosis vigente es la más reciente de cada vacuna', () {
    final vacunas = [
      _dosis('a1', 'Rabia', DateTime(2024, 3, 1), DateTime(2025, 3, 1)),
      _dosis('a2', 'rabia ', DateTime(2025, 3, 2), DateTime(2026, 3, 2)),
      _dosis('b1', 'Séxtuple', DateTime(2025, 1, 10), DateTime(2026, 1, 10)),
    ];
    final vigentes = dosisVigentes(vacunas);
    expect(vigentes.map((v) => v.id).toSet(), {'a2', 'b1'});
  });

  test('sin vacunas no hay dosis vigentes', () {
    expect(dosisVigentes(const []), isEmpty);
  });

  test('una dosis vieja con próxima fecha futura no cuenta como vigente', () {
    // La primera dosis decía "próxima en 2030", pero ya se aplicó otra.
    final vacunas = [
      _dosis('v1', 'Rabia', DateTime(2025, 1, 1), DateTime(2030, 1, 1)),
      _dosis('v2', 'Rabia', DateTime(2025, 6, 1), DateTime(2026, 6, 1)),
    ];
    final vigentes = dosisVigentes(vacunas);
    expect(vigentes.single.id, 'v2');
    expect(vigentes.single.proximaFecha, DateTime(2026, 6, 1));
  });
}
