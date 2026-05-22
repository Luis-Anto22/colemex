import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceProfesionales {
  static const String baseUrl = 'https://corporativolegaldigital.com/api/admin';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static dynamic _decodeResponse(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (_) {
      throw Exception('Respuesta inválida del servidor: ${response.body}');
    }
  }

  static String _extraerMensaje(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      return data['mensaje']?.toString() ?? fallback;
    }
    return fallback;
  }

  static void _validarRespuesta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final data = _decodeResponse(response);
    final mensaje = _extraerMensaje(
      data,
      'Error del servidor: ${response.statusCode}',
    );

    throw Exception(mensaje);
  }

  // ============================================================
  // ESTADÍSTICAS ADMIN
  // ============================================================

  /// Obtener estadísticas generales del panel admin.
  ///
  /// GET /api/admin/estadisticas
  static Future<Map<String, dynamic>> obtenerEstadisticasAdmin() async {
    final response = await http.get(
      Uri.parse('$baseUrl/estadisticas'),
      headers: _headers,
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data['success'] == true) {
      return Map<String, dynamic>.from(data['data'] ?? {});
    }

    throw Exception(data['mensaje'] ?? 'Error al obtener estadísticas');
  }

  // ============================================================
  // PROFESIONALES ADMIN
  // ============================================================

  /// Obtener listado de profesionales.
  ///
  /// GET /api/admin/profesionales
  static Future<List<dynamic>> obtenerProfesionales({
    String buscar = '',
    String perfil = '',
    String estado = '',
  }) async {
    final uri = Uri.parse('$baseUrl/profesionales').replace(
      queryParameters: {
        if (buscar.trim().isNotEmpty) 'buscar': buscar.trim(),
        if (perfil.trim().isNotEmpty && perfil != 'Todos') 'perfil': perfil,
        if (estado.trim().isNotEmpty && estado != 'Todos') 'estado': estado,
      },
    );

    final response = await http.get(uri, headers: _headers);
    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data['success'] == true) {
      return data['profesionales'] ?? data['data'] ?? [];
    }

    throw Exception(data['mensaje'] ?? 'Error al obtener profesionales');
  }

  /// Obtener detalle de profesional.
  ///
  /// GET /api/admin/profesionales/{id}
  static Future<Map<String, dynamic>> obtenerDetalleProfesional(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profesionales/$id'),
      headers: _headers,
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data['success'] == true) {
      return Map<String, dynamic>.from(data['profesional'] ?? data['data']);
    }

    throw Exception(data['mensaje'] ?? 'Error al obtener detalle');
  }

  /// Crear profesional.
  ///
  /// POST /api/admin/profesionales
  static Future<String> crearProfesional(
    Map<String, dynamic> profesional,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profesionales'),
      headers: _headers,
      body: json.encode(profesional),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data['success'] == true) {
      return data['mensaje'] ?? 'Profesional creado correctamente';
    }

    throw Exception(data['mensaje'] ?? 'Error al crear profesional');
  }

  /// Editar profesional.
  ///
  /// PUT /api/admin/profesionales/{id}
  static Future<String> editarProfesional(
    int id,
    Map<String, dynamic> profesional,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profesionales/$id'),
      headers: _headers,
      body: json.encode(profesional),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data['success'] == true) {
      return data['mensaje'] ?? 'Profesional actualizado correctamente';
    }

    throw Exception(data['mensaje'] ?? 'Error al editar profesional');
  }

  /// Eliminar profesional.
  ///
  /// DELETE /api/admin/profesionales/{id}
  static Future<String> eliminarProfesional(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/profesionales/$id'),
      headers: _headers,
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data['success'] == true) {
      return data['mensaje'] ?? 'Profesional eliminado correctamente';
    }

    throw Exception(data['mensaje'] ?? 'Error al eliminar profesional');
  }

  /// Obtener especialidades para abogados.
  ///
  /// GET /api/admin/especialidades
  static Future<List<dynamic>> obtenerEspecialidades() async {
    final response = await http.get(
      Uri.parse('$baseUrl/especialidades'),
      headers: _headers,
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data['success'] == true) {
      return data['especialidades'] ?? data['data'] ?? [];
    }

    throw Exception(data['mensaje'] ?? 'Error al obtener especialidades');
  }

  // ============================================================
  // NOTIFICACIONES ADMIN PUSH
  // ============================================================

  /// Obtener historial de notificaciones admin.
  ///
  /// GET /api/admin/notificaciones
  static Future<List<dynamic>> obtenerNotificacionesAdmin({
    String buscar = '',
    String destinatario = '',
  }) async {
    final uri = Uri.parse('$baseUrl/notificaciones').replace(
      queryParameters: {
        if (buscar.trim().isNotEmpty) 'buscar': buscar.trim(),
        if (destinatario.trim().isNotEmpty && destinatario != 'Todos')
          'destinatario': destinatario,
      },
    );

    final response = await http.get(uri, headers: _headers);
    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data['success'] == true) {
      return data['data'] ?? [];
    }

    throw Exception(data['mensaje'] ?? 'Error al obtener notificaciones');
  }

  /// Enviar push desde panel admin.
  ///
  /// POST /api/admin/notificaciones/enviar
  static Future<Map<String, dynamic>> enviarNotificacionAdmin({
    required String titulo,
    required String mensaje,
    required String destinatario,
    String? perfil,
  }) async {
    final body = {
      'titulo': titulo,
      'mensaje': mensaje,
      'destinatario': destinatario,
      if (perfil != null && perfil.trim().isNotEmpty && perfil != 'Todos')
        'perfil': perfil.trim(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/notificaciones/enviar'),
      headers: _headers,
      body: json.encode(body),
    );

    final data = _decodeResponse(response);

    // Cuando no hay tokens, Laravel responde 422 con success false,
    // pero sí guarda historial. Por eso aquí NO tronamos automáticamente.
    if (response.statusCode == 200 || response.statusCode == 422) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data['mensaje'] ?? 'Error al enviar notificación: ${response.statusCode}',
    );
  }
}