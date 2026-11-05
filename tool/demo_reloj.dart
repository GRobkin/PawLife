// Demostración del reloj sin iniciar sesión ni GPS: un paseo simulado que
// cuenta segundos de verdad, para ver el bisel animado en el navegador.
//
//   flutter run -d web-server --web-port 5006 -t tool/demo_reloj.dart
//
// No toca la API ni Firebase: todo es en memoria.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/wearable/wearable_controller.dart';
import 'package:pawlife/views/wearable/wearable_screen.dart';

/// Paseo falso: el cronómetro avanza un segundo por segundo mientras no esté
/// en pausa.
class PaseoDemo extends ChangeNotifier implements WearablePaseo {
  Duration _t = Duration.zero;
  Timer? _timer;
  bool _pausado = false;

  @override
  Future<String?> iniciar() async {
    _t = Duration.zero;
    _pausado = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_pausado) return;
      _t += const Duration(seconds: 1);
      notifyListeners();
    });
    return null;
  }

  @override
  void pausar() => _pausado = true;

  @override
  void reanudar() => _pausado = false;

  @override
  WalkSession terminar() {
    _timer?.cancel();
    return WalkSession(
      points: const [],
      distanceMeters: 1250,
      duration: _t,
      startedAt: DateTime.now().subtract(_t),
    );
  }

  @override
  Duration get tiempo => _t;

  @override
  double get distanciaMetros => 1250;

  @override
  Listenable get cambios => this;

  @override
  void liberar() => _timer?.cancel();
}

const _mascotas = [
  Mascota(id: 'luna', nombre: 'Luna', especie: 'perro'),
  Mascota(id: 'milo', nombre: 'Milo', especie: 'gato'),
  Mascota(id: 'kira', nombre: 'Kira', especie: 'perro'),
];

void main() {
  final controlador = WearableController(
    paseo: PaseoDemo(),
    cargarMascotas: () async => _mascotas,
    cargarMascota: () async => _mascotas.first,
    guardar: (id, sesion) =>
        Future<void>.delayed(const Duration(milliseconds: 700)),
    vibrar: () async {},
  )..preparar();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      theme: AppTheme.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: WearableScreen(controller: controlador, animarBisel: true),
    ),
  );
}
