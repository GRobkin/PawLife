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
//
// La marca es una huella dibujada a mano (no el icono genérico de Material):
// dedos ovalados e inclinados, almohadilla de dos lóbulos, un corazón en el
// centro, volumen de vidrio en menta y, de fondo, un sendero de paseo.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/theme/app_colors.dart';
import 'package:pawlife/views/widgets/huella_pawlife.dart';

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

/// Sendero de paseo: una curva suave con puntos, muy tenue, detrás de la huella.
class _Sendero extends CustomPainter {
  const _Sendero();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final ruta = Path()
      ..moveTo(-w * 0.05, w * 0.86)
      ..cubicTo(w * 0.28, w * 0.98, w * 0.3, w * 0.62, w * 0.55, w * 0.7)
      ..cubicTo(w * 0.8, w * 0.78, w * 0.78, w * 0.3, w * 1.05, w * 0.22);
    canvas.drawPath(
      ruta,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.05),
    );
    for (final m in ruta.computeMetrics()) {
      for (var d = 20.0; d < m.length; d += 90) {
        final pos = m.getTangentForOffset(d)!.position;
        canvas.drawCircle(
          pos,
          6,
          Paint()..color = AppColors.verdeAcento.withValues(alpha: 0.28),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_Sendero old) => false;
}

Widget _huella(double escala, [ModoHuella modo = ModoHuella.color]) =>
    HuellaPawLife(lado: _lado, escala: escala, modo: modo);

void main() {
  testWidgets('icon.png: fondo verde bosque, sendero y huella', (tester) async {
    await _guardar(
      tester,
      'icon.png',
      Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.35, -0.5),
                radius: 1.15,
                colors: [
                  Color(0xFF237256),
                  Color(0xFF14402F),
                  AppColors.verdeOscuro,
                ],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
          const CustomPaint(painter: _Sendero()),
          // Resplandor menta tras la huella.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.55,
                colors: [
                  AppColors.verdeAcento.withValues(alpha: 0.22),
                  AppColors.verdeAcento.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          _huella(1.12),
        ],
      ),
    );
  });

  testWidgets('foreground.png: solo la huella, para el ícono adaptativo', (
    tester,
  ) async {
    // El adaptativo recorta con una máscara: lo importante cabe en el 66 %.
    await _guardar(tester, 'foreground.png', _huella(1.02));
  });

  testWidgets('monochrome.png: silueta blanca para el ícono temático', (
    tester,
  ) async {
    await _guardar(
      tester,
      'monochrome.png',
      _huella(1.02, ModoHuella.monocromo),
    );
  });

  testWidgets('splash.png: la huella para la pantalla de carga', (
    tester,
  ) async {
    await _guardar(tester, 'splash.png', _huella(0.9));
  });
}
