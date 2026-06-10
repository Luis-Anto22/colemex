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

    final res = await _client.get(
      '/common/profesionales-cercanos',
      params: params,
    );

    if (res['success'] != true) {
      throw Exception(
        res['message'] ??
            res['mensaje'] ??
            'Error al obtener profesionales cercanos',
      );
    }

    final data = res['data'] ?? res['profesionales'] ?? res['items'];

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);

          final latValue = map['lat'] ??
              map['latitude'] ??
              map['latitud'] ??
              map['ubicacion_lat'];

          final lngValue = map['lng'] ??
              map['longitude'] ??
              map['longitud'] ??
              map['ubicacion_lng'];

          map['lat'] = latValue;
          map['lng'] = lngValue;
          map['latitude'] = latValue;
          map['longitude'] = lngValue;

          return map;
        })
        .where((p) {
          final pLat = double.tryParse(p['lat']?.toString() ?? '');
          final pLng = double.tryParse(p['lng']?.toString() ?? '');
          return pLat != null && pLng != null;
        })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getMisCasos({
    required int clienteId,
    int limit = 10,
  }) async {
    final res = await _client.get(
      '/common/mis-casos-cliente',
      params: {
        'cliente_id': clienteId,
        'limit': limit,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? res['mensaje'] ?? 'Error al obtener mis casos');
    }

    final data = res['data'] ?? res['casos'];

    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }
  Future<List<Map<String, dynamic>>> getHistorialCasosCliente({
  required int clienteId,
  int limit = 100,
}) async {
  final res = await _client.get(
    '/common/historial-casos-cliente',
    params: {
      'cliente_id': clienteId,
      'limit': limit,
    },
  );

  if (res['success'] != true) {
    throw Exception(
      res['message'] ??
          res['mensaje'] ??
          'Error al obtener historial de casos',
    );
  }

  final data = res['data'] ?? res['casos'];

  if (data is List) {
    return List<Map<String, dynamic>>.from(data);
  }

  return [];
}
  Future<List<Map<String, dynamic>>> getCasosArchivados({
  required int clienteId,
  int limit = 50,
}) async {
  final res = await _client.get(
    '/common/casos-cliente-archivados',
    params: {
      'cliente_id': clienteId,
      'limit': limit,
    },
  );

  if (res['success'] != true) {
    throw Exception(
      res['message'] ?? res['mensaje'] ?? 'Error al obtener casos archivados',
    );
  }

  final data = res['data'] ?? res['casos'];

  if (data is List) {
    return List<Map<String, dynamic>>.from(data);
  }

  return [];
}
Future<Map<String, dynamic>> desarchivarCaso({
  required int casoId,
  required int clienteId,
}) async {
  final res = await _client.post(
    '/common/casos-cliente/$casoId/desarchivar',
    {
      'cliente_id': clienteId,
    },
  );

  if (res['success'] != true) {
    throw Exception(
      res['message'] ??
      res['mensaje'] ??
      'Error al desarchivar caso',
    );
  }

  return res;
}
Future<Map<String, dynamic>> getConteoCasos({
  required int clienteId,
}) async {
  final res = await _client.get(
    '/common/casos-cliente-conteo',
    params: {
      'cliente_id': clienteId,
    },
  );

  if (res['success'] != true) {
    throw Exception(
      res['message'] ??
      res['mensaje'] ??
      'Error al obtener conteo de casos',
    );
  }

  return Map<String, dynamic>.from(
    res['data'] ?? {},
  );
}

  Future<Map<String, dynamic>> solicitarCaso({
    required int clienteId,
    required int profesionalId,
    required String servicio,
    required String titulo,
    String descripcion = '',
  }) async {
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
      throw Exception(res['message'] ?? res['mensaje'] ?? 'Error al enviar solicitud');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return {
        ...data,
        'message': res['message']?.toString() ??
            res['mensaje']?.toString() ??
            'Solicitud enviada',
      };
    }

    return {
      'message': res['message']?.toString() ??
          res['mensaje']?.toString() ??
          'Solicitud enviada',
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

    final res = await _client.get(
      '/common/especialidades',
      params: params,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? res['mensaje'] ?? 'Error al obtener especialidades');
    }

    final data = res['data'] ?? res['especialidades'];

    if (data is! List) return [];

    final nombres = <String>[];

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final nombre = (item['nombre'] ?? '').toString().trim();
        if (nombre.isNotEmpty) nombres.add(nombre);
      } else {
        final nombre = item.toString().trim();
        if (nombre.isNotEmpty) nombres.add(nombre);
      }
    }

    return nombres;
  }
}