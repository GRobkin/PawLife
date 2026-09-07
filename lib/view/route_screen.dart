import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:pawlife/viewmodel/route_view_model.dart';
import 'package:pawlife/view/walk_summary_screen.dart';

const _kDarkGreen = Color(0xFF12352A);
const _kAccentGreen = Color(0xFF3FB77E);

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Active Walk', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: _buildMapWidget(context, viewModel),
        );
      },
    );
  }

  Widget _buildMapWidget(BuildContext context, RouteViewModel viewModel) {
    final currentPos = viewModel.currentPosition ?? const LatLng(4.6097, -74.0817);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: currentPos,
            initialZoom: 16.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.pawlife',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            if (viewModel.routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: viewModel.routePoints,
                    strokeWidth: 5.0,
                    color: _kAccentGreen,
                  ),
                ],
              ),
            if (viewModel.currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: viewModel.currentPosition!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Time', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(viewModel.formattedElapsed, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _kDarkGreen)),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.black12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Distance (km)', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(viewModel.formattedDistance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _kDarkGreen)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 36,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!viewModel.isTracking)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => viewModel.startTracking(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final paseo = viewModel.stopWalk();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WalkSummaryScreen(paseo: paseo),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text('Finish Walk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
