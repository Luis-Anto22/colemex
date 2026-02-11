import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Modelo de Cita
class Cita {
  final int id;
  final String fechaCita;
  final String estado;
  final String profesional;
  final String cliente;

  Cita({
    required this.id,
    required this.fechaCita,
    required this.estado,
    required this.profesional,
    required this.cliente,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: int.parse(json['id'].toString()),
      fechaCita: json['fecha_cita'] ?? '',
      estado: json['estado'] ?? '',
      profesional: json['profesional'] ?? '',
      cliente: json['cliente'] ?? '',
    );
  }
}

/// Servicio para consumir la API
class ApiService {
  static const String baseUrl =
      "https://corporativolegaldigital.com/api/common/agenda.php";

  static Future<List<Cita>> getCitas() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List citasJson = data['data'];
      return citasJson.map((json) => Cita.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar citas: ${response.statusCode}");
    }
  }
}

/// Pantalla Agenda
class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda / citas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.event_available_outlined, size: 64, color: gold),
            const SizedBox(height: 12),
            const Text('Agenda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'Aquí mostrarás tus citas, disponibilidad y horarios.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            /// Lista de citas desde la API
            Expanded(
              child: FutureBuilder<List<Cita>>(
                future: ApiService.getCitas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final citas = snapshot.data ?? [];
                  if (citas.isEmpty) {
                    return const Center(child: Text("No hay citas registradas"));
                  }
                  return ListView.separated(
                    itemCount: citas.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final cita = citas[i];
                      return ListTile(
                        leading: Icon(Icons.calendar_today, color: gold),
                        title: Text("Cliente: ${cita.cliente}"),
                        subtitle: Text(
                            "${cita.estado} • Profesional: ${cita.profesional}"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Aquí puedes navegar a detalle de cita
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}