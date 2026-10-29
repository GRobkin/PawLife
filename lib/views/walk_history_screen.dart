import 'package:flutter/material.dart';
import 'widgets/esqueletos.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../services/pawlife_repository.dart';
import '../services/walk_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'premium_screen.dart';
import 'walk_detail_screen.dart';
import 'widgets/estado_vacio.dart';
import 'widgets/foto_mascota.dart';
import 'widgets/walk_route_trace.dart';

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({
    super.key,
    this.mascota,
    this.petsRepository,
    this.walkRepository,
  });
  final Mascota? mascota;
  final PawLifeRepository? petsRepository;
  final WalkRepository? walkRepository;

  @override
  State<WalkHistoryScreen> createState() => _WalkHistoryScreenState();
}

class _WalkHistoryScreenState extends State<WalkHistoryScreen> {
  late final _pets = widget.petsRepository ?? PawLifeRepository();
  late final _walks = widget.walkRepository ?? WalkRepository();
  List<Mascota>? _mascotas;
  Mascota? _selected;
  final List<Paseo> _items = [];
  String? _cursor;
  String? _error;
  bool _loading = true;
  bool _premium = true;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _consultarPlan() async {
    try {
      final estado = await _pets.fetchPremium();
      if (mounted) setState(() => _premium = estado['activo'] == true);
    } catch (_) {
      // Sin dato del plan no se muestra el aviso.
    }
  }

  Future<void> _initialize() async {
    _consultarPlan();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pets = await _pets.fetchMascotas();
      if (!mounted) return;
      setState(() {
        _mascotas = pets;
        _selected =
            pets
                .where((p) => p.id == (widget.mascota?.id ?? _selected?.id))
                .firstOrNull ??
            pets.firstOrNull;
      });
      await _load(reset: true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = AppLocalizations.of(context).historyLoadError;
        });
      }
    }
  }

  Future<void> _load({required bool reset}) async {
    final pet = _selected;
    final generation = ++_generation;
    setState(() {
      _loading = pet != null;
      _error = null;
      if (reset) {
        _items.clear();
        _cursor = null;
      }
    });
    if (pet == null) return;
    try {
      final page = await _walks.fetchHistory(
        pet.id,
        cursor: reset ? null : _cursor,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        final known = _items.map((p) => p.id).toSet();
        _items.addAll(page.items.where((p) => !known.contains(p.id)));
        _cursor = page.nextCursor;
        _loading = false;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _error = AppLocalizations.of(context).walksLoadError;
        });
      }
    }
  }

  Future<void> _open(Paseo walk) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WalkDetailScreen(paseo: walk, mascota: _selected!),
      ),
    );
    if (mounted && deleted == true) await _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.fondoPantalla,
      appBar: AppBar(title: Text(t.walkHistoryTitle)),
      body: RefreshIndicator(
        onRefresh: _initialize,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              t.everyWalkCounts,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: context.marca),
            ),
            const SizedBox(height: 6),
            Text(t.reliveWalks),
            const SizedBox(height: 20),
            if (_mascotas != null && _mascotas!.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue: _selected?.id,
                key: ValueKey(_selected?.id),
                decoration: InputDecoration(
                  labelText: t.petLabel,
                  border: const OutlineInputBorder(),
                ),
                items: _mascotas!
                    .map(
                      (p) =>
                          DropdownMenuItem(value: p.id, child: Text(p.nombre)),
                    )
                    .toList(),
                onChanged: _loading
                    ? null
                    : (id) {
                        setState(
                          () => _selected = _mascotas!.firstWhere(
                            (p) => p.id == id,
                          ),
                        );
                        _load(reset: true);
                      },
              ),
              const SizedBox(height: 20),
            ],
            if (_mascotas?.isEmpty == true)
              _HistoryEmpty(text: t.addPetToLogWalks)
            else if (!_loading && _items.isEmpty && _error == null)
              _HistoryEmpty(text: t.noWalksYetHome),
            for (final walk in _items)
              Card(
                margin: const EdgeInsets.only(bottom: 14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _open(walk),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AvatarMascota(mascota: _selected!, radio: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                t.walkWith(_selected!.nombre),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: WalkRouteTrace(
                            points: walk.ruta,
                            startColor: context.esOscuro
                                ? Colors.white
                                : AppColors.verdeOscuro,
                          ),
                        ),
                        Text(formatDateTime(context, walk.fechaInicio)),
                        const SizedBox(height: 6),
                        Text(
                          '${(walk.distanciaMetros / 1000).toStringAsFixed(2)} km · ${t.durationMinSec(walk.duracion.inMinutes, walk.duracion.inSeconds % 60)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: context.marca),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_loading && _items.isEmpty) ...const [
              EsqueletoTarjetaPaseo(),
              EsqueletoTarjetaPaseo(),
            ] else if (_loading)
              const EsqueletoTarjetaPaseo(),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: context.alertaTexto)),
              TextButton(
                onPressed: _mascotas == null
                    ? _initialize
                    : () => _load(reset: _items.isEmpty),
                child: Text(t.retry),
              ),
            ] else if (!_loading && _cursor != null)
              OutlinedButton(
                onPressed: () => _load(reset: false),
                child: Text(t.loadMoreWalks),
              ),
            if (!_premium && !_loading && _items.isNotEmpty) ...[
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PremiumScreen(repository: _pets),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.mentaSuave,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium, color: context.marca),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.walkHistoryFreeNote,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.marca,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.marca),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) =>
      EstadoVacio(icono: Icons.directions_walk, titulo: text);
}
