import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/views/widgets/area_segura.dart';

Widget montar({
  required EdgeInsets barra,
  EdgeInsets teclado = EdgeInsets.zero,
  required Widget hijo,
}) => MediaQuery(
  data: MediaQueryData(
    size: const Size(400, 800),
    padding: barra,
    viewPadding: barra,
    viewInsets: teclado,
  ),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: AreaSegura(siempre: true, child: hijo),
  ),
);

void pantalla(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  const barra = EdgeInsets.only(bottom: 48);
  const clave = Key('contenido');

  testWidgets('la barra de navegación no tapa el final de la pantalla', (
    tester,
  ) async {
    pantalla(tester);
    await tester.pumpWidget(
      montar(
        barra: barra,
        hijo: const SizedBox.expand(key: clave),
      ),
    );
    final caja = tester.getRect(find.byKey(clave));
    expect(caja.bottom, 800 - 48);
  });

  testWidgets('un SafeArea interior no vuelve a restar el espacio', (
    tester,
  ) async {
    pantalla(tester);
    await tester.pumpWidget(
      montar(
        barra: barra,
        hijo: const SafeArea(child: SizedBox.expand(key: clave)),
      ),
    );
    expect(tester.getRect(find.byKey(clave)).bottom, 800 - 48);
  });

  testWidgets('con el teclado abierto no se reserva nada', (tester) async {
    pantalla(tester);
    await tester.pumpWidget(
      montar(
        barra: EdgeInsets.zero,
        teclado: const EdgeInsets.only(bottom: 320),
        hijo: const SizedBox.expand(key: clave),
      ),
    );
    expect(tester.getRect(find.byKey(clave)).bottom, 800);
  });

  testWidgets('sin barra de navegación no cambia nada', (tester) async {
    pantalla(tester);
    pantalla(tester);
    await tester.pumpWidget(
      montar(
        barra: EdgeInsets.zero,
        hijo: const SizedBox.expand(key: clave),
      ),
    );
    expect(tester.getRect(find.byKey(clave)).bottom, 800);
  });
}
