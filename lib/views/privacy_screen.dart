import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/local_reminder_service.dart';
import '../services/pawlife_repository.dart';
import '../services/privacy_export_service.dart';
import '../theme/app_palette.dart';
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
  AppLocalizations get t => AppLocalizations.of(context);

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
          _error = t.privacySessionChanged;
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
      if (mounted) setState(() => _error = t.privacyLoadError);
    }
  }

  Map<String, dynamic> get _inactivity {
    final preferences = _info?['preferencias'];
    final value = preferences is Map ? preferences['inactividad'] : null;
    return value is Map<String, dynamic> ? value : const {};
  }

  /// Aviso por falta de paseos: lo genera el servidor, no hace falta
  /// reprogramar nada en este dispositivo.
  Future<void> _setInactivity(Map<String, Object> change) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final response = await _repo.updatePreferences({'inactividad': change});
      if (!mounted || !_sameUser) return;
      setState(() => _info!['preferencias'] = response['preferencias']);
    } catch (_) {
      if (mounted) setState(() => _error = t.prefNotSaved);
    } finally {
      if (mounted) setState(() => _saving = false);
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
          setState(() => _error = t.prefSavedRemindersFailed);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = t.prefNotSaved);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _prepareExport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.downloadMyData),
        content: Text(t.downloadMyDataBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.continueLabel),
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
              ? exportErrorText(t, error)
              : t.exportIncomplete,
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
        setState(() => _error = t.exportShareFailed);
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
        setState(() => _error = t.requestNotRegistered);
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
      backgroundColor: context.fondoPantalla,
      appBar: AppBar(
        title: Text(t.privacyTitle),
        backgroundColor: context.fondoPantalla,
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
                    child: Text(t.retry),
                  ),
                  const SizedBox(height: 16),
                ],
                if (info != null) ...[
                  Text(
                    t.yourNotices,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.careReminders),
                    subtitle: Text(t.careRemindersHint),
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
                    title: Text(t.teamNotices),
                    value:
                        preferences is Map &&
                        preferences['avisosEquipo'] == true,
                    onChanged: _saving
                        ? null
                        : (value) => _preference('avisosEquipo', value),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.inactivityTitle),
                    subtitle: Text(t.inactivityHint),
                    value: _inactivity['habilitada'] == true,
                    onChanged: _saving
                        ? null
                        : (value) => _setInactivity({'habilitada': value}),
                  ),
                  if (_inactivity['habilitada'] == true) ...[
                    Row(
                      children: [
                        Expanded(child: Text(t.inactivityAfter)),
                        DropdownButton<int>(
                          value:
                              const [
                                24,
                                48,
                                72,
                                120,
                                168,
                                336,
                                720,
                              ].contains(_inactivity['intervaloHoras'])
                              ? _inactivity['intervaloHoras'] as int
                              : 72,
                          items: [
                            for (final hours in const [
                              24,
                              48,
                              72,
                              120,
                              168,
                              336,
                              720,
                            ])
                              DropdownMenuItem(
                                value: hours,
                                child: Text(t.inactivityDays(hours ~/ 24)),
                              ),
                          ],
                          onChanged: _saving
                              ? null
                              : (hours) {
                                  if (hours != null) {
                                    _setInactivity({'intervaloHoras': hours});
                                  }
                                },
                        ),
                      ],
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.inactivityIncludeNew),
                      value: _inactivity['incluirSinPaseos'] == true,
                      onChanged: _saving
                          ? null
                          : (value) =>
                                _setInactivity({'incluirSinPaseos': value}),
                    ),
                  ],
                  const Divider(height: 32),
                  Text(
                    t.yourData,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(t.yourDataBody),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _prepareExport,
                    icon: const Icon(Icons.download_outlined),
                    label: Text(t.prepareFile),
                  ),
                  if (_export != null) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    Text(t.recordsPrepared(_records)),
                    TextButton(
                      onPressed: () => unawaited(_export?.cancel()),
                      child: Text(t.cancelExport),
                    ),
                  ],
                  if (_file != null) ...[
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) => FilledButton.icon(
                        onPressed: _saving ? null : () => _share(context),
                        icon: const Icon(Icons.save_alt),
                        label: Text(t.saveOrShareJson),
                      ),
                    ),
                  ],
                  const Divider(height: 32),
                  Text(
                    t.requestsTitle,
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
                      decoration: InputDecoration(labelText: t.requestType),
                      items: [
                        DropdownMenuItem(
                          value: 'consulta',
                          child: Text(t.reqConsulta),
                        ),
                        DropdownMenuItem(
                          value: 'acceso',
                          child: Text(t.reqAcceso),
                        ),
                        DropdownMenuItem(
                          value: 'correccion',
                          child: Text(t.reqCorreccion),
                        ),
                        DropdownMenuItem(
                          value: 'oposicion',
                          child: Text(t.reqOposicion),
                        ),
                        DropdownMenuItem(
                          value: 'bloqueo',
                          child: Text(t.reqBloqueo),
                        ),
                        DropdownMenuItem(
                          value: 'anonimizacion',
                          child: Text(t.reqAnonimizacion),
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
                      decoration: InputDecoration(
                        labelText: t.detailLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _saving ? null : _sendRequest,
                      child: Text(t.registerRequest),
                    ),
                  ] else
                    Text(
                      contact is Map
                          ? t.requestsByEmail
                          : t.requestChannelMissing,
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
                      child: Text(t.refreshRequests),
                    ),
                ],
              ],
            ),
    );
  }
}
