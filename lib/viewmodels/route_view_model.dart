// viewmodels/route_view_model.dart
//
// ViewModel: expone estado observable a la View (vía ChangeNotifier)
// y contiene toda la lógica de la pantalla.
//
// El tracking del paseo ahora corre dentro de un foreground service
// (ver services/walk_task_handler.dart), para que siga funcionando con
// la pantalla apagada o la app minimizada. Los puntos GPS llegan acá
// por el canal de comunicación de flutter_foreground_task, no por un
// stream directo de geolocator en este isolate.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_point.dart';
import '../services/location_service.dart';
import '../services/walk_task_handler.dart';

enum RouteScreenStatus { loading, error, ready }

class RouteViewModel extends ChangeNotifier {
  RouteViewModel({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  final LocationService _locationService;

  // ---- Estado expuesto a la View ----
  RouteScreenStatus status = RouteScreenStatus.loading;
  String? errorMessage;

  LatLng? currentPosition;
  final List<LatLng> routePoints = [];
  final List<RoutePoint> _rawPoints = [];

  bool isTracking = false;
  double distanceMeters = 0;
  Duration elapsed = Duration.zero;

  /// Velocidad puntual más alta del paseo, calculada tramo a tramo.
  double maxSpeedKmh = 0;

  Timer? _ticker;
  DateTime? _startedAt;

  /// Callback opcional que la View puede usar para recentrar/mover el mapa
  /// cada vez que llega un punto nuevo.
  void Function(LatLng point)? onNewPoint;

  // -----------------------------------------------------------------
  // Inicialización: permisos + ubicación actual
  // -----------------------------------------------------------------
  Future<void> init() async {
    status = RouteScreenStatus.loading;
    errorMessage = null;
    notifyListeners();

    final access = await _locationService.ensurePermission();

    switch (access) {
      case LocationAccessStatus.serviceDisabled:
        _fail('El GPS está desactivado. Activalo para continuar.');
        return;
      case LocationAccessStatus.permissionDenied:
        _fail('Permiso de ubicación denegado.');
        return;
      case LocationAccessStatus.permissionDeniedForever:
        _fail(
          'Permiso denegado permanentemente. Habilitalo desde ajustes del sistema.',
        );
        return;
      case LocationAccessStatus.granted:
        break;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      currentPosition = LatLng(position.latitude, position.longitude);
      status = RouteScreenStatus.ready;
      notifyListeners();

      await startWalk();
    } catch (e) {
      _fail('No se pudo obtener la ubicación: $e');
    }
  }

  void _fail(String message) {
    status = RouteScreenStatus.error;
    errorMessage = message;
    notifyListeners();
  }

  // -----------------------------------------------------------------
  // Iniciar / detener paseo (ahora vía foreground service)
  // -----------------------------------------------------------------
  Future<void> startWalk() async {
    routePoints.clear();
    _rawPoints.clear();
    distanceMeters = 0;
    maxSpeedKmh = 0;
    elapsed = Duration.zero;
    _startedAt = DateTime.now();
    isTracking = true;
    notifyListeners();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startedAt != null) {
        elapsed = DateTime.now().difference(_startedAt!);
        notifyListeners();
      }
    });

    await _requestForegroundServicePermissions();
    _initForegroundService();

    FlutterForegroundTask.addTaskDataCallback(_onTaskData);

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Paseo en curso',
        notificationText: 'PawLife está registrando tu ruta',
        callback: startWalkTrackingCallback,
      );
    }
  }

  /// Detiene el paseo y devuelve la sesión lista para enviar al backend.
  WalkSession stopWalk() {
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    FlutterForegroundTask.stopService();
    _ticker?.cancel();
    isTracking = false;
    notifyListeners();

    return WalkSession(
      points: List.of(_rawPoints),
      distanceMeters: distanceMeters,
      duration: elapsed,
      startedAt: _startedAt ?? DateTime.now(),
      maxSpeedKmh: maxSpeedKmh,
    );
  }

  // -----------------------------------------------------------------
  // Datos que llegan desde el TaskHandler (isolate del servicio)
  // -----------------------------------------------------------------
  void _onTaskData(Object data) {
    if (data is! Map) return;

    final lat = data['lat'] as double?;
    final lng = data['lng'] as double?;
    if (lat == null || lng == null) return;

    final newPoint = LatLng(lat, lng);

    // El TaskHandler manda el momento exacto de la lectura. Lo usamos en
    // vez de DateTime.now() porque el dato puede llegar con retraso desde
    // el isolate del servicio, y eso falsearía la velocidad del tramo.
    final millis = data['timestampMillis'] as int?;
    final timestamp = millis != null
        ? DateTime.fromMillisecondsSinceEpoch(millis)
        : DateTime.now();

    if (routePoints.isNotEmpty) {
      final last = routePoints.last;
      final segmentMeters = _locationService.distanceBetween(
        last.latitude,
        last.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
      distanceMeters += segmentMeters;
      _updateMaxSpeed(segmentMeters, timestamp);
    }

    routePoints.add(newPoint);
    _rawPoints.add(RoutePoint(
      latitude: lat,
      longitude: lng,
      timestamp: timestamp,
    ));
    currentPosition = newPoint;

    onNewPoint?.call(newPoint);
    notifyListeners();
  }

  /// Actualiza la velocidad máxima con el tramo recién recorrido.
  ///
  /// Descartamos tramos de menos de un segundo (dividir por un intervalo
  /// diminuto dispara la velocidad a valores absurdos) y los que dan más
  /// de 30 km/h, que a pie solo puede ser un salto de precisión del GPS.
  void _updateMaxSpeed(double segmentMeters, DateTime timestamp) {
    final previous = _rawPoints.isNotEmpty ? _rawPoints.last.timestamp : null;
    if (previous == null) return;

    final seconds = timestamp.difference(previous).inMilliseconds / 1000;
    if (seconds < 1) return;

    final kmh = (segmentMeters / 1000) / (seconds / 3600);
    if (kmh > 30) return;
    if (kmh > maxSpeedKmh) maxSpeedKmh = kmh;
  }

  // -----------------------------------------------------------------
  // Setup del foreground service
  // -----------------------------------------------------------------
  Future<void> _requestForegroundServicePermissions() async {
    // Android 13+: hace falta permiso explícito para mostrar la
    // notificación persistente del servicio.
    final notifPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notifPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pawlife_walk_channel',
        channelName: 'Paseo en curso',
        channelDescription:
            'Se muestra mientras PawLife está registrando un paseo.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  String get formattedDistance =>
      '${(distanceMeters / 1000).toStringAsFixed(2)} km';

  String get formattedElapsed {
    final h = elapsed.inHours.toString().padLeft(2, '0');
    final m = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  double get averageSpeedKmh {
    if (elapsed.inSeconds == 0) return 0;
    return (distanceMeters / 1000) / (elapsed.inSeconds / 3600);
  }

  String get formattedSpeed => '${averageSpeedKmh.toStringAsFixed(1)} km/h';

  /// NOTA: estimación aproximada, no un cálculo real basado en peso/edad
  /// (ver US27 en el backlog, marcada "Won't have for now").
  double get estimatedCalories => (distanceMeters / 1000) * 60;

  String get formattedCalories => '${estimatedCalories.round()} kcal';

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    _ticker?.cancel();
    super.dispose();
  }
}
