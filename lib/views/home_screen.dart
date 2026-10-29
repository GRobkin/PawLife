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
import 'pet_detail_screen.dart';
import 'premium_screen.dart';
import 'profile_screen.dart';
import 'widgets/iniciar_paseo.dart';
import 'walk_history_screen.dart';
import 'widgets/pawlife_bottom_nav.dart';
import 'wearable/wearable_screen.dart';
import 'widgets/carrusel_hoy.dart';
import 'widgets/motion.dart';
import 'widgets/esqueletos.dart';
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
    PawLifeRepository.mascotasCambiaron.addListener(_cargarMascotas);
    _cargarMascotas();
    _cargarRecordatorios();
  }

  @override
  void dispose() {
    SeleccionMascota.id.removeListener(_cargarPaseos);
    PawLifeRepository.mascotasCambiaron.removeListener(_cargarMascotas);
    _scroll.dispose();
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

  /// El modo reloj es de Premium. Si la consulta falla (sin conexión) se
  /// trata como plan gratuito.
  Future<void> _abrirReloj() async {
    var premium = false;
    try {
      premium = (await _repo.fetchPremium())['activo'] == true;
    } catch (_) {}
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (premium) {
      await navigator.push(
        MaterialPageRoute(builder: (_) => const WearableScreen()),
      );
      return;
    }
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.premiumLockedWatch),
        action: SnackBarAction(
          label: t.premiumSee,
          onPressed: () => navigator.push(
            MaterialPageRoute(builder: (_) => PremiumScreen(repository: _repo)),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirPerfil(Mascota mascota) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PetDetailScreen(mascota: mascota)),
    );
    if (mounted) await _cargarMascotas();
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
        child: LayoutBuilder(
          builder: (context, caja) {
            _alturaPortada = (caja.maxHeight - 640).clamp(160.0, 360.0);
            return ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              children: [
                _buildTopBar(context),
                const SizedBox(height: 12),
                Text(
                  _saludo(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  t.todayAgenda,
                  style: TextStyle(color: context.textoSuave),
                ),
                const SizedBox(height: 20),
                _buildPetCard(),
                const SizedBox(height: 16),
                _buildStartWalkCard(context),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.activitySummary,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.only(left: 10),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WalkHistoryScreen(),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.viewWalkHistory),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildActivitySummary(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.todayTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (_recordatorios != null && hoy!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.mentaSuave,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextoGiratorio(
                          '${hoy.where((r) => r.completado).length}/${hoy.length}',
                          estilo: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: context.marca,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TransicionCarga(
                  child: _recordatorios == null
                      ? const EsqueletoTareaHoy(key: ValueKey('hoy-cargando'))
                      : hoy!.isEmpty
                      ? Container(
                          key: const ValueKey('hoy-vacio'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.tarjetaMenta,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: context.marca),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  t.noTasksToday,
                                  style: TextStyle(color: context.texto),
                                ),
                              ),
                            ],
                          ),
                        )
                      : CarruselHoy(
                          key: const ValueKey('hoy-tareas'),
                          textoMarcar: t.markDone,
                          textoPendiente: t.markPending,
                          tareas: [
                            for (final r in hoy)
                              TareaVista(
                                icono: switch (r.tipo) {
                                  'vacuna' => Icons.vaccines_outlined,
                                  'medicamento' => Icons.medication_outlined,
                                  _ => Icons.assignment_outlined,
                                },
                                titulo: r.mensaje,
                                detalle: r.completado
                                    ? t.completedLabel
                                    : formatTime(context, r.fecha),
                                hecha: r.completado,
                                alTocar: () => _marcarRecordatorio(r),
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
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
        // Sin menú lateral: era un icono que no abría nada. La marca va a la
        // izquierda y las acciones reales a la derecha.
        const Expanded(
          child: Align(alignment: Alignment.centerLeft, child: MarcaPawLife()),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context).wearableOpen,
          icon: const Icon(Icons.watch_outlined),
          onPressed: _abrirReloj,
        ),
        // El avatar es el único sitio desde el que se puede cerrar sesión.
        // Al hacerlo no hay que navegar a ningún lado: el AuthGate de
        // main.dart ve que la sesión se fue y vuelve solo a la bienvenida.
        // Igual que en Mascotas: el avatar abre el perfil, donde también
        // está cerrar sesión.
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: context.mentaSuave,
            child: ClipOval(
              child: fotoUrl == null
                  ? Icon(Icons.person, size: 18, color: context.marca)
                  : Image.network(
                      fotoUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Icon(Icons.person, size: 18, color: context.marca),
                    ),
            ),
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
  /// La foto crece cuando la pantalla es alta, para no dejar un hueco abajo.
  double _alturaPortada = 160;
  final _scroll = ScrollController();

  Widget _buildPetCard() {
    return ValueListenableBuilder<String?>(
      valueListenable: SeleccionMascota.id,
      builder: (context, _, _) =>
          TransicionCarga(child: _contenidoPetCard(context)),
    );
  }

  Widget _contenidoPetCard(BuildContext context) {
    {
      final t = AppLocalizations.of(context);
      final mascotas = _mascotas;
      final activa = mascotas == null
          ? null
          : SeleccionMascota.resolver(mascotas);

      if (activa != null) {
        return Presionable(
          child: Material(
            color: context.superficie,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              // La foto no navega: lo hacen los botones de las esquinas.
              onTap: null,
              child: PortadaMascota(
                mascota: activa,
                height: _alturaPortada,
                scroll: _scroll,
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
                  // Perfil de la mascota: botón redondo, igual que el de
                  // cambiar de mascota, con una huella.
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: t.petViewProfile,
                        onPressed: () => _abrirPerfil(activa),
                        icon: const Icon(Icons.pets, color: Colors.white),
                      ),
                    ),
                  ),
                  // Cambiar de mascota, solo si hay entre qué elegir.
                  if (mascotas != null && mascotas.length > 1)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: t.petSwitch,
                          onPressed: _cambiarMascota,
                          icon: const Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }

      if (mascotas == null) {
        return Esqueleto(alto: _alturaPortada, radio: 22);
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
    }
  }

  // -------------------------------------------------------------------
  // Única parte funcional de esta pantalla: iniciar el paseo
  // -------------------------------------------------------------------
  Widget _buildStartWalkCard(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Presionable(
      child: Material(
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
                PulsoSuave(
                  color: context.botonTexto,
                  child: Container(
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
                ),
              ],
            ),
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
