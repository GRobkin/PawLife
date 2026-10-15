import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/services/walk_repository.dart';
import 'package:pawlife/views/walk_history_screen.dart';
import 'package:pawlife/views/walk_share_screen.dart';
import 'package:pawlife/views/widgets/walk_route_trace.dart';

const pet = Mascota(id: 'luna', nombre: 'Luna', especie: 'perro');
final start = DateTime(2026, 10, 15, 16, 30);
final route = [
  for (final point in [
    (-34.901, -56.168),
    (-34.902, -56.169),
    (-34.904, -56.168),
    (-34.905, -56.164),
    (-34.902, -56.163),
  ])
    RoutePoint(latitude: point.$1, longitude: point.$2, timestamp: start),
];
Paseo walk(String id) => Paseo(
  id: id,
  fechaInicio: start,
  fechaFin: start.add(const Duration(minutes: 20)),
  duracionSegundos: 1200,
  distanciaMetros: 1250,
  velocidadMaximaKmh: 5.2,
  ruta: route,
);

class PetsStub implements PawLifeRepository {
  @override
  Future<List<Mascota>> fetchMascotas() async => [pet];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class WalksStub implements WalkRepository {
  bool fail = false;
  bool empty = false;
  final cursors = <String?>[];
  @override
  Future<WalkPage> fetchHistory(String mascotaId, {String? cursor}) async {
    cursors.add(cursor);
    if (fail) throw Exception('sin conexión');
    if (empty) return const WalkPage([], null);
    return cursor == null
        ? WalkPage([walk('uno')], 'uno')
        : WalkPage([walk('dos')], null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class AuthStub implements AuthService {
  @override
  Future<String> idToken({bool forceRefresh = false}) async => 'test-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'NunitoSans',
    )..addFont(rootBundle.load('assets/fonts/NunitoSans.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets(
    'historial carga la página siguiente sin perder los paseos anteriores',
    (tester) async {
      final walks = WalksStub();
      await tester.pumpWidget(
        MaterialApp(
          home: WalkHistoryScreen(
            petsRepository: PetsStub(),
            walkRepository: walks,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Paseo con Luna'), findsOneWidget);
      expect(
        tester.getSize(find.byType(WalkRouteTrace)).width,
        greaterThan(250),
      );
      await tester.ensureVisible(find.text('Cargar más paseos'));
      await tester.tap(find.text('Cargar más paseos'));
      await tester.pumpAndSettle();
      expect(walks.cursors, [null, 'uno']);
      expect(find.text('Paseo con Luna'), findsNWidgets(2));
      expect(find.text('Cargar más paseos'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('historial permite reintentar un error y muestra estado vacío', (
    tester,
  ) async {
    final walks = WalksStub()..fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: WalkHistoryScreen(
          petsRepository: PetsStub(),
          walkRepository: walks,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reintentar'), findsOneWidget);
    walks
      ..fail = false
      ..empty = true;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no hay paseos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'el repositorio envía el cursor como parámetro de consulta y conserva la foto',
    () async {
      final body = {
        ...walk('uno').toJson(),
        'id': 'uno',
        'fotoUrl': 'data:image/jpeg;base64,YQ==',
      };
      final client = ApiClient(
        auth: AuthStub(),
        httpClient: MockClient((request) async {
          expect(request.url.queryParameters['cursor'], 'anterior');
          expect(request.headers['Authorization'], 'Bearer test-token');
          return http.Response(
            jsonEncode({
              'items': [body],
              'nextCursor': null,
            }),
            200,
          );
        }),
      );
      final page = await WalkRepository(
        client: client,
      ).fetchHistory(pet.id, cursor: 'anterior');
      expect(page.items.single.fotoUrl, body['fotoUrl']);
      expect(page.nextCursor, isNull);
      client.close();
    },
  );

  test(
    'reintentar un guardado con respuesta perdida recupera el mismo paseo',
    () async {
      var requests = 0;
      final client = ApiClient(
        auth: AuthStub(),
        httpClient: MockClient((request) async {
          requests++;
          if (request.method == 'POST') {
            expect(jsonDecode(request.body)['id'], 'estable');
            return http.Response('{"error":{"message":"duplicado"}}', 409);
          }
          return http.Response(
            jsonEncode({...walk('estable').toJson(), 'id': 'estable'}),
            200,
          );
        }),
      );
      final result = await WalkRepository(client: client).savePaseo(
        mascotaId: pet.id,
        id: 'estable',
        session: WalkSession(
          points: route,
          distanceMeters: 1250,
          duration: const Duration(minutes: 20),
          startedAt: start,
        ),
      );
      expect(result, 'estable');
      expect(requests, 2);
      client.close();
    },
  );

  testWidgets(
    'tarjeta se exporta como PNG con recorrido y estadísticas reales',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: RepaintBoundary(
                  key: key,
                  child: WalkShareCard(paseo: walk('uno'), mascota: pet),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1.25 km'), findsOneWidget);
      expect(
        tester.getSize(find.byType(WalkRouteTrace)).width,
        greaterThan(250),
      );
      expect(find.text('20 min 0 s'), findsOneWidget);
      expect(find.text('Paseo con Luna'), findsOneWidget);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 3);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        expect(image.width, 1080);
        expect(bytes.buffer.asUint8List().take(8), [
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
        ]);
        final output = File('build/test-artifacts/walk-share.png');
        await output.parent.create(recursive: true);
        await output.writeAsBytes(bytes.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('traza admite GPS vacío, punto único y cruce del meridiano', (
    tester,
  ) async {
    for (final points in <List<RoutePoint>>[
      [],
      [route.first],
      [route.first, route.first],
      [
        RoutePoint(latitude: 0, longitude: 179.99, timestamp: start),
        RoutePoint(latitude: 0, longitude: -179.99, timestamp: start),
      ],
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: WalkRouteTrace(points: points),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
