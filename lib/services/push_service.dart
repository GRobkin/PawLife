import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushService {
  PushService({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<void> revokeToken() => _messaging.deleteToken();

  Future<String?> init() async {
    try {
      final settings = await _messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('FCM: permiso de notificaciones denegado');
        return null;
      }

      final token = await _messaging.getToken();

      return token;
    } catch (e) {
      debugPrint('FCM ERROR: $e');
      return null;
    }
  }
}
