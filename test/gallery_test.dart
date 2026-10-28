// Genera capturas de pantallas en es/en/pt x claro/oscuro en
// build/test-artifacts/gallery-*.png. No es una prueba de comportamiento:
// solo comprueba que no hay desbordes y deja las imágenes para revisión.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/models/pawlife_models.dart';
import 'package:pawlife/models/route_point.dart';
import 'package:pawlife/preferences/app_preferences.dart';
import 'package:pawlife/services/auth_service.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/services/walk_repository.dart';
import 'package:pawlife/theme/app_theme.dart';
import 'package:pawlife/views/change_password_screen.dart';
import 'package:pawlife/views/home_screen.dart';
import 'package:pawlife/views/pets_screen.dart';
import 'package:pawlife/views/walk_history_screen.dart';
import 'package:pawlife/views/walk_share_screen.dart';
import 'package:pawlife/views/weight_history_screen.dart';
import 'package:pawlife/views/welcome_screen.dart';
import 'package:pawlife/views/widgets/estado_vacio.dart';
import 'package:pawlife/views/widgets/preferences_section.dart';
import 'package:provider/provider.dart';

const pet = Mascota(
  id: 'luna',
  nombre: 'Luna',
  especie: 'perro',
  raza: 'Golden Retriever',
);
final start = DateTime(2026, 10, 15, 16, 30);
final route = [
  for (final p in [
    (-34.901, -56.168),
    (-34.902, -56.169),
    (-34.904, -56.168),
    (-34.905, -56.164),
    (-34.902, -56.163),
  ])
    RoutePoint(latitude: p.$1, longitude: p.$2, timestamp: start),
];
Paseo walk(String id) => Paseo(
  id: id,
  fechaInicio: start,
  fechaFin: start.add(const Duration(minutes: 20)),
  duracionSegundos: 1200,
  distanciaMetros: 1250,
  velocidadMaximaKmh: 5.2,
  ruta: route,
);

class FakeUser implements User {
  @override
  String? get displayName => 'Juana Pérez';
  @override
  String? get email => 'juana@example.com';
  @override
  String? get photoURL => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class AuthFixture implements AuthService {
  @override
  User? get currentUser => FakeUser();
  @override
  bool get supportsPasswordChange => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PetsFixture implements PawLifeRepository {
  @override
  Future<List<Mascota>> fetchMascotas() async => [pet];
  @override
  Future<List<Vacuna>> fetchVacunas(String mascotaId) async => [
    Vacuna(
      id: 'v',
      nombre: 'Rabia',
      fechaAplicacion: DateTime.now().subtract(const Duration(days: 300)),
      proximaFecha: DateTime.now().add(const Duration(days: 2)),
    ),
  ];
  @override
  Future<List<Recordatorio>> fetchRecordatorios({
    bool soloPendientes = false,
  }) async => [
    Recordatorio(
      id: 'r1',
      tipo: 'vacuna',
      mascotaId: 'luna',
      fecha: DateTime.now(),
      mensaje: 'Vacuna antirrábica',
    ),
    Recordatorio(
      id: 'r2',
      tipo: 'tarea',
      mascotaId: 'luna',
      fecha: DateTime.now(),
      mensaje: 'Cepillar el pelo',
      completado: true,
    ),
    Recordatorio(
      id: 'r3',
      tipo: 'medicamento',
      mascotaId: 'luna',
      fecha: DateTime.now().add(const Duration(hours: 3)),
      mensaje: 'Antiparasitario',
    ),
  ];
  @override
  Future<List<RegistroPeso>> fetchPesos(String mascotaId) async => [
    RegistroPeso(id: 'a', fecha: DateTime(2026, 10, 19, 10, 30), valorKg: 12.5),
    RegistroPeso(id: 'b', fecha: DateTime(2026, 9, 19, 10, 30), valorKg: 12.1),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class WalksFixture implements WalkRepository {
  @override
  Future<List<Paseo>> fetchPaseos(String mascotaId, {int? limite}) async => [
    Paseo(
      id: 'h',
      fechaInicio: DateTime.now().subtract(const Duration(hours: 3)),
      fechaFin: DateTime.now().subtract(const Duration(hours: 2)),
      duracionSegundos: 2520,
      distanciaMetros: 2400,
      velocidadMaximaKmh: 6.1,
      ruta: route,
    ),
  ];
  @override
  Future<WalkPage> fetchHistory(String mascotaId, {String? cursor}) async =>
      WalkPage([walk('1'), walk('2')], null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget cell(
  Widget home,
  Locale locale,
  ThemeMode mode, [
  double height = 760,
]) => SizedBox(
  width: 390,
  height: height,
  child: ChangeNotifierProvider(
    create: (_) => AppPreferences.memory(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: mode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: home,
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

  final screens = <String, Widget Function()>{
    'welcome': () => const WelcomeScreen(),
    'home': () => HomeScreen(
      repository: PetsFixture(),
      walkRepository: WalksFixture(),
      auth: AuthFixture(),
    ),
    'pets': () => PetsScreen(repository: PetsFixture(), userPhotoUrl: ''),
    'weight': () =>
        WeightHistoryScreen(mascota: pet, repository: PetsFixture()),
    'password': () => ChangePasswordScreen(auth: AuthFixture()),
    'walks': () => WalkHistoryScreen(
      petsRepository: PetsFixture(),
      walkRepository: WalksFixture(),
    ),
    'share': () => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: WalkShareCard(paseo: walk('x'), mascota: pet),
        ),
      ),
    ),
    'share-menta': () => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: WalkShareCard(
            paseo: walk('x'),
            mascota: pet,
            estilo: TarjetaEstilo.menta,
          ),
        ),
      ),
    ),
    'share-cifras': () => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: WalkShareCard(
            paseo: walk('x'),
            mascota: pet,
            estilo: TarjetaEstilo.cifras,
          ),
        ),
      ),
    ),
    'vacios': () => Builder(
      builder: (context) {
        final t = AppLocalizations.of(context);
        return Scaffold(
          body: Center(
            child: EstadoVacio(
              icono: Icons.pets,
              titulo: t.petsEmptyTitle,
              detalle: t.petsEmptyBody,
              accion: t.addPet,
              onAccion: () {},
            ),
          ),
        );
      },
    ),
    'prefs': () => const Scaffold(
      body: Padding(padding: EdgeInsets.all(20), child: PreferencesSection()),
    ),
  };

  for (final entry in screens.entries) {
    testWidgets('galería ${entry.key}', (tester) async {
      final cellHeight = entry.key == 'home' ? 860.0 : 760.0;
      tester.view.physicalSize = Size(1170, cellHeight * 2);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: Column(
              children: [
                for (final mode in [ThemeMode.light, ThemeMode.dark])
                  Row(
                    children: [
                      for (final lang in ['es', 'en', 'pt'])
                        cell(entry.value(), Locale(lang), mode, cellHeight),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final out = File('build/test-artifacts/gallery-${entry.key}.png');
          await out.parent.create(recursive: true);
          await out.writeAsBytes(bytes!.buffer.asUint8List());
        } finally {
          image.dispose();
        }
      });
    });
  }
}
