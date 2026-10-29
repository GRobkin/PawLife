// views/welcome_screen.dart
//
// Pantalla inicial, como una portada: la foto de las mascotas arriba se
// disuelve en el fondo, la marca va enorme debajo y unos iconos flotan sobre
// la foto para decir qué hace la app sin párrafos. Google va primero porque
// sirve tanto para entrar como para crear la cuenta en un solo paso.
//
// La foto vive en assets/images/ y está declarada en pubspec.yaml.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/app_palette.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'widgets/boton_google.dart';
import 'widgets/motion.dart';
import 'widgets/preferences_section.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.auth});

  final AuthService? auth;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final AuthService _auth = widget.auth ?? AuthService();
  bool _cargando = false;

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
    final fondo = context.fondoPantalla;
    final alto = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: fondo,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // La foto ocupa la parte de arriba y se disuelve en el fondo: sin
          // panel ni borde duro, el texto parece salir de la imagen.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: alto * 0.74,
            child: const _FotoConAcercamiento(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fondo.withValues(alpha: 0),
                    fondo.withValues(alpha: 0),
                    fondo.withValues(alpha: 0.88),
                    fondo,
                  ],
                  stops: const [0, 0.34, 0.58, 0.72],
                ),
              ),
            ),
          ),
          // Destellos de luz cálida que suben despacio sobre la foto, como el
          // sol de la tarde entre las hojas. No reciben toques.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: alto * 0.62,
            child: const IgnorePointer(child: _Destellos()),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _BotonIdioma(
                  codigo: Localizations.localeOf(
                    context,
                  ).languageCode.toUpperCase(),
                  tooltip: t.language,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 10),
                  child: _SinEnvoltura(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Marca enorme y apretada, como portada de revista.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _TituloLetras(
                            texto: 'PawLife',
                            estilo: TextStyle(
                              fontFamily: 'NunitoSans',
                              fontSize: 78,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -3.5,
                              height: 0.95,
                              color: context.marca,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Entrada(
                          retraso: 520,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Icon(
                                  Icons.pets,
                                  size: 18,
                                  color: context.marca,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t.welcomeTagline,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    color: context.textoSuave,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _Entrada(
                          retraso: 640,
                          child: BotonGoogle(
                            cargando: _cargando,
                            onPressed: _google,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Entrada(
                          retraso: 720,
                          child: Presionable(
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _cargando
                                    ? null
                                    : () => _abrir(const RegisterScreen()),
                                style: FilledButton.styleFrom(
                                  backgroundColor: context.botonFondo,
                                  foregroundColor: context.botonTexto,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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
                        ),
                        const SizedBox(height: 6),
                        _Entrada(
                          retraso: 800,
                          child: Center(
                            child: TextButton(
                              onPressed: _cargando
                                  ? null
                                  : () => _abrir(const LoginScreen()),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textoTenue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Idioma y apariencia antes de entrar: una pastilla clara con el idioma
/// actual, legible sobre la foto.
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
          color: context.superficie.withValues(alpha: 0.92),
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
                  Icon(Icons.language, size: 18, color: context.marca),
                  const SizedBox(width: 6),
                  Text(
                    codigo,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: context.marca,
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

/// Foto que se acerca un 8 % en 18 segundos, una vez. Solo cambia la escala
/// (sin redibujar la imagen) y queda quieta después.
class _FotoConAcercamiento extends StatelessWidget {
  const _FotoConAcercamiento();

  @override
  Widget build(BuildContext context) {
    final foto = Image.asset(
      'assets/images/welcome.png',
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.35),
      // Si el asset faltara, mejor un degradado que el recuadro rojo.
      errorBuilder: (_, _, _) => const _HeroPlaceholder(),
    );
    if (reducirMovimiento(context)) return foto;
    return ClipRect(
      child: RepaintBoundary(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 1.08),
          duration: const Duration(seconds: 18),
          curve: Curves.easeOutSine,
          builder: (_, escala, hijo) =>
              Transform.scale(scale: escala, child: hijo),
          child: foto,
        ),
      ),
    );
  }
}

/// El texto de abajo no se mueve en bloque: cada parte entra por su cuenta
/// (letras del título, frase, botones). Esto solo deja pasar al hijo.
class _SinEnvoltura extends StatelessWidget {
  const _SinEnvoltura({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Entra con fundido y un leve ascenso después de [retraso] ms, para que las
/// partes de la pantalla aparezcan en cascada y no todas a la vez.
class _Entrada extends StatelessWidget {
  const _Entrada({required this.retraso, required this.child});

  final int retraso;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) return child;
    const duracion = 520;
    final total = retraso + duracion;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(retraso / total, 1, curve: Curves.easeOutCubic),
      builder: (_, v, hijo) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 18),
          child: hijo,
        ),
      ),
      child: child,
    );
  }
}

/// Título que se arma letra por letra: cada una sube desde abajo, recortada
/// por su propia línea, como tipografía de cartel. Una sola animación para
/// todas las letras; después queda quieto.
class _TituloLetras extends StatefulWidget {
  const _TituloLetras({required this.texto, required this.estilo});

  final String texto;
  final TextStyle estilo;

  @override
  State<_TituloLetras> createState() => _TituloLetrasState();
}

class _TituloLetrasState extends State<_TituloLetras>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducirMovimiento(context)) {
      _c.value = 1;
    } else if (_c.value == 0 && !_c.isAnimating) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letras = widget.texto.characters.toList();
    final n = letras.length;
    return Semantics(
      label: widget.texto,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < n; i++)
              Builder(
                builder: (context) {
                  // Cada letra ocupa una franja del tiempo total, solapada
                  // con la siguiente para que la ola sea continua.
                  final inicio = i / (n + 2);
                  final v = Interval(
                    inicio,
                    (inicio + 3 / (n + 2)).clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic,
                  ).transform(_c.value);
                  return ClipRect(
                    child: Opacity(
                      opacity: v.clamp(0.0, 1.0),
                      child: FractionalTranslation(
                        translation: Offset(0, 1 - v),
                        child: Text(letras[i], style: widget.estilo),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Puntos de luz cálida y difusa que suben despacio y titilan, sobre la foto.
/// Pocos puntos, un solo controlador y un solo lienzo; se detiene después de
/// unas vueltas para no gastar batería con la pantalla abierta.
class _Destellos extends StatefulWidget {
  const _Destellos();

  @override
  State<_Destellos> createState() => _DestellosState();
}

class _DestellosState extends State<_Destellos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducirMovimiento(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(count: 3);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) return const SizedBox.shrink();
    return RepaintBoundary(
      child: CustomPaint(painter: _PintorDestellos(_c), size: Size.infinite),
    );
  }
}

class _PintorDestellos extends CustomPainter {
  _PintorDestellos(this.tiempo) : super(repaint: tiempo);

  final Animation<double> tiempo;

  // Posición x (0..1), fase inicial (0..1), radio y velocidad de cada punto.
  static const _puntos = [
    (0.08, 0.10, 22.0, 1.0),
    (0.22, 0.55, 12.0, 1.4),
    (0.35, 0.30, 30.0, 0.8),
    (0.48, 0.80, 10.0, 1.6),
    (0.60, 0.15, 18.0, 1.1),
    (0.72, 0.65, 26.0, 0.9),
    (0.85, 0.40, 14.0, 1.3),
    (0.93, 0.90, 20.0, 1.0),
    (0.15, 0.75, 16.0, 1.2),
    (0.55, 0.45, 8.0, 1.8),
    (0.78, 0.05, 11.0, 1.5),
    (0.42, 0.95, 24.0, 0.85),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = tiempo.value;
    for (final (x, fase, radio, velocidad) in _puntos) {
      // Sube en bucle y titila con una onda propia.
      final avance = (fase + t * velocidad) % 1.0;
      final y = size.height * (1.05 - avance * 1.1);
      final dx = size.width * x + 10 * math.sin(avance * 6.283);
      final brillo =
          (0.5 + 0.5 * math.sin(avance * 12.566 + fase * 6.283)) *
          (1 - (avance - 0.5).abs() * 2).clamp(0.0, 1.0);
      if (brillo <= 0.01) continue;
      final centro = Offset(dx, y);
      canvas.drawCircle(
        centro,
        radio,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color.fromRGBO(255, 236, 190, 0.55 * brillo),
              const Color.fromRGBO(255, 236, 190, 0),
            ],
          ).createShader(Rect.fromCircle(center: centro, radius: radio)),
      );
    }
  }

  @override
  bool shouldRepaint(_PintorDestellos old) => false;
}

/// Respaldo por si la imagen de fondo no se puede cargar.
class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8D9C0), Color(0xFFD5E3D2)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.pets, size: 90, color: Colors.white54),
      ),
    );
  }
}
