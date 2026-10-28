import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../l10n/app_localizations.dart';
import 'change_email_screen.dart';
import 'change_password_screen.dart';
import 'privacy_screen.dart';
import 'widgets/reauthentication_dialog.dart';
import 'widgets/iniciar_paseo.dart';
import 'widgets/preferences_section.dart';
import 'widgets/pawlife_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppLocalizations get t => AppLocalizations.of(context);

  final _auth = AuthService();
  late final _repo = PawLifeRepository(
    client: ApiClient(auth: _auth, expectedUid: _auth.currentUser?.uid ?? ''),
  );
  final _nombre = TextEditingController();
  Map<String, dynamic>? _perfil;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _repo.client.close();
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await _repo.fetchPerfil();
      if (!mounted) return;
      final perfil = response['perfil'];
      setState(() {
        _perfil = perfil is Map<String, dynamic> ? perfil : {};
        _nombre.text = (_perfil?['nombre'] as String?) ?? '';
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).profileLoadError('$e'),
        );
      }
    }
  }

  Future<void> _save() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) return;
    setState(() => _saving = true);
    try {
      final updated = await _repo.updatePerfil(nombre: nombre);
      if (!mounted) return;
      setState(() => _perfil = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profileSaved)),
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).profileSaveError('$e'),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _saving = true);
    try {
      await _auth.signOut();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) setState(() => _error = t.signOutError('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.deleteAccountTitle),
        content: Text(t.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.deleteForever),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      if (!await confirmIdentity(context, _auth) || !mounted) return;
      final completed = await _repo.eliminarCuenta();
      if (!completed && mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(t.deletionInProgress),
            content: Text(t.deletionInProgressBody),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(t.understood),
              ),
            ],
          ),
        );
      }
      if (_auth.currentUser?.uid == _repo.client.expectedUid) {
        await _auth.signOut(revokePush: false);
      }
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) setState(() => _error = t.deleteAccountError('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeEmail() async {
    final changed = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ChangeEmailScreen(auth: _auth)),
    );
    if (changed != null && mounted) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.emailUpdated(changed))));
    }
  }

  Future<void> _changePassword() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ChangePasswordScreen(auth: _auth)),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.passwordUpdated)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? '';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(t.profileTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _perfil == null && _error == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(onPressed: _load, child: Text(t.retry)),
                ],
                if (_perfil != null) ...[
                  const SizedBox(height: 16),
                  const CircleAvatar(
                    radius: 38,
                    child: Icon(Icons.person, size: 38),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _nombre,
                    maxLength: 80,
                    decoration: InputDecoration(
                      labelText: t.profileName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(title: Text(t.profileEmail), subtitle: Text(email)),
                  const SizedBox(height: 18),
                  const PreferencesSection(),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(t.profileSave),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrivacyScreen(auth: _auth),
                            ),
                          ),
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: Text(t.privacyAndData),
                  ),
                  const SizedBox(height: 12),
                  if (_auth.supportsPasswordChange) ...[
                    OutlinedButton(
                      onPressed: _saving ? null : _changeEmail,
                      child: Text(t.changeEmail),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _saving ? null : _changePassword,
                      child: Text(t.changePassword),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton(
                    onPressed: _saving ? null : _signOut,
                    child: Text(t.signOut),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _saving ? null : _deleteAccount,
                    child: Text(t.deleteAccountButton),
                  ),
                ],
              ],
            ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.perfil,
        onPaseo: () => iniciarPaseo(context),
      ),
    );
  }
}
