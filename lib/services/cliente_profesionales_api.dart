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
    if (perfil != null && perfil.isNotEmpty) params['perfil'] = perfil;
    if (especialidad != null && especialidad.isNotEmpty) {
      params['especialidad'] = especialidad;
    }

    // API: GET /common/profesionales_cercanos.php
    // Uso: panel cliente (Servicios y SOS) para buscar profesionales por ubicacion/filtros.
    final res = await _client.get(
      '/common/profesionales_cercanos.php',
      params: params,
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener profesionales');
    }

    final data = res['data'];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMisCasos({
    required int clienteId,
    int limit = 10,
  }) async {
    // API: GET /common/mis_casos_cliente.php
    // Uso: panel cliente (Inicio) para mostrar el historial "Mis casos".
    final res = await _client.get(
      '/common/mis_casos_cliente.php',
      params: {
        'cliente_id': clienteId,
        'limit': limit,
      },
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener mis casos');
    }

    final data = res['data'];
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
    // API: POST /common/solicitar_caso_cliente.php
    // Uso: panel cliente (Servicios y SOS) para crear solicitud de caso al profesional.
    final res = await _client.post(
      '/common/solicitar_caso_cliente.php',
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

    final data = (res['data'] as Map<String, dynamic>? ?? {});
    return {
      ...data,
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

    // API: GET /common/especialidades.php
    // Uso: panel cliente (Inicio y Servicios) para filtros por especialidad.
    final res = await _client.get(
      '/common/especialidades.php',
      params: params,
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener especialidades');
    }

    final data = res['data'];
    if (data is! List) return [];

    final nombres = <String>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final nombre = (item['nombre'] ?? '').toString().trim();
        if (nombre.isNotEmpty) nombres.add(nombre);
      }
    }
    return nombres;
  }
}
