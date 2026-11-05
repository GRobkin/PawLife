import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_palette.dart';

/// Calendario de PawLife: hoja inferior con el mismo estilo que el selector de
/// hora, atajos (hoy, mañana, en una semana, en un mes) y los botones de
/// siempre. Acepta los mismos parámetros que `showDatePicker`.
Future<DateTime?> elegirFecha({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 480),
    backgroundColor: context.superficie,
    builder: (_) => SelectorFecha(
      inicial: initialDate,
      desde: firstDate,
      hasta: lastDate,
      titulo: helpText,
    ),
  );
}

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

class SelectorFecha extends StatefulWidget {
  const SelectorFecha({
    super.key,
    required this.inicial,
    required this.desde,
    required this.hasta,
    this.titulo,
  });

  final DateTime inicial;
  final DateTime desde;
  final DateTime hasta;
  final String? titulo;

  @override
  State<SelectorFecha> createState() => _SelectorFechaState();
}

class _SelectorFechaState extends State<SelectorFecha> {
  late DateTime _elegida = _dia(widget.inicial);
  // Al saltar con un atajo se recrea el calendario en la nueva fecha.
  int _version = 0;

  void _saltar(DateTime fecha) {
    HapticFeedback.selectionClick();
    setState(() {
      _elegida = fecha;
      _version++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final local = MaterialLocalizations.of(context);
    final hoy = _dia(DateTime.now());
    final desde = _dia(widget.desde);
    final hasta = _dia(widget.hasta);
    final atajos = <(String, DateTime)>[
      (t.dateToday, hoy),
      (t.dateTomorrow, hoy.add(const Duration(days: 1))),
      (t.dateInWeek, hoy.add(const Duration(days: 7))),
      (t.dateInMonth, DateTime(hoy.year, hoy.month + 1, hoy.day)),
    ].where((a) => !a.$2.isBefore(desde) && !a.$2.isAfter(hasta)).toList();

    return SafeArea(
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.titulo ?? t.dateTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  local.formatMediumDate(_elegida),
                  key: const ValueKey('fecha-elegida'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: context.marca,
                  ),
                ),
                const SizedBox(height: 4),
                if (atajos.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  // Grilla de dos columnas: ningún atajo queda cortado.
                  for (var f = 0; f < atajos.length; f += 2) ...[
                    if (f > 0) const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var c = f; c < f + 2; c++) ...[
                          if (c > f) const SizedBox(width: 8),
                          Expanded(
                            child: c < atajos.length
                                ? ActionChip(
                                    label: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        atajos[c].$1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    onPressed: () => _saltar(atajos[c].$2),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
                CalendarDatePicker(
                  key: ValueKey(_version),
                  initialDate: _elegida,
                  firstDate: desde,
                  lastDate: hasta,
                  onDateChanged: (d) => setState(() => _elegida = _dia(d)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('fecha-listo'),
                        onPressed: () => Navigator.pop(context, _elegida),
                        child: Text(t.timeDone),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
