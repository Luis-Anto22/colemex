import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiServicePerito {
  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  static const Duration _timeout = Duration(seconds: 25);

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse('$baseUrl/$cleanPath').replace(
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }

  static dynamic _decode(http.Response response) {
    final body = response.body.trim();

    if (body.isEmpty) return {};

    try {
      return jsonDecode(body);
    } catch (_) {
      throw Exception('Respuesta inválida del servidor: $body');
    }
  }

  static bool _ok(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  static String _error(dynamic data, http.Response response) {
    if (data is Map) {
      return data['mensaje']?.toString() ??
          data['message']?.toString() ??
          data['error']?.toString() ??
          'Error ${response.statusCode}';
    }

    return 'Error ${response.statusCode}';
  }

  static List<Map<String, dynamic>> _list(dynamic data, List<String> keys) {
    dynamic value = data;

    if (data is Map) {
      for (final key in keys) {
        if (data[key] is List) {
          value = data[key];
          break;
        }
      }

      if (value == data && data['data'] is List) {
        value = data['data'];
      }
    }

    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  static Map<String, dynamic> _map(dynamic data, List<String> keys) {
    if (data is Map) {
      for (final key in keys) {
        if (data[key] is Map) {
          return Map<String, dynamic>.from(data[key]);
        }
      }

      if (data['data'] is Map) {
        return Map<String, dynamic>.from(data['data']);
      }

      return Map<String, dynamic>.from(data);
    }

    return {};
  }

  static Future<dynamic> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await http
        .get(
          _uri(path, query),
          headers: _headers,
        )
        .timeout(_timeout);

    final data = _decode(response);

    if (!_ok(response)) {
      throw Exception(_error(data, response));
    }

    return data;
  }

  static Future<dynamic> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http
        .post(
          _uri(path),
          headers: _headers,
          body: jsonEncode(body ?? {}),
        )
        .timeout(_timeout);

    final data = _decode(response);

    if (!_ok(response)) {
      throw Exception(_error(data, response));
    }

    return data;
  }

  static Future<dynamic> _put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http
        .put(
          _uri(path),
          headers: _headers,
          body: jsonEncode(body ?? {}),
        )
        .timeout(_timeout);

    final data = _decode(response);

    if (!_ok(response)) {
      throw Exception(_error(data, response));
    }

    return data;
  }

  static Future<bool> _delete(String path) async {
    final response = await http
        .delete(
          _uri(path),
          headers: _headers,
        )
        .timeout(_timeout);

    final data = _decode(response);

    if (!_ok(response)) {
      throw Exception(_error(data, response));
    }

    if (data is Map && data['success'] is bool) {
      return data['success'] as bool;
    }

    return true;
  }

  // ============================================================
  // CASOS ASIGNADOS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getCasosAsignados({
    required int peritoId,
  }) async {
    final data = await _get(
      'perito/casos',
      query: {
        'perito_id': peritoId,
      },
    );

    return _list(data, [
      'casos',
      'casos_asignados',
      'perito_casos',
      'items',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> getDetalleCaso({
    required int casoId,
  }) async {
    final data = await _get('perito/casos/$casoId');

    return _map(data, [
      'caso',
      'detalle',
      'perito_caso',
      'item',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> crearCaso({
    required Map<String, dynamic> payload,
  }) async {
    final body = Map<String, dynamic>.from(payload);

    body['servicio'] = body['servicio'] ?? 'Peritos en criminalística';
    body['estado'] = body['estado'] ?? 'pendiente';

    final data = await _post(
      'casos',
      body: body,
    );

    return _map(data, [
      'caso',
      'perito_caso',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> actualizarCaso({
    required int casoId,
    required Map<String, dynamic> payload,
  }) async {
    final data = await _put(
      'casos/$casoId',
      body: payload,
    );

    return _map(data, [
      'caso',
      'perito_caso',
      'data',
    ]);
  }

  static Future<bool> cambiarEstadoCaso({
    required int casoId,
    required String estado,
  }) async {
    final data = await _post(
      'perito/casos/$casoId/estado',
      body: {
        'estado': estado,
        'estado_caso': estado,
        'estatus': estado,
      },
    );

    if (data is Map && data['success'] is bool) {
      return data['success'] as bool;
    }

    return true;
  }

  static Future<bool> eliminarCaso({
    required int casoId,
  }) async {
    return _delete('casos/$casoId');
  }

  // ============================================================
  // EVIDENCIAS CRIMINALÍSTICAS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getEvidencias({
    required int peritoId,
    int? casoId,
  }) async {
    final data = await _get(
      'perito/evidencias',
      query: {
        'perito_id': peritoId,
        if (casoId != null) 'caso_id': casoId,
      },
    );

    return _list(data, [
      'evidencias',
      'evidencias_criminalisticas',
      'perito_evidencias',
      'items',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> getDetalleEvidencia({
    required int evidenciaId,
  }) async {
    final data = await _get('perito/evidencias/$evidenciaId');

    return _map(data, [
      'evidencia',
      'perito_evidencia',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> crearEvidencia({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _post(
      'perito/evidencias',
      body: payload,
    );

    return _map(data, [
      'evidencia',
      'perito_evidencia',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> actualizarEvidencia({
    required int evidenciaId,
    required Map<String, dynamic> payload,
  }) async {
    final data = await _put(
      'perito/evidencias/$evidenciaId',
      body: payload,
    );

    return _map(data, [
      'evidencia',
      'perito_evidencia',
      'data',
    ]);
  }

  static Future<bool> cambiarEstadoEvidencia({
    required int evidenciaId,
    required String estado,
  }) async {
    final data = await _put(
      'perito/evidencias/$evidenciaId',
      body: {
        'estado': estado,
        'estado_evidencia': estado,
        'estatus': estado,
      },
    );

    if (data is Map && data['success'] is bool) {
      return data['success'] as bool;
    }

    return true;
  }

  static Future<bool> eliminarEvidencia({
    required int evidenciaId,
  }) async {
    return _delete('perito/evidencias/$evidenciaId');
  }

  // ============================================================
  // CADENA DE CUSTODIA
  // ============================================================

  static Future<List<Map<String, dynamic>>> getCadenaCustodia({
    required int peritoId,
    int? casoId,
    int? evidenciaId,
  }) async {
    final data = await _get(
      'perito/cadena-custodia',
      query: {
        'perito_id': peritoId,
        if (casoId != null) 'caso_id': casoId,
        if (evidenciaId != null) 'evidencia_id': evidenciaId,
      },
    );

    return _list(data, [
      'cadena',
      'cadena_custodia',
      'movimientos',
      'items',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> getDetalleMovimientoCustodia({
    required int movimientoId,
  }) async {
    final data = await _get('perito/cadena-custodia/$movimientoId');

    return _map(data, [
      'movimiento',
      'custodia',
      'cadena_custodia',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> crearMovimientoCustodia({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _post(
      'perito/cadena-custodia',
      body: payload,
    );

    return _map(data, [
      'movimiento',
      'custodia',
      'cadena_custodia',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> actualizarMovimientoCustodia({
    required int movimientoId,
    required Map<String, dynamic> payload,
  }) async {
    final data = await _put(
      'perito/cadena-custodia/$movimientoId',
      body: payload,
    );

    return _map(data, [
      'movimiento',
      'custodia',
      'cadena_custodia',
      'data',
    ]);
  }

  static Future<bool> eliminarMovimientoCustodia({
    required int movimientoId,
  }) async {
    return _delete('perito/cadena-custodia/$movimientoId');
  }

  // ============================================================
  // DICTÁMENES PERICIALES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getDictamenes({
    required int peritoId,
    int? casoId,
  }) async {
    final data = await _get(
      'perito/dictamenes',
      query: {
        'perito_id': peritoId,
        if (casoId != null) 'caso_id': casoId,
      },
    );

    return _list(data, [
      'dictamenes',
      'dictamenes_periciales',
      'perito_dictamenes',
      'items',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> getDetalleDictamen({
    required int dictamenId,
  }) async {
    final data = await _get('perito/dictamenes/$dictamenId');

    return _map(data, [
      'dictamen',
      'dictamen_pericial',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> crearDictamen({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _post(
      'perito/dictamenes',
      body: payload,
    );

    return _map(data, [
      'dictamen',
      'dictamen_pericial',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> actualizarDictamen({
    required int dictamenId,
    required Map<String, dynamic> payload,
  }) async {
    final data = await _put(
      'perito/dictamenes/$dictamenId',
      body: payload,
    );

    return _map(data, [
      'dictamen',
      'dictamen_pericial',
      'data',
    ]);
  }

  static Future<bool> cambiarEstadoDictamen({
    required int dictamenId,
    required String estado,
  }) async {
    final data = await _post(
      'perito/dictamenes/$dictamenId/estado',
      body: {
        'estado': estado,
        'estatus': estado,
      },
    );

    if (data is Map && data['success'] is bool) {
      return data['success'] as bool;
    }

    return true;
  }

  static Future<bool> eliminarDictamen({
    required int dictamenId,
  }) async {
    return _delete('perito/dictamenes/$dictamenId');
  }

  // ============================================================
  // REPORTE FOTOGRÁFICO
  // ============================================================

  static Future<List<Map<String, dynamic>>> getReporteFotografico({
    required int peritoId,
    int? casoId,
  }) async {
    final data = await _get(
      'perito/reporte-fotografico',
      query: {
        'perito_id': peritoId,
        if (casoId != null) 'caso_id': casoId,
      },
    );

    return _list(data, [
      'fotos',
      'fotografias',
      'reporte_fotografico',
      'reportes_fotograficos',
      'items',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> getDetalleFotoReporte({
    required int fotoId,
  }) async {
    final data = await _get('perito/reporte-fotografico/$fotoId');

    return _map(data, [
      'foto',
      'fotografia',
      'reporte',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> crearFotoReporte({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _post(
      'perito/reporte-fotografico',
      body: payload,
    );

    return _map(data, [
      'foto',
      'fotografia',
      'reporte',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> actualizarFotoReporte({
    required int fotoId,
    required Map<String, dynamic> payload,
  }) async {
    final data = await _put(
      'perito/reporte-fotografico/$fotoId',
      body: payload,
    );

    return _map(data, [
      'foto',
      'fotografia',
      'reporte',
      'data',
    ]);
  }

  static Future<bool> eliminarFotoReporte({
    required int fotoId,
  }) async {
    return _delete('perito/reporte-fotografico/$fotoId');
  }

  // ============================================================
  // AGENDA DE INSPECCIONES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAgendaInspecciones({
    required int peritoId,
  }) async {
    final data = await _get(
      'perito/agenda-inspecciones',
      query: {
        'perito_id': peritoId,
      },
    );

    return _list(data, [
      'agenda',
      'inspecciones',
      'agenda_inspecciones',
      'perito_agenda_inspecciones',
      'items',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> getDetalleInspeccion({
    required int inspeccionId,
  }) async {
    final data = await _get('perito/agenda-inspecciones/$inspeccionId');

    return _map(data, [
      'inspeccion',
      'cita',
      'agenda',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> crearInspeccion({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _post(
      'perito/agenda-inspecciones',
      body: payload,
    );

    return _map(data, [
      'inspeccion',
      'cita',
      'agenda',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> actualizarInspeccion({
    required int inspeccionId,
    required Map<String, dynamic> payload,
  }) async {
    final data = await _put(
      'perito/agenda-inspecciones/$inspeccionId',
      body: payload,
    );

    return _map(data, [
      'inspeccion',
      'cita',
      'agenda',
      'data',
    ]);
  }

  static Future<bool> cambiarEstadoInspeccion({
    required int inspeccionId,
    required String estado,
  }) async {
    final data = await _post(
      'perito/agenda-inspecciones/$inspeccionId/estado',
      body: {
        'estado': estado,
        'estatus': estado,
      },
    );

    if (data is Map && data['success'] is bool) {
      return data['success'] as bool;
    }

    return true;
  }

  static Future<bool> eliminarInspeccion({
    required int inspeccionId,
  }) async {
    return _delete('perito/agenda-inspecciones/$inspeccionId');
  }

  // ============================================================
  // HISTORIAL PERICIAL
  // ============================================================

  static Future<List<Map<String, dynamic>>> getHistorialPericial({
    required int peritoId,
    int? casoId,
  }) async {
    final data = await _get(
      'perito/historial',
      query: {
        'perito_id': peritoId,
        if (casoId != null) 'caso_id': casoId,
      },
    );

    return _list(data, [
      'historial',
      'historial_pericial',
      'eventos',
      'actividades',
      'items',
      'data',
    ]);
  }

  static Future<Map<String, dynamic>> crearHistorialPericial({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _post(
      'perito/historial',
      body: payload,
    );

    return _map(data, [
      'historial',
      'historial_pericial',
      'evento',
      'actividad',
      'data',
    ]);
  }

  // ============================================================
  // RESUMEN LOCAL DEL PANEL
  // ============================================================

  static Map<String, dynamic> resumenPericialLocal({
    required int casos,
    required int evidencias,
    required int dictamenes,
    required int inspecciones,
  }) {
    final cargaTotal = casos + evidencias + dictamenes + inspecciones;

    String nivel = 'Baja';

    if (cargaTotal >= 15) {
      nivel = 'Alta';
    } else if (cargaTotal >= 7) {
      nivel = 'Media';
    }

    return {
      'carga_total': cargaTotal,
      'nivel': nivel,
      'casos': casos,
      'evidencias': evidencias,
      'dictamenes': dictamenes,
      'inspecciones': inspecciones,
    };
  }
}