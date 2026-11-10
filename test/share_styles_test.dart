import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/views/walk_share_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'NunitoSans',
    )..addFont(rootBundle.load('assets/fonts/NunitoSans.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() => WalkShareCard.mapaReal = false);
  tearDown(() => WalkShareCard.mapaReal = true);

  for (final ancho in [320.0, 360.0, 411.0]) {
    testWidgets('los 4 estilos van en una sola fila a $ancho px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final inicio = DateTime(2026, 10, 15, 16, 30);
      final marco = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: marco,
          child: MaterialApp(
            locale: const Locale('pt'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WalkShareScreen(
              comprobarPremium: () async => false,
              mascota: const Mascota(id: 'm', nombre: 'Luna', especie: 'perro'),
              paseo: Paseo(
                id: 'p',
                fechaInicio: inicio,
                fechaFin: inicio.add(const Duration(minutes: 20)),
                duracionSegundos: 1200,
                distanciaMetros: 1250,
                velocidadMaximaKmh: 5,
                ruta: [
                  RoutePoint(
                    latitude: -34.9,
                    longitude: -56.1,
                    timestamp: inicio,
                  ),
                  RoutePoint(
                    latitude: -34.91,
                    longitude: -56.12,
                    timestamp: inicio,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      final nombres = ['Floresta', 'Menta', 'Números', 'Candy'];
      final y = <double>{};
      for (final n in nombres) {
        final f = find.text(n);
        expect(f, findsOneWidget, reason: n);
        y.add(tester.getCenter(f).dy);
      }
      expect(y.length, 1, reason: 'no están en la misma fila: $y');
      expect(tester.takeException(), isNull);
      if (ancho == 360) {
        final limite =
            marco.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final img = await limite.toImage();
          final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
          final f = File('build/test-artifacts/compartir-estilos.png');
          await f.parent.create(recursive: true);
          await f.writeAsBytes(bytes!.buffer.asUint8List());
          img.dispose();
        });
      }
    });
  }
}
