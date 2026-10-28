// views/welcome_screen.dart
//
// Pantalla inicial de bienvenida. Solo navega: no tiene lógica.
//
// La foto de fondo vive en assets/images/ y está declarada en pubspec.yaml.
// Encima lleva un degradado que la funde con el color de fondo, para que el
// logo y el texto se lean sin depender de cómo sea la imagen.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'widgets/preferences_section.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final fondo = context.fondoPantalla;
    return Scaffold(
      backgroundColor: fondo,
      body: Column(
        children: [
          // Parte superior: imagen + logo + nombre
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/welcome.png',
                  fit: BoxFit.cover,
                  // Si el asset faltara (por ejemplo tras un merge que se
                  // lleve por delante la carpeta), mejor el degradado de
                  // siempre que el recuadro rojo de error de Flutter.
                  errorBuilder: (_, _, _) => const _HeroPlaceholder(),
                ),
                // Degradado para que el texto se lea sobre la imagen
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        fondo.withValues(alpha: 0.85),
                        fondo,
                      ],
                      stops: const [0.35, 0.75, 1.0],
                    ),
                  ),
                ),
                // Idioma y apariencia disponibles antes de iniciar sesión.
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
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
                  alignment: const Alignment(0, 0.55),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.botonFondo,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.pets,
                          color: context.botonTexto,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'PawLife',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: context.marca,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          t.welcomeTagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.textoSuave,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Parte inferior: botones.
          //
          // SafeArea solo abajo: arriba se deja pasar a propósito, para que la
          // foto llegue hasta el borde por detrás de la barra de estado. Sin
          // esto, el texto de términos queda tapado por la barra de navegación
          // del sistema (la barrita de gestos).
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.botonFondo,
                        foregroundColor: context.botonTexto,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t.getStarted,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.texto,
                        backgroundColor: context.superficie,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: context.bordeSuave),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.signIn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: t.termsPrefix),
                          TextSpan(
                            text: t.termsOfService,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: context.texto,
                            ),
                          ),
                          TextSpan(text: t.termsAnd),
                          TextSpan(
                            text: t.privacyPolicy,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: context.texto,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: context.textoTenue),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Respaldo por si la imagen de fondo no se puede cargar. Repite sus mismos
/// tonos cálidos para que la pantalla siga teniéndose en pie.
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
