// Vista previa del arranque: la pantalla de carga nativa (la del sistema,
// antes de que arranque Flutter) y la de la app (PantallaCarga), lado a lado.
//
//   flutter test tool/capturar_carga_test.dart   ->  build/test-artifacts/carga.png
//
// La nativa se dibuja con las mismas imágenes y colores que flutter_native_splash
// escribe en Android e iOS; es una aproximación, no una captura del sistema.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/views/splash_screen.dart';

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

  testWidgets('carga.png', (tester) async {
    tester.view.physicalSize = const Size(1170, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final splash = FileImage(File('assets/icon/splash.png'));
    await tester.runAsync(() async {
      final ctx = tester.binding.rootElement!;
      await precacheImage(splash, ctx);
    });

    final key = GlobalKey();
    Widget telefono(Widget hijo) =>
        SizedBox(width: 390, height: 844, child: hijo);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: Row(
            children: [
              // 1) Nativa: fondo verde y la huella centrada, de 256 dp.
              telefono(
                ColoredBox(
                  color: PantallaCarga.fondo,
                  child: Center(
                    child: Image(image: splash, width: 256, height: 256),
                  ),
                ),
              ),
              // 2) La de la app en el primer instante: idéntica a la nativa.
              telefono(
                MediaQuery(
                  data: const MediaQueryData(size: Size(390, 844)),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: const PantallaCarga(animar: false),
                  ),
                ),
              ),
              // 3) La de la app un instante después: rastro de huellas, marca y barrita.
              telefono(
                MediaQuery(
                  data: const MediaQueryData(size: Size(390, 844)),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: const PantallaCarga(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 450));
    final limite =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final img = await limite.toImage();
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final f = File('build/test-artifacts/carga.png');
      await f.parent.create(recursive: true);
      await f.writeAsBytes(bytes!.buffer.asUint8List());
      img.dispose();
    });
  });
}
