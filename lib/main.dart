<<<<<<< HEAD
// lib/main.dart
//
// Punto de entrada de la app. Arranca directamente en el Home Dashboard.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necesario para poder recibir datos del foreground service (ver
  // services/walk_task_handler.dart) en el isolate principal de la UI.
  // Sin esto, los puntos GPS del servicio nunca llegan al ViewModel.
  FlutterForegroundTask.initCommunicationPort();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PawLifeApp());
=======
﻿import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'view/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
>>>>>>> 6b5301e6ed537dd8b8e718730d397f895dd14bf6
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
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
      home: const HomeScreen(),
=======
      home: HomeScreen(),
>>>>>>> 6b5301e6ed537dd8b8e718730d397f895dd14bf6
    );
  }
}
