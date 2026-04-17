import 'dart:io';

import 'api_client.dart';

class CommonApi {
  final ApiClient client;

  CommonApi(this.client);

  // ==============================
  // PERFIL
  // ==============================

  Future<Map<String, dynamic>> getPerfil(int profesionalId) async {
    final res = await client.get(
      '/common/perfil.php',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener perfil');
    }

    final data = res['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  // ==============================
  // AGENDA
  // ==============================

  Future<List<dynamic>> getAgenda(int profesionalId) async {
    final res = await client.get(
      '/common/agenda.php',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener agenda');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<void> crearAgenda({
    required int profesionalId,
    required int clienteId,
    required String inicio,
  }) async {
    final res = await client.post(
      '/common/agenda.php',
      {
        'profesional_id': '$profesionalId',
        'cliente_id': '$clienteId',
        'inicio': inicio,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear cita');
    }
  }

  // ==============================
  // HISTORIAL
  // ==============================

  Future<List<dynamic>> getHistorial({
    required int profesionalId,
    required String perfil,
  }) async {
    final res = await client.get(
      '/common/historial.php',
      params: {
        'profesional_id': profesionalId,
        'perfil': perfil,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener historial');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  // ==============================
  // CONFIGURACION
  // ==============================

  Future<Map<String, dynamic>> getConfiguracion(int profesionalId) async {
    final res = await client.get(
      '/common/configuracion.php',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener configuracion');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  Future<void> actualizarConfiguracion({
    required int profesionalId,
    required bool notificaciones,
    required bool compartirUbicacion,
  }) async {
    final res = await client.post(
      '/common/configuracion.php',
      {
        'profesional_id': '$profesionalId',
        'notificaciones': notificaciones ? '1' : '0',
        'compartir_ubicacion': compartirUbicacion ? '1' : '0',
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al guardar configuracion');
    }
  }

  // ==============================
  // UBICACION
  // ==============================
  // Consumido por:
  // - lib/screens/universal_location_button.dart
  // - lib/screens/common/ubicacion/ubicacion_tiempo_real_screen.dart
  // - lib/screens/abogados/ubicacion_despacho_screen.dart

  Future<Map<String, dynamic>> getUbicacion(int profesionalId) async {
    try {
      // Ruta legacy compartida por varias pantallas del app Flutter.
      final res = await client.get(
        '/common/ubicacion.php',
        params: {'profesional_id': profesionalId},
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al obtener ubicacion');
      }

      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } catch (e) {
      // Fallback para entornos donde /common/ubicacion.php no existe aun.
      if (_es404(e)) {
        return _getUbicacionDesdeAdmin(profesionalId);
      }
      rethrow;
    }
  }

  Future<void> actualizarUbicacion({
    required int profesionalId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Flujo principal usado por el boton universal y mapas de ubicacion.
      final res = await client.post(
        '/common/ubicacion.php',
        {
          'profesional_id': '$profesionalId',
          'latitude': '$latitude',
          'longitude': '$longitude',
        },
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al guardar ubicacion');
      }
      return;
    } catch (e) {
      // Si la ruta legacy responde 404, actualizamos por API REST de admin.
      if (_es404(e)) {
        await _actualizarUbicacionEnAdmin(
          profesionalId: profesionalId,
          latitude: latitude,
          longitude: longitude,
        );
        return;
      }
      rethrow;
    }
  }

  bool _es404(Object error) =>
      error.toString().toLowerCase().contains('http 404');

  Future<Map<String, dynamic>> _getUbicacionDesdeAdmin(
      int profesionalId) async {
    final perfil = await _obtenerPerfilAdmin(profesionalId);
    return {
      'profesional_id': profesionalId,
      'latitude': _asDouble(perfil['latitud']),
      'longitude': _asDouble(perfil['longitud']),
    };
  }

  Future<void> _actualizarUbicacionEnAdmin({
    required int profesionalId,
    required double latitude,
    required double longitude,
  }) async {
    // Este fallback conecta con el backend Laravel (routes/api.php):
    // GET /admin/profesionales + PUT /admin/profesionales/{id}.
    final perfil = await _obtenerPerfilAdmin(profesionalId);
    final payload = _buildPayloadAdmin(
      perfil: perfil,
      latitude: latitude,
      longitude: longitude,
    );

    final res =
        await client.put('/admin/profesionales/$profesionalId', payload);
    if (res['success'] != true) {
      throw Exception(
        res['mensaje'] ?? res['message'] ?? 'Error al guardar ubicacion',
      );
    }
  }

  Future<Map<String, dynamic>> _obtenerPerfilAdmin(int profesionalId) async {
    final res = await client.get('/admin/profesionales');
    final items = res['profesionales'];
    if (items is! List) {
      throw Exception('Formato inesperado al consultar profesionales');
    }

    for (final item in items) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final id = int.tryParse('${map['id'] ?? ''}');
      if (id == profesionalId) {
        return map;
      }
    }

    throw Exception('Profesional no encontrado en /admin/profesionales');
  }

  // Reconstruye el payload completo requerido por el update de admin.
  Map<String, dynamic> _buildPayloadAdmin({
    required Map<String, dynamic> perfil,
    required double latitude,
    required double longitude,
  }) {
    final nombre = (perfil['nombre'] ?? '').toString().trim();
    final tipoPerfil = (perfil['perfil'] ?? '').toString().trim();

    if (nombre.isEmpty || tipoPerfil.isEmpty) {
      throw Exception('No se pudo armar payload admin para guardar ubicacion');
    }

    final payload = <String, dynamic>{
      'nombre': nombre,
      'perfil': tipoPerfil,
      'latitud': '$latitude',
      'longitud': '$longitude',
    };

    // Campos opcionales incluidos para no perder informacion en update().
    _putIfPresent(payload, 'correo', perfil['correo']);
    _putIfPresent(payload, 'telefono', perfil['telefono']);
    _putIfPresent(payload, 'especialidad_id', perfil['especialidad_id']);
    _putIfPresent(payload, 'ciudad', perfil['ciudad']);
    _putIfPresent(payload, 'foto', perfil['foto']);
    _putIfPresent(payload, 'verificado', perfil['verificado']);
    _putIfPresent(payload, 'estado', perfil['estado']);

    return payload;
  }

  void _putIfPresent(
    Map<String, dynamic> target,
    String key,
    dynamic value,
  ) {
    if (value == null) return;
    final text = value.toString().trim();
    if (text.isEmpty) return;
    target[key] = value;
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  // ==============================
  // INGRESOS
  // ==============================

  Future<Map<String, dynamic>> getIngresos(int profesionalId) async {
    final res = await client.get(
      '/common/ingresos.php',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener ingresos');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  // ==============================
  // CLIENTES
  // ==============================

  Future<List<dynamic>> getClientes() async {
    final res = await client.get('/common/clientes.php');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener clientes');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  // ==============================
  // CALIFICACIONES
  // ==============================

  Future<Map<String, dynamic>> getCalificaciones(int profesionalId) async {
    final res = await client.get(
      '/common/calificaciones.php',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener calificaciones');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {
      'items': [],
      'promedio': 0,
      'total': 0,
    };
  }

  Future<void> crearCalificacion({
    required int profesionalId,
    required int clienteId,
    required int estrellas,
    String comentario = '',
  }) async {
    final res = await client.post(
      '/common/calificaciones.php',
      {
        'profesional_id': '$profesionalId',
        'cliente_id': '$clienteId',
        'estrellas': '$estrellas',
        'comentario': comentario,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear calificacion');
    }
  }

  // ==============================
  // DOCUMENTOS PERFIL
  // ==============================

  Future<void> subirDocumentoPerfil({
    required int profesionalId,
    required String tipo,
    required File file,
    String? comentarios,
  }) async {
    final res = await client.postMultipart(
      '/common/perfil_documentos.php',
      fields: {
        'profesional_id': '$profesionalId',
        'tipo': tipo,
        if (comentarios != null && comentarios.isNotEmpty)
          'comentarios': comentarios,
      },
      file: file,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al subir documento');
    }
  }
}
