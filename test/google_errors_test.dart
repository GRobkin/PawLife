import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/error_log.dart';
import 'package:pawlife/views/widgets/boton_google.dart';

class _AuthFalsa implements AuthService {
  _AuthFalsa(this.alEntrar);

  final Future<User> Function() alEntrar;

  @override
  Future<User> signInWithGoogle() => alEntrar();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<String?> _pulsarGoogle(
  WidgetTester tester,
  AuthService auth, {
  Locale idioma = const Locale('es'),
}) async {
  String? resultado;
  await tester.pumpWidget(
    MaterialApp(
      locale: idioma,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async =>
              resultado = await entrarConGoogle(context, auth),
          child: const Text('google'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('google'));
  await tester.pumpAndSettle();
  return resultado;
}

void main() {
  tearDown(ErrorLog.clear);

  group('traducirGoogle', () {
    test('cerrar el selector es una cancelación y se calla', () {
      final error = AuthService.traducirGoogle(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: '[16] Cancelled by user.',
        ),
      );

      expect(error.isCancelled, isTrue);
    });

    test('sin descripción se sigue tratando como cancelación', () {
      final error = AuthService.traducirGoogle(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      expect(error.isCancelled, isTrue);
    });

    test('Google rechazando a la app NO es una cancelación', () {
      // Es lo que devuelve Android cuando la firma del APK no está registrada.
      final error = AuthService.traducirGoogle(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: '[16] Account reauth failed.',
        ),
      );

      expect(error.isCancelled, isFalse);
      expect(error.code, 'google-rejected');
      expect(error.message, contains('Account reauth failed'));
    });

    test('los demás errores conservan su código', () {
      final error = AuthService.traducirGoogle(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.unknownError,
          description: '[28444] Developer console is not set up correctly.',
        ),
      );

      expect(error.code, 'google-unknownError');
      expect(error.message, contains('28444'));
    });
  });

  group('entrarConGoogle', () {
    testWidgets('si el rechazo de Google llega, se muestra con su detalle', (
      tester,
    ) async {
      final texto = await _pulsarGoogle(
        tester,
        _AuthFalsa(
          () async => throw AuthService.traducirGoogle(
            const GoogleSignInException(
              code: GoogleSignInExceptionCode.canceled,
              description: '[16] Account reauth failed.',
            ),
          ),
        ),
      );

      expect(texto, isNotNull);
      expect(texto, contains('Google rechazó'));
      expect(texto, contains('Account reauth failed'));
    });

    testWidgets('cancelar de verdad no muestra nada', (tester) async {
      final texto = await _pulsarGoogle(
        tester,
        _AuthFalsa(
          () async => throw const AuthException('x', code: 'cancelado'),
        ),
      );

      expect(texto, isNull);
    });

    testWidgets('un error inesperado se muestra en vez de colgar la pantalla', (
      tester,
    ) async {
      final texto = await _pulsarGoogle(
        tester,
        _AuthFalsa(() async => throw StateError('falla del plugin')),
      );

      expect(texto, isNotNull);
      expect(texto, contains('StateError'));
      expect(ErrorLog.last.value, contains('falla del plugin'));
    });
  });
}
