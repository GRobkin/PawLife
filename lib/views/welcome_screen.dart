// views/welcome_screen.dart
//
// Pantalla inicial. La foto de las mascotas ocupa toda la pantalla y se acerca
// muy despacio, una sola vez; encima sube un panel con la marca y las formas
// de entrar. Google va primero porque sirve tanto para entrar como para
// crear la cuenta en un solo paso.
//
// La foto vive en assets/images/ y está declarada en pubspec.yaml.

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
    final oscuro = context.esOscuro;
    return Scaffold(
      backgroundColor: context.fondoPantalla,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _FotoConAcercamiento(),
          // Velo: aclara u oscurece la foto según el tema para que el panel
          // y el botón de idioma se lean siempre.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: oscuro
                    ? const [Color(0x66000000), Color(0x22000000)]
                    : const [Color(0x22FFFFFF), Color(0x00FFFFFF)],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton.filledTonal(
                  tooltip: t.language,
                  icon: const Icon(Icons.translate),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => const SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: PreferencesSection(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: _PanelQueSube(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.fondoPantalla,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: context.botonFondo,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.pets,
                                  size: 20,
                                  color: context.botonTexto,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'PawLife',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      color: context.marca,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                      height: 1,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            t.welcomeTagline,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: context.textoSuave,
                            ),
                          ),
                          const SizedBox(height: 26),
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
                                        fontWeight: FontWeight.w700,
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
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: t.termsPrefix),
                                TextSpan(
                                  text: t.termsOfService,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: context.textoSuave,
                                  ),
                                ),
                                TextSpan(text: t.termsAnd),
                                TextSpan(
                                  text: t.privacyPolicy,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: context.textoSuave,
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
          ),
        ],
      ),
    );
  }
}

/// Foto a pantalla completa que se acerca un 8 % en 18 segundos, una vez.
/// Solo cambia la escala (sin redibujar la imagen) y queda quieta después.
class _FotoConAcercamiento extends StatelessWidget {
  const _FotoConAcercamiento();

  @override
  Widget build(BuildContext context) {
    final foto = Image.asset(
      'assets/images/welcome.png',
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.6),
      // Si el asset faltara, mejor un degradado que el recuadro rojo.
      errorBuilder: (_, _, _) => const _HeroPlaceholder(),
    );
    if (reducirMovimiento(context)) return foto;
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 1.08),
        duration: const Duration(seconds: 18),
        curve: Curves.easeOutSine,
        builder: (_, escala, hijo) =>
            Transform.scale(scale: escala, child: hijo),
        child: foto,
      ),
    );
  }
}

/// El panel entra desde abajo con un leve desplazamiento y fundido.
class _PanelQueSube extends StatelessWidget {
  const _PanelQueSube({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reducirMovimiento(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutCubic,
      builder: (_, v, hijo) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 60),
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
