import 'package:flutter/material.dart';
import 'package:colemex/api_service.dart';

class HistorialServiciosWidget extends StatelessWidget {
  final int psicologoId; // 🔧 ID del psicólogo
  const HistorialServiciosWidget({super.key, required this.psicologoId});

  @override
  Widget build(BuildContext context) {
    debugPrint("🧠 ID recibido en HistorialServiciosWidget: $psicologoId");
    return Card(
      child: FutureBuilder<List<dynamic>>(
        future: ApiService.obtenerHistorialServiciosPsicologo(psicologoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListTile(
              leading: CircularProgressIndicator(),
              title: Text("Cargando historial..."),
            );
          }

          if (snapshot.hasError) {
            return ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: const Text("Error al obtener historial"),
              subtitle: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const ListTile(
              leading: Icon(Icons.history, color: Colors.grey),
              title: Text("No hay servicios registrados"),
            );
          }

          final historial = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: Icon(Icons.history, color: Colors.orange),
                title: Text("Historial de Servicios"),
              ),
              ...historial.map((h) {
                final servicio = h['servicio']?.toString() ?? "Servicio desconocido";
                final fecha = h['fecha']?.toString() ?? "Fecha no disponible";
                final detalle = h['detalle']?.toString() ?? "Sin detalle";

                return ListTile(
                  title: Text(servicio),
                  subtitle: Text("Fecha: $fecha\nDetalle: $detalle"),
                  isThreeLine: true,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}