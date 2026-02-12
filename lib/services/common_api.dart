import 'dart:io';

import 'api_client.dart';

class CommonApi {
  final ApiClient client;
  CommonApi(this.client);

  Future<Map<String, dynamic>> getPerfil(int profesionalId) async {
    final res = await client.get(
      '/common/perfil.php',
      params: {'profesional_id': profesionalId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener perfil');
    }
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Future<List<dynamic>> getAgenda(int profesionalId) async {
    final res = await client.get(
      '/common/agenda.php',
      params: {'profesional_id': profesionalId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener agenda');
    }
    final data = res['data'];
    if (data is List<dynamic>) return data;
    return [];
  }

  Future<void> crearAgenda({
    required int profesionalId,
    required int clienteId,
    required String inicio,
  }) async {
    final res = await client.post('/common/agenda.php', {
      'profesional_id': '$profesionalId',
      'cliente_id': '$clienteId',
      'inicio': inicio,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear cita');
    }
  }

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
    if (data is List<dynamic>) return data;
    return [];
  }

  Future<Map<String, dynamic>> getConfiguracion(int profesionalId) async {
    final res = await client.get(
      '/common/configuracion.php',
      params: {'profesional_id': profesionalId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener configuracion');
    }
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Future<void> actualizarConfiguracion({
    required int profesionalId,
    required bool notificaciones,
    required bool compartirUbicacion,
  }) async {
    final res = await client.post('/common/configuracion.php', {
      'profesional_id': '$profesionalId',
      'notificaciones': notificaciones ? '1' : '0',
      'compartir_ubicacion': compartirUbicacion ? '1' : '0',
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al guardar configuracion');
    }
  }

  Future<Map<String, dynamic>> getUbicacion(int profesionalId) async {
    final res = await client.get(
      '/common/ubicacion.php',
      params: {'profesional_id': profesionalId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener ubicacion');
    }
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Future<void> actualizarUbicacion({
    required int profesionalId,
    required double latitude,
    required double longitude,
  }) async {
    final res = await client.post('/common/ubicacion.php', {
      'profesional_id': '$profesionalId',
      'latitude': '$latitude',
      'longitude': '$longitude',
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al guardar ubicacion');
    }
  }

  Future<Map<String, dynamic>> getIngresos(int profesionalId) async {
    final res = await client.get(
      '/common/ingresos.php',
      params: {'profesional_id': profesionalId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener ingresos');
    }
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Future<List<dynamic>> getClientes() async {
    final res = await client.get('/common/clientes.php');
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener clientes');
    }
    final data = res['data'];
    if (data is List<dynamic>) return data;
    return [];
  }

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
