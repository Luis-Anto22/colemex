import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmpleadoCrear extends StatefulWidget {
  final int idContador;

  const EmpleadoCrear({
    super.key,
    required this.idContador,
  });

  @override
  State<EmpleadoCrear> createState() => _EmpleadoCrearState();
}

class _EmpleadoCrearState extends State<EmpleadoCrear> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _puestoController = TextEditingController();
  final _salarioController = TextEditingController();
  final _rfcController = TextEditingController();
  final _curpController = TextEditingController();
  final _nssController = TextEditingController();

  bool _loading = false;
  bool _loadingClientes = true;

  String _periodicidad = 'quincenal';

  List<dynamic> _clientes = [];
  int? _clienteSeleccionadoId;

  static const String _empleadosUrl =
      "https://corporativolegaldigital.com/api/contador/empleados";

  static const String _clientesUrl =
      "https://corporativolegaldigital.com/api/contador/clientes";

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _puestoController.dispose();
    _salarioController.dispose();
    _rfcController.dispose();
    _curpController.dispose();
    _nssController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    try {
      final response = await http.get(
        Uri.parse("$_clientesUrl?contador_id=${widget.idContador}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _clientes = data["data"] ?? [];
          _loadingClientes = false;
        });
      } else {
        setState(() => _loadingClientes = false);
      }
    } catch (_) {
      setState(() => _loadingClientes = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un cliente/empresa")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse(_empleadosUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "contador_id": widget.idContador,
          "cliente_id": _clienteSeleccionadoId,
          "nombre": _nombreController.text.trim(),
          "puesto": _puestoController.text.trim(),
          "salario": double.tryParse(_salarioController.text.trim()) ?? 0,
          "rfc": _rfcController.text.trim(),
          "curp": _curpController.text.trim(),
          "nss": _nssController.text.trim(),
          "periodicidad": _periodicidad,
        }),
      );

      final data = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Empleado registrado")),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(data["message"] ?? "No se pudo registrar");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    TextInputType? type,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: required
            ? (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Campo requerido";
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo empleado"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loadingClientes)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: DropdownButtonFormField<int>(
                  value: _clienteSeleccionadoId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Cliente / empresa",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: _clientes.map<DropdownMenuItem<int>>((cliente) {
                    final c = Map<String, dynamic>.from(cliente);

                    return DropdownMenuItem<int>(
                      value: int.tryParse(c["id"].toString()),
                      child: Text(
                        "${c["nombre"] ?? "Sin nombre"}"
                        "${c["correo"] != null ? " • ${c["correo"]}" : ""}",
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _clienteSeleccionadoId = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Selecciona un cliente/empresa";
                    }
                    return null;
                  },
                ),
              ),

            _input(_nombreController, "Nombre empleado"),
            _input(_puestoController, "Puesto"),
            _input(
              _salarioController,
              "Salario",
              type: TextInputType.number,
            ),
            _input(_rfcController, "RFC", required: false),
            _input(_curpController, "CURP", required: false),
            _input(_nssController, "NSS", required: false),

            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                value: _periodicidad,
                decoration: InputDecoration(
                  labelText: "Periodicidad",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                  DropdownMenuItem(
                      value: 'quincenal', child: Text('Quincenal')),
                  DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _periodicidad = value);
                  }
                },
              ),
            ),

            ElevatedButton.icon(
              onPressed: _loading ? null : _guardar,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_loading ? "Guardando..." : "Guardar empleado"),
            ),
          ],
        ),
      ),
    );
  }
}