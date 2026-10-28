// views/route_screen.dart
//
// View: solo se encarga de construir la UI y de reaccionar al estado
// del RouteViewModel. No contiene lógica de negocio.
//
// Diseño: pantalla "Paseo en curso" — el paseo ya está en curso apenas se
// entra (arranca solo desde el ViewModel), y el único control es el
// botón "Finalizar paseo" para terminarlo.
//
// DEPENDENCIAS (agregar en pubspec.yaml):
//   provider, flutter_map, latlong2, geolocator
//
// PERMISOS: ver comentario en location_service.dart / README del proyecto.

import 'widgets/boton_mantener.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../models/route_point.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../services/map_capture_service.dart';
import 'widgets/foto_mascota.dart';
import '../viewmodels/route_view_model.dart';
import 'walk_summary_screen.dart';

// Paleta acorde al diseño (verde bosque oscuro para acciones principales)

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key, required this.mascotaId});

  /// Mascota a la que se le atribuye el paseo. Define la ruta de la API donde
  /// se guarda: /api/mascotas/{mascotaId}/paseos.
  final String mascotaId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RouteViewModel()..init(),
      child: _RouteScreenBody(mascotaId: mascotaId),
    );
  }
}

class _RouteScreenBody extends StatefulWidget {
  const _RouteScreenBody({required this.mascotaId});

  final String mascotaId;

  @override
  State<_RouteScreenBody> createState() => _RouteScreenBodyState();
}

class _RouteScreenBodyState extends State<_RouteScreenBody> {
  final MapController _mapController = MapController();

  /// Marca el RepaintBoundary que envuelve solo el mapa, para capturarlo sin
  /// los botones ni la tarjeta de datos que van encima.
  final GlobalKey _mapaKey = GlobalKey();

