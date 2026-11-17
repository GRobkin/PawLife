import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Huella en coordenadas centradas (la mitad ancha ≈ 300, la alta ≈ 290).
Path _huellaPath() {
  Path ovalo(double cx, double cy, double rx, double ry, double grados) {
    final p = Path()
      ..addOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      );
    final m = Matrix4.identity()
      ..translateByDouble(cx, cy, 0, 1)
      ..rotateZ(grados * math.pi / 180);
    return p.transform(m.storage);
  }

  var huella = ovalo(-232, -24, 58, 82, -30);
  for (final dedo in [
    ovalo(-98, -158, 62, 90, -11),
    ovalo(98, -158, 62, 90, 11),
    ovalo(232, -24, 58, 82, 30),
    // Almohadilla: triángulo redondeado, más angosto arriba.
    Path()
      ..moveTo(0, -34)
      ..cubicTo(60, -34, 110, 42, 178, 104)
      ..cubicTo(232, 154, 214, 258, 118, 258)
      ..cubicTo(70, 258, 40, 240, 0, 240)
      ..cubicTo(-40, 240, -70, 258, -118, 258)
      ..cubicTo(-214, 258, -232, 154, -178, 104)
      ..cubicTo(-110, 42, -60, -34, 0, -34)
      ..close(),
  ]) {
    huella = Path.combine(PathOperation.union, huella, dedo);
  }
  return huella;
}

/// Corazón de [ancho] px, centrado en el origen.
Path _corazon(double ancho) {
  final s = ancho / 100;
  final p = Path()
    ..moveTo(0, 38 * s)
    ..cubicTo(-62 * s, -4 * s, -44 * s, -46 * s, -20 * s, -46 * s)
    ..cubicTo(-8 * s, -46 * s, 0, -36 * s, 0, -28 * s)
    ..cubicTo(0, -36 * s, 8 * s, -46 * s, 20 * s, -46 * s)
    ..cubicTo(44 * s, -46 * s, 62 * s, -4 * s, 0, 38 * s)
    ..close();
  return p;
}

enum ModoHuella { color, monocromo }

class _Huella extends CustomPainter {
  const _Huella(this.escalaRelativa, this.modo);
  final double escalaRelativa;
  final ModoHuella modo;

  @override
  void paint(Canvas canvas, Size size) {
    // Las coordenadas están pensadas para un lienzo de 1024.
    final escala = escalaRelativa * size.width / 1024;
    canvas.translate(size.width / 2, size.height / 2 + 6 * escala);
    canvas.scale(escala);
    final huella = _huellaPath();
    final caja = huella.getBounds();
    final corazon = _corazon(120).shift(const Offset(0, 140));

    if (modo == ModoHuella.monocromo) {
      canvas.drawPath(
        Path.combine(PathOperation.difference, huella, corazon),
        Paint()..color = Colors.white,
      );
      return;
    }

    // Sombra de contacto, para que flote sobre el verde.
    canvas.drawShadow(
      huella.shift(const Offset(0, 18)),
      const Color(0xFF04140D),
      26,
      true,
    );
    canvas.drawPath(
      huella.shift(const Offset(0, 14)),
      Paint()
        ..color = const Color(0xFF04140D).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // Cuerpo: menta con degradé.
    canvas.drawPath(
      huella,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBDF5DA), AppColors.verdeAcento, Color(0xFF38A06F)],
          stops: [0, 0.5, 1],
        ).createShader(caja),
    );

    canvas.save();
    canvas.clipPath(huella);
    // Reflejo de vidrio: velo claro arriba, que se apaga hacia el centro.
    canvas.drawRect(
      caja,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.white.withValues(alpha: 0.42),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(caja),
    );
    // Sombra interior abajo a la derecha: da volumen.
    canvas.drawRect(
      caja,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.7, 0.9),
          radius: 0.9,
          colors: [
            const Color(0xFF0F5A3A).withValues(alpha: 0.35),
            const Color(0xFF0F5A3A).withValues(alpha: 0),
          ],
        ).createShader(caja),
    );
    canvas.restore();

    // Borde de luz.
    canvas.drawPath(
      huella,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.75),
            Colors.white.withValues(alpha: 0.05),
          ],
        ).createShader(caja),
    );

    // Corazón hundido en la almohadilla.
    canvas.drawPath(
      corazon.shift(const Offset(0, 5)),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawPath(
      corazon,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E6B4B), AppColors.verdeOscuro],
        ).createShader(corazon.getBounds()),
    );
  }

  @override
  bool shouldRepaint(_Huella old) =>
      old.escalaRelativa != escalaRelativa || old.modo != modo;
}

/// El logo de PawLife: huella dibujada a mano con un corazón en la almohadilla.
/// Es la misma del icono de la app (ver tool/gerar_icones_test.dart); se dibuja
/// en código para que aparezca en el primer cuadro, sin esperar una imagen.
class HuellaPawLife extends StatelessWidget {
  const HuellaPawLife({
    super.key,
    required this.lado,
    this.escala = 1,
    this.modo = ModoHuella.color,
  });

  /// Lado del lienzo cuadrado, en píxeles lógicos.
  final double lado;

  /// 1 = la del icono (ocupa unos dos tercios del lienzo).
  final double escala;
  final ModoHuella modo;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size(lado, lado), painter: _Huella(escala, modo)),
  );
}
