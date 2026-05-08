import 'package:file_picker/file_picker.dart';

import 'api_client.dart';

class ValuadorApi {
  final ApiClient client;

  ValuadorApi(this.client);

  // ===============================
  // SOLICITUDES
  // ===============================
  Future<List<dynamic>> getSolicitudes(int valuadorId) async {
    try {
      final res = await client.get(
        '/valuador/solicitudes',
        params: {
          'valuador_id': valuadorId,
        },
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al obtener solicitudes');
      }

      final data = res['data'];

      if (data is List) {
        return data;
      }

      return [];
    } catch (e) {
      throw Exception('Error de conexión al obtener solicitudes: $e');
    }
  }

  Future<void> actualizarEstadoSolicitud({
    required int id,
    required String estado,
  }) async {
    try {
      final res = await client.post(
        '/valuador/solicitudes/$id/estado',
        {
          'estado': estado,
        },
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al actualizar solicitud');
      }
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  // ===============================
  // AVALÚOS
  // ===============================
  Future<List<dynamic>> getAvaluos(int valuadorId) async {
    try {
      final res = await client.get(
        '/valuador/avaluos',
        params: {
          'valuador_id': valuadorId,
        },
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al obtener avalúos');
      }

      final data = res['data'];

      if (data is List) {
        return data;
      }

      return [];
    } catch (e) {
      throw Exception('Error de conexión al obtener avalúos: $e');
    }
  }

  Future<void> guardarAvaluo({
    required int valuadorId,
    required int casoId,
    required String estado,
    double? valorEstimado,
    String? notas,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'valuador_id': '$valuadorId',
        'caso_id': '$casoId',
        'estado': estado,
        'notas': notas ?? '',
      };

      if (valorEstimado != null) {
        data['valor_estimado'] = '$valorEstimado';
      }

      final res = await client.post(
        '/valuador/avaluos',
        data,
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al guardar avalúo');
      }
    } catch (e) {
      throw Exception('Error al guardar avalúo: $e');
    }
  }

  // ===============================
  // REPORTES
  // ===============================
  Future<List<dynamic>> getReportes(int casoId) async {
    try {
      final res = await client.get(
        '/valuador/reportes',
        params: {
          'caso_id': casoId,
        },
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al obtener reportes');
      }

      return (res['data'] as List<dynamic>? ?? []);
    } catch (e) {
      throw Exception('Error al obtener reportes: $e');
    }
  }

  Future<void> subirReporte({
    required int casoId,
    required int valuadorId,
    required PlatformFile file,
    String? descripcion,
  }) async {
    try {
      final res = await client.postMultipart(
        '/valuador/reportes',
        fields: {
          'caso_id': '$casoId',
          'profesional_id': '$valuadorId',
          'valuador_id': '$valuadorId',
          'descripcion': descripcion ?? '',
        },
        file: file,
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al subir reporte');
      }
    } catch (e) {
      throw Exception('Error al subir reporte: $e');
    }
  }

  Future<void> eliminarReporte({
    required int reporteId,
  }) async {
    try {
      final res = await client.delete(
        '/valuador/reportes/$reporteId',
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al eliminar reporte');
      }
    } catch (e) {
      throw Exception('Error al eliminar reporte: $e');
    }
  }

  // ===============================
  // FOTOS / EVIDENCIA FOTOGRÁFICA
  // ===============================
  Future<List<dynamic>> getFotos(int casoId) async {
    try {
      final res = await client.get(
        '/valuador/fotos',
        params: {
          'caso_id': casoId,
        },
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al obtener fotos');
      }

      return (res['data'] as List<dynamic>? ?? []);
    } catch (e) {
      throw Exception('Error al obtener fotos: $e');
    }
  }

  Future<void> subirFoto({
    required int casoId,
    required int valuadorId,
    required PlatformFile file,
    String? descripcion,
  }) async {
    try {
      final res = await client.postMultipart(
        '/valuador/fotos',
        fields: {
          'caso_id': '$casoId',
          'profesional_id': '$valuadorId',
          'valuador_id': '$valuadorId',
          'descripcion': descripcion ?? '',
        },
        file: file,
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al subir foto');
      }
    } catch (e) {
      throw Exception('Error al subir foto: $e');
    }
  }

  Future<void> eliminarFoto({
    required int fotoId,
  }) async {
    try {
      final res = await client.delete(
        '/valuador/fotos/$fotoId',
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al eliminar foto');
      }
    } catch (e) {
      throw Exception('Error al eliminar foto: $e');
    }
  }
}