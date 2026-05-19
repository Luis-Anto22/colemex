import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reporte_crear.dart';
import 'reporte_detalle.dart';

class ContadorReportes extends StatefulWidget {
  final int idContador;

  const ContadorReportes({super.key, required this.idContador});

  @override
  State<ContadorReportes> createState() => _ContadorReportesState();
}

class _ContadorReportesState extends State<ContadorReportes> {
  bool _loading = true;
  String? _error;
  List<dynamic> _reportes = [];

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/reportes";

  @override
  void initState() {
    super.initState();
    _fetchReportes();
  }

  Future<void> _fetchReportes() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?contador_id=${widget.idContador}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _reportes = data["data"] ?? [];
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = data["message"] ?? "Error al cargar reportes";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'generado':
        return Colors.green;
      case 'enviado':
        return Colors.blue;
      case 'borrador':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _crearReporte() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReporteCrear(idContador: widget.idContador),
      ),
    );

    if (creado == true) _fetchReportes();
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes financieros"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearReporte,
        icon: const Icon(Icons.add),
        label: const Text("Nuevo reporte"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ $_error"))
              : _reportes.isEmpty
                  ? const Center(child: Text("No hay reportes registrados."))
                  : RefreshIndicator(
                      onRefresh: _fetchReportes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _reportes.length,
                        itemBuilder: (context, index) {
                          final r = Map<String, dynamic>.from(_reportes[index]);
                          final estado = r["estado"]?.toString() ?? "borrador";

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
                                  Icons.bar_chart_outlined,
                                  color: _estadoColor(estado),
                                ),
                              ),
                              title: Text(
                                r["titulo"] ?? "Reporte financiero",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  "Cliente: ${r["cliente_nombre"] ?? "N/A"}\n"
                                  "Periodo: ${r["periodo"] ?? "N/A"}\n"
                                  "Ingresos: \$${r["ingresos"] ?? "0"}\n"
                                  "Egresos: \$${r["egresos"] ?? "0"}\n"
                                  "Utilidad: \$${r["utilidad"] ?? "0"}\n"
                                  "Estado: $estado",
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
                                    builder: (_) => ReporteDetalle(
                                      reporteId: r["id"],
                                    ),
                                  ),
                                ).then((_) => _fetchReportes());
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}