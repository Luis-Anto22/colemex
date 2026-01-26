import 'package:flutter/material.dart';
import '../common/ui_helpers.dart';
import 'api_service_crediticio.dart';
import 'agente_detalle_cliente.dart';

class AgenteClientes extends StatefulWidget {
  final int? idAgente;
  const AgenteClientes({super.key, this.idAgente});

  @override
  State<AgenteClientes> createState() => _AgenteClientesState();
}

class _AgenteClientesState extends State<AgenteClientes> {
  List<dynamic> _clientes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      final clientes =
          await ApiServiceCrediticio.listarClientes(widget.idAgente ?? 0);
      setState(() {
        _clientes = clientes;
        _cargando = false;
      });
    } catch (e) {
      debugPrint("❌ Error al cargar clientes: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes Asignados"),
        backgroundColor: Colors.blueGrey[700],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _clientes.isEmpty
                ? const Center(
                    child: Text(
                      "No hay clientes asignados",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      sectionHeader(
                        context,
                        "Lista de Clientes",
                        subtitle: "Agente #${widget.idAgente ?? '-'}",
                      ),
                      const SizedBox(height: 10),
                      ..._clientes.map((cliente) {
                        final idCredito =
                            int.tryParse(cliente["id"]?.toString() ?? "0") ?? 0;
                        final nombre = cliente["nombre"] ?? "Sin nombre";
                        final solicitud =
                            cliente["solicitud"] ?? "Solicitud desconocida";
                        final correo = cliente["correo"] ?? "";
                        final monto = double.tryParse(
                                cliente["monto_solicitado"]?.toString() ?? "0") ??
                            0.0;
                        final estado =
                            cliente["estado_credito"] ?? "pendiente";
                        final documento = cliente["documento"] ?? "";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: card(
                            context,
                            child: tile(
                              context,
                              icon: Icons.person,
                              title: nombre,
                              subtitle:
                                  "Monto: \$${monto.toStringAsFixed(2)} | Estado: $estado",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AgenteDetalleCliente(
                                      idAgente: widget.idAgente,
                                      idCredito: idCredito, // ⚠️ ahora sí pasamos el ID real
                                      nombre: nombre,
                                      correo: correo,
                                      solicitud: solicitud,
                                      monto: monto,
                                      estado: estado,
                                      documento: documento,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
      ),
    );
  }
}