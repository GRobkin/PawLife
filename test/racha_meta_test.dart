import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/estadisticas_paseos.dart';
import 'package:pawlife/views/widgets/racha_meta.dart';

Widget app(Widget hijo, {String idioma = 'es'}) => MaterialApp(
  locale: Locale(idioma),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(20), child: hijo),
  ),
);

EstadisticasPaseos est({int racha = 0, int semana = 0, bool hoy = false}) =>
    EstadisticasPaseos(
      racha: racha,
      paseosSemana: semana,
      kmSemana: 0,
      paseoHoy: hoy,
    );

void main() {
  _rachaTope();
  testWidgets('sin racha invita a pasear', (tester) async {
    await tester.pumpWidget(
      app(RachaMeta(estadisticas: est(), meta: 3, onCambiarMeta: () {})),
    );
    expect(find.text('0'), findsOneWidget);
    expect(find.text('días seguidos'), findsOneWidget);
    expect(find.text('Paseá hoy para empezar'), findsOneWidget);
    expect(find.text('0/3'), findsOneWidget);
  });

  testWidgets('con racha y paseo hoy', (tester) async {
    await tester.pumpWidget(
      app(
        RachaMeta(
          estadisticas: est(racha: 4, semana: 2, hoy: true),
          meta: 3,
          onCambiarMeta: () {},
        ),
      ),
    );
    expect(find.text('4'), findsOneWidget);
    expect(find.text('días seguidos'), findsOneWidget);
    expect(find.text('Hoy ya sumaste'), findsOneWidget);
    expect(find.text('2 de 3 paseos'), findsOneWidget);
  });

  testWidgets('la racha de un día usa el singular', (tester) async {
    await tester.pumpWidget(
      app(
        RachaMeta(estadisticas: est(racha: 1), meta: 3, onCambiarMeta: () {}),
        idioma: 'en',
      ),
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('day in a row'), findsOneWidget);
    expect(find.text('Walk today to keep it'), findsOneWidget);
  });

  testWidgets('con la meta cumplida lo dice', (tester) async {
    await tester.pumpWidget(
      app(
        RachaMeta(
          estadisticas: est(racha: 3, semana: 3, hoy: true),
          meta: 3,
          onCambiarMeta: () {},
        ),
      ),
    );
    expect(find.text('¡Meta cumplida!'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('tocar la meta permite elegir otra', (tester) async {
    int? elegida;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => RachaMeta(
            estadisticas: est(racha: 1, semana: 1),
            meta: 3,
            onCambiarMeta: () async =>
                elegida = await elegirMetaSemanal(context, 3),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Meta semanal'));
    await tester.pumpAndSettle();
    expect(find.text('Paseos por semana'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('meta-5')));
    await tester.pumpAndSettle();
    expect(elegida, 5);
  });
}

void _rachaTope() {
  testWidgets('plan gratis: racha de 7 o más se muestra como 7+', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        RachaMeta(
          estadisticas: est(racha: 7, semana: 3),
          meta: 3,
          limitada: true,
          onCambiarMeta: () {},
        ),
      ),
    );
    expect(find.text('7+'), findsOneWidget);
    expect(
      find.text('Plan gratis: se cuentan los últimos 7 días.'),
      findsOneWidget,
    );
  });

  testWidgets('Premium o menos de 7: número exacto', (tester) async {
    await tester.pumpWidget(
      app(
        RachaMeta(estadisticas: est(racha: 12), meta: 3, onCambiarMeta: () {}),
      ),
    );
    expect(find.text('12'), findsOneWidget);
    await tester.pumpWidget(
      app(
        RachaMeta(
          estadisticas: est(racha: 5),
          meta: 3,
          limitada: true,
          onCambiarMeta: () {},
        ),
      ),
    );
    expect(find.text('5'), findsOneWidget);
    expect(find.text('7+'), findsNothing);
  });
}
