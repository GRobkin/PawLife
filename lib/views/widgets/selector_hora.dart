import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_palette.dart';

/// Selector de hora de PawLife: dos ruedas grandes (hora y minutos) con la
/// selección en una pastilla de marca y atajos para los momentos del día.
/// Reemplaza al reloj de agujas del sistema.
Future<TimeOfDay?> elegirHora(BuildContext context, TimeOfDay inicial) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 480),
    backgroundColor: context.superficie,
    builder: (_) => SelectorHora(inicial: inicial),
  );
}

class SelectorHora extends StatefulWidget {
  const SelectorHora({super.key, required this.inicial});

  final TimeOfDay inicial;

  @override
  State<SelectorHora> createState() => _SelectorHoraState();
}

class _SelectorHoraState extends State<SelectorHora> {
  static const _alto = 56.0;
  late final FixedExtentScrollController _horas;
  late final FixedExtentScrollController _minutos;
  late int _hora = widget.inicial.hour;
  late int _minuto = widget.inicial.minute;

  @override
  void initState() {
    super.initState();
    // Las ruedas son circulares: se arranca en una vuelta intermedia.
    _horas = FixedExtentScrollController(initialItem: 24 * 50 + _hora);
    _minutos = FixedExtentScrollController(initialItem: 60 * 50 + _minuto);
  }

  @override
  void dispose() {
    _horas.dispose();
    _minutos.dispose();
    super.dispose();
  }

  /// Lleva la rueda al valor [meta] por el camino más corto.
  void _ir(FixedExtentScrollController c, int meta, int vuelta) {
    var delta = (meta - c.selectedItem % vuelta) % vuelta;
    if (delta > vuelta ~/ 2) delta -= vuelta;
    c.animateToItem(
      c.selectedItem + delta,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _atajo(int hora) {
    HapticFeedback.selectionClick();
    _ir(_horas, hora, 24);
    _ir(_minutos, 0, 60);
  }

  Widget _rueda({
    required FixedExtentScrollController controller,
    required int vuelta,
    required String etiqueta,
    required int valor,
    required ValueChanged<int> alCambiar,
  }) {
    return Expanded(
      child: Semantics(
        label: etiqueta,
        value: valor.toString().padLeft(2, '0'),
        increasedValue: ((valor + 1) % vuelta).toString().padLeft(2, '0'),
        decreasedValue: ((valor - 1) % vuelta).toString().padLeft(2, '0'),
        onIncrease: () => controller.animateToItem(
          controller.selectedItem + 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ),
        onDecrease: () => controller.animateToItem(
          controller.selectedItem - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ),
        child: ExcludeSemantics(
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: _alto,
            diameterRatio: 1.7,
            perspective: 0.004,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) {
              HapticFeedback.selectionClick();
              alCambiar(i % vuelta);
            },
            childDelegate: ListWheelChildLoopingListDelegate(
              children: [
                for (var i = 0; i < vuelta; i++)
                  Center(
                    child: Text(
                      i.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: i == valor ? context.marca : context.textoTenue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final atajos = [
      (t.timeMorning, 8),
      (t.timeNoon, 12),
      (t.timeAfternoon, 18),
      (t.timeNight, 21),
    ];
    Widget atajo((String, int) a) => Expanded(
      child: ActionChip(
        label: SizedBox(
          width: double.infinity,
          child: Text(
            '${a.$1} · ${a.$2.toString().padLeft(2, '0')}:00',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onPressed: () => _atajo(a.$2),
      ),
    );
    return SafeArea(
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.timeTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                // Ruedas juntas y centradas, no repartidas por todo el ancho.
                SizedBox(
                  width: 232,
                  height: _alto * 3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        key: const ValueKey('hora-seleccion'),
                        height: _alto,
                        decoration: BoxDecoration(
                          color: context.mentaSuave,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      Row(
                        children: [
                          _rueda(
                            controller: _horas,
                            vuelta: 24,
                            etiqueta: t.timeHours,
                            valor: _hora,
                            alCambiar: (v) => setState(() => _hora = v),
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: context.marca,
                            ),
                          ),
                          _rueda(
                            controller: _minutos,
                            vuelta: 60,
                            etiqueta: t.timeMinutes,
                            valor: _minuto,
                            alCambiar: (v) => setState(() => _minuto = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    atajo(atajos[0]),
                    const SizedBox(width: 10),
                    atajo(atajos[1]),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    atajo(atajos[2]),
                    const SizedBox(width: 10),
                    atajo(atajos[3]),
                  ],
                ),
                const SizedBox(height: 22),
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
                        key: const ValueKey('hora-listo'),
                        onPressed: () => Navigator.pop(
                          context,
                          TimeOfDay(hour: _hora, minute: _minuto),
                        ),
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
