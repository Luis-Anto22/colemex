import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CfdiCrear extends StatefulWidget {
  final int idContador;

  const CfdiCrear({
    super.key,
    required this.idContador,
  });

  @override
  State<CfdiCrear> createState() => _CfdiCrearState();
}

class _CfdiCrearState extends State<CfdiCrear> {
  final _formKey = GlobalKey<FormState>();

  final _rfc = TextEditingController();
  final _razon = TextEditingController();
  final _concepto = TextEditingController();
  final _subtotal = TextEditingController();
  final _iva = TextEditingController();
  final _total = TextEditingController();

  bool _loading = false;
  bool _loadingClientes = true;

  List<dynamic> _clientes = [];
  int? _clienteSeleccionadoId;

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/cfdi";

  static const String _clientesUrl =
      "https://corporativolegaldigital.com/api/contador/clientes";

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _rfc.dispose();
    _razon.dispose();
    _concepto.dispose();
    _subtotal.dispose();
    _iva.dispose();
    _total.dispose();
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
        Uri.parse(_baseUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "contador_id": widget.idContador,
          "cliente_id": _clienteSeleccionadoId,
          "rfc_cliente": _rfc.text.trim(),
          "razon_social": _razon.text.trim(),
          "concepto": _concepto.text.trim(),
          "subtotal": double.tryParse(_subtotal.text.trim()) ?? 0,
          "iva": double.tryParse(_iva.text.trim()) ?? 0,
          "total": double.tryParse(_total.text.trim()) ?? 0,
          "estado": "borrador",
        }),
      );

      final data = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CFDI creado correctamente")),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(data["message"] ?? "No se pudo crear CFDI");
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
        title: const Text("Nuevo CFDI"),
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

            _input(_rfc, "RFC Cliente"),
            _input(_razon, "Razón social"),
            _input(_concepto, "Concepto"),
            _input(_subtotal, "Subtotal", type: TextInputType.number),
            _input(_iva, "IVA", type: TextInputType.number),
            _input(_total, "Total", type: TextInputType.number),

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
              label: Text(_loading ? "Guardando..." : "Guardar CFDI"),
            ),
          ],
        ),
      ),
    );
  }
}