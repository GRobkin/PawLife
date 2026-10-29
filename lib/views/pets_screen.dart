// views/pets_screen.dart
//
// Listado de mascotas del usuario. Es la entrada a todo lo demás: vacunas,
// medicamentos, pesos y paseos se relacionan por mascotaId en la API.
//
// Cada tarjeta resume el estado de salud. Eso obliga a pedir también las
// vacunas y los pesos de cada mascota, así que la carga hace varias llamadas
// en paralelo (ver _cargar). Con la cantidad de mascotas que tiene una persona
// real es barato; si algún día fueran decenas, habría que añadir un endpoint
// que devolviera el resumen ya calculado.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/pawlife_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'pet_detail_screen.dart';
import 'pet_form_screen.dart';
import 'widgets/eliminar_mascota.dart';
import 'widgets/iniciar_paseo.dart';
import 'widgets/esqueletos.dart';
import 'widgets/motion.dart';
import 'widgets/estado_vacio.dart';
import 'widgets/foto_mascota.dart';
import 'widgets/pawlife_bottom_nav.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key, this.repository, this.userPhotoUrl});

  /// Para pruebas: repositorio y foto de usuario inyectados.
  final PawLifeRepository? repository;
  final String? userPhotoUrl;

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  late final _repositorio = widget.repository ?? PawLifeRepository();

  List<_ResumenMascota>? _mascotas;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _error = null);

    try {
      final mascotas = await _repositorio.fetchMascotas();

      // Las vacunas y los pesos de todas las mascotas se piden a la vez en vez
      // de una tras otra: en serie, con cuatro mascotas serían ocho viajes
      // encadenados y la pantalla tardaría casi un segundo en aparecer.
      final resumenes = await Future.wait(
        mascotas.map((mascota) async {
          final resultados = await Future.wait([
            _repositorio.fetchVacunas(mascota.id),
            _repositorio.fetchPesos(mascota.id),
          ]);

          final vacunas = resultados[0] as List<Vacuna>;
          final pesos = resultados[1] as List<RegistroPeso>;

          return _ResumenMascota(
            mascota: mascota,
            proximaVacuna: _proximaVacuna(vacunas),
            // El backend devuelve los pesos de más reciente a más antiguo.
            ultimoPeso: pesos.isEmpty ? null : pesos.first,
          );
        }),
      );

      if (!mounted) return;
      setState(() => _mascotas = resumenes);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = apiErrorText(AppLocalizations.of(context), e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  /// La vacuna cuya próxima dosis toca antes. Es la que define el estado.
  static Vacuna? _proximaVacuna(List<Vacuna> vacunas) {
    if (vacunas.isEmpty) return null;

    final ordenadas = [...vacunas]
      ..sort((a, b) => a.proximaFecha.compareTo(b.proximaFecha));

    return ordenadas.first;
  }

  Future<void> _abrirFormulario({Mascota? mascota}) async {
    final guardada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PetFormScreen(mascota: mascota)),
    );

    if (guardada == true) await _cargar();
  }

  Future<void> _abrirDetalle(Mascota mascota) async {
    // El detalle puede editar o borrar, así que al volver se recarga: si no,
    // la tarjeta seguiría mostrando el nombre viejo.
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PetDetailScreen(mascota: mascota)),
    );

    if (mounted) await _cargar();
  }

  Future<void> _confirmarBorrado(Mascota mascota) async {
    if (await confirmarYEliminarMascota(
      context,
      mascota,
      repositorio: _repositorio,
    )) {
      await _cargar();
    }
  }

  /// El botón central de paseo necesita una mascota a la que atribuirlo.
  /// Reaprovecha la lista ya cargada para no volver a pedirla.
  void _iniciarPaseo() {
    iniciarPaseo(
      context,
      mascotas: _mascotas?.map((r) => r.mascota).toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.fondoPantalla,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: TransicionCarga(
                child: KeyedSubtree(
                  key: ValueKey(_mascotas == null),
                  child: _buildContenido(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.mascotas,
        onPaseo: _iniciarPaseo,
      ),
    );
  }

  Widget _buildTopBar() {
    final inyectada = widget.userPhotoUrl;
    final fotoUrl = inyectada != null
        ? (inyectada.isEmpty ? null : inyectada)
        : AuthService().currentUser?.photoURL;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'PawLife',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          CircleAvatar(
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
        ],
      ),
    );
  }

  Widget _buildContenido() {
    final t = AppLocalizations.of(context);
    if (_error != null) {
      return EstadoVacio(
        icono: Icons.cloud_off,
        titulo: t.petsLoadError,
        detalle: _error!,
        accion: t.retry,
        onAccion: _cargar,
      );
    }

    final mascotas = _mascotas;
    if (mascotas == null) {
      return const EsqueletoMascotas();
    }

    if (mascotas.isEmpty) {
      return EstadoVacio(
        icono: Icons.pets,
        titulo: t.petsEmptyTitle,
        detalle: t.petsEmptyBody,
        accion: t.addPet,
        onAccion: () => _abrirFormulario(),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
        children: [
          Text(t.myPets, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(t.myPetsSubtitle, style: TextStyle(color: context.textoSuave)),
          const SizedBox(height: 20),
          for (final (indice, resumen) in mascotas.indexed) ...[
            AparecerAlEntrar(
              indice: indice,
              child: Presionable(
                child: _TarjetaMascota(
                  resumen: resumen,
                  onTap: () => _abrirDetalle(resumen.mascota),
                  onEditar: () => _abrirFormulario(mascota: resumen.mascota),
                  onEliminar: () => _confirmarBorrado(resumen.mascota),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Presionable(child: _TarjetaAgregar(onTap: () => _abrirFormulario())),
        ],
      ),
    );
  }
}

/// Una mascota con lo necesario para pintar su tarjeta sin volver a pedir nada.
class _ResumenMascota {
  const _ResumenMascota({
    required this.mascota,
    this.proximaVacuna,
    this.ultimoPeso,
  });

  final Mascota mascota;
  final Vacuna? proximaVacuna;
  final RegistroPeso? ultimoPeso;

  /// Estado de salud derivado de la vacuna más próxima.
  _EstadoSalud get estado {
    final vacuna = proximaVacuna;
    if (vacuna == null) return _EstadoSalud.sinVacunas;

    final dias = vacuna.proximaFecha.difference(DateTime.now()).inDays;

    if (dias < 0) return _EstadoSalud.vencida;

    // `anticipacionDias` es cuántos días antes quiere avisar el usuario.
    if (dias <= vacuna.anticipacionDias) return _EstadoSalud.proxima;

    return _EstadoSalud.sano;
  }
}

enum _EstadoSalud { sinVacunas, vencida, proxima, sano }

class _Estado {
  const _Estado(this.texto, this.icono, this.color);

  final String texto;
  final IconData icono;
  final Color color;

  factory _Estado.de(BuildContext context, _EstadoSalud estado) {
    final t = AppLocalizations.of(context);
    return switch (estado) {
      _EstadoSalud.sinVacunas => _Estado(
        t.statusNoVaccines,
        Icons.info_outline,
        context.textoSuave,
      ),
      _EstadoSalud.vencida => _Estado(
        t.statusOverdue,
        Icons.error_outline,
        context.alertaTexto,
      ),
      _EstadoSalud.proxima => _Estado(
        t.statusDueSoon,
        Icons.schedule,
        AppColors.aviso,
      ),
      _EstadoSalud.sano => _Estado(
        t.statusHealthy,
        Icons.check_circle_outline,
        AppColors.verdeAcento,
      ),
    };
  }
}

class _TarjetaMascota extends StatelessWidget {
  const _TarjetaMascota({
    required this.resumen,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  final _ResumenMascota resumen;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final mascota = resumen.mascota;
    final estado = _Estado.de(context, resumen.estado);
    final peso = resumen.ultimoPeso;
    final vacuna = resumen.proximaVacuna;

    return Material(
      color: context.superficie,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
          child: Column(
            children: [
              Row(
                children: [
                  // El punto de color resume el estado de salud de un vistazo.
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AvatarMascota(mascota: mascota, radio: 30),
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: estado.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.superficie,
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mascota.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mascota.subtituloLocalizado(t),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textoSuave,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MenuMascota(onEditar: onEditar, onEliminar: onEliminar),
                ],
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _Celda(
                            rotulo: t.cellStatus,
                            valor: estado.texto,
                            icono: estado.icono,
                            color: estado.color,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _Celda(
                            rotulo: t.cellWeight,
                            valor: peso == null
                                ? t.noRecord
                                : '${_formatearKg(peso.valorKg)} kg',
                            icono: Icons.monitor_weight_outlined,
                            color: peso == null
                                ? context.textoTenue
                                : context.texto,
                          ),
                        ),
                      ],
                    ),
                    if (vacuna != null) ...[
                      const SizedBox(height: 10),
                      _Celda(
                        rotulo: t.cellNextVaccine,
                        valor:
                            '${vacuna.nombre} · '
                            '${_cuando(t, vacuna.proximaFecha)}',
                        icono: Icons.vaccines_outlined,
                        color: context.texto,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "hoy", "mañana", "en 3 días", "vencida hace 2 días".
  static String _cuando(AppLocalizations t, DateTime fecha) {
    final dias = fecha.difference(DateTime.now()).inDays;
    if (dias < 0) return t.relOverdueDays(-dias);
    if (dias == 0) return t.relToday;
    if (dias == 1) return t.relTomorrow;
    return t.relInDays(dias);
  }

  /// 4.2 en vez de 4.20, pero 32 en vez de 32.0.
  static String _formatearKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);
}

/// Menú de la tarjeta: un botón circular suave en lugar de los tres puntos
/// sueltos, y un panel redondeado con iconos.
class _MenuMascota extends StatelessWidget {
  const _MenuMascota({required this.onEditar, required this.onEliminar});

  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: t.options,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
      elevation: 8,
      color: context.superficie,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.bordeSuave),
      ),
      padding: const EdgeInsets.all(6),
      onSelected: (valor) {
        if (valor == 'editar') onEditar();
        if (valor == 'eliminar') onEliminar();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'editar',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 19, color: context.texto),
              const SizedBox(width: 12),
              Text(t.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'eliminar',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 19, color: context.alertaTexto),
              const SizedBox(width: 12),
              Text(t.delete, style: TextStyle(color: context.alertaTexto)),
            ],
          ),
        ),
      ],
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.relleno,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_horiz, size: 22, color: context.textoSuave),
      ),
    );
  }
}

/// Última «tarjeta» de la lista: invita a agregar otra mascota.
class _TarjetaAgregar extends StatelessWidget {
  const _TarjetaAgregar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.bordeSuave, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: context.marca),
            const SizedBox(width: 10),
            Text(
              t.addPet,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: context.marca),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recuadro con rótulo arriba y un valor con icono debajo.
class _Celda extends StatelessWidget {
  const _Celda({
    required this.rotulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  final String rotulo;
  final String valor;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: TextStyle(
              fontSize: 10,
              color: context.textoTenue,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icono, size: 15, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  valor,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
