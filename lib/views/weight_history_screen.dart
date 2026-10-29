import 'package:flutter/material.dart';
import 'widgets/esqueletos.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/pawlife_repository.dart';
import 'widgets/weight_entry_dialog.dart';

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({
    super.key,
    required this.mascota,
    this.repository,
  });
  final Mascota mascota;
  final PawLifeRepository? repository;

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen> {
  AppLocalizations get t => AppLocalizations.of(context);

  late final _repo =
      widget.repository ??
      PawLifeRepository(
        client: ApiClient(expectedUid: AuthService().currentUser?.uid ?? ''),
      );
  List<RegistroPeso>? _items;
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

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final items = await _repo.fetchPesos(widget.mascota.id);
      if (mounted) setState(() => _items = items);
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error = apiErrorText(AppLocalizations.of(context), error),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = t.weightLoadError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          WeightEntryDialog(repository: _repo, mascotaId: widget.mascota.id),
    );
    if (saved == true && mounted) await _load();
  }

  Future<void> _delete(RegistroPeso item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.deleteWeightTitle),
        content: Text(
          '${item.valorKg} kg · ${MaterialLocalizations.of(context).formatMediumDate(item.fecha)}',
        ),
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
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.deletePeso(widget.mascota.id, item.id);
      if (mounted) await _load();
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error = apiErrorText(AppLocalizations.of(context), error),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = t.weightDeleteError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(t.weightHistory)),
    body: Column(
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
              ? Center(child: Text(t.noWeightRecords))
              : ListView.separated(
                  itemCount: _items!.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items![index];
                    return ListTile(
                      key: ValueKey(item.id),
                      leading: const Icon(Icons.monitor_weight_outlined),
                      title: Text('${item.valorKg} kg'),
                      subtitle: Text(
                        '${MaterialLocalizations.of(context).formatMediumDate(item.fecha)} · ${TimeOfDay.fromDateTime(item.fecha).format(context)}',
                      ),
                      trailing: IconButton(
                        tooltip: t.deleteWeightTitle,
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
              label: Text(t.logWeight),
            ),
          ),
        ),
      ],
    ),
  );
}
