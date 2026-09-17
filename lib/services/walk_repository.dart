// services/walk_repository.dart
//
// Capa de "servicio" para los paseos. Las Views y el ViewModel hablan con esta
// clase, nunca con HTTP directamente, igual que hacemos con Geolocator en
// location_service.dart.
//
// Antes esto escribía en Firestore desde el móvil. Ahora manda el paseo a la
// API PHP (../apipaw), que es la única que toca la base de datos. El cambio se
// nota poco desde fuera porque la interfaz pública es casi la misma; lo que sí
// cambió es que `watchPaseos` (un Stream en tiempo real de Firestore) pasó a
// ser `fetchPaseos`: sobre una API REST no hay suscripción que valga, hay que
// pedir la lista.
//
// Traduce el modelo puro `WalkSession` (models/route_point.dart) al modelo de
// dominio `Paseo` (models/pawlife_models.dart), que es el que se persiste.

import '../models/pawlife_models.dart';
import '../models/route_point.dart';
import 'api_client.dart';

/// Error de dominio para que la UI muestre un mensaje entendible en vez de la
/// excepción cruda del cliente HTTP.
class WalkSaveException implements Exception {
  const WalkSaveException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WalkRepository {
  WalkRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Convierte la sesión de paseo al cuerpo que espera la API.
  ///
  /// La ruta va con la hora de cada punto: sin ella se pierde el ritmo del
  /// paseo y no se podría reconstruir la velocidad por tramo más adelante.
  Map<String, dynamic> bodyFromSession(WalkSession session) {
    return {
      'fechaInicio': session.startedAt.toUtc().toIso8601String(),
      'fechaFin': session.endedAt.toUtc().toIso8601String(),
      'duracionSegundos': session.duration.inSeconds,
      'distanciaMetros': session.distanceMeters,
      'velocidadMaximaKmh': session.maxSpeedKmh,
      'ruta': session.points.map((p) => p.toJson()).toList(growable: false),
    };
  }

  /// Guarda el paseo y devuelve el id que le asignó el servidor.
  Future<String> savePaseo({
    required String mascotaId,
    required WalkSession session,
  }) async {
    try {
      final creado = await _client.post(
        _paseos(mascotaId),
        bodyFromSession(session),
      );

      return Paseo.fromJson(creado).id;
    } on ApiException catch (e) {
      throw WalkSaveException('No se pudo guardar el paseo: ${e.message}');
    }
  }

  /// Paseos de una mascota, del más reciente al más antiguo (el orden lo pone
  /// el backend por defecto).
  Future<List<Paseo>> fetchPaseos(String mascotaId, {int? limite}) async {
    try {
      final items = await _client.getList(
        _paseos(mascotaId),
        query: limite == null ? null : {'limit': '$limite'},
      );

      return items.map(Paseo.fromJson).toList(growable: false);
    } on ApiException catch (e) {
      throw WalkSaveException('No se pudieron cargar los paseos: ${e.message}');
    }
  }

  Future<void> deletePaseo(String mascotaId, String paseoId) async {
    try {
      await _client.delete('${_paseos(mascotaId)}/$paseoId');
    } on ApiException catch (e) {
      throw WalkSaveException('No se pudo borrar el paseo: ${e.message}');
    }
  }

  String _paseos(String mascotaId) =>
      '/api/mascotas/${Uri.encodeComponent(mascotaId)}/paseos';
}
