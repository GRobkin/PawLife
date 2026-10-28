import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
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
  AppLocalizations get t => AppLocalizations.of(context);

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
      if (mounted) setState(() => _error = authErrorText(AppLocalizations.of(context), error));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = t.emailLinkError,
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
          () => _error = t.notConfirmedYet('$_sentTo'),
        );
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = authErrorText(AppLocalizations.of(context), error));
    } catch (_) {
      if (mounted) {
        setState(() => _error = t.emailCheckError);
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
          Text(t.linkSentTo('$_sentTo')),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: errorStyle),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _saving ? null : _confirmed,
            child: Text(_saving ? t.checkingEllipsis : t.alreadyOpenedLink),
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
            decoration: InputDecoration(labelText: t.newEmail),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return t.errEnterNewEmail;
              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(text)) {
                return t.errValidEmail;
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
            decoration: InputDecoration(labelText: t.currentPassword),
            validator: (value) => value == null || value.isEmpty
                ? t.errEnterCurrentPassword
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
            child: Text(_saving ? t.sendingEllipsis : t.sendLink),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(title: Text(t.changeEmail)),
      body: !_auth.supportsPasswordChange
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Text(t.googleEmailNote),
            )
          : _body(context),
    ),
  );
}
