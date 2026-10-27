import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/pawlife_repository.dart';

class _User implements User {
  _User(this.uid);
  @override
  final String uid;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements AuthService {
  @override
  User? currentUser = _User('owner');
  @override
  Future<String> idToken({bool forceRefresh = false}) async => 'test-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  ApiClient client(
    Future<http.Response> Function(http.Request) handler, {
    _Auth? auth,
  }) {
    final api = ApiClient(
      auth: auth ?? _Auth(),
      httpClient: MockClient(handler),
    );
    addTearDown(api.close);
    return api;
  }

  test(
    'recorre páginas conservando filtros y cursor, sin inventar total',
    () async {
      var calls = 0;
      final api = client((request) async {
        expect(request.url.path, '/api/pesos');
        expect(request.url.queryParameters['mascotaId'], 'pet');
        expect(request.url.queryParameters['pageSize'], '100');
        calls++;
        expect(request.url.queryParameters['cursor'], calls == 1 ? null : 'a');
        return http.Response(
          jsonEncode({
            'items': [
              {'id': calls == 1 ? 'a' : 'b'},
            ],
            'nextCursor': calls == 1 ? 'a' : null,
          }),
          200,
        );
      });
      expect(await api.getList('/api/pesos', query: {'mascotaId': 'pet'}), [
        {'id': 'a'},
        {'id': 'b'},
      ]);
      expect(calls, 2);
    },
  );

  test('respeta límite explícito sin pedir otra página', () async {
    var calls = 0;
    final api = client((_) async {
      calls++;
      return http.Response(
        '{"items":[{"id":"a"},{"id":"b"}],"nextCursor":"b"}',
        200,
      );
    });
    expect(await api.getList('/api/pesos', query: {'limit': '1'}), [
      {'id': 'a'},
    ]);
    expect(calls, 1);
  });

  test(
    'un fallo de segunda página no devuelve un listado incompleto',
    () async {
      var calls = 0;
      final api = client(
        (_) async => ++calls == 1
            ? http.Response('{"items":[{"id":"a"}],"nextCursor":"a"}', 200)
            : http.Response('{"error":{"message":"Error"}}', 503),
      );
      await expectLater(
        api.getList('/api/pesos'),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 2);
    },
  );

  test('rechaza cursores repetidos', () async {
    var calls = 0;
    final api = client((_) async {
      calls++;
      return http.Response('{"items":[{"id":"a"}],"nextCursor":"a"}', 200);
    });
    await expectLater(api.getList('/api/pesos'), throwsA(isA<ApiException>()));
    expect(calls, 2);
  });

  test('descarta página si cambia la cuenta durante la petición', () async {
    final auth = _Auth();
    final api = client((_) async {
      auth.currentUser = _User('another');
      return http.Response('{"items":[{"id":"a"}]}', 200);
    }, auth: auth);
    await expectLater(api.getList('/api/pesos'), throwsA(isA<ApiException>()));
  });

  test('acepta servidor anterior sin nextCursor', () async {
    final api = client(
      (_) async => http.Response('{"items":[{"id":"a"}]}', 200),
    );
    expect(await api.getList('/api/pesos'), [
      {'id': 'a'},
    ]);
  });

  test(
    'registro reintenta conflicto de versión sin token en URL ni id elegido por cliente',
    () async {
      var calls = 0;
      final api = client((request) async {
        calls++;
        expect(request.method, 'POST');
        expect(request.url.path, '/api/me/devices');
        expect(request.url.query, isEmpty);
        expect(jsonDecode(request.body), {
          'token': 'private:token',
          'plataforma': 'android',
        });
        return calls == 1
            ? http.Response('{"error":{"code":"CONFLICT"}}', 409)
            : http.Response('{}', 200);
      });
      await PawLifeRepository(
        client: api,
      ).registrarDispositivo(token: 'private:token', plataforma: 'android');
      expect(calls, 2);
    },
  );

  for (final status in [404, 409]) {
    test(
      'registro $status no usa ruta antigua ni reasigna token ajeno',
      () async {
        var calls = 0;
        final api = client((request) async {
          calls++;
          expect(request.url.path, '/api/me/devices');
          return http.Response(
            '{"error":{"code":"DEVICE_OWNERSHIP_CONFLICT"}}',
            status,
          );
        });
        await expectLater(
          PawLifeRepository(
            client: api,
          ).registrarDispositivo(token: 'private', plataforma: 'android'),
          throwsA(isA<ApiException>()),
        );
        expect(calls, 1);
      },
    );
  }

  for (final status in [200, 404, 503]) {
    test('revocación $status usa cuerpo y propaga fallos reales', () async {
      final api = client((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/me/devices/revoke');
        expect(request.url.query, isEmpty);
        expect(jsonDecode(request.body), {'token': 'private:token'});
        return http.Response(
          status == 200 ? '{"revocado":true}' : '{"error":{"message":"Error"}}',
          status,
        );
      });
      final operation = PawLifeRepository(
        client: api,
      ).eliminarDispositivo('private:token');
      if (status == 200) {
        await operation;
      } else {
        await expectLater(operation, throwsA(isA<ApiException>()));
      }
    });
  }
}
