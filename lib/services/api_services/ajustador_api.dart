import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AjustadorApi {
  /*
    IMPORTANTE:
    Cambia esta URL si tu ApiClient usa otra base.

    En producción normalmente sería:
    https://corporativolegaldigital.com/api

    En local puede ser algo como:
    http://127.0.0.1:8000/api

    Si pruebas desde emulador Android, usa:
    http://10.0.2.2:8000/api
  */
  static const String baseUrl = 'https://corporativolegaldigital.com/api';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ============================================================
  // MÉTODO INTERNO PARA LEER RESPUESTAS
  // ============================================================

  dynamic _decodeResponse(http.Response response) {
    final body = response.body.trim();

    if (body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      throw Exception('Respuesta inválida del servidor: $body');
    }
  }

  void _validarRespuesta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = null;
    }

    String mensaje = 'Error ${response.statusCode} al consumir la API';

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        mensaje = data['message'].toString();
      } else if (data['error'] != null) {
        mensaje = data['error'].toString();
      } else if (data['mensaje'] != null) {
        mensaje = data['mensaje'].toString();
      }
    }

    throw Exception(mensaje);
  }

  Future<int?> obtenerAjustadorIdGuardado() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt('id');

    if (id != null) {
      return id;
    }

    final idString = prefs.getString('id');

    if (idString == null) {
      return null;
    }

    return int.tryParse(idString);
  }

  // ============================================================
  // SINIESTROS
  // ============================================================

  Future<List<Siniestro>> getSiniestros({
    int? ajustadorId,
    String? estado,
    String? prioridad,
  }) async {
    ajustadorId ??= await obtenerAjustadorIdGuardado();

    final queryParams = <String, String>{};

    if (ajustadorId != null) {
      queryParams['ajustador_id'] = ajustadorId.toString();
    }

    if (estado != null && estado.trim().isNotEmpty) {
      queryParams['estado'] = estado.trim();
    }

    if (prioridad != null && prioridad.trim().isNotEmpty) {
      queryParams['prioridad'] = prioridad.trim();
    }

    final uri = Uri.parse('$baseUrl/ajustadores/siniestros').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final response = await http.get(uri, headers: _headers);

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is List) {
      return data.map((item) => Siniestro.fromJson(item)).toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Siniestro.fromJson(item))
            .toList();
      }

      if (data['siniestros'] is List) {
        return (data['siniestros'] as List)
            .map((item) => Siniestro.fromJson(item))
            .toList();
      }
    }

    return [];
  }

  Future<Siniestro> getSiniestroPorId(int id) async {
    final uri = Uri.parse('$baseUrl/ajustadores/siniestros/$id');

    final response = await http.get(uri, headers: _headers);

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return Siniestro.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return Siniestro.fromJson(data);
    }

    throw Exception('No se pudo leer el siniestro');
  }

  Future<Siniestro> crearSiniestro({
    required int ajustadorId,
    int? clienteId,
    required String folio,
    required String tipo,
    required String ubicacion,
    required String fechaSiniestro,
    String prioridad = 'media',
    String estado = 'asignado',
    String? descripcion,
    String? referenciaExterna,
  }) async {
    final uri = Uri.parse('$baseUrl/ajustadores/siniestros');

    final body = {
      'ajustador_id': ajustadorId,
      'cliente_id': clienteId,
      'folio': folio,
      'tipo': tipo,
      'ubicacion': ubicacion,
      'fecha_siniestro': fechaSiniestro,
      'prioridad': prioridad,
      'estado': estado,
      'descripcion': descripcion,
      'referencia_externa': referenciaExterna,
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return Siniestro.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return Siniestro.fromJson(data);
    }

    throw Exception('No se pudo crear el siniestro');
  }

  Future<Siniestro> actualizarSiniestro({
    required int id,
    int? ajustadorId,
    int? clienteId,
    String? folio,
    String? tipo,
    String? ubicacion,
    String? fechaSiniestro,
    String? prioridad,
    String? estado,
    String? descripcion,
    String? referenciaExterna,
  }) async {
    final uri = Uri.parse('$baseUrl/ajustadores/siniestros/$id');

    final body = <String, dynamic>{};

    if (ajustadorId != null) body['ajustador_id'] = ajustadorId;
    if (clienteId != null) body['cliente_id'] = clienteId;
    if (folio != null) body['folio'] = folio;
    if (tipo != null) body['tipo'] = tipo;
    if (ubicacion != null) body['ubicacion'] = ubicacion;
    if (fechaSiniestro != null) body['fecha_siniestro'] = fechaSiniestro;
    if (prioridad != null) body['prioridad'] = prioridad;
    if (estado != null) body['estado'] = estado;
    if (descripcion != null) body['descripcion'] = descripcion;
    if (referenciaExterna != null) {
      body['referencia_externa'] = referenciaExterna;
    }

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return Siniestro.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return Siniestro.fromJson(data);
    }

    throw Exception('No se pudo actualizar el siniestro');
  }

  Future<bool> eliminarSiniestro(int id) async {
    final uri = Uri.parse('$baseUrl/ajustadores/siniestros/$id');

    final response = await http.delete(uri, headers: _headers);

    _validarRespuesta(response);

    return true;
  }

  Future<Siniestro> cambiarEstadoSiniestro({
    required int id,
    required String estado,
  }) async {
    final uri = Uri.parse('$baseUrl/ajustadores/siniestros/$id/estado');

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        'estado': estado,
      }),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return Siniestro.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return Siniestro.fromJson(data);
    }

    throw Exception('No se pudo cambiar el estado del siniestro');
  }

  // ============================================================
  // PARTES DEL SINIESTRO
  // inspeccion, poliza, danos, dictamen, seguimiento, bitacora
  // ============================================================

  Future<List<SiniestroParte>> getPartes({
    int? siniestroId,
    String? tipo,
  }) async {
    final queryParams = <String, String>{};

    if (siniestroId != null) {
      queryParams['siniestro_id'] = siniestroId.toString();
    }

    if (tipo != null && tipo.trim().isNotEmpty) {
      queryParams['tipo'] = tipo.trim();
    }

    final uri = Uri.parse('$baseUrl/ajustadores/partes').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final response = await http.get(uri, headers: _headers);

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is List) {
      return data.map((item) => SiniestroParte.fromJson(item)).toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((item) => SiniestroParte.fromJson(item))
            .toList();
      }

      if (data['partes'] is List) {
        return (data['partes'] as List)
            .map((item) => SiniestroParte.fromJson(item))
            .toList();
      }
    }

    return [];
  }

  Future<List<SiniestroParte>> getPartesPorTipo(String tipo) async {
    final uri = Uri.parse('$baseUrl/ajustadores/partes/tipo/$tipo');

    final response = await http.get(uri, headers: _headers);

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is List) {
      return data.map((item) => SiniestroParte.fromJson(item)).toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((item) => SiniestroParte.fromJson(item))
            .toList();
      }

      if (data['partes'] is List) {
        return (data['partes'] as List)
            .map((item) => SiniestroParte.fromJson(item))
            .toList();
      }
    }

    return [];
  }

  Future<SiniestroParte> getPartePorId(int id) async {
    final uri = Uri.parse('$baseUrl/ajustadores/partes/$id');

    final response = await http.get(uri, headers: _headers);

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return SiniestroParte.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return SiniestroParte.fromJson(data);
    }

    throw Exception('No se pudo leer la parte del siniestro');
  }

  Future<SiniestroParte> crearParte({
    required int siniestroId,
    required String tipo,
    required String titulo,
    required Map<String, dynamic> contenidoJson,
    String estado = 'activo',
    String? fechaEvento,
    int? createdBy,
  }) async {
    final uri = Uri.parse('$baseUrl/ajustadores/partes');

    final body = {
      'siniestro_id': siniestroId,
      'tipo': tipo,
      'titulo': titulo,
      'contenido_json': contenidoJson,
      'estado': estado,
      'fecha_evento': fechaEvento,
      'created_by': createdBy,
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return SiniestroParte.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return SiniestroParte.fromJson(data);
    }

    throw Exception('No se pudo crear la parte del siniestro');
  }

  Future<SiniestroParte> actualizarParte({
    required int id,
    int? siniestroId,
    String? tipo,
    String? titulo,
    Map<String, dynamic>? contenidoJson,
    String? estado,
    String? fechaEvento,
    int? createdBy,
  }) async {
    final uri = Uri.parse('$baseUrl/ajustadores/partes/$id');

    final body = <String, dynamic>{};

    if (siniestroId != null) body['siniestro_id'] = siniestroId;
    if (tipo != null) body['tipo'] = tipo;
    if (titulo != null) body['titulo'] = titulo;
    if (contenidoJson != null) body['contenido_json'] = contenidoJson;
    if (estado != null) body['estado'] = estado;
    if (fechaEvento != null) body['fecha_evento'] = fechaEvento;
    if (createdBy != null) body['created_by'] = createdBy;

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return SiniestroParte.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return SiniestroParte.fromJson(data);
    }

    throw Exception('No se pudo actualizar la parte del siniestro');
  }

  Future<bool> eliminarParte(int id) async {
    final uri = Uri.parse('$baseUrl/ajustadores/partes/$id');

    final response = await http.delete(uri, headers: _headers);

    _validarRespuesta(response);

    return true;
  }

  // ============================================================
  // MÉTODOS DIRECTOS PARA CADA MÓDULO ESPECIAL
  // ============================================================

  Future<List<SiniestroParte>> getInspecciones({int? siniestroId}) {
    return getPartes(siniestroId: siniestroId, tipo: 'inspeccion');
  }

  Future<List<SiniestroParte>> getPolizas({int? siniestroId}) {
    return getPartes(siniestroId: siniestroId, tipo: 'poliza');
  }

  Future<List<SiniestroParte>> getDanos({int? siniestroId}) {
    return getPartes(siniestroId: siniestroId, tipo: 'danos');
  }

  Future<List<SiniestroParte>> getDictamenes({int? siniestroId}) {
    return getPartes(siniestroId: siniestroId, tipo: 'dictamen');
  }

  Future<List<SiniestroParte>> getSeguimientos({int? siniestroId}) {
    return getPartes(siniestroId: siniestroId, tipo: 'seguimiento');
  }

  Future<List<SiniestroParte>> getBitacora({int? siniestroId}) {
    return getPartes(siniestroId: siniestroId, tipo: 'bitacora');
  }

  // ============================================================
  // TERCEROS INVOLUCRADOS
  // ============================================================

  Future<List<SiniestroTercero>> getTerceros({
    int? siniestroId,
  }) async {
    Uri uri;

    if (siniestroId != null) {
      uri = Uri.parse(
        '$baseUrl/ajustadores/siniestros/$siniestroId/terceros',
      );
    } else {
      uri = Uri.parse('$baseUrl/ajustadores/terceros');
    }

    final response = await http.get(uri, headers: _headers);

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is List) {
      return data.map((item) => SiniestroTercero.fromJson(item)).toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((item) => SiniestroTercero.fromJson(item))
            .toList();
      }

      if (data['terceros'] is List) {
        return (data['terceros'] as List)
            .map((item) => SiniestroTercero.fromJson(item))
            .toList();
      }
    }

    return [];
  }

  Future<SiniestroTercero> getTerceroPorId(int id) async {
    final uri = Uri.parse('$baseUrl/ajustadores/terceros/$id');

    final response = await http.get(uri, headers: _headers);

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return SiniestroTercero.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return SiniestroTercero.fromJson(data);
    }

    throw Exception('No se pudo leer el tercero involucrado');
  }

  Future<SiniestroTercero> crearTercero({
    required int siniestroId,
    required String nombre,
    String? telefono,
    String? placas,
    String? aseguradora,
    String? vehiculo,
    String? versionHechos,
    String? responsabilidad,
    String estado = 'activo',
  }) async {
    final uri = Uri.parse('$baseUrl/ajustadores/terceros');

    final body = {
      'siniestro_id': siniestroId,
      'nombre': nombre,
      'telefono': telefono,
      'placas': placas,
      'aseguradora': aseguradora,
      'vehiculo': vehiculo,
      'version_hechos': versionHechos,
      'responsabilidad': responsabilidad,
      'estado': estado,
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return SiniestroTercero.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return SiniestroTercero.fromJson(data);
    }

    throw Exception('No se pudo crear el tercero involucrado');
  }

  Future<SiniestroTercero> actualizarTercero({
    required int id,
    int? siniestroId,
    String? nombre,
    String? telefono,
    String? placas,
    String? aseguradora,
    String? vehiculo,
    String? versionHechos,
    String? responsabilidad,
    String? estado,
  }) async {
    final uri = Uri.parse('$baseUrl/ajustadores/terceros/$id');

    final body = <String, dynamic>{};

    if (siniestroId != null) body['siniestro_id'] = siniestroId;
    if (nombre != null) body['nombre'] = nombre;
    if (telefono != null) body['telefono'] = telefono;
    if (placas != null) body['placas'] = placas;
    if (aseguradora != null) body['aseguradora'] = aseguradora;
    if (vehiculo != null) body['vehiculo'] = vehiculo;
    if (versionHechos != null) body['version_hechos'] = versionHechos;
    if (responsabilidad != null) body['responsabilidad'] = responsabilidad;
    if (estado != null) body['estado'] = estado;

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    _validarRespuesta(response);

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return SiniestroTercero.fromJson(data['data']);
    }

    if (data is Map<String, dynamic>) {
      return SiniestroTercero.fromJson(data);
    }

    throw Exception('No se pudo actualizar el tercero involucrado');
  }

  Future<bool> eliminarTercero(int id) async {
    final uri = Uri.parse('$baseUrl/ajustadores/terceros/$id');

    final response = await http.delete(uri, headers: _headers);

    _validarRespuesta(response);

    return true;
  }
}

