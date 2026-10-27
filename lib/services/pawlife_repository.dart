// services/pawlife_repository.dart
//
// Acceso a los datos de PawLife a través de la API PHP (../apipaw).
//
// Es el equivalente de lo que antes hacía cloud_firestore desde la app, pero
// ahora la app no sabe nada de Firestore: pide recursos por HTTP y recibe los
// modelos de models/pawlife_models.dart.
//
// Los paseos tienen su propia clase (walk_repository.dart) porque además de
// leerlos hay que convertir la WalkSession que produce el ViewModel.

import '../models/pawlife_models.dart';
import 'api_client.dart';

class PawLifeRepository {
  PawLifeRepository({ApiClient? client}) : client = client ?? ApiClient();

  final ApiClient client;

  Future<Map<String, dynamic>> fetchPerfil() => client.getOne('/api/me');

  /// `true` si la cuenta ya quedó eliminada; `false` si el servidor sigue
  /// terminando el borrado (la cuenta ya está bloqueada y se completa sola).
  Future<bool> eliminarCuenta() async {
    final status = await client.deleteWithStatus('/api/me');
    return status == null || status['estado'] == 'completa';
  }

  Future<Map<String, dynamic>> fetchPrivacy() =>
      client.getOne('/api/me/privacy');
  Future<List<Map<String, dynamic>>> fetchPrivacyRequests() =>
      client.getList('/api/me/privacy-requests');
  Future<Map<String, dynamic>> updatePreferences(Map<String, bool> values) =>
      client.patch('/api/me/preferences', values);
  Future<Map<String, dynamic>> startExport() =>
      client.post('/api/me/exports', {});
  Future<Map<String, dynamic>> exportPage(String id, String cursor) =>
      client.getOne(
        '/api/me/exports/${Uri.encodeComponent(id)}',
        query: {'cursor': cursor},
      );
  Future<void> cancelExport(String id) =>
      client.delete('/api/me/exports/${Uri.encodeComponent(id)}');
  Future<Map<String, dynamic>> createPrivacyRequest({
    required String tipo,
    required String detalle,
    required String solicitudId,
  }) => client.post('/api/me/privacy-requests', {
    'tipo': tipo,
    'detalle': detalle,
    'solicitudId': solicitudId,
  });
  Future<Map<String, dynamic>> privacyRequestStatus(String id) =>
      client.getOne('/api/me/privacy-requests/${Uri.encodeComponent(id)}');

  Future<Map<String, dynamic>> updatePerfil({
    String? nombre,
    String? fotoUrl,
  }) => client.patch('/api/me', {'nombre': ?nombre, 'fotoUrl': ?fotoUrl});

