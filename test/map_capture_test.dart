// Captura del mapa del paseo: tiene que salir en el formato exacto que acepta
// el backend, o el paseo entero se rechaza al guardar.
//
// CareValidator.php exige `data:image/jpeg;base64,` con base64 válido y como
// mucho 409.600 bytes. Flutter solo exporta PNG, así que lo que se prueba aquí
// es la conversión a JPEG y que el tope se respete incluso con la imagen que
// peor comprime.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pawlife/services/map_capture_service.dart';

/// Lo que comprueba el backend, replicado para que el test falle si la app y
/// el servidor dejan de estar de acuerdo.
void expectAceptadoPorBackend(String uri) {
  const prefijo = 'data:image/jpeg;base64,';
  expect(uri, startsWith(prefijo));
  expect(uri.length, lessThanOrEqualTo(409600));
  expect(uri.length, lessThanOrEqualTo(MapCaptureService.topeBytes));

  final jpeg = base64Decode(uri.substring(prefijo.length));
  // Marcadores de inicio y fin de un JPEG.
  expect(jpeg.sublist(0, 2), [0xFF, 0xD8]);
  expect(jpeg.sublist(jpeg.length - 2), [0xFF, 0xD9]);
}

/// Desviación típica del brillo. Sin esto, si `toImage` devolviera una imagen
/// en blanco, los tests de tamaño pasarían sin haber capturado nada.
double variacion(String uri) {
  final imagen = img.decodeJpg(
    base64Decode(uri.substring('data:image/jpeg;base64,'.length)),
  )!;
  final valores = [for (final p in imagen) p.luminance.toDouble()];
  final media = valores.reduce((a, b) => a + b) / valores.length;
  final varianza =
      valores.map((v) => (v - media) * (v - media)).reduce((a, b) => a + b) /
      valores.length;
  return math.sqrt(varianza);
}

Future<RenderRepaintBoundary> montar(
  WidgetTester tester,
  Widget contenido, {
  Size tamano = const Size(400, 700),
}) async {
  final clave = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: clave,
          child: SizedBox.fromSize(size: tamano, child: contenido),
        ),
      ),
    ),
  );
  return clave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
}

void main() {
  test('codificarJpeg produce un JPEG válido a partir de RGBA', () {
    const ancho = 8, alto = 6;
    final rgba = Uint8List(ancho * alto * 4);
    for (var i = 0; i < rgba.length; i += 4) {
      rgba
        ..[i] = 30
        ..[i + 1] = 140
        ..[i + 2] = 90
        ..[i + 3] = 255;
    }

    final jpeg = codificarJpeg((
      rgba: rgba,
      ancho: ancho,
      alto: alto,
      calidad: 80,
    ));

    final leido = img.decodeJpg(jpeg)!;
    expect(leido.width, ancho);
    expect(leido.height, alto);
  });

  testWidgets('captura un mapa típico en el formato del backend', (t) async {
    // Bloques de color plano con líneas: se parece a un mapa de calles.
    final limite = await montar(t, CustomPaint(painter: _MapaFalso()));

    final uri = await t.runAsync(
      () => const MapCaptureService().capturar(limite, devicePixelRatio: 3),
    );

    expectAceptadoPorBackend(uri!);
    expect(variacion(uri), greaterThan(5), reason: 'la captura no está vacía');

    final imagen = img.decodeJpg(
      base64Decode(uri.substring('data:image/jpeg;base64,'.length)),
    )!;
    // El lado mayor se limita aunque la pantalla tenga más densidad.
    expect(
      math.max(imagen.width, imagen.height),
      lessThanOrEqualTo(MapCaptureService.ladoMaximo),
    );
  });

  testWidgets('ni el peor caso supera el tope del backend', (t) async {
    // Ruido aleatorio píxel a píxel: lo que peor comprime en JPEG. Obliga a
    // bajar calidad y resolución, que es justo lo que se quiere probar.
    final ruido = await t.runAsync(() => _imagenDeRuido(400, 700));
    final limite = await montar(t, RawImage(image: ruido, fit: BoxFit.fill));

    final uri = await t.runAsync(
      () => const MapCaptureService().capturar(limite, devicePixelRatio: 3),
    );

    expectAceptadoPorBackend(uri!);
    // El ruido puro tiene una desviación de ~74, pero aquí sale bastante
    // menos (~33): para entrar en el tope la captura baja de resolución, y al
    // reducir se promedian píxeles vecinos y el ruido se suaviza. Aun así
    // queda muy por encima de una imagen plana (~13 el mapa de arriba, ~0 una
    // en blanco), que es lo que hay que descartar.
    expect(variacion(uri), greaterThan(20), reason: 'se capturó el ruido');
    ruido!.dispose();
  });

  testWidgets('un mapa sin tamaño avisa en vez de romper', (t) async {
    final limite = await montar(t, const SizedBox.shrink(), tamano: Size.zero);

    await t.runAsync(() async {
      await expectLater(
        const MapCaptureService().capturar(limite),
        throwsA(isA<MapCaptureException>()),
      );
    });
  });
}

class _MapaFalso extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF2EFE9),
    );
    final parque = Paint()..color = const Color(0xFFC8E6C9);
    canvas.drawRect(const Rect.fromLTWH(40, 60, 160, 120), parque);
    final calle = Paint()
      ..color = Colors.white
      ..strokeWidth = 10;
    for (var y = 0.0; y < size.height; y += 70) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), calle);
    }
    final ruta = Paint()
      ..color = const Color(0xFF3FB77E)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(50, 600)
        ..lineTo(150, 400)
        ..lineTo(300, 300)
        ..lineTo(350, 100),
      ruta,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<ui.Image> _imagenDeRuido(int ancho, int alto) {
  final azar = math.Random(42);
  final pixeles = Uint8List(ancho * alto * 4);
  for (var i = 0; i < pixeles.length; i += 4) {
    pixeles
      ..[i] = azar.nextInt(256)
      ..[i + 1] = azar.nextInt(256)
      ..[i + 2] = azar.nextInt(256)
      ..[i + 3] = 255;
  }

  final terminado = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixeles,
    ancho,
    alto,
    ui.PixelFormat.rgba8888,
    terminado.complete,
  );
  return terminado.future;
}
