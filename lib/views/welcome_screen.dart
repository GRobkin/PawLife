// views/welcome_screen.dart
//
// Primera impresión de la app, con el mismo lenguaje que el panel
// administrativo: fondo verde bosque, "pawlife" gigante de marca de agua,
// órbitas finas, titular enorme en blanco, la foto de las mascotas recortada
// en una forma orgánica con sombra menta y la medalla con la huella, que se
// puede arrastrar y vuelve a su sitio con un resorte.
//
// Debajo, una hoja clara con las formas de entrar. Google va primero porque
// sirve tanto para entrar como para crear la cuenta en un solo paso.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/app_palette.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'widgets/boton_google.dart';
import 'widgets/motion.dart';
import 'widgets/preferences_section.dart';

const _bosque = Color(0xFF12352A);
const _menta = Color(0xFF5CC58F);
const _cantoMedalla = Color(0xFF28674A);
const _papel = Color(0xFFF7F8FA);

/// Curva del panel: arranca rápido y se posa suave.
const _llegada = Cubic(0.16, 1, 0.3, 1);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.auth});

  final AuthService? auth;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AuthService _auth = widget.auth ?? AuthService();
  bool _cargando = false;

  /// Un solo reloj para toda la entrada: titular, foto, medalla y hoja.
  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducirMovimiento(context)) {
      _entrada.value = 1;
    } else if (_entrada.value == 0 && !_entrada.isAnimating) {
      _entrada.forward();
    }
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  Animation<double> _tramo(double desde, double hasta) => CurvedAnimation(
    parent: _entrada,
    curve: Interval(desde, hasta, curve: _llegada),
  );

  Future<void> _google() async {
    setState(() => _cargando = true);
    final error = await entrarConGoogle(context, _auth);
    if (!mounted) return;
    setState(() => _cargando = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _abrir(Widget pantalla) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lineas = t.welcomeHeadline.split('\n');
    return Scaffold(
      backgroundColor: _bosque,
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, caja) => _Escena(
                ancho: math.min(caja.maxWidth, 560),
                alto: caja.maxHeight,
                lineas: lineas,
                titular: _tramo(0, 0.7),
                titularSegunda: _tramo(0.08, 0.78),
                foto: _tramo(0.1, 0.9),
                medalla: _tramo(0.25, 1),
                idioma: t.language,
              ),
            ),
          ),
          _Hoja(
            aparicion: _tramo(0.35, 1),
            cargando: _cargando,
            onGoogle: _google,
            onComenzar: () => _abrir(const RegisterScreen()),
            onEntrar: () => _abrir(const LoginScreen()),
          ),
        ],
      ),
    );
  }
}

/// Parte verde: marca de agua, órbitas, titular, foto y medalla.
class _Escena extends StatelessWidget {
  const _Escena({
    required this.ancho,
    required this.alto,
    required this.lineas,
    required this.titular,
    required this.titularSegunda,
    required this.foto,
    required this.medalla,
    required this.idioma,
  });

  final double ancho;
  final double alto;
  final List<String> lineas;
  final Animation<double> titular;
  final Animation<double> titularSegunda;
  final Animation<double> foto;
  final Animation<double> medalla;
  final String idioma;