  Future<void> registrarDispositivo({
    required String token,
    required String plataforma,
  }) async {
    final data = {'token': token, 'plataforma': plataforma};
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await client.post('/api/me/devices', data);
        return;
      } on ApiException catch (error) {
        if (error.statusCode != 409 ||
            error.code == 'DEVICE_OWNERSHIP_CONFLICT' ||
            attempt == 2) {
          rethrow;
        }
      }
    }
  }

  Future<void> eliminarDispositivo(String token) async {
    await client.post('/api/me/devices/revoke', {'token': token});
  }

  // ---------------------------------------------------------------- mascotas

  Future<List<Mascota>> fetchMascotas() async {
    final items = await client.getList('/api/mascotas');

    return items.map(Mascota.fromJson).toList(growable: false);
  }

  Future<Mascota> fetchMascota(String id) async {
    return Mascota.fromJson(await client.getOne('/api/mascotas/$id'));
  }

  /// [id] fija el identificador en vez de dejar que lo genere el servidor.
  /// Solo hace falta para datos con identidad conocida de antemano, como la
  /// mascota por defecto (ver [ensureMascota]).
  Future<Mascota> createMascota({
    required String nombre,
    required String especie,
    String? id,
    String? raza,
    DateTime? fechaNacimiento,
    String? fotoUrl,
    String? notas,
  }) async {
    final creada = await client.post('/api/mascotas', {
      'id': ?id,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'fechaNacimiento': fechaNacimiento?.toUtc().toIso8601String(),
      'fotoUrl': fotoUrl,
      'notas': notas,
    });

    return Mascota.fromJson(creada);
  }

  /// Devuelve la mascota [id], creándola si todavía no existe.
  ///
  /// El backend rechaza registros de cuidados asociados a una mascota inexistente.
  Future<Mascota> ensureMascota({
    required String id,
    required String nombre,
    required String especie,
  }) async {
    try {
      return await fetchMascota(id);
    } on ApiException catch (e) {
      if (!e.isNotFound) rethrow;
    }

    try {
      return await createMascota(id: id, nombre: nombre, especie: especie);
    } on ApiException catch (e) {
      // 409: alguien la creó entre el fetch y el create (otro dispositivo, o
      // dos arranques a la vez). No es un error: la mascota está.
      if (e.statusCode == 409) return fetchMascota(id);
      rethrow;
    }
  }

  /// Guarda los cambios de una mascota existente.
  ///
  /// Manda todos los campos editables, incluidos los que estén en `null`: el
  /// formulario de edición los muestra todos, así que vaciar "raza" o "notas"
  /// tiene que borrarlos de verdad. Una actualización parcial dejaría el valor
  /// anterior y el usuario vería que su borrado no tuvo efecto.
  Future<Mascota> updateMascota(Mascota mascota) async {
    final actualizada = await client.patch(
      '/api/mascotas/${mascota.id}',
      mascota.toJson(),
    );

    return Mascota.fromJson(actualizada);
  }

  /// Borra la mascota y, con ella, sus vacunas, medicamentos, pesos y paseos.
  Future<void> deleteMascota(String id) => client.delete('/api/mascotas/$id');

  // ----------------------------------------------------------------- vacunas

  Future<List<Vacuna>> fetchVacunas(String mascotaId) async {
    final items = await client.getList(_sub(mascotaId, 'vacunas'));

    return items.map(Vacuna.fromJson).toList(growable: false);
  }

  Future<Vacuna> createVacuna(
    String mascotaId, {
    required String nombre,
    required DateTime fechaAplicacion,
    required DateTime proximaFecha,
    int anticipacionDias = 3,
  }) async {
    final creada = await client.post(_sub(mascotaId, 'vacunas'), {
      'nombre': nombre,
      'fechaAplicacion': fechaAplicacion.toUtc().toIso8601String(),
      'proximaFecha': proximaFecha.toUtc().toIso8601String(),
      'anticipacionDias': anticipacionDias,
    });

    return Vacuna.fromJson(creada);
  }

  Future<Vacuna> updateVacuna(
    String mascotaId,
    String id,
    Map<String, dynamic> cambios,
  ) async {
    final actualizada = await client.patch(
      '${_sub(mascotaId, 'vacunas')}/$id',
      cambios,
    );

    return Vacuna.fromJson(actualizada);
  }

  Future<void> deleteVacuna(String mascotaId, String id) =>
      client.delete('${_sub(mascotaId, 'vacunas')}/$id');

  // ------------------------------------------------------------ medicamentos

  Future<List<Medicamento>> fetchMedicamentos(String mascotaId) async {
    final items = await client.getList(_sub(mascotaId, 'medicamentos'));

    return items.map(Medicamento.fromJson).toList(growable: false);
  }

  Future<Medicamento> createMedicamento(
    String mascotaId, {
    required String nombre,
    required String dosis,
    required List<String> horarios,
    required DateTime fechaInicio,
    DateTime? fechaFin,
    bool activo = true,
  }) async {
    final creado = await client.post(_sub(mascotaId, 'medicamentos'), {
      'nombre': nombre,
      'dosis': dosis,
      'horarios': horarios,
      'fechaInicio': fechaInicio.toUtc().toIso8601String(),
      'fechaFin': fechaFin?.toUtc().toIso8601String(),
      'activo': activo,
    });

    return Medicamento.fromJson(creado);
  }

  Future<Medicamento> updateMedicamento(
    String mascotaId,
    String id,
    Map<String, dynamic> cambios,
  ) async {
    final actualizado = await client.patch(
      '${_sub(mascotaId, 'medicamentos')}/$id',
      cambios,
    );

    return Medicamento.fromJson(actualizado);
  }

  Future<void> deleteMedicamento(String mascotaId, String id) =>
      client.delete('${_sub(mascotaId, 'medicamentos')}/$id');

  // ----------------------------------------------------------- alimentación

  Future<List<Alimentacion>> fetchAlimentaciones(String mascotaId) async {
    final items = await client.getList(_sub(mascotaId, 'alimentaciones'));
    return items.map(Alimentacion.fromJson).toList(growable: false);
  }

  Future<Alimentacion> createAlimentacion(
    String mascotaId, {
    required String tipoAlimento,
    required double cantidadGramos,
    required DateTime fechaHora,
    String? notas,
  }) async {
    final creada = await client.post(_sub(mascotaId, 'alimentaciones'), {
      'tipoAlimento': tipoAlimento,
      'cantidadGramos': cantidadGramos,
      'fechaHora': fechaHora.toUtc().toIso8601String(),
      'notas': notas,
    });
    return Alimentacion.fromJson(creada);
  }

  Future<void> deleteAlimentacion(String mascotaId, String id) =>
      client.delete('${_sub(mascotaId, 'alimentaciones')}/$id');

  // ------------------------------------------------------------------- pesos

  Future<List<RegistroPeso>> fetchPesos(String mascotaId) async {
    final items = await client.getList(_sub(mascotaId, 'pesos'));

    final registros = items.map(RegistroPeso.fromJson).toList();
    registros.sort((a, b) {
      final fecha = b.fecha.compareTo(a.fecha);
      return fecha != 0 ? fecha : b.id.compareTo(a.id);
    });
    return registros;
  }

  Future<RegistroPeso> createPeso(
    String mascotaId, {
    required double valorKg,
    DateTime? fecha,
    String? id,
  }) async {
    // La API devuelve milisegundos; normalizar antes de enviar permite reconocer
    // la misma escritura tras una respuesta perdida.
    final instante = DateTime.fromMillisecondsSinceEpoch(
      (fecha ?? DateTime.now()).millisecondsSinceEpoch,
      isUtc: true,
    );
    final body = {
      'id': ?id,
      'fecha': instante.toUtc().toIso8601String(),
      'valorKg': valorKg,
    };
    try {
      return RegistroPeso.fromJson(
        await client.post(_sub(mascotaId, 'pesos'), body),
      );
    } on ApiException catch (error) {
      if (error.statusCode != 409 || id == null) rethrow;
      final existente = RegistroPeso.fromJson(
        await client.getOne(
          '${_sub(mascotaId, 'pesos')}/${Uri.encodeComponent(id)}',
        ),
      );
      if (existente.valorKg != valorKg ||
          !existente.fecha.isAtSameMomentAs(instante)) {
        rethrow;
      }
      return existente;
    }
  }

  Future<void> deletePeso(String mascotaId, String id) =>
      client.delete('${_sub(mascotaId, 'pesos')}/$id');

  // ----------------------------------------------------------- recordatorios

  Future<List<Recordatorio>> fetchRecordatorios({
    bool soloPendientes = false,
  }) async {
    final items = await client.getList('/api/recordatorios');
    final recordatorios = items.map(Recordatorio.fromJson);

    // El filtro se aplica aquí y no en el servidor porque filtrar por
    // `completado` y ordenar por `fecha` a la vez obligaría a crear un índice
    // compuesto en Firestore, y la lista de un usuario es corta.
    return (soloPendientes
            ? recordatorios.where((r) => !r.completado)
            : recordatorios)
        .toList(growable: false);
  }

  Future<Recordatorio> createRecordatorio({
    required String tipo,
    required String mascotaId,
    required DateTime fecha,
    required String mensaje,
  }) async {
    final creado = await client.post('/api/recordatorios', {
      'tipo': tipo,
      'mascotaId': mascotaId,
      'fecha': fecha.toUtc().toIso8601String(),
      'mensaje': mensaje,
      'completado': false,
    });

    return Recordatorio.fromJson(creado);
  }

  Future<Recordatorio> marcarRecordatorio(
    String id, {
    required bool completado,
  }) async {
    final actualizado = await client.patch('/api/recordatorios/$id', {
      'completado': completado,
    });

    return Recordatorio.fromJson(actualizado);
  }

  Future<void> deleteRecordatorio(String id) =>
      client.delete('/api/recordatorios/$id');

  String _sub(String mascotaId, String coleccion) =>
      '/api/mascotas/${Uri.encodeComponent(mascotaId)}/$coleccion';
}
