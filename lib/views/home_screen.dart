// views/home_screen.dart
//
// Pantalla estática (sin ViewModel propio) que replica el diseño del
// Home Dashboard. La ÚNICA parte funcional es el botón "Start Walk",
// que navega a RouteScreen (Active Walk). Todo lo demás (saludo, resumen
// de actividad, lista de tareas, bottom nav) es decorativo por ahora.

import 'package:flutter/material.dart';

import 'route_screen.dart';

const _kDarkGreen = Color(0xFF12352A);
const _kBackground = Color(0xFFF4F5F7);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onStartWalkPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RouteScreen()),
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
              'Good morning, Sarah!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's your schedule for today.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildPetCard(),
            const SizedBox(height: 16),
            _buildStartWalkCard(context),
            const SizedBox(height: 24),
            const Text(
              'Activity Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildActivitySummary(),
            const SizedBox(height: 24),
            const Text(
              'Today',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildTaskTile(
              icon: Icons.medical_services_outlined,
              iconColor: Colors.red,
              title: 'Morning Medication',
              subtitle: '8:00 AM • Overdue',
              subtitleColor: Colors.red,
              checked: false,
            ),
            const SizedBox(height: 10),
            _buildTaskTile(
              icon: Icons.restaurant_outlined,
              iconColor: Colors.orange,
              title: 'Daily feeding',
              subtitle: 'Completed',
              checked: true,
            ),
            const SizedBox(height: 10),
            _buildTaskTile(
              icon: Icons.directions_walk,
              iconColor: Colors.blueGrey,
              title: 'Afternoon Walk',
              subtitle: '2:00 PM • Upcoming',
              checked: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Icon(Icons.menu),
        const Expanded(
          child: Center(
            child: Text(
              'PawLife',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const CircleAvatar(
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black12,
            child: Icon(Icons.pets, color: Colors.black45),
          ),
          const SizedBox(width: 12),
          const Expanded(
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
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Única parte funcional de esta pantalla: iniciar el paseo
  // -------------------------------------------------------------------
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
                      'Start Walk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ready for an adventure?',
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
            label: 'Last Walk',
            value: '2.4 km',
            hint: 'Yesterday, 5:30 PM',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.timer_outlined,
            iconColor: Colors.blueGrey,
            label: 'Active Time',
            value: '45 min',
            hint: 'Daily goal: 60m',
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

  Widget _buildTaskTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool checked,
    Color subtitleColor = Colors.black54,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: subtitleColor == Colors.red
            ? const Border(left: BorderSide(color: Colors.red, width: 4))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconColor.withValues(alpha: 0.12),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: subtitleColor)),
              ],
            ),
          ),
          // Decorativo: no dispara ninguna acción todavía.
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            color: checked ? _kDarkGreen : Colors.black26,
          ),
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
            _buildNavItem(Icons.home, 'Home', active: true),
            _buildNavItem(Icons.pets, 'Pets'),
            // Ícono central de "Walk": también funcional, por comodidad
            // de navegación (misma acción que la tarjeta Start Walk).
            GestureDetector(
              onTap: () => _onStartWalkPressed(context),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: _kDarkGreen,
                child: const Icon(Icons.directions_walk,
                    color: Colors.white, size: 20),
              ),
            ),
            _buildNavItem(Icons.assignment_outlined, 'Tasks'),
            _buildNavItem(Icons.person_outline, 'Profile'),
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
