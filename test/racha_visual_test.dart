import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/estadisticas_paseos.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/widgets/racha_meta.dart';

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

  testWidgets('captura de la tarjeta de racha en sus tres formas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(840, 2000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    const e = EstadisticasPaseos(
      racha: 5,
      paseosSemana: 2,
      kmSemana: 6.2,
      paseoHoy: false,
    );
    Widget tarjeta(
      double ancho,
      double escala,
      ThemeMode modo,
      String idioma,
    ) => SizedBox(
      width: ancho + 40,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topCenter,
              child: RachaMeta(
                estadisticas: e,
                meta: 3,
                nombreMascota: 'Luna',
                onCambiarMeta: () {},
              ),
            ),
          ),
        ),
      ),
    );
    final marco = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: marco,
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: tarjeta(350, 1, ThemeMode.light, 'es'),
              ),
              SizedBox(
                height: 230,
                child: tarjeta(280, 1, ThemeMode.light, 'pt'),
              ),
              SizedBox(
                height: 320,
                child: tarjeta(350, 2, ThemeMode.dark, 'es'),
              ),
              SizedBox(
                height: 240,
                child: tarjeta(350, 1.5, ThemeMode.dark, 'en'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    final limite =
        marco.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final img = await limite.toImage();
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final f = File('build/test-artifacts/racha-variantes.png');
      await f.parent.create(recursive: true);
      await f.writeAsBytes(bytes!.buffer.asUint8List());
      img.dispose();
    });
  });
}
