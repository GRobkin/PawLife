import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/error_messages.dart';
import '../../services/auth_service.dart';

Future<bool> confirmIdentity(BuildContext context, AuthService auth) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ReauthenticationDialog(auth: auth),
    ) ??
    false;

class _ReauthenticationDialog extends StatefulWidget {
  const _ReauthenticationDialog({required this.auth});
  final AuthService auth;

  @override
  State<_ReauthenticationDialog> createState() =>
      _ReauthenticationDialogState();
}

class _ReauthenticationDialogState extends State<_ReauthenticationDialog> {
  AppLocalizations get t => AppLocalizations.of(context);

  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_busy) return;
    if (widget.auth.supportsPasswordChange && _password.text.isEmpty) {
      setState(() => _error = t.errEnterCurrentPassword);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.reauthenticateForSensitiveAction(
        password: widget.auth.supportsPasswordChange ? _password.text : null,
      );
      if (mounted) Navigator.pop(context, true);
    } on AuthException catch (error) {
      if (mounted && !error.isCancelled) setState(() => _error = authErrorText(AppLocalizations.of(context), error));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = t.identityVerifyError,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: Text(t.confirmIdentity),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.auth.supportsPasswordChange)
            TextField(
              controller: _password,
              enabled: !_busy,
              autofocus: true,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(labelText: t.currentPassword),
              onSubmitted: (_) => _confirm(),
            )
          else
            Text(t.confirmGoogleAccount),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _confirm,
          child: Text(_busy ? t.verifyingEllipsis : t.confirm),
        ),
      ],
    ),
  );
}
