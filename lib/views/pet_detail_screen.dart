// views/pet_detail_screen.dart
//
// Perfil de una mascota. Es el centro de sus cuidados: desde aquí se ven las
// vacunas, los medicamentos y los paseos, que en el backend cuelgan todos de
// users/{uid}/mascotas/{id}/...
//
// Las pestañas de vacunas, medicamentos y paseos son de solo lectura por
// ahora: muestran datos reales, pero darlos de alta necesita sus propios
// formularios, que todavía no existen. El único registro que se puede crear
// desde aquí es el de peso, con el botón "Registrar peso".

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../services/walk_repository.dart';
import '../theme/app_colors.dart';
import 'pet_form_screen.dart';
import 'route_screen.dart';
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

  late final TabController _tabs = TabController(length: 4, vsync: this);

  late Mascota _mascota = widget.mascota;

  List<RegistroPeso>? _pesos;
  List<Vacuna>? _vacunas;
  List<Medicamento>? _medicamentos;
  List<Paseo>? _paseos;
  List<Recordatorio>? _recordatorios;
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
        _paseosRepo.fetchPaseos(_mascota.id, limite: 10),
        _repositorio.fetchRecordatorios(soloPendientes: true),
      ]);

      if (!mounted) return;
      setState(() {
        _pesos = resultados[0] as List<RegistroPeso>;
        _vacunas = resultados[1] as List<Vacuna>;
        _medicamentos = resultados[2] as List<Medicamento>;
        _paseos = resultados[3] as List<Paseo>;
        // Los recordatorios cuelgan del usuario, no de la mascota, así que se
        // filtran aquí por mascotaId.
        _recordatorios = (resultados[4] as List<Recordatorio>)
            .where((r) => r.mascotaId == _mascota.id)
            .toList(growable: false);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
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
    final valor = await showDialog<double>(
      context: context,
      builder: (_) => const _DialogoPeso(),
    );

    if (valor == null || !mounted) return;

    try {
      await _repositorio.createPeso(_mascota.id, valorKg: valor);
      await _cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar el peso: $e')));
    }
  }

  RegistroPeso? get _ultimoPeso =>
      (_pesos == null || _pesos!.isEmpty) ? null : _pesos!.first;

  Paseo? get _ultimoPaseo =>
      (_paseos == null || _paseos!.isEmpty) ? null : _paseos!.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        elevation: 0,
        foregroundColor: AppColors.verdeOscuro,
        title: const Text(
          'PawLife',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: _editar,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Eliminar',
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
                        labelColor: AppColors.verdeOscuro,
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: AppColors.verdeOscuro,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: const [
                          Tab(text: 'Resumen'),
                          Tab(text: 'Vacunas'),
                          Tab(text: 'Medicamentos'),
                          Tab(text: 'Paseos'),
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
            const Icon(Icons.cloud_off, size: 48, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricas() {
    final peso = _ultimoPeso;
    final paseo = _ultimoPaseo;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Metrica(
                icono: Icons.monitor_weight_outlined,
                rotulo: 'PESO',
                valor: peso == null ? '—' : _formatearKg(peso.valorKg),
                unidad: peso == null ? null : 'kg',
                insignia: peso == null
                    ? 'Sin registro'
                    : 'Medido ${_haceCuanto(peso.fecha)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Metrica(
                icono: Icons.directions_walk,
                rotulo: 'ÚLTIMO PASEO',
                valor: paseo == null ? '—' : _haceCuanto(paseo.fechaInicio),
                insignia: paseo == null
                    ? 'Sin paseos'
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
                rotulo: 'PRÓXIMA VISITA AL VET',
                valor: '—',
                // Pendiente: todavía no existe el concepto de visita
                // veterinaria como entidad, así que no hay de dónde sacar la
                // fecha. Se deja el hueco a la vista para no prometer un dato
                // que la app no tiene.
                insignia: 'Sin agendar',
                atenuada: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _BotonMetrica(onTap: _registrarPeso)),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------- pestañas

  Widget _buildResumen() {
    final recordatorios = _recordatorios;
    final paseos = _paseos;

    if (recordatorios == null || paseos == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final proximaVacuna = _proximaVacuna();

    return ListView(
      key: const PageStorageKey("resumen"),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        const _TituloSeccion('Próximos cuidados'),
        const SizedBox(height: 12),
        if (recordatorios.isEmpty && proximaVacuna == null)
          const _Vacio(
            icono: Icons.event_available_outlined,
            texto: 'No hay nada pendiente.',
          )
        else ...[
          if (proximaVacuna != null)
            _FilaCuidado(
              icono: Icons.vaccines_outlined,
              titulo: proximaVacuna.nombre,
              detalle: 'Vacuna · ${_cuandoToca(proximaVacuna.proximaFecha)}',
            ),
          for (final recordatorio in recordatorios)
            _FilaCuidado(
              icono: Icons.notifications_outlined,
              titulo: recordatorio.mensaje,
              detalle:
                  '${recordatorio.tipo} · ${_cuandoToca(recordatorio.fecha)}',
            ),
        ],
        const SizedBox(height: 26),
        const _TituloSeccion('Actividad reciente'),
        const SizedBox(height: 12),
        if (paseos.isEmpty)
          const _Vacio(
            icono: Icons.directions_walk,
            texto: 'Todavía no hay paseos registrados.',
          )
        else
          for (final paseo in paseos.take(5))
            _FilaCuidado(
              icono: Icons.directions_walk,
              titulo:
                  '${(paseo.distanciaMetros / 1000).toStringAsFixed(2)} km en '
                  '${_duracion(paseo.duracion)}',
              detalle: _fechaLarga(paseo.fechaInicio),
            ),
      ],
    );
  }

  Widget _buildVacunas() {
    final vacunas = _vacunas;
    if (vacunas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vacunas.isEmpty) {
      return const _Vacio(
        icono: Icons.vaccines_outlined,
        texto:
            'Sin vacunas registradas.\nLa pantalla para darlas de alta '
            'todavía no está hecha.',
      );
    }

    final ordenadas = [...vacunas]
      ..sort((a, b) => a.proximaFecha.compareTo(b.proximaFecha));

    return ListView(
      key: const PageStorageKey("vacunas"),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        for (final vacuna in ordenadas)
          _FilaCuidado(
            icono: Icons.vaccines_outlined,
            titulo: vacuna.nombre,
            detalle:
                'Aplicada el ${_fechaCorta(vacuna.fechaAplicacion)} · '
                'próxima ${_cuandoToca(vacuna.proximaFecha)}',
            alerta: vacuna.proximaFecha.isBefore(DateTime.now()),
          ),
      ],
    );
  }

  Widget _buildMedicamentos() {
    final medicamentos = _medicamentos;
    if (medicamentos == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (medicamentos.isEmpty) {
      return const _Vacio(
        icono: Icons.medication_outlined,
        texto:
            'Sin medicamentos registrados.\nLa pantalla para darlos de alta '
            'todavía no está hecha.',
      );
    }

    return ListView(
      key: const PageStorageKey("medicamentos"),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        for (final medicamento in medicamentos)
          _FilaCuidado(
            icono: Icons.medication_outlined,
            titulo: '${medicamento.nombre} · ${medicamento.dosis}',
            detalle: medicamento.activo
                ? 'Activo · ${medicamento.horarios.join(', ')}'
                : 'Finalizado',
            atenuada: !medicamento.activo,
          ),
      ],
    );
  }

  Widget _buildPaseos() {
    final paseos = _paseos;
    if (paseos == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paseos.isEmpty) {
      return const _Vacio(
        icono: Icons.directions_walk,
        texto:
            'Todavía no hay paseos.\nUsá el botón verde de abajo para '
            'registrar uno.',
      );
    }

    return ListView(
      key: const PageStorageKey("paseos"),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      children: [
        for (final paseo in paseos)
          _FilaCuidado(
            icono: Icons.directions_walk,
            titulo: '${(paseo.distanciaMetros / 1000).toStringAsFixed(2)} km',
            detalle:
                '${_fechaLarga(paseo.fechaInicio)} · '
                '${_duracion(paseo.duracion)} · '
                'máx ${paseo.velocidadMaximaKmh.toStringAsFixed(1)} km/h',
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

  static String _duracion(Duration d) {
    if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes.remainder(60)} min';

    return '${d.inMinutes} min';
  }

  /// "hoy", "ayer", "hace 3 días", "hace 2 meses".
  static String _haceCuanto(DateTime fecha) {
    final dias = DateTime.now().difference(fecha).inDays;

    if (dias <= 0) return 'hoy';
    if (dias == 1) return 'ayer';
    if (dias < 30) return 'hace $dias días';

    final meses = dias ~/ 30;

    return 'hace $meses ${meses == 1 ? 'mes' : 'meses'}';
  }

  /// "en 3 días", "hoy", "vencida hace 5 días".
  static String _cuandoToca(DateTime fecha) {
    final dias = fecha.difference(DateTime.now()).inDays;

    if (dias < 0) {
      final atraso = -dias;

      return 'vencida hace $atraso ${atraso == 1 ? 'día' : 'días'}';
    }
    if (dias == 0) return 'hoy';
    if (dias == 1) return 'mañana';

    return 'en $dias días';
  }

  static const _meses = [
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

  static String _fechaCorta(DateTime f) =>
      '${f.day} ${_meses[f.month - 1]} ${f.year}';

  static String _fechaLarga(DateTime f) =>
      '${f.day} ${_meses[f.month - 1]}, '
      '${f.hour.toString().padLeft(2, '0')}:'
      '${f.minute.toString().padLeft(2, '0')}';
}

/// Diálogo para anotar un peso. Devuelve los kg, o null si se canceló.
///
/// Es un StatefulWidget y no un AlertDialog suelto porque así el controlador
/// del campo lo crea y lo libera el propio diálogo, en su dispose().
///
/// Creándolo fuera y liberándolo justo después de `await showDialog` se
/// rompía: showDialog devuelve en cuanto se hace pop, pero el TextField sigue
/// vivo durante la animación de salida, así que se quedaba apuntando a un
/// controlador ya destruido y Flutter lanzaba
/// "'_dependents.isEmpty': is not true".
class _DialogoPeso extends StatefulWidget {
  const _DialogoPeso();

  @override
  State<_DialogoPeso> createState() => _DialogoPesoState();
}

class _DialogoPesoState extends State<_DialogoPeso> {
  final _controlador = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _guardar() {
    final texto = _controlador.text.trim().replaceAll(',', '.');
    final kg = double.tryParse(texto);

    // Antes, con un valor inválido el botón simplemente no hacía nada y no
    // había forma de saber por qué.
    if (kg == null) {
      setState(() => _error = 'Escribí un número.');
      return;
    }
    if (kg <= 0 || kg > 200) {
      setState(() => _error = 'Tiene que estar entre 0 y 200 kg.');
      return;
    }

    Navigator.of(context).pop(kg);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar peso'),
      content: TextField(
        controller: _controlador,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        onSubmitted: (_) => _guardar(),
        decoration: InputDecoration(
          suffixText: 'kg',
          hintText: '0.0',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
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
    return ColoredBox(color: AppColors.fondo, child: tabBar);
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
            child: foto == null
                ? const _PortadaVacia()
                : Image(
                    image: foto,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _PortadaVacia(),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mascota.subtitulo,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 14, color: Colors.black45),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  rotulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
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
                  color: atenuada ? Colors.black38 : Colors.black87,
                ),
              ),
              if (unidad != null) ...[
                const SizedBox(width: 3),
                Text(
                  unidad!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ],
          ),
          if (insignia != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: atenuada
                    ? const Color(0xFFF0F1F3)
                    : AppColors.verdeSuave,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                insignia!,
                style: TextStyle(
                  fontSize: 11,
                  color: atenuada ? Colors.black45 : AppColors.verdeOscuro,
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
          border: Border.all(color: AppColors.borde, style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.black54),
            SizedBox(height: 8),
            Text(
              'REGISTRAR PESO',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
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
    return Text(
      texto,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }
}

class _FilaCuidado extends StatelessWidget {
  const _FilaCuidado({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.alerta = false,
    this.atenuada = false,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final bool alerta;
  final bool atenuada;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: alerta ? AppColors.alertaSuave : const Color(0xFFEDF2F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icono,
              size: 18,
              color: alerta ? AppColors.alerta : AppColors.verdeOscuro,
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
                    color: atenuada ? Colors.black45 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: alerta ? AppColors.alerta : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            Icon(icono, size: 40, color: Colors.black26),
            const SizedBox(height: 14),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
