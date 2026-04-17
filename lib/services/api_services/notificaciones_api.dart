import 'api_client.dart';

class NotificacionesApi {
  final ApiClient client;

  NotificacionesApi(this.client);

  Future<List<Map<String, dynamic>>> listar({
    required int profesionalId,
    int limit = 50,
    bool soloNoLeidas = false,
  }) async {
    final res = await client.get(
      '/notificaciones',
      params: {
        'profesional_id': profesionalId,
        'limit': limit,
        'solo_no_leidas': soloNoLeidas ? 1 : 0,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener notificaciones');
    }

    final data = res['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<int> countNoLeidas({required int profesionalId}) async {
    final res = await client.get(
      '/notificaciones/count',
      params: {
        'profesional_id': profesionalId,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener conteo');
    }

    final raw = res['unread_count'];
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  Future<void> marcarLeida({
    required int notificacionId,
    required int profesionalId,
  }) async {
    final res = await client.post(
      '/notificaciones/$notificacionId/leer',
      {
        'profesional_id': '$profesionalId',
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'No se pudo marcar como leida');
    }
  }

  Future<void> marcarTodasLeidas({required int profesionalId}) async {
    final res = await client.post(
      '/notificaciones/leer-todas',
      {
        'profesional_id': '$profesionalId',
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'No se pudo marcar todo como leido');
    }
  }
}
