import 'package:flutter/material.dart';

import '../models/pawlife_models.dart';
import '../services/pawlife_repository.dart';
import '../services/local_reminder_service.dart';
import '../theme/app_colors.dart';
import 'widgets/iniciar_paseo.dart';
import 'widgets/pawlife_bottom_nav.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repo = PawLifeRepository();
  List<Recordatorio>? _items;
  List<Mascota> _mascotas = [];
  String? _error;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await Future.wait([
        _repo.fetchRecordatorios(),
        _repo.fetchMascotas(),
      ]);
      if (!mounted) return;
      setState(() {
        _items = result[0] as List<Recordatorio>;
        _mascotas = result[1] as List<Mascota>;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudieron cargar las tareas: $e');
      }
    }
  }

  Future<void> _change(Recordatorio item, bool value) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await _repo.marcarRecordatorio(item.id, completado: value);
      await LocalReminderService.instance.syncBestEffort(_repo);
      await _load();
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _delete(Recordatorio item) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await _repo.deleteRecordatorio(item.id);
      await LocalReminderService.instance.syncBestEffort(_repo);
      await _load();
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _showError(Object e) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    }
  }

  Future<void> _add() async {
    if (_mascotas.isEmpty) {
      _showError('Agregá una mascota antes de crear una tarea.');
      return;
    }
    var mensaje = '';
    var mascotaId = _mascotas.first.id;
    var fecha = DateTime.now().add(const Duration(days: 1));
    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Nueva tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: mascotaId,
                decoration: const InputDecoration(labelText: 'Mascota'),
                items: _mascotas
                    .map(
                      (m) =>
                          DropdownMenuItem(value: m.id, child: Text(m.nombre)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => mascotaId = value);
                },
              ),
              TextField(
                onChanged: (value) => mensaje = value,
                maxLength: 160,
                decoration: const InputDecoration(
                  labelText: '¿Qué hay que hacer?',
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.event),
                label: Text(
                  '${fecha.day}/${fecha.month}/${fecha.year} '
                  '${fecha.hour.toString().padLeft(2, '0')}:'
                  '${fecha.minute.toString().padLeft(2, '0')}',
                ),
                onPressed: () async {
                  final dia = await showDatePicker(
                    context: dialogContext,
                    initialDate: fecha,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (dia == null || !dialogContext.mounted) return;
                  final hora = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.fromDateTime(fecha),
                  );
                  if (hora == null) return;
                  setDialogState(
                    () => fecha = DateTime(
                      dia.year,
                      dia.month,
                      dia.day,
                      hora.hour,
                      hora.minute,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (mensaje.trim().isEmpty || fecha.isBefore(DateTime.now())) {
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (guardar != true) return;
    setState(() => _working = true);
    try {
      await _repo.createRecordatorio(
        tipo: 'tarea',
        mascotaId: mascotaId,
        fecha: fecha,
        mensaje: mensaje.trim(),
      );
      await LocalReminderService.instance.syncBestEffort(_repo);
      await _load();
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [...?_items]..sort((a, b) => a.fecha.compareTo(b.fecha));
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: const Text('Tareas'),
        backgroundColor: AppColors.fondo,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: const Text('Reintentar')),
                ],
              ),
            )
          : _items == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Todavía no hay tareas.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final mascota = _mascotas.where(
                          (m) => m.id == item.mascotaId,
                        );
                        final nombre = mascota.isEmpty
                            ? 'Mascota'
                            : mascota.first.nombre;
                        return Card(
                          child: CheckboxListTile(
                            value: item.completado,
                            onChanged: _working
                                ? null
                                : (v) => _change(item, v ?? false),
                            title: Text(item.mensaje),
                            subtitle: Text(
                              '$nombre · ${item.fecha.day}/${item.fecha.month}/${item.fecha.year} '
                              '${item.fecha.hour.toString().padLeft(2, '0')}:'
                              '${item.fecha.minute.toString().padLeft(2, '0')}',
                            ),
                            secondary: IconButton(
                              tooltip: 'Eliminar tarea',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _working ? null : () => _delete(item),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _working ? null : _add,
        backgroundColor: AppColors.verdeOscuro,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.tareas,
        onPaseo: () => iniciarPaseo(context),
      ),
    );
  }
}
