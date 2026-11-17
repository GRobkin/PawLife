import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/widgets/banner_premium.dart';

/// Captura el banner con el destello a mitad de camino (con animación activa).
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

  testWidgets('banner con destello en pleno recorrido', (tester) async {
    tester.view.physicalSize = const Size(780, 760);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    Widget fila(ThemeMode modo) => SizedBox(
      height: 190,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: modo,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: BannerPremium(onTap: () {}),
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
            children: [fila(ThemeMode.light), fila(ThemeMode.dark)],
          ),
        ),
      ),
    );
    // 0,18 de 4,6 s: la franja va por la primera mitad de la tarjeta.
    await tester.pump(const Duration(milliseconds: 830));
    await tester.runAsync(() async {
      final boundary =
          marco.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final out = File('build/test-artifacts/banner-brillo.png');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(bytes!.buffer.asUint8List());
    });
  });
}