  @override
  Widget build(BuildContext context) {
    final tamTitular = (ancho * 0.17).clamp(48.0, 96.0);
    final anchoFoto = math.min(ancho * 0.8, alto * 0.64);
    final altoFoto = anchoFoto * 1.06;
    return ClipRect(
      child: Center(
        child: SizedBox(
          width: ancho,
          height: alto,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // "pawlife" gigante de fondo, como en el panel.
              Positioned(
                top: alto * 0.1,
                left: -ancho * 0.04,
                child: Text(
                  'pawlife',
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontSize: ancho * 0.42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -ancho * 0.42 * 0.09,
                    height: 1,
                    color: _menta.withValues(alpha: 0.24),
                  ),
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PintorOrbitas()),
                ),
              ),
              // Foto en forma orgánica, girada, con sombra menta sólida.
              Positioned(
                right: ancho * 0.03,
                bottom: 28,
                width: anchoFoto,
                height: altoFoto,
                child: AnimatedBuilder(
                  animation: foto,
                  builder: (_, hijo) => Opacity(
                    opacity: foto.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (1 - foto.value) * 50),
                      child: Transform.scale(
                        scale: 0.9 + 0.1 * foto.value,
                        child: hijo,
                      ),
                    ),
                  ),
                  child: const _FotoOrganica(),
                ),
              ),
              // Medalla con la huella: se arrastra y vuelve con un resorte.
              Positioned(
                left: ancho * 0.05,
                bottom: 28 + altoFoto * 0.04,
                width: (ancho * 0.3).clamp(96.0, 150.0),
                child: AnimatedBuilder(
                  animation: medalla,
                  builder: (_, hijo) => Opacity(
                    opacity: medalla.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(
                        -30 * (1 - medalla.value),
                        40 * (1 - medalla.value),
                      ),
                      child: Transform.rotate(
                        angle: -0.6 * (1 - medalla.value),
                        child: hijo,
                      ),
                    ),
                  ),
                  child: const _MedallaArrastrable(),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _LogoMinusculas(),
                          const Spacer(),
                          _BotonIdioma(
                            codigo: Localizations.localeOf(
                              context,
                            ).languageCode.toUpperCase(),
                            tooltip: idioma,
                          ),
                        ],
                      ),
                      SizedBox(height: alto * 0.04),
                      Semantics(
                        header: true,
                        label: lineas.join(' '),
                        excludeSemantics: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < lineas.length; i++)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: i == 0 ? 0 : ancho * 0.12,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: _LineaQueSube(
                                    texto: lineas[i],
                                    tam: tamTitular,
                                    animacion: i == 0
                                        ? titular
                                        : titularSegunda,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Línea del titular que sube desde abajo de su propio renglón.
class _LineaQueSube extends StatelessWidget {
  const _LineaQueSube({
    required this.texto,
    required this.tam,
    required this.animacion,
  });

  final String texto;
  final double tam;
  final Animation<double> animacion;

  @override
  Widget build(BuildContext context) {
    final linea = Text(
      texto,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(
        fontFamily: 'NunitoSans',
        fontSize: tam,
        fontWeight: FontWeight.w900,
        letterSpacing: -tam * 0.065,
        height: 0.95,
        color: _papel,
      ),
    );
    return ClipRect(
      child: AnimatedBuilder(
        animation: animacion,
        child: linea,
        builder: (_, hijo) => FractionalTranslation(
          translation: Offset(0, 1 - animacion.value),
          child: Opacity(opacity: animacion.value.clamp(0.0, 1.0), child: hijo),
        ),
      ),
    );
  }
}

class _FotoOrganica extends StatelessWidget {
  const _FotoOrganica();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, caja) {
        final w = caja.maxWidth;
        final radio = BorderRadius.only(
          topLeft: Radius.circular(w * 0.48),
          topRight: Radius.circular(w * 0.48),
          bottomRight: Radius.circular(w * 0.03),
          bottomLeft: Radius.circular(w * 0.48),
        );
        return Transform.rotate(
          angle: -9 * math.pi / 180,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radio,
              color: _menta,
              boxShadow: const [
                BoxShadow(color: _menta, offset: Offset(18, 18)),
                BoxShadow(
                  color: Color(0x66041A14),
                  offset: Offset(16, 40),
                  blurRadius: 50,
                  spreadRadius: -24,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.rotate(
                    angle: 9 * math.pi / 180,
                    child: Transform.scale(
                      scale: 1.16,
                      child: Image.asset(
                        'assets/images/welcome.png',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.3),
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: _cantoMedalla),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [Color(0x6612352A), Color(0x0012352A)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Medalla menta con canto oscuro, como un dije de collar. Se puede arrastrar;
/// al soltarla vuelve con un resorte.
class _MedallaArrastrable extends StatefulWidget {
  const _MedallaArrastrable();

  @override
  State<_MedallaArrastrable> createState() => _MedallaArrastrableState();
}

class _MedallaArrastrableState extends State<_MedallaArrastrable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resorte = AnimationController.unbounded(
    vsync: this,
  );
  Offset _desplazamiento = Offset.zero;
  Offset _alSoltar = Offset.zero;

  @override
  void initState() {
    super.initState();
    _resorte.addListener(() {
      setState(() => _desplazamiento = _alSoltar * _resorte.value);
    });
  }

  @override
  void dispose() {
    _resorte.dispose();
    super.dispose();
  }

  void _soltar(DragEndDetails _) {
    _alSoltar = _desplazamiento;
    if (reducirMovimiento(context)) {
      setState(() => _desplazamiento = Offset.zero);
      return;
    }
    // Va de 1 (donde se soltó) a 0 (su sitio), con un poco de rebote.
    _resorte.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 180, damping: 11),
        1,
        0,
        0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // El giro sigue al arrastre, como si colgara de una argolla.
    final giro = -0.3 + _desplazamiento.dx / 400;
    return GestureDetector(
      onPanStart: (_) => _resorte.stop(),
      onPanUpdate: (d) => setState(() => _desplazamiento += d.delta),
      onPanEnd: _soltar,
      child: Transform.translate(
        offset: _desplazamiento,
        child: Transform.rotate(
          angle: giro,
          child: const AspectRatio(aspectRatio: 0.82, child: _Medalla()),
        ),
      ),
    );
  }
}

class _Medalla extends StatelessWidget {
  const _Medalla();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, caja) {
        final w = caja.maxWidth;
        final h = caja.maxHeight;
        final forma = BorderRadius.only(
          topLeft: Radius.elliptical(w * 0.42, h * 0.42),
          topRight: Radius.elliptical(w * 0.42, h * 0.42),
          bottomLeft: Radius.elliptical(w * 0.28, h * 0.28),
          bottomRight: Radius.elliptical(w * 0.28, h * 0.28),
        );
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Canto: la misma forma, más oscura y corrida, da volumen.
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(w * 0.07, h * 0.06),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _cantoMedalla,
                    borderRadius: forma,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x80041A14),
                        offset: Offset(12, 22),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: forma,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8BE0B2), _menta],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: h * 0.1),
                    // Agujero de la argolla.
                    Container(
                      width: w * 0.16,
                      height: w * 0.16,
                      decoration: BoxDecoration(
                        color: _bosque,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _cantoMedalla,
                          width: w * 0.025,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.pets, size: w * 0.42, color: _bosque),
                    SizedBox(height: h * 0.16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Órbitas finas en menta, inclinadas, detrás de todo.
class _PintorOrbitas extends CustomPainter {
  const _PintorOrbitas();

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _menta.withValues(alpha: 0.4);
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.62);
    canvas.rotate(-24 * math.pi / 180);
    for (final (rx, ry) in [(0.62, 0.36), (0.8, 0.5), (1.0, 0.64)]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * rx * 2,
          height: size.height * ry * 2,
        ),
        pincel,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorOrbitas old) => false;
}

/// "pawlife" en minúsculas con una huella pequeña, como en el panel.
class _LogoMinusculas extends StatelessWidget {
  const _LogoMinusculas();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'pawlife',
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            height: 1,
            color: _papel,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 2, bottom: 2),
          child: Icon(Icons.pets, size: 12, color: _menta),
        ),
      ],
    );
  }
}

