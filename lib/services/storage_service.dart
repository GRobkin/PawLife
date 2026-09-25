// services/storage_service.dart
//
// Subida de las fotos de las mascotas a Firebase Storage.
//
// Es la única excepción a "todos los datos pasan por el backend". El archivo
// va directo de la app a Storage y a la API solo se le manda la URL, que es lo
// que guarda en `fotoUrl`. Mandar el binario a través de la función PHP de
// Vercel obligaría a reenviarlo dos veces y choca con el límite de tamaño de
// cuerpo de una función serverless.
//
// El aislamiento entre usuarios lo dan aquí las reglas de Storage
// (storage.rules): la ruta siempre empieza por users/{uid}/ y las reglas
// exigen que ese uid sea el de quien sube.

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'auth_service.dart';

class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// De dónde sacar la foto. Lo elige el usuario en un menú.
enum OrigenFoto { camara, galeria }

class StorageService {
  StorageService({
    FirebaseStorage? storage,
    ImagePicker? picker,
    AuthService? auth,
  }) : _storage = storage ?? FirebaseStorage.instance,
       _picker = picker ?? ImagePicker(),
       _auth = auth ?? AuthService();

  final FirebaseStorage _storage;
  final ImagePicker _picker;
  final AuthService _auth;

  /// Abre la cámara o la galería. Devuelve null si el usuario cancela, que no
  /// es un error y la UI no debe tratarlo como tal.
  Future<File?> elegirFoto(OrigenFoto origen) async {
    try {
      final elegida = await _picker.pickImage(
        source: origen == OrigenFoto.camara
            ? ImageSource.camera
            : ImageSource.gallery,
        // Se reduce antes de subir: una foto de móvil son varios megas y para
        // un avatar de 80 px no aporta nada. Ahorra datos al usuario y espacio
        // en Storage, que se paga por uso.
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      return elegida == null ? null : File(elegida.path);
    } on Exception catch (e) {
      throw StorageException('No se pudo abrir la imagen: $e');
    }
  }

  /// Sube la foto de una mascota y devuelve su URL pública.
  ///
  /// El nombre lleva una marca de tiempo para que al cambiar la foto no se
  /// reutilice la misma ruta: si se sobrescribiera, las cachés de imagen de la
  /// app y del CDN seguirían sirviendo la anterior.
  Future<String> subirFotoMascota({
    required String mascotaId,
    required File archivo,
  }) async {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      throw const StorageException('No hay sesión iniciada.');
    }

    final marca = DateTime.now().millisecondsSinceEpoch;
    final extension = _extensionDe(archivo.path);
    final ruta =
        'users/${usuario.uid}/mascotas/$mascotaId/foto_$marca$extension';

    try {
      final tarea = await _storage
          .ref(ruta)
          .putFile(
            archivo,
            SettableMetadata(contentType: _tipoMimeDe(extension)),
          );

      return await tarea.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(_traducir(e));
    }
  }

  /// Borra una foto a partir de su URL. Se usa al reemplazarla o al borrar la
  /// mascota, para no dejar archivos huérfanos ocupando y pagándose.
  ///
  /// Si falla no se propaga: el objetivo de quien llama es guardar la mascota,
  /// y que la limpieza falle no debería tirar abajo la operación entera.
  Future<void> borrarPorUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      await _storage.refFromURL(url).delete();
    } on Exception {
      // Se ignora a propósito: puede que ya no exista o que la URL no sea
      // nuestra (por ejemplo la foto de perfil de Google).
    }
  }

  static String _extensionDe(String ruta) {
    final punto = ruta.lastIndexOf('.');
    if (punto == -1) return '.jpg';

    final extension = ruta.substring(punto).toLowerCase();

    return const ['.jpg', '.jpeg', '.png', '.webp', '.heic'].contains(extension)
        ? extension
        : '.jpg';
  }

  /// Sin esto Storage guarda el archivo como application/octet-stream y el
  /// navegador se lo descarga en lugar de mostrarlo.
  static String _tipoMimeDe(String extension) => switch (extension) {
    '.png' => 'image/png',
    '.webp' => 'image/webp',
    '.heic' => 'image/heic',
    _ => 'image/jpeg',
  };

  static String _traducir(FirebaseException e) => switch (e.code) {
    'unauthorized' =>
      'Sin permiso para subir la foto. Revisá las reglas de Firebase Storage.',
    'canceled' => 'Subida cancelada.',
    'quota-exceeded' => 'Se agotó la cuota de almacenamiento del proyecto.',
    'object-not-found' => 'El archivo no existe.',
    // Pasa cuando Storage no está habilitado en el proyecto de Firebase.
    'unknown' =>
      'Fallo al subir la foto. Comprobá que Firebase Storage esté habilitado en el proyecto.',
    _ => 'Fallo al subir la foto: ${e.message ?? e.code}',
  };
}
