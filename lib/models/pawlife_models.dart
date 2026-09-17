// models/pawlife_models.dart
//
// Modelos de dominio de PawLife. Son objetos Dart puros: no dependen de
// Firebase ni de ningún paquete de red.
//
// Antes se construían desde un DocumentSnapshot de cloud_firestore y usaban
// Timestamp y GeoPoint. Ahora los datos llegan como JSON de la API PHP
// (../apipaw), donde las fechas viajan en ISO 8601, así que el mapeo es
// fromJson/toJson y Firestore queda escondido detrás del backend.

import 'route_point.dart';

/// Fecha obligatoria. Si el backend manda algo que no se entiende preferimos
/// caer aquí, con el nombre del campo, y no arrastrar una fecha inventada
/// hasta la pantalla.
DateTime _fecha(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is! String) {
    throw FormatException('Falta el campo "$campo" o no es una fecha.');
  }

  return DateTime.parse(valor).toLocal();
}

DateTime? _fechaOpcional(Map<String, dynamic> json, String campo) {
  final valor = json[campo];

  return valor is String ? DateTime.parse(valor).toLocal() : null;
}

/// La API manda las fechas en UTC; `toIso8601String` sobre un DateTime local
/// no lleva zona, así que hay que convertir antes de serializar.
String _iso(DateTime fecha) => fecha.toUtc().toIso8601String();

String _texto(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is! String || valor.isEmpty) {
    throw FormatException('Falta el campo "$campo".');
  }

  return valor;
}

double _decimal(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is! num) {
    throw FormatException('El campo "$campo" no es un número.');
  }

  return valor.toDouble();
}

int _entero(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is! num) {
    throw FormatException('El campo "$campo" no es un número.');
  }

  return valor.toInt();
}

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

  factory Mascota.fromJson(Map<String, dynamic> json) => Mascota(
        id: _texto(json, 'id'),
        nombre: _texto(json, 'nombre'),
        especie: _texto(json, 'especie'),
        raza: json['raza'] as String?,
        fotoUrl: json['fotoUrl'] as String?,
        notas: json['notas'] as String?,
      );

  /// Cuerpo para POST/PATCH. El `id` no va: lo pone el backend y viaja en la
  /// URL cuando se edita.
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'especie': especie,
        'raza': raza,
        'fotoUrl': fotoUrl,
        'notas': notas,
      };

  Mascota copyWith({
    String? nombre,
    String? especie,
    String? raza,
    String? fotoUrl,
    String? notas,
  }) =>
      Mascota(
        id: id,
        nombre: nombre ?? this.nombre,
        especie: especie ?? this.especie,
        raza: raza ?? this.raza,
        fotoUrl: fotoUrl ?? this.fotoUrl,
        notas: notas ?? this.notas,
      );
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

  /// Cuántos días antes de `proximaFecha` hay que avisar.
  final int anticipacionDias;

  factory Vacuna.fromJson(Map<String, dynamic> json) => Vacuna(
        id: _texto(json, 'id'),
        nombre: _texto(json, 'nombre'),
        fechaAplicacion: _fecha(json, 'fechaAplicacion'),
        proximaFecha: _fecha(json, 'proximaFecha'),
        anticipacionDias: (json['anticipacionDias'] as num?)?.toInt() ?? 3,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'fechaAplicacion': _iso(fechaAplicacion),
        'proximaFecha': _iso(proximaFecha),
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

  /// Horas del día en formato "HH:mm".
  final List<String> horarios;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool activo;

  factory Medicamento.fromJson(Map<String, dynamic> json) => Medicamento(
        id: _texto(json, 'id'),
        nombre: _texto(json, 'nombre'),
        dosis: _texto(json, 'dosis'),
        horarios: (json['horarios'] as List<dynamic>? ?? const [])
            .map((h) => h.toString())
            .toList(growable: false),
        fechaInicio: _fecha(json, 'fechaInicio'),
        fechaFin: _fechaOpcional(json, 'fechaFin'),
        activo: json['activo'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'dosis': dosis,
        'horarios': horarios,
        'fechaInicio': _iso(fechaInicio),
        'fechaFin': fechaFin == null ? null : _iso(fechaFin!),
        'activo': activo,
      };
}

class RegistroPeso {
  const RegistroPeso({
    required this.id,
    required this.fecha,
    required this.valorKg,
  });

  final String id;
  final DateTime fecha;
  final double valorKg;

  factory RegistroPeso.fromJson(Map<String, dynamic> json) => RegistroPeso(
        id: _texto(json, 'id'),
        fecha: _fecha(json, 'fecha'),
        valorKg: _decimal(json, 'valorKg'),
      );

  Map<String, dynamic> toJson() => {
        'fecha': _iso(fecha),
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

  /// Velocidad puntual más alta del paseo, no la media.
  final double velocidadMaximaKmh;

  /// Ruta con la hora de cada punto. En la versión anterior esto estaba
  /// partido en dos campos de Firestore (`ruta` con GeoPoint y sin tiempos, y
  /// `rutaDetallada` con ellos); el backend los unificó en uno solo.
  final List<RoutePoint> ruta;

  factory Paseo.fromJson(Map<String, dynamic> json) {
    final fechaInicio = _fecha(json, 'fechaInicio');

    return Paseo(
      id: _texto(json, 'id'),
      fechaInicio: fechaInicio,
      fechaFin: _fecha(json, 'fechaFin'),
      duracionSegundos: _entero(json, 'duracionSegundos'),
      distanciaMetros: _decimal(json, 'distanciaMetros'),
      velocidadMaximaKmh: _decimal(json, 'velocidadMaximaKmh'),
      ruta: (json['ruta'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          // Los paseos guardados antes de tener backend no traen la hora de
          // cada punto; se les pone la de inicio para poder dibujarlos igual.
          .map((p) => RoutePoint.fromJson(p, fallbackTimestamp: fechaInicio))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'fechaInicio': _iso(fechaInicio),
        'fechaFin': _iso(fechaFin),
        'duracionSegundos': duracionSegundos,
        'distanciaMetros': distanciaMetros,
        'velocidadMaximaKmh': velocidadMaximaKmh,
        'ruta': ruta.map((p) => p.toJson()).toList(growable: false),
      };

  Duration get duracion => Duration(seconds: duracionSegundos);
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

  /// "vacuna", "medicamento", "paseo", ...
  final String tipo;
  final String mascotaId;
  final DateTime fecha;
  final String mensaje;
  final bool completado;

  factory Recordatorio.fromJson(Map<String, dynamic> json) => Recordatorio(
        id: _texto(json, 'id'),
        tipo: _texto(json, 'tipo'),
        mascotaId: _texto(json, 'mascotaId'),
        fecha: _fecha(json, 'fecha'),
        mensaje: _texto(json, 'mensaje'),
        completado: json['completado'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'mascotaId': mascotaId,
        'fecha': _iso(fecha),
        'mensaje': mensaje,
        'completado': completado,
      };
}
