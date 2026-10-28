import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../services/walk_repository.dart';
import 'walk_share_screen.dart';
import 'widgets/foto_mascota.dart';

class WalkDetailScreen extends StatefulWidget {
  const WalkDetailScreen({
    super.key,
    required this.paseo,
    required this.mascota,
  });

  final Paseo paseo;
  final Mascota mascota;

  @override
  State<WalkDetailScreen> createState() => _WalkDetailScreenState();
}

class _WalkDetailScreenState extends State<WalkDetailScreen> {
  Paseo get paseo => widget.paseo;
  Mascota get mascota => widget.mascota;
  bool _deleting = false;

  Future<void> _delete() async {
    if (_deleting) return;
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteWalkTitle),
        content: Text(t.deleteWalkBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await WalkRepository().deletePaseo(mascota.id, paseo.id);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.deleteWalkError)));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final points = paseo.ruta
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.walkWith(mascota.nombre)),
        actions: [
          IconButton(
            tooltip: t.shareAsPng,
            icon: const Icon(Icons.ios_share),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WalkShareScreen(paseo: paseo, mascota: mascota),
              ),
            ),
          ),
          IconButton(
            tooltip: t.deleteWalk,
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleting ? null : _delete,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: points.isEmpty
                ? Center(child: Text(t.noGpsPoints))
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
                    t.dateAtTime(
                      formatDate(context, paseo.fechaInicio),
                      formatTime(context, paseo.fechaInicio),
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(paseo.distanciaMetros / 1000).toStringAsFixed(2)} km'
                    ' · ${paseo.duracion.inMinutes} min'
                    ' · ${t.maxSpeedLabel(paseo.velocidadMaximaKmh.toStringAsFixed(1))}',
                  ),
                  const SizedBox(height: 4),
                  if (paseo.fotoUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: proveedorDeFoto(paseo.fotoUrl),
                          ),
                          const SizedBox(width: 12),
                          Text(t.walkPhoto),
                        ],
                      ),
                    ),
                  Text(
                    t.mapAttribution,
                    style: TextStyle(fontSize: 11, color: context.textoSuave),
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
