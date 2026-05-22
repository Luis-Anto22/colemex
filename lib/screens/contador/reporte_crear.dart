import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReporteCrear extends StatefulWidget {
  final int idContador;

  const ReporteCrear({super.key, required this.idContador});

  @override
  State<ReporteCrear> createState() => _ReporteCrearState();
}

class _ReporteCrearState extends State<ReporteCrear> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _periodoController = TextEditingController();
  final _ingresosController = TextEditingController();
  final _egresosController = TextEditingController();
  final _utilidadController = TextEditingController();
  final _observacionesController = TextEditingController();

  bool _loading = false;
  bool _loadingClientes = true;

  List<dynamic> _clientes = [];
  int? _clienteSeleccionadoId;

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/reportes";

  static const String _clientesUrl =
      "https://corporativolegaldigital.com/api/contador/clientes";

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _periodoController.dispose();
    _ingresosController.dispose();
    _egresosController.dispose();
    _utilidadController.dispose();
    _observacionesController.dispose();
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

  void _calcularUtilidad() {
    final ingresos = double.tryParse(_ingresosController.text.trim()) ?? 0;
    final egresos = double.tryParse(_egresosController.text.trim()) ?? 0;
    _utilidadController.text = (ingresos - egresos).toStringAsFixed(2);
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
        Uri.parse(_baseUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "contador_id": widget.idContador,
          "cliente_id": _clienteSeleccionadoId,
          "titulo": _tituloController.text.trim(),
          "periodo": _periodoController.text.trim(),
          "ingresos": double.tryParse(_ingresosController.text.trim()) ?? 0,
          "egresos": double.tryParse(_egresosController.text.trim()) ?? 0,
          "utilidad": double.tryParse(_utilidadController.text.trim()) ?? 0,
          "observaciones": _observacionesController.text.trim(),
          "estado": "borrador",
        }),
      );

      final data = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reporte creado correctamente")),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(data["message"] ?? "No se pudo crear reporte");
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
    int maxLines = 1,
    bool required = true,
    VoidCallback? onChangedCalc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        onChanged: (_) => onChangedCalc?.call(),
        validator: required
            ? (v) {
                if (v == null || v.trim().isEmpty) return "Campo requerido";
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
        title: const Text("Nuevo reporte financiero"),
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
                    if (value == null) return "Selecciona un cliente/empresa";
                    return null;
                  },
                ),
              ),
            _input(_tituloController, "Título"),
            _input(_periodoController, "Periodo"),
            _input(
              _ingresosController,
              "Ingresos",
              type: TextInputType.number,
              required: false,
              onChangedCalc: _calcularUtilidad,
            ),
            _input(
              _egresosController,
              "Egresos",
              type: TextInputType.number,
              required: false,
              onChangedCalc: _calcularUtilidad,
            ),
            _input(
              _utilidadController,
              "Utilidad",
              type: TextInputType.number,
              required: false,
            ),
            _input(
              _observacionesController,
              "Observaciones",
              maxLines: 3,
              required: false,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loading ? null : _guardar,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_loading ? "Guardando..." : "Guardar reporte"),
            ),
          ],
        ),
      ),
    );
  }
}