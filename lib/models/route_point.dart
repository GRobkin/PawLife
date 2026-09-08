// models/route_point.dart
//
// Modelo puro de datos: un punto capturado durante el paseo.
// No depende de Flutter ni de ningún paquete de mapas/GPS,
// para que sea fácil de testear y de serializar (guardar en backend).

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
        'timestamp': timestamp.toIso8601String(),
      };

  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
        latitude: json['lat'] as double,
        longitude: json['lng'] as double,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// Resultado final de un paseo, listo para persistir en el backend.
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
        'startedAt': startedAt.toIso8601String(),
        'maxSpeedKmh': maxSpeedKmh,
      };
}
