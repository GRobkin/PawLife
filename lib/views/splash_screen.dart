import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pantalla de carga de la app mientras Firebase restaura la sesión.
///
/// Continuación de la pantalla de carga nativa: el primer cuadro es el mismo
/// (mismo verde, misma huella, en el mismo lugar). Enseguida, y con un fundido
/// suave, se suma lo demás, siempre tenue:
///  - un rastro de huellitas que camina por debajo, cada vez más visible,
///  - la marca en minúsculas,
///  - una barrita de carga fina.
/// Lo único que se mueve es la barrita. Con "reducir movimiento" ni eso: queda
/// un segmento quieto.
class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key, this.animar = true});

  /// Para capturas y pruebas: en false se queda en el primer cuadro.
  final bool animar;

  /// Fondo de la marca: el mismo de la pantalla de carga nativa.
  static const Color fondo = AppColors.verdeOscuro;

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga>
    with SingleTickerProviderStateMixin {
  static const _tamanoHuella = 155.0;
  static const _anchoBarra = 132.0;

  late final AnimationController _barra = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  Timer? _espera;
  bool _extras = false;
  bool _arrancado = false;

  /// Rastro de huellas: posición (fracción de la pantalla), giro y opacidad.
  /// Caminan hacia la derecha y se van marcando más.
  static const _rastro = <(double, double, double, double)>[
    (0.17, 0.765, 1.82, 0.05),
    (0.29, 0.725, 1.32, 0.07),
    (0.41, 0.765, 1.82, 0.10),
    (0.53, 0.725, 1.32, 0.13),
    (0.65, 0.765, 1.82, 0.17),
    (0.77, 0.725, 1.32, 0.21),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_arrancado || !widget.animar) return;
    _arrancado = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _extras = true; // Sin movimiento: se ve todo desde el principio, quieto.
      return;
    }
    // El primer instante es idéntico al splash nativo; lo demás se funde.
    _espera = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _extras = true);
      _barra.repeat();
    });
  }

  @override
  void dispose() {
    _espera?.cancel();
    _barra.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tamano = MediaQuery.sizeOf(context);
    final quieto = MediaQuery.disableAnimationsOf(context);
    final duracion = quieto ? Duration.zero : const Duration(milliseconds: 650);
    return Scaffold(
      backgroundColor: PantallaCarga.fondo,
      body: Semantics(
        label: 'PawLife',
        child: Stack(
          children: [
            // Rastro de huellas, por debajo de la huella principal.
            for (final (x, y, giro, alfa) in _rastro)
              Positioned(
                left: tamano.width * x - 14,
                top: tamano.height * y - 14,
                child: AnimatedOpacity(
                  opacity: _extras ? 1 : 0,
                  duration: duracion,
                  curve: Curves.easeOut,
                  child: Transform.rotate(
                    angle: giro,
                    child: Icon(
                      Icons.pets,
                      size: 28,
                      color: AppColors.verdeAcento.withValues(alpha: alfa),
                    ),
                  ),
                ),
              ),
            // La huella principal: igual a la del splash nativo.
            Center(
              child: ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFA6F0CB),
                    AppColors.verdeAcento,
                    Color(0xFF3FA878),
                  ],
                ).createShader(r),
                child: const Icon(
                  Icons.pets,
                  size: _tamanoHuella,
                  color: Colors.white,
                ),
              ),
            ),
            // Marca y barrita de carga, abajo.
            Positioned(
              left: 0,
              right: 0,
              bottom: tamano.height * 0.085,
              child: AnimatedOpacity(
                opacity: _extras ? 1 : 0,
                duration: duracion,
                curve: Curves.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'pawlife',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 4,
                        color: AppColors.verdeAcento.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: _anchoBarra,
                      height: 3,
                      child: CustomPaint(
                        painter: _BarraPainter(_barra, quieto),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barrita de carga: un carril casi invisible con un tramo claro que lo recorre.
/// Sin movimiento queda el tramo quieto en el centro.
class _BarraPainter extends CustomPainter {
  _BarraPainter(this.t, this.quieto) : super(repaint: t);

  final Animation<double> t;
  final bool quieto;

  @override
  void paint(Canvas canvas, Size size) {
    final carril = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(
      carril,
      Paint()..color = AppColors.verdeAcento.withValues(alpha: 0.13),
    );
    canvas.save();
    canvas.clipRRect(carril);
    final largo = size.width * 0.38;
    final avance = quieto ? 0.5 : Curves.easeInOut.transform(t.value);
    final x = -largo + (size.width + largo) * avance;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, largo, size.height),
        Radius.circular(size.height / 2),
      ),
      Paint()..color = AppColors.verdeAcento.withValues(alpha: 0.7),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BarraPainter old) => old.quieto != quieto;
}
