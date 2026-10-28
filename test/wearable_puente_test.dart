import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/views/wearable/wearable_controller.dart';
import 'package:pawlife/views/wearable/wearable_puente.dart';

class _Paseo extends ChangeNotifier implements WearablePaseo {
  @override
  Future<String?> iniciar() async => null;
  @override
  void pausar() {}
  @override
  void reanudar() {}
  @override
  WalkSession terminar() => WalkSession(
    points: const [],
    distanceMeters: 900,
    duration: const Duration(minutes: 10),
    startedAt: DateTime(2026, 10, 28),
  );
  @override
  Duration get tiempo => const Duration(seconds: 42);
  @override
  double get distanciaMetros => 120;
  @override
  Listenable get cambios => this;
  @override
  void liberar() {}
}

class _Transporte implements WearableTransporte {
  final entrada = StreamController<Map<String, Object?>>();
  final enviados = <Map<String, Object?>>[];
  @override
  Stream<Map<String, Object?>> get comandos => entrada.stream;
  @override
  Future<void> enviarEstado(Map<String, Object?> estado) async =>
      enviados.add(estado);
}

void main() {
  const luna = Mascota(id: 'luna', nombre: 'Luna', especie: 'perro');
  late WearableController controller;
  late _Transporte transporte;
  late WearablePuente puente;

  setUp(() async {
    controller = WearableController(
      paseo: _Paseo(),
      cargarMascota: () async => luna,
      guardar: (_, _) async {},
      vibrar: () async {},
    );
    await controller.preparar();
    transporte = _Transporte();
    puente = WearablePuente(controller: controller, transporte: transporte);
  });

  tearDown(() {
    puente.liberar();
    controller.dispose();
  });

  Future<void> mandar(Map<String, Object?> datos) async {
    transporte.entrada.add(datos);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  test('publica el estado inicial con la mascota', () {
    final m = WearableEstadoMensaje.desdeJson(transporte.enviados.last)!;
    expect(m.estado, WearableEstado.reposo);
    expect(m.mascota, 'Luna');
  });

  test('los comandos del reloj mueven el paseo del teléfono', () async {
    await mandar({'v': 1, 'comando': 'iniciar'});
    expect(controller.estado, WearableEstado.enPaseo);
    await mandar({'v': 1, 'comando': 'pausar'});
    expect(controller.estado, WearableEstado.pausado);
    await mandar({'v': 1, 'comando': 'reanudar'});
    expect(controller.estado, WearableEstado.enPaseo);
    await mandar({'v': 1, 'comando': 'terminar'});
    expect(controller.estado, WearableEstado.terminado);
    final ultimo = WearableEstadoMensaje.desdeJson(transporte.enviados.last)!;
    expect(ultimo.estado, WearableEstado.terminado);
    expect(ultimo.segundos, 600);
    expect(ultimo.distanciaMetros, 900);
  });

  test('ignora comandos desconocidos o de otra versión', () async {
    await mandar({'v': 2, 'comando': 'iniciar'});
    await mandar({'v': 1, 'comando': 'borrarTodo'});
    await mandar({'comando': 'iniciar'});
    expect(controller.estado, WearableEstado.reposo);
  });

  test('rechaza estados mal formados', () {
    expect(WearableEstadoMensaje.desdeJson(null), isNull);
    expect(WearableEstadoMensaje.desdeJson({'v': 1, 'estado': 'x'}), isNull);
    expect(
      WearableEstadoMensaje.desdeJson({
        'v': 1,
        'estado': 'enPaseo',
        'segundos': -3,
        'distanciaMetros': 1,
      }),
      isNull,
    );
  });
}
