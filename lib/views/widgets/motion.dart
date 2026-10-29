// views/widgets/motion.dart
//
// Movimiento con propósito: entradas escalonadas, esqueletos de carga y
// cifras que cuentan hacia arriba. Todo respeta "reducir movimiento" del
// sistema: con esa opción activada no hay animación, solo el estado final.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// Bloque de carga con un brillo que lo recorre de izquierda a derecha, como
/// luz que pasa. Solo cambia un degradado (sin capas ni desenfoque), aislado
/// para no redibujar el resto de la pantalla.
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
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducirMovimiento(context)) {
      _controlador.stop();
    } else if (!_controlador.isAnimating) {
      _controlador.repeat();
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
    final brillo = Color.lerp(base, context.mentaSuave, 0.55)!;
    final quieto = reducirMovimiento(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controlador,
        builder: (context, _) {
          // El brillo entra desde fuera por la izquierda y sale por la derecha.
          final x = quieto
              ? 0.0
              : Curves.easeInOutSine.transform(_controlador.value) * 3 - 1.5;
          return Container(
            height: widget.alto,
            width: widget.ancho,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radio),
              color: base,
              gradient: quieto
                  ? null
                  : LinearGradient(
                      begin: Alignment(x - 1, -0.3),
                      end: Alignment(x + 1, 0.3),
                      colors: [base, brillo, base],
                      stops: const [0.25, 0.5, 0.75],
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Cambia de la carga al contenido con un fundido corto, sin salto brusco.
class TransicionCarga extends StatelessWidget {
  const TransicionCarga({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) return child;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      layoutBuilder: (actual, previos) => Stack(
        alignment: Alignment.topCenter,
        children: [...previos, ?actual],
      ),
      child: child,
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

/// Se hunde un poco al tocarlo y vuelve al soltar: confirma que la app
/// escuchó el toque. Solo escala (no reconstruye el hijo ni repinta el resto).
class Presionable extends StatefulWidget {
  const Presionable({super.key, required this.child});

  final Widget child;

  @override
  State<Presionable> createState() => _PresionableState();
}

class _PresionableState extends State<Presionable> {
  bool _abajo = false;

  void _poner(bool v) {
    if (_abajo != v) setState(() => _abajo = v);
  }

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) return widget.child;
    return Listener(
      onPointerDown: (_) => _poner(true),
      onPointerUp: (_) => _poner(false),
      onPointerCancel: (_) => _poner(false),
      child: AnimatedScale(
        scale: _abajo ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Anillo que late alrededor de [child] unas pocas veces y se detiene: llama
/// la atención al llegar sin consumir batería mientras la pantalla está quieta.
class PulsoSuave extends StatefulWidget {
  const PulsoSuave({
    super.key,
    required this.child,
    required this.color,
    this.veces = 3,
  });

  final Widget child;
  final Color color;
  final int veces;

  @override
  State<PulsoSuave> createState() => _PulsoSuaveState();
}

class _PulsoSuaveState extends State<PulsoSuave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducirMovimiento(context)) {
      _c.stop();
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.repeat(count: widget.veces);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) return widget.child;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, hijo) {
          // Solo la primera parte del ciclo dibuja el anillo; el resto descansa.
          final k = (_c.value / 0.7).clamp(0.0, 1.0);
          final visible = _c.isAnimating && k < 1;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (visible)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Transform.scale(
                      scale: 1 + Curves.easeOutCubic.transform(k) * 0.55,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.color.withValues(
                              alpha: 0.8 * (1 - k),
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              hijo!,
            ],
          );
        },
      ),
    );
  }
}

/// Texto que, al cambiar, sale hacia arriba y entra el nuevo desde abajo,
/// como un marcador. Pensado para contadores cortos ("1/2").
class TextoGiratorio extends StatelessWidget {
  const TextoGiratorio(this.texto, {super.key, this.estilo});

  final String texto;
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    final hijo = Text(texto, key: ValueKey(texto), style: estilo);
    if (reducirMovimiento(context)) return hijo;
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          final entra = child.key == ValueKey(texto);
          final desde = entra ? const Offset(0, 1) : const Offset(0, -1);
          return SlideTransition(
            position: Tween(begin: desde, end: Offset.zero).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        child: hijo,
      ),
    );
  }
}

/// Escala un instante hacia arriba y vuelve cuando [activo] pasa a true:
/// recompensa al completar algo. No hace nada al desmarcar.
class ReboteAlActivar extends StatefulWidget {
  const ReboteAlActivar({super.key, required this.activo, required this.child});

  final bool activo;
  final Widget child;

  @override
  State<ReboteAlActivar> createState() => _ReboteAlActivarState();
}

class _ReboteAlActivarState extends State<ReboteAlActivar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _escala = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.22,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.22,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 60,
    ),
  ]).animate(_c);

  @override
  void didUpdateWidget(ReboteAlActivar old) {
    super.didUpdateWidget(old);
    if (widget.activo && !old.activo && !reducirMovimiento(context)) {
      HapticFeedback.lightImpact();
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _escala, child: widget.child);
}
