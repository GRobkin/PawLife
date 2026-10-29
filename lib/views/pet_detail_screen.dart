// views/pet_detail_screen.dart
//
// Perfil de una mascota. Es el centro de sus cuidados: desde aquí se ven las
// vacunas, los medicamentos y los paseos se filtran por mascotaId en la API.
// Aquí se consultan y se editan los cuidados de la mascota.

import 'package:flutter/material.dart';
import 'widgets/esqueletos.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../services/local_reminder_service.dart';
import '../services/walk_repository.dart';
import '../theme/app_palette.dart';
import 'care_form_screen.dart';
import 'pet_form_screen.dart';
import 'route_screen.dart';
import 'walk_detail_screen.dart';
import 'walk_history_screen.dart';
import 'visits_screen.dart';
import 'weight_history_screen.dart';
import 'widgets/weight_entry_dialog.dart';
import 'widgets/eliminar_mascota.dart';
import 'widgets/foto_mascota.dart';
import 'widgets/pawlife_bottom_nav.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key, required this.mascota});

  final Mascota mascota;

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
    with SingleTickerProviderStateMixin {
  final _repositorio = PawLifeRepository();

  // Los paseos tienen su propio repositorio porque además de leerlos hay que
  // convertir la WalkSession que produce el ViewModel al guardar.
  final _paseosRepo = WalkRepository();

  late final TabController _tabs = TabController(length: 5, vsync: this);

  late Mascota _mascota = widget.mascota;

  List<RegistroPeso>? _pesos;
  List<Vacuna>? _vacunas;
  List<Medicamento>? _medicamentos;
  List<Alimentacion>? _alimentaciones;
  List<Paseo>? _paseos;
  List<Recordatorio>? _recordatorios;
  List<VisitaVeterinaria>? _visitas;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _error = null);

    try {
      // Todo a la vez: son cinco colecciones distintas y en serie la pantalla
      // tardaría cinco viajes en estar completa.
      final resultados = await Future.wait([
        _repositorio.fetchPesos(_mascota.id),
        _repositorio.fetchVacunas(_mascota.id),
        _repositorio.fetchMedicamentos(_mascota.id),
        _repositorio.fetchAlimentaciones(_mascota.id),
        _paseosRepo.fetchPaseos(_mascota.id),
        _repositorio.fetchRecordatorios(soloPendientes: true),
        _repositorio.fetchVisitas(_mascota.id),
      ]);

      if (!mounted) return;
      setState(() {
        _pesos = resultados[0] as List<RegistroPeso>;
        _vacunas = resultados[1] as List<Vacuna>;
        _medicamentos = resultados[2] as List<Medicamento>;
        _alimentaciones = resultados[3] as List<Alimentacion>;
        _paseos = resultados[4] as List<Paseo>;
        // Los recordatorios cuelgan del usuario, no de la mascota, así que se
        // filtran aquí por mascotaId.
        _visitas = resultados[6] as List<VisitaVeterinaria>;
        _recordatorios = (resultados[5] as List<Recordatorio>)
            .where((r) => r.mascotaId == _mascota.id)
            .toList(growable: false);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = apiErrorText(AppLocalizations.of(context), e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _editar() async {
    final guardada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PetFormScreen(mascota: _mascota)),
    );

    if (guardada != true || !mounted) return;

    // Se vuelve a pedir la mascota porque el formulario pudo cambiar nombre,
    // foto o fecha, y esta pantalla tiene su propia copia.
    try {
      final actualizada = await _repositorio.fetchMascota(_mascota.id);
      if (!mounted) return;
      setState(() => _mascota = actualizada);
      await _cargar();
    } catch (_) {
      // Si falla la recarga, al menos los datos viejos siguen en pantalla.
    }
  }

  Future<void> _eliminar() async {
    if (await confirmarYEliminarMascota(context, _mascota)) {
      if (!mounted) return;
      // La mascota ya no existe, así que esta pantalla no tiene nada que
      // mostrar: se vuelve al listado, que se recarga solo al recibir el pop.
      Navigator.of(context).pop();
    }
  }

  Future<void> _registrarPeso() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          WeightEntryDialog(repository: _repositorio, mascotaId: _mascota.id),
    );
    if (saved == true && mounted) await _cargar();
  }

  Future<void> _abrirPesos() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WeightHistoryScreen(mascota: _mascota, repository: _repositorio),
      ),
    );
    if (mounted) await _cargar();
  }

  Future<void> _abrirVacuna([Vacuna? vacuna]) async {
    final guardada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            VaccineFormScreen(mascotaId: _mascota.id, vacuna: vacuna),
      ),
    );
    if (guardada == true && mounted) await _cargar();
  }

  Future<void> _abrirMedicamento([Medicamento? medicamento]) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MedicationFormScreen(
          mascotaId: _mascota.id,
          medicamento: medicamento,
        ),
      ),
    );
    if (guardado == true && mounted) await _cargar();
  }

  Future<void> _abrirAlimentacion() async {
    final guardada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FoodFormScreen(mascotaId: _mascota.id)),
    );
    if (guardada == true && mounted) await _cargar();
  }

  Future<bool> _confirmarBorrado(String nombre) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).deleteItemTitle(nombre)),
          content: Text(AppLocalizations.of(context).cannotBeUndone),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context).delete),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _borrarVacuna(Vacuna vacuna) async {
    if (!await _confirmarBorrado(vacuna.nombre)) return;
    try {
      await _repositorio.deleteVacuna(_mascota.id, vacuna.id);
      await LocalReminderService.instance.syncBestEffort(_repositorio);
      await _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).deleteError('$e')),
          ),
        );
      }
    }
  }

  Future<void> _borrarMedicamento(Medicamento medicamento) async {
    if (!await _confirmarBorrado(medicamento.nombre)) return;
    try {
      await _repositorio.deleteMedicamento(_mascota.id, medicamento.id);
      await LocalReminderService.instance.syncBestEffort(_repositorio);
      await _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).deleteError('$e')),
          ),
        );
      }
    }
  }

  Future<void> _borrarAlimentacion(Alimentacion alimentacion) async {
    if (!await _confirmarBorrado(alimentacion.tipoAlimento)) return;
    try {
      await _repositorio.deleteAlimentacion(_mascota.id, alimentacion.id);
      await _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).deleteError('$e')),
          ),
        );
      }
    }
  }

  RegistroPeso? get _ultimoPeso =>
      (_pesos == null || _pesos!.isEmpty) ? null : _pesos!.first;

  /// La visita futura más cercana que el dueño dejó agendada, si hay alguna.
  DateTime? get _proximaVisita {
    final hoy = DateTime.now();
    final futuras =
        (_visitas ?? const <VisitaVeterinaria>[])
            .map((v) => v.proximaFecha)
            .whereType<DateTime>()
            .where((f) => f.isAfter(hoy))
            .toList()
          ..sort();
    return futuras.isEmpty ? null : futuras.first;
  }

  Future<void> _abrirVisitas() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            VisitsScreen(mascota: _mascota, repository: _repositorio),
      ),
    );
    if (mounted) await _cargar();
  }

  Paseo? get _ultimoPaseo =>
      (_paseos == null || _paseos!.isEmpty) ? null : _paseos!.first;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.fondoPantalla,
      appBar: AppBar(
        backgroundColor: context.fondoPantalla,
        elevation: 0,
        foregroundColor: context.marca,
        title: Text('PawLife', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            tooltip: t.edit,
            onPressed: _editar,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: t.delete,
            onPressed: _eliminar,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      // NestedScrollView y no un ListView con el TabBarView dentro: así la
      // cabecera y el contenido de la pestaña comparten un único scroll.
      //
      // Antes la pestaña era un ListView de alto fijo metido en otro ListView,
      // y eso impedía arrastrar hacia arriba desde dentro de la pestaña: el
      // gesto lo capturaba la lista interna, que al estar ya arriba no tenía
      // a dónde ir y no lo propagaba al padre. La cabecera quedaba atrapada
      // fuera de la pantalla.
      body: _error != null
          ? _buildError()
          : RefreshIndicator(
              onRefresh: _cargar,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          _Portada(mascota: _mascota),
                          const SizedBox(height: 16),
                          _buildMetricas(),
                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    // El TabBar se queda pegado arriba al scrollear, para poder
                    // cambiar de pestaña sin volver a subir.
                    pinned: true,
                    delegate: _CabeceraPestanas(
                      TabBar(
                        controller: _tabs,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: context.marca,
                        unselectedLabelColor: context.textoSuave,
                        indicatorColor: context.marca,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Tab(text: t.tabSummary),
                          Tab(text: t.tabVaccines),
                          Tab(text: t.tabMedications),
                          Tab(text: t.tabFeeding),
                          Tab(text: t.tabWalks),
                        ],
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabs,
                  children: [
                    _buildResumen(),
                    _buildVacunas(),
                    _buildMedicamentos(),
                    _buildAlimentaciones(),
                    _buildPaseos(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.mascotas,
        onPaseo: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RouteScreen(mascotaId: _mascota.id),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 48, color: context.textoTenue),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textoSuave),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _cargar,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricas() {
    final t = AppLocalizations.of(context);
    final peso = _ultimoPeso;
    final paseo = _ultimoPaseo;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Metrica(
                icono: Icons.monitor_weight_outlined,
                rotulo: t.cellWeight,
                valor: peso == null ? '—' : _formatearKg(peso.valorKg),
                unidad: peso == null ? null : 'kg',
                insignia: peso == null
                    ? t.noRecord
                    : t.measuredWhen(_haceCuanto(peso.fecha)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Metrica(
                icono: Icons.directions_walk,
                rotulo: t.metricLastWalk,
                valor: paseo == null ? '—' : _haceCuanto(paseo.fechaInicio),
                insignia: paseo == null
                    ? t.noWalks
                    : '${(paseo.distanciaMetros / 1000).toStringAsFixed(1)} km',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Metrica(
                icono: Icons.calendar_today_outlined,
                rotulo: t.metricNextVet,
                valor: _proximaVisita == null
                    ? '—'
                    : MaterialLocalizations.of(
                        context,
                      ).formatShortMonthDay(_proximaVisita!),
                insignia: _proximaVisita == null
                    ? t.notScheduled
                    : MaterialLocalizations.of(
                        context,
                      ).formatYear(_proximaVisita!),
                atenuada: _proximaVisita == null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _BotonMetrica(onTap: _registrarPeso)),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _abrirVisitas,
            icon: const Icon(Icons.local_hospital_outlined),
            label: Text(t.visitsTitle),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _abrirPesos,
            icon: const Icon(Icons.monitor_weight_outlined),
            label: Text(t.weightHistory),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- pestañas

  Widget _buildResumen() {
    final t = AppLocalizations.of(context);
    final recordatorios = _recordatorios;
    final paseos = _paseos;

    if (recordatorios == null || paseos == null) {
      return const _CuerpoPestana(
        clave: "resumen",
        arriba: true,
        child: EsqueletoFilas(),
      );
    }

    final proximaVacuna = _proximaVacuna();

    return ListView(
      key: const PageStorageKey("resumen"),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        _TituloSeccion(t.upcomingCare),
        const SizedBox(height: 12),
        if (recordatorios.isEmpty && proximaVacuna == null)
          _Vacio(icono: Icons.event_available_outlined, texto: t.nothingPending)
        else ...[
          if (proximaVacuna != null)
            _FilaCuidado(
              icono: Icons.vaccines_outlined,
              titulo: proximaVacuna.nombre,
              detalle: t.kindWhen(
                t.kindVaccine,
                _cuandoToca(proximaVacuna.proximaFecha),
              ),
            ),
          for (final recordatorio in recordatorios)
            _FilaCuidado(
              icono: Icons.notifications_outlined,
              titulo: recordatorio.mensaje,
              detalle: t.kindWhen(
                _tipoRecordatorio(t, recordatorio.tipo),
                _cuandoToca(recordatorio.fecha),
              ),
            ),
        ],
        const SizedBox(height: 26),
        _TituloSeccion(t.recentActivity),
        const SizedBox(height: 12),
        if (paseos.isEmpty)
          _Vacio(icono: Icons.directions_walk, texto: t.noWalksRecorded)
        else
          for (final paseo in paseos.take(5))
            _FilaCuidado(
              icono: Icons.directions_walk,
              titulo: t.kmIn(
                (paseo.distanciaMetros / 1000).toStringAsFixed(2),
                _duracion(paseo.duracion),
              ),
              detalle: _fechaLarga(paseo.fechaInicio),
            ),
      ],
    );
  }

  Widget _buildVacunas() {
    final t = AppLocalizations.of(context);
    final vacunas = _vacunas;
    if (vacunas == null) {
      return const _CuerpoPestana(
        clave: "vacunas",
        arriba: true,
        child: EsqueletoFilas(),
      );
    }

    final ordenadas = [...vacunas]
      ..sort((a, b) => a.proximaFecha.compareTo(b.proximaFecha));

    return ListView(
      key: const PageStorageKey("vacunas"),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        _BotonAgregar(
          icono: Icons.add,
          texto: t.addVaccine,
          onTap: _abrirVacuna,
        ),
        const SizedBox(height: 14),
        if (ordenadas.isEmpty)
          _Vacio(icono: Icons.vaccines_outlined, texto: t.noVaccinesRecorded),
        for (final vacuna in ordenadas)
          _FilaCuidado(
            icono: Icons.vaccines_outlined,
            titulo: vacuna.nombre,
            detalle: t.appliedOnNext(
              formatDate(context, vacuna.fechaAplicacion),
              _cuandoToca(vacuna.proximaFecha),
            ),
            alerta: vacuna.proximaFecha.isBefore(DateTime.now()),
            onTap: () => _abrirVacuna(vacuna),
            onDelete: () => _borrarVacuna(vacuna),
          ),
      ],
    );
  }

  Widget _buildMedicamentos() {
    final t = AppLocalizations.of(context);
    final medicamentos = _medicamentos;
    if (medicamentos == null) {
      return const _CuerpoPestana(
        clave: "medicamentos",
        arriba: true,
        child: EsqueletoFilas(),
      );
    }

    return ListView(
      key: const PageStorageKey("medicamentos"),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        _BotonAgregar(
          icono: Icons.add,
          texto: t.addMedication,
          onTap: _abrirMedicamento,
        ),
        const SizedBox(height: 14),
        if (medicamentos.isEmpty)
          _Vacio(
            icono: Icons.medication_outlined,
            texto: t.noMedicationsRecorded,
          ),
        for (final medicamento in medicamentos)
          _FilaCuidado(
            icono: Icons.medication_outlined,
            titulo: '${medicamento.nombre} · ${medicamento.dosis}',
            detalle: medicamento.activo
                ? t.activeWithTimes(medicamento.horarios.join(', '))
                : t.finished,
            atenuada: !medicamento.activo,
            onTap: () => _abrirMedicamento(medicamento),
            onDelete: () => _borrarMedicamento(medicamento),
          ),
      ],
    );
  }

  Widget _buildAlimentaciones() {
    final t = AppLocalizations.of(context);
    final alimentaciones = _alimentaciones;
    if (alimentaciones == null) {
      return const _CuerpoPestana(
        clave: "alimentaciones",
        arriba: true,
        child: EsqueletoFilas(),
      );
    }

    final ordenadas = [...alimentaciones]
      ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    return ListView(
      key: const PageStorageKey('alimentaciones'),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        _BotonAgregar(
          icono: Icons.add,
          texto: t.logFeeding,
          onTap: _abrirAlimentacion,
        ),
        const SizedBox(height: 14),
        if (ordenadas.isEmpty)
          _Vacio(icono: Icons.restaurant_outlined, texto: t.noFeedingsRecorded),
        for (final alimentacion in ordenadas)
          _FilaCuidado(
            icono: Icons.restaurant_outlined,
            titulo:
                '${alimentacion.tipoAlimento} · ${alimentacion.cantidadGramos.toStringAsFixed(0)} g',
            detalle: _fechaLarga(alimentacion.fechaHora),
            onDelete: () => _borrarAlimentacion(alimentacion),
          ),
      ],
    );
  }

  Widget _buildPaseos() {
    final t = AppLocalizations.of(context);
    final paseos = _paseos;
    if (paseos == null) {
      return const _CuerpoPestana(
        clave: "paseos",
        arriba: true,
        child: EsqueletoFilas(),
      );
    }

    if (paseos.isEmpty) {
      // Era el único estado vacío que quedaba como cuerpo directo de una
      // pestaña: las demás lo tienen dentro de su ListView, junto al botón
      // de añadir, y por eso solo esta se desbordaba.
      return _CuerpoPestana(
        clave: "paseos",
        child: _Vacio(icono: Icons.directions_walk, texto: t.noWalksYetHint),
      );
    }

    return ListView(
      key: const PageStorageKey("paseos"),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        TextButton.icon(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WalkHistoryScreen(mascota: _mascota),
              ),
            );
            if (mounted) await _cargar();
          },
          icon: const Icon(Icons.history),
          label: Text(t.openWalkHistory),
        ),
        for (final paseo in paseos)
          _FilaCuidado(
            icono: Icons.directions_walk,
            titulo: '${(paseo.distanciaMetros / 1000).toStringAsFixed(2)} km',
            detalle:
                '${_fechaLarga(paseo.fechaInicio)} · '
                '${_duracion(paseo.duracion)} · '
                '${t.maxSpeedKmh(paseo.velocidadMaximaKmh.toStringAsFixed(1))}',
            onTap: () async {
              final deleted = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      WalkDetailScreen(paseo: paseo, mascota: _mascota),
                ),
              );
              if (mounted && deleted == true) await _cargar();
            },
          ),
      ],
    );
  }

  Vacuna? _proximaVacuna() {
    final vacunas = _vacunas;
    if (vacunas == null || vacunas.isEmpty) return null;

    final ordenadas = [...vacunas]
      ..sort((a, b) => a.proximaFecha.compareTo(b.proximaFecha));

    return ordenadas.first;
  }

  // ------------------------------------------------------------- formatos

  static String _formatearKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);

  String _duracion(Duration d) {
    final t = AppLocalizations.of(context);
    if (d.inHours > 0) {
      return t.durationHoursMinutes(
        '${d.inHours}',
        '${d.inMinutes.remainder(60)}',
      );
    }

    return t.minutesShort(d.inMinutes);
  }

  /// "hoy", "ayer", "hace 3 días", "hace 2 meses".
  String _haceCuanto(DateTime fecha) {
    final t = AppLocalizations.of(context);
    final dias = DateTime.now().difference(fecha).inDays;

    if (dias <= 0) return t.relToday;
    if (dias == 1) return t.relYesterday;
    if (dias < 30) return t.relDaysAgo(dias);

    return t.relMonthsAgo(dias ~/ 30);
  }

  /// "en 3 días", "hoy", "vencida hace 5 días".
  String _cuandoToca(DateTime fecha) {
    final t = AppLocalizations.of(context);
    final dias = fecha.difference(DateTime.now()).inDays;

    if (dias < 0) return t.relOverdueDays(-dias);
    if (dias == 0) return t.relToday;
    if (dias == 1) return t.relTomorrow;

    return t.relInDays(dias);
  }

  /// El tipo viene del servidor ("vacuna", "tarea"…); lo desconocido se
  /// muestra tal cual.
  static String _tipoRecordatorio(AppLocalizations t, String tipo) =>
      switch (tipo) {
        'vacuna' => t.kindVaccine,
        'tarea' => t.kindTask,
        'inactividad' => t.kindInactivity,
        'medicamento' => t.medicationLabel,
        _ => tipo,
      };

  String _fechaLarga(DateTime f) => formatDayMonthTime(context, f);
}

