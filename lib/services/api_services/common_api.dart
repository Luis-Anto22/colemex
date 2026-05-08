import 'package:file_picker/file_picker.dart';

import 'api_client.dart';

class CommonApi {
  final ApiClient client;

  CommonApi(this.client);

  // ==============================
  // PERFIL
  // ==============================

  Future<Map<String, dynamic>> getPerfil(int profesionalId) async {
    final res = await client.get(
      '/common/perfil',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener perfil');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  // ==============================
  // AGENDA / CITAS - LARAVEL
  // ==============================

  Future<List<dynamic>> getAgenda(int profesionalId) async {
    final res = await client.get(
      '/citas',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener agenda');
    }

    final data = res['data'] ?? res['citas'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<void> crearAgenda({
    required int profesionalId,
    required int clienteId,
    required String inicio,
    String? titulo,
    String? motivo,
    String? fin,
    String? tipo,
    String? ubicacion,
    String? enlaceReunion,
    String? notas,
    String? creadaPor,
    String? estado,
  }) async {
    final payload = <String, dynamic>{
      'profesional_id': '$profesionalId',
      'cliente_id': '$clienteId',
      'inicio': inicio,
      if (titulo != null && titulo.trim().isNotEmpty) 'titulo': titulo.trim(),
      if (motivo != null && motivo.trim().isNotEmpty) 'motivo': motivo.trim(),
      if (fin != null && fin.trim().isNotEmpty) 'fin': fin.trim(),
      if (tipo != null && tipo.trim().isNotEmpty) 'tipo': tipo.trim(),
      if (ubicacion != null && ubicacion.trim().isNotEmpty)
        'ubicacion': ubicacion.trim(),
      if (enlaceReunion != null && enlaceReunion.trim().isNotEmpty)
        'enlace_reunion': enlaceReunion.trim(),
      if (notas != null && notas.trim().isNotEmpty) 'notas': notas.trim(),
      if (creadaPor != null && creadaPor.trim().isNotEmpty)
        'creada_por': creadaPor.trim(),
      if (estado != null && estado.trim().isNotEmpty) 'estado': estado.trim(),
    };

    final res = await client.post('/citas', payload);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear cita');
    }
  }

  Future<Map<String, dynamic>> getCita(int citaId) async {
    final res = await client.get('/citas/$citaId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener cita');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  Future<void> actualizarCita({
    required int citaId,
    String? titulo,
    String? motivo,
    String? inicio,
    String? fin,
    String? estado,
    String? tipo,
    String? ubicacion,
    String? enlaceReunion,
    String? notas,
    String? canceladaPor,
    String? motivoCancelacion,
    String? fechaCancelacion,
  }) async {
    final payload = <String, dynamic>{
      if (titulo != null) 'titulo': titulo,
      if (motivo != null) 'motivo': motivo,
      if (inicio != null) 'inicio': inicio,
      if (fin != null) 'fin': fin,
      if (estado != null) 'estado': estado,
      if (tipo != null) 'tipo': tipo,
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (enlaceReunion != null) 'enlace_reunion': enlaceReunion,
      if (notas != null) 'notas': notas,
      if (canceladaPor != null) 'cancelada_por': canceladaPor,
      if (motivoCancelacion != null) 'motivo_cancelacion': motivoCancelacion,
      if (fechaCancelacion != null) 'fecha_cancelacion': fechaCancelacion,
    };

    final res = await client.put('/citas/$citaId', payload);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar cita');
    }
  }

  Future<void> actualizarEstadoCita({
    required int citaId,
    required String estado,
    String? canceladaPor,
    String? motivoCancelacion,
    String? fechaCancelacion,
  }) async {
    final payload = <String, dynamic>{
      'estado': estado,
      if (canceladaPor != null && canceladaPor.trim().isNotEmpty)
        'cancelada_por': canceladaPor.trim(),
      if (motivoCancelacion != null && motivoCancelacion.trim().isNotEmpty)
        'motivo_cancelacion': motivoCancelacion.trim(),
      if (fechaCancelacion != null && fechaCancelacion.trim().isNotEmpty)
        'fecha_cancelacion': fechaCancelacion.trim(),
    };

    final res = await client.post(
      '/citas/$citaId/estado',
      payload,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar estado de la cita');
    }
  }

  Future<void> eliminarCita(int citaId) async {
    final res = await client.delete('/citas/$citaId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al eliminar cita');
    }
  }

  // ==============================
  // HISTORIAL - LARAVEL
  // ==============================

  Future<List<dynamic>> getHistorial({
    required int profesionalId,
    required String perfil,
  }) async {
    Map<String, dynamic> res;

    try {
      // Ruta nueva Laravel
      res = await client.get('/casos/mis-casos/$profesionalId');
    } catch (_) {
      // Compatibilidad con ruta anterior
      res = await client.get(
        '/common/historial',
        params: {
          'profesional_id': profesionalId,
          'perfil': perfil,
        },
      );
    }

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener historial');
    }

    final data = res['data'] ?? res['casos'];

    if (data is List) {
      return data;
    }

    return [];
  }

  // ==============================
  // CONFIGURACION
  // ==============================

  Future<Map<String, dynamic>> getConfiguracion(int profesionalId) async {
    final res = await client.get(
      '/common/configuracion',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener configuración');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {
      'notificaciones': true,
      'compartir_ubicacion': false,
    };
  }

  Future<void> actualizarConfiguracion({
    required int profesionalId,
    required bool notificaciones,
    required bool compartirUbicacion,
  }) async {
    final res = await client.post(
      '/common/configuracion',
      {
        'profesional_id': '$profesionalId',
        'notificaciones': notificaciones ? '1' : '0',
        'compartir_ubicacion': compartirUbicacion ? '1' : '0',
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al guardar configuración');
    }
  }

  // ==============================
  // UBICACION
  // ==============================

  Future<Map<String, dynamic>> getUbicacion(int profesionalId) async {
    final res = await client.get(
      '/common/ubicacion',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener ubicación');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  Future<void> actualizarUbicacion({
    required int profesionalId,
    required double latitude,
    required double longitude,
  }) async {
    final res = await client.post(
      '/common/ubicacion',
      {
        'profesional_id': '$profesionalId',
        'latitude': '$latitude',
        'longitude': '$longitude',
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al guardar ubicación');
    }
  }

  // ==============================
  // INGRESOS - LARAVEL
  // ==============================

  Future<Map<String, dynamic>> getIngresos(int profesionalId) async {
    final res = await client.get(
      '/common/ingresos',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener ingresos');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {
      'total': 0,
      'pagado': 0,
      'pendiente': 0,
      'items': [],
    };
  }

  // ==============================
  // CLIENTES - LARAVEL
  // ==============================

  Future<List<dynamic>> getClientes() async {
    final res = await client.get('/clientes');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener clientes');
    }

    final data = res['data'] ?? res['clientes'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<List<dynamic>> getClientesActivos() async {
    final res = await client.get('/clientes/activos');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener clientes activos');
    }

    final data = res['data'] ?? res['clientes'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<Map<String, dynamic>> getCliente(int clienteId) async {
    final res = await client.get('/clientes/$clienteId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener cliente');
    }

    final data = res['data'] ?? res['cliente'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  // ==============================
  // CALIFICACIONES - LARAVEL
  // ==============================

  Future<Map<String, dynamic>> getCalificaciones(int profesionalId) async {
    final res = await client.get(
      '/common/calificaciones',
      params: {'profesional_id': profesionalId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener calificaciones');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {
      'items': [],
      'promedio': 0,
      'total': 0,
    };
  }

  Future<void> crearCalificacion({
    required int profesionalId,
    required int clienteId,
    required int estrellas,
    String comentario = '',
  }) async {
    final res = await client.post(
      '/common/calificaciones',
      {
        'profesional_id': profesionalId,
        'cliente_id': clienteId,
        'estrellas': estrellas,
        'comentario': comentario,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear calificación');
    }
  }

  // ==============================
  // DOCUMENTOS PERFIL
  // ==============================

  Future<void> subirDocumentoPerfil({
    required int profesionalId,
    required String tipo,
    required PlatformFile file,
    String? comentarios,
  }) async {
    final res = await client.postMultipart(
      '/common/perfil-documentos',
      fields: {
        'profesional_id': '$profesionalId',
        'tipo': tipo,
        if (comentarios != null && comentarios.trim().isNotEmpty)
          'comentarios': comentarios.trim(),
      },
      file: file,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al subir documento');
    }
  }

  // ==============================
  // PSICOLOGOS - PACIENTES
  // ==============================

  Future<List<dynamic>> getPacientesPsicologo(int psicologoId) async {
    final res = await client.get(
      '/psicologos/pacientes',
      params: {'psicologo_id': psicologoId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener pacientes');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<void> crearPacientePsicologo({
    required int psicologoId,
    required int clienteId,
    String origen = 'alta_profesional',
    String estado = 'activo',
    String? notas,
  }) async {
    final res = await client.post(
      '/psicologos/pacientes',
      {
        'psicologo_id': '$psicologoId',
        'cliente_id': '$clienteId',
        'origen': origen,
        'estado': estado,
        if (notas != null && notas.trim().isNotEmpty) 'notas': notas.trim(),
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al vincular paciente');
    }
  }

  Future<Map<String, dynamic>> getPacientePsicologo(int relacionId) async {
    final res = await client.get('/psicologos/pacientes/$relacionId');

    if (res['success'] != true) {
      throw Exception(
        res['message'] ?? 'Error al obtener paciente del psicólogo',
      );
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  Future<void> actualizarPacientePsicologo({
    required int relacionId,
    String? estado,
    String? notas,
  }) async {
    final payload = <String, dynamic>{
      if (estado != null) 'estado': estado,
      if (notas != null) 'notas': notas,
    };

    final res = await client.put('/psicologos/pacientes/$relacionId', payload);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar paciente');
    }
  }

  Future<void> eliminarPacientePsicologo(int relacionId) async {
    final res = await client.delete('/psicologos/pacientes/$relacionId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al eliminar paciente');
    }
  }

  // ==============================
  // PSICOLOGOS - EXPEDIENTES
  // ==============================

  Future<List<dynamic>> getExpedientesPsicologo(int psicologoId) async {
    final res = await client.get(
      '/psicologos/expedientes',
      params: {'psicologo_id': psicologoId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener expedientes');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<Map<String, dynamic>> getExpedientePsicologo(int expedienteId) async {
    final res = await client.get('/psicologos/expedientes/$expedienteId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener expediente');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  Future<void> crearExpedientePsicologo({
    required int psicologoId,
    required int clienteId,
    int? profesionalClienteId,
    String? motivoConsulta,
    String? antecedentes,
    String? diagnosticoInicial,
    String? objetivoGeneral,
    String? objetivosEspecificos,
    String? enfoqueTerapeutico,
    String? planTratamiento,
    String nivelRiesgo = 'bajo',
    String estado = 'activo',
    String? fechaApertura,
    String? notasGenerales,
  }) async {
    final res = await client.post(
      '/psicologos/expedientes',
      {
        'psicologo_id': '$psicologoId',
        'cliente_id': '$clienteId',
        if (profesionalClienteId != null)
          'profesional_cliente_id': '$profesionalClienteId',
        if (motivoConsulta != null) 'motivo_consulta': motivoConsulta,
        if (antecedentes != null) 'antecedentes': antecedentes,
        if (diagnosticoInicial != null)
          'diagnostico_inicial': diagnosticoInicial,
        if (objetivoGeneral != null) 'objetivo_general': objetivoGeneral,
        if (objetivosEspecificos != null)
          'objetivos_especificos': objetivosEspecificos,
        if (enfoqueTerapeutico != null)
          'enfoque_terapeutico': enfoqueTerapeutico,
        if (planTratamiento != null) 'plan_tratamiento': planTratamiento,
        'nivel_riesgo': nivelRiesgo,
        'estado': estado,
        if (fechaApertura != null) 'fecha_apertura': fechaApertura,
        if (notasGenerales != null) 'notas_generales': notasGenerales,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear expediente');
    }
  }

  Future<void> actualizarExpedientePsicologo({
    required int expedienteId,
    String? motivoConsulta,
    String? antecedentes,
    String? diagnosticoInicial,
    String? objetivoGeneral,
    String? objetivosEspecificos,
    String? enfoqueTerapeutico,
    String? planTratamiento,
    String? nivelRiesgo,
    String? estado,
    String? fechaApertura,
    String? fechaCierre,
    String? notasGenerales,
  }) async {
    final payload = <String, dynamic>{
      if (motivoConsulta != null) 'motivo_consulta': motivoConsulta,
      if (antecedentes != null) 'antecedentes': antecedentes,
      if (diagnosticoInicial != null)
        'diagnostico_inicial': diagnosticoInicial,
      if (objetivoGeneral != null) 'objetivo_general': objetivoGeneral,
      if (objetivosEspecificos != null)
        'objetivos_especificos': objetivosEspecificos,
      if (enfoqueTerapeutico != null)
        'enfoque_terapeutico': enfoqueTerapeutico,
      if (planTratamiento != null) 'plan_tratamiento': planTratamiento,
      if (nivelRiesgo != null) 'nivel_riesgo': nivelRiesgo,
      if (estado != null) 'estado': estado,
      if (fechaApertura != null) 'fecha_apertura': fechaApertura,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (notasGenerales != null) 'notas_generales': notasGenerales,
    };

    final res = await client.put(
      '/psicologos/expedientes/$expedienteId',
      payload,
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar expediente');
    }
  }

  Future<void> eliminarExpedientePsicologo(int expedienteId) async {
    final res = await client.delete('/psicologos/expedientes/$expedienteId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al eliminar expediente');
    }
  }

  // ==============================
  // PSICOLOGOS - SESIONES
  // ==============================

  Future<List<dynamic>> getSesionesPsicologo({
    required int psicologoId,
    int? clienteId,
    int? expedienteId,
    String? tipoSesion,
  }) async {
    final params = <String, dynamic>{
      'psicologo_id': psicologoId,
    };

    if (clienteId != null) params['cliente_id'] = clienteId;
    if (expedienteId != null) params['expediente_id'] = expedienteId;

    if (tipoSesion != null && tipoSesion.isNotEmpty) {
      params['tipo_sesion'] = tipoSesion;
    }

    final res = await client.get('/psicologos/sesiones', params: params);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener sesiones');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<Map<String, dynamic>> getSesionPsicologo(int sesionId) async {
    final res = await client.get('/psicologos/sesiones/$sesionId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener sesión');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  Future<void> crearSesionPsicologo({
    required int psicologoId,
    required int clienteId,
    required int expedienteId,
    required String fechaSesion,
    int? profesionalClienteId,
    String tipoSesion = 'seguimiento',
    String modalidad = 'presencial',
    String? estadoEmocional,
    String? nivelAnimo,
    String nivelRiesgo = 'bajo',
    String? evaluacionNombre,
    String? evaluacionResultado,
    String? avances,
    String? retrocesos,
    String? observaciones,
    String? tareasTerapeuticas,
    String? objetivoSesion,
    String? acuerdosSesion,
    String estado = 'registrada',
  }) async {
    final res = await client.post(
      '/psicologos/sesiones',
      {
        'psicologo_id': '$psicologoId',
        'cliente_id': '$clienteId',
        'expediente_id': '$expedienteId',
        'fecha_sesion': fechaSesion,
        if (profesionalClienteId != null)
          'profesional_cliente_id': '$profesionalClienteId',
        'tipo_sesion': tipoSesion,
        'modalidad': modalidad,
        if (estadoEmocional != null) 'estado_emocional': estadoEmocional,
        if (nivelAnimo != null) 'nivel_animo': nivelAnimo,
        'nivel_riesgo': nivelRiesgo,
        if (evaluacionNombre != null) 'evaluacion_nombre': evaluacionNombre,
        if (evaluacionResultado != null)
          'evaluacion_resultado': evaluacionResultado,
        if (avances != null) 'avances': avances,
        if (retrocesos != null) 'retrocesos': retrocesos,
        if (observaciones != null) 'observaciones': observaciones,
        if (tareasTerapeuticas != null)
          'tareas_terapeuticas': tareasTerapeuticas,
        if (objetivoSesion != null) 'objetivo_sesion': objetivoSesion,
        if (acuerdosSesion != null) 'acuerdos_sesion': acuerdosSesion,
        'estado': estado,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear sesión');
    }
  }

  Future<void> actualizarSesionPsicologo({
    required int sesionId,
    String? fechaSesion,
    String? tipoSesion,
    String? modalidad,
    String? estadoEmocional,
    String? nivelAnimo,
    String? nivelRiesgo,
    String? evaluacionNombre,
    String? evaluacionResultado,
    String? avances,
    String? retrocesos,
    String? observaciones,
    String? tareasTerapeuticas,
    String? objetivoSesion,
    String? acuerdosSesion,
    String? estado,
  }) async {
    final payload = <String, dynamic>{
      if (fechaSesion != null) 'fecha_sesion': fechaSesion,
      if (tipoSesion != null) 'tipo_sesion': tipoSesion,
      if (modalidad != null) 'modalidad': modalidad,
      if (estadoEmocional != null) 'estado_emocional': estadoEmocional,
      if (nivelAnimo != null) 'nivel_animo': nivelAnimo,
      if (nivelRiesgo != null) 'nivel_riesgo': nivelRiesgo,
      if (evaluacionNombre != null) 'evaluacion_nombre': evaluacionNombre,
      if (evaluacionResultado != null)
        'evaluacion_resultado': evaluacionResultado,
      if (avances != null) 'avances': avances,
      if (retrocesos != null) 'retrocesos': retrocesos,
      if (observaciones != null) 'observaciones': observaciones,
      if (tareasTerapeuticas != null)
        'tareas_terapeuticas': tareasTerapeuticas,
      if (objetivoSesion != null) 'objetivo_sesion': objetivoSesion,
      if (acuerdosSesion != null) 'acuerdos_sesion': acuerdosSesion,
      if (estado != null) 'estado': estado,
    };

    final res = await client.put('/psicologos/sesiones/$sesionId', payload);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar sesión');
    }
  }

  Future<void> eliminarSesionPsicologo(int sesionId) async {
    final res = await client.delete('/psicologos/sesiones/$sesionId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al eliminar sesión');
    }
  }

  Future<List<dynamic>> getEvaluacionesPsicologo(int psicologoId) async {
    final res = await client.get(
      '/psicologos/evaluaciones',
      params: {'psicologo_id': psicologoId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener evaluaciones');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<List<dynamic>> getTareasPsicologo(int psicologoId) async {
    final res = await client.get(
      '/psicologos/tareas',
      params: {'psicologo_id': psicologoId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener tareas');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<List<dynamic>> getSeguimientosPsicologo(int psicologoId) async {
    final res = await client.get(
      '/psicologos/seguimientos',
      params: {'psicologo_id': psicologoId},
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener seguimientos');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  // ==============================
  // PSICOLOGOS - REPORTES
  // ==============================

  Future<List<dynamic>> getReportesPsicologo({
    required int psicologoId,
    int? clienteId,
    int? expedienteId,
  }) async {
    final params = <String, dynamic>{
      'psicologo_id': psicologoId,
    };

    if (clienteId != null) params['cliente_id'] = clienteId;
    if (expedienteId != null) params['expediente_id'] = expedienteId;

    final res = await client.get('/psicologos/reportes', params: params);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener reportes');
    }

    final data = res['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Future<Map<String, dynamic>> getReportePsicologo(int reporteId) async {
    final res = await client.get('/psicologos/reportes/$reporteId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al obtener reporte');
    }

    final data = res['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  Future<void> crearReportePsicologo({
    required int psicologoId,
    required int clienteId,
    required int expedienteId,
    int? profesionalClienteId,
    String tipoReporte = 'reporte_evolucion',
    String? fechaReporte,
    String estado = 'borrador',
    String? motivo,
    String? conclusiones,
    String? recomendaciones,
    String? observaciones,
    String? archivoUrl,
  }) async {
    final res = await client.post(
      '/psicologos/reportes',
      {
        'psicologo_id': '$psicologoId',
        'cliente_id': '$clienteId',
        'expediente_id': '$expedienteId',
        if (profesionalClienteId != null)
          'profesional_cliente_id': '$profesionalClienteId',
        'tipo_reporte': tipoReporte,
        if (fechaReporte != null) 'fecha_reporte': fechaReporte,
        'estado': estado,
        if (motivo != null) 'motivo': motivo,
        if (conclusiones != null) 'conclusiones': conclusiones,
        if (recomendaciones != null) 'recomendaciones': recomendaciones,
        if (observaciones != null) 'observaciones': observaciones,
        if (archivoUrl != null) 'archivo_url': archivoUrl,
      },
    );

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al crear reporte');
    }
  }

  Future<void> actualizarReportePsicologo({
    required int reporteId,
    String? tipoReporte,
    String? fechaReporte,
    String? estado,
    String? motivo,
    String? conclusiones,
    String? recomendaciones,
    String? observaciones,
    String? archivoUrl,
  }) async {
    final payload = <String, dynamic>{
      if (tipoReporte != null) 'tipo_reporte': tipoReporte,
      if (fechaReporte != null) 'fecha_reporte': fechaReporte,
      if (estado != null) 'estado': estado,
      if (motivo != null) 'motivo': motivo,
      if (conclusiones != null) 'conclusiones': conclusiones,
      if (recomendaciones != null) 'recomendaciones': recomendaciones,
      if (observaciones != null) 'observaciones': observaciones,
      if (archivoUrl != null) 'archivo_url': archivoUrl,
    };

    final res = await client.put('/psicologos/reportes/$reporteId', payload);

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al actualizar reporte');
    }
  }

  Future<void> eliminarReportePsicologo(int reporteId) async {
    final res = await client.delete('/psicologos/reportes/$reporteId');

    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Error al eliminar reporte');
    }
  }
}