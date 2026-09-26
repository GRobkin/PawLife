// views/register_screen.dart
//
// Pantalla de creación de cuenta, contra Firebase Auth vía AuthService.
//
// Igual que LoginScreen: no navega al Home al terminar. De eso se encarga el
// AuthGate de main.dart, que escucha el estado de la sesión.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import '../theme/app_colors.dart';

const _kDarkGreen = Color(0xFF12352A);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _auth = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccountPressed() async {
    if (_cargando) return;

    final nombre = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmacion = _confirmController.text;

    final error = _validar(nombre, email, password, confirmacion);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await _auth.registerWithEmail(
        nombre: nombre,
        email: email,
        password: password,
      );
      if (!mounted) return;

      // Registrarse deja la sesión abierta, así que el AuthGate ya tiene el
      // Home montado debajo: solo hay que vaciar la pila para dejarlo a la
      // vista. Ver la nota en main.dart.
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Comprobaciones que se pueden hacer sin preguntarle a Firebase. La
  /// confirmación de contraseña solo existe aquí: Firebase no sabe nada de
  /// ella, es cosa del formulario.
  String? _validar(
    String nombre,
    String email,
    String password,
    String confirmacion,
  ) {
    if (nombre.isEmpty) return 'Escribí tu nombre.';
    if (email.isEmpty) return 'Escribí tu correo electrónico.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'El correo no tiene un formato válido.';
    }
    // Es el mínimo que exige Firebase; mejor decirlo antes de que lo rechace.
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (password != confirmacion) return 'Las contraseñas no coinciden.';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdeSuave,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            (MediaQuery.sizeOf(context).height - 730).clamp(24, 100).toDouble(),
            20,
            24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120D2C1E),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'PawLife',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _kDarkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Creá tu cuenta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Completá tus datos para empezar.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 26),

                    const AppFieldLabel('Nombre completo'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _nameController,
                      hint: 'Ej. Juana Pérez',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 18),

                    const AppFieldLabel('Correo electrónico'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _emailController,
                      hint: 'nombre@ejemplo.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    const AppFieldLabel('Contraseña'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _passwordController,
                      hint: '••••••••',
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
                    const SizedBox(height: 18),

                    const AppFieldLabel('Confirmar contraseña'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _confirmController,
                      hint: '••••••••',
                      obscureText: _obscureConfirm,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: Colors.black45,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 22),
                      AppErrorBanner(_error!),
                    ],
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _onCreateAccountPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kDarkGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                'Crear cuenta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: '¿Ya tenés una cuenta? ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () =>
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    ),
                                child: const Text(
                                  'Iniciar sesión',
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
            ),
          ),
        ),
      ),
    );
  }
}
