import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/services/error_log.dart';

void main() {
  tearDown(ErrorLog.clear);

  test('guarda el tipo, el mensaje y el lugar del error', () {
    ErrorLog.report(StateError('sin token'), null, contexto: 'sesión');

    final texto = ErrorLog.last.value!;
    expect(texto, contains('[sesión]'));
    expect(texto, contains('StateError'));
    expect(texto, contains('sin token'));
  });

  test('recorta los mensajes muy largos', () {
    ErrorLog.report(Exception('x' * 2000), null);

    expect(ErrorLog.last.value!.length, lessThan(500));
  });

  test('clear deja la franja sin error', () {
    ErrorLog.report(Exception('algo'), null);
    ErrorLog.clear();

    expect(ErrorLog.last.value, isNull);
  });

  test('install recoge los errores de Flutter que nadie captura', () {
    final anterior = FlutterError.onError;
    addTearDown(() => FlutterError.onError = anterior);

    ErrorLog.install();
    FlutterError.onError!(
      FlutterErrorDetails(exception: StateError('falla al abrir la sesión')),
    );

    expect(ErrorLog.last.value, contains('falla al abrir la sesión'));
  });

  test('install ignora las imágenes que no cargan', () {
    final anterior = FlutterError.onError;
    addTearDown(() => FlutterError.onError = anterior);

    ErrorLog.install();
    FlutterError.onError!(
      FlutterErrorDetails(
        exception: Exception('imagen rota'),
        library: 'image resource service',
      ),
    );

    expect(ErrorLog.last.value, isNull);
  });
}
