import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_palette.dart';
import 'motion.dart';

/// Botón que se confirma manteniéndolo pulsado: una barra se llena y, al
/// completarse, ejecuta [onCompletar]. Un toque corto solo muestra [pista].
/// Con lector de pantalla basta tocarlo dos veces (no exige mantener).
class BotonMantener extends StatefulWidget {
  const BotonMantener({
    super.key,
    required this.icono,
    required this.texto,
    required this.pista,
    required this.onCompletar,
    this.duracion = const Duration(milliseconds: 1100),
  });

  final IconData icono;
  final String texto;
  final String pista;
  final VoidCallback onCompletar;
  final Duration duracion;

  @override
  State<BotonMantener> createState() => _BotonMantenerState();
}

class _BotonMantenerState extends State<BotonMantener>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progreso = AnimationController(
    vsync: this,
    duration: widget.duracion,
  )..addStatusListener(_alCambiar);
  bool _mostrandoPista = false;
  bool _completado = false;

  void _alCambiar(AnimationStatus estado) {
    if (estado == AnimationStatus.completed) {
      _completado = true;
      HapticFeedback.mediumImpact();
      widget.onCompletar();
      _progreso.value = 0;
    }
  }

  @override
  void dispose() {
    _progreso.dispose();
    super.dispose();
  }

  void _soltar() {
    if (_completado) {
      _completado = false;
      return;
    }
    final fueToque = _progreso.value < 0.15;
    _progreso.animateBack(
      0,
      duration: reducirMovimiento(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
    );
    if (fueToque) {
      setState(() => _mostrandoPista = true);
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _mostrandoPista = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.texto,
      onTap: widget.onCompletar,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          setState(() => _mostrandoPista = false);
          _progreso.forward();
        },
        onTapUp: (_) => _soltar(),
        onTapCancel: _soltar,
        child: AnimatedBuilder(
          animation: _progreso,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                height: 54,
                color: context.botonFondo,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _progreso.value,
                          child: Container(
                            color: context.botonTexto.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icono, size: 20, color: context.botonTexto),
                        const SizedBox(width: 8),
                        Flexible(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              _mostrandoPista ? widget.pista : widget.texto,
                              key: ValueKey(_mostrandoPista),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontSize: _mostrandoPista ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: context.botonTexto,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
