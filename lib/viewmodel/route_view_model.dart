import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawlife/model/pawlife_models.dart';
import 'package:pawlife/services/location_service.dart';

enum RouteScreenStatus { initial, ready, loading, tracking, paused, error }

class RouteViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final String? mascotaId;

  RouteScreenStatus status = RouteScreenStatus.ready;
  List<LatLng> routePoints = [];
  bool isTracking = false;
  double totalDistanceMeters = 0;
  double maxSpeedKmh = 0;
  DateTime? startTime;
  LatLng? currentPosition;

  RouteViewModel({this.mascotaId});

  Future<void> init() async {
    final statusPermission = await _locationService.ensurePermission();
    if (statusPermission == LocationAccessStatus.granted) {
      final pos = await _locationService.getCurrentPosition();
      currentPosition = LatLng(pos.latitude, pos.longitude);
    }
    _initForegroundListener();
    notifyListeners();
  }

  void _initForegroundListener() {
    FlutterForegroundTask.addTaskDataCallback((data) {
      if (data is Map<String, dynamic>) {
        final double lat = data['lat'];
        final double lng = data['lng'];
        _onNewPosition(LatLng(lat, lng));
      }
    });
  }

  void startTracking() {
    isTracking = true;
    status = RouteScreenStatus.tracking;
    routePoints.clear();
    totalDistanceMeters = 0;
    maxSpeedKmh = 0;
    startTime = DateTime.now();
    notifyListeners();
  }

  void _onNewPosition(LatLng newPos) {
    if (currentPosition != null && isTracking) {
      totalDistanceMeters += _locationService.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        newPos.latitude,
        newPos.longitude,
      );
    }
    currentPosition = newPos;
    if (isTracking) {
      routePoints.add(newPos);
    }
    notifyListeners();
  }

  Paseo stopWalk() {
    isTracking = false;
    status = RouteScreenStatus.ready;
    
    final now = DateTime.now();
    final durationSeconds = startTime != null ? now.difference(startTime!).inSeconds : 0;
    
    final geoPoints = routePoints
        .map((p) => GeoPoint(p.latitude, p.longitude))
        .toList();

    final paseo = Paseo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fechaInicio: startTime ?? now,
      fechaFin: now,
      duracionSegundos: durationSeconds,
      distanciaMetros: totalDistanceMeters,
      velocidadMaximaKmh: maxSpeedKmh,
      ruta: geoPoints,
    );

    _savePaseoToFirebase(paseo);
    notifyListeners();
    return paseo;
  }

  Future<void> _savePaseoToFirebase(Paseo paseo) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      debugPrint('--- STARTING WALK SAVE ---');
      debugPrint('User UID: ${user?.uid}');
      debugPrint('Pet ID: $mascotaId');

      if (user == null) {
        debugPrint('ERROR: No authenticated user found.');
        return;
      }

      if (mascotaId == null) {
        debugPrint('ERROR: mascotaId was not provided to RouteViewModel.');
        return;
      }

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mascotas')
          .doc(mascotaId)
          .collection('paseos')
          .add(paseo.toMap());

      debugPrint('SUCCESS: Walk saved in Firestore with ID: ${docRef.id}');
    } catch (e, stack) {
      debugPrint('EXCEPTION SAVING TO FIREBASE: $e');
      debugPrint(stack.toString());
    }
  }

  String get formattedElapsed {
    if (startTime == null) return "00:00";
    final diff = DateTime.now().difference(startTime!);
    final min = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  String get formattedDistance => (totalDistanceMeters / 1000).toStringAsFixed(2);
}
