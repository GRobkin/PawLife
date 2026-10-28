import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
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
                        label: Text(e.$2),
                        selected: _estilo == e.$1,
                        onSelected: (_) {
                          if (_estilo == e.$1) return;
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
    final traza = Container(
      height: cifras ? 150 : 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: claro ? Colors.white : AppColors.verdeSuave,
        borderRadius: BorderRadius.circular(18),
      ),
      child: WalkRouteTrace(points: paseo.ruta),
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
              Text(t.traceCaption, style: const TextStyle(fontSize: 11)),
            ] else ...[
              traza,
              const SizedBox(height: 8),
              Text(t.traceCaption, style: const TextStyle(fontSize: 11)),
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
