import 'package:flutter/material.dart';

class AuditorDashboard extends StatelessWidget {
  const AuditorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo, en la práctica vendrán de tu backend
    final int quejasPendientes = 5;
    final int documentosPendientes = 8;
    final double promedioCalificaciones = 4.2;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard Auditor",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de quejas pendientes
            Card(
              child: ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: const Text("Quejas pendientes"),
                subtitle: Text("Total: $quejasPendientes"),
              ),
            ),

            // Tarjeta de documentos pendientes
            Card(
              child: ListTile(
                leading: const Icon(Icons.folder, color: Colors.blue),
                title: const Text("Documentos por verificar"),
                subtitle: Text("Total: $documentosPendientes"),
              ),
            ),

            // Tarjeta de calificaciones promedio
            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.green),
                title: const Text("Calificación promedio de profesionales"),
                subtitle: Text(promedioCalificaciones.toString()),
              ),
            ),

            const SizedBox(height: 30),

            // Sección de resumen rápido
            const Text(
              "Resumen rápido",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Revisa las quejas pendientes.\n"
              "• Verifica documentos de profesionales.\n"
              "• Consulta calificaciones y reputación.",
            ),
          ],
        ),
      ),
    );
  }
}