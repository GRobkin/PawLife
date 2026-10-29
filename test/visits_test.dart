import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/views/visits_screen.dart';

class _AuthStub implements AuthService {
  @override
  Null get currentUser => null;
  @override
  Future<String> idToken({bool forceRefresh = false}) async => 'test-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _luna = Mascota(id: 'luna', nombre: 'Luna', especie: 'perro');

void main() {
  test('ordena las visitas por fecha descendente y desempata por id', () async {
    final client = ApiClient(
      auth: _AuthStub(),
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'items': [
              {'id': 'a', 'fecha': '2026-01-01T00:00:00Z', 'motivo': 'Control'},
              {
                'id': 'b',
                'fecha': '2026-03-01T00:00:00Z',
                'motivo': 'Vacuna',
                'proximaFecha': '2027-03-01T00:00:00Z',
              },
            ],
          }),
          200,
        ),
      ),
    );
    addTearDown(client.close);
    final visitas = await PawLifeRepository(
      client: client,
    ).fetchVisitas('luna');
    expect(visitas.map((v) => v.id), ['b', 'a']);
    expect(visitas.first.proximaFecha, isNotNull);
    expect(visitas.last.proximaFecha, isNull);
  });

  test('un 409 con el mismo id devuelve la visita ya guardada', () async {
    final client = ApiClient(
      auth: _AuthStub(),
      httpClient: MockClient((request) async {
        if (request.method == 'POST') {
          return http.Response('{"error":{"message":"duplicado"}}', 409);
        }
        return http.Response(
          jsonEncode({
            'id': 'v1',
            'fecha': '2026-01-01T00:00:00Z',
            'motivo': 'Control',
          }),
          200,
        );
      }),
    );
    addTearDown(client.close);
    final visita = await PawLifeRepository(client: client).createVisita(
      'luna',
      VisitaVeterinaria(id: 'v1', fecha: DateTime.utc(2026), motivo: 'Control'),
    );
    expect(visita.id, 'v1');
  });

  testWidgets('la pantalla lista visitas y valida el motivo', (tester) async {
    final client = ApiClient(
      auth: _AuthStub(),
      httpClient: MockClient((request) async {
        if (request.method == 'POST') {
          fail('no debe enviarse una visita sin motivo');
        }
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'items': [
                {
                  'id': 'a',
                  'fecha': '2026-01-01T00:00:00Z',
                  'motivo': 'Control anual',
                  'veterinario': 'Dra. Pérez',
                },
              ],
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(client.close);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: VisitsScreen(
          mascota: _luna,
          repository: PawLifeRepository(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Control anual'), findsOneWidget);
    expect(find.textContaining('Dra. Pérez'), findsOneWidget);

    await tester.tap(find.text('Registrar visita'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Indicá el motivo de la visita.'), findsOneWidget);
  });
}
