// views/walk_summary_screen.dart
//
// Pantalla de resumen que se muestra al terminar un paseo.
// Recibe la WalkSession ya cerrada y muestra sus datos + la ruta de fondo.
//
// Además manda el paseo al backend apenas se abre (vía WalkRepository),
// porque si esperáramos al botón "Paseo guardado" un cierre con la X
// perdería el paseo entero. El botón refleja el estado del guardado y
// permite reintentar si falló.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

import '../l10n/app_localizations.dart';
import '../l10n/formatting.dart';
import '../models/route_point.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../models/pawlife_models.dart';
import 'walk_share_screen.dart';
import 'widgets/foto_mascota.dart';
import '../services/pawlife_repository.dart';
import '../services/walk_repository.dart';

/// Estado del guardado del paseo en el backend.
enum _SaveStatus { saving, saved, error }

class WalkSummaryScreen extends StatefulWidget {
  const WalkSummaryScreen({
    super.key,
    required this.session,
    required this.mascotaId,
  });

  final WalkSession session;
  final String mascotaId;

  @override
  State<WalkSummaryScreen> createState() => _WalkSummaryScreenState();
}

class _WalkSummaryScreenState extends State<WalkSummaryScreen> {
  final WalkRepository _repository = WalkRepository();
  final PawLifeRepository _mascotas = PawLifeRepository();

  _SaveStatus _saveStatus = _SaveStatus.saving;
  String? _saveError;
  String? _mascotaNombre;
  Mascota? _mascota;
  late final String _paseoId =
      'paseo_${List.generate(16, (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';

  WalkSession get session => widget.session;

  @override
  void initState() {
    super.initState();
    _save();
  }

