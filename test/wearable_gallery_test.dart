// Captura los estados del reloj en build/test-artifacts/gallery-reloj.png.
// No verifica comportamiento: deja la imagen para revisión visual.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/wearable/wearable_controller.dart';
import 'package:pawlife/views/wearable/wearable_theme.dart';
import 'package:pawlife/views/wearable/wearable_walk_view.dart';

class _Paseo extends ChangeNotifier implements WearablePaseo {
  Duration t = const Duration(minutes: 12, seconds: 34);
  @override
  Future<String?> iniciar() async => null;
  @override
  void pausar() {}
  @override
  void reanudar() {}
  @override
  WalkSession terminar() => WalkSession(
    points: const [],
    distanceMeters: 1250,
    duration: const Duration(minutes: 20, seconds: 5),
    startedAt: DateTime(2026, 10, 28),
  );
  @override
  Duration get tiempo => t;
  @override
  double get distanciaMetros => 1250;
  @override
  Listenable get cambios => this;
  @override
  void liberar() {}
}

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

  testWidgets('galería reloj', (tester) async {
    tester.view.physicalSize = const Size(1020, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const luna = Mascota(id: 'luna', nombre: 'Luna', especie: 'perro');
    final pendiente = Completer<void>();

    Future<WearableController> en(
      WearableEstado destino, {
      bool falla = false,
    }) async {
      final c = WearableController(
        paseo: _Paseo(),
        cargarMascota: () async => falla ? null : luna,
        guardar: (_, _) => destino == WearableEstado.guardando
            ? pendiente.future
            : Future.value(),
        vibrar: () async {},
      );
      await c.preparar();
      if (destino == WearableEstado.reposo || falla) return c;
      await c.iniciar();
      if (destino == WearableEstado.pausado) await c.pausar();
      if (destino == WearableEstado.guardando) {
        unawaited(c.terminar());
      } else if (destino == WearableEstado.terminado) {
        await c.terminar();
      }
      return c;
    }

    final controladores = [
      await en(WearableEstado.reposo),
      await en(WearableEstado.enPaseo),
      await en(WearableEstado.pausado),
      await en(WearableEstado.guardando),
      await en(WearableEstado.terminado),
      await en(WearableEstado.error, falla: true),
    ];

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: key,
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: Wrap(
                children: [
                  for (final c in controladores)
                    SizedBox(
                      width: 340,
                      height: 350,
                      child: Center(
                        child: ClipOval(
                          child: Container(
                            width: WearableColors.lado,
                            height: WearableColors.lado,
                            color: Colors.black,
                            child: ListenableBuilder(
                              listenable: c,
                              builder: (_, _) =>
                                  WearableWalkView(controller: c),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    final limite =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final imagen = await limite.toImage();
      try {
        final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
        final out = File('build/test-artifacts/gallery-reloj.png');
        await out.parent.create(recursive: true);
        await out.writeAsBytes(bytes!.buffer.asUint8List());
      } finally {
        imagen.dispose();
      }
    });
    for (final c in controladores) {
      c.dispose();
    }
    pendiente.complete();
  });
}
