import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/local_reminder_service.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/services/push_service.dart';
import 'package:pawlife/services/session_registration.dart';

class UserStub implements User {
  UserStub(this.uid);
  @override
  final String uid;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class AuthStub implements AuthService {
  AuthStub(this.currentUser);
  @override
  final User currentUser;
  @override
  Future<String> idToken({bool forceRefresh = false}) async => 'test';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PushStub implements PushService {
  int initialCalls = 0;
  final initial = Completer<RemoteMessage?>();
  final opened = StreamController<RemoteMessage>.broadcast();
  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
  @override
  Stream<RemoteMessage> get onMessage => const Stream.empty();
  @override
  Stream<RemoteMessage> get onMessageOpenedApp => opened.stream;
  @override
  Future<String?> init() async => null;
  @override
  Future<RemoteMessage?> getInitialMessage() {
    initialCalls++;
    return initial.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RemindersStub implements LocalReminderService {
  final synced = <String>[];
  int incoming = 0;
  @override
  Future<void> syncBestEffort(PawLifeRepository repository) async {
    final profile = await repository.fetchPerfil();
    synced.add(profile['uid'] as String);
  }

  @override
  Future<void> clear() async {}
  @override
  Future<void> showIncoming({
    required String reminderId,
    required String title,
    required String body,
  }) async {
    incoming++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  SessionRegistration registration(PushStub push, RemindersStub reminders) =>
      SessionRegistration(
        pushFactory: () => push,
        reminders: reminders,
        clientFactory: (uid) => ApiClient(
          auth: AuthStub(UserStub(uid)),
          expectedUid: uid,
          httpClient: MockClient(
            (request) async =>
                http.Response(jsonEncode({'uid': uid, 'perfil': {}}), 200),
          ),
        ),
      );

  testWidgets(
    'cold start refresca datos propios una vez sin mostrar el payload',
    (tester) async {
      final push = PushStub();
      final reminders = RemindersStub();
      final session = registration(push, reminders);
      session.start(UserStub('a'));
      await tester.pumpAndSettle();
      expect(push.initialCalls, 1);
      push.initial.complete(
        const RemoteMessage(data: {'mascotaId': 'ajena', 'userId': 'otro'}),
      );
      await tester.pumpAndSettle();
      expect(reminders.synced, ['a', 'a']);
      expect(reminders.incoming, 0);
      session.start(UserStub('b'));
      await tester.pumpAndSettle();
      expect(push.initialCalls, 1);
      expect(reminders.synced.last, 'b');
      session.dispose();
      await push.opened.close();
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'mensaje inicial que termina después de cambiar de cuenta se descarta',
    (tester) async {
      final push = PushStub();
      final reminders = RemindersStub();
      final session = registration(push, reminders);
      session.start(UserStub('a'));
      await tester.pumpAndSettle();
      session.start(UserStub('b'));
      await tester.pumpAndSettle();
      push.initial.complete(
        const RemoteMessage(data: {'mascotaId': 'privada-a'}),
      );
      await tester.pumpAndSettle();
      expect(reminders.synced, ['a', 'b']);
      expect(reminders.incoming, 0);
      session.dispose();
      await push.opened.close();
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
