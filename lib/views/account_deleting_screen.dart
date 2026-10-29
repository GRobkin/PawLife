import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_palette.dart';

/// La cuenta ya está bloqueada y el servidor termina de borrarla solo. Aquí no
/// hay nada más que hacer que salir: ninguna otra pantalla funcionaría.
class AccountDeletingScreen extends StatefulWidget {
  const AccountDeletingScreen({super.key, this.auth});

  final AuthService? auth;

  @override
  State<AccountDeletingScreen> createState() => _AccountDeletingScreenState();
}

class _AccountDeletingScreenState extends State<AccountDeletingScreen> {
  bool _saliendo = false;

  Future<void> _salir() async {
    setState(() => _saliendo = true);
    try {
      await (widget.auth ?? AuthService()).signOut(revokePush: false);
      cuentaEliminandose.value = false;
    } catch (_) {
      if (mounted) setState(() => _saliendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: context.mentaSuave,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_bottom_rounded,
                      size: 34,
                      color: context.marca,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.deletionInProgress,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.deletionInProgressBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.textoSuave, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saliendo ? null : _salir,
                      icon: const Icon(Icons.logout),
                      label: Text(t.signOut),
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
