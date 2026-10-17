import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';

class _Auth implements AuthService {
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
