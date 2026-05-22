import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'declaracion_crear.dart';
import 'declaracion_detalle.dart';

class ContadorDeclaraciones extends StatefulWidget {
  final int idContador;

  const ContadorDeclaraciones({
    super.key,
    required this.idContador,
  });

  @override
  State<ContadorDeclaraciones> createState() => _ContadorDeclaracionesState();
}

class _ContadorDeclaracionesState extends State<ContadorDeclaraciones> {
  bool _loading = true;
  String? _error;
  List<dynamic> _declaraciones = [];

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/declaraciones";

  @override
  void initState() {
    super.initState();
    _fetchDeclaraciones();
  }

  Future<void> _fetchDeclaraciones() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?contador_id=${widget.idContador}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _declaraciones = data["data"] ?? [];
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = data["message"] ?? "Error al cargar declaraciones";
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
      case 'presentada':
        return Colors.green;
      case 'en proceso':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _abrirCrear() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeclaracionCrear(
          idContador: widget.idContador,
        ),
      ),
    );

    if (creado == true) {
      _fetchDeclaraciones();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Declaraciones SAT"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCrear,
        icon: const Icon(Icons.add),
        label: const Text("Nueva declaración"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("❌ $_error"))
              : _declaraciones.isEmpty
                  ? const Center(
                      child: Text("No hay declaraciones registradas."),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchDeclaraciones,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _declaraciones.length,
                        itemBuilder: (context, index) {
                          final d = Map<String, dynamic>.from(
                            _declaraciones[index],
                          );

                          final estado =
                              d["estado"]?.toString() ?? "pendiente";

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
                                  Icons.account_balance_outlined,
                                  color: _estadoColor(estado),
                                ),
                              ),
                              title: Text(
                                "${d["tipo"] ?? "Declaración"} • ${d["periodo"] ?? ""}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  "Cliente: ${d["cliente_nombre"] ?? "N/A"}\n"
                                  "Ejercicio: ${d["ejercicio"] ?? "N/A"}\n"
                                  "Monto: \$${d["monto"] ?? "0.00"}\n"
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
                                    builder: (_) => DeclaracionDetalle(
                                      declaracionId: d["id"],
                                    ),
                                  ),
                                ).then((_) => _fetchDeclaraciones());
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}