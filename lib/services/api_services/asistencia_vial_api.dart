import 'api_client.dart';

class AsistenciaVialApi {
  final ApiClient client;

  AsistenciaVialApi(this.client);

  // =========================================================
  // TIPOS DE AUXILIO
  // =========================================================

  Future<List<dynamic>> getTiposAuxilio() async {
    final res = await client.get('/asistencia-vial/tipos-auxilio');

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al obtener tipos de auxilio',
      );
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  // =========================================================
  // SOLICITUDES PENDIENTES
  // =========================================================

  Future<List<dynamic>> getSolicitudesPendientes() async {
    final res = await client.get('/asistencia-vial/solicitudes');

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al obtener solicitudes',
      );
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  // =========================================================
  // SERVICIO EN CURSO
  // =========================================================

  Future<Map<String, dynamic>?> getServicioEnCurso(
    int profesionalId,
  ) async {
    final res = await client.get(
      '/asistencia-vial/servicio-en-curso',
      params: {
        'profesional_id': profesionalId,
      },
    );

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al obtener servicio',
      );
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return null;
  }

  // =========================================================
  // CREAR SOLICITUD
  // =========================================================

  Future<void> crearSolicitud({
    required int clienteId,
    required int tipoAuxilioId,

    String? vehiculoMarca,
    String? vehiculoModelo,
    String? vehiculoAnio,
    String? vehiculoColor,
    String? placas,

    String? descripcion,

    double? latitud,
    double? longitud,
    String? direccion,
  }) async {
    final payload = <String, dynamic>{
      'cliente_id': clienteId,
      'tipo_auxilio_id': tipoAuxilioId,

      if (vehiculoMarca != null) 'vehiculo_marca': vehiculoMarca,
      if (vehiculoModelo != null) 'vehiculo_modelo': vehiculoModelo,
      if (vehiculoAnio != null) 'vehiculo_anio': vehiculoAnio,
      if (vehiculoColor != null) 'vehiculo_color': vehiculoColor,
      if (placas != null) 'placas': placas,

      if (descripcion != null) 'descripcion': descripcion,

      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (direccion != null) 'direccion': direccion,
    };

    final res = await client.post(
      '/asistencia-vial/servicios',
      payload,
    );

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al crear solicitud',
      );
    }
  }

  // =========================================================
  // ACEPTAR SERVICIO
  // =========================================================

  Future<void> aceptarServicio({
    required int servicioId,
    required int profesionalId,
  }) async {
    final res = await client.post(
      '/asistencia-vial/servicios/$servicioId/aceptar',
      {
        'profesional_id': profesionalId,
      },
    );

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al aceptar servicio',
      );
    }
  }

  // =========================================================
  // RECHAZAR SERVICIO
  // =========================================================

  Future<void> rechazarServicio(int servicioId) async {
    final res = await client.post(
      '/asistencia-vial/servicios/$servicioId/rechazar',
      {},
    );

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al rechazar servicio',
      );
    }
  }

  // =========================================================
  // CAMBIAR ESTADO
  // =========================================================

  Future<void> cambiarEstadoServicio({
    required int servicioId,
    required String estado,
    double? costo,
  }) async {
    final payload = <String, dynamic>{
      'estado': estado,
      if (costo != null) 'costo': costo,
    };

    final res = await client.post(
      '/asistencia-vial/servicios/$servicioId/estado',
      payload,
    );

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al cambiar estado',
      );
    }
  }

  // =========================================================
  // HISTORIAL
  // =========================================================

  Future<List<dynamic>> getHistorial(
    int profesionalId,
  ) async {
    final res = await client.get(
      '/asistencia-vial/historial',
      params: {
        'profesional_id': profesionalId,
      },
    );

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al obtener historial',
      );
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  // =========================================================
  // DETALLE SERVICIO
  // =========================================================

   Future<Map<String, dynamic>?> getServicio(
    int servicioId,
  ) async {
    final res = await client.get(
      '/asistencia-vial/servicios/$servicioId',
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener servicio');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return null;
  }

  // =========================================================
  // VEHÍCULOS ATENDIDOS
  // =========================================================

  Future<List<dynamic>> getVehiculosAtendidos(int profesionalId) async {
    final res = await client.get(
      '/asistencia-vial/vehiculos/$profesionalId',
    );

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al obtener vehículos atendidos',
      );
    }

    final data = res['vehiculos'];

    if (data is List) {
      return data;
    }

    return [];
  }

  // =========================================================
  // RESUMEN DEL DÍA
  // =========================================================

  Future<Map<String, dynamic>> getResumenDia(int profesionalId) async {
    final res = await client.get(
      '/asistencia-vial/resumen-dia',
      params: {
        'profesional_id': profesionalId,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener resumen del día');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {
      'servicios': 0,
      'ingresos': 0,
      'solicitudes': 0,
    };
  }
}