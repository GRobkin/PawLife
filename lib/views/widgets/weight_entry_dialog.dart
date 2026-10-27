import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_client.dart';
import '../../services/pawlife_repository.dart';

class WeightEntryDialog extends StatefulWidget {
  const WeightEntryDialog({
    super.key,
    required this.repository,
    required this.mascotaId,
  });
  final PawLifeRepository repository;
  final String mascotaId;

  @override
  State<WeightEntryDialog> createState() => _WeightEntryDialogState();
}

class _WeightEntryDialogState extends State<WeightEntryDialog> {
  final _controller = TextEditingController();
  final _fecha = DateTime.now();
  final _id = List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  double? _pendingValue;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final kg = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (kg == null || !kg.isFinite || kg <= 0) {
      setState(() => _error = 'Ingresá un peso mayor que cero.');
      return;
    }
    // Un timeout permite reintentar la misma intención, con ID/fecha/valor estables.
    _pendingValue ??= kg;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.createPeso(
        widget.mascotaId,
        valorKg: _pendingValue!,
        fecha: _fecha,
        id: _id,
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          // Un rechazo de validación confirma que no hubo escritura. Permitir
          // corregirlo; ante timeout se conserva la intención para reintentar.
          if (error.statusCode == 400 || error.statusCode == 422) {
            _pendingValue = null;
          }
          _error = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No se pudo guardar el peso. Podés reintentar el mismo registro.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('Registrar peso'),
      content: TextField(
        controller: _controller,
        enabled: !_saving && _pendingValue == null,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          suffixText: 'kg',
          hintText: '0.0',
          errorText: _error,
          errorMaxLines: 4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Guardando…' : 'Guardar'),
        ),
      ],
    ),
  );
}