  Future<void> _save() async {
    setState(() {
      _saveStatus = _SaveStatus.saving;
      _saveError = null;
    });

    try {
      await _repository.savePaseo(
        mascotaId: widget.mascotaId,
        session: session,
        id: _paseoId,
      );
      if (!mounted) return;
      setState(() => _saveStatus = _SaveStatus.saved);
      try {
        final mascota = await _mascotas.fetchMascota(widget.mascotaId);
        if (mounted) {
          setState(() {
            _mascota = mascota;
            _mascotaNombre = mascota.nombre;
          });
        }
      } catch (_) {
        /* El paseo quedó guardado aunque falle la carga del perfil. */
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saveStatus = _SaveStatus.error;
        _saveError = e.toString();
      });
    }
  }

  List<LatLng> get _points => session.points
      .map((p) => LatLng(p.latitude, p.longitude))
      .toList(growable: false);

  String get _formattedDistance =>
      (session.distanceMeters / 1000).toStringAsFixed(2);

  /// Usamos "min"/"s" en vez de "m" para no confundir minutos con metros.
  String get _formattedDuration {
    final t = AppLocalizations.of(context);
    final seconds = session.duration.inSeconds;
    if (seconds < 60) return t.durationSeconds(seconds);
    final minutes = session.duration.inMinutes;
    if (minutes < 60) return t.minutesShort(minutes);
    return t.durationHm(session.duration.inHours, minutes % 60);
  }

  String get _formattedSpeed {
    final seconds = session.duration.inSeconds;
    if (seconds == 0) return '0.0';
    final kmh = (session.distanceMeters / 1000) / (seconds / 3600);
    return kmh.toStringAsFixed(1);
  }

  Future<void> _close(BuildContext context) async {
    if (_saveStatus == _SaveStatus.saving) return;
    if (_saveStatus == _SaveStatus.error) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context).walkNotSaved),
          content: Text(AppLocalizations.of(context).walkNotSavedBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context).back),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context).leaveWithoutSaving),
            ),
          ],
        ),
      );
      if (discard != true || !context.mounted) return;
    }
    // Vuelve al Home, descartando también la pantalla de paseo en curso.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _share() {
    final mascota = _mascota;
    if (mascota == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalkShareScreen(
          mascota: mascota,
          paseo: Paseo(
            id: _paseoId,
            fechaInicio: session.startedAt,
            fechaFin: session.endedAt,
            duracionSegundos: session.duration.inSeconds,
            distanciaMetros: session.distanceMeters,
            velocidadMaximaKmh: session.maxSpeedKmh,
            ruta: session.points,
            fotoUrl: session.fotoUrl,
            imagenTipo: session.imagenTipo,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final mapHeight = MediaQuery.of(context).size.height * 0.34;

    return PopScope(
      canPop: _saveStatus == _SaveStatus.saved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(context);
      },
      child: Scaffold(
        backgroundColor: context.fondoPantalla,
        body: Stack(
          children: [
            // 1. Mapa de fondo, anclado arriba
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: mapHeight,
              child: _MapHeader(points: _points),
            ),

            // 2. Contenido scrolleable, empieza debajo del mapa
            Positioned.fill(
              child: ListView(
                // clipBehavior none para que el badge pueda sobresalir
                // hacia arriba sin quedar recortado.
                clipBehavior: Clip.none,
                padding: EdgeInsets.fromLTRB(
                  20,
                  mapHeight - 20,
                  20,
                  // Espacio para el botón fijo de abajo + la barra de
                  // navegación del sistema.
                  MediaQuery.of(context).padding.bottom + 100,
                ),
                children: [
                  _buildBadge(),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      t.walkWith(_mascotaNombre ?? t.yourPet),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.texto,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      formatDateTime(context, session.startedAt),
                      style: TextStyle(fontSize: 14, color: context.textoSuave),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildStats(),
                  const SizedBox(height: 14),
                  _buildPetCard(),
                ],
              ),
            ),

            // 3. Botón de cerrar, flotando sobre el mapa
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: Material(
                color: context.superficie,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _close(context),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.close, size: 22, color: context.texto),
                  ),
                ),
              ),
            ),

            // 4. Botón principal fijo abajo, respetando la barra del sistema
            Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSaveButton(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón principal: refleja en qué punto está el guardado del paseo.
  /// Mientras guarda no deja cerrar por accidente sin saber si se guardó;
  /// si falló, el mismo botón reintenta.
  Widget _buildSaveButton(BuildContext context) {
    final t = AppLocalizations.of(context);
    final saving = _saveStatus == _SaveStatus.saving;
    final failed = _saveStatus == _SaveStatus.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (failed && _saveError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.errorFondo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _saveError!,
                      style: TextStyle(fontSize: 13, color: context.errorTexto),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: saving
              ? null
              : failed
              ? _save
              : () => _close(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: failed ? Colors.redAccent : context.botonFondo,
            foregroundColor: failed ? Colors.white : context.botonTexto,
            disabledBackgroundColor: context.botonFondo.withValues(alpha: 0.6),
            disabledForegroundColor: context.botonTexto.withValues(alpha: 0.7),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white70),
                  ),
                )
              : Icon(failed ? Icons.refresh : Icons.check_circle, size: 20),
          label: Text(
            saving
                ? t.savingWalk
                : failed
                ? t.retry
                : t.walkSaved,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.verdeBadge,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 18, color: AppColors.verdeOscuro),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).goodWalk,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.verdeOscuro,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        _SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardLabel(icon: Icons.route, label: t.distanceCaps),
              const SizedBox(height: 10),
              _BigValue(value: _formattedDistance, unit: 'km'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SummaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel(
                        icon: Icons.timer_outlined,
                        label: t.durationLabel,
                        uppercase: false,
                      ),
                      const SizedBox(height: 16),
                      _BigValue(value: _formattedDuration),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SummaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel(
                        icon: Icons.speed,
                        label: t.avgSpeed,
                        uppercase: false,
                      ),
                      const SizedBox(height: 16),
                      _BigValue(value: _formattedSpeed, unit: 'km/h'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard() {
    final t = AppLocalizations.of(context);
    return _SummaryCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: context.bordeSuave,
            backgroundImage: proveedorDeFoto(
              session.fotoUrl ?? _mascota?.fotoUrl,
            ),
            child: session.fotoUrl == null && _mascota?.fotoUrl == null
                ? Icon(Icons.pets, size: 20, color: context.textoTenue)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.walkedWith(_mascotaNombre ?? t.yourPet),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.texto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_formattedDistance km • $_formattedDuration',
                  style: TextStyle(fontSize: 13, color: context.textoSuave),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: t.shareAsPng,
            onPressed: _mascota == null ? null : _share,
            icon: Icon(Icons.share_outlined, color: context.textoSuave),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Mapa de fondo con la ruta recorrida
// ---------------------------------------------------------------------

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.points});

  final List<LatLng> points;

  @override
  Widget build(BuildContext context) {
    final LatLng center = points.isNotEmpty
        ? points.first
        : const LatLng(-30.9053, -55.5508); // Rivera, por defecto

    return ShaderMask(
      // Desvanece el borde inferior del mapa hacia el fondo de la pantalla
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0.0, 0.70, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: IgnorePointer(
        // El mapa es decorativo en esta pantalla: no se puede mover.
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 16,
            initialCameraFit: points.length > 1
                ? CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(points),
                    padding: const EdgeInsets.all(50),
                  )
                : null,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.pawlife',
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
            // Si solo hay un punto (paseo muy corto), al menos lo marcamos.
            if (points.length == 1)
              MarkerLayer(
                markers: [
                  Marker(
                    point: points.first,
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
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Widgets auxiliares de presentación
// ---------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.tarjetaMenta,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel({
    required this.icon,
    required this.label,
    this.uppercase = true,
  });

  final IconData icon;
  final String label;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.marca),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: uppercase ? 12 : 14,
              letterSpacing: uppercase ? 0.8 : 0,
              fontWeight: FontWeight.w600,
              color: context.textoSuave,
            ),
          ),
        ),
      ],
    );
  }
}

class _BigValue extends StatelessWidget {
  const _BigValue({required this.value, this.unit});

  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
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
    );
  }
}
