import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ApiClient {
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

  Map<String, dynamic> _decodeResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body);

      if (body is Map<String, dynamic>) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return body;
        }

        return {
          'success': false,
          'message': body['message'] ?? 'HTTP ${res.statusCode}',
          'errors': body['errors'],
        };
      }

      return {
        'success': false,
        'message': 'Respuesta inesperada del servidor',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'HTTP ${res.statusCode}: ${res.body}',
      };
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final res = await http.get(
      _buildUri(path, params),
      headers: {
        'Accept': 'application/json',
      },
    );

    return _decodeResponse(res);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      _buildUri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data.map((k, v) => MapEntry(k, '$v')),
    );

    return _decodeResponse(res);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      _buildUri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data.map((k, v) => MapEntry(k, '$v')),
    );

    return _decodeResponse(res);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await http.delete(
      _buildUri(path),
      headers: {
        'Accept': 'application/json',
      },
    );

    return _decodeResponse(res);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required PlatformFile file,
    String fieldName = 'archivo',
  }) async {
    final uri = _buildUri(path);

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
    });

    request.fields.addAll(fields);

    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          file.bytes!,
          filename: file.name,
        ),
      );
    } else if (file.path != null && file.path!.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path!,
          filename: file.name,
        ),
      );
    } else {
      return {
        'success': false,
        'message': 'No se pudo leer el archivo seleccionado',
      };
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    return _decodeResponse(res);
  }
  Future<Map<String, dynamic>> archivarCasoCliente({
  required int casoId,
  required int clienteId,
}) async {
  return post(
    '/common/casos-cliente/$casoId/archivar',
    {
      'cliente_id': clienteId,
    },
  );
}

Future<Map<String, dynamic>> eliminarCasoCliente({
  required int casoId,
  required int clienteId,
}) async {
  return post(
    '/common/casos-cliente/$casoId/eliminar',
    {
      'cliente_id': clienteId,
    },
  );
}
}