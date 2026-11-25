import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/views/profile_screen.dart';

void main() {
  group('nombreInicialPerfil', () {
    test('usa el de la API cuando existe', () {
      expect(nombreInicialPerfil('Juana Pérez', 'Otro'), 'Juana Pérez');
    });

    test(
      'si la API lo trae vacío, usa el de Firebase (cuenta recién registrada)',
      () {
        expect(nombreInicialPerfil('', 'Prueba Beta5'), 'Prueba Beta5');
        expect(nombreInicialPerfil(null, 'Prueba Beta5'), 'Prueba Beta5');
        expect(nombreInicialPerfil('   ', 'Prueba Beta5'), 'Prueba Beta5');
      },
    );

    test('sin ningún nombre queda vacío en vez de fallar', () {
      expect(nombreInicialPerfil(null, null), '');
      expect(nombreInicialPerfil('', ''), '');
    });

    test('recorta los espacios sobrantes', () {
      expect(nombreInicialPerfil('  Juana ', null), 'Juana');
    });
  });
}
