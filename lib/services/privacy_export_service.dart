import 'dart:convert';
import 'dart:typed_data';

import 'auth_service.dart';
import 'pawlife_repository.dart';

class PrivacyExportException implements Exception {
  const PrivacyExportException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PrivacyExportService {
  PrivacyExportService({
    required this.repository,
    required this.auth,
    required this.uid,
  });
  final PawLifeRepository repository;
  final AuthService auth;
  final String uid;
  bool _cancelled = false;
  String? _session;

  void _check() {
    if (_cancelled) {
      throw const PrivacyExportException('Exportación cancelada.');
    }
    if (auth.currentUser?.uid != uid) {
      throw const PrivacyExportException(
        'La sesión cambió. No se preparó el archivo.',
      );
    }
  }

  Future<void> cancel() async {
    _cancelled = true;
    final id = _session;
    if (id != null && auth.currentUser?.uid == uid) {
      try {
        await repository.cancelExport(id);
      } catch (_) {
        /* La sesión vence también en el servidor. */
      }
    }
  }

  Future<Uint8List> prepare({void Function(int records)? onProgress}) async {
    _check();
    final buffer = BytesBuilder(copy: false);
    void append(String text) {
      final bytes = utf8.encode(text);
      if (buffer.length + bytes.length > 64 * 1024 * 1024) {
        throw const PrivacyExportException(
          'El archivo necesita asistencia por su tamaño.',
        );
      }
      buffer.add(bytes);
    }

    try {
      final session = await repository.startExport();
      final id = session['id'];
      final initial = session['cursor'];
      if (id is! String ||
          id.isEmpty ||
          initial is! String ||
          initial.isEmpty ||
          session['manifest'] is! Map<String, dynamic>) {
        throw const PrivacyExportException(
          'No se pudo iniciar una exportación válida.',
        );
      }
      _session = id;
      _check();
      append('{"manifest":${jsonEncode(session['manifest'])},"datos":[');
      String? cursor = initial;
      final seen = <String>{};
      var count = 0;
      for (var page = 0; page < 3000 && cursor != null; page++) {
        _check();
        if (!seen.add(cursor)) {
          throw const PrivacyExportException(
            'La exportación devolvió un cursor repetido.',
          );
        }
        final response = await repository.exportPage(id, cursor);
        _check();
        final items = response['items'];
        if (items is! List ||
            items.any((item) => item is! Map<String, dynamic>)) {
          throw const PrivacyExportException(
            'La exportación devolvió una página inválida.',
          );
        }
        for (final item in items) {
          append('${count == 0 ? '' : ','}${jsonEncode(item)}');
          count++;
        }
        onProgress?.call(count);
        final next = response['nextCursor'];
        if (next != null && (next is! String || next.isEmpty)) {
          throw const PrivacyExportException(
            'La exportación devolvió un cursor inválido.',
          );
        }
        cursor = next as String?;
        if (cursor == null) {
          if (response['finalizadoEn'] is! String) {
            throw const PrivacyExportException(
              'No se confirmó el final de la exportación.',
            );
          }
          append(
            '],"finalizadoEn":${jsonEncode(response['finalizadoEn'])},"registros":$count}',
          );
          _check();
          return buffer.takeBytes();
        }
      }
      throw const PrivacyExportException(
        'No se completó la exportación. Iniciá otra.',
      );
    } catch (_) {
      await cancel();
      rethrow;
    }
  }
}
