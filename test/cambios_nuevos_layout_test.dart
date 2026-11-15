import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/estadisticas_paseos.dart';
import 'package:pawlife/models/horario_silencio.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/widgets/racha_meta.dart';

EstadisticasPaseos est(int racha, int semana, {bool hoy = false}) =>
    EstadisticasPaseos(
      racha: racha,
      paseosSemana: semana,
      kmSemana: 0,
      paseoHoy: hoy,
    );

Widget app(Widget hijo, String idioma, double escala, ThemeMode modo) =>
    MaterialApp(
      locale: Locale(idioma),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: modo,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(escala)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: hijo,
        ),
      ),
    );

void main() {
  // La tarjeta de racha no desborda en pantallas angostas ni con texto grande.
  for (final ancho in [320.0, 360.0, 411.0]) {
    for (final escala in [1.0, 1.5, 2.0]) {
      for (final idioma in ['es', 'en', 'pt']) {
        testWidgets('RachaMeta sin desbordes: $ancho px, x$escala, $idioma', (
          tester,
        ) async {
          tester.view.physicalSize = Size(ancho, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          for (final caso in [
            (racha: 0, semana: 0, hoy: false),
            (racha: 12, semana: 2, hoy: true),
            (racha: 1, semana: 7, hoy: false),
          ]) {
            await tester.pumpWidget(
              app(
                RachaMeta(
                  estadisticas: est(caso.racha, caso.semana, hoy: caso.hoy),
                  meta: caso.semana >= 7 ? 7 : 3,
                  nombreMascota: 'Maximiliano de la Santísima Trinidad',
                  onCambiarMeta: () {},
                ),
                idioma,
                escala,
                ThemeMode.light,
              ),
            );
            await tester.pump(const Duration(seconds: 1));
            expect(tester.takeException(), isNull, reason: '$caso');
          }
        });
      }
    }
  }

  testWidgets('el esqueleto de la racha mide como la tarjeta real', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(const RachaMetaEsqueleto(), 'es', 1, ThemeMode.light),
    );
    final esqueleto = tester.getSize(find.byType(RachaMetaEsqueleto));
    await tester.pumpWidget(
      app(
        RachaMeta(
          estadisticas: est(3, 2, hoy: true),
          meta: 3,
          onCambiarMeta: () {},
        ),
        'es',
        1,
        ThemeMode.light,
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    final real = tester.getSize(find.byType(RachaMeta));
    expect((esqueleto.height - real.height).abs(), lessThan(8));
  });

  test('las horas de no molestar salen siempre con ceros y en 24 horas', () {
    expect(HorarioSilencio.formatoHora(7 * 60), '07:00');
    expect(HorarioSilencio.formatoHora(22 * 60 + 5), '22:05');
    expect(HorarioSilencio.formatoHora(0), '00:00');
    expect(HorarioSilencio.formatoHora(23 * 60 + 59), '23:59');
    expect(
      const HorarioSilencio(desdeMin: 480, hastaMin: 480).sinFranja,
      isTrue,
    );
    expect(const HorarioSilencio().sinFranja, isFalse);
  });
}
