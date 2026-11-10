import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/services/walk_repository.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/walk_summary_screen.dart';
import 'package:pawlife/views/widgets/area_segura.dart';

const _pet = Mascota(id: 'luna', nombre: 'Luna', especie: 'perro');

class _Paseos implements WalkRepository {
  _Paseos(this.alGuardar);
  final Future<String> Function() alGuardar;
  @override
  Future<String> savePaseo({
    required String mascotaId,
    required WalkSession session,
    String? id,
  }) => alGuardar();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Mascotas implements PawLifeRepository {
  @override
  Future<Mascota> fetchMascota(String id) async => _pet;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _inicio = DateTime(2026, 11, 9, 18, 10);

WalkSession _sesion() => WalkSession(
  points: [
    for (var i = 0; i < 12; i++)
      RoutePoint(
        latitude: -34.9 + i * 0.0006 + (i.isEven ? 0.0003 : 0),
        longitude: -56.16 + i * 0.0008,
        timestamp: _inicio,
      ),
  ],
  distanceMeters: 2400,
  duration: const Duration(minutes: 42),
  startedAt: _inicio,
  maxSpeedKmh: 7.4,
);

/// Una pantalla de 390 x 844 con la barra de navegación de Android simulada
/// (tres botones, 48 px) dibujada encima, como en el teléfono.
Widget _telefono(Widget pantalla, ThemeMode modo) {
  const barra = 48.0;
  return SizedBox(
    width: 412,
    height: 915,
    child: MediaQuery(
      data: const MediaQueryData(
        size: Size(412, 915),
        padding: EdgeInsets.only(top: 28, bottom: barra),
        viewPadding: EdgeInsets.only(top: 28, bottom: barra),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        themeMode: modo,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        builder: (context, child) => Stack(
          children: [
            // Igual que en main.dart: la barra del sistema no tapa la app.
            AreaSegura(siempre: true, child: child!),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: barra,
              child: ColoredBox(
                color: Color(0xCCB4B4B4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.play_arrow, size: 22, color: Colors.black54),
                    Icon(
                      Icons.circle_outlined,
                      size: 24,
                      color: Colors.black54,
                    ),
                    Icon(Icons.crop_square, size: 22, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        ),
        home: pantalla,
      ),
    ),
  );
}

void main() {
  setUp(() => WalkSummaryScreen.mapaReal = false);
  tearDown(() => WalkSummaryScreen.mapaReal = true);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'NunitoSans',
    )..addFont(rootBundle.load('assets/fonts/NunitoSans.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('captura: guardando, guardado y con error', (tester) async {
    tester.view.physicalSize = const Size(1236, 1830);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final pendiente = Completer<String>();
    Widget resumen(Future<String> Function() guardar) => WalkSummaryScreen(
      session: _sesion(),
      mascotaId: 'luna',
      repository: _Paseos(guardar),
      mascotas: _Mascotas(),
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: Column(
            children: [
              for (final modo in [ThemeMode.light, ThemeMode.dark])
                Row(
                  children: [
                    _telefono(resumen(() => pendiente.future), modo),
                    _telefono(resumen(() async => 'p1'), modo),
                    _telefono(
                      resumen(() async => throw Exception('Sin conexión')),
                      modo,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);

    // El botón ocupa todo el ancho útil (no se encoge a su contenido) y
    // queda por encima de la barra de navegación.
    final botones = find.byType(ElevatedButton);
    expect(botones, findsNWidgets(6));
    for (final b in botones.evaluate()) {
      final caja = tester.getRect(find.byWidget(b.widget));
      expect(caja.width, greaterThan(330), reason: 'botón angosto: $caja');
      expect(caja.height, greaterThanOrEqualTo(58));
    }

    final limite =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final img = await limite.toImage();
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final f = File('build/test-artifacts/resumen-paseo.png');
      await f.parent.create(recursive: true);
      await f.writeAsBytes(bytes!.buffer.asUint8List());
      img.dispose();
    });
  });
}
