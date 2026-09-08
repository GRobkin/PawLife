// services/walk_repository.dart
//
// Capa de "servicio": aísla toda la dependencia de Firebase (Auth +
// Firestore). Las Views y el ViewModel hablan con esta clase, nunca
// directamente con FirebaseFirestore, igual que hacemos con Geolocator
// en location_service.dart.
//
// Traduce el modelo puro `WalkSession` (models/route_point.dart, sin
// dependencias de Firebase) al modelo de dominio `Paseo`
// (models/pawlife_models.dart) que es el que se persiste.
//
// Estructura en Firestore:
//   users/{uid}/mascotas/{mascotaId}/paseos/{paseoId}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/pawlife_models.dart';
import '../models/route_point.dart';

/// Error de dominio para que la UI pueda mostrar un mensaje entendible
/// en vez de la excepción cruda de Firebase.
class WalkSaveException implements Exception {
  const WalkSaveException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WalkRepository {
  WalkRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Se asegura de que haya un usuario con el que escribir. Las reglas de
  /// Firestore (firestore.rules) exigen `request.auth.uid == uid`, así que
  /// sin sesión no se puede guardar nada.
  Future<User> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;

    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        throw const WalkSaveException('No se pudo iniciar sesión anónima.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw WalkSaveException('Error de autenticación: ${e.message ?? e.code}');
    }
  }

  /// Convierte la sesión de paseo al modelo `Paseo` que se persiste.
  ///
  /// `Paseo.ruta` es una `List<GeoPoint>`, que no guarda el tiempo de cada
  /// punto; por eso guardamos aparte `rutaDetallada`, con los timestamps
  /// que sí trae `RoutePoint`. Sin eso se pierde el ritmo del paseo y no
  /// se podría reconstruir la velocidad por tramo más adelante.
  Paseo paseoFromSession(WalkSession session, {String? id}) {
    return Paseo(
      id: id ?? session.startedAt.millisecondsSinceEpoch.toString(),
      fechaInicio: session.startedAt,
      fechaFin: session.endedAt,
      duracionSegundos: session.duration.inSeconds,
      distanciaMetros: session.distanceMeters,
      velocidadMaximaKmh: session.maxSpeedKmh,
      ruta: session.points
          .map((p) => GeoPoint(p.latitude, p.longitude))
          .toList(growable: false),
    );
  }

  /// Guarda el paseo y devuelve el id del documento creado.
  Future<String> savePaseo({
    required String mascotaId,
    required WalkSession session,
  }) async {
    final user = await ensureSignedIn();
    final paseo = paseoFromSession(session);

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mascotas')
          .doc(mascotaId)
          .collection('paseos')
          .add({
        ...paseo.toMap(),
        // Timestamps por punto: complementa `ruta`, que solo tiene lat/lng.
        'rutaDetallada': session.points
            .map((p) => {
                  'lat': p.latitude,
                  'lng': p.longitude,
                  'timestamp': Timestamp.fromDate(p.timestamp),
                })
            .toList(growable: false),
        'creadoEn': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } on FirebaseException catch (e) {
      throw WalkSaveException(
        'No se pudo guardar el paseo: ${e.message ?? e.code}',
      );
    }
  }

  /// Paseos de una mascota, del más reciente al más antiguo.
  Stream<List<Paseo>> watchPaseos(String mascotaId) async* {
    final user = await ensureSignedIn();

    yield* _firestore
        .collection('users')
        .doc(user.uid)
        .collection('mascotas')
        .doc(mascotaId)
        .collection('paseos')
        .orderBy('fechaInicio', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Paseo.fromDoc).toList(growable: false));
  }
}
