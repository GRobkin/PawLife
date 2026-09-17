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
    String? fotoUrl,
    String? notas,
  }) async {
    final creada = await client.post('/api/mascotas', {
      'id': ?id,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'fotoUrl': fotoUrl,
      'notas': notas,
    });

    return Mascota.fromJson(creada);
  }

  /// Devuelve la mascota [id], creándola si todavía no existe.
  ///
  /// Hace falta porque el backend rechaza colgar un paseo (o una vacuna, o lo
  /// que sea) de una mascota inexistente, y mientras no haya pantalla para
  /// darla de alta la app trabaja con una fija. Antes esto no daba problema
  /// porque Firestore deja crear subcolecciones bajo un documento que no
  /// existe, dejando la mascota como un hueco en el árbol.
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

  /// Actualización parcial: solo viajan los campos que se pasen. Pasar `null`
  /// en uno de ellos lo borra en el servidor.
  Future<Mascota> updateMascota(
    String id, {
    String? nombre,
    String? especie,
    String? raza,
    String? fotoUrl,
    String? notas,
  }) async {
    final cambios = <String, dynamic>{
      'nombre': ?nombre,
      'especie': ?especie,
      'raza': ?raza,
      'fotoUrl': ?fotoUrl,
      'notas': ?notas,
    };

    return Mascota.fromJson(await client.patch('/api/mascotas/$id', cambios));
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

  // ------------------------------------------------------------------- pesos

  Future<List<RegistroPeso>> fetchPesos(String mascotaId) async {
    final items = await client.getList(_sub(mascotaId, 'pesos'));

    return items.map(RegistroPeso.fromJson).toList(growable: false);
  }

  Future<RegistroPeso> createPeso(
    String mascotaId, {
    required double valorKg,
    DateTime? fecha,
  }) async {
    final creado = await client.post(_sub(mascotaId, 'pesos'), {
      'fecha': (fecha ?? DateTime.now()).toUtc().toIso8601String(),
      'valorKg': valorKg,
    });

    return RegistroPeso.fromJson(creado);
  }

  Future<void> deletePeso(String mascotaId, String id) =>
      client.delete('${_sub(mascotaId, 'pesos')}/$id');

  // ----------------------------------------------------------- recordatorios

  Future<List<Recordatorio>> fetchRecordatorios({bool soloPendientes = false}) async {
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

  Future<Recordatorio> marcarRecordatorio(String id, {required bool completado}) async {
    final actualizado = await client.patch(
      '/api/recordatorios/$id',
      {'completado': completado},
    );

    return Recordatorio.fromJson(actualizado);
  }

  Future<void> deleteRecordatorio(String id) =>
      client.delete('/api/recordatorios/$id');

  String _sub(String mascotaId, String coleccion) =>
      '/api/mascotas/${Uri.encodeComponent(mascotaId)}/$coleccion';
}
