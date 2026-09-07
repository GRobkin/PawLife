// lib/main.dart
//
// Punto de entrada de la app. Arranca directamente en el Home Dashboard.

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'home_screen.dart';

void main() {
  // Necesario para poder recibir datos del foreground service (ver
  // services/walk_task_handler.dart) en el isolate principal de la UI.
  FlutterForegroundTask.initCommunicationPort();
  runApp(const PawLifeApp());
}

class PawLifeApp extends StatelessWidget {
  const PawLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawLife',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
