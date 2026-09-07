import 'package:flutter/material.dart';

import 'views/home_screen.dart';

void main() {
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
