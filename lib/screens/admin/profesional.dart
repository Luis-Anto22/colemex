class Profesional {
  final int id;
  final String nombre;
  final String correo;
  final String telefono;
  final String perfil;

  final int? especialidadId;
  final String? especialidadNombre;

  final String ciudad;
  final String foto;
  final int verificado;
  final String estado;
  final DateTime fechaRegistro;

  final double? latitude;
  final double? longitude;

  // Campos nuevos del flujo admin / pagos / auditoría
  final String estadoProceso;
  final int? planId;
  final int pagoConfirmado;
  final DateTime? fechaPago;
  final int documentosSubidos;
  final DateTime? fechaDocumentos;
  final int? auditorId;
  final DateTime? fechaVerificacion;
  final String motivoRechazo;

  Profesional({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.perfil,
    this.especialidadId,
    this.especialidadNombre,
    required this.ciudad,
    required this.foto,
    required this.verificado,
    required this.estado,
    required this.fechaRegistro,
    this.latitude,
    this.longitude,
    required this.estadoProceso,
    this.planId,
    required this.pagoConfirmado,
    this.fechaPago,
    required this.documentosSubidos,
    this.fechaDocumentos,
    this.auditorId,
    this.fechaVerificacion,
    required this.motivoRechazo,
  });

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: _toInt(json['id']),
      nombre: _toStringValue(json['nombre']),
      correo: _toStringValue(json['correo']),
      telefono: _toStringValue(json['telefono']),
      perfil: _toStringValue(json['perfil']),

      especialidadId: _toNullableInt(json['especialidad_id']),
      especialidadNombre: _resolverEspecialidadNombre(json),

      ciudad: _toStringValue(json['ciudad']),
      foto: _toStringValue(json['foto']),
      verificado: _toInt(json['verificado']),
      estado: _toStringValue(json['estado'], fallback: 'disponible'),
      fechaRegistro: _toDateTime(json['fecha_registro']) ?? DateTime.now(),

      // Lee ambos formatos por seguridad:
      // Laravel/MySQL: latitud, longitud
      // Flutter anterior: latitude, longitude
      latitude: _toNullableDouble(json['latitude'] ?? json['latitud']),
      longitude: _toNullableDouble(json['longitude'] ?? json['longitud']),

      estadoProceso: _toStringValue(
        json['estado_proceso'],
        fallback: 'verificado',
      ),
      planId: _toNullableInt(json['plan_id']),
      pagoConfirmado: _toInt(json['pago_confirmado'], fallback: 1),
      fechaPago: _toDateTime(json['fecha_pago']),
      documentosSubidos: _toInt(json['documentos_subidos']),
      fechaDocumentos: _toDateTime(json['fecha_documentos']),
      auditorId: _toNullableInt(json['auditor_id']),
      fechaVerificacion: _toDateTime(json['fecha_verificacion']),
      motivoRechazo: _toStringValue(json['motivo_rechazo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'perfil': perfil,
      'especialidad_id': especialidadId,
      'especialidad': especialidadNombre,
      'especialidad_nombre': especialidadNombre,
      'ciudad': ciudad,
      'foto': foto,
      'verificado': verificado,
      'estado': estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'latitud': latitude,
      'longitud': longitude,
      'latitude': latitude,
      'longitude': longitude,
      'estado_proceso': estadoProceso,
      'plan_id': planId,
      'pago_confirmado': pagoConfirmado,
      'fecha_pago': fechaPago?.toIso8601String(),
      'documentos_subidos': documentosSubidos,
      'fecha_documentos': fechaDocumentos?.toIso8601String(),
      'auditor_id': auditorId,
      'fecha_verificacion': fechaVerificacion?.toIso8601String(),
      'motivo_rechazo': motivoRechazo,
    };
  }

  Profesional copyWith({
    int? id,
    String? nombre,
    String? correo,
    String? telefono,
    String? perfil,
    int? especialidadId,
    String? especialidadNombre,
    String? ciudad,
    String? foto,
    int? verificado,
    String? estado,
    DateTime? fechaRegistro,
    double? latitude,
    double? longitude,
    String? estadoProceso,
    int? planId,
    int? pagoConfirmado,
    DateTime? fechaPago,
    int? documentosSubidos,
    DateTime? fechaDocumentos,
    int? auditorId,
    DateTime? fechaVerificacion,
    String? motivoRechazo,
  }) {
    return Profesional(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      perfil: perfil ?? this.perfil,
      especialidadId: especialidadId ?? this.especialidadId,
      especialidadNombre: especialidadNombre ?? this.especialidadNombre,
      ciudad: ciudad ?? this.ciudad,
      foto: foto ?? this.foto,
      verificado: verificado ?? this.verificado,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      estadoProceso: estadoProceso ?? this.estadoProceso,
      planId: planId ?? this.planId,
      pagoConfirmado: pagoConfirmado ?? this.pagoConfirmado,
      fechaPago: fechaPago ?? this.fechaPago,
      documentosSubidos: documentosSubidos ?? this.documentosSubidos,
      fechaDocumentos: fechaDocumentos ?? this.fechaDocumentos,
      auditorId: auditorId ?? this.auditorId,
      fechaVerificacion: fechaVerificacion ?? this.fechaVerificacion,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
    );
  }

  static String? _resolverEspecialidadNombre(Map<String, dynamic> json) {
    final especialidadNombre = json['especialidad_nombre'];
    if (especialidadNombre != null &&
        especialidadNombre.toString().trim().isNotEmpty) {
      return especialidadNombre.toString();
    }

    final especialidad = json['especialidad'];

    if (especialidad is Map<String, dynamic>) {
      return _toStringValue(especialidad['nombre']);
    }

    if (especialidad != null && especialidad.toString().trim().isNotEmpty) {
      return especialidad.toString();
    }

    return null;
  }

  static String _toStringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;

    if (value is int) return value;

    if (value is bool) return value ? 1 : 0;

    return int.tryParse(value.toString()) ?? fallback;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    return int.tryParse(text);
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    return double.tryParse(text);
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    return DateTime.tryParse(text);
  }
}