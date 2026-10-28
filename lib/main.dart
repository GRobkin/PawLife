// lib/main.dart
//
// Punto de entrada de la app. La pantalla inicial la decide AuthGate según
// haya sesión abierta o no.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'preferences/app_preferences.dart';
import 'services/auth_service.dart';
import 'services/session_registration.dart';
import 'views/home_screen.dart';
import 'views/welcome_screen.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necesario para poder recibir datos del foreground service (ver
  // services/walk_task_handler.dart) en el isolate principal de la UI.
  // Sin esto, los puntos GPS del servicio nunca llegan al ViewModel.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    FlutterForegroundTask.initCommunicationPort();
  }

  // Firebase se inicializa solo por Auth: los datos viven detrás de la API PHP
  // (../apipaw) y la app ya no habla con Firestore. Lo que sale de aquí es el
  // ID token que el backend verifica en cada petición.
  //
  // Sin esta llamada, FirebaseAuth.instance revienta con "[core/no-app]" y no
  // se puede ni entrar ni guardar nada.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final preferences = await AppPreferences.load();
  runApp(
    ChangeNotifierProvider.value(value: preferences, child: const PawLifeApp()),
  );
}

class PawLifeApp extends StatelessWidget {
  const PawLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferences>();
    return MaterialApp(
      onGenerateTitle: (_) => 'PawLife',
      debugShowCheckedModeBanner: false,
      // Idioma elegido por la persona; sin elección se usa el del sistema y,
      // si no está soportado, español (primer elemento de supportedLocales).
      locale: prefs.locale,
      supportedLocales: AppPreferences.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: prefs.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      builder: (context, child) => _MaxWidth(child: child!),
      home: const AuthGate(),
    );
  }
}

/// Decide la pantalla raíz escuchando el estado de la sesión.
///
/// Es la única que hace ese cambio: las pantallas de login y registro no
/// navegan al Home al terminar, solo vacían la pila de navegación
/// (`popUntil(isFirst)`) y este widget, que está debajo de todo, ya se ha
/// reconstruido con el usuario nuevo. Si además hicieran `pushReplacement`
/// acabaría habiendo dos Home, uno encima del otro.
///
/// Lo mismo al cerrar sesión: el stream emite null y aquí se vuelve a Welcome
/// sin que nadie tenga que navegar a mano.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  // El stream se guarda una sola vez. Si se creara dentro de build(), cada
  // reconstrucción abriría una suscripción nueva y el StreamBuilder volvería
  // al estado "waiting", haciendo parpadear la pantalla.
  final SessionRegistration _registration = SessionRegistration();
  late final Stream<User?> _sesion = AuthService().authStateChanges.map((user) {
    _registration.start(user);
    return user;
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _registration.refreshReminders().catchError((Object _) {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _registration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _sesion,
      builder: (context, snapshot) {
        // Primer frame: Firebase todavía está restaurando la sesión guardada
        // en el dispositivo. Enseñar Welcome aquí haría que a un usuario ya
        // logueado le parpadease la pantalla de bienvenida en cada arranque.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        return snapshot.data == null
            ? const WelcomeScreen()
            : const HomeScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 56, color: context.marca),
            const SizedBox(height: 20),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Limita el ancho de la interfaz en tablet y web: sin esto las listas y los
/// formularios se estiran a todo el ancho de la ventana. En teléfono (menos de
/// [maxWidth]) no cambia nada.
class _MaxWidth extends StatelessWidget {
  const _MaxWidth({required this.child});

  static const double maxWidth = 720;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
