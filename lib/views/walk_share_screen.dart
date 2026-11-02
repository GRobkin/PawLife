import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../config/app_identity.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../models/route_point.dart';
import '../services/pawlife_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'widgets/foto_mascota.dart';
import 'widgets/walk_route_trace.dart';

enum TarjetaEstilo { bosque, menta, cifras }

class WalkShareScreen extends StatefulWidget {
  const WalkShareScreen({
    super.key,
    required this.paseo,
    required this.mascota,
  });
  final Paseo paseo;
  final Mascota mascota;

  @override
  State<WalkShareScreen> createState() => _WalkShareScreenState();
}

class _WalkShareScreenState extends State<WalkShareScreen> {
  final _cardKey = GlobalKey();
  Uint8List? _png;
  String? _error;
  bool _sharing = false;
  TarjetaEstilo _estilo = TarjetaEstilo.bosque;
  bool _premium = false;

  @override
  void initState() {
    super.initState();
    _consultarPremium();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _consultarPremium() async {
    final repo = PawLifeRepository();
    try {
      final estado = await repo.fetchPremium();
      if (mounted) setState(() => _premium = estado['activo'] == true);
    } catch (_) {
      // Sin conexión o con error: se trata como plan gratuito.
    } finally {
      repo.client.close();
    }
  }

  Future<void> _prepare() async {
    setState(() {
      _error = null;
      _png = null;
    });
    try {
      final photo = proveedorDeFoto(
        widget.paseo.fotoParaCompartir(widget.mascota),
      );
      if (photo != null) {
        await precacheImage(photo, context, onError: (_, _) {});
      }
      await WidgetsBinding.instance.endOfFrame;
      // Las teselas del mapa llegan por red: se espera un tiempo acotado
      // para que salgan en la imagen.
      if (WalkShareCard.mapaReal && widget.paseo.ruta.isNotEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 2500));
      }
      if (!mounted) return;
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) throw StateError('No se pudo crear el PNG.');
        if (mounted) setState(() => _png = bytes.buffer.asUint8List());
      } finally {
        image.dispose();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).shareImageError);
      }
    }
  }

  Future<void> _share(BuildContext buttonContext) async {
    if (_png == null || _sharing) return;
    final box = buttonContext.findRenderObject()! as RenderBox;
    setState(() => _sharing = true);
    try {
      // Los bytes ya están preparados antes del gesto: Web Share necesita
      // activación del usuario. En navegadores sin soporte se descarga el PNG.
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(_png!, mimeType: 'image/png')],
          fileNameOverrides: [
            'pawlife-paseo-${widget.paseo.fechaInicio.millisecondsSinceEpoch}.png',
          ],
          title: AppLocalizations.of(context).walkWith(widget.mascota.nombre),
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).shareFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.shareWalkTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                RepaintBoundary(
                  key: _cardKey,
                  child: WalkShareCard(
                    paseo: widget.paseo,
                    mascota: widget.mascota,
                    estilo: _estilo,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.shareStyleLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in [
                      (TarjetaEstilo.bosque, t.shareStyleForest),
                      (TarjetaEstilo.menta, t.shareStyleMint),
                      (TarjetaEstilo.cifras, t.shareStyleStats),
                    ])
                      ChoiceChip(
                        avatar: e.$1 == TarjetaEstilo.bosque || _premium
                            ? null
                            : const Icon(Icons.lock_outline, size: 16),
                        label: Text(e.$2),
                        selected: _estilo == e.$1,
                        onSelected: (_) {
                          if (_estilo == e.$1) return;
                          // Menta y Cifras son de Premium.
                          if (e.$1 != TarjetaEstilo.bosque && !_premium) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t.premiumLockedCard)),
                            );
                            return;
                          }
                          setState(() => _estilo = e.$1);
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _prepare(),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(t.sharePrivacyNote),
                const SizedBox(height: 14),
                if (_error != null) ...[
                  Text(_error!, style: TextStyle(color: context.alertaTexto)),
                  TextButton(onPressed: _prepare, child: Text(t.retry)),
                ] else if (_png == null)
                  const LinearProgressIndicator(),
                Builder(
                  builder: (buttonContext) => FilledButton.icon(
                    onPressed: _png == null || _sharing
                        ? null
                        : () => _share(buttonContext),
                    icon: const Icon(Icons.ios_share),
                    label: Text(_sharing ? t.sharingEllipsis : t.sharePng),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WalkShareCard extends StatelessWidget {
  const WalkShareCard({
    super.key,
    required this.paseo,
    required this.mascota,
    this.estilo = TarjetaEstilo.bosque,
  });
  final Paseo paseo;
  final Mascota mascota;
  final TarjetaEstilo estilo;

  /// Los tests lo apagan para no pedir teselas a la red.
  static bool mapaReal = true;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final date = paseo.fechaInicio;
    final photo = proveedorDeFoto(paseo.fotoParaCompartir(mascota));
    final claro = estilo == TarjetaEstilo.menta;
    final fondo = claro ? AppColors.verdeSuave : AppColors.verdeOscuro;
    final texto = claro ? AppColors.verdeOscuro : Colors.white;
    final acento = claro ? AppColors.verdeOscuro : AppColors.verdeAcento;
    final cifras = estilo == TarjetaEstilo.cifras;
    final km = '${(paseo.distanciaMetros / 1000).toStringAsFixed(2)} km';
    final tiempo = t.durationMinSec(
      paseo.duracion.inMinutes,
      paseo.duracion.inSeconds % 60,
    );
    final conRuta = paseo.ruta.length > 1;
    final hayPunto = paseo.ruta.isNotEmpty;
    final traza = Container(
      height: cifras ? 150 : 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: claro ? Colors.white : AppColors.verdeSuave,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: hayPunto && mapaReal
          ? _MapaPaseo(ruta: paseo.ruta)
          : WalkRouteTrace(points: paseo.ruta),
    );
    final leyenda = Text(
      conRuta
          ? t.traceCaption
          : hayPunto
          ? t.shareStartOnly
          : t.shareNoGps,
      style: const TextStyle(fontSize: 11),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: fondo,
      child: DefaultTextStyle(
        style: TextStyle(color: texto, fontFamily: 'NunitoSans', fontSize: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: acento),
                const SizedBox(width: 8),
                const Text(
                  'PawLife',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: photo,
                  child: photo == null ? const Icon(Icons.pets) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.walkWith(mascota.nombre),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(formatDateTime(context, date)),
            const SizedBox(height: 18),
            if (cifras) ...[
              Text(
                km,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(tiempo, style: TextStyle(fontSize: 24, color: acento)),
              const SizedBox(height: 18),
              traza,
              const SizedBox(height: 8),
              leyenda,
            ] else ...[
              traza,
              const SizedBox(height: 8),
              leyenda,
              const SizedBox(height: 18),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  Text(
                    km,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(tiempo, style: const TextStyle(fontSize: 21)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(t.shareTagline, style: TextStyle(color: acento)),
          ],
        ),
      ),
    );
  }
}

/// Mapa de calles con el recorrido, sus puntos de inicio y final, y la
/// atribución que exige OpenStreetMap.
class _MapaPaseo extends StatelessWidget {
  const _MapaPaseo({required this.ruta});

  final List<RoutePoint> ruta;

  @override
  Widget build(BuildContext context) {
    final puntos = [for (final p in ruta) LatLng(p.latitude, p.longitude)];
    Marker punto(LatLng en, Color color) => Marker(
      point: en,
      width: 18,
      height: 18,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
    return IgnorePointer(
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: puntos.first,
              initialZoom: 17,
              // Con un solo punto (paseo sin desplazamiento) no hay límites que
              // encuadrar: se centra en el inicio.
              initialCameraFit: puntos.length > 1
                  ? CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(puntos),
                      padding: const EdgeInsets.all(28),
                      maxZoom: 18,
                    )
                  : null,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: kAppPackageId,
              ),
              if (puntos.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: puntos,
                      strokeWidth: 5,
                      color: AppColors.verdeOscuro,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  punto(puntos.first, AppColors.verdeAcento),
                  if (puntos.length > 1) punto(puntos.last, Colors.redAccent),
                ],
              ),
            ],
          ),
          Positioned(
            right: 6,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: Colors.white70,
              child: const Text(
                '© OpenStreetMap',
                style: TextStyle(fontSize: 9, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
