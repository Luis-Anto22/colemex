import 'api_client.dart';

class FcmTokenApi {
  final ApiClient client;

  FcmTokenApi(this.client);

  Future<void> guardar({
    required String tipoUsuario,
    required int usuarioId,
    required String fcmToken,
    String plataforma = 'android',
  }) async {
    final res = await client.post(
      '/common/fcm-token',
      {
        'tipo_usuario': tipoUsuario,
        'usuario_id': usuarioId,
        'fcm_token': fcmToken,
        'plataforma': plataforma,
      },
    );

    if (res['success'] != true) {
      throw Exception(
        res['mensaje'] ??
            res['message'] ??
            'No se pudo guardar el token FCM',
      );
    }
  }

  Future<void> eliminar({
    required String tipoUsuario,
    required int usuarioId,
  }) async {
    final res = await client.post(
      '/common/fcm-token/eliminar',
      {
        'tipo_usuario': tipoUsuario,
        'usuario_id': usuarioId,
      },
    );

    if (res['success'] != true) {
      throw Exception(
        res['mensaje'] ??
            res['message'] ??
            'No se pudo eliminar el token FCM',
      );
    }
  }

  Future<bool> consultar({
    required String tipoUsuario,
    required int usuarioId,
  }) async {
    final res = await client.get(
      '/common/fcm-token',
      params: {
        'tipo_usuario': tipoUsuario,
        'usuario_id': usuarioId,
      },
    );

    if (res['success'] != true) {
      throw Exception(
        res['mensaje'] ??
            res['message'] ??
            'No se pudo consultar el token FCM',
      );
    }

    final value = res['tiene_fcm_token'];
    if (value is bool) return value;
    if (value is num) return value.toInt() == 1;

    return value.toString().toLowerCase() == 'true' ||
        value.toString() == '1';
  }
}