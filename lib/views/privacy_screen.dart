import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/local_reminder_service.dart';
import '../services/pawlife_repository.dart';
import '../services/privacy_export_service.dart';
import '../theme/app_colors.dart';
import 'widgets/reauthentication_dialog.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key, this.auth, this.repository, this.reminders});
  final AuthService? auth;
  final PawLifeRepository? repository;
  final LocalReminderService? reminders;

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late final _auth = widget.auth ?? AuthService();
  late final _uid = _auth.currentUser?.uid ?? '';
  late final _reminders = widget.reminders ?? LocalReminderService.instance;
  late final _repo =
      widget.repository ??
      PawLifeRepository(
        client: ApiClient(auth: _auth, expectedUid: _uid),
      );
  Map<String, dynamic>? _info;
  List<Map<String, dynamic>> _requests = [];
  String? _error;
  bool _saving = false;
  PrivacyExportService? _export;
  Uint8List? _file;
  int _records = 0;
  final _detail = TextEditingController();
  String _requestType = 'consulta';
  String? _requestId;
  StreamSubscription<dynamic>? _authChanges;

  bool get _sameUser => _auth.currentUser?.uid == _uid;

  @override
  void initState() {
    super.initState();
    _authChanges = _auth.authStateChanges.listen((_) {
      if (mounted && !_sameUser) {
        unawaited(_export?.cancel());
        setState(() {
          _file = null;
          _info = null;
          _requests = [];
          _detail.clear();
          _error = 'La sesión cambió. Volvé a entrar desde tu perfil.';
        });
      }
    });
    _load();
  }

  @override
  void dispose() {
    unawaited(_export?.cancel());
    _authChanges?.cancel();
    _file = null;
    _detail.dispose();
    if (widget.repository == null) _repo.client.close();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final info = await _repo.fetchPrivacy();
      final requests = await _repo.fetchPrivacyRequests();
      requests.sort((a, b) => '${b['creadoEn']}'.compareTo('${a['creadoEn']}'));
      if (mounted && _sameUser) {
        setState(() {
          _info = info;
          _requests = requests;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cargar la privacidad.');
    }
  }

  Future<void> _preference(String key, bool value) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final response = await _repo.updatePreferences({key: value});
      if (!mounted || !_sameUser) return;
      setState(() => _info!['preferencias'] = response['preferencias']);
      try {
        final preferences = response['preferencias'];
        if (preferences is Map &&
            preferences['recordatoriosCuidados'] == false) {
          await _reminders.clear();
        } else {
          await _reminders.sync(_repo);
        }
      } catch (_) {
        if (mounted) {
          setState(
            () => _error =
                'Preferencia guardada. No se pudieron actualizar los avisos de este dispositivo; reintentá antes de cerrarlo.',
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se guardó la preferencia. Reintentá.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _prepareExport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descargar mis datos'),
        content: const Text(
          'El archivo incluye tus fotos y recorridos GPS. Elegí un destino privado cuando lo guardes o compartas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || !_sameUser) return;
    setState(() {
      _saving = true;
      _file = null;
      _error = null;
      _records = 0;
    });
    try {
      if (!await confirmIdentity(context, _auth) || !mounted || !_sameUser) {
        return;
      }
      final operation = PrivacyExportService(
        repository: _repo,
        auth: _auth,
        uid: _uid,
      );
      _export = operation;
      final bytes = await operation.prepare(
        onProgress: (count) {
          if (mounted && _sameUser) setState(() => _records = count);
        },
      );
      if (mounted && _sameUser) setState(() => _file = bytes);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is PrivacyExportException
              ? error.message
              : 'No se completó el archivo. Podés iniciar otra exportación.',
        );
      }
    } finally {
      _export = null;
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share(BuildContext buttonContext) async {
    final bytes = _file;
    if (bytes == null || !_sameUser) {
      setState(() => _file = null);
      return;
    }
    final box = buttonContext.findRenderObject()! as RenderBox;
    setState(() => _saving = true);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'application/json')],
          fileNameOverrides: [
            'pawlife-datos-${DateTime.now().millisecondsSinceEpoch}.json',
          ],
          title: 'Mis datos PawLife',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No se pudo guardar o compartir. El archivo sigue preparado para reintentar.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendRequest() async {
    if (_detail.text.trim().isEmpty) return;
    _requestId ??= List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repo.createPrivacyRequest(
        tipo: _requestType,
        detalle: _detail.text.trim(),
        solicitudId: _requestId!,
      );
      if (!mounted || !_sameUser) return;
      _detail.clear();
      _requestId = null;
      await _load();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No se pudo registrar la solicitud. Conservamos el texto para reintentar.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final preferences = info?['preferencias'];
    final contact = info?['contacto'];
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: const Text('Privacidad'),
        backgroundColor: AppColors.fondo,
      ),
      body: info == null && _error == null
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
                  TextButton(
                    onPressed: _saving ? null : _load,
                    child: const Text('Reintentar'),
                  ),
                  const SizedBox(height: 16),
                ],
                if (info != null) ...[
                  Text(
                    'Tus avisos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Recordatorios de cuidados'),
                    subtitle: const Text('Vacunas, medicamentos y tareas'),
                    value:
                        preferences is Map &&
                        preferences['recordatoriosCuidados'] == true,
                    onChanged: _saving
                        ? null
                        : (value) =>
                              _preference('recordatoriosCuidados', value),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Avisos del equipo'),
                    value:
                        preferences is Map &&
                        preferences['avisosEquipo'] == true,
                    onChanged: _saving
                        ? null
                        : (value) => _preference('avisosEquipo', value),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Tus datos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Descargá tu perfil, mascotas, cuidados, fotos y recorridos en un archivo JSON.',
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _prepareExport,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Preparar archivo'),
                  ),
                  if (_export != null) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    Text('$_records registros preparados'),
                    TextButton(
                      onPressed: () => unawaited(_export?.cancel()),
                      child: const Text('Cancelar exportación'),
                    ),
                  ],
                  if (_file != null) ...[
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) => FilledButton.icon(
                        onPressed: _saving ? null : () => _share(context),
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Guardar o compartir JSON'),
                      ),
                    ),
                  ],
                  const Divider(height: 32),
                  Text(
                    'Solicitudes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (contact is Map) ...[
                    SelectableText(
                      '${contact['responsable']} · ${contact['email']}',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (info['solicitudesHabilitadas'] == true &&
                      contact is Map) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _requestType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de solicitud',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'consulta',
                          child: Text('Consulta'),
                        ),
                        DropdownMenuItem(
                          value: 'acceso',
                          child: Text('Acceso a información'),
                        ),
                        DropdownMenuItem(
                          value: 'correccion',
                          child: Text('Corrección'),
                        ),
                        DropdownMenuItem(
                          value: 'oposicion',
                          child: Text('Oposición'),
                        ),
                        DropdownMenuItem(
                          value: 'bloqueo',
                          child: Text('Bloqueo'),
                        ),
                        DropdownMenuItem(
                          value: 'anonimizacion',
                          child: Text('Anonimización'),
                        ),
                      ],
                      onChanged: _saving
                          ? null
                          : (value) {
                              _requestType = value!;
                              _requestId = null;
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _detail,
                      enabled: !_saving,
                      maxLength: 1000,
                      maxLines: 4,
                      onChanged: (_) => _requestId = null,
                      decoration: const InputDecoration(
                        labelText: 'Detalle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _saving ? null : _sendRequest,
                      child: const Text('Registrar solicitud'),
                    ),
                  ] else
                    Text(
                      contact is Map
                          ? 'Por ahora podés enviar tus solicitudes al correo de soporte.'
                          : 'El canal de consultas todavía no está configurado.',
                    ),
                  for (final request in _requests)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${request['tipo']} · ${request['estado']}'),
                      subtitle: Text('${request['detalle']}'),
                    ),
                  if (_requests.isNotEmpty)
                    TextButton(
                      onPressed: _saving ? null : _load,
                      child: const Text('Actualizar solicitudes'),
                    ),
                ],
              ],
            ),
    );
  }
}
