import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificacionesWidget extends StatefulWidget {
  final int profesionalId; // 👈 ID del agente o psicólogo

  const NotificacionesWidget({super.key, required this.profesionalId});

  @override
  State<NotificacionesWidget> createState() => _NotificacionesWidgetState();
}

class _NotificacionesWidgetState extends State<NotificacionesWidget> {
  List<Map<String, dynamic>> notificaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    fetchNotificaciones();
  }

  Future<void> fetchNotificaciones() async {
    final url = Uri.parse(
        "https://corporativolegaldigital.com/api/notificaciones.php?profesionalId=${widget.profesionalId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["success"] == true && jsonData["data"] is List) {
          setState(() {
            notificaciones =
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
    if (notificaciones.isEmpty) {
      return const Center(child: Text("No hay notificaciones"));
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.notifications, color: Colors.blue),
            title: Text("Notificaciones"),
          ),
          ...notificaciones.map((n) => ListTile(
                leading: Icon(
                  (n['leido']?.toString() == '1')
                      ? Icons.mark_email_read
                      : Icons.notifications_active,
                  color: (n['leido']?.toString() == '1')
                      ? Colors.grey
                      : Colors.red,
                ),
                title: Text(n['mensaje'] ?? ''),
                subtitle: Text("Fecha: ${n['fecha'] ?? ''}"),
                trailing: (n['leido']?.toString() == '1')
                    ? const Text("Leído",
                        style: TextStyle(color: Colors.grey))
                    : const Text("Nuevo",
                        style: TextStyle(color: Colors.red)),
              )).toList(),
        ],
      ),
    );
  }
}