import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.auth});

  final AuthService? auth;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  AppLocalizations get t => AppLocalizations.of(context);

  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirmation = TextEditingController();
  late final _auth = widget.auth ?? AuthService();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _auth.changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (mounted) Navigator.pop(context, true);
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = authErrorText(AppLocalizations.of(context), error));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = t.passwordChangeError,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(title: Text(t.changePassword)),
      body: !_auth.supportsPasswordChange
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Text(t.googlePasswordNote),
            )
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _current,
                    enabled: !_saving,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(labelText: t.currentPassword),
                    validator: (value) => value == null || value.isEmpty
                        ? t.errEnterCurrentPassword
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _next,
                    enabled: !_saving,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(labelText: t.newPassword),
                    validator: (value) => value == null || value.length < 6
                        ? t.errMin6Chars
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmation,
                    enabled: !_saving,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(labelText: t.repeatNewPassword),
                    validator: (value) => value != _next.text
                        ? t.errPasswordMismatch
                        : null,
                    onFieldSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? t.saving : t.changePassword),
                  ),
                ],
              ),
            ),
    ),
  );
}