  /// Rotación actual del mapa en grados. 0 = norte arriba.
  double _rotation = 0;
  String? _fotoUrl;
  bool _takingPhoto = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<RouteViewModel>();
      vm.onNewPoint = (point) {
        _mapController.move(point, _mapController.camera.zoom);
      };
    });
  }

  /// Vuelve a orientar el mapa al norte, como el botón de brújula
  /// de Google Maps.
  void _resetRotation() {
    _mapController.rotate(0);
  }

  void _onFinishPressed(BuildContext context, RouteViewModel vm) {
    if (_finishing || _takingPhoto) return;
    _finishing = true;
    final stopped = vm.stopWalk();
    final session = WalkSession(
      points: stopped.points,
      distanceMeters: stopped.distanceMeters,
      duration: stopped.duration,
      startedAt: stopped.startedAt,
      maxSpeedKmh: stopped.maxSpeedKmh,
      fotoUrl: _fotoUrl,
      imagenTipo: _fotoUrl == null
          ? TipoImagenPaseo.desconocida
          : TipoImagenPaseo.mapa,
    );
    // El guardado lo hace la pantalla de resumen, que es la
    // que puede mostrar el estado ("Guardando…", error, reintentar) sin
    // depender de este ViewModel, que muere en este mismo push.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            WalkSummaryScreen(session: session, mascotaId: widget.mascotaId),
      ),
    );
  }

  /// Captura el mapa con el recorrido y la guarda como imagen del paseo.
  ///
  /// Es el encuadre visible al pulsar, no una captura del paseo completo.
  Future<void> _onCameraPressed(BuildContext context) async {
    if (_takingPhoto || _finishing) return;

    final densidad = MediaQuery.devicePixelRatioOf(context);
    final avisos = ScaffoldMessenger.of(context);
    final t = AppLocalizations.of(context);

    setState(() => _takingPhoto = true);
    try {
      // El setState de arriba reconstruye la pantalla, y toImage exige que el
      // RepaintBoundary ya esté pintado: se espera a que termine ese frame.
      await WidgetsBinding.instance.endOfFrame;

      final limite =
          _mapaKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (limite == null) {
        throw const MapCaptureException('El mapa todavía no está listo.');
      }

      final captura = await const MapCaptureService().capturar(
        limite,
        devicePixelRatio: densidad,
      );
      if (!mounted) return;

      setState(() => _fotoUrl = captura);
      avisos.showSnackBar(
        SnackBar(
          content: Text(t.mapCaptured),
          duration: const Duration(seconds: 2),
        ),
      );
    } on MapCaptureException catch (e) {
      avisos.showSnackBar(SnackBar(content: Text(captureErrorText(t, e))));
    } catch (_) {
      // toImage puede fallar por motivos del motor gráfico que no son culpa
      // del usuario. Que no tumbe el paseo en curso: se avisa y se sigue.
      avisos.showSnackBar(SnackBar(content: Text(t.mapCaptureFailed)));
    } finally {
      if (mounted) setState(() => _takingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RouteViewModel>();

    return PopScope(
      canPop: !vm.isTracking,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && vm.isTracking) _onFinishPressed(context, vm);
      },
      child: Scaffold(
        backgroundColor: context.fondoPantalla,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildContent(context, vm)),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Header: flecha atrás + título centrado, fondo blanco
  // -------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: context.superficie,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back,
            onPressed: () {
              final vm = context.read<RouteViewModel>();
              if (vm.isTracking) {
                _onFinishPressed(context, vm);
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context).walkInProgress,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: context.texto),
              ),
            ),
          ),
          const SizedBox(width: 40), // balancea el ancho del botón atrás
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Contenido: mapa + badge GPS + tarjeta de stats + botones
  // -------------------------------------------------------------------
  Widget _buildContent(BuildContext context, RouteViewModel vm) {
    final t = AppLocalizations.of(context);
    switch (vm.status) {
      case RouteScreenStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case RouteScreenStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_off, size: 48, color: context.textoTenue),
                const SizedBox(height: 12),
                Text(
                  locationErrorText(
                    t,
                    code: vm.errorCode,
                    fallback: vm.errorMessage,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: vm.init, child: Text(t.retry)),
              ],
            ),
          ),
        );

      case RouteScreenStatus.ready:
        return Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                key: _mapaKey,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: vm.currentPosition!,
                    initialZoom: 16,
                    // Nos avisa de cualquier cambio de cámara (incluida la
                    // rotación con dos dedos) para actualizar la brújula.
                    onMapEvent: (event) {
                      final rotation = event.camera.rotation;
                      if (rotation != _rotation) {
                        setState(() => _rotation = rotation);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      // Tiles raster oficiales de OpenStreetMap. OpenFreeMap
                      // (que usamos antes) sirve mapas VECTORIALES, no PNG por
                      // tile, así que no es compatible con este TileLayer.
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.pawlife',
                    ),
                    if (vm.routePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: vm.routePoints,
                            strokeWidth: 5,
                            color: AppColors.verdeAcento,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: vm.currentPosition!,
                          width: 22,
                          height: 22,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.verdeAcento,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: ColoredBox(
                        color: Colors.white,
                        child: Text(
                          '© OpenStreetMap contributors · openstreetmap.org/copyright',
                          style: TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Badge "GPS activo"
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(child: _GpsActiveBadge(active: vm.isTracking)),
            ),

            // Botón de brújula: solo aparece cuando el mapa está rotado.
            if (_rotation % 360 != 0)
              Positioned(
                top: 12,
                right: 16,
                child: _CompassButton(
                  rotation: _rotation,
                  onPressed: _resetRotation,
                ),
              ),

            // Tarjeta de stats + botones, abajo
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatsCard(vm: vm),
                  if (_fotoUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Chip(
                        avatar: CircleAvatar(
                          backgroundImage: proveedorDeFoto(_fotoUrl),
                        ),
                        label: Text(t.mapCaptureChip),
                        onDeleted: () => setState(() => _fotoUrl = null),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.map_outlined,
                        elevated: true,
                        onPressed: () => _onCameraPressed(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BotonMantener(
                          icono: Icons.stop_circle_outlined,
                          texto: t.finishWalk,
                          pista: t.holdToFinish,
                          onCompletar: () => _onFinishPressed(context, vm),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}

// ---------------------------------------------------------------------
// Widgets auxiliares (solo presentación)
// ---------------------------------------------------------------------

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.elevated = false,
  });

  final IconData icon;
  final VoidCallback onPressed;

  /// Sobre el mapa: fondo de superficie con sombra.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: elevated ? context.superficie : context.relleno,
      shape: const CircleBorder(),
      elevation: elevated ? 3 : 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: context.texto),
        ),
      ),
    );
  }
}

class _CompassButton extends StatelessWidget {
  const _CompassButton({required this.rotation, required this.onPressed});

  /// Rotación del mapa en grados.
  final double rotation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.superficie,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Transform.rotate(
            // La aguja gira en sentido contrario a la cámara, para que
            // siga apuntando al norte real.
            angle: rotation * math.pi / 180,
            child: const Icon(
              Icons.navigation,
              size: 22,
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }
}

class _GpsActiveBadge extends StatelessWidget {
  const _GpsActiveBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.verdeAcento : context.textoTenue,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            active
                ? AppLocalizations.of(context).gpsActive
                : AppLocalizations.of(context).gpsInactive,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.texto,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.vm});

  final RouteViewModel vm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBlock(label: t.durationCaps, value: vm.formattedElapsed),
              _StatBlock(
                label: t.distanceCaps,
                value: vm.formattedDistance.split(' ').first,
                unit: 'km',
                alignEnd: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.speed, size: 16, color: context.textoSuave),
                  const SizedBox(width: 6),
                  Text(
                    vm.formattedSpeed,
                    style: TextStyle(fontSize: 13, color: context.texto),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    this.unit,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final String? unit;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.5,
            color: context.textoTenue,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: context.texto,
                ),
              ),
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.textoSuave,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
