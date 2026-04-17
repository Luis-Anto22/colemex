import 'package:flutter/material.dart';

class AgendaWidget extends StatelessWidget {
  const AgendaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔧 Datos simulados, luego vendrán de la API
    final citas = [
      {"fecha": "2026-01-15", "hora": "10:00 AM", "detalle": "Cita con cliente"},
      {"fecha": "2026-01-16", "hora": "3:00 PM", "detalle": "Revisión de contrato"},
    ];

    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
            title: Text("Agenda"),
          ),
          ...citas.map((c) => ListTile(
                title: Text("${c['fecha']} - ${c['hora']}"),
                subtitle: Text(c['detalle']?.toString() ?? ""),
              )),
        ],
      ),
    );
  }
}