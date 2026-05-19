import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiServiceCrediticio {
  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  // ===============================
  // HELPERS
  // ===============================

  static Uri _uri(String path, [Map<String, dynamic>? params]) {
    final uri = Uri.parse('$baseUrl$path');

    if (params == null || params.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: params.map(
        (key, value) => MapEntry(key, '$value'),
      ),
    );
  }

  static Map<String, dynamic> _decode(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        body['status_code'] = response.statusCode;
        return body;
      }

      return {
        'success': false,
        'message': 'Respuesta inesperada del servidor',
        'status_code': response.statusCode,
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Respuesta inválida del servidor',
        'error': response.body,
        'status_code': response.statusCode,
      };
    }
  }

  static Exception _apiException(
    Map<String, dynamic> res,
    String fallback,
  ) {
    final message = '${res['message'] ?? fallback}'.trim();
    final error = '${res['error'] ?? ''}'.trim();
    final errors = res['errors'];
    final statusCode = '${res['status_code'] ?? ''}'.trim();

    if (errors != null && '$errors'.trim().isNotEmpty) {
      return Exception('$message: $errors');
    }

    if (error.isNotEmpty && error != 'null') {
      return Exception('$message: $error');
    }

    if (statusCode.isNotEmpty && statusCode != 'null') {
      return Exception('$message. Código HTTP: $statusCode');
    }

    return Exception(message);
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final response = await http.get(
      _uri(path, params),
      headers: {
        'Accept': 'application/json',
      },
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data.map(
        (key, value) => MapEntry(key, '$value'),
      ),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data.map(
        (key, value) => MapEntry(key, '$value'),
      ),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> _delete(String path) async {
    final response = await http.delete(
      _uri(path),
      headers: {
        'Accept': 'application/json',
      },
    );

    return _decode(response);
  }

  // ===============================
  // SOLICITUDES DE CRÉDITO
  // ===============================

  static Future<List<dynamic>> getSolicitudes({
    required int agenteId,
    String? estadoCredito,
    String? buscar,
  }) async {
    final params = <String, dynamic>{
      'agente_id': agenteId,
      'profesional_id': agenteId,
    };

    if (estadoCredito != null && estadoCredito.trim().isNotEmpty) {
      params['estado_credito'] = estadoCredito.trim();
    }

    if (buscar != null && buscar.trim().isNotEmpty) {
      params['buscar'] = buscar.trim();
    }

    final res = await _get(
      '/crediticio/solicitudes',
      params: params,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener solicitudes de crédito');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  static Future<Map<String, dynamic>> getDetalleSolicitud({
    required int solicitudId,
  }) async {
    final res = await _get('/crediticio/solicitudes/$solicitudId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener detalle de solicitud');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  static Future<void> registrarSolicitud({
    required int agenteId,
    required int clienteId,
    required String ocupacion,
    required double ingresoMensual,
    required String ingresoFrecuencia,
    required double montoSolicitado,
    required int plazoMeses,
    String estadoCredito = 'pendiente',
    String historialCredito = '',
    String comentariosAgente = '',
  }) async {
    final res = await _post(
      '/crediticio/solicitudes',
      {
        'agente_id': agenteId,
        'cliente_id': clienteId,
        'ocupacion': ocupacion,
        'ingreso_mensual': ingresoMensual,
        'ingreso_frecuencia': ingresoFrecuencia,
        'monto_solicitado': montoSolicitado,
        'plazo_meses': plazoMeses,
        'estado_credito': estadoCredito,
        'historial_credito': historialCredito,
        'comentarios_agente': comentariosAgente,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al registrar solicitud de crédito');
    }
  }

  static Future<void> actualizarSolicitud({
    required int solicitudId,
    int? agenteId,
    int? clienteId,
    String? ocupacion,
    double? ingresoMensual,
    String? ingresoFrecuencia,
    double? montoSolicitado,
    int? plazoMeses,
    String? estadoCredito,
    String? historialCredito,
    String? comentariosAgente,
  }) async {
    final body = <String, dynamic>{};

    if (agenteId != null) body['agente_id'] = agenteId;
    if (clienteId != null) body['cliente_id'] = clienteId;
    if (ocupacion != null) body['ocupacion'] = ocupacion;
    if (ingresoMensual != null) body['ingreso_mensual'] = ingresoMensual;
    if (ingresoFrecuencia != null) {
      body['ingreso_frecuencia'] = ingresoFrecuencia;
    }
    if (montoSolicitado != null) body['monto_solicitado'] = montoSolicitado;
    if (plazoMeses != null) body['plazo_meses'] = plazoMeses;
    if (estadoCredito != null) body['estado_credito'] = estadoCredito;
    if (historialCredito != null) body['historial_credito'] = historialCredito;
    if (comentariosAgente != null) {
      body['comentarios_agente'] = comentariosAgente;
    }

    final res = await _put(
      '/crediticio/solicitudes/$solicitudId',
      body,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al actualizar solicitud de crédito');
    }
  }

  static Future<void> cambiarEstadoSolicitud({
    required int solicitudId,
    required String estadoCredito,
    String comentariosAgente = '',
  }) async {
    final body = <String, dynamic>{
      'estado_credito': estadoCredito,
    };

    if (comentariosAgente.trim().isNotEmpty) {
      body['comentarios_agente'] = comentariosAgente.trim();
    }

    final res = await _post(
      '/crediticio/solicitudes/$solicitudId/estado',
      body,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al cambiar estado de solicitud');
    }
  }

  static Future<void> actualizarComentariosSolicitud({
    required int solicitudId,
    String comentariosAgente = '',
    String historialCredito = '',
  }) async {
    final body = <String, dynamic>{
      'comentarios_agente': comentariosAgente,
      'historial_credito': historialCredito,
    };

    final res = await _post(
      '/crediticio/solicitudes/$solicitudId/comentarios',
      body,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al actualizar comentarios');
    }
  }

  static Future<void> eliminarSolicitud({
    required int solicitudId,
  }) async {
    final res = await _delete('/crediticio/solicitudes/$solicitudId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al eliminar solicitud de crédito');
    }
  }

  // ===============================
  // DOCUMENTOS DE CRÉDITO
  // ===============================

  static Future<List<dynamic>> getDocumentos({
    int? agenteId,
    int? solicitudId,
    int? clienteId,
    String? estado,
    String? tipoDocumento,
  }) async {
    final params = <String, dynamic>{};

    if (agenteId != null) {
      params['agente_id'] = agenteId;
      params['profesional_id'] = agenteId;
    }

    if (solicitudId != null) {
      params['solicitud_id'] = solicitudId;
    }

    if (clienteId != null) {
      params['cliente_id'] = clienteId;
    }

    if (estado != null && estado.trim().isNotEmpty) {
      params['estado'] = estado.trim();
    }

    if (tipoDocumento != null && tipoDocumento.trim().isNotEmpty) {
      params['tipo_documento'] = tipoDocumento.trim();
    }

    final res = await _get(
      '/crediticio/documentos',
      params: params,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener documentos de crédito');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  static Future<List<dynamic>> getDocumentosPorSolicitud({
    required int solicitudId,
  }) async {
    final res = await _get(
      '/crediticio/solicitudes/$solicitudId/documentos',
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener documentos de la solicitud');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  static Future<Map<String, dynamic>> getDetalleDocumento({
    required int documentoId,
  }) async {
    final res = await _get('/crediticio/documentos/$documentoId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener documento');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  static Future<void> registrarDocumento({
    required int solicitudId,
    required int clienteId,
    required String tipoDocumento,
    required String archivoUrl,
    String archivoNombre = '',
    String estado = 'pendiente',
    String comentarios = '',
  }) async {
    final res = await _post(
      '/crediticio/documentos',
      {
        'solicitud_id': solicitudId,
        'cliente_id': clienteId,
        'tipo_documento': tipoDocumento,
        'archivo_url': archivoUrl,
        'archivo_nombre': archivoNombre,
        'estado': estado,
        'comentarios': comentarios,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al registrar documento');
    }
  }

  static Future<void> actualizarDocumento({
    required int documentoId,
    String? tipoDocumento,
    String? archivoUrl,
    String? archivoNombre,
    String? estado,
    String? comentarios,
  }) async {
    final body = <String, dynamic>{};

    if (tipoDocumento != null) body['tipo_documento'] = tipoDocumento;
    if (archivoUrl != null) body['archivo_url'] = archivoUrl;
    if (archivoNombre != null) body['archivo_nombre'] = archivoNombre;
    if (estado != null) body['estado'] = estado;
    if (comentarios != null) body['comentarios'] = comentarios;

    final res = await _put(
      '/crediticio/documentos/$documentoId',
      body,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al actualizar documento');
    }
  }

  static Future<void> validarDocumento({
    required int documentoId,
    required String estado,
    String comentarios = '',
  }) async {
    final body = <String, dynamic>{
      'estado': estado,
    };

    if (comentarios.trim().isNotEmpty) {
      body['comentarios'] = comentarios.trim();
    }

    final res = await _post(
      '/crediticio/documentos/$documentoId/validar',
      body,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al validar documento');
    }
  }

  static Future<void> eliminarDocumento({
    required int documentoId,
  }) async {
    final res = await _delete('/crediticio/documentos/$documentoId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al eliminar documento');
    }
  }

  // ===============================
  // PROSPECTOS / CLIENTES INTERESADOS
  // ===============================

  static Future<List<dynamic>> getProspectos({
    required int agenteId,
    String? nivelInteres,
    String? estado,
    String? buscar,
  }) async {
    final params = <String, dynamic>{
      'agente_id': agenteId,
      'profesional_id': agenteId,
    };

    if (nivelInteres != null && nivelInteres.trim().isNotEmpty) {
      params['nivel_interes'] = nivelInteres.trim();
    }

    if (estado != null && estado.trim().isNotEmpty) {
      params['estado'] = estado.trim();
    }

    if (buscar != null && buscar.trim().isNotEmpty) {
      params['buscar'] = buscar.trim();
    }

    final res = await _get(
      '/crediticio/prospectos',
      params: params,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener prospectos crediticios');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  static Future<Map<String, dynamic>> getDetalleProspecto({
    required int prospectoId,
  }) async {
    final res = await _get('/crediticio/prospectos/$prospectoId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener prospecto crediticio');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  static Future<void> registrarProspecto({
    required int agenteId,
    int? clienteId,
    required String nombre,
    String telefono = '',
    String correo = '',
    String tipoCredito = '',
    double? montoAproximado,
    String mensaje = '',
    String nivelInteres = 'medio',
    String estado = 'nuevo',
  }) async {
    final body = <String, dynamic>{
      'agente_id': agenteId,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'tipo_credito': tipoCredito,
      'mensaje': mensaje,
      'nivel_interes': nivelInteres,
      'estado': estado,
    };

    if (clienteId != null) {
      body['cliente_id'] = clienteId;
    }

    if (montoAproximado != null) {
      body['monto_aproximado'] = montoAproximado;
    }

    final res = await _post(
      '/crediticio/prospectos',
      body,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al registrar prospecto crediticio');
    }
  }

  static Future<void> actualizarProspecto({
    required int prospectoId,
    int? agenteId,
    int? clienteId,
    String? nombre,
    String? telefono,
    String? correo,
    String? tipoCredito,
    double? montoAproximado,
    String? mensaje,
    String? nivelInteres,
    String? estado,
  }) async {
    final body = <String, dynamic>{};

    if (agenteId != null) body['agente_id'] = agenteId;
    if (clienteId != null) body['cliente_id'] = clienteId;
    if (nombre != null) body['nombre'] = nombre;
    if (telefono != null) body['telefono'] = telefono;
    if (correo != null) body['correo'] = correo;
    if (tipoCredito != null) body['tipo_credito'] = tipoCredito;
    if (montoAproximado != null) {
      body['monto_aproximado'] = montoAproximado;
    }
    if (mensaje != null) body['mensaje'] = mensaje;
    if (nivelInteres != null) body['nivel_interes'] = nivelInteres;
    if (estado != null) body['estado'] = estado;

    final res = await _put(
      '/crediticio/prospectos/$prospectoId',
      body,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al actualizar prospecto crediticio');
    }
  }

  static Future<void> cambiarEstadoProspecto({
    required int prospectoId,
    required String estado,
  }) async {
    final res = await _post(
      '/crediticio/prospectos/$prospectoId/estado',
      {
        'estado': estado,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al cambiar estado del prospecto');
    }
  }

  static Future<void> cambiarInteresProspecto({
    required int prospectoId,
    required String nivelInteres,
  }) async {
    final res = await _post(
      '/crediticio/prospectos/$prospectoId/interes',
      {
        'nivel_interes': nivelInteres,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al cambiar nivel de interés');
    }
  }

  static Future<void> eliminarProspecto({
    required int prospectoId,
  }) async {
    final res = await _delete('/crediticio/prospectos/$prospectoId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al eliminar prospecto crediticio');
    }
  }

  // ===============================
  // SIMULADOR LOCAL
  // No necesita backend por ahora
  // ===============================

  static Map<String, dynamic> simularCredito({
    required double monto,
    required double enganche,
    required double tasaAnual,
    required int plazoMeses,
    double ingresoMensual = 0,
  }) {
    final capital = monto - enganche;

    if (capital <= 0 || plazoMeses <= 0) {
      return {
        'capital': 0.0,
        'pago_mensual': 0.0,
        'total_pagar': 0.0,
        'intereses_estimados': 0.0,
        'porcentaje_ingreso': 0.0,
        'nivel_riesgo': 'Sin cálculo',
      };
    }

    final tasaMensual = (tasaAnual / 100) / 12;

    double pagoMensual;

    if (tasaMensual == 0) {
      pagoMensual = capital / plazoMeses;
    } else {
      final factor = _pow(1 + tasaMensual, plazoMeses);
      pagoMensual = capital * ((tasaMensual * factor) / (factor - 1));
    }

    final totalPagar = pagoMensual * plazoMeses;
    final intereses = totalPagar - capital;

    double porcentajeIngreso = 0;

    if (ingresoMensual > 0) {
      porcentajeIngreso = (pagoMensual / ingresoMensual) * 100;
    }

    String nivelRiesgo = 'Sin ingreso';

    if (ingresoMensual > 0) {
      if (porcentajeIngreso <= 30) {
        nivelRiesgo = 'Bajo';
      } else if (porcentajeIngreso <= 45) {
        nivelRiesgo = 'Medio';
      } else {
        nivelRiesgo = 'Alto';
      }
    }

    return {
      'capital': capital,
      'pago_mensual': pagoMensual,
      'total_pagar': totalPagar,
      'intereses_estimados': intereses,
      'porcentaje_ingreso': porcentajeIngreso,
      'nivel_riesgo': nivelRiesgo,
    };
  }

  static double _pow(double base, int exponent) {
    double result = 1;

    for (int i = 0; i < exponent; i++) {
      result *= base;
    }

    return result;
  }
}