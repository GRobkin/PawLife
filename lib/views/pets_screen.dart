// views/pets_screen.dart
//
// Listado de mascotas del usuario. Es la entrada a todo lo demás: vacunas,
// medicamentos, pesos y paseos cuelgan de una mascota en el backend
// (users/{uid}/mascotas/{id}/...), así que sin elegir mascota no hay a qué
// colgarlos.
//
// Cada tarjeta resume el estado de salud. Eso obliga a pedir también las
// vacunas y los pesos de cada mascota, así que la carga hace varias llamadas
// en paralelo (ver _cargar). Con la cantidad de mascotas que tiene una persona
// real es barato; si algún día fueran decenas, habría que añadir un endpoint
// que devolviera el resumen ya calculado.

import 'package:flutter/material.dart';

import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/pawlife_repository.dart';
import '../theme/app_colors.dart';
import 'pet_detail_screen.dart';
import 'pet_form_screen.dart';
import 'route_screen.dart';
import 'widgets/pawlife_bottom_nav.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final _repositorio = PawLifeRepository();

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
      setState(() => _error = e.message);
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
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text('¿Eliminar a ${mascota.nombre}?'),
        // Se dice explícitamente lo que se lleva por delante: el backend borra
        // las subcolecciones en cascada y no hay forma de recuperarlas.
        content: const Text(
          'Se borrarán también sus vacunas, medicamentos, registros de peso y '
          'paseos. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.alerta),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      await _repositorio.deleteMascota(mascota.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${mascota.nombre} eliminada.')));
      await _cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  /// El botón central de paseo necesita una mascota a la que atribuirlo.
  void _iniciarPaseo() {
    final mascotas = _mascotas;

    if (mascotas == null || mascotas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero agregá una mascota para registrar el paseo.'),
        ),
      );
      return;
    }

    if (mascotas.length == 1) {
      _irAlPaseo(mascotas.first.mascota);
      return;
    }

    // Con varias mascotas hay que preguntar: atribuir el paseo a la primera
    // sería adivinar, y el dato quedaría mal guardado sin que se note.
    showModalBottomSheet<void>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '¿Con quién vas a pasear?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            for (final resumen in mascotas)
              ListTile(
                leading: _AvatarMascota(mascota: resumen.mascota, radio: 18),
                title: Text(resumen.mascota.nombre),
                subtitle: Text(resumen.mascota.subtitulo),
                onTap: () {
                  Navigator.of(contexto).pop();
                  _irAlPaseo(resumen.mascota);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _irAlPaseo(Mascota mascota) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RouteScreen(mascotaId: mascota.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildContenido()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppColors.verdeOscuro,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.mascotas,
        onPaseo: _iniciarPaseo,
      ),
    );
  }

  Widget _buildTopBar() {
    final fotoUrl = AuthService().currentUser?.photoURL;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
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
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black12,
            backgroundImage: fotoUrl == null ? null : NetworkImage(fotoUrl),
            child: fotoUrl != null
                ? null
                : const Icon(Icons.person, size: 18, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    if (_error != null) {
      return _EstadoVacio(
        icono: Icons.cloud_off,
        titulo: 'No se pudieron cargar tus mascotas',
        detalle: _error!,
        accion: 'Reintentar',
        onAccion: _cargar,
      );
    }

    final mascotas = _mascotas;
    if (mascotas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mascotas.isEmpty) {
      return _EstadoVacio(
        icono: Icons.pets,
        titulo: 'Todavía no tenés mascotas',
        detalle: 'Agregá la primera para empezar a llevar sus cuidados.',
        accion: 'Agregar mascota',
        onAccion: () => _abrirFormulario(),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
        children: [
          const Text(
            'Mis mascotas',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gestioná a los miembros peludos de tu familia.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          for (final resumen in mascotas) ...[
            _TarjetaMascota(
              resumen: resumen,
              onTap: () => _abrirDetalle(resumen.mascota),
              onEditar: () => _abrirFormulario(mascota: resumen.mascota),
              onEliminar: () => _confirmarBorrado(resumen.mascota),
            ),
            const SizedBox(height: 14),
          ],
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
  _Estado get estado {
    final vacuna = proximaVacuna;
    if (vacuna == null) {
      return const _Estado('Sin vacunas', Icons.info_outline, Colors.black54);
    }

    final dias = vacuna.proximaFecha.difference(DateTime.now()).inDays;

    if (dias < 0) {
      return const _Estado(
        'Vacuna vencida',
        Icons.warning_amber_rounded,
        AppColors.alerta,
      );
    }

    // `anticipacionDias` es cuántos días antes quiere avisar el usuario.
    if (dias <= vacuna.anticipacionDias) {
      return const _Estado(
        'Vacuna próxima',
        Icons.warning_amber_rounded,
        AppColors.aviso,
      );
    }

    return const _Estado(
      'Sano',
      Icons.check_circle_outline,
      AppColors.verdeAcento,
    );
  }
}

class _Estado {
  const _Estado(this.texto, this.icono, this.color);

  final String texto;
  final IconData icono;
  final Color color;
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
    final mascota = resumen.mascota;
    final estado = resumen.estado;
    final peso = resumen.ultimoPeso;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  _AvatarMascota(mascota: mascota, radio: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mascota.nombre,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mascota.subtitulo,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Opciones',
                    icon: const Icon(Icons.more_vert, color: Colors.black45),
                    onSelected: (valor) {
                      if (valor == 'editar') onEditar();
                      if (valor == 'eliminar') onEliminar();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Text(
                          'Eliminar',
                          style: TextStyle(color: AppColors.alerta),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Celda(
                      rotulo: 'ESTADO',
                      valor: estado.texto,
                      icono: estado.icono,
                      color: estado.color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Celda(
                      rotulo: 'PESO',
                      valor: peso == null
                          ? 'Sin registro'
                          : '${_formatearKg(peso.valorKg)} kg',
                      icono: Icons.monitor_weight_outlined,
                      color: peso == null ? Colors.black45 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4.2 en vez de 4.20, pero 32 en vez de 32.0.
  static String _formatearKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);
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
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black45,
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

/// Foto de la mascota, o un círculo con su inicial mientras no tenga.
class _AvatarMascota extends StatelessWidget {
  const _AvatarMascota({required this.mascota, required this.radio});

  final Mascota mascota;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final fotoUrl = mascota.fotoUrl;

    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radio,
        backgroundColor: AppColors.verdeSuave,
        backgroundImage: NetworkImage(fotoUrl),
      );
    }

    return CircleAvatar(
      radius: radio,
      backgroundColor: AppColors.verdeSuave,
      child: Text(
        mascota.inicial,
        style: TextStyle(
          fontSize: radio * 0.8,
          fontWeight: FontWeight.bold,
          color: AppColors.verdeOscuro,
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.accion,
    required this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final String accion;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 56, color: Colors.black26),
            const SizedBox(height: 18),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: onAccion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdeOscuro,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(accion),
            ),
          ],
        ),
      ),
    );
  }
}
