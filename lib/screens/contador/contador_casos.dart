import 'package:flutter/material.dart';
import 'contador_detalle.dart';
import 'api_service_contador.dart'; // Importa tu servicio de contador

class ContadorCasos extends StatefulWidget {
  final int idContador; // Recibimos el ID del contador para cargar casos reales

  const ContadorCasos({super.key, required this.idContador});

  @override
  State<ContadorCasos> createState() => _ContadorCasosState();
}

class _ContadorCasosState extends State<ContadorCasos> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _casos = [];

  @override
  void initState() {
    super.initState();
    _fetchCasos();
  }

  Future<void> _fetchCasos() async {
    try {
      final data = await ApiServiceContador.obtenerCasos(widget.idContador);
      setState(() {
        _casos = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Casos Asignados"),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ Error: $_error"))
              : ListView.builder(
                  itemCount: _casos.length,
                  itemBuilder: (context, index) {
                    final caso = _casos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          caso["estado"] == "abierto"
                              ? Icons.circle
                              : caso["estado"] == "cerrado"
                                  ? Icons.check_circle
                                  : Icons.timelapse,
                          color: caso["estado"] == "abierto"
                              ? Colors.green
                              : caso["estado"] == "cerrado"
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                        title: Text(
                          caso["titulo"] ?? "Sin título",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Cliente: ${caso["cliente"] ?? "N/A"}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContadorDetalle(
                                idCaso: caso["id"], // ✅ pasamos el ID real
                                titulo: caso["titulo"] ?? "",
                                descripcion: caso["descripcion"] ?? "",
                                cliente: caso["cliente"] ?? "",
                                documento: caso["documento"] ?? "",
                                estado: caso["estado"] ?? "N/A",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}