import 'package:file_picker/file_picker.dart';

import 'api_client.dart';

class InvestigadorApi {
  final ApiClient client;

  InvestigadorApi(this.client);

  // CASOS
  Future<List<dynamic>> getCasos(int investigadorId) async {
    final res = await client.get(
      '/investigador/casos',
      params: {
        'investigador_id': investigadorId,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener casos');
    }

    return (res['data'] as List<dynamic>? ?? []);
  }

  Future<void> crearCaso({
    required int investigadorId,
    int? clienteId,
    required String titulo,
    String? descripcion,
  }) async {
    final res = await client.post(
      '/investigador/casos',
      {
        'investigador_id': '$investigadorId',
        if (clienteId != null) 'cliente_id': '$clienteId',
        'titulo': titulo,
        'descripcion': descripcion ?? '',
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear caso');
    }
  }

  Future<void> actualizarEstadoCaso({
    required int id,
    required String estado,
  }) async {
    final res = await client.post(
      '/investigador/casos/estado',
      {
        'id': '$id',
        'estado': estado,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar estado');
    }
  }
  Future<void> editarCaso({
  required int id,
  int? clienteId,
  required String titulo,
  String? descripcion,
  String? estado,
}) async {
  final res = await client.post(
    '/investigador/casos/$id',
    {
      if (clienteId != null) 'cliente_id': '$clienteId',
      'titulo': titulo,
      'descripcion': descripcion ?? '',
      if (estado != null) 'estado': estado,
    },
  );

  if (res['success'] != true) {
    throw Exception(res['message'] ?? 'Error al editar caso');
  }
}

Future<void> eliminarCaso({
  required int id,
}) async {
  final res = await client.delete(
    '/investigador/casos/$id',
  );

  if (res['success'] != true) {
    throw Exception(res['message'] ?? 'Error al eliminar caso');
  }
}

  // BITÁCORA
  Future<List<dynamic>> getBitacora(int casoId) async {
    final res = await client.get(
      '/investigador/bitacora',
      params: {
        'caso_id': casoId,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener bitácora');
    }

    return (res['data'] as List<dynamic>? ?? []);
  }

  Future<void> agregarNota({
    required int casoId,
    required int profesionalId,
    required String nota,
    String? estado,
  }) async {
    final res = await client.post(
      '/investigador/bitacora',
      {
        'caso_id': '$casoId',
        'profesional_id': '$profesionalId',
        'nota': nota,
        'estado': estado ?? '',
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al agregar nota');
    }
  }

  // EVIDENCIAS FOTOGRÁFICAS
  Future<List<dynamic>> getEvidencias({
    required int casoId,
    int? profesionalId,
  }) async {
    final params = <String, dynamic>{
      'caso_id': casoId,
    };

    if (profesionalId != null) {
      params['profesional_id'] = profesionalId;
    }

    final res = await client.get(
      '/investigador/evidencias',
      params: params,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener evidencias');
    }

    return (res['data'] as List<dynamic>? ?? []);
  }

  Future<void> subirEvidencia({
    required int casoId,
    required int profesionalId,
    required PlatformFile file,
    String? descripcion,
  }) async {
    final res = await client.postMultipart(
      '/investigador/evidencias',
      fields: {
        'caso_id': '$casoId',
        'profesional_id': '$profesionalId',
        'descripcion': descripcion ?? '',
      },
      file: file,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al subir evidencia');
    }
  }

  Future<void> eliminarEvidencia({
    required int evidenciaId,
  }) async {
    final res = await client.delete(
      '/investigador/evidencias/$evidenciaId',
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al eliminar evidencia');
    }
  }
}