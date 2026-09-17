// views/login_screen.dart
//
// Pantalla de inicio de sesión, contra Firebase Auth vía AuthService.
//
// No navega al Home al terminar: de eso se encarga el AuthGate de main.dart,
// que escucha el estado de la sesión. Aquí solo se vacía la pila de
// navegación para dejarlo a la vista.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';

const _kDarkGreen = Color(0xFF12352A);
const _kAccentGreen = Color(0xFF5CC58F);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();

  bool _obscurePassword = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Ejecuta una acción de autenticación controlando el estado de carga y los
  /// errores, para no repetir lo mismo en los tres botones de la pantalla.
  Future<void> _ejecutar(Future<void> Function() accion) async {
    if (_cargando) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await accion();
      if (!mounted) return;

      // El AuthGate ya tiene el Home construido debajo; basta con vaciar la
      // pila para dejarlo a la vista. Un pushReplacement aquí crearía un
      // segundo Home encima del que el gate acaba de montar.
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    } on AuthException catch (e) {
      if (!mounted) return;
      // Cancelar el diálogo de Google no es un error que haya que enseñar.
      setState(() => _error = e.isCancelled ? null : e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validación mínima en cliente: evita un viaje a Firebase para errores
    // que se ven a simple vista. El resto lo valida Firebase.
    if (email.isEmpty) {
      setState(() => _error = 'Escribí tu correo electrónico.');
      return;
    }
    if (!_emailValido(email)) {
      setState(() => _error = 'El correo no tiene un formato válido.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Escribí tu contraseña.');
      return;
    }

    _ejecutar(() => _auth.signInWithEmail(email: email, password: password));
  }

  void _onGooglePressed() {
    _ejecutar(() => _auth.signInWithGoogle());
  }

  Future<void> _onForgotPasswordPressed() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !_emailValido(email)) {
      setState(
        () => _error = 'Escribí tu correo arriba y volvé a pulsar aquí.',
      );
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await _auth.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te enviamos un correo a $email.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  static bool _emailValido(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F7FB), Color(0xFFEFF4F1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bienvenido de nuevo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: _kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Iniciá sesión para gestionar los cuidados de tu mascota.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  // Tarjeta del formulario
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Correo electrónico'),
                        const SizedBox(height: 8),
                        _AppTextField(
                          controller: _emailController,
                          hint: 'hola@pawlife.com',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const _FieldLabel('Contraseña'),
                            GestureDetector(
                              onTap: _cargando ? null : _onForgotPasswordPressed,
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _kAccentGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _AppTextField(
                          controller: _passwordController,
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: Colors.black45,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 18),
                          _ErrorBanner(_error!),
                        ],
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : _onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kAccentGreen,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _cargando
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'o',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _cargando ? null : _onGooglePressed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Color(0xFFDDE1E6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Logo oficial de Google. Sus guías de marca
                            // exigen usar este, no una versión dibujada a
                            // mano, en cualquier botón de "Acceder con
                            // Google".
                            icon: Image.asset(
                              'assets/images/google_logo.png',
                              width: 20,
                              height: 20,
                            ),
                            label: const Text(
                              'Continuar con Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: '¿No tenés una cuenta? ',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      'Registrate',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _kDarkGreen,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(fontSize: 14),
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
    );
  }
}

// ---------------------------------------------------------------------
// Widgets reutilizables por login y registro
// ---------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: 20, color: Colors.black45),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFFBFCFD),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE1E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE1E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDarkGreen, width: 1.4),
        ),
      ),
    );
  }
}

/// Aviso de error dentro de la tarjeta del formulario.
///
/// Se usa un bloque fijo en vez de un SnackBar porque el mensaje suele pedir
/// corregir un campo que está justo encima, y un SnackBar desaparece solo
/// antes de que dé tiempo a arreglarlo.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.mensaje);

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5C6C6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 19, color: Color(0xFFC0392B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8E2A22)),
            ),
          ),
        ],
      ),
    );
  }
}

// Exportados para que RegisterScreen los reutilice.
typedef AppFieldLabel = _FieldLabel;
typedef AppTextField = _AppTextField;
typedef AppErrorBanner = _ErrorBanner;
