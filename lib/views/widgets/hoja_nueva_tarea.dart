// views/widgets/hoja_nueva_tarea.dart
//
// Hoja inferior para crear una tarea: la mascota se elige con fichas, el texto
// va en un campo grande y la fecha y la hora son dos tarjetas que se tocan.

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pawlife_models.dart';
import '../../theme/app_palette.dart';
import 'motion.dart';

class NuevaTarea {
  const NuevaTarea({
    required this.mascotaId,
    required this.mensaje,
    required this.fecha,
  });

  final String mascotaId;
  final String mensaje;
  final DateTime fecha;
}

Future<NuevaTarea?> mostrarHojaNuevaTarea(
  BuildContext context,
  List<Mascota> mascotas,
) => showModalBottomSheet<NuevaTarea>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: context.fondoPantalla,
  builder: (_) => _HojaNuevaTarea(mascotas: mascotas),
);

class _HojaNuevaTarea extends StatefulWidget {
  const _HojaNuevaTarea({required this.mascotas});

  final List<Mascota> mascotas;

  @override
  State<_HojaNuevaTarea> createState() => _HojaNuevaTareaState();
}

class _HojaNuevaTareaState extends State<_HojaNuevaTarea> {
  late String _mascotaId = widget.mascotas.first.id;
  final _texto = TextEditingController();
  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  String? _error;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final dia = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (dia == null || !mounted) return;
    setState(
      () => _fecha = DateTime(
        dia.year,
        dia.month,
        dia.day,
        _fecha.hour,
        _fecha.minute,
      ),
    );
  }

  Future<void> _elegirHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fecha),
    );
    if (hora == null || !mounted) return;
    setState(
      () => _fecha = DateTime(
        _fecha.year,
        _fecha.month,
        _fecha.day,
        hora.hour,
        hora.minute,
      ),
    );
  }

  void _guardar() {
    final t = AppLocalizations.of(context);
    final mensaje = _texto.text.trim();
    if (mensaje.isEmpty) {
      setState(() => _error = t.errTaskEmpty);
      return;
    }
    if (_fecha.isBefore(DateTime.now())) {
      setState(() => _error = t.errTaskPast);
      return;
    }
    Navigator.pop(
      context,
      NuevaTarea(mascotaId: _mascotaId, mensaje: mensaje, fecha: _fecha),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final local = MaterialLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.newTask,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: context.texto,
                ),
              ),
              const SizedBox(height: 18),
              if (widget.mascotas.length > 1) ...[
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.mascotas.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final m = widget.mascotas[i];
                      final elegida = m.id == _mascotaId;
                      return _FichaMascota(
                        mascota: m,
                        elegida: elegida,
                        onTap: () => setState(() => _mascotaId = m.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                decoration: BoxDecoration(
                  color: context.superficie,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _texto,
                  autofocus: true,
                  maxLength: 160,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.texto,
                  ),
                  decoration: InputDecoration(
                    hintText: t.taskPrompt,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    counterStyle: TextStyle(color: context.textoTenue),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TarjetaCuando(
                      icono: Icons.calendar_today_outlined,
                      etiqueta: t.visitDate,
                      valor: local.formatMediumDate(_fecha),
                      onTap: _elegirFecha,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TarjetaCuando(
                      icono: Icons.schedule,
                      etiqueta: t.taskTimeLabel,
                      valor: TimeOfDay.fromDateTime(_fecha).format(context),
                      onTap: _elegirHora,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _error == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Presionable(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _guardar,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.botonFondo,
                      foregroundColor: context.botonTexto,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      t.save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FichaMascota extends StatelessWidget {
  const _FichaMascota({
    required this.mascota,
    required this.elegida,
    required this.onTap,
  });

  final Mascota mascota;
  final bool elegida;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: elegida,
      button: true,
      child: Presionable(
        child: Material(
          color: elegida ? context.botonFondo : context.superficie,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: elegida
                        ? context.botonTexto.withValues(alpha: 0.18)
                        : context.mentaSuave,
                    child: Text(
                      mascota.inicial,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: elegida ? context.botonTexto : context.marca,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mascota.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: elegida ? context.botonTexto : context.texto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaCuando extends StatelessWidget {
  const _TarjetaCuando({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.onTap,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Presionable(
      child: Material(
        color: context.superficie,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.mentaSuave,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, size: 18, color: context.marca),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        etiqueta,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textoSuave,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        valor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.texto,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
