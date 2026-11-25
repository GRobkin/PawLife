// services/error_log.dart
//
// Guarda el último error inesperado para enseñarlo en pantalla. En un APK de
// prueba, un fallo que no llega a ninguna pantalla (por ejemplo, algo que
// revienta al abrir la sesión) dejaba la app "sin hacer nada" y sin pista de
// la causa. Con esto el motivo queda a la vista y se puede copiar o mandar en
// una captura.

import 'package:flutter/foundation.dart';

class ErrorLog {
  ErrorLog._();

  /// Texto corto del último error, o null si no hay ninguno que mostrar.
  static final ValueNotifier<String?> last = ValueNotifier<String?>(null);

  static const int _maxLength = 400;

  /// Anota un error. [contexto] dice dónde pasó (por ejemplo "sesión").
  static void report(Object error, StackTrace? stack, {String? contexto}) {
    final tipo = error.runtimeType;
    var detalle = error.toString().replaceAll('\n', ' ').trim();
    if (detalle.length > _maxLength) {
      detalle = '${detalle.substring(0, _maxLength)}…';
    }
    final donde = contexto == null ? '' : '[$contexto] ';
    last.value = '$donde$tipo: $detalle';
    debugPrint('ErrorLog $donde$tipo: $detalle');
    if (stack != null) {
      debugPrint(stack.toString().split('\n').take(6).join('\n'));
    }
  }

  static void clear() => last.value = null;

  /// Engancha los dos puntos por donde se cuelan los errores que nadie captura:
  /// los del framework de Flutter y los asíncronos de la plataforma.
  static void install() {
    final anterior = FlutterError.onError;
    FlutterError.onError = (details) {
      // Una imagen que no carga no es motivo para tapar la pantalla.
      if (!details.silent && details.library != 'image resource service') {
        report(details.exception, details.stack, contexto: 'Flutter');
      }
      anterior?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack, contexto: 'plataforma');
      return true;
    };
  }
}
