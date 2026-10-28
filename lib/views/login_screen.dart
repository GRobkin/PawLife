// views/login_screen.dart
//
// Pantalla de inicio de sesión, contra Firebase Auth vía AuthService.
//
// No navega al Home al terminar: de eso se encarga el AuthGate de main.dart,
// que escucha el estado de la sesión. Aquí solo se vacía la pila de
// navegación para dejarlo a la vista.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'register_screen.dart';

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
      setState(
        () => _error = e.isCancelled
            ? null
            : authErrorText(AppLocalizations.of(context), e),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _onLoginPressed() {
    final t = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validación mínima en cliente: evita un viaje a Firebase para errores
    // que se ven a simple vista. El resto lo valida Firebase.
    if (email.isEmpty) {
      setState(() => _error = t.errEnterEmail);
      return;
    }
    if (!_emailValido(email)) {
      setState(() => _error = t.errInvalidEmail);
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = t.errEnterPassword);
      return;
    }

    _ejecutar(() => _auth.signInWithEmail(email: email, password: password));
  }

  void _onGooglePressed() {
    _ejecutar(() => _auth.signInWithGoogle());
  }

  Future<void> _onForgotPasswordPressed() async {
    final t = AppLocalizations.of(context);
    final email = _emailController.text.trim();

    if (email.isEmpty || !_emailValido(email)) {
      setState(() => _error = t.errEmailAbove);
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await _auth.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.resetEmailSent(email))));
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = authErrorText(AppLocalizations.of(context), e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  static bool _emailValido(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: context.esOscuro
                ? const [Color(0xFF0E1A15), Color(0xFF0B1410)]
                : const [Color(0xFFF4F7FB), Color(0xFFEFF4F1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.welcomeBack,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: context.marca,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: context.textoSuave),
                  ),
                  const SizedBox(height: 28),

                  // Tarjeta del formulario
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: context.superficie,
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
                        _FieldLabel(t.emailLabel),
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
                            _FieldLabel(t.passwordLabel),
                            GestureDetector(
                              onTap: _cargando
                                  ? null
                                  : _onForgotPasswordPressed,
                              child: Text(
                                t.forgotPassword,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.enlace,
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
                            tooltip: _obscurePassword
                                ? t.showPassword
                                : t.hidePassword,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: context.textoTenue,
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
                              backgroundColor: AppColors.verdeAcento,
                              foregroundColor: context.sobreAcento,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _cargando
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: context.sobreAcento,
                                    ),
                                  )
                                : Text(
                                    t.signIn,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                t.orSeparator,
                                style: TextStyle(color: context.textoTenue),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _cargando ? null : _onGooglePressed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.texto,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(color: context.bordeSuave),
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
                            label: Text(
                              t.continueWithGoogle,
                              style: const TextStyle(
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
                                TextSpan(
                                  text: t.noAccountPrefix,
                                  style: TextStyle(color: context.textoSuave),
                                ),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen(),
                                          ),
                                        ),
                                    child: Text(
                                      t.signUp,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: context.marca,
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
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.texto,
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
        hintStyle: TextStyle(color: context.textoTenue),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: 20, color: context.textoTenue),
        suffixIcon: suffix,
        filled: true,
        fillColor: context.campo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.bordeSuave),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.bordeSuave),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.marca, width: 1.4),
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
        color: context.errorFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.errorBorde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 19, color: context.errorIcono),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(fontSize: 13, color: context.errorTexto),
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
