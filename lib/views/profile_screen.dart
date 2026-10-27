import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../theme/app_colors.dart';
import 'change_email_screen.dart';
import 'change_password_screen.dart';
import 'privacy_screen.dart';
import 'widgets/reauthentication_dialog.dart';
import 'widgets/iniciar_paseo.dart';
import 'widgets/pawlife_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      if (mounted) setState(() => _error = 'No se pudo cargar el perfil: $e');
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil guardado.')));
    } catch (e) {
      if (mounted) setState(() => _error = 'No se pudo guardar: $e');
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
      if (mounted) setState(() => _error = 'No se pudo cerrar sesión: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          'Se borrarán tu cuenta, tus mascotas y sus registros. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar definitivamente'),
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
            title: const Text('Eliminación en curso'),
            content: const Text(
              'Tu cuenta ya está bloqueada y estamos terminando de borrar tus datos. '
              'Se completará automáticamente en unos minutos.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Entendido'),
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
      if (mounted) setState(() => _error = 'No se pudo eliminar la cuenta: $e');
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
      ).showSnackBar(SnackBar(content: Text('Correo actualizado: $changed')));
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
      ).showSnackBar(const SnackBar(content: Text('Contraseña actualizada.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? '';
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.fondo,
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
                  TextButton(onPressed: _load, child: const Text('Reintentar')),
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
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Correo electrónico'),
                    subtitle: Text(email),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Guardar cambios'),
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
                    label: const Text('Privacidad y mis datos'),
                  ),
                  const SizedBox(height: 12),
                  if (_auth.supportsPasswordChange) ...[
                    OutlinedButton(
                      onPressed: _saving ? null : _changeEmail,
                      child: const Text('Cambiar correo'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _saving ? null : _changePassword,
                      child: const Text('Cambiar contraseña'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton(
                    onPressed: _saving ? null : _signOut,
                    child: const Text('Cerrar sesión'),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _saving ? null : _deleteAccount,
                    child: const Text('Eliminar mi cuenta'),
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
