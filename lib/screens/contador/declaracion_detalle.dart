import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DeclaracionDetalle extends StatefulWidget {
  final int declaracionId;

  const DeclaracionDetalle({
    super.key,
    required this.declaracionId,
  });

  @override
  State<DeclaracionDetalle> createState() => _DeclaracionDetalleState();
}

class _DeclaracionDetalleState extends State<DeclaracionDetalle> {
  bool _loading = true;
  bool _subiendo = false;
  bool _actualizando = false;

  Map<String, dynamic>? _declaracion;
  PlatformFile? _acuseFile;

  static const String _baseUrl =
      "https://corporativolegaldigital.com/api/contador/declaraciones";

  final List<String> _estados = const [
    'pendiente',
    'en proceso',
    'presentada',
    'cancelada',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDetalle();
  }

  Future<void> _fetchDetalle() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/${widget.declaracionId}"),
        headers: {"Accept": "application/json"},
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _declaracion = Map<String, dynamic>.from(data["data"]);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _seleccionarAcuse() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _acuseFile = result.files.single;
    });
  }

  Future<void> _subirAcuse() async {
    if (_acuseFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un acuse PDF")),
      );
      return;
    }

    setState(() => _subiendo = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/${widget.declaracionId}/acuse"),
      );

      request.headers["Accept"] = "application/json";

      if (_acuseFile!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'archivo',
            _acuseFile!.bytes!,
            filename: _acuseFile!.name,
          ),
        );
      } else if (_acuseFile!.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'archivo',
            _acuseFile!.path!,
            filename: _acuseFile!.name,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Acuse subido")),
        );

        setState(() {
          _acuseFile = null;
        });

        await _fetchDetalle();
      } else {
        throw Exception(data["message"] ?? "No se pudo subir el acuse");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  Future<void> _actualizarEstado(String estado) async {
    setState(() => _actualizando = true);

    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/${widget.declaracionId}/estado"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "estado": estado,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Estado actualizado")),
        );

        await _fetchDetalle();
      } else {
        throw Exception(data["message"] ?? "Error al cambiar estado");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _actualizando = false);
    }
  }

  Future<void> _abrirArchivo(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle declaración"),
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _declaracion == null
              ? const Center(child: Text("Declaración no encontrada"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _info("Cliente", _declaracion!["cliente_nombre"] ?? "N/A"),
                    _info("Tipo", _declaracion!["tipo"] ?? "N/A"),
                    _info("Periodo", _declaracion!["periodo"] ?? "N/A"),
                    _info("Ejercicio", "${_declaracion!["ejercicio"] ?? "N/A"}"),
                    _info("Monto", "\$${_declaracion!["monto"] ?? "0"}"),
                    _info("Estado", _declaracion!["estado"] ?? "N/A"),
                    _info(
                      "Descripción",
                      _declaracion!["descripcion"] ?? "Sin descripción",
                    ),
                    const Divider(height: 32),
                    const Text(
                      "Cambiar estado",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _estados.contains(_declaracion!["estado"])
                          ? _declaracion!["estado"]
                          : 'pendiente',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Estado",
                      ),
                      items: _estados.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: _actualizando
                          ? null
                          : (value) {
                              if (value != null) {
                                _actualizarEstado(value);
                              }
                            },
                    ),
                    const Divider(height: 32),
                    const Text(
                      "Acuse SAT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _seleccionarAcuse,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(
                          _acuseFile == null
                              ? "Seleccionar acuse PDF"
                              : "PDF: ${_acuseFile!.name}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _subiendo ? null : _subirAcuse,
                        icon: _subiendo
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(
                          _subiendo ? "Subiendo..." : "Subir acuse SAT",
                        ),
                      ),
                    ),
                    if ((_declaracion!["archivo_url"] ?? "")
                        .toString()
                        .isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _abrirArchivo(_declaracion!["archivo_url"]),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text("Abrir / imprimir acuse"),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}