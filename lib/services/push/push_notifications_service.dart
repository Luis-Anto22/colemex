import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_services/api_client.dart';
import '../api_services/fcm_token_api.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationsService {
  PushNotificationsService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _inicializado = false;

  static Future<void> init() async {
    if (_inicializado) return;

    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _pedirPermisos();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(' PUSH EN FOREGROUND');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(' PUSH ABIERTA POR EL USUARIO');
      debugPrint('Data: ${message.data}');
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _guardarTokenEnBackend(token);
    });

    _inicializado = true;
  }

  static Future<void> _pedirPermisos() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static Future<void> guardarTokenActual() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Si ya estaba inicializado, no pasa nada.
    }

    final token = await _messaging.getToken();

    debugPrint('FCM TOKEN ACTUAL: $token');

    if (token == null || token.trim().isEmpty) return;

    await _guardarTokenEnBackend(token);
  }

  static Future<void> _guardarTokenEnBackend(String token) async {
    final prefs = await SharedPreferences.getInstance();

    final usuarioId = prefs.getInt('id') ?? 0;
    final tipoLogin = prefs.getString('tipo_login') ?? '';

    if (usuarioId <= 0) {
      debugPrint('FCM: no se guardó token porque usuarioId viene vacío.');
      return;
    }

    if (tipoLogin != 'cliente' && tipoLogin != 'profesional') {
      debugPrint('FCM: tipo_login inválido: $tipoLogin');
      return;
    }

    final plataforma = _plataformaActual();

    try {
      final api = FcmTokenApi(ApiClient());

      await api.guardar(
        tipoUsuario: tipoLogin,
        usuarioId: usuarioId,
        fcmToken: token,
        plataforma: plataforma,
      );

      debugPrint('FCM: token guardado correctamente para $tipoLogin $usuarioId');
    } catch (e) {
      debugPrint('FCM: error guardando token en backend: $e');
    }
  }

  static String _plataformaActual() {
    if (kIsWeb) return 'web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }
}