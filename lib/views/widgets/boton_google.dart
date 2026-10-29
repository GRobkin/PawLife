// views/widgets/boton_google.dart
//
// "Continuar con Google" sirve para entrar y para registrarse: si la cuenta no
// existe, Firebase la crea. Por eso está en la bienvenida, en el login y en el
// registro, siempre igual.

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/error_messages.dart';
import '../../services/auth_service.dart';
import '../../theme/app_palette.dart';
import 'motion.dart';

/// Entra con Google. Devuelve el error a mostrar, o null si salió bien o si la
/// persona cerró el selector de cuentas (eso no es un error).
Future<String?> entrarConGoogle(BuildContext context, AuthService auth) async {
  final t = AppLocalizations.of(context);
  try {
    await auth.signInWithGoogle();
    return null;
  } on AuthException catch (e) {
    return e.isCancelled ? null : authErrorText(t, e);
  }
}

class BotonGoogle extends StatelessWidget {
  const BotonGoogle({
    super.key,
    required this.onPressed,
    this.cargando = false,
  });

  final VoidCallback? onPressed;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Presionable(
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: cargando ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: context.superficie,
            foregroundColor: context.texto,
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: BorderSide(color: context.bordeSuave),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: cargando
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: context.marca,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo oficial: las guías de marca de Google exigen este
                    // y no uno dibujado a mano.
                    Image.asset(
                      'assets/images/google_logo.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      t.continueWithGoogle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Línea fina con "o" en el medio, entre Google y el formulario de correo.
class SeparadorO extends StatelessWidget {
  const SeparadorO({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: context.bordeSuave)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            t.orSeparator,
            style: TextStyle(color: context.textoTenue),
          ),
        ),
        Expanded(child: Divider(color: context.bordeSuave)),
      ],
    );
  }
}
