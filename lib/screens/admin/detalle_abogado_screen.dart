import 'package:flutter/material.dart';

class DetalleAbogadoScreen extends StatelessWidget {
  final int id;
  final String nombre;
  final String correo;
  final String telefono;
  final String tipo;

  // Datos simulados de casos (luego los conectas a tu backend)
  final int casosPendientes;
  final int casosEnProceso;
  final int casosFinalizados;

  const DetalleAbogadoScreen({
    super.key,
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.tipo,
    this.casosPendientes = 0,
    this.casosEnProceso = 0,
    this.casosFinalizados = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de $nombre"),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información personal
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.indigo),
                  title: Text(nombre,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📧 Correo: $correo"),
                      Text("📞 Teléfono: $telefono"),
                      Text("⚖️ Tipo: $tipo"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Estadísticas de casos
              const Text(
                "Casos asignados",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.pending_actions,
                      color: Colors.orange),
                  title: const Text("Casos pendientes"),
                  trailing: Text(
                    "$casosPendientes",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.work, color: Colors.blue),
                  title: const Text("Casos en proceso"),
                  trailing: Text(
                    "$casosEnProceso",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle,
                      color: Colors.green),
                  title: const Text("Casos finalizados"),
                  trailing: Text(
                    "$casosFinalizados",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de acción futura
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Asignar nuevo caso"),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Funcionalidad en desarrollo..."),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}