/// Deja el TabBar fijo arriba mientras se scrollea el contenido de la pestaña.
///
/// Hace falta un delegado propio porque SliverPersistentHeader necesita saber
/// de antemano cuánto mide, y un TabBar no lo dice: se le pregunta a su
/// `preferredSize`.
class _CabeceraPestanas extends SliverPersistentHeaderDelegate {
  const _CabeceraPestanas(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Fondo opaco: sin él, el contenido de la pestaña se vería pasar por
    // detrás de los rótulos al scrollear.
    return ColoredBox(color: context.fondoPantalla, child: tabBar);
  }

  @override
  bool shouldRebuild(_CabeceraPestanas anterior) => anterior.tabBar != tabBar;
}

/// Foto grande con el nombre encima, como en el prototipo.
class _Portada extends StatelessWidget {
  const _Portada({required this.mascota});

  final Mascota mascota;

  @override
  Widget build(BuildContext context) {
    final foto = proveedorDeFoto(mascota.fotoUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          SizedBox(
            height: 210,
            width: double.infinity,
            child: Hero(
              tag: 'foto-mascota-${mascota.id}',
              child: foto == null
                  ? const _PortadaVacia()
                  : Image(
                      image: foto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _PortadaVacia(),
                    ),
            ),
          ),
          // Velo oscuro solo en la mitad inferior: sin él, el nombre en blanco
          // desaparece sobre una foto clara.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mascota.nombre,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  mascota.subtituloLocalizado(AppLocalizations.of(context)),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortadaVacia extends StatelessWidget {
  const _PortadaVacia();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8D9C0), Color(0xFFD5E3D2)],
        ),
      ),
      child: Center(child: Icon(Icons.pets, size: 64, color: Colors.white54)),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.icono,
    required this.rotulo,
    required this.valor,
    this.unidad,
    this.insignia,
    this.atenuada = false,
  });

  final IconData icono;
  final String rotulo;
  final String valor;
  final String? unidad;
  final String? insignia;
  final bool atenuada;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 14, color: context.textoTenue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  rotulo,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: context.textoTenue,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valor,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: atenuada ? context.textoTenue : context.texto,
                ),
              ),
              if (unidad != null) ...[
                const SizedBox(width: 3),
                Text(
                  unidad!,
                  style: TextStyle(fontSize: 13, color: context.textoSuave),
                ),
              ],
            ],
          ),
          if (insignia != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: atenuada ? context.rellenoNeutro : context.mentaSuave,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                insignia!,
                style: TextStyle(
                  fontSize: 11,
                  color: atenuada ? context.textoTenue : context.marca,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// La cuarta celda del cuadro de métricas: un botón para registrar peso.
class _BotonMetrica extends StatelessWidget {
  const _BotonMetrica({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.bordeSuave,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, color: context.textoSuave),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).registerWeightCaps,
              style: TextStyle(
                fontSize: 10,
                color: context.textoSuave,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(texto, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _FilaCuidado extends StatelessWidget {
  const _FilaCuidado({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.alerta = false,
    this.atenuada = false,
    this.onTap,
    this.onDelete,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final bool alerta;
  final bool atenuada;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.superficie,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: alerta ? context.errorFondo : context.relleno,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icono,
                size: 18,
                color: alerta ? context.errorIcono : context.marca,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: atenuada ? context.textoTenue : context.texto,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detalle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: alerta ? context.errorIcono : context.textoSuave,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: AppLocalizations.of(context).delete,
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: context.textoTenue),
              ),
          ],
        ),
      ),
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  const _BotonAgregar({
    required this.icono,
    required this.texto,
    required this.onTap,
  });
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onTap,
    icon: Icon(icono),
    label: Text(texto),
    style: FilledButton.styleFrom(
      backgroundColor: context.botonFondo,
      foregroundColor: context.botonTexto,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

/// Cuerpo de pestaña para contenido que no scrollea solo: el indicador de
/// carga o un estado vacío.
///
/// Dentro del NestedScrollView el cuerpo de cada pestaña TIENE que ser
/// scrollable. Un Center suelto recibe la altura que queda bajo la cabecera,
/// que con la portada desplegada es muy poca: el contenido se desbordaba
/// ("BOTTOM OVERFLOWED BY 95 PIXELS") y además no se podía arrastrar para
/// plegar la cabecera y ganar espacio.
///
/// SliverFillRemaining con hasScrollBody: false centra el contenido cuando
/// sobra sitio y, cuando no, lo deja scrollear en vez de desbordarse.
class _CuerpoPestana extends StatelessWidget {
  const _CuerpoPestana({
    required this.clave,
    required this.child,
    this.arriba = false,
  });

  /// Los esqueletos van arriba, donde aparecerá la lista; los vacíos, centrados.
  final bool arriba;

  /// La misma clave que usa la lista de esa pestaña, para que la posición de
  /// scroll se guarde en un único sitio pase por el estado que pase.
  final String clave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: PageStorageKey(clave),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: arriba
              ? Align(alignment: Alignment.topCenter, child: child)
              : Center(child: child),
        ),
      ],
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 40, color: context.textoTenue),
            const SizedBox(height: 14),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textoSuave, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
