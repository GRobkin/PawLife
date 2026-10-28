// views/home_screen.dart
//
// Home Dashboard. Funcionan el saludo con el nombre real, el menú de la
// cuenta, la tarjeta de mascota (que permite cambiar de mascota activa), el
// botón "Iniciar paseo" y la agenda real de recordatorios.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../services/auth_service.dart';
import '../services/pawlife_repository.dart';
import '../services/local_reminder_service.dart';
import '../services/seleccion_mascota.dart';
import '../services/walk_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'pets_screen.dart';
import 'widgets/iniciar_paseo.dart';
import 'walk_history_screen.dart';
import 'widgets/pawlife_bottom_nav.dart';
import 'widgets/motion.dart';
import 'widgets/portada_mascota.dart';
import 'widgets/selector_mascota.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.repository,
    this.walkRepository,
    this.auth,
  });

  /// Para pruebas: dependencias inyectadas.
  final PawLifeRepository? repository;
  final WalkRepository? walkRepository;
  final AuthService? auth;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _repo = widget.repository ?? PawLifeRepository();
  late final _walks = widget.walkRepository ?? WalkRepository();
  late final _auth = widget.auth ?? AuthService();

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
      final mascotas = await _repo.fetchMascotas();
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
      final paseos = await _walks.fetchPaseos(activa.id, limite: 20);
      if (!mounted) return;
      setState(() => _paseos = paseos);
    } catch (_) {
      if (!mounted) return;
      setState(() => _paseos = const []);
    }
  }

  Future<void> _cargarRecordatorios() async {
    try {
      final items = await _repo.fetchRecordatorios();
      if (mounted) setState(() => _recordatorios = items);
    } catch (_) {
      if (mounted) setState(() => _recordatorios = const []);
    }
  }

  Future<void> _marcarRecordatorio(Recordatorio item) async {
    try {
      await _repo.marcarRecordatorio(item.id, completado: !item.completado);
      await LocalReminderService.instance.syncBestEffort(_repo);
      await _cargarRecordatorios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).updateTaskError('$e')),
          ),
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
        SnackBar(content: Text(AppLocalizations.of(context).onlyOnePet)),
      );
      return;
    }

    final elegida = await elegirMascota(
      context,
      mascotas,
      titulo: AppLocalizations.of(context).changePet,
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
    final t = AppLocalizations.of(context);
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
      backgroundColor: context.esOscuro
          ? context.fondoPantalla
          : AppColors.fondoAlterno,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildTopBar(context),
            const SizedBox(height: 20),
            Text(_saludo(), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(t.todayAgenda, style: TextStyle(color: context.textoSuave)),
            const SizedBox(height: 20),
            _buildPetCard(),
            const SizedBox(height: 16),
            _buildStartWalkCard(context),
            const SizedBox(height: 24),
            Text(
              t.activitySummary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildActivitySummary(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WalkHistoryScreen()),
                ),
                icon: const Icon(Icons.history),
                label: Text(t.viewWalkHistory),
              ),
            ),
            const SizedBox(height: 24),
            Text(t.todayTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_recordatorios == null)
              const Column(
                children: [
                  Esqueleto(alto: 64, radio: 14),
                  SizedBox(height: 10),
                  Esqueleto(alto: 64, radio: 14),
                ],
              )
            else if (hoy!.isEmpty)
              Row(
                children: [
                  Icon(Icons.check_circle_outline, color: context.marca),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.noTasksToday,
                      style: TextStyle(color: context.textoSuave),
                    ),
                  ),
                ],
              )
            else
              ...hoy.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildTaskTile(
                    icon: r.tipo == 'vacuna'
                        ? Icons.medical_services_outlined
                        : Icons.assignment_outlined,
                    iconColor: context.marca,
                    title: r.mensaje,
                    subtitle: r.completado
                        ? t.completedLabel
                        : formatTime(context, r.fecha),
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
    final t = AppLocalizations.of(context);
    final usuario = _auth.currentUser;
    final nombre = usuario?.displayName?.trim();

    final hora = DateTime.now().hour;
    final tramo = hora < 13
        ? 0
        : hora < 21
        ? 1
        : 2;

    if (nombre == null || nombre.isEmpty) {
      return [t.goodMorning, t.goodAfternoon, t.goodEvening][tramo];
    }

    // Solo el primer nombre: "¡Buenos días, Juana Pérez!" queda raro y además
    // se sale de la línea en pantallas estrechas.
    final primero = nombre.split(' ').first;
    return [
      t.goodMorningName(primero),
      t.goodAfternoonName(primero),
      t.goodEveningName(primero),
    ][tramo];
  }

  Widget _buildTopBar(BuildContext context) {
    final usuario = _auth.currentUser;
    final fotoUrl = usuario?.photoURL;

    return Row(
      children: [
        const Icon(Icons.menu),
        Expanded(
          child: Center(
            child: Text(
              'PawLife',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        // El avatar es el único sitio desde el que se puede cerrar sesión.
        // Al hacerlo no hay que navegar a ningún lado: el AuthGate de
        // main.dart ve que la sesión se fue y vuelve solo a la bienvenida.
        PopupMenuButton<String>(
          tooltip: AppLocalizations.of(context).yourAccount,
          offset: const Offset(0, 40),
          onSelected: (valor) {
            if (valor == 'salir') _auth.signOut();
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                usuario?.email ??
                    usuario?.displayName ??
                    AppLocalizations.of(context).signedIn,
                style: TextStyle(fontSize: 13, color: context.textoSuave),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'salir',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: context.textoSuave),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context).logout),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 16,
            backgroundColor: context.bordeSuave,
            // Google trae foto de perfil; con email y contraseña no hay, y se
            // cae al icono genérico de siempre.
            backgroundImage: fotoUrl == null ? null : NetworkImage(fotoUrl),
            child: fotoUrl != null
                ? null
                : Icon(Icons.person, size: 18, color: context.textoTenue),
          ),
        ),
      ],
    );
  }

  /// Tareas de hoy que todavía no se completaron.
  int _pendientesHoy() {
    final ahora = DateTime.now();
    return (_recordatorios ?? const <Recordatorio>[])
        .where(
          (r) =>
              !r.completado &&
              r.fecha.year == ahora.year &&
              r.fecha.month == ahora.month &&
              r.fecha.day == ahora.day,
        )
        .length;
  }

  /// Tarjeta de la mascota activa. Al pulsarla se cambia de mascota.
  ///
  /// Escucha `SeleccionMascota.id` en vez de guardarse la elegida en el estado:
  /// así cambiarla desde cualquier otro sitio también repinta esta tarjeta.
  Widget _buildPetCard() {
    return ValueListenableBuilder<String?>(
      valueListenable: SeleccionMascota.id,
      builder: (context, _, _) {
        final t = AppLocalizations.of(context);
        final mascotas = _mascotas;
        final activa = mascotas == null
            ? null
            : SeleccionMascota.resolver(mascotas);

        if (activa != null) {
          return Material(
            color: context.superficie,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _cambiarMascota,
              child: PortadaMascota(
                mascota: activa,
                height: 184,
                children: [
                  if (_recordatorios != null)
                    Positioned(
                      top: 12,
                      left: 14,
                      child: _PastillaTareas(
                        pendientes: _pendientesHoy(),
                        textoPendientes: t.homeTasksPending(_pendientesHoy()),
                        textoAlDia: t.homeAllDone,
                      ),
                    ),
                  Positioned(
                    left: 18,
                    right: 64,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activa.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activa.subtituloLocalizado(t),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // La flecha solo tiene sentido si hay entre qué elegir.
                  if (mascotas != null && mascotas.length > 1)
                    Positioned(
                      right: 14,
                      bottom: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        if (mascotas == null) {
          return const Esqueleto(alto: 184, radio: 22);
        }

        // Sin mascotas: tarjeta compacta.
        return Material(
          color: context.superficie,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: _cambiarMascota,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: context.bordeSuave,
                    child: Icon(Icons.pets, color: context.textoTenue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.noPets,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          t.tapToAddFirst,
                          style: TextStyle(
                            color: context.textoSuave,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.add, color: context.textoTenue),
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
    final t = AppLocalizations.of(context);
    return Material(
      color: context.botonFondo,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _onStartWalkPressed(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.startWalk,
                      style: TextStyle(
                        color: context.botonTexto,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.readyForAdventure,
                      style: TextStyle(
                        color: context.botonTexto.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.botonTexto,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_walk,
                  color: context.botonFondo,
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
    final t = AppLocalizations.of(context);
    final paseos = _paseos;

    if (paseos == null) {
      return _summaryBand(
        left: _SummaryData(Icons.map_outlined, t.lastWalk, '…', t.loadingShort),
        right: _SummaryData(
          Icons.timer_outlined,
          t.activeTime,
          '…',
          t.loadingShort,
        ),
      );
    }

    final ultimo = paseos.isEmpty ? null : paseos.first;

    final deHoy = paseos.where((p) => _esHoy(p.fechaInicio));
    final minutosHoy =
        deHoy.fold<int>(0, (t, p) => t + p.duracionSegundos) ~/ 60;
    final cuantosHoy = deHoy.length;

    return _summaryBand(
      left: _SummaryData(
        Icons.map_outlined,
        t.lastWalk,
        ultimo == null
            ? '—'
            : '${(ultimo.distanciaMetros / 1000).toStringAsFixed(2)} km',
        ultimo == null ? t.noWalks : _cuando(ultimo.fechaInicio),
      ),
      right: _SummaryData(
        Icons.timer_outlined,
        t.activeTime,
        cuantosHoy == 0 ? '—' : t.minutesShort(minutosHoy),
        cuantosHoy == 0 ? t.noWalksToday : t.walksToday(cuantosHoy),
      ),
    );
  }

  static bool _esHoy(DateTime fecha) {
    final ahora = DateTime.now();

    return fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
  }

  /// "Hoy, 17:30", "Ayer, 09:15", "14 sep, 18:40".
  String _cuando(DateTime fecha) {
    final t = AppLocalizations.of(context);
    final hora = formatTime(context, fecha);

    if (_esHoy(fecha)) return t.todayAt(hora);

    final ayer = DateTime.now().subtract(const Duration(days: 1));
    if (fecha.year == ayer.year &&
        fecha.month == ayer.month &&
        fecha.day == ayer.day) {
      return t.yesterdayAt(hora);
    }

    return formatDayMonthTime(context, fecha);
  }

  /// Las dos cifras de actividad en una sola banda, con los números grandes
  /// como protagonistas.
  Widget _summaryBand({
    required _SummaryData left,
    required _SummaryData right,
  }) {
    Widget cell(_SummaryData d) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(d.icon, size: 16, color: context.marca),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  d.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: context.textoSuave),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              d.value,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: context.texto),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            d.hint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.textoTenue),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cell(left),
            VerticalDivider(color: context.bordeSuave, width: 28),
            cell(right),
          ],
        ),
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
    Color? subtitleColor,
  }) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.superficie,
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
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: checked ? context.textoTenue : context.texto,
                    decoration: checked ? TextDecoration.lineThrough : null,
                  ),
                  child: Text(title),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor ?? context.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: checked ? t.markPending : t.markDone,
            onPressed: onTap,
            icon: AnimatedSwitcher(
              duration: reducirMovimiento(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              transitionBuilder: (hijo, animacion) =>
                  ScaleTransition(scale: animacion, child: hijo),
              child: Icon(
                checked ? Icons.check_box : Icons.check_box_outline_blank,
                key: ValueKey(checked),
                color: checked ? context.marca : context.textoTenue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryData {
  const _SummaryData(this.icon, this.label, this.value, this.hint);

  final IconData icon;
  final String label;
  final String value;
  final String hint;
}

/// Resumen de las tareas del día, sobre la foto de la mascota.
class _PastillaTareas extends StatelessWidget {
  const _PastillaTareas({
    required this.pendientes,
    required this.textoPendientes,
    required this.textoAlDia,
  });

  final int pendientes;
  final String textoPendientes;
  final String textoAlDia;

  @override
  Widget build(BuildContext context) {
    final alDia = pendientes == 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              alDia ? Icons.check_circle : Icons.assignment_outlined,
              size: 15,
              color: alDia ? AppColors.verdeBadge : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              alDia ? textoAlDia : textoPendientes,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
