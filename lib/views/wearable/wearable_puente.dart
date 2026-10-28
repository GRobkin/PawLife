// Lado teléfono del reloj real (Wear OS) como control remoto.
//
// El teléfono sigue haciendo GPS, sesión y guardado. El reloj manda comandos
// y recibe el estado. Este archivo define el protocolo y el puente; el
// transporte concreto (Data Layer de Wear OS) se implementa aparte, en
// Android, y aún no existe: ver docs/PLAN_WEAR_OS.md.

import 'dart:async';

import 'wearable_controller.dart';

enum WearableComando { iniciar, pausar, reanudar, terminar, aceptar }

/// Lo que el reloj necesita pintar. Sin datos personales más allá del nombre
/// de la mascota activa.
class WearableEstadoMensaje {
  const WearableEstadoMensaje({
    required this.estado,
    required this.segundos,
    required this.distanciaMetros,
    this.mascota,
    this.error,
  });

  final WearableEstado estado;
  final int segundos;
  final double distanciaMetros;
  final String? mascota;
  final WearableError? error;

  Map<String, Object?> toJson() => {
    'v': 1,
    'estado': estado.name,
    'segundos': segundos,
    'distanciaMetros': distanciaMetros,
    'mascota': mascota,
    'error': error?.name,
  };

  /// Devuelve null si el mensaje no es de esta versión o está mal formado.
  static WearableEstadoMensaje? desdeJson(Object? datos) {
    if (datos is! Map || datos['v'] != 1) return null;
    final estado = WearableEstado.values.asNameMap()[datos['estado']];
    final segundos = datos['segundos'];
    final distancia = datos['distanciaMetros'];
    if (estado == null || segundos is! int || segundos < 0) return null;
    if (distancia is! num || distancia < 0) return null;
    final nombre = datos['mascota'];
    final error = datos['error'];
    return WearableEstadoMensaje(
      estado: estado,
      segundos: segundos,
      distanciaMetros: distancia.toDouble(),
      mascota: nombre is String ? nombre : null,
      error: error is String ? WearableError.values.asNameMap()[error] : null,
    );
  }
}

/// Canal con el reloj. Lo implementa la capa Android (Data Layer).
abstract class WearableTransporte {
  Stream<Map<String, Object?>> get comandos;
  Future<void> enviarEstado(Map<String, Object?> estado);
}

/// Conecta un [WearableController] del teléfono con un [WearableTransporte].
class WearablePuente {
  WearablePuente({required this.controller, required this.transporte}) {
    _suscripcion = transporte.comandos.listen(_alRecibir);
    controller.addListener(_publicar);
    _publicar();
  }

  final WearableController controller;
  final WearableTransporte transporte;
  late final StreamSubscription<Map<String, Object?>> _suscripcion;

  static WearableComando? comandoDe(Map<String, Object?> datos) {
    if (datos['v'] != 1) return null;
    return WearableComando.values.asNameMap()[datos['comando']];
  }

  Future<void> _alRecibir(Map<String, Object?> datos) async {
    final comando = comandoDe(datos);
    if (comando == null) return;
    switch (comando) {
      case WearableComando.iniciar:
        await controller.iniciar();
      case WearableComando.pausar:
        await controller.pausar();
      case WearableComando.reanudar:
        await controller.reanudar();
      case WearableComando.terminar:
        await controller.terminar();
      case WearableComando.aceptar:
        controller.aceptar();
    }
  }

  void _publicar() {
    final mensaje = WearableEstadoMensaje(
      estado: controller.estado,
      segundos: controller.estado == WearableEstado.terminado
          ? controller.tiempoFinal.inSeconds
          : controller.tiempo.inSeconds,
      distanciaMetros: controller.estado == WearableEstado.terminado
          ? controller.distanciaFinalM
          : controller.paseo.distanciaMetros,
      mascota: controller.mascota?.nombre,
      error: controller.error,
    );
    transporte.enviarEstado(mensaje.toJson()).catchError((_) {
      // Si el reloj no está al alcance, el paseo sigue en el teléfono.
    });
  }

  void liberar() {
    controller.removeListener(_publicar);
    _suscripcion.cancel();
  }
}
