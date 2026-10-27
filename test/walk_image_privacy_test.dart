import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/services/gps_point_filter.dart';
import 'package:pawlife/services/walk_repository.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/views/walk_share_screen.dart';

class AuthStub implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final time = DateTime.utc(2026);
  final photoBytes = img.encodePng(img.Image(width: 2, height: 2));
  final mapBytes = img.encodePng(img.Image(width: 4, height: 4));
  final photo = 'data:image/png;base64,${base64Encode(photoBytes)}';
  final map = 'data:image/png;base64,${base64Encode(mapBytes)}';
  final pet = Mascota(
    id: 'luna',
    nombre: 'Luna',
    especie: 'perro',
    fotoUrl: photo,
  );
  Paseo walk(TipoImagenPaseo tipo) => Paseo(
    id: 'paseo',
    fechaInicio: time,
    fechaFin: time.add(const Duration(minutes: 10)),
    duracionSegundos: 600,
    distanciaMetros: 500,
    velocidadMaximaKmh: 4,
    ruta: const [],
    fotoUrl: map,
    imagenTipo: tipo,
  );

  test('origen desconocido no se infiere y se conserva en la API', () {
    final json = {'id': 'paseo', ...walk(TipoImagenPaseo.mapa).toJson()}
      ..remove('imagenTipo');
    expect(Paseo.fromJson(json).imagenTipo, TipoImagenPaseo.desconocida);
    expect(
      Paseo.fromJson({...json, 'imagenTipo': 'otro'}).imagenTipo,
      TipoImagenPaseo.desconocida,
    );
    final client = ApiClient(auth: AuthStub());
    addTearDown(client.close);
    final repository = WalkRepository(client: client);
    expect(
      repository.bodyFromSession(
        WalkSession(
          points: const [],
          distanceMeters: 500,
          duration: const Duration(minutes: 10),
          startedAt: time,
          imagenTipo: TipoImagenPaseo.mapa,
        ),
      )['imagenTipo'],
      'mapa',
    );
  });

  for (final type in [TipoImagenPaseo.mapa, TipoImagenPaseo.desconocida]) {
    testWidgets('PNG excluye imagen $type y usa foto de mascota', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WalkShareCard(paseo: walk(type), mascota: pet),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect((avatar.backgroundImage! as MemoryImage).bytes, photoBytes);
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'fotografía explícita puede incluirse y mapa nunca se usa sin foto de mascota',
    () {
      expect(walk(TipoImagenPaseo.foto).fotoParaCompartir(pet), map);
      expect(
        walk(TipoImagenPaseo.mapa).fotoParaCompartir(
          const Mascota(id: 'luna', nombre: 'Luna', especie: 'perro'),
        ),
        isNull,
      );
    },
  );

  test('GPS inválido no contamina el siguiente punto válido', () {
    final filter = GpsPointFilter(inicio: time);
    for (final lat in [double.nan, double.infinity, 91.0]) {
      expect(
        filter.evaluar(LecturaGps(latitud: lat, longitud: 0, momento: time)),
        MotivoDescarte.invalida,
      );
    }
    expect(
      filter.evaluar(LecturaGps(latitud: 0, longitud: 181, momento: time)),
      MotivoDescarte.invalida,
    );
    expect(
      filter.evaluar(
        LecturaGps(
          latitud: 0,
          longitud: 0,
          momento: time,
          precisionMetros: double.nan,
        ),
      ),
      MotivoDescarte.invalida,
    );
    expect(filter.ultima, isNull);
    expect(
      filter.evaluar(LecturaGps(latitud: 0, longitud: 0, momento: time)),
      isNull,
    );
  });
}
