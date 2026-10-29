// views/welcome_screen.dart
//
// Pantalla inicial, como una portada: la foto de las mascotas arriba se
// disuelve en el fondo, la marca va enorme debajo y unos iconos flotan sobre
// la foto para decir qué hace la app sin párrafos. Google va primero porque
// sirve tanto para entrar como para crear la cuenta en un solo paso.
//
// La foto vive en assets/images/ y está declarada en pubspec.yaml.

import 'dart:async';

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
          // Lo que hace la app, dicho con iconos que flotan sobre la foto.
          const _Burbuja(
            alineacion: Alignment(0.8, -0.46),
            icono: Icons.directions_walk,
            indice: 0,
          ),
          const _Burbuja(
            alineacion: Alignment(-0.84, -0.18),
            icono: Icons.vaccines_outlined,
            indice: 1,
          ),
          const _Burbuja(
            alineacion: Alignment(0.66, 0.02),
            icono: Icons.monitor_weight_outlined,
            indice: 2,
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
                  child: _PanelQueSube(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Marca enorme y apretada, como portada de revista.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'PawLife',
                            style: TextStyle(
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
                        Row(
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
                        const SizedBox(height: 28),
                        BotonGoogle(cargando: _cargando, onPressed: _google),
                        const SizedBox(height: 12),
                        Presionable(
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
                        const SizedBox(height: 6),
                        Center(
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

/// Icono redondo que aparece con un pequeño salto y flota despacio unas pocas
/// veces antes de quedarse quieto (no consume batería con la pantalla abierta).
class _Burbuja extends StatefulWidget {
  const _Burbuja({
    required this.alineacion,
    required this.icono,
    required this.indice,
  });

  final Alignment alineacion;
  final IconData icono;
  final int indice;

  @override
  State<_Burbuja> createState() => _BurbujaState();
}

class _BurbujaState extends State<_Burbuja>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flotar = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 2600 + widget.indice * 400),
  );
  bool _iniciado = false;
  Timer? _espera;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado || reducirMovimiento(context)) return;
    _iniciado = true;
    _espera = Timer(Duration(milliseconds: 600 + widget.indice * 160), () {
      if (mounted) _flotar.repeat(reverse: true, count: 6);
    });
  }

  @override
  void dispose() {
    _espera?.cancel();
    _flotar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final burbuja = Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: context.superficie.withValues(alpha: 0.94),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(widget.icono, color: context.marca, size: 26),
    );
    if (reducirMovimiento(context)) {
      return Align(alignment: widget.alineacion, child: burbuja);
    }
    return Align(
      alignment: widget.alineacion,
      child: RepaintBoundary(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 560 + widget.indice * 170),
          curve: Curves.easeOutBack,
          builder: (_, entrada, hijo) => Opacity(
            opacity: entrada.clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.6 + 0.4 * entrada, child: hijo),
          ),
          child: AnimatedBuilder(
            animation: _flotar,
            child: burbuja,
            builder: (_, hijo) => Transform.translate(
              offset: Offset(
                0,
                -8 * Curves.easeInOutSine.transform(_flotar.value),
              ),
              child: hijo,
            ),
          ),
        ),
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

/// El contenido entra desde abajo con un leve desplazamiento y fundido.
class _PanelQueSube extends StatelessWidget {
  const _PanelQueSube({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
      builder: (_, v, hijo) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 48),
          child: hijo,
        ),
      ),
      child: child,
    );
  }
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
