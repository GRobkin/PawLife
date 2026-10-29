import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../services/local_reminder_service.dart';
import '../theme/app_palette.dart';

class VaccineFormScreen extends StatefulWidget {
  const VaccineFormScreen({
    super.key,
    required this.mascotaId,
    this.vacuna,
    this.plantilla,
  });

  final String mascotaId;
  final Vacuna? vacuna;

  /// Nueva dosis de una vacuna existente: copia el nombre y el aviso, pero
  /// guarda un registro nuevo con fechas nuevas.
  final Vacuna? plantilla;

  @override
  State<VaccineFormScreen> createState() => _VaccineFormScreenState();
}

class _VaccineFormScreenState extends State<VaccineFormScreen> {
  final _form = GlobalKey<FormState>();
  final _repo = PawLifeRepository();
  late final _nombre = TextEditingController(
    text: widget.vacuna?.nombre ?? widget.plantilla?.nombre,
  );
  late final _aviso = TextEditingController(
    text:
        (widget.vacuna?.anticipacionDias ??
                widget.plantilla?.anticipacionDias ??
                3)
            .toString(),
  );
  late DateTime _aplicacion = widget.vacuna?.fechaAplicacion ?? DateTime.now();
  late DateTime _proxima =
      widget.vacuna?.proximaFecha ??
      DateTime.now().add(
        widget.plantilla == null
            ? const Duration(days: 365)
            : widget.plantilla!.proximaFecha.difference(
                widget.plantilla!.fechaAplicacion,
              ),
      );
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _aviso.dispose();
    super.dispose();
  }

  Future<DateTime?> _fecha(DateTime actual) => showDatePicker(
    context: context,
    initialDate: actual,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final aviso = int.parse(_aviso.text);
      if (widget.vacuna == null) {
        await _repo.createVacuna(
          widget.mascotaId,
          nombre: _nombre.text.trim(),
          fechaAplicacion: _aplicacion,
          proximaFecha: _proxima,
          anticipacionDias: aviso,
        );
      } else {
        await _repo.updateVacuna(widget.mascotaId, widget.vacuna!.id, {
          'nombre': _nombre.text.trim(),
          'fechaAplicacion': _aplicacion.toUtc().toIso8601String(),
          'proximaFecha': _proxima.toUtc().toIso8601String(),
          'anticipacionDias': aviso,
        });
      }
      try {
        await LocalReminderService.instance.syncBestEffort(_repo);
      } catch (_) {
        // El registro se guardó; se intentará reprogramar al iniciar sesión.
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiErrorText(AppLocalizations.of(context), e)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _CareScaffold(
      title: widget.vacuna == null ? t.addVaccine : t.editVaccine,
      saving: _guardando,
      onSave: _guardar,
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _nombre,
              decoration: InputDecoration(
                labelText: t.vaccineName,
                prefixIcon: const Icon(Icons.vaccines_outlined),
              ),
              validator: _required(context),
            ),
            const SizedBox(height: 16),
            _DateField(
              label: t.applicationDate,
              date: _aplicacion,
              onTap: () async {
                final value = await _fecha(_aplicacion);
                if (value != null) setState(() => _aplicacion = value);
              },
            ),
            const SizedBox(height: 16),
            _DateField(
              label: t.nextDose,
              date: _proxima,
              onTap: () async {
                final value = await _fecha(_proxima);
                if (value != null) setState(() => _proxima = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aviso,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.remindInAdvance,
                suffixText: t.daysUnit,
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n < 0 || n > 365 ? t.errRange0to365 : null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MedicationFormScreen extends StatefulWidget {
  const MedicationFormScreen({
    super.key,
    required this.mascotaId,
    this.medicamento,
  });

  final String mascotaId;
  final Medicamento? medicamento;

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class FoodFormScreen extends StatefulWidget {
  const FoodFormScreen({super.key, required this.mascotaId});
  final String mascotaId;

  @override
  State<FoodFormScreen> createState() => _FoodFormScreenState();
}

class _FoodFormScreenState extends State<FoodFormScreen> {
  final _form = GlobalKey<FormState>();
  final _repo = PawLifeRepository();
  final _tipo = TextEditingController();
  final _cantidad = TextEditingController();
  final _notas = TextEditingController();
  DateTime _fechaHora = DateTime.now();
  bool _guardando = false;

  @override
  void dispose() {
    _tipo.dispose();
    _cantidad.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha == null || !mounted) return;
    final hora = await showTimePicker(
      orientation: Orientation.portrait,
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
    );
    if (hora == null) return;
    setState(() {
      _fechaHora = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await _repo.createAlimentacion(
        widget.mascotaId,
        tipoAlimento: _tipo.text.trim(),
        cantidadGramos: double.parse(_cantidad.text.replaceAll(',', '.')),
        fechaHora: _fechaHora,
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiErrorText(AppLocalizations.of(context), e)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _CareScaffold(
      title: t.logFeeding,
      saving: _guardando,
      onSave: _guardar,
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _tipo,
              decoration: InputDecoration(
                labelText: t.foodType,
                hintText: t.foodTypeHint,
                prefixIcon: const Icon(Icons.restaurant_outlined),
              ),
              validator: _required(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cantidad,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: t.amountLabel,
                suffixText: 'g',
              ),
              validator: (value) {
                final amount = double.tryParse(
                  (value ?? '').replaceAll(',', '.'),
                );
                return amount == null || amount <= 0 || amount > 10000
                    ? t.errValidAmount
                    : null;
              },
            ),
            const SizedBox(height: 16),
            _DateField(
              label: t.dateAndTime,
              date: _fechaHora,
              onTap: _elegirFecha,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notas,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.notesOptional),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _form = GlobalKey<FormState>();
  final _repo = PawLifeRepository();
  late final _nombre = TextEditingController(text: widget.medicamento?.nombre);
  late final _dosis = TextEditingController(text: widget.medicamento?.dosis);
  late final _horarios = TextEditingController(
    text: widget.medicamento?.horarios.join(', '),
  );
  late DateTime _inicio = widget.medicamento?.fechaInicio ?? DateTime.now();
  DateTime? _fin;
  late bool _activo = widget.medicamento?.activo ?? true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _fin = widget.medicamento?.fechaFin;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _dosis.dispose();
    _horarios.dispose();
    super.dispose();
  }

  Future<DateTime?> _fecha(DateTime actual) => showDatePicker(
    context: context,
    initialDate: actual,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  List<String> get _hours => _horarios.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final data = {
        'nombre': _nombre.text.trim(),
        'dosis': _dosis.text.trim(),
        'horarios': _hours,
        'fechaInicio': _inicio.toUtc().toIso8601String(),
        'fechaFin': _fin?.toUtc().toIso8601String(),
        'activo': _activo,
      };
      if (widget.medicamento == null) {
        await _repo.createMedicamento(
          widget.mascotaId,
          nombre: _nombre.text.trim(),
          dosis: _dosis.text.trim(),
          horarios: _hours,
          fechaInicio: _inicio,
          fechaFin: _fin,
          activo: _activo,
        );
      } else {
        await _repo.updateMedicamento(
          widget.mascotaId,
          widget.medicamento!.id,
          data,
        );
      }
      try {
        await LocalReminderService.instance.syncBestEffort(_repo);
      } catch (_) {
        // El registro se guardó; se intentará reprogramar al iniciar sesión.
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiErrorText(AppLocalizations.of(context), e)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _CareScaffold(
      title: widget.medicamento == null ? t.addMedication : t.editMedication,
      saving: _guardando,
      onSave: _guardar,
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _nombre,
              decoration: InputDecoration(
                labelText: t.medicationLabel,
                prefixIcon: const Icon(Icons.medication_outlined),
              ),
              validator: _required(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosis,
              decoration: InputDecoration(
                labelText: t.doseLabel,
                hintText: t.doseHint,
              ),
              validator: _required(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _horarios,
              decoration: InputDecoration(
                labelText: t.schedulesLabel,
                hintText: '09:00, 21:00',
              ),
              validator: (v) {
                final values = (v ?? '')
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty);
                return values.isEmpty ||
                        values.any(
                          (e) =>
                              !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(e),
                        )
                    ? t.errTimesFormat
                    : null;
              },
            ),
            const SizedBox(height: 16),
            _DateField(
              label: t.startDate,
              date: _inicio,
              onTap: () async {
                final v = await _fecha(_inicio);
                if (v != null) setState(() => _inicio = v);
              },
            ),
            const SizedBox(height: 16),
            _DateField(
              label: t.endDateOptional,
              date: _fin,
              onTap: () async {
                final v = await _fecha(_fin ?? _inicio);
                if (v != null) setState(() => _fin = v);
              },
              onClear: _fin == null ? null : () => setState(() => _fin = null),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.activeTreatment),
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
              activeThumbColor: context.botonFondo,
            ),
          ],
        ),
      ),
    );
  }
}

String? Function(String?) _required(BuildContext context) {
  final message = AppLocalizations.of(context).requiredField;
  return (value) => value == null || value.trim().isEmpty ? message : null;
}

class _CareScaffold extends StatelessWidget {
  const _CareScaffold({
    required this.title,
    required this.child,
    required this.saving,
    required this.onSave,
  });
  final String title;
  final Widget child;
  final bool saving;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.fondoPantalla,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: context.fondoPantalla,
      foregroundColor: context.marca,
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.superficie,
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(
              saving
                  ? AppLocalizations.of(context).saving
                  : AppLocalizations.of(context).save,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
  });
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    shape: RoundedRectangleBorder(
      side: BorderSide(color: context.bordeSuave),
      borderRadius: BorderRadius.circular(12),
    ),
    leading: const Icon(Icons.calendar_month_outlined),
    title: Text(label),
    subtitle: Text(
      date == null
          ? AppLocalizations.of(context).noDate
          : formatDate(context, date!),
    ),
    trailing: onClear == null
        ? const Icon(Icons.chevron_right)
        : IconButton(onPressed: onClear, icon: const Icon(Icons.close)),
    onTap: onTap,
  );
}
