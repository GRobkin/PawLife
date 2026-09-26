import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/pawlife_models.dart';
import '../theme/app_colors.dart';

class WalkDetailScreen extends StatelessWidget {
  const WalkDetailScreen({
    super.key,
    required this.paseo,
    required this.mascota,
  });

  final Paseo paseo;
  final Mascota mascota;

  @override
  Widget build(BuildContext context) {
    final points = paseo.ruta
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: Text('Paseo con ${mascota.nombre}')),
      body: Column(
        children: [
          Expanded(
            child: points.isEmpty
                ? const Center(
                    child: Text('Este paseo no tiene puntos de GPS.'),
                  )
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: points.first,
                      initialZoom: 16,
                      initialCameraFit: points.length > 1
                          ? CameraFit.bounds(
                              bounds: LatLngBounds.fromPoints(points),
                              padding: const EdgeInsets.all(40),
                            )
                          : null,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.flutter_application_1',
                      ),
                      if (points.length > 1)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: points,
                              strokeWidth: 5,
                              color: AppColors.verdeAcento,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: points.first,
                            child: const Icon(
                              Icons.trip_origin,
                              color: AppColors.verdeOscuro,
                              size: 28,
                            ),
                          ),
                          if (points.length > 1)
                            Marker(
                              point: points.last,
                              child: const Icon(
                                Icons.place,
                                color: AppColors.alerta,
                                size: 32,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${paseo.fechaInicio.day}/${paseo.fechaInicio.month}/${paseo.fechaInicio.year} '
                    'a las ${paseo.fechaInicio.hour.toString().padLeft(2, '0')}:'
                    '${paseo.fechaInicio.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(paseo.distanciaMetros / 1000).toStringAsFixed(2)} km'
                    ' · ${paseo.duracion.inMinutes} min'
                    ' · Máx. ${paseo.velocidadMaximaKmh.toStringAsFixed(1)} km/h',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mapa © OpenStreetMap contributors',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
