import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../walk_share_screen.dart' show TarjetaEstilo;

/// Ilustración propia de cada carta de paseo: la escena representa el nombre.
///  - Bosque: bosque de noche, luna, luciérnagas y pinos en capas.
///  - Menta: ramitas de menta con hojas ovaladas y caramelos de menta.
///  - Cifras: números gigantes, regla de distancia y rueda de cuentakilómetros.
///  - Candy: glaseado rosa, grageas, chupetines y caramelos envueltos.
class SelvaPainter extends CustomPainter {
  const SelvaPainter(this.estilo, {this.cifra = ''});

  final TarjetaEstilo estilo;

  /// Texto de la distancia (p. ej. "1.25") que Cifras dibuja gigante al fondo.
  final String cifra;

  /// Alto al pie que el contenido de la tarjeta reserva para la ilustración.
  static double franjaDe(TarjetaEstilo e) => switch (e) {
    TarjetaEstilo.bosque => 100,
    TarjetaEstilo.menta => 70,
    TarjetaEstilo.cifras => 64,
    TarjetaEstilo.candy => 84,
  };

  static const cifrasFondo = Color(0xFF111B2E);
  static const cifrasAcento = Color(0xFFFFC857);
  static const _rosa = Color(0xFFE8508A);
  static const _rosaClaro = Color(0xFFFFB3D1);
  static const _mentaCandy = Color(0xFF8FE3C8);
  static const _amarillo = Color(0xFFFFD86B);
  static const _lila = Color(0xFFC2AEFF);

  @override
  void paint(Canvas canvas, Size size) {
    switch (estilo) {
      case TarjetaEstilo.bosque:
        _noche(canvas, size);
      case TarjetaEstilo.menta:
        _menta(canvas, size);
      case TarjetaEstilo.cifras:
        _cifras(canvas, size);
      case TarjetaEstilo.candy:
        _candy(canvas, size);
    }
  }

  Color _oscuro(double a) =>
      Color.lerp(AppColors.verdeOscuro, AppColors.verdeAcento, a)!;

