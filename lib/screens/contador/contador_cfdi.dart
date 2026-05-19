import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'cfdi_crear.dart';
import 'cfdi_detalle.dart';

class ContadorCfdi extends StatefulWidget {
  final int idContador;

  const ContadorCfdi({
    super.key,
    required this.idContador,
  });

  @override
  State<ContadorCfdi> createState() => _ContadorCfdiState();
}

class _ContadorCfdiState extends State<ContadorCfdi> {
  bool _isLoading = true;
  String? _error;

  List<dynamic> _cfdis = [];

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/cfdi";

  @override
  void initState() {
    super.initState();
    _fetchCfdis();
  }

  Future<void> _fetchCfdis() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?contador_id=${widget.idContador}"),
        headers: {
          "Accept": "application/json",
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _cfdis = data["data"] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data["message"] ?? "Error al obtener CFDI";
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

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'emitido':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'borrador':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _abrirCrearCfdi() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CfdiCrear(
          idContador: widget.idContador,
        ),
      ),
    );

    if (creado == true) {
      _fetchCfdis();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Facturación CFDI"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCrearCfdi,
        icon: const Icon(Icons.add),
        label: const Text("Nuevo CFDI"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ $_error"))
              : _cfdis.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay CFDI registrados.",
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _cfdis.length,
                      itemBuilder: (context, index) {
                        final cfdi =
                            Map<String, dynamic>.from(_cfdis[index]);

                        final estado =
                            cfdi["estado"]?.toString() ?? "borrador";

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: CircleAvatar(
                              backgroundColor:
                                  _estadoColor(estado).withOpacity(.12),
                              child: Icon(
                                Icons.receipt_long,
                                color: _estadoColor(estado),
                              ),
                            ),
                            title: Text(
                              cfdi["razon_social"] ?? "Sin razón social",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "RFC: ${cfdi["rfc_cliente"] ?? "N/A"}",
                                  ),
                                  Text(
                                    "Total: \$${cfdi["total"] ?? "0.00"}",
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
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
                                        color:
                                            _estadoColor(estado),
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CfdiDetalle(
                                    cfdiId: cfdi["id"],
                                  ),
                                ),
                              ).then((_) => _fetchCfdis());
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}