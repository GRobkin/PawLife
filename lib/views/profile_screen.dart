import 'package:flutter/material.dart';
import 'widgets/esqueletos.dart';
import 'widgets/motion.dart';

import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'change_email_screen.dart';
import 'change_password_screen.dart';
import 'premium_screen.dart';
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
      await _repo.eliminarCuenta();
      // Terminado o en curso, la cuenta ya está bloqueada: se cierra la sesión
      // en este dispositivo y el servidor completa el borrado solo.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      await _auth.signOut(revokePush: false);
      cuentaEliminandose.value = false;
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
      body: TransicionCarga(
        child: _perfil == null && _error == null
            ? const EsqueletoPerfil(key: ValueKey('cargando'))
            : ListView(
                key: const ValueKey('perfil'),
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
                    Center(
                      child: _AvatarPerfil(
                        fotoUrl: _auth.currentUser?.photoURL,
                        nombre: _auth.currentUser?.displayName ?? email,
                      ),
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
                    ListTile(
                      title: Text(t.profileEmail),
                      subtitle: Text(email),
                    ),
                    const SizedBox(height: 18),
                    const PreferencesSection(),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(t.profileSave),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _GrupoOpciones(
                      children: [
                        _Opcion(
                          icono: Icons.workspace_premium_outlined,
                          texto: t.premiumTitle,
                          onTap: _saving
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PremiumScreen(repository: _repo),
                                  ),
                                ),
                        ),
                        _Opcion(
                          icono: Icons.shield_outlined,
                          texto: t.privacyAndData,
                          onTap: _saving
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PrivacyScreen(auth: _auth),
                                  ),
                                ),
                        ),
                        if (_auth.supportsPasswordChange) ...[
                          _Opcion(
                            icono: Icons.alternate_email,
                            texto: t.changeEmail,
                            onTap: _saving ? null : _changeEmail,
                          ),
                          _Opcion(
                            icono: Icons.lock_outline,
                            texto: t.changePassword,
                            onTap: _saving ? null : _changePassword,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    _GrupoOpciones(
                      children: [
                        _Opcion(
                          icono: Icons.logout,
                          texto: t.signOut,
                          onTap: _saving ? null : _signOut,
                          flecha: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: _saving ? null : _deleteAccount,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text(t.deleteAccountButton),
                      ),
                    ),
                  ],
                ],
              ),
      ),
      bottomNavigationBar: PawLifeBottomNav(
        activa: SeccionNav.perfil,
        onPaseo: () => iniciarPaseo(context),
      ),
    );
  }
}

/// Tarjeta con opciones apiladas y separadas por una línea fina: todas con la
/// misma altura, icono y alineación, en lugar de botones sueltos distintos.
class _GrupoOpciones extends StatelessWidget {
  const _GrupoOpciones({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.superficie,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, indent: 62, color: context.bordeSuave),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.texto,
    required this.onTap,
    this.flecha = true,
  });

  final IconData icono;
  final String texto;
  final VoidCallback? onTap;
  final bool flecha;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 58),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.mentaSuave,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, size: 19, color: context.marca),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.texto,
                  ),
                ),
              ),
              if (flecha) Icon(Icons.chevron_right, color: context.textoTenue),
            ],
          ),
        ),
      ),
    );
  }
}

/// Foto de Google si hay; si no, las iniciales sobre menta, con un anillo de
/// marca alrededor.
class _AvatarPerfil extends StatelessWidget {
  const _AvatarPerfil({required this.fotoUrl, required this.nombre});

  final String? fotoUrl;
  final String nombre;

  String get _iniciales {
    final texto = nombre
        .trim()
        .split(RegExp(r'[\s@._-]+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p.characters.first.toUpperCase())
        .join();
    return texto.isEmpty ? '?' : texto;
  }

  @override
  Widget build(BuildContext context) {
    final iniciales = Center(
      child: Text(
        _iniciales,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: context.marca,
        ),
      ),
    );
    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.marca, width: 2),
      ),
      child: ClipOval(
        child: ColoredBox(
          color: context.mentaSuave,
          child: fotoUrl == null
              ? iniciales
              : Image.network(
                  fotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => iniciales,
                ),
        ),
      ),
    );
  }
}
