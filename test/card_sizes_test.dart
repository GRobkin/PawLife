import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/views/walk_share_screen.dart';

final inicio = DateTime(2026, 10, 15, 16, 30);

Paseo paseo({List<RoutePoint> ruta = const []}) => Paseo(
  id: 'x',
  fechaInicio: inicio,
  fechaFin: inicio.add(const Duration(minutes: 20)),
  duracionSegundos: 1200,
  distanciaMetros: 1250,
  velocidadMaximaKmh: 5.2,
  ruta: ruta,
);

void main() {
  setUp(() => WalkShareCard.mapaReal = false);
  tearDown(() => WalkShareCard.mapaReal = true);

  for (final idioma in ['es', 'en', 'pt']) {
    for (final nombre in ['Luna', 'Maximiliano de la Santísima Trinidad']) {
      testWidgets('las 4 cartas miden lo mismo ($idioma, $nombre)', (
        tester,
      ) async {
        final tamanos = <TarjetaEstilo, Size>{};
        for (final estilo in TarjetaEstilo.values) {
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(idioma),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: 360,
                    child: WalkShareCard(
                      paseo: paseo(
                        ruta: [
                          RoutePoint(
                            latitude: -34.9,
                            longitude: -56.1,
                            timestamp: inicio,
                          ),
                          RoutePoint(
                            latitude: -34.91,
                            longitude: -56.12,
                            timestamp: inicio,
                          ),
                        ],
                      ),
                      mascota: Mascota(
                        id: 'm',
                        nombre: nombre,
                        especie: 'perro',
                      ),
                      estilo: estilo,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          tamanos[estilo] = tester.getSize(find.byType(WalkShareCard));
        }
        expect(tamanos.values.toSet().length, 1, reason: '$tamanos');
        expect(tamanos.values.first.height, greaterThanOrEqualTo(altoCarta));
      });
    }
  }
}
