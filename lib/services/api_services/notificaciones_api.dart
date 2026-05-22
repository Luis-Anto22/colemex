import 'api_client.dart';

class NotificacionesApi {
  final ApiClient client;

  NotificacionesApi(this.client);

  Future<List<Map<String, dynamic>>> listar({
    int? profesionalId,
    int? clienteId,
    int limit = 50,
    bool soloNoLeidas = false,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'solo_no_leidas': soloNoLeidas ? 1 : 0,
    };

    if (profesionalId != null && profesionalId > 0) {
      params['profesional_id'] = profesionalId;
    }

    if (clienteId != null && clienteId > 0) {
      params['cliente_id'] = clienteId;
    }

    final res = await client.get('/notificaciones', params: params);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener notificaciones');
    }

    final data = res['data'] ?? res['notificaciones'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }

  Future<int> countNoLeidas({
    int? profesionalId,
    int? clienteId,
  }) async {
    final params = <String, dynamic>{};

    if (profesionalId != null && profesionalId > 0) {
      params['profesional_id'] = profesionalId;
    }

    if (clienteId != null && clienteId > 0) {
      params['cliente_id'] = clienteId;
    }

    final res = await client.get('/notificaciones/count', params: params);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener conteo');
    }

    final raw = res['unread_count'];
    if (raw is num) return raw.toInt();

    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  Future<void> marcarLeida({
    required int notificacionId,
    int? profesionalId,
    int? clienteId,
  }) async {
    final body = <String, dynamic>{};

    if (profesionalId != null && profesionalId > 0) {
      body['profesional_id'] = profesionalId;
    }

    if (clienteId != null && clienteId > 0) {
      body['cliente_id'] = clienteId;
    }

    final res = await client.post(
      '/notificaciones/$notificacionId/leer',
      body,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'No se pudo marcar como leida');
    }
  }

  Future<void> marcarTodasLeidas({
    int? profesionalId,
    int? clienteId,
  }) async {
    final body = <String, dynamic>{};

    if (profesionalId != null && profesionalId > 0) {
      body['profesional_id'] = profesionalId;
    }

    if (clienteId != null && clienteId > 0) {
      body['cliente_id'] = clienteId;
    }

    final res = await client.post(
      '/notificaciones/leer-todas',
      body,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'No se pudo marcar todo como leido');
    }
  }
}