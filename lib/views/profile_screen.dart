import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/pawlife_repository.dart';
import '../theme/app_colors.dart';
import 'widgets/iniciar_paseo.dart';
import 'widgets/pawlife_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = PawLifeRepository();
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
      await AuthService().signOut();
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
      await _repo.eliminarCuenta();
      await AuthService().signOut(revokePush: false);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) setState(() => _error = 'No se pudo eliminar la cuenta: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUser?.email ?? '';
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
