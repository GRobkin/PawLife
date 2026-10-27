// services/photo_service.dart
//
// Fotos de las mascotas, sin Firebase Storage.
//
// Storage exige plan Blaze en los proyectos nuevos, así que la foto se guarda
// dentro del propio documento de la mascota: se reduce a 256x256, se codifica
// en base64 y viaja como data URI en el campo `fotoUrl`. Son unas decenas de
// kilobytes, muy por debajo del límite de 1 MB por documento de Firestore, y
// para un avatar de 56 px da de sobra.
//
// La contrapartida es que la foto viaja en cada carga del listado, así que el
// tamaño importa: de ahí que se reescale ANTES de codificar y que haya un tope
// duro en [_topeBytes]. Si algún día hacen falta fotos grandes de galería, eso
// sí pide Storage (o cualquier otro almacenamiento de archivos) y el sitio
// donde cambiarlo es este archivo.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class PhotoException implements Exception {
  const PhotoException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// De dónde sacar la foto. Lo elige el usuario en un menú.
enum OrigenFoto { camara, galeria }

class PhotoService {
  PhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Lado máximo en píxeles. El avatar más grande que pinta la app es la
  /// portada del detalle, y ahí la imagen se recorta a 210 px de alto.
  static const int _ladoMaximo = 256;

  /// Tope de seguridad sobre el data URI ya codificado. Con 256 px no se
  /// alcanza ni de lejos; está para que un formato raro no acabe generando un
  /// documento que Firestore rechace con un error incomprensible.
  static const int _topeBytes = 400 * 1024;

  /// Abre la cámara o la galería y devuelve la foto lista para guardar, como
  /// data URI (`data:image/jpeg;base64,...`).
  ///
  /// Devuelve null si el usuario cancela, que no es un error y la UI no debe
  /// tratarlo como tal.
  Future<String?> elegirFoto(OrigenFoto origen) async {
    final XFile? elegida;

    try {
      elegida = await _picker.pickImage(
        source: origen == OrigenFoto.camara
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: _ladoMaximo.toDouble(),
        maxHeight: _ladoMaximo.toDouble(),
        // JPEG con algo de pérdida: en un avatar no se distingue y baja mucho
        // el tamaño frente a PNG, que para una foto es enorme.
        imageQuality: 78,
      );
    } on Exception {
      throw const PhotoException('No se pudo abrir la imagen. Probá otra vez.');
    }

    if (elegida == null) return null;

    if (await elegida.length() > 10 * 1024 * 1024) {
      throw const PhotoException(
        'La imagen es demasiado grande. Probá con otra.',
      );
    }
    final bytes = await elegida.readAsBytes();
    final jpeg = await compute(prepararFotoJpeg, bytes);
    final dataUri = 'data:image/jpeg;base64,${base64Encode(jpeg)}';

    if (dataUri.length > _topeBytes) {
      throw const PhotoException(
        'La foto es demasiado grande incluso después de reducirla. '
        'Probá con otra.',
      );
    }

    return dataUri;
  }
}

/// Normaliza también en web: el selector no garantiza JPEG ni elimina EXIF.
Uint8List prepararFotoJpeg(Uint8List bytes) {
  try {
    if (bytes.length > 10 * 1024 * 1024) {
      throw const PhotoException(
        'La imagen es demasiado grande. Probá con otra.',
      );
    }
    final decoder = img.findDecoderForData(bytes);
    if (decoder is! img.JpegDecoder && decoder is! img.PngDecoder) {
      throw const PhotoException('Elegí una imagen JPEG o PNG.');
    }
    final info = decoder!.startDecode(bytes);
    if (info == null ||
        info.width < 1 ||
        info.height < 1 ||
        info.width > 4096 ||
        info.height > 4096 ||
        info.width * info.height > 16 * 1024 * 1024 ||
        info.numFrames != 1) {
      throw const PhotoException(
        'La imagen no es válida o es demasiado grande.',
      );
    }
    final decoded = decoder.decodeFrame(0);
    if (decoded == null) {
      throw const PhotoException('No se pudo leer la imagen.');
    }
    var oriented = img.bakeOrientation(decoded);
    if (oriented.width > 256 || oriented.height > 256) {
      oriented = img.copyResize(
        oriented,
        width: oriented.width >= oriented.height ? 256 : null,
        height: oriented.height > oriented.width ? 256 : null,
      );
    }
    // Copiar solo los píxeles evita heredar EXIF, GPS, comentarios y perfiles.
    final clean = img.Image(
      width: oriented.width,
      height: oriented.height,
      numChannels: 3,
    );
    img.fill(clean, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(clean, oriented);
    return img.encodeJpg(clean, quality: 78, chroma: img.JpegChroma.yuv420);
  } on PhotoException {
    rethrow;
  } catch (_) {
    throw const PhotoException('No se pudo leer la imagen. Probá con otra.');
  }
}
