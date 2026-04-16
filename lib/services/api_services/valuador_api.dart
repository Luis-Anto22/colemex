import 'dart:io';
import 'api_client.dart';

class ValuadorApi {
  final ApiClient client;

  ValuadorApi(this.client);

  // ===============================
  // SOLICITUDES (casos pendientes)
  // ===============================
  Future<List<dynamic>> getSolicitudes(int valuadorId) async {
    try {
      final res = await client.get(
        '/valuador/solicitudes.php',
        params: {'valuador_id': valuadorId},
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al obtener solicitudes');
      }

      return (res['data'] as List<dynamic>? ?? []);
    } catch (e) {
      throw Exception('Error de conexión al obtener solicitudes');
    }
  }

  Future<void> actualizarEstadoSolicitud({
    required int id,
    required String estado,
  }) async {
    try {
      final res = await client.post('/valuador/solicitudes.php', {
        'action': 'update_estado',
        'id': '$id',
        'estado': estado,
      });

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
        '/valuador/avaluos.php',
        params: {'valuador_id': valuadorId},
      );

      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Error al obtener avalúos');
      }

      return (res['data'] as List<dynamic>? ?? []);
    } catch (e) {
      throw Exception('Error de conexión al obtener avalúos');
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
      final Map<String, String> data = {
        'action': 'save',
        'valuador_id': '$valuadorId',
        'caso_id': '$casoId',
        'estado': estado,
        'notas': notas ?? '',
      };

      if (valorEstimado != null) {
        data['valor_estimado'] = valorEstimado.toString();
      }

      final res = await client.post('/valuador/avaluos.php', data);

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
        '/valuador/reportes.php',
        params: {'caso_id': casoId},
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
    required File file,
    String? descripcion,
  }) async {
    try {
      if (!file.existsSync()) {
        throw Exception("El archivo no existe");
      }

      final res = await client.postMultipart(
        '/valuador/reportes.php',
        fields: {
          'caso_id': '$casoId',
          'profesional_id': '$valuadorId',
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

  // ===============================
  // FOTOS
  // ===============================
  Future<List<dynamic>> getFotos(int casoId) async {
    try {
      final res = await client.get(
        '/valuador/fotos.php',
        params: {'caso_id': casoId},
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
    required File file,
    String? descripcion,
  }) async {
    try {
      if (!file.existsSync()) {
        throw Exception("El archivo no existe");
      }

      final res = await client.postMultipart(
        '/valuador/fotos.php',
        fields: {
          'caso_id': '$casoId',
          'profesional_id': '$valuadorId',
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
}