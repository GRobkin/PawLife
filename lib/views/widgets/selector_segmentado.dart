// views/widgets/selector_segmentado.dart
//
// Control segmentado: una pista redondeada con todas las opciones del mismo
// ancho y una pastilla que se desliza hasta la elegida. Reemplaza a los chips
// sueltos de idioma y apariencia.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_palette.dart';
import 'motion.dart';

class OpcionSegmento<T> {
  const OpcionSegmento(this.valor, this.texto, {this.icono});

  final T valor;
  final String texto;
  final IconData? icono;
}

class SelectorSegmentado<T> extends StatelessWidget {
  const SelectorSegmentado({
    super.key,
    required this.opciones,
    required this.valor,
    required this.onCambio,
  });

  final List<OpcionSegmento<T>> opciones;
  final T valor;
  final ValueChanged<T> onCambio;

  @override
  Widget build(BuildContext context) {
    final indice = opciones.indexWhere((o) => o.valor == valor);
    final n = opciones.length;
    final colorElegido = context.esOscuro ? context.botonTexto : context.marca;
    final duracion = reducirMovimiento(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.relleno,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Pastilla de la opción elegida: se desliza, no salta.
          if (indice >= 0)
            AnimatedAlign(
              duration: duracion,
              curve: Curves.easeOutCubic,
              alignment: Alignment(n == 1 ? 0 : -1 + 2 * indice / (n - 1), 0),
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.esOscuro
                        ? context.botonFondo
                        : context.superficie,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            children: [
              for (final opcion in opciones)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: opcion.valor == valor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: opcion.valor == valor
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              onCambio(opcion.valor);
                            },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedDefaultTextStyle(
                              duration: duracion,
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontSize: 14,
                                fontWeight: opcion.valor == valor
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: opcion.valor == valor
                                    ? colorElegido
                                    : context.textoSuave,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (opcion.icono != null) ...[
                                    Icon(
                                      opcion.icono,
                                      size: 16,
                                      color: opcion.valor == valor
                                          ? colorElegido
                                          : context.textoSuave,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(opcion.texto),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
