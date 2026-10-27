import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';

class _Auth implements AuthService {
  @override
  Null get currentUser => null;
  @override
  Future<String> idToken({bool forceRefresh = false}) async => 'test-token';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StalledBodyClient extends http.BaseClient {
  final body = StreamController<List<int>>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(body.stream, 200);

  @override
  void close() {
    unawaited(body.close());
    super.close();
  }
}

void main() {
  test(
    'la API conserva el código de reauth y no repite la operación sensible',
    () async {
      var calls = 0;
      final api = ApiClient(
        auth: _Auth(),
        httpClient: MockClient((_) async {
          calls++;
          return http.Response(
            '{"error":{"code":"REAUTHENTICATION_REQUIRED","message":"Confirmar identidad"}}',
            401,
          );
        }),
      );
      addTearDown(api.close);
      await expectLater(
        api.delete('/api/me'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.requiresReauthentication,
            'reauth',
            isTrue,
          ),
        ),
      );
      expect(calls, 1);
    },
  );
  test('deleteWithStatus conserva el 202 y devuelve null en 204', () async {
    final responses = [
      http.Response('{"estado":"pendiente","fase":"roots"}', 202),
      http.Response('', 204),
    ];
    final api = ApiClient(
      auth: _Auth(),
      httpClient: MockClient((_) async => responses.removeAt(0)),
    );
    addTearDown(api.close);
    expect((await api.deleteWithStatus('/api/me'))?['estado'], 'pendiente');
    expect(await api.deleteWithStatus('/api/me'), isNull);
  });
  test(
    'la espera del cuerpo también vence aunque lleguen las cabeceras',
    () async {
      final transport = _StalledBodyClient();
      final api = ApiClient(
        auth: _Auth(),
        httpClient: transport,
        timeout: const Duration(milliseconds: 30),
      );
      addTearDown(api.close);

      await expectLater(
        api.getOne('/api/me').timeout(const Duration(seconds: 2)),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'mensaje',
            contains('tardó demasiado'),
          ),
        ),
      );
    },
  );
}
