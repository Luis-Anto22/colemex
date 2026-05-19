import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContadorClientes extends StatefulWidget {
  final int idContador;

  const ContadorClientes({
    super.key,
    required this.idContador,
  });

  @override
  State<ContadorClientes> createState() => _ContadorClientesState();
}

class _ContadorClientesState extends State<ContadorClientes> {
  bool _isLoading = true;
  String? _error;

  List<dynamic> _clientes = [];
  List<dynamic> _clientesFiltrados = [];

  final TextEditingController _buscarController = TextEditingController();

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/clientes";

  @override
  void initState() {
    super.initState();
    _fetchClientes();
    _buscarController.addListener(_filtrarClientes);
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientes() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?contador_id=${widget.idContador}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _clientes = data["data"] ?? [];
          _clientesFiltrados = _clientes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data["message"] ?? "Error al obtener clientes";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filtrarClientes() {
    final query = _buscarController.text.toLowerCase().trim();

    setState(() {
      _clientesFiltrados = query.isEmpty
          ? _clientes
          : _clientes.where((cliente) {
              final nombre =
                  cliente["nombre"]?.toString().toLowerCase() ?? "";
              final correo =
                  cliente["correo"]?.toString().toLowerCase() ?? "";
              final telefono =
                  cliente["telefono"]?.toString().toLowerCase() ?? "";

              return nombre.contains(query) ||
                  correo.contains(query) ||
                  telefono.contains(query);
            }).toList();
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.orange;
      case 'bloqueado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes y empresas"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    "❌ Error: $_error",
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _buscarController,
                        decoration: InputDecoration(
                          hintText: "Buscar cliente...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _clientesFiltrados.isEmpty
                          ? const Center(
                              child: Text("No hay clientes asignados."),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _clientesFiltrados.length,
                              itemBuilder: (context, index) {
                                final cliente = Map<String, dynamic>.from(
                                  _clientesFiltrados[index],
                                );

                                final estado =
                                    cliente["relacion_estado"]?.toString() ??
                                        "activo";

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  gold.withOpacity(.15),
                                              child: Icon(
                                                Icons.business_center,
                                                color: gold,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    cliente["nombre"] ??
                                                        "Sin nombre",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    cliente["correo"] ??
                                                        "Sin correo",
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _estadoColor(estado)
                                                    .withOpacity(.12),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                estado,
                                                style: TextStyle(
                                                  color: _estadoColor(estado),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              cliente["telefono"] ??
                                                  "Sin teléfono",
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_city,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              cliente["ciudad"] ??
                                                  "Sin ciudad",
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            Chip(
                                              label: Text(
                                                "Casos: ${cliente["total_casos"] ?? 0}",
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                "Origen: ${cliente["origen"] ?? "N/A"}",
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (cliente["notas"] != null &&
                                            cliente["notas"]
                                                .toString()
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(cliente["notas"]),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}