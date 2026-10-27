import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Cambio de correo con verificación: no se modifica nada hasta que la
/// persona abre el enlace que llega al correo nuevo.
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key, this.auth});

  final AuthService? auth;

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final _auth = widget.auth ?? AuthService();
  bool _saving = false;
  String? _error;
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final target = _email.text.trim().toLowerCase();
      await _auth.requestEmailChange(
        currentPassword: _password.text,
        newEmail: target,
      );
      if (mounted) setState(() => _sentTo = target);
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo enviar el enlace. Intentá otra vez.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmed() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final current = await _auth.refreshAccount();
      if (!mounted) return;
      if (current?.toLowerCase() == _sentTo) {
        Navigator.pop(context, current);
      } else {
        setState(
          () => _error =
              'Todavía no confirmaste el enlace. Abrí el correo que enviamos a $_sentTo.',
        );
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo comprobar. Intentá otra vez.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _body(BuildContext context) {
    final errorStyle = TextStyle(color: Theme.of(context).colorScheme.error);
    if (_sentTo != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Te enviamos un enlace a $_sentTo. Tu correo actual no cambia hasta que lo abras.',
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: errorStyle),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _saving ? null : _confirmed,
            child: Text(_saving ? 'Comprobando…' : 'Ya abrí el enlace'),
          ),
        ],
      );
    }
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _email,
            enabled: !_saving,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'Correo nuevo'),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Ingresá el correo nuevo.';
              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(text)) {
                return 'Ingresá un correo válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _password,
            enabled: !_saving,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'Contraseña actual'),
            validator: (value) => value == null || value.isEmpty
                ? 'Ingresá tu contraseña actual.'
                : null,
            onFieldSubmitted: (_) => _send(),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: errorStyle),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _saving ? null : _send,
            child: Text(_saving ? 'Enviando…' : 'Enviar enlace'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(title: const Text('Cambiar correo')),
      body: !_auth.supportsPasswordChange
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Tu cuenta utiliza Google. Gestioná tu correo desde tu cuenta de Google.',
              ),
            )
          : _body(context),
    ),
  );
}
