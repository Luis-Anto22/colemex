import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ApiServiceInmobiliario {
  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  // ===============================
  // Helpers
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
    final statusCode = '${res['status_code'] ?? ''}'.trim();

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
      headers: {'Accept': 'application/json'},
    );

    final decoded = _decode(response);
    decoded['status_code'] = response.statusCode;
    return decoded;
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
      body: data.map((key, value) => MapEntry(key, '$value')),
    );

    final decoded = _decode(response);
    decoded['status_code'] = response.statusCode;
    return decoded;
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
      body: data.map((key, value) => MapEntry(key, '$value')),
    );

    final decoded = _decode(response);
    decoded['status_code'] = response.statusCode;
    return decoded;
  }

  static Future<Map<String, dynamic>> _delete(String path) async {
    final response = await http.delete(
      _uri(path),
      headers: {'Accept': 'application/json'},
    );

    final decoded = _decode(response);
    decoded['status_code'] = response.statusCode;
    return decoded;
  }

  // ===============================
  // INMUEBLES / PANEL AGENTE
  // ===============================

  static Future<List<dynamic>> getInmuebles({
    required int agenteId,
  }) async {
    final res = await _get(
      '/inmobiliario/inmuebles',
      params: {
        'agente_id': agenteId,
        'profesional_id': agenteId,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener inmuebles');
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  // ===============================
  // CATÁLOGO CLIENTE / FILTROS
  // ===============================

  static Future<List<dynamic>> getCatalogoInmuebles({
    String? tipoOperacion,
    String? tipoInmueble,
    double? precioMin,
    double? precioMax,
    int? recamaras,
    int? banos,
    int? estacionamientos,
    bool? amueblado,
    bool? mascotasPermitidas,
    bool? aceptaCredito,
    double? calificacionMin,
    String? buscar,
    double? latitud,
    double? longitud,
    double? radioKm,
  }) async {
    final params = <String, dynamic>{};

    if (tipoOperacion != null && tipoOperacion.isNotEmpty) {
      params['tipo_operacion'] = tipoOperacion;
    }

    if (tipoInmueble != null && tipoInmueble.isNotEmpty) {
      params['tipo_inmueble'] = tipoInmueble;
    }

    if (precioMin != null) params['precio_min'] = precioMin;
    if (precioMax != null) params['precio_max'] = precioMax;
    if (recamaras != null) params['recamaras'] = recamaras;
    if (banos != null) params['banos'] = banos;
    if (estacionamientos != null) {
      params['estacionamientos'] = estacionamientos;
    }
    if (amueblado != null) params['amueblado'] = amueblado ? 1 : 0;
    if (mascotasPermitidas != null) {
      params['mascotas_permitidas'] = mascotasPermitidas ? 1 : 0;
    }
    if (aceptaCredito != null) {
      params['acepta_credito'] = aceptaCredito ? 1 : 0;
    }
    if (calificacionMin != null) {
      params['calificacion_min'] = calificacionMin;
    }
    if (buscar != null && buscar.trim().isNotEmpty) {
      params['buscar'] = buscar.trim();
    }

    if (latitud != null && longitud != null) {
      params['latitud'] = latitud;
      params['longitud'] = longitud;

      if (radioKm != null) {
        params['radio_km'] = radioKm;
      }
    }

    final res = await _get('/inmobiliario/inmuebles', params: params);

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener catálogo de inmuebles');
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  static Future<Map<String, dynamic>> getInmuebleDetalle({
    required int inmuebleId,
  }) async {
    final res = await _get('/inmobiliario/inmuebles/$inmuebleId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener inmueble');
    }

    final data = res['data'];
    return data is Map<String, dynamic> ? data : {};
  }

  static Future<void> registrarInmueble({
    required int agenteId,
    required String titulo,
    required String tipoInmueble,
    required String tipoOperacion,
    required String ubicacion,
    required double precio,
    required String descripcion,
    String estado = 'disponible',
    int? recamaras,
    int? banos,
    int? estacionamientos,
    double? metrosConstruccion,
    double? metrosTerreno,
    int? antiguedad,
    bool? amueblado,
    bool? mascotasPermitidas,
    bool? aceptaCredito,
    double? deposito,
    String? serviciosIncluidos,
    String? requisitos,
    double? latitud,
    double? longitud,
  }) async {
    final body = <String, dynamic>{
      'agente_id': agenteId,
      'profesional_id': agenteId,
      'titulo': titulo,
      'tipo_inmueble': tipoInmueble,
      'tipo_operacion': tipoOperacion,
      'ubicacion': ubicacion,
      'precio': precio,
      'descripcion': descripcion,
      'estado': estado,
    };

    if (recamaras != null) body['recamaras'] = recamaras;
    if (banos != null) body['banos'] = banos;
    if (estacionamientos != null) body['estacionamientos'] = estacionamientos;
    if (metrosConstruccion != null) {
      body['metros_construccion'] = metrosConstruccion;
    }
    if (metrosTerreno != null) body['metros_terreno'] = metrosTerreno;
    if (antiguedad != null) body['antiguedad'] = antiguedad;
    if (amueblado != null) body['amueblado'] = amueblado ? 1 : 0;
    if (mascotasPermitidas != null) {
      body['mascotas_permitidas'] = mascotasPermitidas ? 1 : 0;
    }
    if (aceptaCredito != null) {
      body['acepta_credito'] = aceptaCredito ? 1 : 0;
    }
    if (deposito != null) body['deposito'] = deposito;
    if (serviciosIncluidos != null) {
      body['servicios_incluidos'] = serviciosIncluidos;
    }
    if (requisitos != null) body['requisitos'] = requisitos;
    if (latitud != null) body['latitud'] = latitud;
    if (longitud != null) body['longitud'] = longitud;

    final res = await _post('/inmobiliario/inmuebles', body);

    if (res['success'] != true) {
      throw _apiException(res, 'Error al registrar inmueble');
    }
  }

  static Future<void> actualizarInmueble({
    required int inmuebleId,
    required int agenteId,
    required String titulo,
    required String tipoInmueble,
    required String tipoOperacion,
    required String ubicacion,
    required double precio,
    required String descripcion,
    required String estado,
    int? recamaras,
    int? banos,
    int? estacionamientos,
    double? metrosConstruccion,
    double? metrosTerreno,
    int? antiguedad,
    bool? amueblado,
    bool? mascotasPermitidas,
    bool? aceptaCredito,
    double? deposito,
    String? serviciosIncluidos,
    String? requisitos,
    double? latitud,
    double? longitud,
  }) async {
    final body = <String, dynamic>{
      'agente_id': agenteId,
      'profesional_id': agenteId,
      'titulo': titulo,
      'tipo_inmueble': tipoInmueble,
      'tipo_operacion': tipoOperacion,
      'ubicacion': ubicacion,
      'precio': precio,
      'descripcion': descripcion,
      'estado': estado,
    };

    if (recamaras != null) body['recamaras'] = recamaras;
    if (banos != null) body['banos'] = banos;
    if (estacionamientos != null) body['estacionamientos'] = estacionamientos;
    if (metrosConstruccion != null) {
      body['metros_construccion'] = metrosConstruccion;
    }
    if (metrosTerreno != null) body['metros_terreno'] = metrosTerreno;
    if (antiguedad != null) body['antiguedad'] = antiguedad;
    if (amueblado != null) body['amueblado'] = amueblado ? 1 : 0;
    if (mascotasPermitidas != null) {
      body['mascotas_permitidas'] = mascotasPermitidas ? 1 : 0;
    }
    if (aceptaCredito != null) {
      body['acepta_credito'] = aceptaCredito ? 1 : 0;
    }
    if (deposito != null) body['deposito'] = deposito;
    if (serviciosIncluidos != null) {
      body['servicios_incluidos'] = serviciosIncluidos;
    }
    if (requisitos != null) body['requisitos'] = requisitos;
    if (latitud != null) body['latitud'] = latitud;
    if (longitud != null) body['longitud'] = longitud;

    final res = await _put('/inmobiliario/inmuebles/$inmuebleId', body);

    if (res['success'] != true) {
      throw _apiException(res, 'Error al actualizar inmueble');
    }
  }

  static Future<void> actualizarEstadoInmueble({
    required int inmuebleId,
    required int agenteId,
    required String estado,
  }) async {
    final res = await _post(
      '/inmobiliario/inmuebles/$inmuebleId/estado',
      {
        'agente_id': agenteId,
        'profesional_id': agenteId,
        'estado': estado,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al actualizar estado');
    }
  }

  static Future<void> eliminarInmueble({
    required int inmuebleId,
  }) async {
    final res = await _delete('/inmobiliario/inmuebles/$inmuebleId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al eliminar inmueble');
    }
  }

  // ===============================
  // CALIFICACIONES
  // ===============================

  static Future<List<dynamic>> getCalificacionesInmueble({
    required int inmuebleId,
  }) async {
    final res = await _get(
      '/inmobiliario/inmuebles/$inmuebleId/calificaciones',
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener calificaciones');
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  static Future<void> calificarInmueble({
    required int inmuebleId,
    required int clienteId,
    required int calificacion,
    String comentario = '',
  }) async {
    final res = await _post(
      '/inmobiliario/inmuebles/$inmuebleId/calificar',
      {
        'cliente_id': clienteId,
        'calificacion': calificacion,
        'comentario': comentario,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al calificar inmueble');
    }
  }

  static Future<void> eliminarCalificacionInmueble({
    required int calificacionId,
  }) async {
    final res = await _delete(
      '/inmobiliario/inmuebles/calificaciones/$calificacionId',
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al eliminar calificación');
    }
  }

  // ===============================
  // ARCHIVOS DEL INMUEBLE
  // Fotos / documentos / contratos / escrituras
  // ===============================

  static Future<List<dynamic>> getArchivosInmueble({
    required int inmuebleId,
    String? categoria,
    int? agenteId,
  }) async {
    final params = <String, dynamic>{};

    if (categoria != null && categoria.isNotEmpty) {
      params['categoria'] = categoria;
    }

    if (agenteId != null) {
      params['agente_id'] = agenteId;
      params['profesional_id'] = agenteId;
    }

    final res = await _get(
      '/inmobiliario/inmuebles/$inmuebleId/archivos',
      params: params,
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener archivos del inmueble');
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  static Future<List<dynamic>> getFotosInmueble({
    required int inmuebleId,
    int? agenteId,
  }) async {
    return getArchivosInmueble(
      inmuebleId: inmuebleId,
      categoria: 'foto',
      agenteId: agenteId,
    );
  }

  static Future<List<dynamic>> getDocumentosInmueble({
    required int inmuebleId,
    int? agenteId,
  }) async {
    return getArchivosInmueble(
      inmuebleId: inmuebleId,
      categoria: 'documento',
      agenteId: agenteId,
    );
  }

  static Future<void> subirArchivoInmueble({
    required int inmuebleId,
    required int agenteId,
    required PlatformFile file,
    required String categoria,
    String tipo = 'general',
    String descripcion = '',
  }) async {
    final uri = _uri('/inmobiliario/inmuebles/$inmuebleId/archivos');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({'Accept': 'application/json'});

    request.fields.addAll({
      'agente_id': '$agenteId',
      'profesional_id': '$agenteId',
      'categoria': categoria,
      'tipo': tipo,
      'descripcion': descripcion,
    });

    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          file.bytes!,
          filename: file.name,
        ),
      );
    } else if (file.path != null && file.path!.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'archivo',
          file.path!,
          filename: file.name,
        ),
      );
    } else {
      throw Exception('No se pudo leer el archivo seleccionado');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final res = _decode(response);
    res['status_code'] = response.statusCode;

    if (res['success'] != true) {
      throw _apiException(res, 'Error al subir archivo del inmueble');
    }
  }

  static Future<void> subirFotoInmueble({
    required int inmuebleId,
    required int agenteId,
    required PlatformFile file,
    String tipo = 'general',
    String descripcion = '',
  }) async {
    await subirArchivoInmueble(
      inmuebleId: inmuebleId,
      agenteId: agenteId,
      file: file,
      categoria: 'foto',
      tipo: tipo,
      descripcion: descripcion,
    );
  }

  static Future<void> subirDocumentoInmueble({
    required int inmuebleId,
    required int agenteId,
    required PlatformFile file,
    String tipo = 'general',
    String descripcion = '',
  }) async {
    await subirArchivoInmueble(
      inmuebleId: inmuebleId,
      agenteId: agenteId,
      file: file,
      categoria: 'documento',
      tipo: tipo,
      descripcion: descripcion,
    );
  }

  static Future<void> eliminarArchivoInmueble({
    required int archivoId,
  }) async {
    final res = await _delete('/inmobiliario/archivos/$archivoId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al eliminar archivo del inmueble');
    }
  }

  // ===============================
  // HISTORIAL DE INMUEBLES
  // ===============================

  static Future<List<dynamic>> getHistorial({
    required int agenteId,
  }) async {
    final res = await _get(
      '/inmobiliario/historial',
      params: {
        'agente_id': agenteId,
        'profesional_id': agenteId,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener historial');
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  // ===============================
  // PROSPECTOS / CLIENTES INTERESADOS
  // ===============================

  static Future<List<dynamic>> getProspectos({
    required int agenteId,
  }) async {
    final res = await _get(
      '/inmobiliario/prospectos',
      params: {
        'agente_id': agenteId,
        'profesional_id': agenteId,
      },
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al obtener prospectos');
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  static Future<void> registrarProspecto({
    required int inmuebleId,
    int? clienteId,
    required String nombre,
    String telefono = '',
    String correo = '',
    String nivelInteres = 'medio',
    String mensaje = '',
  }) async {
    final body = <String, dynamic>{
      'inmueble_id': inmuebleId,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'nivel_interes': nivelInteres,
      'mensaje': mensaje,
    };

    if (clienteId != null) {
      body['cliente_id'] = clienteId;
    }

    final res = await _post('/inmobiliario/prospectos', body);

    if (res['success'] != true) {
      throw _apiException(res, 'Error al registrar prospecto');
    }
  }

  static Future<void> actualizarProspecto({
    required int prospectoId,
    int? inmuebleId,
    int? clienteId,
    String? nombre,
    String? telefono,
    String? correo,
    String? nivelInteres,
    String? estado,
    String? mensaje,
  }) async {
    final body = <String, dynamic>{};

    if (inmuebleId != null) body['inmueble_id'] = inmuebleId;
    if (clienteId != null) body['cliente_id'] = clienteId;
    if (nombre != null) body['nombre'] = nombre;
    if (telefono != null) body['telefono'] = telefono;
    if (correo != null) body['correo'] = correo;
    if (nivelInteres != null) body['nivel_interes'] = nivelInteres;
    if (estado != null) body['estado'] = estado;
    if (mensaje != null) body['mensaje'] = mensaje;

    final res = await _put('/inmobiliario/prospectos/$prospectoId', body);

    if (res['success'] != true) {
      throw _apiException(res, 'Error al actualizar prospecto');
    }
  }

  static Future<void> cambiarEstadoProspecto({
    required int prospectoId,
    required String estado,
  }) async {
    final res = await _post(
      '/inmobiliario/prospectos/$prospectoId/estado',
      {'estado': estado},
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
      '/inmobiliario/prospectos/$prospectoId/interes',
      {'nivel_interes': nivelInteres},
    );

    if (res['success'] != true) {
      throw _apiException(res, 'Error al cambiar interés del prospecto');
    }
  }

  static Future<void> eliminarProspecto({
    required int prospectoId,
  }) async {
    final res = await _delete('/inmobiliario/prospectos/$prospectoId');

    if (res['success'] != true) {
      throw _apiException(res, 'Error al eliminar prospecto');
    }
  }
}