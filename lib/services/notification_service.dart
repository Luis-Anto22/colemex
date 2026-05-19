import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Este handler se ejecuta cuando llega una notificación en segundo plano.
  // Firebase ya inicializa el contexto necesario para recibir el mensaje.
}

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'advocatus_channel',
    'Notificaciones Advocatus',
    description: 'Canal principal de notificaciones de Advocatus',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> init() async {
    await _crearCanalAndroid();
    await _inicializarLocalNotifications();
    await _pedirPermisos();
    await _configurarForegroundNotifications();
    await _escucharRefreshToken();
    await registrarTokenActual();
  }

  static Future<void> _crearCanalAndroid() async {
    if (!Platform.isAndroid) return;

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  static Future<void> _inicializarLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;

        if (payload == null || payload.trim().isEmpty) return;

        try {
          final data = jsonDecode(payload);
          // Aquí después podemos navegar a una pantalla específica.
          // Ejemplo: caso_id, tipo_notificacion, ruta, etc.
          // Por ahora solo dejamos listo el payload.
          data;
        } catch (_) {}
      },
    );
  }

  static Future<void> _pedirPermisos() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();
    }
  }

  static Future<void> _configurarForegroundNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await mostrarNotificacionLocal(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Aquí después podemos abrir una pantalla cuando el usuario toque la notificación.
      // Ejemplo: abrir detalle de caso, cita, evidencia, etc.
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      // Aquí después podemos manejar cuando la app estaba cerrada
      // y se abrió desde una notificación.
    }
  }

  static Future<void> _escucharRefreshToken() async {
    _firebaseMessaging.onTokenRefresh.listen((nuevoToken) async {
      await _guardarTokenEnServidor(nuevoToken);
    });
  }

  static Future<String?> obtenerToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (_) {
      return null;
    }
  }

  static Future<void> registrarTokenActual() async {
    final token = await obtenerToken();

    if (token == null || token.trim().isEmpty) {
      return;
    }

    await _guardarTokenEnServidor(token);
  }

  static Future<void> _guardarTokenEnServidor(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();

    final int usuarioId = prefs.getInt('id') ?? 0;
    final String perfil = prefs.getString('perfil') ?? '';
    final bool sesionActiva = prefs.getBool('sesion_activa') ?? false;

    if (!sesionActiva || usuarioId <= 0 || perfil.trim().isEmpty) {
      return;
    }

    final tipoUsuario = _tipoUsuarioDesdePerfil(perfil);

    if (tipoUsuario == null) {
      return;
    }

    final uri = Uri.parse('$baseUrl/common/fcm-token');

    final body = {
      'tipo_usuario': tipoUsuario,
      'usuario_id': usuarioId,
      'fcm_token': fcmToken,
      'plataforma': Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : 'otro',
    };

    final response = await http
        .post(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo guardar token FCM: ${response.statusCode} ${response.body}',
      );
    }
  }

  static String? _tipoUsuarioDesdePerfil(String perfil) {
    final p = perfil
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' ', '_');

    if (p == 'cliente' || p == 'clientes') {
      return 'cliente';
    }

    const perfilesProfesionales = {
      'abogado',
      'abogados',
      'psicologo',
      'psicologos',
      'investigador',
      'investigadores',
      'valuador',
      'valuadores',
      'agente_inmobiliario',
      'agentes_inmobiliarios',
      'contador',
      'contadores',
      'auditor',
      'auditores',
      'perito_en_criminalistica',
      'perito_criminalistica',
      'peritos_en_criminalistica',
      'peritos',
      'ajustador',
      'ajustadores',
      'agente_crediticio',
      'agentes_crediticios',
      'asistencia_vial',
    };

    if (perfilesProfesionales.contains(p)) {
      return 'profesional';
    }

    return null;
  }

  static Future<void> mostrarNotificacionLocal(RemoteMessage message) async {
    final notification = message.notification;

    final title = notification?.title ??
        message.data['title']?.toString() ??
        message.data['titulo']?.toString() ??
        'Advocatus';

    final body = notification?.body ??
        message.data['body']?.toString() ??
        message.data['mensaje']?.toString() ??
        'Tienes una nueva notificación';

    final payload = jsonEncode(message.data);

    const androidDetails = AndroidNotificationDetails(
      'advocatus_channel',
      'Notificaciones Advocatus',
      channelDescription: 'Canal principal de notificaciones de Advocatus',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> eliminarTokenDelServidor() async {
    final prefs = await SharedPreferences.getInstance();

    final int usuarioId = prefs.getInt('id') ?? 0;
    final String perfil = prefs.getString('perfil') ?? '';

    if (usuarioId <= 0 || perfil.trim().isEmpty) {
      return;
    }

    final tipoUsuario = _tipoUsuarioDesdePerfil(perfil);

    if (tipoUsuario == null) {
      return;
    }

    final uri = Uri.parse('$baseUrl/common/fcm-token/eliminar');

    await http
        .post(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'tipo_usuario': tipoUsuario,
            'usuario_id': usuarioId,
          }),
        )
        .timeout(const Duration(seconds: 20));
  }

  static Future<void> imprimirTokenEnConsola() async {
    final token = await obtenerToken();
    // Úsalo solo para pruebas.
    // ignore: avoid_print
    print('FCM TOKEN ACTUAL: $token');
  }
}