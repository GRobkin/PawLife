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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../models/route_point.dart';
import '../viewmodels/route_view_model.dart';
import 'walk_summary_screen.dart';

// Paleta acorde al diseño (verde bosque oscuro para acciones principales)
const _kDarkGreen = Color(0xFF12352A);
const _kAccentGreen = Color(0xFF3FB77E);
const _kBackground = Color(0xFFF4F5F7);

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key, required this.mascotaId});

  /// Mascota a la que se le atribuye el paseo. Define dónde se guarda en
  /// Firestore: users/{uid}/mascotas/{mascotaId}/paseos.
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

  /// Rotación actual del mapa en grados. 0 = norte arriba.
  double _rotation = 0;

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
    final WalkSession session = vm.stopWalk();
    // El guardado en Firestore lo hace la pantalla de resumen, que es la
    // que puede mostrar el estado ("Guardando…", error, reintentar) sin
    // depender de este ViewModel, que muere en este mismo push.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WalkSummaryScreen(
          session: session,
          mascotaId: widget.mascotaId,
        ),
      ),
    );
  }

  void _onCameraPressed(BuildContext context) {
    // Placeholder: la funcionalidad de sacar foto durante el paseo
    // no está en el alcance de esta pantalla todavía.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de cámara: pendiente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RouteViewModel>();

    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent(context, vm)),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Header: flecha atrás + título centrado, fondo blanco
  // -------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Paseo en curso',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
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
                const Icon(Icons.location_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  vm.errorMessage ?? 'Ocurrió un error de ubicación.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: vm.init,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );

      case RouteScreenStatus.ready:
        return Stack(
          children: [
            Positioned.fill(
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
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.pawlife',
                  ),
                  if (vm.routePoints.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: vm.routePoints,
                          strokeWidth: 5,
                          color: _kAccentGreen,
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
                              color: _kAccentGreen,
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.camera_alt_outlined,
                        backgroundColor: Colors.white,
                        onPressed: () => _onCameraPressed(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _onFinishPressed(context, vm),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kDarkGreen,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          icon: const Icon(Icons.stop_circle_outlined,
                              size: 20),
                          label: const Text(
                            'Finalizar paseo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    this.backgroundColor = const Color(0xFFEFF1F3),
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: backgroundColor == Colors.white ? 3 : 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.black87),
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
      color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              color: active ? _kAccentGreen : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            active ? 'GPS activo' : 'GPS inactivo',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              _StatBlock(label: 'DURACIÓN', value: vm.formattedElapsed),
              _StatBlock(
                label: 'DISTANCIA',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 16, color: _kAccentGreen),
                  const SizedBox(width: 6),
                  Text(vm.formattedCalories,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.speed, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(vm.formattedSpeed,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87)),
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
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 0.5,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
