import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/views/change_password_screen.dart';

class ProviderStub implements UserInfo {
  ProviderStub(this.providerId);
  @override
  final String providerId;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UserStub implements User {
  UserStub(this.uid, {this.provider = 'password'});
  @override
  final String uid;
  final String provider;
  final events = <String>[];
  Completer<void>? reauthGate;
  bool wrongPassword = false;
  @override
  String? get email => 'cuenta@example.test';
  @override
  List<UserInfo> get providerData => [ProviderStub(provider)];
  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    events.add('reauth');
    if (wrongPassword) throw FirebaseAuthException(code: 'wrong-password');
    await reauthGate?.future;
    return CredentialStub();
  }

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    expect(forceRefresh, isTrue);
    events.add('token');
    return 'token-sandbox';
  }

  @override
  Future<void> updatePassword(String value) async {
    events.add('update');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class CredentialStub implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FirebaseStub implements FirebaseAuth {
  FirebaseStub(this.currentUser);
  @override
  User? currentUser;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'cambiar contraseña reautentica y refresca el token antes y después',
    () async {
      final user = UserStub('a');
      await AuthService(auth: FirebaseStub(user)).changePassword(
        currentPassword: 'anterior',
        newPassword: 'nueva-segura',
      );
      expect(user.events, ['reauth', 'token', 'update', 'token']);
    },
  );

  test('credencial incorrecta no actualiza contraseña', () async {
    final user = UserStub('a')..wrongPassword = true;
    await expectLater(
      AuthService(auth: FirebaseStub(user)).changePassword(
        currentPassword: 'incorrecta',
        newPassword: 'nueva-segura',
      ),
      throwsA(isA<AuthException>()),
    );
    expect(user.events, ['reauth']);
  });

  test(
    'cambiar de sesión durante reauth impide modificar otra cuenta',
    () async {
      final user = UserStub('a')..reauthGate = Completer<void>();
      final firebase = FirebaseStub(user);
      final operation = AuthService(auth: firebase).changePassword(
        currentPassword: 'anterior',
        newPassword: 'nueva-segura',
      );
      final expectation = expectLater(
        operation,
        throwsA(
          isA<AuthException>().having((e) => e.code, 'code', 'sesion-cambio'),
        ),
      );
      firebase.currentUser = UserStub('b');
      user.reauthGate!.complete();
      await expectation;
      expect(user.events, ['reauth']);
    },
  );

  test('cuenta Google no crea contraseña por el flujo de cambio', () async {
    final user = UserStub('a', provider: 'google.com');
    final service = AuthService(auth: FirebaseStub(user));
    expect(service.supportsPasswordChange, isFalse);
    await expectLater(
      service.changePassword(
        currentPassword: 'anterior',
        newPassword: 'nueva-segura',
      ),
      throwsA(isA<AuthException>()),
    );
    expect(user.events, isEmpty);
  });

  testWidgets('formulario exige coincidencia antes de cambiar contraseña', (
    tester,
  ) async {
    final user = UserStub('a');
    await tester.pumpWidget(
      MaterialApp(
        home: ChangePasswordScreen(auth: AuthService(auth: FirebaseStub(user))),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'anterior');
    await tester.enterText(find.byType(TextFormField).at(1), 'nueva-segura');
    await tester.enterText(find.byType(TextFormField).at(2), 'distinta');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pump();
    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    expect(user.events, isEmpty);
  });
}
