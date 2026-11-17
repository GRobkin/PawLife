import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import 'motion.dart';

/// Banner de Home que lleva a la pantalla de Premium. Solo se muestra a quien
/// no tiene Premium.
///
/// Verde bosque con resplandores menta detrás y encima un panel de vidrio: borde
/// con brillo en la esquina, reflejo en la mitad de arriba y un destello que lo
/// cruza cada pocos segundos. Lo único amarillo es la medalla. Con movimiento
/// reducido el destello queda quieto, fuera de la tarjeta.
class BannerPremium extends StatefulWidget {
  const BannerPremium({super.key, required this.onTap});

  final VoidCallback onTap;

  /// Los tests de capturas lo apagan: una animación en bucle impide que
  /// `pumpAndSettle` termine.
  static bool animar = true;

  @override
  State<BannerPremium> createState() => _BannerPremiumState();
}

const Color _oro = Color(0xFFFFD25E);

class _BannerPremiumState extends State<BannerPremium>
    with SingleTickerProviderStateMixin {
  static const _radio = 22.0;

  late final AnimationController _brillo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4600),
  );
  bool _animando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final quieto = reducirMovimiento(context) || !BannerPremium.animar;
    if (quieto && _animando) {
      _brillo.stop();
      _animando = false;
    } else if (!quieto && !_animando) {
      _brillo.repeat();
      _animando = true;
    }
  }

  @override
  void dispose() {
    _brillo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final borde = BorderRadius.circular(_radio);
    return Semantics(
      button: true,
      label: '${t.premiumBannerTitle}. ${t.premiumBannerBody}',
      excludeSemantics: true,
      child: Presionable(
        // Mide lo que ocupa su contenido aunque el espacio sea abierto.
        child: IntrinsicHeight(
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: borde,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F5844), AppColors.verdeOscuro],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.verdeAcento.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: borde,
                onTap: widget.onTap,
                child: ClipRRect(
                  borderRadius: borde,
                  child: Stack(
                    children: [
                      // Resplandores de color: dan algo que el vidrio refleje.
                      Positioned(
                        right: -30,
                        top: -40,
                        child: _Resplandor(
                          tamano: 150,
                          color: AppColors.verdeAcento.withValues(alpha: 0.55),
                        ),
                      ),
                      Positioned(
                        left: -40,
                        bottom: -60,
                        child: _Resplandor(
                          tamano: 140,
                          color: const Color(
                            0xFF8DE8B0,
                          ).withValues(alpha: 0.28),
                        ),
                      ),
                      // La huella a medio salir por la derecha, como en el original.
                      Positioned(
                        right: -14,
                        bottom: -22,
                        child: Transform.rotate(
                          angle: -0.35,
                          child: Icon(
                            Icons.pets,
                            size: 120,
                            color: AppColors.verdeAcento.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      // Panel de vidrio: velo, reflejo superior y borde claro.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _Vidrio(_radio)),
                        ),
                      ),
                      // Destello que cruza el panel.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _brillo,
                            builder: (context, _) => CustomPaint(
                              painter: _Destello(
                                _animando ? _brillo.value : 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                        child: Row(
                          children: [
                            const _Medalla(),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.premiumBannerTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    t.premiumBannerBody,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.14),
                                border: Border.all(
                                  color: AppColors.verdeAcento.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.verdeAcento,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// La medalla: disco de vidrio con un halo dorado y el icono amarillo.
class _Medalla extends StatelessWidget {
  const _Medalla();

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.30),
          Colors.white.withValues(alpha: 0.06),
        ],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
      boxShadow: [
        BoxShadow(color: _oro.withValues(alpha: 0.45), blurRadius: 16),
      ],
    ),
    child: const Icon(Icons.workspace_premium, color: _oro, size: 28),
  );
}

class _Resplandor extends StatelessWidget {
  const _Resplandor({required this.tamano, required this.color});
  final double tamano;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: tamano,
    height: tamano,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
    ),
  );
}

/// Vidrio: velo blanco muy suave, reflejo en la mitad de arriba y un borde que
/// brilla en la esquina superior izquierda y se apaga hacia abajo a la derecha.
class _Vidrio extends CustomPainter {
  const _Vidrio(this.radio);
  final double radio;

  @override
  void paint(Canvas canvas, Size size) {
    final cuerpo = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radio),
    );
    canvas.drawRRect(
      cuerpo,
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );
    final arriba = Rect.fromLTWH(0, 0, size.width, size.height * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        arriba,
        topLeft: Radius.circular(radio),
        topRight: Radius.circular(radio),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(arriba),
    );
    canvas.drawRRect(
      cuerpo.deflate(0.75),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.65),
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.22),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_Vidrio old) => old.radio != radio;
}

/// Franja diagonal blanca y translúcida. [t] va de 0 a 1; más de 0,55 es el
/// descanso entre pasadas (la franja ya salió por la derecha).
class _Destello extends CustomPainter {
  const _Destello(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final avance = t / 0.55;
    if (avance >= 1) return;
    final ancho = size.width * 0.34;
    final x =
        -ancho + (size.width + ancho * 2) * Curves.easeInOut.transform(avance);
    final rect = Rect.fromLTWH(x, -size.height, ancho, size.height * 3);
    canvas.save();
    canvas.translate(x + ancho / 2, size.height / 2);
    canvas.rotate(math.pi / 9);
    canvas.translate(-(x + ancho / 2), -size.height / 2);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.38),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Destello old) => old.t != t;
}
