<<<<<<< HEAD:lib/views/home_screen.dart
// views/home_screen.dart
//
// Pantalla estática (sin ViewModel propio) que replica el diseño del
// Home Dashboard. La ÚNICA parte funcional es el botón "Iniciar paseo",
// que navega a RouteScreen (paseo en curso). Todo lo demás (saludo, resumen
// de actividad, lista de tareas, bottom nav) es decorativo por ahora.

import 'package:flutter/material.dart';

import '../services/walk_repository.dart';
=======
﻿import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawlife/viewmodel/route_view_model.dart';
>>>>>>> 6b5301e6ed537dd8b8e718730d397f895dd14bf6:lib/view/home_screen.dart
import 'route_screen.dart';

const _kDarkGreen = Color(0xFF12352A);
const _kBackground = Color(0xFFF4F5F7);

/// Mascota fija por ahora: todavía no existe la pantalla para elegirla,
/// así que todos los paseos se le atribuyen a Buddy (la del PetCard).
const _kMascotaId = 'buddy_123';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onStartWalkPressed(BuildContext context) async {
<<<<<<< HEAD:lib/views/home_screen.dart
    // Autenticamos ANTES de salir a caminar, mientras es razonable
    // suponer que hay conexión. Si esperáramos al final del paseo y no
    // hubiera señal, el guardado fallaría con la ruta ya hecha.
    try {
      await WalkRepository().ensureSignedIn();
    } catch (e) {
      debugPrint('No se pudo autenticar al iniciar el paseo: $e');
      // Seguimos igual: el paseo se puede registrar y el guardado se
      // reintenta desde la pantalla de resumen.
=======
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        debugPrint('Error authenticating anonymously: $e');
      }
>>>>>>> 6b5301e6ed537dd8b8e718730d397f895dd14bf6:lib/view/home_screen.dart
    }

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
<<<<<<< HEAD:lib/views/home_screen.dart
        builder: (_) => const RouteScreen(mascotaId: _kMascotaId),
=======
        builder: (_) => ChangeNotifierProvider(
          create: (_) => RouteViewModel(mascotaId: 'buddy_123')..init(),
          child: const RouteScreen(),
        ),
>>>>>>> 6b5301e6ed537dd8b8e718730d397f895dd14bf6:lib/view/home_screen.dart
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildTopBar(),
            const SizedBox(height: 20),
            const Text(
              '¡Buenos días, Sarah!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Esta es tu agenda de hoy.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildPetCard(),
            const SizedBox(height: 16),
            _buildStartWalkCard(context),
            const SizedBox(height: 24),
            const Text(
              'Resumen de actividad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildActivitySummary(),
<<<<<<< HEAD:lib/views/home_screen.dart
            const SizedBox(height: 24),
            const Text(
              'Hoy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildTaskTile(
              icon: Icons.medical_services_outlined,
              iconColor: Colors.red,
              title: 'Medicación de la mañana',
              subtitle: '8:00 • Atrasada',
              subtitleColor: Colors.red,
              checked: false,
            ),
            const SizedBox(height: 10),
            _buildTaskTile(
              icon: Icons.restaurant_outlined,
              iconColor: Colors.orange,
              title: 'Alimentación diaria',
              subtitle: 'Completada',
              checked: true,
            ),
            const SizedBox(height: 10),
            _buildTaskTile(
              icon: Icons.directions_walk,
              iconColor: Colors.blueGrey,
              title: 'Paseo de la tarde',
              subtitle: '14:00 • Próximo',
              checked: false,
            ),
=======
>>>>>>> 6b5301e6ed537dd8b8e718730d397f895dd14bf6:lib/view/home_screen.dart
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar() {
    return const Row(
      children: [
        Icon(Icons.menu),
        Expanded(
          child: Center(
            child: Text(
              'PawLife',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.black12,
          child: Icon(Icons.person, size: 18, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _buildPetCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black12,
            child: Icon(Icons.pets, color: Colors.black45),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buddy',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text('Golden Retriever',
                    style: TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildStartWalkCard(BuildContext context) {
    return Material(
      color: _kDarkGreen,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _onStartWalkPressed(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iniciar paseo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '¿Listos para una aventura?',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_walk,
                    color: _kDarkGreen, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.map_outlined,
            iconColor: Colors.green,
            label: 'Último paseo',
            value: '2.4 km',
            hint: 'Ayer, 17:30',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.timer_outlined,
            iconColor: Colors.blueGrey,
            label: 'Tiempo activo',
            value: '45 min',
            hint: 'Meta diaria: 60 min',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(label,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(hint,
              style: const TextStyle(fontSize: 11, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
<<<<<<< HEAD:lib/views/home_screen.dart
            _buildNavItem(Icons.home, 'Inicio', active: true),
            _buildNavItem(Icons.pets, 'Mascotas'),
            // Ícono central de "Walk": también funcional, por comodidad
            // de navegación (misma acción que la tarjeta Iniciar paseo).
=======
            _buildNavItem(Icons.home, 'Home', active: true),
            _buildNavItem(Icons.pets, 'Pets'),
>>>>>>> 6b5301e6ed537dd8b8e718730d397f895dd14bf6:lib/view/home_screen.dart
            GestureDetector(
              onTap: () => _onStartWalkPressed(context),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: _kDarkGreen,
                child: Icon(Icons.directions_walk,
                    color: Colors.white, size: 20),
              ),
            ),
            _buildNavItem(Icons.assignment_outlined, 'Tareas'),
            _buildNavItem(Icons.person_outline, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool active = false}) {
    final color = active ? _kDarkGreen : Colors.black45;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}
