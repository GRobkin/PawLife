import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import 'motion.dart';

/// Estado vacío con ilustración: un icono grande sobre círculos suaves y
/// huellitas alrededor. Flota despacio salvo que se pida reducir movimiento.
class EstadoVacio extends StatefulWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.accion,
    this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String? detalle;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  State<EstadoVacio> createState() => _EstadoVacioState();
}

class _EstadoVacioState extends State<EstadoVacio>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flota = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducirMovimiento(context)) {
      _flota.stop();
    } else if (!_flota.isAnimating) {
      _flota.repeat(reverse: true, count: 4);
    }
  }

  @override
  void dispose() {
    _flota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detalle = widget.detalle;
    final accion = widget.accion;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _flota,
                builder: (context, hijo) => Transform.translate(
                  offset: Offset(
                    0,
                    -6 * Curves.easeInOut.transform(_flota.value),
                  ),
                  child: hijo,
                ),
                child: SizedBox(
                  width: 170,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _circulo(context.mentaSuave.withValues(alpha: 0.55), 150),
                      _circulo(context.mentaSuave, 104),
                      Icon(widget.icono, size: 46, color: context.marca),
                      Positioned(
                        left: 6,
                        top: 18,
                        child: _huella(context, 20, -0.4),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: _huella(context, 15, 0.5),
                      ),
                      Positioned(
                        right: 14,
                        bottom: 10,
                        child: _huella(context, 22, 0.25),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (detalle != null) ...[
              const SizedBox(height: 8),
              Text(
                detalle,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textoSuave),
              ),
            ],
            if (accion != null && widget.onAccion != null) ...[
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: widget.onAccion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.botonFondo,
                  foregroundColor: context.botonTexto,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(accion),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _circulo(Color color, double tam) => Container(
    width: tam,
    height: tam,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _huella(BuildContext context, double tam, double giro) =>
      Transform.rotate(
        angle: giro,
        child: Icon(
          Icons.pets,
          size: tam,
          color: context.marca.withValues(alpha: 0.28),
        ),
      );
}
