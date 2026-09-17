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
  const ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;

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
    this.timeout = const Duration(seconds: 20),
  })  : _auth = auth ?? AuthService(),
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
    final body = await _send('GET', path, query: query);
    final items = body is Map<String, dynamic> ? body['items'] : null;

    if (items is! List) {
      throw const ApiException('La respuesta del servidor no trae una lista.');
    }

    return items.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> getOne(String path) async {
    return _expectObject(await _send('GET', path));
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

  void close() => _http.close();

  Map<String, dynamic> _expectObject(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw const ApiException('La respuesta del servidor no es un objeto.');
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
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );

    final token = await _auth.idToken(forceRefresh: forceRefresh);

    final request = http.Request(method, uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }

    try {
      final streamed = await _http.send(request).timeout(timeout);

      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException(
        'El servidor tardó demasiado en responder (${timeout.inSeconds} s).',
      );
    } on SocketException {
      throw const ApiException(
        'No hay conexión con el servidor. Comprueba tu conexión a internet.',
      );
    } on http.ClientException catch (e) {
      throw ApiException('Fallo de red: ${e.message}');
    }
  }

  dynamic _decode(http.Response response) {
    final status = response.statusCode;

    // 204 y cualquier respuesta vacía: no hay nada que decodificar.
    if (status == 204 || response.bodyBytes.isEmpty) {
      if (status >= 400) {
        throw ApiException('El servidor respondió $status.', statusCode: status);
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
      return ApiException('El servidor respondió $status.', statusCode: status);
    }

    final details = error['details'];
    final fieldErrors = details is Map<String, dynamic>
        ? details.map((key, value) => MapEntry(key, value.toString()))
        : null;

    return ApiException(
      error['message']?.toString() ?? 'El servidor respondió $status.',
      statusCode: status,
      fieldErrors: fieldErrors,
    );
  }
}
