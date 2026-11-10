import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/views/splash_screen.dart';

Widget app({bool reducir = false, bool animar = true}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(390, 844),
      disableAnimations: reducir,
    ),
    child: PantallaCarga(animar: animar),
  ),
);

void main() {
  testWidgets('el primer cuadro es la huella sobre el verde de la marca', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, PantallaCarga.fondo);
    // La huella principal más las 6 del rastro.
    expect(find.byIcon(Icons.pets), findsNWidgets(7));
    // Sin indicador de progreso: el movimiento lo reemplaza.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tras un instante suma el rastro, la marca y la barrita', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    // Primer cuadro: solo la huella principal (igual al splash nativo).
    expect(find.byIcon(Icons.pets), findsNWidgets(7));
    final marca = find.text('pawlife');
    double opacidad() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(of: marca, matching: find.byType(AnimatedOpacity)),
        )
        .opacity;
    expect(opacidad(), 0);
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 700));
    expect(opacidad(), 1);
    // Lo único que se mueve es la barrita de carga.
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('con reducir movimiento se queda quieta', (tester) async {
    await tester.pumpWidget(app(reducir: true));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.hasRunningAnimations, isFalse);
    // Pero se ve todo, quieto.
    expect(find.text('pawlife'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
