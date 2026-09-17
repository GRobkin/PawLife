// models/route_point.dart
//
// Modelo puro de datos: un punto capturado durante el paseo.
// No depende de Flutter ni de ningún paquete de mapas/GPS,
// para que sea fácil de testear y de serializar.
//
// Es también el formato en el que la API (../apipaw) devuelve la ruta de un
// paseo: una lista de {lat, lng, timestamp} con las fechas en ISO 8601.

class RoutePoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };

  /// [fallbackTimestamp] cubre los paseos guardados por la versión anterior de
  /// la app, cuando la ruta se escribía como lista de GeoPoint y no llevaba la
  /// hora de cada punto. Sin él esos paseos no se podrían ni abrir.
  factory RoutePoint.fromJson(
    Map<String, dynamic> json, {
    DateTime? fallbackTimestamp,
  }) {
    final lat = json['lat'] ?? json['latitude'];
    final lng = json['lng'] ?? json['longitude'];

    if (lat is! num || lng is! num) {
      throw const FormatException('El punto de la ruta no trae lat/lng.');
    }

    final rawTimestamp = json['timestamp'];
    final timestamp = rawTimestamp is String
        ? DateTime.parse(rawTimestamp).toLocal()
        : fallbackTimestamp;

    if (timestamp == null) {
      throw const FormatException('El punto de la ruta no trae timestamp.');
    }

    return RoutePoint(
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      timestamp: timestamp,
    );
  }
}

/// Resultado final de un paseo, listo para mandar al backend.
class WalkSession {
  final List<RoutePoint> points;
  final double distanceMeters;
  final Duration duration;
  final DateTime startedAt;

  /// Velocidad puntual más alta registrada durante el paseo, en km/h.
  /// Se calcula tramo a tramo en el ViewModel; no es la velocidad media.
  final double maxSpeedKmh;

  const WalkSession({
    required this.points,
    required this.distanceMeters,
    required this.duration,
    required this.startedAt,
    this.maxSpeedKmh = 0,
  });

  DateTime get endedAt => startedAt.add(duration);

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => p.toJson()).toList(),
        'distanceMeters': distanceMeters,
        'durationSeconds': duration.inSeconds,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'maxSpeedKmh': maxSpeedKmh,
      };
}
