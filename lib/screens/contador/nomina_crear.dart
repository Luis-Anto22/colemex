import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NominaCrear extends StatefulWidget {
  final int idContador;
  final int empleadoId;

  const NominaCrear({
    super.key,
    required this.idContador,
    required this.empleadoId,
  });

  @override
  State<NominaCrear> createState() => _NominaCrearState();
}

class _NominaCrearState extends State<NominaCrear> {
  final _formKey = GlobalKey<FormState>();

  final _periodoController = TextEditingController();
  final _fechaPagoController = TextEditingController();
  final _sueldoBaseController = TextEditingController();
  final _deduccionesController = TextEditingController();
  final _percepcionesController = TextEditingController();
  final _totalPagadoController = TextEditingController();

  bool _loading = false;
  bool _subiendo = false;
  bool _loadingClientes = true;

  List<dynamic> _clientes = [];
  int? _clienteSeleccionadoId;

  PlatformFile? _pdfFile;
  PlatformFile? _xmlFile;

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/nominas";

  static const String _clientesUrl =
      "https://corporativolegaldigital.com/api/contador/clientes";

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _periodoController.dispose();
    _fechaPagoController.dispose();
    _sueldoBaseController.dispose();
    _deduccionesController.dispose();
    _percepcionesController.dispose();
    _totalPagadoController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    try {
      final response = await http.get(
        Uri.parse("$_clientesUrl?contador_id=${widget.idContador}"),
        headers: {
          "Accept": "application/json",
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {
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

  Future<void> _seleccionarArchivo(String tipo) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: tipo == 'xml' ? ['xml'] : ['pdf'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      if (tipo == 'xml') {
        _xmlFile = result.files.single;
      } else {
        _pdfFile = result.files.single;
      }
    });
  }

  Future<int?> _crearNomina() async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "contador_id": widget.idContador,
        "cliente_id": _clienteSeleccionadoId,
        "empleado_id": widget.empleadoId,
        "periodo": _periodoController.text.trim(),
        "fecha_pago": _fechaPagoController.text.trim().isEmpty
            ? null
            : _fechaPagoController.text.trim(),
        "sueldo_base": double.tryParse(_sueldoBaseController.text.trim()) ?? 0,
        "deducciones": double.tryParse(_deduccionesController.text.trim()) ?? 0,
        "percepciones": double.tryParse(_percepcionesController.text.trim()) ?? 0,
        "total_pagado": double.tryParse(_totalPagadoController.text.trim()) ?? 0,
        "estado": "borrador",
      }),
    );

    final data = json.decode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data["success"] == true) {
      return int.tryParse(data["data"]["id"].toString());
    }

    throw Exception(data["message"] ?? "No se pudo crear la nómina");
  }

  Future<void> _subirRecibos(int nominaId) async {
    if (_pdfFile == null && _xmlFile == null) return;

    setState(() => _subiendo = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/$nominaId/recibos"),
    );

    request.headers["Accept"] = "application/json";

    if (_pdfFile != null) {
      if (_pdfFile!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'pdf',
            _pdfFile!.bytes!,
            filename: _pdfFile!.name,
          ),
        );
      } else if (_pdfFile!.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pdf',
            _pdfFile!.path!,
            filename: _pdfFile!.name,
          ),
        );
      }
    }

    if (_xmlFile != null) {
      if (_xmlFile!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'xml',
            _xmlFile!.bytes!,
            filename: _xmlFile!.name,
          ),
        );
      } else if (_xmlFile!.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'xml',
            _xmlFile!.path!,
            filename: _xmlFile!.name,
          ),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = json.decode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "No se pudieron subir recibos");
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona un cliente/empresa"),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final nominaId = await _crearNomina();

      if (nominaId == null) {
        throw Exception("No se obtuvo ID de nómina");
      }

      await _subirRecibos(nominaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nómina registrada correctamente"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _subiendo = false;
        });
      }
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
        title: const Text("Nuevo recibo de nómina"),
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

            _input(_periodoController, "Periodo"),

            _input(
              _fechaPagoController,
              "Fecha pago YYYY-MM-DD",
              required: false,
            ),

            _input(
              _sueldoBaseController,
              "Sueldo base",
              type: TextInputType.number,
              required: false,
            ),

            _input(
              _percepcionesController,
              "Percepciones",
              type: TextInputType.number,
              required: false,
            ),

            _input(
              _deduccionesController,
              "Deducciones",
              type: TextInputType.number,
              required: false,
            ),

            _input(
              _totalPagadoController,
              "Total pagado",
              type: TextInputType.number,
              required: false,
            ),

            const Divider(height: 28),

            OutlinedButton.icon(
              onPressed: () => _seleccionarArchivo('pdf'),
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                _pdfFile == null
                    ? "Seleccionar PDF"
                    : "PDF: ${_pdfFile!.name}",
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: () => _seleccionarArchivo('xml'),
              icon: const Icon(Icons.code),
              label: Text(
                _xmlFile == null
                    ? "Seleccionar XML"
                    : "XML: ${_xmlFile!.name}",
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed:
                  (_loading || _subiendo)
                      ? null
                      : _guardar,
              icon:
                  (_loading || _subiendo)
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                      )
                      : const Icon(Icons.save),
              label: Text(
                (_loading || _subiendo)
                    ? "Guardando..."
                    : "Guardar nómina",
              ),
            ),
          ],
        ),
      ),
    );
  }
}