import 'dart:io';

import 'api_client.dart';

class InvestigadorApi {
  final ApiClient client;
  InvestigadorApi(this.client);

  Future<List<dynamic>> getCasos(int investigadorId) async {
    final res = await client.get(
      '/investigador/casos.php',
      params: {'investigador_id': investigadorId},
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
    final res = await client.post('/investigador/casos.php', {
      'action': 'create',
      'investigador_id': investigadorId,
      if (clienteId != null) 'cliente_id': '$clienteId',
      'titulo': titulo,
      'descripcion': descripcion ?? '',
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear caso');
    }
  }

  Future<void> actualizarEstadoCaso({
    required int id,
    required String estado,
  }) async {
    final res = await client.post('/investigador/casos.php', {
      'action': 'update_estado',
      'id': '$id',
      'estado': estado,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar estado');
    }
  }

  // BITÁCORA
  Future<List<dynamic>> getBitacora(int casoId) async {
    final res = await client.get(
      '/investigador/bitacora.php',
      params: {'caso_id': casoId},
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
    final res = await client.post('/investigador/bitacora.php', {
      'action': 'add',
      'caso_id': '$casoId',
      'profesional_id': '$profesionalId',
      'nota': nota,
      'estado': estado ?? '',
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al agregar nota');
    }
  }

  // EVIDENCIAS
  Future<List<dynamic>> getEvidencias(int casoId) async {
    final res = await client.get(
      '/investigador/evidencias.php',
      params: {'caso_id': casoId},
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener evidencias');
    }
    return (res['data'] as List<dynamic>? ?? []);
  }

  Future<void> subirEvidencia({
    required int casoId,
    required int profesionalId,
    required File file,
    required String tipo,
    String? descripcion,
  }) async {
    final res = await client.postMultipart(
      '/investigador/evidencias.php',
      fields: {
        'caso_id': '$casoId',
        'profesional_id': '$profesionalId',
        'tipo': tipo,
        'descripcion': descripcion ?? '',
      },
      file: file,
    );
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al subir evidencia');
    }
  }
}
