import 'package:pawlife/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/services/local_reminder_service.dart';
import 'package:pawlife/services/privacy_export_service.dart';
import 'package:pawlife/views/privacy_screen.dart';

class PrivacyUser implements User {
  PrivacyUser(this.uid);
  @override
  final String uid;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PrivacyAuth implements AuthService {
  @override
  User? currentUser = PrivacyUser('a');
  final changes = StreamController<User?>.broadcast();
  @override
  Stream<User?> get authStateChanges => changes.stream;
  @override
  Future<String> idToken({bool forceRefresh = false}) async => 'fixture-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PrivacyRepoFixture implements PawLifeRepository {
  bool care = true;
  bool team = true;
  bool contact = false;
  bool requestsEnabled = true;
  String contactEmail = 'privacy@example.test';
  int privacyReads = 0;
  bool failAfterFirstRead = false;
  @override
  Future<Map<String, dynamic>> fetchPrivacy() async {
    privacyReads++;
    if (failAfterFirstRead && privacyReads > 1) {
      throw const ApiException('Sin conexión');
    }
    return {
      'preferencias': {'recordatoriosCuidados': care, 'avisosEquipo': team},
      'solicitudesHabilitadas': contact && requestsEnabled,
      'contacto': contact
          ? {'responsable': 'Equipo de prueba', 'email': contactEmail}
          : null,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPrivacyRequests() async => [];
  @override
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, Object> values,
  ) async {
    care = values['recordatoriosCuidados'] as bool? ?? care;
    team = values['avisosEquipo'] as bool? ?? team;
    return {
      'preferencias': {'recordatoriosCuidados': care, 'avisosEquipo': team},
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PrivacyReminders implements LocalReminderService {
  int cleared = 0;
  int synced = 0;
  @override
  Future<void> clear() async {
    cleared++;
  }

  @override
  Future<void> sync(PawLifeRepository repository) async {
    synced++;
    await repository.fetchPrivacy();
  }

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

  test('ensambla un JSON completo siguiendo páginas incluso vacías', () async {
    final auth = PrivacyAuth();
    addTearDown(auth.changes.close);
    var pages = 0;
    final api = ApiClient(
      auth: auth,
      expectedUid: 'a',
      httpClient: MockClient((r) async {
        if (r.method == 'POST') {
          return http.Response(
            '{"id":"session","cursor":"first","manifest":{"schemaVersion":1}}',
            202,
          );
        }
        pages++;
        if (pages == 1) {
          return http.Response('{"items":[],"nextCursor":"second"}', 200);
        }
        return http.Response(
          '{"items":[{"categoria":"perfil","datos":{"nombre":"Persona"}}],"nextCursor":null,"finalizadoEn":"2026-10-20T12:00:00Z"}',
          200,
        );
      }),
    );
    addTearDown(api.close);
    final bytes = await PrivacyExportService(
      repository: PawLifeRepository(client: api),
      auth: auth,
      uid: 'a',
    ).prepare();
    final result = jsonDecode(utf8.decode(bytes)) as Map;
    expect(result['registros'], 1);
    expect((result['datos'] as List).single['datos']['nombre'], 'Persona');
    expect(pages, 2);
  });

  test(
    'fallo de página cancela sesión y nunca devuelve archivo parcial',
    () async {
      final auth = PrivacyAuth();
      addTearDown(auth.changes.close);
      var cancelled = 0;
      final api = ApiClient(
        auth: auth,
        expectedUid: 'a',
        httpClient: MockClient((r) async {
          if (r.method == 'POST') {
            return http.Response(
              '{"id":"session","cursor":"first","manifest":{}}',
              202,
            );
          }
          if (r.method == 'DELETE') {
            cancelled++;
            return http.Response('', 204);
          }
          return http.Response('{"error":{"message":"Falló"}}', 503);
        }),
      );
      addTearDown(api.close);
      await expectLater(
        PrivacyExportService(
          repository: PawLifeRepository(client: api),
          auth: auth,
          uid: 'a',
        ).prepare(),
        throwsA(isA<ApiException>()),
      );
      expect(cancelled, 1);
    },
  );

  test(
    'cambio de cuenta descarta datos y no cancela con otra identidad',
    () async {
      final auth = PrivacyAuth();
      addTearDown(auth.changes.close);
      var cancelled = 0;
      final api = ApiClient(
        auth: auth,
        expectedUid: 'a',
        httpClient: MockClient((r) async {
          if (r.method == 'POST') {
            return http.Response(
              '{"id":"session","cursor":"first","manifest":{}}',
              202,
            );
          }
          if (r.method == 'DELETE') {
            cancelled++;
            return http.Response('', 204);
          }
          auth.currentUser = PrivacyUser('b');
          return http.Response(
            '{"items":[],"nextCursor":null,"finalizadoEn":"now"}',
            200,
          );
        }),
      );
      addTearDown(api.close);
      await expectLater(
        PrivacyExportService(
          repository: PawLifeRepository(client: api),
          auth: auth,
          uid: 'a',
        ).prepare(),
        throwsA(isA<PrivacyExportException>()),
      );
      expect(cancelled, 0);
    },
  );

  for (final malformed in [
    '{"items":[],"nextCursor":"first"}',
    '{"items":[],"nextCursor":null}',
  ]) {
    test('rechaza bucle o final sin confirmación: $malformed', () async {
      final auth = PrivacyAuth();
      addTearDown(auth.changes.close);
      final api = ApiClient(
        auth: auth,
        expectedUid: 'a',
        httpClient: MockClient((r) async {
          if (r.method == 'POST') {
            return http.Response(
              '{"id":"session","cursor":"first","manifest":{}}',
              202,
            );
          }
          if (r.method == 'DELETE') return http.Response('', 204);
          return http.Response(malformed, 200);
        }),
      );
      addTearDown(api.close);
      await expectLater(
        PrivacyExportService(
          repository: PawLifeRepository(client: api),
          auth: auth,
          uid: 'a',
        ).prepare(),
        throwsA(isA<PrivacyExportException>()),
      );
    });
  }

  testWidgets('preferencia persiste y cambio de cuenta limpia la pantalla', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final auth = PrivacyAuth();
    final repository = PrivacyRepoFixture();
    addTearDown(auth.changes.close);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,

        home: PrivacyScreen(auth: auth, repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avisos del equipo'));
    await tester.pumpAndSettle();
    expect(repository.team, isFalse);
    auth.currentUser = PrivacyUser('b');
    auth.changes.add(auth.currentUser);
    await tester.pumpAndSettle();
    expect(find.text('Preparar archivo'), findsNothing);
    expect(find.textContaining('La sesión cambió'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('desactivar cuidados cancela localmente sin otro GET', (
    tester,
  ) async {
    final auth = PrivacyAuth();
    addTearDown(auth.changes.close);
    final repository = PrivacyRepoFixture()..failAfterFirstRead = true;
    final reminders = PrivacyReminders();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,

        home: PrivacyScreen(
          auth: auth,
          repository: repository,
          reminders: reminders,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recordatorios de cuidados'));
    await tester.pumpAndSettle();
    expect(repository.care, isFalse);
    expect(reminders.cleared, 1);
    expect(reminders.synced, 0);
    expect(repository.privacyReads, 1);
    expect(find.textContaining('No se pudieron'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('contacto por correo no habilita cola ni permisos de revisión', (
    tester,
  ) async {
    final auth = PrivacyAuth();
    addTearDown(auth.changes.close);
    final repository = PrivacyRepoFixture()
      ..contact = true
      ..requestsEnabled = false
      ..contactEmail = 'pawlife.support@gmail.com';
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,

        home: PrivacyScreen(auth: auth, repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('pawlife.support@gmail.com'), findsOneWidget);
    expect(find.text('Registrar solicitud'), findsNothing);
    expect(find.textContaining('correo de soporte'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [320.0, 390.0, 800.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('privacidad responsive $width texto $scale', (tester) async {
        tester.view.physicalSize = Size(width, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final auth = PrivacyAuth();
        addTearDown(auth.changes.close);
        final repository = PrivacyRepoFixture()..contact = true;
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              locale: const Locale('es'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,

              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'NunitoSans',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF12352A),
                ),
              ),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: PrivacyScreen(auth: auth, repository: repository),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Registrar solicitud'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (width == 390 && scale == 1) {
          await tester.drag(find.byType(ListView), const Offset(0, 1400));
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage();
            try {
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final output = File('build/test-artifacts/stage3-privacy.png');
              await output.parent.create(recursive: true);
              await output.writeAsBytes(data!.buffer.asUint8List());
            } finally {
              image.dispose();
            }
          });
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
