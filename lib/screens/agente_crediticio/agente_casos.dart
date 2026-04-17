import 'package:flutter/material.dart';
import 'api_service_crediticio.dart';

class AgenteCasos extends StatefulWidget {
  final int? idAgente;
  const AgenteCasos({super.key, this.idAgente});

  @override
  State<AgenteCasos> createState() => _AgenteCasosState();
}

class _AgenteCasosState extends State<AgenteCasos> {
  List<dynamic> _casos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCasos();
  }

  Future<void> _cargarCasos() async {
    try {
      final data = await ApiServiceCrediticio.listarCasos(widget.idAgente ?? 0);
      setState(() {
        _casos = data;
        _cargando = false;
      });
    } catch (e) {
      debugPrint("❌ Error al cargar casos: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Casos del Agente"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _casos.isEmpty
              ? const Center(child: Text("No hay casos registrados"))
              : ListView.builder(
                  itemCount: _casos.length,
                  itemBuilder: (context, index) {
                    final caso = _casos[index];
                    final titulo = caso["titulo"] ?? "Sin título";
                    final descripcion = caso["descripcion"] ?? "";
                    final estado = caso["estado"] ?? "pendiente";
                    final fecha = caso["fecha_creacion"] ?? "";

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(titulo),
                        subtitle: Text("$descripcion\nEstado: $estado\nFecha: $fecha"),
                        isThreeLine: true,
                        onTap: () {
                          // Aquí puedes navegar a detalle de caso con documentos y bitácora
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Abrir detalle del caso: $titulo")),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}