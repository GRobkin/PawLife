import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'pawlife_repository.dart';
import 'push_service.dart';
import 'local_reminder_service.dart';

/// Mantiene el perfil y el dispositivo asociados a una sola sesion.
class SessionRegistration {
  SessionRegistration({
    PushService Function()? pushFactory,
    ApiClient Function(String uid)? clientFactory,
    LocalReminderService? reminders,
  }) : _pushFactory = pushFactory ?? (() => PushService()),
       _clientFactory = clientFactory ?? ((uid) => ApiClient(expectedUid: uid)),
       _reminders = reminders ?? LocalReminderService.instance;

  final PushService Function() _pushFactory;
  final ApiClient Function(String uid) _clientFactory;
  final LocalReminderService _reminders;
  StreamSubscription<String>? _tokens;
  StreamSubscription<RemoteMessage>? _messages;
  StreamSubscription<RemoteMessage>? _opened;
  Timer? _retry;
  ApiClient? _client;
  int _generation = 0;
  String? _lastToken;
  bool _initialMessageConsumed = false;

  Future<void> refreshReminders() async {
    final client = _client;
    if (client == null) return;
    await _reminders.syncBestEffort(PawLifeRepository(client: client));
  }

  void start(User? user) {
    dispose();
    if (user == null) return;
    final generation = _generation;
    final client = _clientFactory(user.uid);
    _client = client;
    final repository = PawLifeRepository(client: client);
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    final push = mobile ? _pushFactory() : null;
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
        if (generation != _generation) return;
        await _reminders.syncBestEffort(repository);
        if (generation != _generation || push == null) return;
        if (!_initialMessageConsumed) {
          _initialMessageConsumed = true;
          final initialMessage = await push.getInitialMessage();
          if (generation != _generation) return;
          if (initialMessage != null) {
            // Solo refrescar datos de la sesión actual mediante su API; no abrir
            // recursos ni mostrar contenido privado del payload de una sesión anterior.
            await refreshReminders();
          }
        }
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
      Future<void> displayIncoming(RemoteMessage message) async {
        try {
          final privacy = await repository.fetchPrivacy();
          if (generation != _generation) return;
          final preferences = privacy['preferencias'];
          final key = message.data['tipo'] == 'manual'
              ? 'avisosEquipo'
              : 'recordatoriosCuidados';
          if (preferences is! Map<String, dynamic> || preferences[key] != true) {
            return;
          }
          await _reminders.showIncoming(
            reminderId:
                message.data['recordatorioId'] ?? message.messageId ?? '',
            title: message.notification?.title ?? 'PawLife',
            body: message.notification?.body ?? 'Tenes un cuidado pendiente.',
          );
        } catch (_) {
          /* No mostrar contenido privado si no se pudo comprobar la sesión/preferencia. */
        }
      }

      _messages = push.onMessage.listen((message) {
        if (generation != _generation) return;
        unawaited(displayIncoming(message));
      });
      _opened = push.onMessageOpenedApp.listen((_) {
        if (generation == _generation) {
          unawaited(refreshReminders().catchError((Object _) {}));
        }
      });
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
    unawaited(_reminders.clear().catchError((Object _) {}));
    _tokens?.cancel();
    _tokens = null;
    _messages?.cancel();
    _messages = null;
    _opened?.cancel();
    _opened = null;
    _retry?.cancel();
    _retry = null;
    _client?.close();
    _client = null;
    _lastToken = null;
  }
}
