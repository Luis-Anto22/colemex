class Profesional {
  final int id;
  final String nombre;
  final String correo;
  final String telefono;
  final String perfil;
  final String especialidad;
  final String ciudad;
  final String foto;
  final int verificado;
  final String estado;
  final DateTime fechaRegistro;
  final double? latitude;
  final double? longitude;

  Profesional({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.perfil,
    required this.especialidad,
    required this.ciudad,
    required this.foto,
    required this.verificado,
    required this.estado,
    required this.fechaRegistro,
    this.latitude,
    this.longitude,
  });

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      perfil: json['perfil'] ?? '',
      especialidad: json['especialidad'] ?? '',
      ciudad: json['ciudad'] ?? '',
      foto: json['foto'] ?? '',
      verificado: int.tryParse(json['verificado'].toString()) ?? 0,
      estado: json['estado'] ?? '',
      fechaRegistro: DateTime.tryParse(json['fecha_registro'].toString()) ?? DateTime.now(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }
}