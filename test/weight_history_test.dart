import 'package:pawlife/l10n/app_localizations.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/views/weight_history_screen.dart';

class AuthStub implements AuthService {
  @override
  Null get currentUser => null;
  @override
  Future<String> idToken({bool forceRefresh = false}) async => 'test-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const pet = Mascota(id: 'luna', nombre: 'Luna', especie: 'perro');

void main() {
  test(
    'historial ordena por fecha y desempata por id sin perder decimales',
    () async {
      final client = ApiClient(
        auth: AuthStub(),
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'items': [
                {'id': 'a', 'fecha': '2026-01-01T00:00:00Z', 'valorKg': 2.75},
                {'id': 'b', 'fecha': '2026-01-02T00:00:00Z', 'valorKg': 3.15},
                {'id': 'c', 'fecha': '2026-01-02T00:00:00Z', 'valorKg': 3.25},
              ],
            }),
            200,
          ),
        ),
      );
      addTearDown(client.close);
      final records = await PawLifeRepository(
        client: client,
      ).fetchPesos('luna');
      expect(records.map((e) => e.id), ['c', 'b', 'a']);
      expect(records.first.valorKg, 3.25);
    },
  );

  test(
    'respuesta perdida de un peso recupera el mismo registro con precisión ms',
    () async {
      final fecha = DateTime.parse('2026-01-01T00:00:00.123456Z');
      final client = ApiClient(
        auth: AuthStub(),
        httpClient: MockClient((request) async {
          if (request.method == 'POST') {
            final body = jsonDecode(request.body);
            expect(body['fecha'], '2026-01-01T00:00:00.123Z');
            expect(body['id'], 'estable');
            return http.Response('{"error":{"message":"duplicado"}}', 409);
          }
          return http.Response(
            jsonEncode({
              'id': 'estable',
              'fecha': '2026-01-01T00:00:00.123Z',
              'valorKg': 4.5,
            }),
            200,
          );
        }),
      );
      addTearDown(client.close);
      final saved = await PawLifeRepository(
        client: client,
      ).createPeso('luna', id: 'estable', fecha: fecha, valorKg: 4.5);
      expect(saved.id, 'estable');
    },
  );

  test('un conflicto con otro peso no se presenta como guardado', () async {
    final client = ApiClient(
      auth: AuthStub(),
      httpClient: MockClient(
        (request) async => request.method == 'POST'
            ? http.Response('{"error":{"message":"duplicado"}}', 409)
            : http.Response(
                jsonEncode({
                  'id': 'estable',
                  'fecha': '2026-01-01T00:00:00Z',
                  'valorKg': 9,
                }),
                200,
              ),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      PawLifeRepository(client: client).createPeso(
        'luna',
        id: 'estable',
        fecha: DateTime.utc(2026),
        valorKg: 4.5,
      ),
      throwsA(isA<ApiException>()),
    );
  });

  testWidgets(
    'historial permite agregar con coma decimal y eliminar con confirmación',
    (tester) async {
      final records = <Map<String, dynamic>>[];
      final client = ApiClient(
        auth: AuthStub(),
        httpClient: MockClient((request) async {
          if (request.method == 'POST') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            records.add(body);
            return http.Response(jsonEncode(body), 201);
          }
          if (request.method == 'DELETE') {
            records.clear();
            return http.Response('', 204);
          }
          return http.Response(jsonEncode({'items': records}), 200);
        }),
      );
      addTearDown(client.close);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          home: WeightHistoryScreen(
            mascota: pet,
            repository: PawLifeRepository(client: client),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Todavía no hay registros de peso.'), findsOneWidget);
      await tester.tap(find.text('Registrar peso'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '4,5');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('4.5 kg'), findsOneWidget);
      await tester.tap(find.byTooltip('Eliminar registro de peso'));
      await tester.pumpAndSettle();
      expect(records, hasLength(1));
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(records, hasLength(1));
      await tester.tap(find.byTooltip('Eliminar registro de peso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      expect(find.text('Todavía no hay registros de peso.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