/// Idioma y apariencia antes de entrar.
class _BotonIdioma extends StatelessWidget {
  const _BotonIdioma({required this.codigo, required this.tooltip});

  final String codigo;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Presionable(
        child: Material(
          color: _papel.withValues(alpha: 0.12),
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => const SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: PreferencesSection(),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 18, color: _papel),
                  const SizedBox(width: 6),
                  Text(
                    codigo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _papel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja de abajo con las formas de entrar. Sube al final de la entrada.
class _Hoja extends StatelessWidget {
  const _Hoja({
    required this.aparicion,
    required this.cargando,
    required this.onGoogle,
    required this.onComenzar,
    required this.onEntrar,
  });

  final Animation<double> aparicion;
  final bool cargando;
  final VoidCallback onGoogle;
  final VoidCallback onComenzar;
  final VoidCallback onEntrar;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: aparicion,
      builder: (_, hijo) => FractionalTranslation(
        translation: Offset(0, 0.25 * (1 - aparicion.value)),
        child: hijo,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.fondoPantalla,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BotonGoogle(cargando: cargando, onPressed: onGoogle),
                    const SizedBox(height: 12),
                    Presionable(
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: cargando ? null : onComenzar,
                          style: FilledButton.styleFrom(
                            backgroundColor: context.botonFondo,
                            foregroundColor: context.botonTexto,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t.getStarted,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: cargando ? null : onEntrar,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: t.hasAccountPrefix,
                              style: TextStyle(
                                color: context.textoSuave,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: t.signIn,
                              style: TextStyle(
                                color: context.marca,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: t.termsPrefix),
                          TextSpan(
                            text: t.termsOfService,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: t.termsAnd),
                          TextSpan(
                            text: t.privacyPolicy,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: context.textoTenue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
