import 'package:pawlife/l10n/app_localizations.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/views/change_email_screen.dart';

class _Provider implements UserInfo {
  _Provider(this.providerId);
  @override
  final String providerId;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Credential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _User implements User {
  _User(this.uid, {this.provider = 'password'});
  @override
  final String uid;
  final String provider;
  String currentEmail = 'cuenta@example.test';
  String? emailAfterReload;
  bool wrongPassword = false;
  Completer<void>? reauthGate;
  final events = <String>[];

  @override
  String? get email => currentEmail;
  @override
  List<UserInfo> get providerData => [_Provider(provider)];

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    events.add('reauth');
    if (wrongPassword) throw FirebaseAuthException(code: 'wrong-password');
    await reauthGate?.future;
    return _Credential();
  }

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    events.add('token');
    return 'token-sandbox';
  }

  @override
  Future<void> verifyBeforeUpdateEmail(
    String newEmail, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    events.add('verify:$newEmail');
  }

  @override
  Future<void> reload() async {
    events.add('reload');
    if (emailAfterReload != null) currentEmail = emailAfterReload!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Firebase implements FirebaseAuth {
  _Firebase(this.currentUser);
  @override
  User? currentUser;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'pide el cambio: reautentica y solo entonces envía la verificación',
    () async {
      final user = _User('a');
      await AuthService(auth: _Firebase(user)).requestEmailChange(
        currentPassword: 'clave-actual',
        newEmail: '  Nuevo@Example.TEST ',
      );
      expect(user.events, ['reauth', 'token', 'verify:nuevo@example.test']);
      expect(user.currentEmail, 'cuenta@example.test');
    },
  );

  test('rechaza datos inválidos sin tocar Firebase', () async {
    for (final (email, password) in [
      ('sin-arroba', 'clave'),
      ('a@b', 'clave'),
      ('CUENTA@example.test', 'clave'),
      ('otro@example.test', ''),
    ]) {
      final user = _User('a');
      await expectLater(
        AuthService(
          auth: _Firebase(user),
        ).requestEmailChange(currentPassword: password, newEmail: email),
        throwsA(isA<AuthException>()),
      );
      expect(user.events, isEmpty, reason: '$email / $password');
    }
  });

  test(
    'una cuenta de Google no puede cambiar el correo por esta vía',
    () async {
      final user = _User('a', provider: 'google.com');
      await expectLater(
        AuthService(auth: _Firebase(user)).requestEmailChange(
          currentPassword: 'x',
          newEmail: 'otro@example.test',
        ),
        throwsA(isA<AuthException>()),
      );
      expect(user.events, isEmpty);
    },
  );

  test('contraseña incorrecta no envía ningún enlace', () async {
    final user = _User('a')..wrongPassword = true;
    await expectLater(
      AuthService(auth: _Firebase(user)).requestEmailChange(
        currentPassword: 'mala',
        newEmail: 'otro@example.test',
      ),
      throwsA(isA<AuthException>()),
    );
    expect(user.events.where((event) => event.startsWith('verify')), isEmpty);
  });

  test(
    'cambiar de sesión durante la reautenticación impide enviar el enlace',
    () async {
      final first = _User('a');
      final gate = Completer<void>();
      first.reauthGate = gate;
      final firebase = _Firebase(first);
      final pending = AuthService(auth: firebase).requestEmailChange(
        currentPassword: 'clave',
        newEmail: 'otro@example.test',
      );
      await Future<void>.delayed(Duration.zero);
      firebase.currentUser = _User('b');
      gate.complete();
      await expectLater(pending, throwsA(isA<AuthException>()));
      expect(
        first.events.where((event) => event.startsWith('verify')),
        isEmpty,
      );
    },
  );

  test('refreshAccount devuelve el correo nuevo tras verificar', () async {
    final user = _User('a')..emailAfterReload = 'nuevo@example.test';
    final result = await AuthService(auth: _Firebase(user)).refreshAccount();
    expect(result, 'nuevo@example.test');
    expect(user.events, ['reload', 'token']);
  });

  Future<void> pumpScreen(WidgetTester tester, _User user) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,

        home: ChangeEmailScreen(auth: AuthService(auth: _Firebase(user))),
      ),
    );
  }

  testWidgets('la pantalla valida, envía el enlace y exige confirmarlo', (
    tester,
  ) async {
    final user = _User('a');
    await pumpScreen(tester, user);

    await tester.tap(find.text('Enviar enlace'));
    await tester.pump();
    expect(find.text('Ingresá el correo nuevo.'), findsOneWidget);
    expect(user.events, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo nuevo'),
      'nuevo@example.test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña actual'),
      'clave',
    );
    await tester.tap(find.text('Enviar enlace'));
    await tester.pumpAndSettle();
    expect(find.textContaining('nuevo@example.test'), findsOneWidget);
    expect(user.events, contains('verify:nuevo@example.test'));

    // Aún sin abrir el enlace: el correo sigue siendo el anterior.
    await tester.tap(find.text('Ya abrí el enlace'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no confirmaste'), findsOneWidget);
    expect(user.currentEmail, 'cuenta@example.test');
  });

  testWidgets('una cuenta de Google ve el aviso y ningún formulario', (
    tester,
  ) async {
    await pumpScreen(tester, _User('a', provider: 'google.com'));
    expect(find.textContaining('Tu cuenta utiliza Google'), findsOneWidget);
    expect(find.text('Enviar enlace'), findsNothing);
  });
}
