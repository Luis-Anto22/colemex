import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'nomina_crear.dart';

class NominaRecibos extends StatefulWidget {
  final int idContador;
  final int empleadoId;
  final String empleadoNombre;

  const NominaRecibos({
    super.key,
    required this.idContador,
    required this.empleadoId,
    required this.empleadoNombre,
  });

  @override
  State<NominaRecibos> createState() => _NominaRecibosState();
}

class _NominaRecibosState extends State<NominaRecibos> {
  bool _loading = true;
  String? _error;
  List<dynamic> _nominas = [];

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/nominas";

  @override
  void initState() {
    super.initState();
    _fetchNominas();
  }

  Future<void> _fetchNominas() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?contador_id=${widget.idContador}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final todas = data["data"] ?? [];

        setState(() {
          _nominas = todas.where((n) {
            return n["empleado_id"].toString() == widget.empleadoId.toString();
          }).toList();
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = data["message"] ?? "Error al cargar recibos";
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
      case 'pagada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'borrador':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _crearNomina() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NominaCrear(
          idContador: widget.idContador,
          empleadoId: widget.empleadoId,
        ),
      ),
    );

    if (creado == true) {
      _fetchNominas();
    }
  }

  Future<void> _abrirArchivo(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("Recibos • ${widget.empleadoNombre}"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNomina,
        icon: const Icon(Icons.add),
        label: const Text("Recibo"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ $_error"))
              : _nominas.isEmpty
                  ? const Center(
                      child: Text("No hay recibos de nómina registrados."),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _nominas.length,
                      itemBuilder: (context, index) {
                        final nomina = Map<String, dynamic>.from(_nominas[index]);
                        final estado = nomina["estado"]?.toString() ?? "borrador";

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          _estadoColor(estado).withOpacity(.12),
                                      child: Icon(
                                        Icons.payments_outlined,
                                        color: _estadoColor(estado),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Periodo: ${nomina["periodo"] ?? "N/A"}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text("Fecha de pago: ${nomina["fecha_pago"] ?? "N/A"}"),
                                Text("Sueldo base: \$${nomina["sueldo_base"] ?? "0"}"),
                                Text("Percepciones: \$${nomina["percepciones"] ?? "0"}"),
                                Text("Deducciones: \$${nomina["deducciones"] ?? "0"}"),
                                Text(
                                  "Total pagado: \$${nomina["total_pagado"] ?? "0"}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Chip(
                                  label: Text(estado),
                                  backgroundColor:
                                      _estadoColor(estado).withOpacity(.12),
                                  labelStyle: TextStyle(
                                    color: _estadoColor(estado),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if ((nomina["pdf_url"] ?? "").toString().isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _abrirArchivo(nomina["pdf_url"]),
                                      icon: const Icon(Icons.picture_as_pdf),
                                      label: const Text("Abrir / imprimir PDF"),
                                    ),
                                  ),
                                if ((nomina["xml_url"] ?? "").toString().isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _abrirArchivo(nomina["xml_url"]),
                                      icon: const Icon(Icons.code),
                                      label: const Text("Abrir XML"),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}