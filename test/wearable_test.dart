import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/views/wearable/wearable_controller.dart';
import 'package:pawlife/views/wearable/wearable_screen.dart';
import 'package:pawlife/views/wearable/wearable_theme.dart';

class PaseoFalso extends ChangeNotifier implements WearablePaseo {
  PaseoFalso({this.falloInicio});
  final String? falloInicio;
  Duration t = Duration.zero;
  bool pausado = false;
  bool liberado = false;

  @override
  Future<String?> iniciar() async => falloInicio;
  @override
  void pausar() => pausado = true;
  @override
  void reanudar() => pausado = false;
  @override
  WalkSession terminar() => WalkSession(
    points: const [],
    distanceMeters: 1250,
    duration: const Duration(minutes: 20, seconds: 5),
    startedAt: DateTime(2026, 10, 28),
  );
  @override
  Duration get tiempo => t;
  @override
  double get distanciaMetros => 1250;
  @override
  Listenable get cambios => this;
  @override
  void liberar() => liberado = true;

  void avanzar(int segundos) {
    t += Duration(seconds: segundos);
    notifyListeners();
  }
}

const luna = Mascota(id: 'luna', nombre: 'Luna', especie: 'perro');

double luminancia(Color c) {
  double f(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
}

double contraste(Color a, Color b) {
  final la = luminancia(a), lb = luminancia(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  late PaseoFalso paseo;
  late List<String> guardados;
  late bool fallaGuardar;

  WearableController crear({Mascota? mascota = luna, PaseoFalso? p}) {
    paseo = p ?? PaseoFalso();
    return WearableController(
      paseo: paseo,
      cargarMascota: () async => mascota,
      guardar: (id, sesion) async {
        if (fallaGuardar) throw Exception('sin red');
        guardados.add(id);
      },
      vibrar: () async {},
    );
  }

  Future<void> montar(WidgetTester tester, WearableController c) async {
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
        home: WearableScreen(controller: c),
      ),
    );
    await c.preparar();
    await tester.pump();
  }

  int pulsables(WidgetTester tester) => find
      .descendant(
        of: find.byKey(const Key('wearable-frame')),
        matching: find.byType(GestureDetector),
      )
      .evaluate()
      .length;

  setUp(() {
    guardados = [];
    fallaGuardar = false;
  });

  testWidgets('marco 250x250, fondo negro y sin teclado', (tester) async {
    final c = crear();
    await montar(tester, c);
    expect(
      tester.getSize(find.byKey(const Key('wearable-frame'))),
      const Size(250, 250),
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.black,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('INICIAR'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
  });

  testWidgets('iniciar, pausar, seguir y terminar con un toque cada uno', (
    tester,
  ) async {
    final c = crear();
    await montar(tester, c);
    expect(pulsables(tester), 1);

    await tester.tap(find.text('INICIAR'));
    await tester.pump();
    expect(c.estado, WearableEstado.enPaseo);
    expect(pulsables(tester), lessThanOrEqualTo(2));
    expect(find.text('00:00'), findsOneWidget);

    paseo.avanzar(75);
    await tester.pump();
    expect(find.text('01:15'), findsOneWidget);

    await tester.tap(find.text('PAUSAR'));
    await tester.pump();
    expect(c.estado, WearableEstado.pausado);
    expect(paseo.pausado, isTrue);
    expect(find.text('SEGUIR'), findsOneWidget);
    expect(pulsables(tester), lessThanOrEqualTo(2));

    await tester.tap(find.text('SEGUIR'));
    await tester.pump();
    expect(c.estado, WearableEstado.enPaseo);
    expect(paseo.pausado, isFalse);

    await tester.tap(find.text('TERMINAR'));
    await tester.pumpAndSettle();
    expect(c.estado, WearableEstado.terminado);
    expect(guardados, ['luna']);
    expect(find.text('GUARDADO'), findsOneWidget);
    expect(find.text('1.25 km'), findsOneWidget);
    expect(pulsables(tester), 1);

    await tester.tap(find.text('LISTO'));
    await tester.pump();
    expect(c.estado, WearableEstado.reposo);
  });

  testWidgets('el cronometro solo repinta cuando cambia el segundo', (
    tester,
  ) async {
    final c = crear();
    await montar(tester, c);
    await c.iniciar();
    var avisos = 0;
    c.addListener(() => avisos++);
    paseo.t = const Duration(seconds: 5, milliseconds: 100);
    paseo.notifyListeners();
    paseo.t = const Duration(seconds: 5, milliseconds: 600);
    paseo.notifyListeners();
    paseo.notifyListeners();
    expect(avisos, 1);
    paseo.t = const Duration(seconds: 6);
    paseo.notifyListeners();
    expect(avisos, 2);
  });

  testWidgets('sin GPS muestra el error y vuelve al reposo', (tester) async {
    final c = crear(p: PaseoFalso(falloInicio: 'gps-off'));
    await montar(tester, c);
    await tester.tap(find.text('INICIAR'));
    await tester.pump();
    expect(find.text('SIN GPS'), findsOneWidget);
    await tester.tap(find.text('LISTO'));
    await tester.pump();
    expect(c.estado, WearableEstado.reposo);
  });

  testWidgets('sin mascota no se puede iniciar', (tester) async {
    final c = crear(mascota: null);
    await montar(tester, c);
    expect(find.text('SIN MASCOTA'), findsOneWidget);
    expect(c.estado, WearableEstado.error);
  });

  testWidgets('si falla el guardado se puede reintentar sin perder el paseo', (
    tester,
  ) async {
    fallaGuardar = true;
    final c = crear();
    await montar(tester, c);
    await c.iniciar();
    await c.terminar();
    await tester.pump();
    expect(find.text('NO GUARDÓ'), findsOneWidget);
    fallaGuardar = false;
    await tester.tap(find.text('REINTENTAR'));
    await tester.pumpAndSettle();
    expect(c.estado, WearableEstado.terminado);
    expect(guardados, ['luna']);
  });

  testWidgets('los textos visibles son cortos en todos los estados', (
    tester,
  ) async {
    final c = crear();
    await montar(tester, c);
    final vistos = <String>{};
    void leer() {
      for (final w in tester.widgetList<Text>(
        find.descendant(
          of: find.byKey(const Key('wearable-frame')),
          matching: find.byType(Text),
        ),
      )) {
        if (w.data != null && w.data != 'Luna') vistos.add(w.data!);
      }
    }

    leer();
    await c.iniciar();
    await tester.pump();
    leer();
    await c.pausar();
    await tester.pump();
    leer();
    await c.terminar();
    await tester.pumpAndSettle();
    leer();
    expect(vistos, isNotEmpty);
    for (final texto in vistos) {
      expect(texto.length, lessThanOrEqualTo(12), reason: texto);
    }
  });

  test('contraste minimo 7:1 en cada par texto/fondo', () {
    const pares = {
      'texto/fondo': [WearableColors.texto, WearableColors.fondo],
      'tenue/fondo': [WearableColors.textoTenue, WearableColors.fondo],
      'acento/fondo': [WearableColors.acento, WearableColors.fondo],
      'error/fondo': [WearableColors.error, WearableColors.fondo],
      'sobreAcento/acento': [WearableColors.sobreAcento, WearableColors.acento],
      'texto/secundario': [WearableColors.texto, WearableColors.secundario],
    };
    pares.forEach((nombre, par) {
      expect(
        contraste(par[0], par[1]),
        greaterThanOrEqualTo(7),
        reason: nombre,
      );
    });
  });

  testWidgets('salir con un paseo en curso libera el servicio', (tester) async {
    final c = crear();
    await montar(tester, c);
    await c.iniciar();
    c.dispose();
    expect(paseo.liberado, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
