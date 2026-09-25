// views/home_screen.dart
//
// Home Dashboard. La parte funcional es el saludo con el nombre real, el menú
// de la cuenta y el botón "Iniciar paseo". El resumen de actividad y la lista
// de tareas siguen siendo datos escritos a mano: se llenarán cuando exista la
// pantalla de Tareas.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'widgets/iniciar_paseo.dart';
import 'widgets/pawlife_bottom_nav.dart';

const _kDarkGreen = Color(0xFF12352A);
const _kBackground = Color(0xFFF4F5F7);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Antes esta pantalla creaba una mascota fija llamada Buddy y le atribuía
  /// todos los paseos. Ahora que existe el listado de mascotas, se pregunta a
  /// cuál corresponde (ver widgets/iniciar_paseo.dart).
  Future<void> _onStartWalkPressed(BuildContext context) =>
      iniciarPaseo(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildTopBar(context),
            const SizedBox(height: 20),
            Text(
              _saludo(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.inicio,
        onPaseo: () => _onStartWalkPressed(context),
      ),
    );
  }

  /// Saludo con el nombre de quien inició sesión. Con Google llega solo; con
  /// email y contraseña es el que se escribió al registrarse. Si no hay
  /// ninguno (cuentas creadas antes de pedir el nombre), se saluda sin él.
  String _saludo() {
    final usuario = AuthService().currentUser;
    final nombre = usuario?.displayName?.trim();

    final hora = DateTime.now().hour;
    final momento = hora < 13
        ? 'Buenos días'
        : hora < 21
        ? 'Buenas tardes'
        : 'Buenas noches';

    if (nombre == null || nombre.isEmpty) return '¡$momento!';

    // Solo el primer nombre: "¡Buenos días, Juana Pérez!" queda raro y además
    // se sale de la línea en pantallas estrechas.
    return '¡$momento, ${nombre.split(' ').first}!';
  }

  Widget _buildTopBar(BuildContext context) {
    final usuario = AuthService().currentUser;
    final fotoUrl = usuario?.photoURL;

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
        // El avatar es el único sitio desde el que se puede cerrar sesión.
        // Al hacerlo no hay que navegar a ningún lado: el AuthGate de
        // main.dart ve que la sesión se fue y vuelve solo a la bienvenida.
        PopupMenuButton<String>(
          tooltip: 'Tu cuenta',
          offset: const Offset(0, 40),
          onSelected: (valor) {
            if (valor == 'salir') AuthService().signOut();
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                usuario?.email ?? usuario?.displayName ?? 'Sesión iniciada',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'salir',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: Colors.black54),
                  SizedBox(width: 10),
                  Text('Cerrar sesión'),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black12,
            // Google trae foto de perfil; con email y contraseña no hay, y se
            // cae al icono genérico de siempre.
            backgroundImage: fotoUrl == null ? null : NetworkImage(fotoUrl),
            child: fotoUrl != null
                ? null
                : const Icon(Icons.person, size: 18, color: Colors.black45),
          ),
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
                Text(
                  'Buddy',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Text(
                  'Golden Retriever',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
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
                child: const Icon(
                  Icons.directions_walk,
                  color: _kDarkGreen,
                  size: 20,
                ),
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
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
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
}
