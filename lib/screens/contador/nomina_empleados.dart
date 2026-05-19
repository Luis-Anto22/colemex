import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'empleado_crear.dart';
import 'nomina_recibos.dart';

class NominaEmpleados extends StatefulWidget {
  final int idContador;

  const NominaEmpleados({
    super.key,
    required this.idContador,
  });

  @override
  State<NominaEmpleados> createState() =>
      _NominaEmpleadosState();
}

class _NominaEmpleadosState
    extends State<NominaEmpleados> {
  bool _loading = true;
  String? _error;

  List<dynamic> _empleados = [];

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/empleados";

  @override
  void initState() {
    super.initState();
    _fetchEmpleados();
  }

  Future<void> _fetchEmpleados() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_baseUrl?contador_id=${widget.idContador}",
        ),
        headers: {
          "Accept": "application/json",
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {
        setState(() {
          _empleados = data["data"] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              data["message"] ??
                  "Error al cargar empleados";
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

  Future<void> _crearEmpleado() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EmpleadoCrear(
              idContador: widget.idContador,
            ),
      ),
    );

    if (creado == true) {
      _fetchEmpleados();
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'activo':
        return Colors.green;

      case 'inactivo':
        return Colors.orange;

      case 'baja':
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
        title: const Text("Empleados"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      floatingActionButton:
          FloatingActionButton.extended(
            onPressed: _crearEmpleado,
            icon: const Icon(Icons.add),
            label: const Text("Empleado"),
          ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : _error != null
              ? Center(
                child: Text("❌ $_error"),
              )
              : _empleados.isEmpty
              ? const Center(
                child: Text(
                  "No hay empleados registrados.",
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _empleados.length,
                itemBuilder: (context, index) {
                  final empleado =
                      Map<String, dynamic>.from(
                        _empleados[index],
                      );

                  final estado =
                      empleado["estado"]
                          ?.toString() ??
                      "activo";

                  return Card(
                    margin:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(
                            14,
                          ),
                      leading: CircleAvatar(
                        backgroundColor:
                            _estadoColor(
                              estado,
                            ).withOpacity(.12),
                        child: Icon(
                          Icons.person,
                          color: _estadoColor(
                            estado,
                          ),
                        ),
                      ),
                      title: Text(
                        empleado["nombre"] ??
                            "Empleado",
                        style:
                            const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(
                              top: 6,
                            ),
                        child: Text(
                          "Empresa: ${empleado["cliente_nombre"] ?? "N/A"}\n"
                          "Puesto: ${empleado["puesto"] ?? "N/A"}\n"
                          "Salario: \$${empleado["salario"] ?? "0.00"}\n"
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
                            builder:
                                (_) => NominaRecibos(
                                  idContador:
                                      widget
                                          .idContador,
                                  empleadoId:
                                      empleado["id"],
                                  empleadoNombre:
                                      empleado["nombre"] ??
                                      "",
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