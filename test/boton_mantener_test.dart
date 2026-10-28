import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/widgets/boton_mantener.dart';

void main() {
  testWidgets('un toque corto no finaliza y muestra la pista', (tester) async {
    var cuenta = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BotonMantener(
            icono: Icons.stop,
            texto: 'Finalizar',
            pista: 'Mantené',
            onCompletar: () => cuenta++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Finalizar'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(cuenta, 0);
    expect(find.text('Mantené'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('mantener pulsado completa una sola vez', (tester) async {
    var cuenta = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BotonMantener(
            icono: Icons.stop,
            texto: 'Finalizar',
            pista: 'Mantené',
            onCompletar: () => cuenta++,
          ),
        ),
      ),
    );
    final gesto = await tester.startGesture(
      tester.getCenter(find.text('Finalizar')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(cuenta, 0);
    await tester.pump(const Duration(milliseconds: 700));
    expect(cuenta, 1);
    await gesto.up();
    await tester.pump(const Duration(seconds: 1));
    expect(cuenta, 1);
  });

  testWidgets('soltar antes de tiempo cancela', (tester) async {
    var cuenta = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BotonMantener(
            icono: Icons.stop,
            texto: 'Finalizar',
            pista: 'Mantené',
            onCompletar: () => cuenta++,
          ),
        ),
      ),
    );
    final gesto = await tester.startGesture(
      tester.getCenter(find.text('Finalizar')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await gesto.up();
    await tester.pump(const Duration(seconds: 2));
    expect(cuenta, 0);
  });
}
