import 'package:flutter/material.dart';

import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../services/local_reminder_service.dart';
import '../theme/app_colors.dart';

class VaccineFormScreen extends StatefulWidget {
  const VaccineFormScreen({super.key, required this.mascotaId, this.vacuna});

  final String mascotaId;
  final Vacuna? vacuna;

  @override
  State<VaccineFormScreen> createState() => _VaccineFormScreenState();
}

class _VaccineFormScreenState extends State<VaccineFormScreen> {
  final _form = GlobalKey<FormState>();
  final _repo = PawLifeRepository();
  late final _nombre = TextEditingController(text: widget.vacuna?.nombre);
  late final _aviso = TextEditingController(
    text: (widget.vacuna?.anticipacionDias ?? 3).toString(),
  );
  late DateTime _aplicacion = widget.vacuna?.fechaAplicacion ?? DateTime.now();
  late DateTime _proxima =
      widget.vacuna?.proximaFecha ??
      DateTime.now().add(const Duration(days: 365));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => _CareScaffold(
    title: widget.vacuna == null ? 'Añadir vacuna' : 'Editar vacuna',
    saving: _guardando,
    onSave: _guardar,
    child: Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: 'Nombre de la vacuna',
              prefixIcon: Icon(Icons.vaccines_outlined),
            ),
            validator: _required,
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Fecha de aplicación',
            date: _aplicacion,
            onTap: () async {
              final value = await _fecha(_aplicacion);
              if (value != null) setState(() => _aplicacion = value);
            },
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Próxima dosis',
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
            decoration: const InputDecoration(
              labelText: 'Avisar con anticipación',
              suffixText: 'días',
            ),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              return n == null || n < 0 || n > 365
                  ? 'Ingresá un valor entre 0 y 365.'
                  : null;
            },
          ),
        ],
      ),
    ),
  );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) => _CareScaffold(
    title: 'Registrar alimentación',
    saving: _guardando,
    onSave: _guardar,
    child: Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            controller: _tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo de alimento',
              hintText: 'Ej. alimento seco',
              prefixIcon: Icon(Icons.restaurant_outlined),
            ),
            validator: _required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cantidad,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              suffixText: 'g',
            ),
            validator: (value) {
              final amount = double.tryParse(
                (value ?? '').replaceAll(',', '.'),
              );
              return amount == null || amount <= 0 || amount > 10000
                  ? 'Ingresá una cantidad válida.'
                  : null;
            },
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Fecha y hora',
            date: _fechaHora,
            onTap: _elegirFecha,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notas,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
        ],
      ),
    ),
  );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => _CareScaffold(
    title: widget.medicamento == null
        ? 'Añadir medicamento'
        : 'Editar medicamento',
    saving: _guardando,
    onSave: _guardar,
    child: Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: 'Medicamento',
              prefixIcon: Icon(Icons.medication_outlined),
            ),
            validator: _required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dosis,
            decoration: const InputDecoration(
              labelText: 'Dosis',
              hintText: 'Ej. 1 comprimido',
            ),
            validator: _required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _horarios,
            decoration: const InputDecoration(
              labelText: 'Horarios',
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
                  ? 'Usá horarios HH:mm separados por coma.'
                  : null;
            },
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Fecha de inicio',
            date: _inicio,
            onTap: () async {
              final v = await _fecha(_inicio);
              if (v != null) setState(() => _inicio = v);
            },
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Fecha de fin (opcional)',
            date: _fin,
            onTap: () async {
              final v = await _fecha(_fin ?? _inicio);
              if (v != null) setState(() => _fin = v);
            },
            onClear: _fin == null ? null : () => setState(() => _fin = null),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tratamiento activo'),
            value: _activo,
            onChanged: (v) => setState(() => _activo = v),
            activeThumbColor: AppColors.verdeOscuro,
          ),
        ],
      ),
    ),
  );
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'Este campo es obligatorio.' : null;

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
    backgroundColor: AppColors.fondo,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: AppColors.fondo,
      foregroundColor: AppColors.verdeOscuro,
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
            label: Text(saving ? 'Guardando…' : 'Guardar'),
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
      side: const BorderSide(color: AppColors.borde),
      borderRadius: BorderRadius.circular(12),
    ),
    leading: const Icon(Icons.calendar_month_outlined),
    title: Text(label),
    subtitle: Text(
      date == null
          ? 'Sin fecha'
          : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
    ),
    trailing: onClear == null
        ? const Icon(Icons.chevron_right)
        : IconButton(onPressed: onClear, icon: const Icon(Icons.close)),
    onTap: onTap,
  );
}
