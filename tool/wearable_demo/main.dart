// Demo del reloj para probarlo en el navegador (W5), sin Firebase ni GPS.
//
//   flutter run -d chrome -t tool/wearable_demo/main.dart
//
// Usa un paseo simulado: el tiempo corre, se puede pausar y terminar, y el
// "guardado" no sale de la página.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/views/wearable/wearable_controller.dart';
import 'package:pawlife/views/wearable/wearable_screen.dart';

class PaseoSimulado extends ChangeNotifier implements WearablePaseo {
  Timer? _timer;
  Duration _tiempo = Duration.zero;
  bool _pausado = false;

  @override
  Future<String?> iniciar() async {
    _tiempo = Duration.zero;
    _pausado = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_pausado) return;
      _tiempo += const Duration(seconds: 1);
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
      distanceMeters: _tiempo.inSeconds * 1.3,
      duration: _tiempo,
      startedAt: DateTime.now().subtract(_tiempo),
    );
  }

  @override
  Duration get tiempo => _tiempo;
  @override
  double get distanciaMetros => _tiempo.inSeconds * 1.3;
  @override
  Listenable get cambios => this;
  @override
  void liberar() => _timer?.cancel();
}

void main() {
  const luna = Mascota(id: 'luna', nombre: 'Luna', especie: 'perro');
  final controlador = WearableController(
    paseo: PaseoSimulado(),
    cargarMascota: () async => luna,
    guardar: (_, _) async =>
        Future<void>.delayed(const Duration(milliseconds: 600)),
  )..preparar();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: WearableScreen(controller: controlador),
    ),
  );
}
