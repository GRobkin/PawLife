// services/map_capture_service.dart
//
// Captura del mapa durante el paseo, para usarla como imagen del paseo.
//
// Sustituye a sacar una foto con la cámara: lo que interesa guardar del paseo
// es el recorrido, no lo que tenía delante el teléfono.
//
// El formato lo impone el backend: la foto del paseo tiene que ser
// `data:image/jpeg;base64,...` de hasta 409.600 bytes (CareValidator.php). Si
// no, rechaza el paseo entero y no se guarda. Flutter solo sabe exportar una
// captura en PNG, así que aquí se codifica a JPEG a mano con el paquete
// `image`.

import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

class MapCaptureException implements Exception {
  const MapCaptureException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MapCaptureService {
  const MapCaptureService();

  /// Lado mayor de la captura en píxeles. Basta para verla a pantalla
  /// completa en el detalle del paseo, y a más resolución el JPEG crece sin
  /// que se note.
  static const int ladoMaximo = 720;

  /// Tope del data URI. El backend admite 409.600 bytes; se deja margen para
  /// no depender de que los dos números coincidan exactamente.
  static const int topeBytes = 400000;

  /// Captura lo que pinta [limite] y lo devuelve como data URI JPEG listo
  /// para guardar en `fotoUrl`.
  ///
  /// Si la imagen no entra en el tope, baja primero la calidad y después la
  /// resolución. Un mapa con muchas calles y texto comprime peor que una
  /// zona de parque, y el tamaño no se puede saber hasta codificar.
  Future<String> capturar(
    RenderRepaintBoundary limite, {
    double devicePixelRatio = 1,
  }) async {
    final tamano = limite.size;
    if (tamano.isEmpty) {
      throw const MapCaptureException('El mapa todavía no está listo.');
    }

    for (final escala in const [1.0, 0.75, 0.5]) {
      final lado = ladoMaximo * escala;
      // Nunca por encima de la densidad real de la pantalla: sería inventar
      // píxeles que el mapa no tiene.
      final ratio = math.min(
        devicePixelRatio,
        lado / math.max(tamano.width, tamano.height),
      );

      final imagen = await limite.toImage(pixelRatio: ratio);
      final ancho = imagen.width;
      final alto = imagen.height;
      final datos = await imagen.toByteData(format: ui.ImageByteFormat.rawRgba);
      imagen.dispose();

      if (datos == null) {
        throw const MapCaptureException('No se pudo leer la imagen del mapa.');
      }

      final rgba = datos.buffer.asUint8List(
        datos.offsetInBytes,
        datos.lengthInBytes,
      );

      for (final calidad in const [80, 65]) {
        // En un isolate aparte: codificar un JPEG de 720 px en Dart tarda
        // del orden de cientos de milisegundos, y en el hilo principal
        // congelaría el mapa mientras se sigue registrando el paseo.
        final jpeg = await compute(codificarJpeg, (
          rgba: rgba,
          ancho: ancho,
          alto: alto,
          calidad: calidad,
        ));

        final uri = 'data:image/jpeg;base64,${base64Encode(jpeg)}';
        if (uri.length <= topeBytes) return uri;
      }
    }

    throw const MapCaptureException(
      'La captura del mapa salió demasiado grande. Probá con menos zoom.',
    );
  }
}

/// Convierte píxeles RGBA en un JPEG.
///
/// Es una función de primer nivel, y pública, por dos razones: `compute` solo
/// acepta funciones que se puedan mandar a otro isolate, y así se puede
/// probar sin necesidad de pintar nada en pantalla.
Uint8List codificarJpeg(
  ({Uint8List rgba, int ancho, int alto, int calidad}) p,
) {
  final imagen = img.Image.fromBytes(
    width: p.ancho,
    height: p.alto,
    bytes: p.rgba.buffer,
    // Al cruzar de isolate la lista puede llegar como vista de un buffer más
    // grande: sin el desplazamiento se leerían píxeles de otro sitio.
    bytesOffset: p.rgba.offsetInBytes,
    numChannels: 4,
  );

  // 4:2:0 es el submuestreo de color habitual en fotos: reduce bastante el
  // tamaño y en un mapa no se distingue.
  return img.encodeJpg(
    imagen,
    quality: p.calidad,
    chroma: img.JpegChroma.yuv420,
  );
}
