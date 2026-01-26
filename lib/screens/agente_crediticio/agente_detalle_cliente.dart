import 'package:flutter/material.dart';
import 'api_service_crediticio.dart';

class AgenteDetalleCliente extends StatefulWidget {
  final int? idAgente;
  final int idCredito; // ⚠️ nuevo campo para pasar el ID real del crédito
  final String nombre;
  final String correo;
  final String solicitud;
  final double monto;
  final String estado;
  final String documento;

  const AgenteDetalleCliente({
    super.key,
    this.idAgente,
    required this.idCredito,
    required this.nombre,
    required this.correo,
    required this.solicitud,
    required this.monto,
    required this.estado,
    required this.documento,
  });

  @override
  State<AgenteDetalleCliente> createState() => _AgenteDetalleClienteState();
}

class _AgenteDetalleClienteState extends State<AgenteDetalleCliente> {
  Map<String, dynamic>? detalle;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final data = await ApiServiceCrediticio.detalleCredito(widget.idCredito);
      setState(() {
        detalle = data;
        cargando = false;
      });
    } catch (e) {
      debugPrint("❌ Error al cargar detalle: $e");
      setState(() => cargando = false);
    }
  }

  Future<void> _actualizarEstado(String nuevoEstado) async {
    try {
      await ApiServiceCrediticio.actualizarEstadoCredito({
        "id": widget.idCredito,
        "estado_credito": nuevoEstado,
        "comentarios_agente": "Actualizado desde la app"
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Estado actualizado a $nuevoEstado")),
      );
      setState(() {
        detalle?["estado"] = nuevoEstado;
      });
    } catch (e) {
      debugPrint("❌ Error al actualizar estado: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar estado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = detalle?["nombre"] ?? widget.nombre;
    final correo = detalle?["correo"] ?? widget.correo;
    final solicitud = detalle?["solicitud"] ?? widget.solicitud;
    final monto = double.tryParse(detalle?["monto_solicitado"]?.toString() ?? "") ?? widget.monto;
    final estado = detalle?["estado_credito"] ?? widget.estado;
    final documento = detalle?["documento"] ?? widget.documento;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Cliente"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Correo
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(correo),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Solicitud
                      Row(
                        children: [
                          const Icon(Icons.description, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text("Solicitud: $solicitud")),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Monto
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text("Monto solicitado: \$${monto.toStringAsFixed(2)}"),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Estado
                      Row(
                        children: [
                          Icon(
                            estado.toLowerCase() == "aprobado"
                                ? Icons.check_circle
                                : estado.toLowerCase() == "rechazado"
                                    ? Icons.cancel
                                    : Icons.timelapse,
                            color: estado.toLowerCase() == "aprobado"
                                ? Colors.green
                                : estado.toLowerCase() == "rechazado"
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text("Estado: $estado"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Documento
                      if (documento.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.attach_file, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Documento: $documento",
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Abrir documento: $documento")),
                                );
                              },
                              child: const Text(
                                "Ver",
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      // Mostrar ID del agente si existe
                      if (widget.idAgente != null)
                        Center(
                          child: Text(
                            "ID del agente: ${widget.idAgente}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Botón de acción
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () => _actualizarEstado("aprobado"),
                          icon: const Icon(Icons.update),
                          label: const Text("Actualizar Estado a Aprobado"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}