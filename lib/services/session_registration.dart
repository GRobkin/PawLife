import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'pawlife_repository.dart';
import 'push_service.dart';
import 'local_reminder_service.dart';

/// Mantiene el perfil y el dispositivo asociados a una sola sesion.
class SessionRegistration {
  StreamSubscription<String>? _tokens;
  Timer? _retry;
  ApiClient? _client;
  int _generation = 0;
  String? _lastToken;

  Future<void> refreshReminders() async {
    final client = _client;
    if (client == null) return;
    await LocalReminderService.instance.syncBestEffort(
      PawLifeRepository(client: client),
    );
  }

  void start(User? user) {
    dispose();
    if (user == null) return;
    final generation = _generation;
    final client = ApiClient(expectedUid: user.uid);
    _client = client;
    final repository = PawLifeRepository(client: client);
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    final push = mobile ? PushService() : null;
    Future<void> queue = Future.value();

    Future<void> register(String token) {
      // Serializar renovaciones evita que una respuesta antigua borre el token nuevo.
      queue = queue.catchError((Object _) {}).then((_) async {
        if (generation != _generation) return;
        await repository.registrarDispositivo(
          token: token,
          plataforma: platform,
        );
        if (generation != _generation) return;
        final previous = _lastToken;
        _lastToken = token;
        if (previous != null && previous != token) {
          await repository.eliminarDispositivo(previous);
        }
      });
      return queue;
    }

    Future<void> sync(int attempt) async {
      try {
        await repository.fetchPerfil();
        await LocalReminderService.instance.syncBestEffort(repository);
        if (generation != _generation || push == null) return;
        final token = await push.init();
        if (generation != _generation) return;
        if (token != null) await register(token);
      } catch (_) {
        debugPrint('No se pudo sincronizar el perfil o el dispositivo.');
        if (generation == _generation && attempt < 3) {
          _retry?.cancel();
          _retry = Timer(
            const Duration(seconds: 30),
            () => unawaited(sync(attempt + 1)),
          );
        }
      }
    }

    if (push != null) {
      _tokens = push.onTokenRefresh.listen(
        (token) {
          unawaited(
            register(token).catchError((Object _) {
              if (generation == _generation) {
                _retry?.cancel();
                _retry = Timer(
                  const Duration(seconds: 30),
                  () => unawaited(sync(1)),
                );
              }
            }),
          );
        },
        onError: (Object _) {
          debugPrint('No se pudo escuchar la renovacion del token.');
        },
      );
    }
    unawaited(sync(0));
  }

  void dispose() {
    _generation++;
    unawaited(LocalReminderService.instance.clear().catchError((Object _) {}));
    _tokens?.cancel();
    _tokens = null;
    _retry?.cancel();
    _retry = null;
    _client?.close();
    _client = null;
    _lastToken = null;
  }
}
