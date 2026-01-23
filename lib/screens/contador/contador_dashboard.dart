import 'package:flutter/material.dart';
import 'api_service_contador.dart'; // Importa tu servicio de contador

class ContadorDashboard extends StatefulWidget {
  final int idContador; // Recibimos el ID del contador para cargar datos reales

  const ContadorDashboard({super.key, required this.idContador});

  @override
  State<ContadorDashboard> createState() => _ContadorDashboardState();
}

class _ContadorDashboardState extends State<ContadorDashboard> {
  bool _isLoading = true;
  String? _error;

  int _casosActivos = 0;
  int _casosCerrados = 0;
  double _ingresos = 0.0;
  int _notificaciones = 0;

  List<dynamic> _documentos = []; // 🔹 Lista de documentos del contador

  @override
  void initState() {
    super.initState();

    // ✅ Si no hay contador real, no llamamos API
    if (widget.idContador > 0) {
      _fetchDashboard();
      _fetchDocumentos();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDashboard() async {
    try {
      final data = await ApiServiceContador.obtenerDashboard(widget.idContador);

      if (data["success"] == true) {
        setState(() {
          _casosActivos = data["casos_activos"] ?? 0;
          _casosCerrados = data["casos_cerrados"] ?? 0;
          _ingresos = (data["ingresos"] ?? 0).toDouble();
          _notificaciones = data["notificaciones"] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data["mensaje"] ?? "No hay datos disponibles";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error al obtener dashboard: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDocumentos() async {
    try {
      final docs = await ApiServiceContador.obtenerDocumentos(widget.idContador);
      setState(() {
        _documentos = docs;
      });
    } catch (e) {
      setState(() {
        _error = "Error al obtener documentos: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Contador"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ $_error"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 🔹 Sección de métricas
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildCard(
                            icon: Icons.folder_open,
                            title: "Casos Activos",
                            value: _casosActivos > 0
                                ? "$_casosActivos"
                                : "Todavía no hay casos",
                            color: Colors.blue,
                          ),
                          _buildCard(
                            icon: Icons.check_circle,
                            title: "Casos Cerrados",
                            value: _casosCerrados > 0
                                ? "$_casosCerrados"
                                : "Ninguno cerrado aún",
                            color: Colors.green,
                          ),
                          _buildCard(
                            icon: Icons.attach_money,
                            title: "Ingresos",
                            value: _ingresos > 0
                                ? "\$${_ingresos.toStringAsFixed(2)}"
                                : "Sin ingresos",
                            color: Colors.orange,
                          ),
                          _buildCard(
                            icon: Icons.notifications,
                            title: "Notificaciones",
                            value: _notificaciones > 0
                                ? "$_notificaciones"
                                : "Sin notificaciones",
                            color: Colors.red,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🔹 Sección de documentos
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Documentos / Tickets",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _documentos.isEmpty
                          ? const Text("No hay documentos registrados aún.")
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _documentos.length,
                              itemBuilder: (context, index) {
                                final doc = _documentos[index];
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.description,
                                        color: Colors.blue),
                                    title: Text(doc["tipo_documento"] ?? "Documento"),
                                    subtitle: Text(
                                        "Ticket: ${doc["ticket"]} • Estado: ${doc["estatus"]}"),
                                    trailing: Icon(
                                      doc["estatus"] == "validado"
                                          ? Icons.check_circle
                                          : doc["estatus"] == "rechazado"
                                              ? Icons.cancel
                                              : Icons.hourglass_empty,
                                      color: doc["estatus"] == "validado"
                                          ? Colors.green
                                          : doc["estatus"] == "rechazado"
                                              ? Colors.red
                                              : Colors.orange,
                                    ),
                                    onTap: () {
                                      // Aquí puedes navegar a contador_detalle.dart
                                      // Navigator.push(...);
                                    },
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  // Widget reutilizable para cada tarjeta
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}