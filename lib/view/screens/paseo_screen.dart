import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/paseo_viewmodel.dart';

class PaseoScreen extends StatefulWidget {
  const PaseoScreen({super.key, required this.mascotaId});

  final String mascotaId;

  @override
  State<PaseoScreen> createState() => _PaseoScreenState();
}

class _PaseoScreenState extends State<PaseoScreen> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<PaseoViewModel>().ubicarme();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaseoViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Paseo')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: vm.posicionActual ?? const LatLng(-30.9, -55.55),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pawlife.app',
              ),
              PolylineLayer(polylines: [
                Polyline(points: vm.puntos, strokeWidth: 4, color: Colors.blue),
              ]),
              if (vm.posicionActual != null)
                MarkerLayer(markers: [
                  Marker(
                    point: vm.posicionActual!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                  ),
                ]),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('${(vm.distanciaMetros / 1000).toStringAsFixed(2)} km'),
                    Text('${vm.velocidadMaximaKmh.toStringAsFixed(1)} km/h máx'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: vm.tracking ? vm.terminarPaseo : vm.iniciarPaseo,
        icon: Icon(vm.tracking ? Icons.stop : Icons.play_arrow),
        label: Text(vm.tracking ? 'Terminar' : 'Iniciar'),
        backgroundColor: vm.tracking ? Colors.red : Colors.green,
      ),
    );
  }
}
