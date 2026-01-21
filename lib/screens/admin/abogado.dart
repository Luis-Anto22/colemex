class Abogado {
  final int id;
  final String nombre;
  final double? latitude;
  final double? longitude;
  final String especialidad;
  final String ciudad;
  final String correo;
  final String telefono;
  final String foto;

  Abogado({
    required this.id,
    required this.nombre,
    this.latitude,
    this.longitude,
    required this.especialidad,
    required this.ciudad,
    required this.correo,
    required this.telefono,
    required this.foto,
  });

  factory Abogado.fromJson(Map<String, dynamic> json) {
    return Abogado(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      especialidad: json['especialidad'] ?? '',
      ciudad: json['ciudad'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      foto: json['foto'] ?? '',
    );
  }
}