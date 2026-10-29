import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../services/pawlife_repository.dart';
import '../services/local_reminder_service.dart';
import '../theme/app_palette.dart';
import 'widgets/estado_vacio.dart';
import 'widgets/hoja_nueva_tarea.dart';
import 'widgets/iniciar_paseo.dart';
import 'widgets/motion.dart';
import 'widgets/esqueletos.dart';
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

  Future<void> _edit(Recordatorio item) async {
    final tarea = await mostrarHojaNuevaTarea(
      context,
      _mascotas,
      inicial: NuevaTarea(
        mascotaId: item.mascotaId,
        mensaje: item.mensaje,
        fecha: item.fecha,
      ),
    );
    if (tarea == null || !mounted) return;
    setState(() => _working = true);
    try {
      await _repo.updateRecordatorio(
        item.id,
        mascotaId: tarea.mascotaId,
        fecha: tarea.fecha,
        mensaje: tarea.mensaje,
      );
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
    if (_mascotas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).addPetFirst)),
      );
      return;
    }
    final tarea = await mostrarHojaNuevaTarea(context, _mascotas);
    if (tarea == null || !mounted) return;
    setState(() => _working = true);
    try {
      await _repo.createRecordatorio(
        tipo: 'tarea',
        mascotaId: tarea.mascotaId,
        fecha: tarea.fecha,
        mensaje: tarea.mensaje,
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
      body: TransicionCarga(
        child: KeyedSubtree(
          key: ValueKey('${_error != null}-${_items == null}'),
          child: _error != null
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
              ? const EsqueletoLista()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: items.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 60),
                            EstadoVacio(
                              icono: Icons.assignment_outlined,
                              titulo: t.noTasks,
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final mascota = _mascotas.where(
                              (m) => m.id == item.mascotaId,
                            );
                            final nombre = mascota.isEmpty
                                ? t.petLabel
                                : mascota.first.nombre;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _FilaTarea(
                                tarea: item,
                                mascota: nombre,
                                cuando: formatDateTime(context, item.fecha),
                                bloqueada: _working,
                                tooltipBorrar: t.deleteTask,
                                onCambio: (v) => _change(item, v),
                                onEditar: () => _edit(item),
                                onBorrar: () => _delete(item),
                              ),
                            );
                          },
                        ),
                ),
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

/// Tarea como tarjeta propia: check redondo que rebota al completar, texto
/// tachado y atenuado si está hecha, mascota en una pastilla y la hora.
class _FilaTarea extends StatelessWidget {
  const _FilaTarea({
    required this.tarea,
    required this.mascota,
    required this.cuando,
    required this.bloqueada,
    required this.tooltipBorrar,
    required this.onCambio,
    required this.onEditar,
    required this.onBorrar,
  });

  final Recordatorio tarea;
  final String mascota;
  final String cuando;
  final bool bloqueada;
  final String tooltipBorrar;
  final ValueChanged<bool> onCambio;
  final VoidCallback onEditar;
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) {
    final hecha = tarea.completado;
    final rapido = reducirMovimiento(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return Presionable(
      child: Material(
        color: hecha ? context.relleno : context.superficie,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          // La tarjeta abre la edición; el círculo marca o desmarca.
          onTap: bloqueada ? null : onEditar,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                Semantics(
                  checked: hecha,
                  button: true,
                  child: InkResponse(
                    radius: 22,
                    onTap: bloqueada ? null : () => onCambio(!hecha),
                    child: ReboteAlActivar(
                      activo: hecha,
                      child: AnimatedContainer(
                        duration: rapido,
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hecha
                              ? context.botonFondo
                              : Colors.transparent,
                          border: Border.all(
                            color: hecha
                                ? context.botonFondo
                                : context.textoTenue,
                            width: 2,
                          ),
                        ),
                        child: hecha
                            ? Icon(
                                Icons.check,
                                size: 17,
                                color: context.botonTexto,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: rapido,
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: hecha ? context.textoTenue : context.texto,
                          decoration: hecha ? TextDecoration.lineThrough : null,
                        ),
                        child: Text(
                          tarea.mensaje,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.mentaSuave,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.pets,
                                  size: 12,
                                  color: context.marca,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mascota,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: context.marca,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: context.textoTenue,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              cuando,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textoSuave,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: tooltipBorrar,
                  onPressed: bloqueada ? null : onBorrar,
                  icon: Icon(Icons.delete_outline, color: context.textoTenue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
