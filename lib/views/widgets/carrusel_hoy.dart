import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import 'motion.dart';

class TareaVista {
  const TareaVista({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.hecha,
    required this.alTocar,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final bool hecha;
  final VoidCallback alTocar;
}

/// Tareas de hoy en tarjetas horizontales: se desliza de una a otra y la
/// tarjeta enfocada se agranda suavemente.
class CarruselHoy extends StatefulWidget {
  const CarruselHoy({
    super.key,
    required this.tareas,
    required this.textoMarcar,
    required this.textoPendiente,
  });

  final List<TareaVista> tareas;
  final String textoMarcar;
  final String textoPendiente;

  @override
  State<CarruselHoy> createState() => _CarruselHoyState();
}

class _CarruselHoyState extends State<CarruselHoy> {
  final _controller = PageController(viewportFraction: 0.84);
  double _pagina = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final p = _controller.page ?? 0;
      if (p != _pagina) setState(() => _pagina = p);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quieto = reducirMovimiento(context);
    final rapido = quieto ? Duration.zero : const Duration(milliseconds: 220);
    final n = widget.tareas.length;
    return Column(
      children: [
        SizedBox(
          height: 116,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            clipBehavior: Clip.none,
            itemCount: n,
            itemBuilder: (context, i) {
              final cerca = (1 - (_pagina - i).abs()).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Transform.scale(
                  scale: quieto ? 1.0 : 0.93 + 0.07 * cerca,
                  child: Opacity(
                    opacity: quieto ? 1.0 : 0.65 + 0.35 * cerca,
                    child: _Tarjeta(
                      tarea: widget.tareas[i],
                      rapido: rapido,
                      textoMarcar: widget.textoMarcar,
                      textoPendiente: widget.textoPendiente,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (n > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < n; i++)
                AnimatedContainer(
                  duration: rapido,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: (_pagina - i).abs() < 0.5 ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: (_pagina - i).abs() < 0.5
                        ? context.marca
                        : context.textoTenue.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.tarea,
    required this.rapido,
    required this.textoMarcar,
    required this.textoPendiente,
  });

  final TareaVista tarea;
  final Duration rapido;
  final String textoMarcar;
  final String textoPendiente;

  @override
  Widget build(BuildContext context) {
    final hecha = tarea.hecha;
    return Presionable(
      child: Material(
        color: hecha ? context.relleno : context.superficie,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: tarea.alTocar,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: context.mentaSuave,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(tarea.icono, size: 19, color: context.marca),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tarea.detalle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: hecha ? context.textoTenue : context.marca,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: hecha ? textoPendiente : textoMarcar,
                      excludeSemantics: true,
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
                  ],
                ),
                const Spacer(),
                Text(
                  tarea.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: hecha ? context.textoTenue : context.texto,
                    decoration: hecha ? TextDecoration.lineThrough : null,
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
