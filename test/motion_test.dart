import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/views/widgets/motion.dart';

Widget _app(Widget child, {bool reducir = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reducir),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('el pulso se detiene solo y no deja animaciones vivas', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const PulsoSuave(
          color: Colors.green,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DecoratedBox), findsOneWidget);
    // Tres ciclos de 2,2 s y se queda quieto: pumpAndSettle termina.
    await tester.pumpAndSettle();
    expect(find.byType(DecoratedBox), findsNothing);
  });

  testWidgets('con reducir movimiento no hay pulso ni escala', (tester) async {
    await tester.pumpWidget(
      _app(
        const Column(
          children: [
            PulsoSuave(color: Colors.green, child: Text('pulso')),
            Presionable(child: Text('presionable')),
          ],
        ),
        reducir: true,
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byType(DecoratedBox), findsNothing);
    expect(find.byType(AnimatedScale), findsNothing);
  });

  testWidgets('presionable se hunde al tocar y vuelve al soltar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Presionable(
          child: ColoredBox(
            color: Colors.green,
            child: SizedBox(width: 80, height: 40),
          ),
        ),
      ),
    );
    final gesto = await tester.startGesture(
      tester.getCenter(find.byType(Presionable)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.97,
    );
    await gesto.up();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });

  testWidgets('el contador gira al cambiar y queda el valor nuevo', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const TextoGiratorio('1/2')));
    await tester.pumpWidget(_app(const TextoGiratorio('2/2')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsNothing);
    expect(find.text('2/2'), findsOneWidget);
  });

  testWidgets('el rebote solo ocurre al activar', (tester) async {
    await tester.pumpWidget(
      _app(const ReboteAlActivar(activo: false, child: Text('x'))),
    );
    await tester.pumpWidget(
      _app(const ReboteAlActivar(activo: true, child: Text('x'))),
    );
    await tester.pump(const Duration(milliseconds: 150));
    final escala = tester
        .widget<ScaleTransition>(
          find.descendant(
            of: find.byType(ReboteAlActivar),
            matching: find.byType(ScaleTransition),
          ),
        )
        .scale
        .value;
    expect(escala, greaterThan(1));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _app(const ReboteAlActivar(activo: false, child: Text('x'))),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });
}
