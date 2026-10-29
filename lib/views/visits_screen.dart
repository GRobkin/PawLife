import 'dart:math';

import 'package:flutter/material.dart';
import 'widgets/esqueletos.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/pawlife_repository.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key, required this.mascota, this.repository});
  final Mascota mascota;
  final PawLifeRepository? repository;

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  AppLocalizations get t => AppLocalizations.of(context);

  late final _repo =
      widget.repository ??
      PawLifeRepository(
        client: ApiClient(expectedUid: AuthService().currentUser?.uid ?? ''),
      );
  List<VisitaVeterinaria>? _items;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    if (widget.repository == null) _repo.client.close();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function() action,
    String Function(AppLocalizations) fallback,
  ) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error = apiErrorText(AppLocalizations.of(context), error),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = fallback(AppLocalizations.of(context)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    final items = await _repo.fetchVisitas(widget.mascota.id);
    if (mounted) setState(() => _items = items);
  }

  Future<void> _load() async => _run(_refresh, (t) => t.visitsLoadError);

  Future<void> _add() async {
    final visita = await showDialog<VisitaVeterinaria>(
      context: context,
      builder: (_) => const _VisitDialog(),
    );
    if (visita == null || !mounted) return;
    await _run(() async {
      await _repo.createVisita(widget.mascota.id, visita);
      await _refresh();
    }, (t) => t.visitsSaveError);
  }

  Future<void> _delete(VisitaVeterinaria item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.visitDeleteTitle),
        content: Text(item.motivo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      await _repo.deleteVisita(widget.mascota.id, item.id);
      await _refresh();
    }, (t) => t.visitsDeleteError);
  }

  @override
  Widget build(BuildContext context) {
    final fechas = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.visitsTitle)),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _load,
                    child: Text(t.retry),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _items == null
                ? (_error == null
                      ? const EsqueletoLista(filas: 4)
                      : const SizedBox.shrink())
                : _items!.isEmpty
                ? Center(child: Text(t.visitsEmpty))
                : ListView.separated(
                    itemCount: _items!.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _items![index];
                      final detalle = [
                        fechas.formatMediumDate(item.fecha),
                        if (item.veterinario?.isNotEmpty ?? false)
                          item.veterinario!,
                        if (item.proximaFecha != null)
                          '${t.visitNextDate}: ${fechas.formatMediumDate(item.proximaFecha!)}',
                        if (item.notas?.isNotEmpty ?? false) item.notas!,
                      ].join(' · ');
                      return ListTile(
                        key: ValueKey(item.id),
                        leading: const Icon(Icons.local_hospital_outlined),
                        title: Text(item.motivo),
                        subtitle: Text(detalle),
                        isThreeLine: detalle.length > 48,
                        trailing: IconButton(
                          tooltip: t.visitDeleteTitle,
                          onPressed: _busy ? null : () => _delete(item),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _busy ? null : _add,
                icon: const Icon(Icons.add),
                label: Text(t.visitsAdd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitDialog extends StatefulWidget {
  const _VisitDialog();

  @override
  State<_VisitDialog> createState() => _VisitDialogState();
}

class _VisitDialogState extends State<_VisitDialog> {
  AppLocalizations get t => AppLocalizations.of(context);

  final _motivo = TextEditingController();
  final _vet = TextEditingController();
  final _notas = TextEditingController();
  final _id = List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  DateTime _fecha = DateTime.now();
  DateTime? _proxima;
  String? _error;

  @override
  void dispose() {
    _motivo.dispose();
    _vet.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<DateTime?> _elegir(DateTime inicial, DateTime desde, DateTime hasta) =>
      showDatePicker(
        context: context,
        initialDate: inicial,
        firstDate: desde,
        lastDate: hasta,
      );

  String? _limpio(TextEditingController c) {
    final texto = c.text.trim();
    return texto.isEmpty ? null : texto;
  }

  void _guardar() {
    final motivo = _motivo.text.trim();
    if (motivo.isEmpty) {
      setState(() => _error = t.errVisitReason);
      return;
    }
    if (_proxima != null && _proxima!.isBefore(_fecha)) {
      setState(() => _error = t.errVisitNextBefore);
      return;
    }
    Navigator.pop(
      context,
      VisitaVeterinaria(
        id: _id,
        fecha: _fecha,
        motivo: motivo,
        veterinario: _limpio(_vet),
        notas: _limpio(_notas),
        proximaFecha: _proxima,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechas = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(t.visitsAdd),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _motivo,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: t.visitReason,
                errorText: _error,
                errorMaxLines: 3,
              ),
            ),
            TextField(
              controller: _vet,
              maxLength: 120,
              decoration: InputDecoration(labelText: t.visitVet),
            ),
            TextField(
              controller: _notas,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.visitNotes),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.visitDate),
              subtitle: Text(fechas.formatMediumDate(_fecha)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () async {
                final d = await _elegir(
                  _fecha,
                  DateTime(2000),
                  DateTime.now().add(const Duration(days: 1)),
                );
                if (d != null) setState(() => _fecha = d);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.visitNextDate),
              subtitle: Text(
                _proxima == null
                    ? t.visitNone
                    : fechas.formatMediumDate(_proxima!),
              ),
              trailing: _proxima == null
                  ? const Icon(Icons.event_outlined)
                  : IconButton(
                      tooltip: t.visitNone,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _proxima = null),
                    ),
              onTap: () async {
                final d = await _elegir(
                  _proxima ?? _fecha,
                  _fecha,
                  DateTime.now().add(const Duration(days: 3650)),
                );
                if (d != null) setState(() => _proxima = d);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _guardar, child: Text(t.save)),
      ],
    );
  }
}
