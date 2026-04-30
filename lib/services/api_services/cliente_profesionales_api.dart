import 'api_client.dart';

class ClienteProfesionalesApi {
  final ApiClient _client;

  ClienteProfesionalesApi([ApiClient? client]) : _client = client ?? ApiClient();

  Future<List<Map<String, dynamic>>> getProfesionalesCercanos({
    String? perfil,
    String? especialidad,
    required double lat,
    required double lng,
    int limit = 50,
  }) async {
    final params = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'limit': limit,
    };

    if (perfil != null && perfil.trim().isNotEmpty) {
      params['perfil'] = perfil.trim();
    }

    if (especialidad != null && especialidad.trim().isNotEmpty) {
      params['especialidad'] = especialidad.trim();
    }

    // Laravel: GET /api/common/profesionales-cercanos
    final res = await _client.get(
      '/common/profesionales-cercanos',
      params: params,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener profesionales');
    }

    final data = res['data'] ?? res['profesionales'];

    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getMisCasos({
    required int clienteId,
    int limit = 10,
  }) async {
    // Laravel: GET /api/common/mis-casos-cliente
    final res = await _client.get(
      '/common/mis-casos-cliente',
      params: {
        'cliente_id': clienteId,
        'limit': limit,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener mis casos');
    }

    final data = res['data'] ?? res['casos'];

    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }

  Future<Map<String, dynamic>> solicitarCaso({
    required int clienteId,
    required int profesionalId,
    required String servicio,
    required String titulo,
    String descripcion = '',
  }) async {
    // Laravel: POST /api/common/solicitar-caso-cliente
    final res = await _client.post(
      '/common/solicitar-caso-cliente',
      {
        'cliente_id': clienteId,
        'profesional_id': profesionalId,
        'servicio': servicio,
        'titulo': titulo,
        'descripcion': descripcion,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al enviar solicitud');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return {
        ...data,
        'message': res['message']?.toString() ?? 'Solicitud enviada',
      };
    }

    return {
      'message': res['message']?.toString() ?? 'Solicitud enviada',
    };
  }

  Future<List<String>> getEspecialidades({
    String? query,
    int limit = 100,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
    };

    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }

    // Laravel: GET /api/common/especialidades
    final res = await _client.get(
      '/common/especialidades',
      params: params,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener especialidades');
    }

    final data = res['data'] ?? res['especialidades'];

    if (data is! List) return [];

    final nombres = <String>[];

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final nombre = (item['nombre'] ?? '').toString().trim();
        if (nombre.isNotEmpty) {
          nombres.add(nombre);
        }
      } else {
        final nombre = item.toString().trim();
        if (nombre.isNotEmpty) {
          nombres.add(nombre);
        }
      }
    }

    return nombres;
  }
}
