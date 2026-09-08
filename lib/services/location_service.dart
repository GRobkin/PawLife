// services/location_service.dart
//
// Capa de "servicio": aísla toda la dependencia del paquete `geolocator`.
// El ViewModel habla con esta clase, nunca directamente con Geolocator.
// Esto permite, por ejemplo, mockear el servicio en tests del ViewModel.

import 'package:geolocator/geolocator.dart';

/// Resultado de verificar permisos/servicio de ubicación.
enum LocationAccessStatus {
  granted,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationService {
  /// Verifica servicio de GPS + permisos, pidiéndolos si hace falta.
  Future<LocationAccessStatus> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationAccessStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationAccessStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationAccessStatus.permissionDeniedForever;
    }

    return LocationAccessStatus.granted;
  }

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Stream de posiciones. `distanceFilter` evita emitir puntos cuando
  /// el usuario está quieto (ruido de GPS).
  Stream<Position> watchPosition({int distanceFilterMeters = 5}) {
    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  double distanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
