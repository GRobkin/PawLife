import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/views/splash_screen.dart';
import 'package:pawlife/views/widgets/huella_pawlife.dart';

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
    // La huella principal (imagen del splash nativo) y las 6 del rastro.
    expect(find.byType(HuellaPawLife), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsNWidgets(6));
    // Sin indicador de progreso: el movimiento lo reemplaza.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('desde el primer cuadro están la marca y la barrita', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(find.byType(HuellaPawLife), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsNWidgets(6));
    expect(find.text('pawlife'), findsOneWidget);
    // Lo único que se mueve es la barrita de carga.
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 700));
    final marca = find.text('pawlife');
    final opacidad = tester
        .widget<AnimatedOpacity>(
          find.ancestor(of: marca, matching: find.byType(AnimatedOpacity)),
        )
        .opacity;
    expect(opacidad, 1);
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
