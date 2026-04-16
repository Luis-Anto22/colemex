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
      throw Exception(res['message'] ?? 'Error al obtener configuración');
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
      throw Exception(res['message'] ?? 'Error al guardar configuración');
    }
  }

  // ==============================
  // UBICACION
  // ==============================

  Future<Map<String, dynamic>> getUbicacion(int profesionalId) async {
    final res = await client.get(
      '/common/ubicacion.php',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener ubicación');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  Future<void> actualizarUbicacion({
    required int profesionalId,
    required double latitude,
    required double longitude,
  }) async {
    final res = await client.post(
      '/common/ubicacion.php',
      {
        'profesional_id': '$profesionalId',
        'latitude': '$latitude',
        'longitude': '$longitude',
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al guardar ubicación');
    }
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
      "items": [],
      "promedio": 0,
      "total": 0,
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
      throw Exception(res['message'] ?? 'Error al crear calificación');
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