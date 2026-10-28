// views/widgets/motion.dart
//
// Movimiento con propósito: entradas escalonadas, esqueletos de carga y
// cifras que cuentan hacia arriba. Todo respeta "reducir movimiento" del
// sistema: con esa opción activada no hay animación, solo el estado final.

import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

bool reducirMovimiento(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Aparece con un fundido y un leve desplazamiento hacia arriba. [indice]
/// escalona la entrada de elementos de una lista.
class AparecerAlEntrar extends StatelessWidget {
  const AparecerAlEntrar({super.key, required this.child, this.indice = 0});

  final Widget child;
  final int indice;

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) return child;

    final retraso = (indice.clamp(0, 6)) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + retraso),
      curve: Curves.easeOutCubic,
      builder: (context, valor, hijo) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, (1 - valor) * 14),
          child: hijo,
        ),
      ),
      child: child,
    );
  }
}

/// Bloque gris que pulsa suavemente mientras carga el contenido real.
class Esqueleto extends StatefulWidget {
  const Esqueleto({super.key, this.alto = 16, this.ancho, this.radio = 10});

  final double alto;
  final double? ancho;
  final double radio;

  @override
  State<Esqueleto> createState() => _EsqueletoState();
}

class _EsqueletoState extends State<Esqueleto>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducirMovimiento(context)) {
      _controlador.stop();
    } else if (!_controlador.isAnimating) {
      _controlador.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.relleno;
    final claro = context.superficieAlta;
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) => Container(
        height: widget.alto,
        width: widget.ancho,
        decoration: BoxDecoration(
          color: Color.lerp(base, claro, _controlador.value),
          borderRadius: BorderRadius.circular(widget.radio),
        ),
      ),
    );
  }
}

/// Número que cuenta desde cero hasta [valor] al aparecer.
class CifraAnimada extends StatelessWidget {
  const CifraAnimada({
    super.key,
    required this.valor,
    required this.formato,
    this.estilo,
  });

  final double valor;
  final String Function(double) formato;
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) {
      return Text(formato(valor), style: estilo);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: valor),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(formato(v), style: estilo),
    );
  }
}
