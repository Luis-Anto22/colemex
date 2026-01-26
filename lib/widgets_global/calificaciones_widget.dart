import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalificacionesWidget extends StatefulWidget {
  final int profesionalId; // 👈 ID del agente o psicólogo

  const CalificacionesWidget({super.key, required this.profesionalId});

  @override
  State<CalificacionesWidget> createState() => _CalificacionesWidgetState();
}

class _CalificacionesWidgetState extends State<CalificacionesWidget> {
  List<Map<String, dynamic>> calificaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    fetchCalificaciones();
  }

  Future<void> fetchCalificaciones() async {
    final url = Uri.parse(
        "https://corporativolegaldigital.com/api/calificaciones.php?profesionalId=${widget.profesionalId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["success"] == true && jsonData["data"] is List) {
          setState(() {
            calificaciones =
                List<Map<String, dynamic>>.from(jsonData["data"] as List);
            cargando = false;
          });
        } else {
          setState(() {
            cargando = false;
          });
        }
      } else {
        setState(() {
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (calificaciones.isEmpty) {
      return const Center(child: Text("No hay calificaciones registradas"));
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ evita warnings
        children: [
          const ListTile(
            leading: Icon(Icons.star, color: Colors.amber),
            title: Text("Calificaciones"),
          ),
          ...calificaciones.map((c) => ListTile(
                title: Text(
                    "${c['cliente'] ?? 'Anónimo'} - ${c['estrellas']?.toString() ?? '0'}⭐"),
                subtitle: Text(c['comentario']?.toString() ?? ""),
                trailing: Text(c['fecha']?.toString() ?? ""),
              )).toList(), // ✅ convierte Iterable en List
        ],
      ),
    );
  }
}