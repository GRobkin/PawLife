// views/home_screen.dart
//
// Home Dashboard. Funcionan el saludo con el nombre real, el menú de la
// cuenta, la tarjeta de mascota (que permite cambiar de mascota activa), el
// botón "Iniciar paseo" y la agenda real de recordatorios.

import 'package:flutter/material.dart';

import '../models/pawlife_models.dart';
import '../services/auth_service.dart';
import '../services/pawlife_repository.dart';
import '../services/local_reminder_service.dart';
import '../services/seleccion_mascota.dart';
import '../services/walk_repository.dart';
import 'pets_screen.dart';
import 'widgets/foto_mascota.dart';
import 'widgets/iniciar_paseo.dart';
import 'widgets/pawlife_bottom_nav.dart';
import 'widgets/selector_mascota.dart';

const _kDarkGreen = Color(0xFF12352A);
const _kBackground = Color(0xFFF4F5F7);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Las mascotas del usuario. null mientras se cargan; vacía si no tiene.
  List<Mascota>? _mascotas;

  /// Paseos de la mascota activa, para el resumen de actividad. null mientras
  /// se cargan.
  List<Paseo>? _paseos;
  List<Recordatorio>? _recordatorios;

  @override
  void initState() {
    super.initState();
    // Al cambiar de mascota hay que recargar los paseos: el resumen habla de
    // la activa, no del usuario.
    SeleccionMascota.id.addListener(_cargarPaseos);
    _cargarMascotas();
    _cargarRecordatorios();
  }

  @override
  void dispose() {
    SeleccionMascota.id.removeListener(_cargarPaseos);
    super.dispose();
  }

  Future<void> _cargarMascotas() async {
    try {
      final mascotas = await PawLifeRepository().fetchMascotas();
      if (!mounted) return;
      setState(() => _mascotas = mascotas);
      await _cargarPaseos();
    } catch (_) {
      // El Home tiene que poder abrirse sin conexión: la tarjeta se queda con
      // el aviso de que no se pudieron cargar y el resto de la pantalla sigue
      // siendo utilizable.
      if (!mounted) return;
      setState(() {
        _mascotas = const [];
        _paseos = const [];
      });
    }
  }

  Future<void> _cargarPaseos() async {
    final mascotas = _mascotas;
    final activa = mascotas == null
        ? null
        : SeleccionMascota.resolver(mascotas);

    if (activa == null) {
      if (mounted) setState(() => _paseos = const []);
      return;
    }

    if (mounted) setState(() => _paseos = null);

    try {
      // 20 basta: el resumen solo mira el último paseo y los de hoy.
      final paseos = await WalkRepository().fetchPaseos(activa.id, limite: 20);
      if (!mounted) return;
      setState(() => _paseos = paseos);
    } catch (_) {
      if (!mounted) return;
      setState(() => _paseos = const []);
    }
  }

  Future<void> _cargarRecordatorios() async {
    try {
      final items = await PawLifeRepository().fetchRecordatorios();
      if (mounted) setState(() => _recordatorios = items);
    } catch (_) {
      if (mounted) setState(() => _recordatorios = const []);
    }
  }

  Future<void> _marcarRecordatorio(Recordatorio item) async {
    try {
      await PawLifeRepository().marcarRecordatorio(
        item.id,
        completado: !item.completado,
      );
      await LocalReminderService.instance.syncBestEffort(PawLifeRepository());
      await _cargarRecordatorios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar la tarea: $e')),
        );
      }
    }
  }

  /// Antes esta pantalla creaba una mascota fija llamada Buddy y le atribuía
  /// todos los paseos. Ahora usa la mascota activa (ver iniciar_paseo.dart).
  Future<void> _onStartWalkPressed(BuildContext context) async {
    await iniciarPaseo(context, mascotas: _mascotas);
    // Al volver del paseo puede haber uno nuevo guardado, así que el resumen
    // se queda viejo si no se recarga.
    if (mounted) await _cargarPaseos();
  }

  Future<void> _cambiarMascota() async {
    final mascotas = _mascotas;

    if (mascotas == null) return;

    if (mascotas.isEmpty) {
      // Sin mascotas no hay nada que elegir: se lleva al listado, que tiene el
      // botón para crear la primera.
      _irAMascotas();
      return;
    }

    if (mascotas.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo tenés una mascota por ahora.')),
      );
      return;
    }

    final elegida = await elegirMascota(
      context,
      mascotas,
      titulo: 'Cambiar de mascota',
      seleccionadaId: SeleccionMascota.resolver(mascotas)?.id,
    );

    if (elegida == null) return;
    SeleccionMascota.seleccionar(elegida);
  }

  void _irAMascotas() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PetsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hoy = _recordatorios
        ?.where(
          (r) =>
              r.fecha.year == now.year &&
              r.fecha.month == now.month &&
              r.fecha.day == now.day,
        )
        .toList();
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
            if (_recordatorios == null)
              const Center(child: CircularProgressIndicator())
            else if (hoy!.isEmpty)
              const Text('No tenés tareas para hoy.')
            else
              ...hoy.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildTaskTile(
                    icon: r.tipo == 'vacuna'
                        ? Icons.medical_services_outlined
                        : Icons.assignment_outlined,
                    iconColor: _kDarkGreen,
                    title: r.mensaje,
                    subtitle: r.completado
                        ? 'Completada'
                        : '${r.fecha.hour.toString().padLeft(2, '0')}:'
                              '${r.fecha.minute.toString().padLeft(2, '0')}',
                    checked: r.completado,
                    onTap: () => _marcarRecordatorio(r),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.inicio,
        onPaseo: () => _onStartWalkPressed(context),
        onReturn: _cargarRecordatorios,
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

  /// Tarjeta de la mascota activa. Al pulsarla se cambia de mascota.
  ///
  /// Escucha `SeleccionMascota.id` en vez de guardarse la elegida en el estado:
  /// así cambiarla desde cualquier otro sitio también repinta esta tarjeta.
  Widget _buildPetCard() {
    return ValueListenableBuilder<String?>(
      valueListenable: SeleccionMascota.id,
      builder: (context, _, _) {
        final mascotas = _mascotas;
        final activa = mascotas == null
            ? null
            : SeleccionMascota.resolver(mascotas);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: _cambiarMascota,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (activa != null)
                    AvatarMascota(mascota: activa, radio: 22)
                  else
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.pets, color: Colors.black45),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activa?.nombre ??
                              (mascotas == null ? 'Cargando…' : 'Sin mascotas'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          activa?.subtitulo ??
                              (mascotas == null
                                  ? ''
                                  : 'Tocá para agregar la primera'),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // La flecha solo tiene sentido si hay entre qué elegir.
                  if (mascotas != null && mascotas.length > 1)
                    const Icon(Icons.keyboard_arrow_down)
                  else if (mascotas != null && mascotas.isEmpty)
                    const Icon(Icons.add, color: Colors.black45),
                ],
              ),
            ),
          ),
        );
      },
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

  /// Resumen de actividad de la mascota activa, con datos reales de sus paseos.
  ///
  /// Antes eran dos valores escritos a mano ("2.4 km, ayer" y "45 min, meta
  /// diaria 60"). La meta diaria se quitó porque no existe en ningún sitio: no
  /// hay dónde configurarla ni con qué compararla, así que la segunda tarjeta
  /// pasó a contar el tiempo caminado HOY, que sí se puede sumar de los paseos.
  Widget _buildActivitySummary() {
    final paseos = _paseos;

    if (paseos == null) {
      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.map_outlined,
              iconColor: Colors.green,
              label: 'Último paseo',
              value: '…',
              hint: 'Cargando',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.timer_outlined,
              iconColor: Colors.blueGrey,
              label: 'Tiempo activo',
              value: '…',
              hint: 'Cargando',
            ),
          ),
        ],
      );
    }

    final ultimo = paseos.isEmpty ? null : paseos.first;

    final deHoy = paseos.where((p) => _esHoy(p.fechaInicio));
    final minutosHoy =
        deHoy.fold<int>(0, (t, p) => t + p.duracionSegundos) ~/ 60;
    final cuantosHoy = deHoy.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.map_outlined,
            iconColor: Colors.green,
            label: 'Último paseo',
            value: ultimo == null
                ? '—'
                : '${(ultimo.distanciaMetros / 1000).toStringAsFixed(2)} km',
            hint: ultimo == null ? 'Sin paseos' : _cuando(ultimo.fechaInicio),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.timer_outlined,
            iconColor: Colors.blueGrey,
            label: 'Tiempo activo',
            value: cuantosHoy == 0 ? '—' : '$minutosHoy min',
            hint: switch (cuantosHoy) {
              0 => 'Sin paseos hoy',
              1 => '1 paseo hoy',
              _ => '$cuantosHoy paseos hoy',
            },
          ),
        ),
      ],
    );
  }

  static bool _esHoy(DateTime fecha) {
    final ahora = DateTime.now();

    return fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
  }

  /// "Hoy, 17:30", "Ayer, 09:15", "14 sep, 18:40".
  static String _cuando(DateTime fecha) {
    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';

    if (_esHoy(fecha)) return 'Hoy, $hora';

    final ayer = DateTime.now().subtract(const Duration(days: 1));
    if (fecha.year == ayer.year &&
        fecha.month == ayer.month &&
        fecha.day == ayer.day) {
      return 'Ayer, $hora';
    }

    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    return '${fecha.day} ${meses[fecha.month - 1]}, $hora';
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
    required VoidCallback onTap,
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
          IconButton(
            tooltip: checked ? 'Marcar pendiente' : 'Marcar completada',
            onPressed: onTap,
            icon: Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              color: checked ? _kDarkGreen : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}
