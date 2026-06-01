class InmuebleModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String tipoOperacion;
  final String tipoInmueble;
  final String estado;
  final String ubicacion;
  final double precio;
  final int recamaras;
  final int banos;
  final int estacionamientos;
  final double metrosConstruccion;
  final double metrosTerreno;
  final int antiguedad;
  final bool amueblado;
  final bool mascotasPermitidas;
  final bool aceptaCredito;
  final double deposito;
  final double? latitud;
  final double? longitud;
  final double calificacionPromedio;
  final int totalCalificaciones;
  final double? distanciaKm;
  final int? clienteId;
  final int? agenteId;
  final String? fechaRegistro;
  final List<InmuebleArchivoModel> fotos;
  final List<InmuebleArchivoModel> documentos;

  InmuebleModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipoOperacion,
    required this.tipoInmueble,
    required this.estado,
    required this.ubicacion,
    required this.precio,
    required this.recamaras,
    required this.banos,
    required this.estacionamientos,
    required this.metrosConstruccion,
    required this.metrosTerreno,
    required this.antiguedad,
    required this.amueblado,
    required this.mascotasPermitidas,
    required this.aceptaCredito,
    required this.deposito,
    required this.latitud,
    required this.longitud,
    required this.calificacionPromedio,
    required this.totalCalificaciones,
    required this.distanciaKm,
    required this.clienteId,
    required this.agenteId,
    required this.fechaRegistro,
    required this.fotos,
    required this.documentos,
  });

  factory InmuebleModel.fromJson(Map<String, dynamic> json) {
    return InmuebleModel(
      id: _toInt(json['id']),
      titulo: _toString(json['titulo']),
      descripcion: _toString(json['descripcion']),
      tipoOperacion: _toString(json['tipo_operacion']),
      tipoInmueble: _toString(json['tipo_inmueble'], fallback: 'casa'),
      estado: _toString(json['estado'], fallback: 'disponible'),
      ubicacion: _toString(json['ubicacion']),
      precio: _toDouble(json['precio']),
      recamaras: _toInt(json['recamaras']),
      banos: _toInt(json['banos']),
      estacionamientos: _toInt(json['estacionamientos']),
      metrosConstruccion: _toDouble(json['metros_construccion']),
      metrosTerreno: _toDouble(json['metros_terreno']),
      antiguedad: _toInt(json['antiguedad']),
      amueblado: _toBool(json['amueblado']),
      mascotasPermitidas: _toBool(json['mascotas_permitidas']),
      aceptaCredito: _toBool(json['acepta_credito']),
      deposito: _toDouble(json['deposito']),
      latitud: _toNullableDouble(json['latitud']),
      longitud: _toNullableDouble(json['longitud']),
      calificacionPromedio: _toDouble(json['calificacion_promedio']),
      totalCalificaciones: _toInt(json['total_calificaciones']),
      distanciaKm: _toNullableDouble(json['distancia_km']),
      clienteId: _toNullableInt(json['cliente_id']),
      agenteId: _toNullableInt(json['agente_id']),
      fechaRegistro: json['fecha_registro']?.toString(),
      fotos: _parseArchivos(json['fotos']),
      documentos: _parseArchivos(json['documentos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo_operacion': tipoOperacion,
      'tipo_inmueble': tipoInmueble,
      'estado': estado,
      'ubicacion': ubicacion,
      'precio': precio,
      'recamaras': recamaras,
      'banos': banos,
      'estacionamientos': estacionamientos,
      'metros_construccion': metrosConstruccion,
      'metros_terreno': metrosTerreno,
      'antiguedad': antiguedad,
      'amueblado': amueblado ? 1 : 0,
      'mascotas_permitidas': mascotasPermitidas ? 1 : 0,
      'acepta_credito': aceptaCredito ? 1 : 0,
      'deposito': deposito,
      'latitud': latitud,
      'longitud': longitud,
      'calificacion_promedio': calificacionPromedio,
      'total_calificaciones': totalCalificaciones,
      'distancia_km': distanciaKm,
      'cliente_id': clienteId,
      'agente_id': agenteId,
      'fecha_registro': fechaRegistro,
      'fotos': fotos.map((e) => e.toJson()).toList(),
      'documentos': documentos.map((e) => e.toJson()).toList(),
    };
  }

  String get precioFormateado {
    final value = precio.toStringAsFixed(0);
    final chars = value.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }

    final formatted = buffer.toString().split('').reversed.join();

    if (tipoOperacion == 'renta') {
      return '\$$formatted / mes';
    }

    return '\$$formatted';
  }

  String get operacionLabel {
    if (tipoOperacion == 'renta') return 'Renta';
    if (tipoOperacion == 'venta') return 'Venta';
    return tipoOperacion;
  }

  String get estadoLabel {
    switch (estado) {
      case 'disponible':
        return 'Disponible';
      case 'en_proceso':
        return 'En proceso';
      case 'vendido':
        return 'Vendido';
      case 'rentado':
        return 'Rentado';
      default:
        return estado;
    }
  }

  String get tipoInmuebleLabel {
    switch (tipoInmueble) {
      case 'casa':
        return 'Casa';
      case 'departamento':
        return 'Departamento';
      case 'terreno':
        return 'Terreno';
      case 'local':
        return 'Local';
      case 'oficina':
        return 'Oficina';
      case 'bodega':
        return 'Bodega';
      case 'otro':
        return 'Otro';
      default:
        return tipoInmueble;
    }
  }

  String get imagenPrincipal {
    if (fotos.isNotEmpty) {
      return fotos.first.archivoUrl;
    }

    return '';
  }

  String get distanciaLabel {
    if (distanciaKm == null) return '';

    if (distanciaKm! < 1) {
      final metros = (distanciaKm! * 1000).round();
      return '$metros m de ti';
    }

    return '${distanciaKm!.toStringAsFixed(1)} km de ti';
  }

  static List<InmuebleArchivoModel> _parseArchivos(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((e) => InmuebleArchivoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static String _toString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final text = value.toString().toLowerCase();
    return text == '1' || text == 'true' || text == 'si' || text == 'sí';
  }
}

class InmuebleArchivoModel {
  final int id;
  final int inmuebleId;
  final int agenteId;
  final String categoria;
  final String tipo;
  final String archivoUrl;
  final String descripcion;
  final String? creadoEn;

  InmuebleArchivoModel({
    required this.id,
    required this.inmuebleId,
    required this.agenteId,
    required this.categoria,
    required this.tipo,
    required this.archivoUrl,
    required this.descripcion,
    required this.creadoEn,
  });

  factory InmuebleArchivoModel.fromJson(Map<String, dynamic> json) {
    return InmuebleArchivoModel(
      id: InmuebleModel._toInt(json['id']),
      inmuebleId: InmuebleModel._toInt(json['inmueble_id']),
      agenteId: InmuebleModel._toInt(json['agente_id']),
      categoria: InmuebleModel._toString(json['categoria']),
      tipo: InmuebleModel._toString(json['tipo'], fallback: 'general'),
      archivoUrl: InmuebleModel._toString(json['archivo_url']),
      descripcion: InmuebleModel._toString(json['descripcion']),
      creadoEn: json['creado_en']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inmueble_id': inmuebleId,
      'agente_id': agenteId,
      'categoria': categoria,
      'tipo': tipo,
      'archivo_url': archivoUrl,
      'descripcion': descripcion,
      'creado_en': creadoEn,
    };
  }
}

class InmuebleCalificacionModel {
  final int id;
  final int inmuebleId;
  final int clienteId;
  final int calificacion;
  final String comentario;
  final String? createdAt;

  InmuebleCalificacionModel({
    required this.id,
    required this.inmuebleId,
    required this.clienteId,
    required this.calificacion,
    required this.comentario,
    required this.createdAt,
  });

  factory InmuebleCalificacionModel.fromJson(Map<String, dynamic> json) {
    return InmuebleCalificacionModel(
      id: InmuebleModel._toInt(json['id']),
      inmuebleId: InmuebleModel._toInt(json['inmueble_id']),
      clienteId: InmuebleModel._toInt(json['cliente_id']),
      calificacion: InmuebleModel._toInt(json['calificacion']),
      comentario: InmuebleModel._toString(json['comentario']),
      createdAt: json['created_at']?.toString(),
    );
  }
}