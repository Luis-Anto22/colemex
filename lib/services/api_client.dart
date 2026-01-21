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
