import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../services/pawlife_repository.dart';
import '../services/local_reminder_service.dart';
import '../theme/app_palette.dart';
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
        setState(
          () => _error = AppLocalizations.of(context).tasksLoadError('$e'),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).genericSaveError('$e')),
        ),
      );
    }
  }

  Future<void> _add() async {
    final t = AppLocalizations.of(context);
    if (_mascotas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).addPetFirst)),
      );
      return;
    }
    var mensaje = '';
    var mascotaId = _mascotas.first.id;
    var fecha = DateTime.now().add(const Duration(days: 1));
    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(t.newTask),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: mascotaId,
                decoration: InputDecoration(labelText: t.petLabel),
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
                decoration: InputDecoration(labelText: t.taskPrompt),
              ),
              TextButton.icon(
                icon: const Icon(Icons.event),
                label: Text(formatDateTime(dialogContext, fecha)),
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
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (mensaje.trim().isEmpty || fecha.isBefore(DateTime.now())) {
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: Text(t.save),
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
    final t = AppLocalizations.of(context);
    final items = [...?_items]..sort((a, b) => a.fecha.compareTo(b.fecha));
    return Scaffold(
      backgroundColor: context.fondoPantalla,
      appBar: AppBar(
        title: Text(t.tasksTitle),
        backgroundColor: context.fondoPantalla,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: Text(t.retry)),
                ],
              ),
            )
          : _items == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(child: Text(t.noTasks)),
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
                            ? t.petLabel
                            : mascota.first.nombre;
                        return Card(
                          child: CheckboxListTile(
                            value: item.completado,
                            onChanged: _working
                                ? null
                                : (v) => _change(item, v ?? false),
                            title: Text(item.mensaje),
                            subtitle: Text(
                              '$nombre · ${formatDateTime(context, item.fecha)}',
                            ),
                            secondary: IconButton(
                              tooltip: t.deleteTask,
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
        backgroundColor: context.botonFondo,
        foregroundColor: context.botonTexto,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.tareas,
        onPaseo: () => iniciarPaseo(context),
      ),
    );
  }
}
