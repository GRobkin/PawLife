import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/profile_screen.dart';

Widget _celda(ThemeMode modo, Key clave) => SizedBox(
  width: 390,
  height: 520,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('es'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    themeMode: modo,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: Scaffold(
      body: Center(
        child: ConfirmarBorradoDialog(key: clave, palabra: 'borrar'),
      ),
    ),
  ),
);

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

  testWidgets('captura del diálogo de borrar cuenta', (tester) async {
    tester.view.physicalSize = const Size(780, 1040);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final claveClara = GlobalKey();
    final claveOscura = GlobalKey();
    final marco = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: marco,
          child: Row(
            children: [
              _celda(ThemeMode.light, claveClara),
              _celda(ThemeMode.dark, claveOscura),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 6));
    // Se marca la casilla y se escribe la palabra en los dos.
    for (final c in find.byKey(const ValueKey('borrar-entiendo')).evaluate()) {
      await tester.tap(find.byWidget(c.widget));
    }
    await tester.pump();
    for (final c
        in find.byKey(const ValueKey('borrar-confirmacion')).evaluate()) {
      await tester.enterText(find.byWidget(c.widget), 'borrar');
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 2));

    // Cancelar y Eliminar van en la misma fila, a la misma altura.
    final cancelar = find.text('Cancelar');
    final eliminar = find.text('Eliminar');
    expect(cancelar, findsNWidgets(2));
    expect(eliminar, findsNWidgets(2));
    for (var i = 0; i < 2; i++) {
      expect(
        tester.getCenter(cancelar.at(i)).dy,
        closeTo(tester.getCenter(eliminar.at(i)).dy, 1),
      );
    }

    final limite =
        marco.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final img = await limite.toImage();
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final f = File('build/test-artifacts/borrar-dialogo.png');
      await f.parent.create(recursive: true);
      await f.writeAsBytes(bytes!.buffer.asUint8List());
      img.dispose();
    });
  });
}
