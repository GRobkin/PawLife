// services/walk_task_handler.dart
//
// Este código corre DENTRO del foreground service (un isolate separado
// del isolate principal de la UI). Por eso no puede usar directamente
// el LocationService/ChangeNotifier del ViewModel — solo puede mandar
// datos "planos" (Map, String, num, etc.) de vuelta al isolate principal
// vía FlutterForegroundTask.sendDataToMain().
//
// El flujo es:
//   1. onStart(): se suscribe al stream de posición de Geolocator.
//   2. Cada vez que llega una posición nueva, la manda al isolate
//      principal como un Map {lat, lng, timestampMillis, accuracy}. El
//      filtrado de lecturas malas se hace allí (services/gps_point_filter.dart).
//   3. onDestroy(): cancela la suscripción cuando se detiene el servicio.

import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

// El callback SIEMPRE tiene que ser una función top-level o estática
// (no un método de instancia), porque se ejecuta en el isolate del
// servicio, que arranca "desde cero" sin el resto de tu app.
@pragma('vm:entry-point')
void startWalkTrackingCallback() {
  FlutterForegroundTask.setTaskHandler(WalkTaskHandler());
}

class WalkTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionSub;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // mismos 5 metros que usábamos antes
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((position) {
          // Actualiza el texto de la notificación (opcional, pero le da
          // feedback al usuario de que sigue registrando el paseo).
          FlutterForegroundTask.updateService(
            notificationText:
                'Lat: ${position.latitude.toStringAsFixed(4)}, '
                'Lng: ${position.longitude.toStringAsFixed(4)}',
          );

          FlutterForegroundTask.sendDataToMain({
            'lat': position.latitude,
            'lng': position.longitude,
            // La hora en que el GPS tomó la posición, no DateTime.now(). Con la
            // pantalla apagada Android entrega varias lecturas juntas: con
            // now() quedaban todas con la misma hora, y eso rompía tanto el
            // orden como el cálculo de saltos.
            'timestampMillis': position.timestamp.millisecondsSinceEpoch,
            // Radio de error en metros. Sin él no había forma de descartar las
            // lecturas malas, que eran las que cruzaban las cuadras.
            'accuracy': position.accuracy,
          });
        });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // No lo usamos: los datos ya nos llegan por el stream de posición,
    // no necesitamos un tick periódico aparte.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  @override
  void onReceiveData(Object data) {}

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}

  @override
  void onNotificationDismissed() {}
}
