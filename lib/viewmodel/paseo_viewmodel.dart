import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/pawlife_models.dart';

class PaseoViewModel extends ChangeNotifier {
  PaseoViewModel({required this.mascotaId});

  final String mascotaId;

  StreamSubscription<Position>? _sub;
  final List<LatLng> puntos = [];
  LatLng? posicionActual;

  bool tracking = false;
  DateTime? inicio;
  double distanciaMetros = 0;
  double velocidadMaximaKmh = 0;

  Future<void> ubicarme() async {
    if (!await _tienePermiso()) return;
    final pos = await Geolocator.getCurrentPosition();
    posicionActual = LatLng(pos.latitude, pos.longitude);
    notifyListeners();
  }

  Future<bool> _tienePermiso() async {
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    return permiso == LocationPermission.always ||
        permiso == LocationPermission.whileInUse;
  }

  Future<void> iniciarPaseo() async {
    if (!await _tienePermiso()) return;

    tracking = true;
    inicio = DateTime.now();
    puntos.clear();
    distanciaMetros = 0;
    velocidadMaximaKmh = 0;
    notifyListeners();

    const config = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
    _sub = Geolocator.getPositionStream(locationSettings: config).listen(_onPosicion);
  }

  void _onPosicion(Position pos) {
    final punto = LatLng(pos.latitude, pos.longitude);

    if (puntos.isNotEmpty) {
      distanciaMetros += Geolocator.distanceBetween(
        puntos.last.latitude,
        puntos.last.longitude,
        punto.latitude,
        punto.longitude,
      );
    }

    final velocidadKmh = pos.speed * 3.6;
    if (velocidadKmh > velocidadMaximaKmh) velocidadMaximaKmh = velocidadKmh;

    puntos.add(punto);
    posicionActual = punto;
    notifyListeners();
  }

  Future<void> terminarPaseo() async {
    await _sub?.cancel();
    tracking = false;
    notifyListeners();

    if (puntos.length < 2) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final paseo = Paseo(
      id: '',
      fechaInicio: inicio!,
      fechaFin: DateTime.now(),
      duracionSegundos: DateTime.now().difference(inicio!).inSeconds,
      distanciaMetros: distanciaMetros,
      velocidadMaximaKmh: velocidadMaximaKmh,
      ruta: puntos.map((p) => GeoPoint(p.latitude, p.longitude)).toList(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('mascotas')
        .doc(mascotaId)
        .collection('paseos')
        .add(paseo.toMap());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
