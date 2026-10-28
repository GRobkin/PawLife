import 'package:pawlife/l10n/app_localizations.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/theme/app_colors.dart';
import 'package:pawlife/views/change_password_screen.dart';
import 'package:pawlife/views/weight_history_screen.dart';

class AuthFixture implements AuthService {
  @override
  bool get supportsPasswordChange => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class WeightsFixture implements PawLifeRepository {
  @override
  Future<List<RegistroPeso>> fetchPesos(String mascotaId) async => [
    RegistroPeso(
      id: 'uno',
      fecha: DateTime(2026, 10, 19, 10, 30),
      valorKg: 12.5,
    ),
    RegistroPeso(
      id: 'dos',
      fecha: DateTime(2026, 9, 19, 10, 30),
      valorKg: 12.1,
    ),
  ];
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

  for (final width in [320.0, 390.0, 800.0]) {
    for (final largeText in [false, true]) {
      testWidgets('pantallas etapa1 ancho $width texto ampliado $largeText', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final page in ['peso', 'password']) {
          final boundaryKey = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: boundaryKey,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                locale: const Locale('es'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                theme: ThemeData(
                  useMaterial3: true,
                  fontFamily: 'NunitoSans',
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.verdeOscuro,
                  ),
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(largeText ? 2 : 1)),
                  child: child!,
                ),
                home: page == 'peso'
                    ? WeightHistoryScreen(
                        mascota: const Mascota(
                          id: 'luna',
                          nombre: 'Luna',
                          especie: 'perro',
                        ),
                        repository: WeightsFixture(),
                      )
                    : ChangePasswordScreen(auth: AuthFixture()),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (width == 390 && !largeText) {
            final boundary =
                boundaryKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await boundary.toImage();
              try {
                final bytes = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                final output = File('build/test-artifacts/stage1-$page.png');
                await output.parent.create(recursive: true);
                await output.writeAsBytes(bytes!.buffer.asUint8List());
              } finally {
                image.dispose();
              }
            });
          }
        }
      });
    }
  }
}