  // ---------------------------------------------------------------- Bosque
  void _noche(Canvas canvas, Size size) {
    final base = size.height;
    final luna = Offset(size.width - 56, 64);
    canvas.drawCircle(
      luna,
      46,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.verdeAcento.withValues(alpha: .28),
            AppColors.verdeAcento.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: luna, radius: 46)),
    );
    canvas.drawCircle(
      luna,
      17,
      Paint()..color = AppColors.verdeSuave.withValues(alpha: .9),
    );
    canvas.drawCircle(
      luna + const Offset(6, -4),
      15,
      Paint()..color = _oscuro(.05),
    );
    final rnd = math.Random(21);
    for (var i = 0; i < 16; i++) {
      final p = Offset(
        rnd.nextDouble() * size.width,
        size.height * (.25 + rnd.nextDouble() * .6),
      );
      canvas.drawCircle(
        p,
        1 + rnd.nextDouble() * 1.6,
        Paint()
          ..color = AppColors.verdeAcento.withValues(
            alpha: .25 + rnd.nextDouble() * .4,
          ),
      );
    }
    final niebla = Rect.fromLTWH(0, base - 120, size.width, 120);
    canvas.drawRect(
      niebla,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _oscuro(0).withValues(alpha: 0),
            _oscuro(.22).withValues(alpha: .55),
          ],
        ).createShader(niebla),
    );
    _arboles(canvas, size, _oscuro(.2), 12, 3, base - 12, 46, 72, pino: true);
    _arboles(canvas, size, _oscuro(.1), 8, 5, base - 4, 56, 86, pino: true);
    final cerca = Color.lerp(AppColors.verdeOscuro, Colors.black, .45)!;
    _arboles(canvas, size, cerca, 6, 9, base, 38, 62, pino: false);
    canvas.drawRect(
      Rect.fromLTWH(0, base - 10, size.width, 10),
      Paint()..color = cerca,
    );
  }

  void _arboles(
    Canvas canvas,
    Size size,
    Color color,
    int cantidad,
    int semilla,
    double suelo,
    double hMin,
    double hMax, {
    required bool pino,
  }) {
    final rnd = math.Random(semilla);
    final paso = size.width / cantidad;
    final p = Paint()..color = color;
    for (var i = 0; i < cantidad; i++) {
      final x = paso * (i + .5) + (rnd.nextDouble() - .5) * paso * .5;
      final h = hMin + rnd.nextDouble() * (hMax - hMin);
      if (pino) {
        for (var k = 0; k < 3; k++) {
          final top = suelo - h + k * h * .24;
          final ancho = h * (.22 + k * .09);
          canvas.drawPath(
            Path()
              ..moveTo(x, top)
              ..lineTo(x - ancho, top + h * .42)
              ..lineTo(x + ancho, top + h * .42)
              ..close(),
            p,
          );
        }
        canvas.drawRect(Rect.fromLTWH(x - 2, suelo - h * .2, 4, h * .2), p);
      } else {
        canvas.drawRect(Rect.fromLTWH(x - 2.5, suelo - h * .5, 5, h * .5), p);
        canvas.drawCircle(Offset(x, suelo - h * .66), h * .27, p);
        canvas.drawCircle(Offset(x - h * .2, suelo - h * .5), h * .21, p);
        canvas.drawCircle(Offset(x + h * .2, suelo - h * .5), h * .21, p);
      }
    }
  }

  // ----------------------------------------------------------------- Menta
  void _menta(Canvas canvas, Size size) {
    const hojaMenta = Color(0xFF2DBE8E);
    const tallo = Color(0xFF1E8F6A);
    // Ramitas de menta: tallo curvo con pares de hojas ovaladas.
    _ramita(canvas, Offset(-6, size.height * .58), -.5, 118, hojaMenta, tallo);
    _ramita(
      canvas,
      Offset(size.width + 6, 70),
      math.pi + .4,
      130,
      hojaMenta,
      tallo,
    );
    _ramita(
      canvas,
      Offset(size.width * .18, size.height + 4),
      -math.pi / 2 - .15,
      78,
      hojaMenta,
      tallo,
    );
    _ramita(
      canvas,
      Offset(size.width * .55, size.height + 4),
      -math.pi / 2 + .12,
      64,
      hojaMenta,
      tallo,
    );
    _ramita(
      canvas,
      Offset(size.width * .86, size.height + 4),
      -math.pi / 2 + .3,
      72,
      hojaMenta,
      tallo,
    );
    // Caramelos de menta con rayas.
    _caramelo(canvas, Offset(size.width - 38, 44), 17);
    _caramelo(canvas, Offset(30, size.height - 36), 13);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 6, size.width, 6),
      Paint()..color = tallo.withValues(alpha: .45),
    );
  }

  void _ramita(
    Canvas canvas,
    Offset origen,
    double angulo,
    double largo,
    Color hoja,
    Color tallo,
  ) {
    canvas.save();
    canvas.translate(origen.dx, origen.dy);
    canvas.rotate(angulo);
    canvas.drawPath(
      Path()..quadraticBezierTo(largo * .5, -largo * .08, largo, 0),
      Paint()
        ..color = tallo.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    for (var k = 1; k <= 5; k++) {
      final t = k / 5.4;
      final x = largo * t;
      final y = -largo * .08 * 2 * t * (1 - t);
      final tam = largo * (.3 - t * .15);
      for (final lado in [-1.0, 1.0]) {
        _hoja(
          canvas,
          Offset(x, y),
          lado * .95,
          tam,
          hoja.withValues(alpha: .4),
          ancho: .5,
          nervio: tallo.withValues(alpha: .5),
        );
      }
    }
    _hoja(
      canvas,
      Offset(largo, 0),
      0,
      largo * .2,
      hoja.withValues(alpha: .45),
      ancho: .5,
    );
    canvas.restore();
  }

  void _caramelo(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    const gajos = 8;
    for (var i = 0; i < gajos; i += 2) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..arcTo(
            Rect.fromCircle(center: c, radius: r),
            i * 2 * math.pi / gajos,
            2 * math.pi / gajos,
            false,
          )
          ..close(),
        Paint()..color = const Color(0xFF2DBE8E).withValues(alpha: .75),
      );
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFF1E8F6A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  // ---------------------------------------------------------------- Cifras
  void _cifras(Canvas canvas, Size size) {
    const acento = cifrasAcento;
    final base = size.height;
    // Distancia gigante, apenas visible, detrás de todo.
    if (cifra.isNotEmpty) {
      final gigante = TextPainter(
        text: TextSpan(
          text: cifra,
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 190,
            fontWeight: FontWeight.w900,
            height: 1,
            color: acento.withValues(alpha: .07),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      gigante.paint(
        canvas,
        Offset(size.width - gigante.width + 24, size.height * .38),
      );
    }
    // Rueda de cuentakilómetros en el borde derecho.
    for (var i = 0; i < 10; i++) {
      final t = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: acento.withValues(alpha: i == 4 ? .75 : .22),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      t.paint(canvas, Offset(size.width - 18, 70 + i * 24.0));
    }
    // Regla de distancia al pie.
    final linea = Paint()
      ..color = acento.withValues(alpha: .55)
      ..strokeWidth = 1.5;
    final y = base - 22;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linea);
    for (var i = 0; i <= 40; i++) {
      final x = i * size.width / 40;
      final largo = i % 10 == 0 ? 16.0 : (i % 5 == 0 ? 11.0 : 6.0);
      canvas.drawLine(Offset(x, y), Offset(x, y - largo), linea);
      if (i % 10 == 0 && i < 40) {
        final t = TextPainter(
          text: TextSpan(
            text: '${i ~/ 10}',
            style: TextStyle(
              fontFamily: 'NunitoSans',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: acento.withValues(alpha: .8),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        t.paint(canvas, Offset(x + 4, y + 3));
      }
    }
  }

  // ----------------------------------------------------------------- Candy
  void _candy(Canvas canvas, Size size) {
    final base = size.height;
    final rnd = math.Random(5);
    // Glaseado que gotea desde arriba.
    final glaseado = Paint()..color = _rosaClaro;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 14), glaseado);
    var x = 4.0;
    while (x < size.width) {
      final w = 20 + rnd.nextDouble() * 12;
      final largo = 18 + rnd.nextDouble() * 34;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, w, largo),
          Radius.circular(w / 2),
        ),
        glaseado,
      );
      x += w + 6 + rnd.nextDouble() * 20;
    }
    // Grageas sobre el glaseado y al pie.
    final colores = [_rosa, _mentaCandy, _amarillo, _lila, Colors.white];
    void grajea(double x, double y) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rnd.nextDouble() * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-6, -2, 12, 4),
          const Radius.circular(2),
        ),
        Paint()..color = colores[rnd.nextInt(colores.length)],
      );
      canvas.restore();
    }

    for (var i = 0; i < 20; i++) {
      grajea(rnd.nextDouble() * size.width, 6 + rnd.nextDouble() * 22);
    }
    for (var i = 0; i < 16; i++) {
      grajea(rnd.nextDouble() * size.width, base - 80 + rnd.nextDouble() * 36);
    }
    // Chupetines y caramelo envuelto.
    _chupete(canvas, Offset(size.width * .16, base - 40), 22);
    _chupete(canvas, Offset(size.width * .8, base - 46), 18);
    _envuelto(canvas, Offset(size.width * .5, base - 30));
    // Borde festoneado al pie.
    final feston = Paint()..color = _rosa;
    for (var cx = 0.0; cx < size.width + 20; cx += 26) {
      canvas.drawCircle(Offset(cx, base + 2), 14, feston);
    }
  }

  void _chupete(Canvas canvas, Offset c, double r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - 2, c.dy, 4, r * 2.4),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(c, r, Paint()..color = _rosa);
    final espiral = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (var a = 0.0; a < 4 * math.pi; a += .2) {
      final rr = r * .9 * a / (4 * math.pi);
      final p = Offset(c.dx + rr * math.cos(a), c.dy + rr * math.sin(a));
      a == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, espiral);
  }

  void _envuelto(Canvas canvas, Offset c) {
    final papel = Paint()..color = _amarillo;
    for (final lado in [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + lado * 12, c.dy)
          ..lineTo(c.dx + lado * 28, c.dy - 11)
          ..lineTo(c.dx + lado * 28, c.dy + 11)
          ..close(),
        papel,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 34, height: 24),
      Paint()..color = _mentaCandy,
    );
    canvas.drawLine(
      c + const Offset(-6, -9),
      c + const Offset(-1, 9),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  // --------------------------------------------------------------- Común
  /// Hoja con punta, apoyada en [origen] y girada [angulo]. [ancho] es la
  /// proporción del ancho respecto del largo.
  void _hoja(
    Canvas canvas,
    Offset origen,
    double angulo,
    double largo,
    Color color, {
    double ancho = .24,
    Color? nervio,
  }) {
    canvas.save();
    canvas.translate(origen.dx, origen.dy);
    canvas.rotate(angulo);
    final w = largo * ancho;
    canvas.drawPath(
      Path()
        ..quadraticBezierTo(largo * .5, -w * 1.6, largo, 0)
        ..quadraticBezierTo(largo * .5, w * 1.6, 0, 0),
      Paint()..color = color,
    );
    if (nervio != null) {
      canvas.drawLine(
        Offset.zero,
        Offset(largo * .92, 0),
        Paint()
          ..color = nervio
          ..strokeWidth = 1.2,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(SelvaPainter old) =>
      old.estilo != estilo || old.cifra != cifra;
}
