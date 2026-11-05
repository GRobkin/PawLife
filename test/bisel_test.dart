import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/views/wearable/wearable_bisel.dart';
import 'package:pawlife/views/wearable/wearable_theme.dart';

Widget cristal() => const ColoredBox(color: Colors.black);

/// El reloj entero: un cuadro exacto de 250×250 recortado con ClipOval.
Widget reloj(BiselModo modo, {bool animar = true}) => ClipOval(
  child: SizedBox(
    width: WearableColors.lado,
    height: WearableColors.lado,
    child: BiselReloj(animar: animar, modo: modo, child: cristal()),
  ),
);

Widget app(Widget hijo, {bool reducir = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reducir),
    child: Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: hijo),
    ),
  ),
);

void main() {
  testWidgets('en pausa el aro se queda quieto y no consume frames', (
    tester,
  ) async {
    await tester.pumpWidget(app(reloj(BiselModo.activo)));
    await tester.pump(const Duration(seconds: 5));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(app(reloj(BiselModo.pausado)));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('con reducir movimiento no hay animaciones', (tester) async {
    await tester.pumpWidget(app(reloj(BiselModo.activo), reducir: true));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('el reloj entero mide exactamente 250x250', (tester) async {
    await tester.pumpWidget(app(reloj(BiselModo.reposo, animar: false)));
    expect(
      tester.getSize(find.byType(ClipOval).first),
      const Size(WearableColors.lado, WearableColors.lado),
    );
    expect(
      tester.getSize(find.byType(BiselReloj)),
      const Size(WearableColors.lado, WearableColors.lado),
    );
  });

  testWidgets('captura de los cuatro estados', (tester) async {
    final key = GlobalKey();
    Widget celda(BiselModo modo) => reloj(modo);
    final modos = [
      BiselModo.reposo,
      BiselModo.activo,
      BiselModo.pausado,
      BiselModo.exito,
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          body: RepaintBoundary(
            key: key,
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: Wrap(
                children: [
                  for (final m in modos)
                    SizedBox(
                      width: 340,
                      height: 330,
                      child: Center(child: celda(m)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // El paseo lleva 20 s, un tercio de vuelta; la pausa se toma ahí mismo.
    await tester.pump(const Duration(seconds: 20));
    final limite =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final imagen = await limite.toImage();
      final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
      final out = File('build/test-artifacts/gallery-reloj-vivo.png');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(bytes!.buffer.asUint8List());
      imagen.dispose();
    });
    expect(tester.takeException(), isNull);
  });
}
