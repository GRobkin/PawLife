// views/welcome_screen.dart
//
// Pantalla inicial de bienvenida. Solo navega: no tiene lógica.
//
// La foto de fondo vive en assets/images/ y está declarada en pubspec.yaml.
// Encima lleva un degradado que la funde con el color de fondo, para que el
// logo y el texto se lean sin depender de cómo sea la imagen.

import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

const _kDarkGreen = Color(0xFF12352A);
const _kBackground = Color(0xFFF7F8FA);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
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
                        _kBackground.withValues(alpha: 0.85),
                        _kBackground,
                      ],
                      stops: const [0.35, 0.75, 1.0],
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
                        decoration: const BoxDecoration(
                          color: _kDarkGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'PawLife',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: _kDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'La salud y felicidad de tu compañero,\ntodo en un solo lugar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
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
                        backgroundColor: _kDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Comenzar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
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
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFDDE1E6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Al continuar, aceptás nuestros '),
                          TextSpan(
                            text: 'Términos del servicio',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(text: ' y la '),
                          TextSpan(
                            text: 'Política de privacidad',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black45),
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
