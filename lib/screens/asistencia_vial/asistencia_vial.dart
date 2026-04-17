import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../localizacion.dart';

class AsistenciaVialScreen extends StatefulWidget {
  final double? userLat;
  final double? userLng;

  const AsistenciaVialScreen({
    super.key,
    this.userLat,
    this.userLng,
  });

  @override
  State<AsistenciaVialScreen> createState() => _AsistenciaVialScreenState();
}

class _AsistenciaVialScreenState extends State<AsistenciaVialScreen> {
  late Future<List<Profesional>> profesionales;

  @override
  void initState() {
    super.initState();
    profesionales = fetchAsistenciaVial();
  }

  Future<List<Profesional>> fetchAsistenciaVial() async {
    final response = await http.get(
      Uri.parse(
        'https://corporativolegaldigital.com/api/asistencia_vial/asistencia_vial.php',
      ),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((prof) => Profesional.fromJson(prof))
          .toList();
    } else {
      throw Exception('Error al cargar profesionales de Asistencia Vial');
    }
  }

  Future<void> _llamar(String telefono) async {
    final Uri uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia Vial'),
      ),
      body: FutureBuilder<List<Profesional>>(
        future: profesionales,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay profesionales disponibles.'),
            );
          }

          final profs = snapshot.data!;

          return ListView.builder(
            itemCount: profs.length,
            itemBuilder: (context, index) {
              final prof = profs[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: prof.foto != null
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(prof.foto!),
                        )
                      : const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person),
                        ),
                  title: Text(
                    prof.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${prof.ciudad ?? "Ciudad no disponible"}\nEstado: ${prof.estado}',
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      /// BOTÓN LLAMAR
                      if (prof.telefono != null)
                        IconButton(
                          icon: const Icon(
                            Icons.phone,
                            color: Colors.green,
                          ),
                          onPressed: () => _llamar(prof.telefono!),
                        ),

                      /// BOTÓN MAPA
                      if (prof.latitud != null &&
                          prof.longitud != null)
                        IconButton(
                          icon: const Icon(
                            Icons.map,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LocalizacionPanel(
                                  idProfesional: prof.id,
                                  perfil: "Asistencia Vial",
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Profesional {
  final int id;
  final String nombre;
  final String? telefono;
  final String? ciudad;
  final String? foto;
  final String estado;
  final double? latitud;
  final double? longitud;

  Profesional({
    required this.id,
    required this.nombre,
    this.telefono,
    this.ciudad,
    this.foto,
    required this.estado,
    this.latitud,
    this.longitud,
  });

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      ciudad: json['ciudad'],
      foto: json['foto'],
      estado: json['estado'] ?? 'disponible',
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
    );
  }
}