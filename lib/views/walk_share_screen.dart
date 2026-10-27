import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../models/pawlife_models.dart';
import '../theme/app_colors.dart';
import 'widgets/foto_mascota.dart';
import 'widgets/walk_route_trace.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
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
        setState(
          () => _error = 'No se pudo preparar la imagen. Intentá otra vez.',
        );
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
          title: 'Paseo con ${widget.mascota.nombre}',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo compartir. Volvé a intentarlo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Compartir paseo')),
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
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Compartís la traza y las estadísticas, sin el mapa de calles. La forma del recorrido puede revelar lugares que visitaste.',
              ),
              const SizedBox(height: 14),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: AppColors.alerta)),
                TextButton(
                  onPressed: _prepare,
                  child: const Text('Reintentar'),
                ),
              ] else if (_png == null)
                const LinearProgressIndicator(),
              Builder(
                builder: (buttonContext) => FilledButton.icon(
                  onPressed: _png == null || _sharing
                      ? null
                      : () => _share(buttonContext),
                  icon: const Icon(Icons.ios_share),
                  label: Text(_sharing ? 'Compartiendo…' : 'Compartir PNG'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class WalkShareCard extends StatelessWidget {
  const WalkShareCard({super.key, required this.paseo, required this.mascota});
  final Paseo paseo;
  final Mascota mascota;

  @override
  Widget build(BuildContext context) {
    final date = paseo.fechaInicio;
    final photo = proveedorDeFoto(paseo.fotoParaCompartir(mascota));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.verdeOscuro,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'NunitoSans',
          fontSize: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pets, color: AppColors.verdeAcento),
                SizedBox(width: 8),
                Text(
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
                    'Paseo con ${mascota.nombre}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${date.day}/${date.month}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 18),
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.verdeSuave,
                borderRadius: BorderRadius.circular(18),
              ),
              child: WalkRouteTrace(points: paseo.ruta),
            ),
            const SizedBox(height: 8),
            const Text(
              'Traza del recorrido · inicio verde / final rojo',
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                Text(
                  '${(paseo.distanciaMetros / 1000).toStringAsFixed(2)} km',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${paseo.duracion.inMinutes} min ${paseo.duracion.inSeconds % 60} s',
                  style: const TextStyle(fontSize: 21),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Un paseo más, un recuerdo juntos.',
              style: TextStyle(color: AppColors.verdeAcento),
            ),
          ],
        ),
      ),
    );
  }
}
