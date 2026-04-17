<<<<<<< Updated upstream:lib/services/api_client.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  // Ajusta si cambia tu ruta base
  final String baseUrl = 'https://corporativolegaldigital.com/api';

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, '$v')),
      },
    );
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? params}) async {
    final res = await http.get(_buildUri(path, params));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) return body;
      throw Exception('Respuesta inesperada');
    } else {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> data) async {
    final res = await http.post(
      _buildUri(path),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: data.map((k, v) => MapEntry(k, '$v')),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) return body;
      throw Exception('Respuesta inesperada');
    } else {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required File file,
    String fieldName = 'archivo',
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(fields)
      ..files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) return body;
      throw Exception('Respuesta inesperada');
    } else {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}
=======
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// Cliente HTTP base compartido por los servicios de lib/services/api_services/.
// Ejemplo de cadena de uso:
// Pantalla -> CommonApi -> ApiClient -> endpoint del backend.
class ApiClient {
  static const String _defaultBaseUrl =
      'https://corporativolegaldigital.com/api';
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = _normalizarBaseUrl(
          baseUrl ??
              const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: _defaultBaseUrl,
              ),
        );

  // Normaliza la URL base para evitar dobles slash al concatenar rutas.
  static String _normalizarBaseUrl(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) return _defaultBaseUrl;
    return clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalizedPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, '$v')),
      },
    );
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? params}) async {
    final res = await http.get(_buildUri(path, params));
    return _parseResponse(res);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      _buildUri(path),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: data.map((k, v) => MapEntry(k, '$v')),
    );
    return _parseResponse(res);
  }

  // Se usa para fallback contra endpoints REST de Laravel.
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      _buildUri(path),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: data.map((k, v) => MapEntry(k, '$v')),
    );
    return _parseResponse(res);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required File file,
    String fieldName = 'archivo',
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(fields)
      ..files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _parseResponse(res);
  }

  Map<String, dynamic> _parseResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = _tryDecodeJson(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('Respuesta inesperada');
    }
    throw Exception(_buildHttpError(res));
  }

  dynamic _tryDecodeJson(String rawBody) {
    try {
      return jsonDecode(rawBody);
    } catch (_) {
      return null;
    }
  }

  // Recorta HTML/errores largos para que el mensaje sea legible en SnackBars.
  String _buildHttpError(http.Response res) {
    final body = res.body.trim();
    final preview = body.length > 220 ? '${body.substring(0, 220)}...' : body;
    return 'HTTP ${res.statusCode}: $preview';
  }
}
>>>>>>> Stashed changes:lib/services/api_services/api_client.dart
