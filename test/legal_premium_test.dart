import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/views/legal_screen.dart';
import 'package:pawlife/views/widgets/selector_fecha.dart';
import 'package:pawlife/views/widgets/selector_hora.dart';
import 'package:pawlife/views/profile_screen.dart';
import 'package:pawlife/views/wearable/wearable_screen.dart';

Widget app(Widget home) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('borrar cuenta exige casilla, espera y la palabra', (
    tester,
  ) async {
    bool? resultado;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              resultado = await showDialog<bool>(
                context: context,
                builder: (_) => const ConfirmarBorradoDialog(palabra: 'borrar'),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    FilledButton boton() =>
        tester.widget<FilledButton>(find.byType(FilledButton));

    // Palabra y casilla listas, pero falta la espera.
    await tester.tap(find.byKey(const ValueKey('borrar-entiendo')));
    await tester.enterText(
      find.byKey(const ValueKey('borrar-confirmacion')),
      'Borrar',
    );
    await tester.pump();
    expect(boton().onPressed, isNull);

    await tester.pump(const Duration(seconds: 5));
    expect(boton().onPressed, isNotNull);

    // Palabra incorrecta: se vuelve a bloquear.
    await tester.enterText(
      find.byKey(const ValueKey('borrar-confirmacion')),
      'borrando',
    );
    await tester.pump();
    expect(boton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('borrar-confirmacion')),
      ' borrar ',
    );
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(resultado, true);
  });

  testWidgets('sin la casilla no se puede borrar aunque escriba la palabra', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const Scaffold(body: ConfirmarBorradoDialog(palabra: 'borrar'))),
    );
    await tester.enterText(
      find.byKey(const ValueKey('borrar-confirmacion')),
      'borrar',
    );
    await tester.pump(const Duration(seconds: 6));
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('el reloj sin Premium queda bloqueado', (tester) async {
    await tester.pumpWidget(
      app(WearableScreen(comprobarPremium: () async => false)),
    );
    await tester.pump();
    expect(find.byKey(const Key('wearable-bloqueado')), findsOneWidget);
    expect(find.byKey(const Key('wearable-frame')), findsNothing);
  });

  testWidgets('el selector de hora devuelve el atajo elegido', (tester) async {
    TimeOfDay? resultado;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => resultado = await elegirHora(
              context,
              const TimeOfDay(hour: 8, minute: 30),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tarde · 18:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hora-listo')));
    await tester.pumpAndSettle();
    expect(resultado, const TimeOfDay(hour: 18, minute: 0));
  });

  testWidgets('el reloj sin poder comprobar el plan ofrece reintentar', (
    tester,
  ) async {
    var intentos = 0;
    await tester.pumpWidget(
      app(
        WearableScreen(
          comprobarPremium: () async {
            intentos++;
            throw Exception('sin red');
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.text('No se pudo comprobar tu plan.'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    expect(intentos, 2);
  });

  testWidgets('el calendario salta con el atajo y devuelve el día', (
    tester,
  ) async {
    DateTime? resultado;
    final hoy = DateTime.now();
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => resultado = await elegirFecha(
              context: context,
              initialDate: hoy,
              firstDate: DateTime(hoy.year, hoy.month, hoy.day),
              lastDate: hoy.add(const Duration(days: 400)),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('En una semana'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('fecha-listo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fecha-listo')));
    await tester.pumpAndSettle();
    final esperado = DateTime(hoy.year, hoy.month, hoy.day + 7);
    expect(resultado, esperado);
  });

  testWidgets('términos y privacidad muestran su texto', (tester) async {
    await tester.pumpWidget(app(const LegalScreen(doc: LegalDoc.terms)));
    expect(find.text('Términos de uso'), findsWidgets);
    await tester.pumpWidget(app(const LegalScreen(doc: LegalDoc.privacy)));
    await tester.pump();
    await tester.scrollUntilVisible(find.textContaining('HTTPS'), 300);
    expect(find.textContaining('HTTPS'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('LGPD'), 300);
    expect(find.textContaining('art. 18'), findsOneWidget);
  });
}
