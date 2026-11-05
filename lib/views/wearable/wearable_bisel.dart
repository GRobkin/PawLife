import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'wearable_theme.dart';

/// Qué está haciendo el reloj; el bisel lo cuenta con movimiento.
enum BiselModo {
  /// Esperando: el aro respira despacio.
  reposo,

  /// Paseo en curso: un arco recorre el aro como segundero y las marcas de
  /// los segundos transcurridos se encienden.
  activo,

  /// Paseo en pausa: el arco se congela, atenuado.
  pausado,

  /// Paseo guardado: un pulso verde sale del cristal una vez.
  exito,
}

/// Pone el aro del reloj DENTRO del cuadro de 250×250 que lo contiene (la
/// consigna pide que todo el contenido visual quepa en esa área): un anillo
/// oscuro con marcas de minutos en el borde y el cristal circular dentro. No
/// dibuja nada fuera de su caja.
///
/// Con [animar] el aro cobra vida según [modo]. Todo el movimiento es de
/// decoración o de estado (no hay acciones del usuario esperando): usa
/// movimiento constante lineal para el segundero y curvas suaves para la
/// respiración y el pulso. Con "reducir movimiento" queda estático.
class BiselReloj extends StatefulWidget {
  const BiselReloj({
    super.key,
    required this.child,
    this.modo = BiselModo.reposo,
    this.animar = false,
  });

  final Widget child;
  final BiselModo modo;
  final bool animar;

  @override
  State<BiselReloj> createState() => _BiselRelojState();
}

class _BiselRelojState extends State<BiselReloj> with TickerProviderStateMixin {
  // Una vuelta por minuto: el arco funciona de segundero.
  late final _giro = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  );
  late final _respira = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  );
  late final _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _reducido = false;
  bool _iniciado = false;

  bool get _anima => widget.animar && !_reducido;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducido = MediaQuery.disableAnimationsOf(context);
    _sincronizar(null);
  }

  @override
  void didUpdateWidget(BiselReloj anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.modo != widget.modo || anterior.animar != widget.animar) {
      _sincronizar(anterior.modo);
    }
  }

  void _sincronizar(BiselModo? anterior) {
    if (!_anima) {
      _giro.stop();
      _respira.stop();
      _entrada.value = 1;
      return;
    }
    if (!_iniciado) {
      _iniciado = true;
      _entrada.forward(from: 0);
    }
    switch (widget.modo) {
      case BiselModo.reposo:
        _giro.value = 0;
        _respira.repeat(reverse: true);
      case BiselModo.activo:
        _respira.stop();
        _giro.repeat();
      case BiselModo.pausado:
        _respira.stop();
        _giro.stop();
      case BiselModo.exito:
        _giro.value = 0;
        _respira.repeat(reverse: true);
        if (anterior != BiselModo.exito) _pulso.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _giro.dispose();
    _respira.dispose();
    _entrada.dispose();
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CajaPainter(
        modo: widget.modo,
        animado: _anima,
        giro: _giro,
        respira: _respira,
        entrada: _entrada,
        pulso: _pulso,
      ),
      foregroundPainter: const _ReflejoPainter(),
      // La esfera no se repinta con el movimiento del aro y no puede pisarlo.
      child: Padding(
        padding: const EdgeInsets.all(_CajaPainter.margen),
        child: RepaintBoundary(child: ClipOval(child: widget.child)),
      ),
    );
  }
}

class _CajaPainter extends CustomPainter {
  _CajaPainter({
    required this.modo,
    required this.animado,
    required this.giro,
    required this.respira,
    required this.entrada,
    required this.pulso,
  }) : super(repaint: Listenable.merge([giro, respira, entrada, pulso]));

  final BiselModo modo;
  final bool animado;
  final Animation<double> giro;
  final Animation<double> respira;
  final Animation<double> entrada;
  final Animation<double> pulso;

  /// Ancho del aro, de afuera hacia el cristal.
  static const double margen = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final exterior = size.shortestSide / 2;
    final cristal = exterior - margen;
    final acento = WearableColors.acento;
    final conMarcha =
        animado && (modo == BiselModo.activo || modo == BiselModo.pausado);
    final vuelta = conMarcha ? giro.value : 0.0;