// ============================================================
// MODELO: SINIESTRO
// ============================================================

class Siniestro {
  final int id;
  final int? ajustadorId;
  final int? clienteId;
  final String folio;
  final String tipo;
  final String? ubicacion;
  final String? fechaSiniestro;
  final String? prioridad;
  final String? estado;
  final String? descripcion;
  final String? referenciaExterna;
  final String? createdAt;
  final String? updatedAt;

  Siniestro({
    required this.id,
    this.ajustadorId,
    this.clienteId,
    required this.folio,
    required this.tipo,
    this.ubicacion,
    this.fechaSiniestro,
    this.prioridad,
    this.estado,
    this.descripcion,
    this.referenciaExterna,
    this.createdAt,
    this.updatedAt,
  });

  factory Siniestro.fromJson(Map<String, dynamic> json) {
    return Siniestro(
      id: _toInt(json['id']) ?? 0,
      ajustadorId: _toInt(json['ajustador_id']),
      clienteId: _toInt(json['cliente_id']),
      folio: json['folio']?.toString() ?? 'Sin folio',
      tipo: json['tipo']?.toString() ?? 'Sin tipo',
      ubicacion: json['ubicacion']?.toString(),
      fechaSiniestro: json['fecha_siniestro']?.toString(),
      prioridad: json['prioridad']?.toString(),
      estado: json['estado']?.toString(),
      descripcion: json['descripcion']?.toString(),
      referenciaExterna: json['referencia_externa']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ajustador_id': ajustadorId,
      'cliente_id': clienteId,
      'folio': folio,
      'tipo': tipo,
      'ubicacion': ubicacion,
      'fecha_siniestro': fechaSiniestro,
      'prioridad': prioridad,
      'estado': estado,
      'descripcion': descripcion,
      'referencia_externa': referenciaExterna,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ============================================================
// MODELO: SINIESTRO PARTE
// ============================================================

class SiniestroParte {
  final int id;
  final int? siniestroId;
  final String tipo;
  final String titulo;
  final Map<String, dynamic> contenidoJson;
  final String? estado;
  final String? fechaEvento;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  SiniestroParte({
    required this.id,
    this.siniestroId,
    required this.tipo,
    required this.titulo,
    required this.contenidoJson,
    this.estado,
    this.fechaEvento,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory SiniestroParte.fromJson(Map<String, dynamic> json) {
    return SiniestroParte(
      id: _toInt(json['id']) ?? 0,
      siniestroId: _toInt(json['siniestro_id']),
      tipo: json['tipo']?.toString() ?? 'general',
      titulo: json['titulo']?.toString() ?? 'Sin título',
      contenidoJson: _toMap(json['contenido_json']),
      estado: json['estado']?.toString(),
      fechaEvento: json['fecha_evento']?.toString(),
      createdBy: _toInt(json['created_by']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siniestro_id': siniestroId,
      'tipo': tipo,
      'titulo': titulo,
      'contenido_json': contenidoJson,
      'estado': estado,
      'fecha_evento': fechaEvento,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ============================================================
// MODELO: SINIESTRO TERCERO
// ============================================================

class SiniestroTercero {
  final int id;
  final int? siniestroId;
  final String nombre;
  final String? telefono;
  final String? placas;
  final String? aseguradora;
  final String? vehiculo;
  final String? versionHechos;
  final String? responsabilidad;
  final String? estado;
  final String? createdAt;
  final String? updatedAt;

  SiniestroTercero({
    required this.id,
    this.siniestroId,
    required this.nombre,
    this.telefono,
    this.placas,
    this.aseguradora,
    this.vehiculo,
    this.versionHechos,
    this.responsabilidad,
    this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory SiniestroTercero.fromJson(Map<String, dynamic> json) {
    return SiniestroTercero(
      id: _toInt(json['id']) ?? 0,
      siniestroId: _toInt(json['siniestro_id']),
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      telefono: json['telefono']?.toString(),
      placas: json['placas']?.toString(),
      aseguradora: json['aseguradora']?.toString(),
      vehiculo: json['vehiculo']?.toString(),
      versionHechos: json['version_hechos']?.toString(),
      responsabilidad: json['responsabilidad']?.toString(),
      estado: json['estado']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siniestro_id': siniestroId,
      'nombre': nombre,
      'telefono': telefono,
      'placas': placas,
      'aseguradora': aseguradora,
      'vehiculo': vehiculo,
      'version_hechos': versionHechos,
      'responsabilidad': responsabilidad,
      'estado': estado,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ============================================================
// HELPERS INTERNOS
// ============================================================

int? _toInt(dynamic value) {
  if (value == null) return null;

  if (value is int) return value;

  if (value is double) return value.toInt();

  return int.tryParse(value.toString());
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value == null) {
    return {};
  }

  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  if (value is String) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return {
        'texto': value,
      };
    }
  }

  return {};
}