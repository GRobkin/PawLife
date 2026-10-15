import 'package:flutter/material.dart';

import '../models/pawlife_models.dart';
import '../services/pawlife_repository.dart';
import '../services/walk_repository.dart';
import '../theme/app_colors.dart';
import 'walk_detail_screen.dart';
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
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
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
          _error = 'No se pudo cargar el historial. Comprobá tu conexión.';
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
          _error =
              'No se pudieron cargar los paseos. Reintentá o actualizá el historial.';
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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.fondo,
    appBar: AppBar(title: const Text('Historial de paseos')),
    body: RefreshIndicator(
      onRefresh: _initialize,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Cada paseo cuenta',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.verdeOscuro,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Reviví sus recorridos y compartí un recuerdo juntos.'),
          const SizedBox(height: 20),
          if (_mascotas != null && _mascotas!.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              initialValue: _selected?.id,
              key: ValueKey(_selected?.id),
              decoration: const InputDecoration(
                labelText: 'Mascota',
                border: OutlineInputBorder(),
              ),
              items: _mascotas!
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.nombre)),
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
            const _HistoryEmpty(
              text: 'Agregá una mascota para empezar a registrar sus paseos.',
            )
          else if (!_loading && _items.isEmpty && _error == null)
            const _HistoryEmpty(
              text:
                  'Todavía no hay paseos. Iniciá uno desde el botón verde de la app.',
            ),
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
                              'Paseo con ${_selected!.nombre}',
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
                        child: WalkRouteTrace(points: walk.ruta),
                      ),
                      Text(
                        '${walk.fechaInicio.day}/${walk.fechaInicio.month}/${walk.fechaInicio.year} · '
                        '${walk.fechaInicio.hour.toString().padLeft(2, '0')}:${walk.fechaInicio.minute.toString().padLeft(2, '0')}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(walk.distanciaMetros / 1000).toStringAsFixed(2)} km · ${walk.duracion.inMinutes} min ${walk.duracion.inSeconds % 60} s',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.verdeOscuro,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.alerta)),
            TextButton(
              onPressed: _mascotas == null
                  ? _initialize
                  : () => _load(reset: _items.isEmpty),
              child: const Text('Reintentar'),
            ),
          ] else if (!_loading && _cursor != null)
            OutlinedButton(
              onPressed: () => _load(reset: false),
              child: const Text('Cargar más paseos'),
            ),
        ],
      ),
    ),
  );
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 45),
    child: Column(
      children: [
        const Icon(
          Icons.directions_walk,
          size: 54,
          color: AppColors.verdeAcento,
        ),
        const SizedBox(height: 16),
        Text(text, textAlign: TextAlign.center),
      ],
    ),
  );
}