    // Aro oscuro: casi negro, con un brillo metálico tenue arriba a la
    // izquierda. El fondo de la pantalla sigue siendo negro.
    final aro = Rect.fromCircle(center: c, radius: exterior);
    canvas.drawCircle(
      c,
      (cristal + exterior) / 2,
      Paint()
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          transform: GradientRotation(-math.pi / 4),
          colors: [
            Color(0xFF0B0B0B),
            Color(0xFF4A4D4B),
            Color(0xFF151515),
            Color(0xFF070707),
            Color(0xFF2E302F),
            Color(0xFF0B0B0B),
          ],
          stops: [0, .12, .35, .6, .82, 1],
        ).createShader(aro)
        ..style = PaintingStyle.stroke
        ..strokeWidth = margen,
    );
    canvas.drawCircle(
      c,
      exterior - .75,
      Paint()
        ..color = Colors.white.withValues(alpha: .22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Marcas de minutos sobre el aro. Entran en cascada desde las 12 al abrir;
    // con un paseo en curso, las de los segundos ya pasados se encienden.
    final entrada01 = Curves.easeOutCubic.transform(entrada.value);
    final encendidas = conMarcha ? (vuelta * 60).floor() : -1;
    for (var i = 0; i < 60; i++) {
      final aparece = ((entrada01 * 1.5) - i / 60).clamp(0.0, 1.0);
      if (aparece == 0) continue;
      final a = i * math.pi / 30 - math.pi / 2;
      final principal = i % 15 == 0;
      final hora = i % 5 == 0;
      final lit = i <= encendidas;
      final dentro = cristal + 2.5;
      final largo = (principal ? 9.5 : (hora ? 7.0 : 3.5)) * aparece;
      final dir = Offset(math.cos(a), math.sin(a));
      final p0 = c + dir * dentro;
      final p1 = c + dir * (dentro + largo);
      final color = hora || lit
          ? acento.withValues(alpha: (lit && !hora ? .8 : 1) * aparece)
          : Colors.white.withValues(alpha: .38 * aparece);
      canvas.drawLine(
        p0,
        p1,
        Paint()
          ..color = color
          ..strokeWidth = principal ? 2.6 : (hora ? 1.8 : (lit ? 1.4 : 1))
          ..strokeCap = StrokeCap.round,
      );
    }

    // Filo verde del cristal. En reposo respira (decoración lenta); el halo
    // vive hacia adentro, sobre el negro.
    final respiro =
        animado && (modo == BiselModo.reposo || modo == BiselModo.exito)
        ? Curves.easeInOutSine.transform(respira.value)
        : .4;
    canvas.drawCircle(
      c,
      cristal - .5,
      Paint()
        ..color = acento.withValues(
          alpha: .22 + .3 * respiro + (modo == BiselModo.exito ? .15 : 0),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );
    canvas.drawCircle(
      c,
      cristal + .75,
      Paint()
        ..color = acento.withValues(alpha: .85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Segundero: un arco con cola que recorre el filo del cristal.
    if (conMarcha) {
      final cabeza = vuelta * 2 * math.pi - math.pi / 2;
      final intensidad = modo == BiselModo.activo ? 1.0 : .45;
      const tramos = 56;
      const paso = 0.03;
      for (var k = 0; k < tramos; k++) {
        final t = 1 - k / tramos;
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: cristal + .75),
          cabeza - (k + 1) * paso,
          paso * 1.15,
          false,
          Paint()
            ..color = acento.withValues(
              alpha: math.pow(t, 1.4).toDouble() * intensidad,
            )
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 + 4.5 * t
            ..strokeCap = StrokeCap.round,
        );
      }
      final punta =
          c + Offset(math.cos(cabeza), math.sin(cabeza)) * (cristal + .75);
      canvas.drawCircle(
        punta,
        8,
        Paint()
          ..color = acento.withValues(alpha: .9 * intensidad)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        punta,
        3.6,
        Paint()..color = Colors.white.withValues(alpha: intensidad),
      );
    }

    // Pulso de éxito: un anillo que sale del cristal hacia el borde y se
    // desvanece, sin pasarse del cuadro.
    if (animado && pulso.isAnimating) {
      final p = Curves.easeOutCubic.transform(pulso.value);
      canvas.drawCircle(
        c,
        cristal + (exterior - 1 - cristal) * p,
        Paint()
          ..color = acento.withValues(alpha: (1 - p) * .7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(_CajaPainter old) =>
      old.modo != modo || old.animado != animado;
}

/// Reflejo del cristal: un brillo suave, sin bordes, arriba a la izquierda.
class _ReflejoPainter extends CustomPainter {
  const _ReflejoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - _CajaPainter.margen;
    final cristal = Rect.fromCircle(center: c, radius: r);
    canvas.save();
    canvas.clipPath(Path()..addOval(cristal));
    canvas.drawRect(
      cristal,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.55, -0.7),
          radius: 0.75,
          colors: [
            Colors.white.withValues(alpha: .10),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(cristal),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ReflejoPainter old) => false;
}
