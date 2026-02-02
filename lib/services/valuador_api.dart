import 'dart:io';

import 'api_client.dart';

class ValuadorApi {
  final ApiClient client;
  ValuadorApi(this.client);

  // SOLICITUDES (casos pendientes)
  Future<List<dynamic>> getSolicitudes(int valuadorId) async {
    final res = await client.get(
      '/valuador/solicitudes.php',
      params: {'valuador_id': valuadorId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener solicitudes');
    }
    return (res['data'] as List<dynamic>? ?? []);
  }

  Future<void> actualizarEstadoSolicitud({
    required int id,
    required String estado,
  }) async {
    final res = await client.post('/valuador/solicitudes.php', {
      'action': 'update_estado',
      'id': '$id',
      'estado': estado,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar solicitud');
    }
  }

  // AVALÚOS
  Future<List<dynamic>> getAvaluos(int valuadorId) async {
    final res = await client.get(
      '/valuador/avaluos.php',
      params: {'valuador_id': valuadorId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener avalúos');
    }
    return (res['data'] as List<dynamic>? ?? []);
  }

  Future<void> guardarAvaluo({
    required int valuadorId,
    required int casoId,
    required String estado,
    double? valorEstimado,
    String? notas,
  }) async {
    final res = await client.post('/valuador/avaluos.php', {
      'action': 'save',
      'valuador_id': '$valuadorId',
      'caso_id': '$casoId',
      'estado': estado,
      'valor_estimado': valorEstimado?.toString() ?? '',
      'notas': notas ?? '',
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al guardar avalúo');
    }
  }

  // REPORTES
  Future<List<dynamic>> getReportes(int casoId) async {
    final res = await client.get(
      '/valuador/reportes.php',
      params: {'caso_id': casoId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener reportes');
    }
    return (res['data'] as List<dynamic>? ?? []);
  }

  Future<void> subirReporte({
    required int casoId,
    required int valuadorId,
    required File file,
    String? descripcion,
  }) async {
    final res = await client.postMultipart(
      '/valuador/reportes.php',
      fields: {
        'caso_id': '$casoId',
        'profesional_id': '$valuadorId',
        'descripcion': descripcion ?? '',
      },
      file: file,
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al subir reporte');
    }
  }

  // FOTOS
  Future<List<dynamic>> getFotos(int casoId) async {
    final res = await client.get(
      '/valuador/fotos.php',
      params: {'caso_id': casoId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener fotos');
    }
    return (res['data'] as List<dynamic>? ?? []);
  }

  Future<void> subirFoto({
    required int casoId,
    required int valuadorId,
    required File file,
    String? descripcion,
  }) async {
    final res = await client.postMultipart(
      '/valuador/fotos.php',
      fields: {
        'caso_id': '$casoId',
        'profesional_id': '$valuadorId',
        'descripcion': descripcion ?? '',
      },
      file: file,
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al subir foto');
    }
  }
}
