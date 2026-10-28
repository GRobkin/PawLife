// services/api_client.dart
//
// Cliente HTTP de la API de PawLife (../apipaw, desplegada en Vercel).
//
// Se ocupa de lo que es igual en todas las llamadas: la URL base, meter el ID
// token de Firebase en la cabecera, decodificar el JSON y convertir los
// errores del backend en una excepción con un mensaje que se pueda enseñar.
// Los repositorios de arriba solo hablan de recursos.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Error devuelto por la API, ya traducido a algo mostrable.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  bool get requiresReauthentication => code == 'REAUTHENTICATION_REQUIRED';

  /// Errores de validación por campo, tal como los manda el backend en
  /// `error.details`. Sirve para marcar el campo concreto en un formulario.
  final Map<String, String>? fieldErrors;

  bool get isAuthError => statusCode == 401 || statusCode == 403;

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    AuthService? auth,
    http.Client? httpClient,
    String? baseUrl,
    this.expectedUid,
    this.timeout = const Duration(seconds: 20),
  }) : _auth = auth ?? AuthService(),
       _http = httpClient ?? http.Client(),
       baseUrl = _normalizeBaseUrl(baseUrl ?? defaultBaseUrl);

  /// URL del backend. Se fija al compilar para no tener que tocar código al
  /// cambiar de entorno:
  ///
  ///   flutter run --dart-define=PAWLIFE_API_URL=https://apipaw.vercel.app
  ///
  /// Contra un `php -S localhost:8000` hay que tener en cuenta que "localhost"
  /// dentro del emulador es el propio emulador: en Android hay que apuntar a
  /// http://10.0.2.2:8000 y en el simulador de iOS sí vale localhost.
  static const String defaultBaseUrl = String.fromEnvironment(
    'PAWLIFE_API_URL',
    defaultValue: 'https://apipaw.vercel.app',
  );

  final AuthService _auth;
  final String? expectedUid;
  final http.Client _http;
  final String baseUrl;
  final Duration timeout;

  static String _normalizeBaseUrl(String url) {
    final trimmed = url.trim().replaceAll(RegExp(r'/+$'), '');

    return trimmed.isEmpty ? defaultBaseUrl : trimmed;
  }

  /// GET de un listado. El backend responde {"items": [...], "total": n}.
  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final uid = _auth.currentUser?.uid;
    final all = <Map<String, dynamic>>[];
    final seen = <String>{};
    final requestedLimit = int.tryParse(query?['limit'] ?? '');
    String? cursor = query?['cursor'];
    var bytes = 0;
    for (var page = 0; page < 250; page++) {
      if (_auth.currentUser?.uid != uid) {
        throw const ApiException(
          'La sesión cambió.',
          code: 'client-session-changed',
        );
      }
      final body = await _send(
        'GET',
        path,
        query: {'pageSize': '100', ...?query, 'cursor': ?cursor},
      );
      if (_auth.currentUser?.uid != uid) {
        throw const ApiException(
          'La sesión cambió.',
          code: 'client-session-changed',
        );
      }
      final items = body is Map<String, dynamic> ? body['items'] : null;
      if (items is! List ||
          items.any((item) => item is! Map<String, dynamic>)) {
        throw const ApiException(
          'La respuesta del servidor no trae una lista válida.',
          code: 'client-invalid-response',
        );
      }
      bytes += utf8.encode(jsonEncode(items)).length;
      if (bytes > 8 * 1024 * 1024) {
        throw const ApiException(
          'El listado es demasiado grande para esta pantalla. No se mostraron resultados incompletos.',
          code: 'client-list-too-large',
        );
      }
      all.addAll(items.cast<Map<String, dynamic>>());
      if (requestedLimit != null &&
          requestedLimit > 0 &&
          all.length >= requestedLimit) {
        return all.take(requestedLimit).toList(growable: false);
      }
      final next = body['nextCursor'];
      if (next == null) return all;
      if (next is! String || next.isEmpty || !seen.add(next) || items.isEmpty) {
        throw const ApiException(
          'El servidor devolvió una página inválida. Reintentá cargar el listado.',
          code: 'client-invalid-response',
        );
      }
      cursor = next;
    }
    throw const ApiException(
      'El listado requiere demasiadas páginas. No se mostraron resultados incompletos.',
      code: 'client-list-too-large',
    );
  }

  Future<Map<String, dynamic>> getOne(
    String path, {
    Map<String, String>? query,
  }) async {
    return _expectObject(await _send('GET', path, query: query));
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _expectObject(await _send('POST', path, body: body));
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _expectObject(await _send('PATCH', path, body: body));
  }

  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  /// Como [delete], pero conserva el cuerpo de un 202 (operación en curso).
  Future<Map<String, dynamic>?> deleteWithStatus(String path) async {
    final body = await _send('DELETE', path);
    return body is Map<String, dynamic> ? body : null;
  }

  void close() => _http.close();

  Map<String, dynamic> _expectObject(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw const ApiException(
        'La respuesta del servidor no es un objeto.',
        code: 'client-invalid-response',
      );
    }

    return body;
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    // Un 401 puede ser simplemente un token caducado que el SDK aún daba por
    // bueno. Se reintenta una vez forzando refresco antes de dar error: si
    // vuelve a fallar, el problema es otro.
    var forceRefresh = false;

    while (true) {
      final response = await _perform(
        method,
        path,
        query: query,
        body: body,
        forceRefresh: forceRefresh,
      );

      if (response.statusCode == 401 && !forceRefresh) {
        try {
          _decode(response);
        } on ApiException catch (error) {
          // Refrescar el token no cambia auth_time: una operación sensible
          // necesita reautenticación y no debe repetirse automáticamente.
          if (error.requiresReauthentication) rethrow;
        }
        forceRefresh = true;
        continue;
      }

      return _decode(response);
    }
  }

  Future<http.Response> _perform(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    required bool forceRefresh,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);

    if (expectedUid != null && _auth.currentUser?.uid != expectedUid) {
      throw const ApiException(
        'La sesion cambio.',
        code: 'client-session-changed',
      );
    }
    final token = await _auth.idToken(forceRefresh: forceRefresh);
    if (expectedUid != null && _auth.currentUser?.uid != expectedUid) {
      throw const ApiException(
        'La sesion cambio.',
        code: 'client-session-changed',
      );
    }

    final request = http.Request(method, uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }

    try {
      // El límite incluye el cuerpo: recibir las cabeceras no garantiza que
      // el servidor termine de transmitir la respuesta.
      return await _http
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
    } on TimeoutException {
      throw ApiException(
        'El servidor tardó demasiado en responder (${timeout.inSeconds} s).',
        code: 'client-timeout',
      );
    } on SocketException {
      throw const ApiException(
        'No hay conexión con el servidor. Comprueba tu conexión a internet.',
        code: 'client-offline',
      );
    } on http.ClientException catch (e) {
      throw ApiException('Fallo de red: ${e.message}', code: 'client-offline');
    }
  }

  dynamic _decode(http.Response response) {
    final status = response.statusCode;

    // 204 y cualquier respuesta vacía: no hay nada que decodificar.
    if (status == 204 || response.bodyBytes.isEmpty) {
      if (status >= 400) {
        throw ApiException(
          'El servidor respondió $status.',
          statusCode: status,
          code: 'client-http-status',
        );
      }

      return null;
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      // Suele pasar cuando Vercel devuelve su propia página de error HTML en
      // vez de una respuesta de la API: mejor decirlo que enseñar el HTML.
      throw ApiException(
        'El servidor devolvió una respuesta que no es JSON (código $status).',
        statusCode: status,
        code: 'client-invalid-response',
      );
    }

    if (status >= 200 && status < 300) {
      return decoded;
    }

    throw _errorFrom(status, decoded);
  }

  ApiException _errorFrom(int status, dynamic decoded) {
    final error = decoded is Map<String, dynamic> ? decoded['error'] : null;

    if (error is! Map<String, dynamic>) {
      return ApiException(
        'El servidor respondió $status.',
        statusCode: status,
        code: 'client-http-status',
      );
    }

    final details = error['details'];
    final fieldErrors = details is Map<String, dynamic>
        ? details.map((key, value) => MapEntry(key, value.toString()))
        : null;

    return ApiException(
      error['message']?.toString() ?? 'El servidor respondió $status.',
      statusCode: status,
      fieldErrors: fieldErrors,
      code: error['code'] is String ? error['code'] as String : null,
    );
  }
}
