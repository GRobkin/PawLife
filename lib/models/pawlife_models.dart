import 'package:cloud_firestore/cloud_firestore.dart';

class Mascota {
  const Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    this.raza,
    this.fotoUrl,
    this.notas,
  });

  final String id;
  final String nombre;
  final String especie;
  final String? raza;
  final String? fotoUrl;
  final String? notas;

  factory Mascota.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mascota(
      id: doc.id,
      nombre: data['nombre'],
      especie: data['especie'],
      raza: data['raza'],
      fotoUrl: data['fotoUrl'],
      notas: data['notas'],
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'especie': especie,
        'raza': raza,
        'fotoUrl': fotoUrl,
        'notas': notas,
      };
}

class Vacuna {
  const Vacuna({
    required this.id,
    required this.nombre,
    required this.fechaAplicacion,
    required this.proximaFecha,
    this.anticipacionDias = 3,
  });

  final String id;
  final String nombre;
  final DateTime fechaAplicacion;
  final DateTime proximaFecha;
  final int anticipacionDias;

  factory Vacuna.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vacuna(
      id: doc.id,
      nombre: data['nombre'],
      fechaAplicacion: (data['fechaAplicacion'] as Timestamp).toDate(),
      proximaFecha: (data['proximaFecha'] as Timestamp).toDate(),
      anticipacionDias: data['anticipacionDias'] ?? 3,
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'fechaAplicacion': Timestamp.fromDate(fechaAplicacion),
        'proximaFecha': Timestamp.fromDate(proximaFecha),
        'anticipacionDias': anticipacionDias,
      };
}

class Medicamento {
  const Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.horarios,
    required this.fechaInicio,
    this.fechaFin,
    this.activo = true,
  });

  final String id;
  final String nombre;
  final String dosis;
  final List<String> horarios;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool activo;

  factory Medicamento.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicamento(
      id: doc.id,
      nombre: data['nombre'],
      dosis: data['dosis'],
      horarios: List<String>.from(data['horarios']),
      fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (data['fechaFin'] as Timestamp?)?.toDate(),
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'dosis': dosis,
        'horarios': horarios,
        'fechaInicio': Timestamp.fromDate(fechaInicio),
        'fechaFin': fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
        'activo': activo,
      };
}

class RegistroPeso {
  const RegistroPeso({required this.id, required this.fecha, required this.valorKg});

  final String id;
  final DateTime fecha;
  final double valorKg;

  factory RegistroPeso.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RegistroPeso(
      id: doc.id,
      fecha: (data['fecha'] as Timestamp).toDate(),
      valorKg: (data['valorKg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'fecha': Timestamp.fromDate(fecha),
        'valorKg': valorKg,
      };
}

class Paseo {
  const Paseo({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.duracionSegundos,
    required this.distanciaMetros,
    required this.velocidadMaximaKmh,
    required this.ruta,
  });

  final String id;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int duracionSegundos;
  final double distanciaMetros;
  final double velocidadMaximaKmh;
  final List<GeoPoint> ruta;

  factory Paseo.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Paseo(
      id: doc.id,
      fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (data['fechaFin'] as Timestamp).toDate(),
      duracionSegundos: data['duracionSegundos'],
      distanciaMetros: (data['distanciaMetros'] as num).toDouble(),
      velocidadMaximaKmh: (data['velocidadMaximaKmh'] as num).toDouble(),
      ruta: List<GeoPoint>.from(data['ruta']),
    );
  }

  Map<String, dynamic> toMap() => {
        'fechaInicio': Timestamp.fromDate(fechaInicio),
        'fechaFin': Timestamp.fromDate(fechaFin),
        'duracionSegundos': duracionSegundos,
        'distanciaMetros': distanciaMetros,
        'velocidadMaximaKmh': velocidadMaximaKmh,
        'ruta': ruta,
      };
}

class Recordatorio {
  const Recordatorio({
    required this.id,
    required this.tipo,
    required this.mascotaId,
    required this.fecha,
    required this.mensaje,
    this.completado = false,
  });

  final String id;
  final String tipo;
  final String mascotaId;
  final DateTime fecha;
  final String mensaje;
  final bool completado;

  factory Recordatorio.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recordatorio(
      id: doc.id,
      tipo: data['tipo'],
      mascotaId: data['mascotaId'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      mensaje: data['mensaje'],
      completado: data['completado'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'tipo': tipo,
        'mascotaId': mascotaId,
        'fecha': Timestamp.fromDate(fecha),
        'mensaje': mensaje,
        'completado': completado,
      };
}
