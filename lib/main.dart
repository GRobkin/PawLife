// lib/main.dart
//
// Punto de entrada de la app. La pantalla inicial la decide AuthGate según
// haya sesión abierta o no.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'views/home_screen.dart';
import 'views/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necesario para poder recibir datos del foreground service (ver
  // services/walk_task_handler.dart) en el isolate principal de la UI.
  // Sin esto, los puntos GPS del servicio nunca llegan al ViewModel.
  FlutterForegroundTask.initCommunicationPort();

  // Firebase se inicializa solo por Auth: los datos viven detrás de la API PHP
  // (../apipaw) y la app ya no habla con Firestore. Lo que sale de aquí es el
  // ID token que el backend verifica en cada petición.
  //
  // Sin esta llamada, FirebaseAuth.instance revienta con "[core/no-app]" y no
  // se puede ni entrar ni guardar nada.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PawLifeApp());
}

class PawLifeApp extends StatelessWidget {
  const PawLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawLife',
      debugShowCheckedModeBanner: false,
      // Toda la interfaz está en español: fijamos el locale para que los
      // widgets propios de Material (selectores, menús de texto, tooltips)
      // también se muestren traducidos, sin depender del idioma del sistema.
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
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

class _AuthGateState extends State<AuthGate> {
  // El stream se guarda una sola vez. Si se creara dentro de build(), cada
  // reconstrucción abriría una suscripción nueva y el StreamBuilder volvería
  // al estado "waiting", haciendo parpadear la pantalla.
  late final Stream<User?> _sesion = AuthService().authStateChanges;

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

        return snapshot.data == null ? const WelcomeScreen() : const HomeScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 56, color: Color(0xFF12352A)),
            SizedBox(height: 20),
            SizedBox(
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
