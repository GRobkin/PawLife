// Genera las imágenes de marca del ícono y de la pantalla de carga nativa:
//
//   flutter test tool/gerar_icones_test.dart
//
// Escribe en assets/icon/. Después se aplican con:
//
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// No es una prueba de comportamiento: está en tool/ para que `flutter test`
// (que solo corre test/) no la ejecute ni toque los archivos.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/theme/app_colors.dart';

const _lado = 1024.0;

Future<void> _guardar(
  WidgetTester tester,
  String nombre,
  Widget contenido,
) async {
  final key = GlobalKey();
  tester.view.physicalSize = const Size(_lado, _lado);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: SizedBox(width: _lado, height: _lado, child: contenido),
      ),
    ),
  );
  await tester.pump();
  final limite =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final imagen = await limite.toImage();
    final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
    final archivo = File('assets/icon/$nombre');
    await archivo.parent.create(recursive: true);
    await archivo.writeAsBytes(bytes!.buffer.asUint8List());
    imagen.dispose();
  });
}

/// La huella de PawLife: el icono `pets` en menta, con un brillo sutil.
Widget _huella(double tamano) => Center(
  child: ShaderMask(
    shaderCallback: (r) => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFA6F0CB), AppColors.verdeAcento, Color(0xFF3FA878)],
    ).createShader(r),
    child: Icon(Icons.pets, size: tamano, color: Colors.white),
  ),
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('icon.png: fondo verde bosque con la huella', (tester) async {
    await _guardar(
      tester,
      'icon.png',
      DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.2, -0.3),
            radius: 1.0,
            colors: [Color(0xFF1F5642), AppColors.verdeOscuro],
          ),
        ),
        child: _huella(600),
      ),
    );
  });

  testWidgets('foreground.png: solo la huella, para el ícono adaptativo', (
    tester,
  ) async {
    // El ícono adaptativo recorta con una máscara: lo importante tiene que
    // caber en el 66 % central.
    await _guardar(tester, 'foreground.png', _huella(740));
  });

  testWidgets('splash.png: la huella para la pantalla de carga', (
    tester,
  ) async {
    await _guardar(tester, 'splash.png', _huella(620));
  });
}
